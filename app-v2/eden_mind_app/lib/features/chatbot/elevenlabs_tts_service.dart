import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:eden_mind_app/config/app_config.dart';

/// ElevenLabs Text-to-Speech Service via Backend Proxy (bypasses CORS)
/// with fallback to flutter_tts
class ElevenLabsTtsService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _fallbackTts = FlutterTts();
  bool _isSpeaking = false;
  bool _useBackendTts = true; // Will switch to false if backend fails
  Function? onSpeakingComplete;
  
  bool get isSpeaking => _isSpeaking;
  
  ElevenLabsTtsService() {
    _initFallbackTts();
  }
  
  /// Initialize fallback TTS with cheerful feminine settings
  Future<void> _initFallbackTts() async {
    await _fallbackTts.setLanguage('en-US');
    await _fallbackTts.setSpeechRate(1.0);
    await _fallbackTts.setVolume(1.0);
    await _fallbackTts.setPitch(1.2); // Higher pitch for feminine tone
    
    _fallbackTts.setCompletionHandler(() {
      _isSpeaking = false;
      onSpeakingComplete?.call();
    });
  }
  
  /// Speak text using backend TTS proxy with fallback
  Future<void> speak(String text, {String? voiceId}) async {
    if (text.isEmpty) return;
    
    _isSpeaking = true;
    
    if (_useBackendTts) {
      final success = await _speakWithBackend(text, voiceId: voiceId);
      if (!success) {
        // Fallback to flutter_tts
        debugPrint('Backend TTS failed, using fallback TTS');
        await _speakWithFallback(text);
      }
    } else {
      await _speakWithFallback(text);
    }
  }
  
  /// Speak using backend proxy (which calls ElevenLabs)
  Future<bool> _speakWithBackend(String text, {String? voiceId}) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/tts/speak'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          if (voiceId != null) 'voiceId': voiceId,
        }),
      );
      
      if (response.statusCode == 200) {
        final audioBytes = response.bodyBytes;
        
        // Play audio
        await _audioPlayer.play(BytesSource(audioBytes));
        
        // Listen for completion
        _audioPlayer.onPlayerComplete.listen((_) {
          _isSpeaking = false;
          onSpeakingComplete?.call();
        });
        
        return true;
      } else {
        debugPrint('Backend TTS error: ${response.statusCode}');
        if (response.statusCode == 500) {
          // Backend issue - might be ElevenLabs quota
          _useBackendTts = false;
        }
        return false;
      }
    } catch (e) {
      debugPrint('Backend TTS exception: $e');
      return false;
    }
  }
  
  /// Speak using fallback flutter_tts
  Future<void> _speakWithFallback(String text) async {
    await _fallbackTts.speak(text);
  }
  
  /// Stop speaking
  Future<void> stop() async {
    await _audioPlayer.stop();
    await _fallbackTts.stop();
    _isSpeaking = false;
  }
  
  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
