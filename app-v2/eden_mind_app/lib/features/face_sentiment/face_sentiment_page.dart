import 'dart:async';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'package:universal_html/html.dart' as html;
import 'package:eden_mind_app/core/utils/web_utils.dart'; // Import the helper
// import 'dart:ui_web' as ui; // Removed direct import
import 'package:flutter/material.dart';
import 'package:eden_mind_app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'face_sentiment_service.dart';
import '../chatbot/chatbot_page.dart';

class FaceSentimentPage extends StatefulWidget {
  const FaceSentimentPage({super.key});

  @override
  State<FaceSentimentPage> createState() => _FaceSentimentPageState();
}

class _FaceSentimentPageState extends State<FaceSentimentPage>
    with TickerProviderStateMixin {
  final FaceSentimentService _sentimentService = FaceSentimentService();

  // State variables
  bool _isAnalyzing = false;
  bool _isServiceAvailable = false;
  bool _isCheckingService = true;
  bool _isCameraActive = false;
  bool _isCameraInitializing = false;
  FaceSentimentResult? _lastResult;
  String? _errorMessage;
  Uint8List? _capturedImage;

  // Camera elements
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  final String _viewId = 'webcam-view-${DateTime.now().millisecondsSinceEpoch}';

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _resultController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _checkServiceAvailability();
    _registerViewFactory();
  }

  void _registerViewFactory() {
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.borderRadius = '32px'
      ..style.transform = 'scaleX(-1)'; // Mirror effect

    // Register the platform view
    WebUtils.registerViewFactory(_viewId, (int viewId) => _videoElement!);
  }

  @override
  void dispose() {
    _stopCamera();
    _pulseController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _checkServiceAvailability() async {
    setState(() => _isCheckingService = true);
    final available = await _sentimentService.isServiceAvailable();
    setState(() {
      _isServiceAvailable = available;
      _isCheckingService = false;
    });
  }

  Future<void> _startCamera() async {
    setState(() {
      _isCameraInitializing = true;
      _errorMessage = null;
      _lastResult = null;
      _capturedImage = null;
    });

    try {
      // Request camera access
      _mediaStream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
        'audio': false,
      });

      if (_mediaStream != null && _videoElement != null) {
        _videoElement!.srcObject = _mediaStream;
        await _videoElement!.play();

        setState(() {
          _isCameraActive = true;
          _isCameraInitializing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCameraInitializing = false;
        _errorMessage =
            'Camera access denied. Please allow camera access and try again.';
      });
    }
  }

  void _stopCamera() {
    if (_mediaStream != null) {
      _mediaStream!.getTracks().forEach((track) => (track as dynamic).stop());
      _mediaStream = null;
    }
    if (_videoElement != null) {
      _videoElement!.srcObject = null;
    }
    setState(() {
      _isCameraActive = false;
    });
  }

  Future<void> _captureAndAnalyze() async {
    if (_videoElement == null || !_isCameraActive) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      // Create a canvas to capture the video frame
      final canvas = html.CanvasElement(
        width: (_videoElement as dynamic).videoWidth,
        height: (_videoElement as dynamic).videoHeight,
      );
      final ctx = canvas.context2D;

      // Draw the current video frame (mirrored)
      ctx.save();
      ctx.scale(-1, 1);
      ctx.drawImage(_videoElement!, -canvas.width!, 0);
      ctx.restore();

      // Convert to blob and then to bytes
      final blob = await canvas.toBlob('image/jpeg', 0.85);
      final reader = html.FileReader();

      final completer = Completer<Uint8List>();
      reader.onLoadEnd.listen((_) {
        final result = reader.result! as List<int>;
        completer.complete(Uint8List.fromList(result));
      });
      reader.readAsArrayBuffer(blob);

      final imageBytes = await completer.future;

      // Stop camera and show captured image
      _stopCamera();
      setState(() => _capturedImage = imageBytes);

      // Analyze emotion
      final result = await _sentimentService.analyzeEmotion(imageBytes);

      setState(() {
        _lastResult = result;
        _isAnalyzing = false;
      });

      // Trigger result animation
      await _resultController.forward(from: 0);

      // Save mood to backend
      await _saveMood(result);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  Future<void> _saveMood(FaceSentimentResult result) async {
    try {
      await _sentimentService.saveMoodFromSentiment(
        emotionType: result.emotion,
        confidence: result.confidence,
      );
    } catch (e) {
      debugPrint('Error saving mood: $e');
    }
  }

  void _startChatWithMood() {
    if (_lastResult == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatbotPage(
          initialMood: _lastResult!.emotion,
          initialMessage: _lastResult!.empatheticMessage,
        ),
      ),
    );
  }

  void _retryCapture() {
    setState(() {
      _lastResult = null;
      _capturedImage = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EdenMindTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isCheckingService
                  ? _buildLoadingState()
                  : !_isServiceAvailable
                  ? _buildServiceUnavailable()
                  : _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              _stopCamera();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Mood Scanner',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: EdenMindTheme.textColor,
                ),
              ),
              Text(
                'Analyze your emotions',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(width: 48),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: EdenMindTheme.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Connecting to emotion service...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceUnavailable() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.cloud_off, size: 64, color: Colors.red[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'Service Unavailable',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: EdenMindTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The face sentiment analysis service is not running.\nPlease start the service and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _checkServiceAvailability,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: EdenMindTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildCameraArea(),
          const SizedBox(height: 24),
          if (_lastResult != null) _buildResultCard(),
          if (_errorMessage != null) _buildErrorCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          if (_lastResult != null) ...[
            const SizedBox(height: 16),
            _buildChatButton(),
          ],
          const SizedBox(height: 32),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildCameraArea() {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: _buildCameraContent(),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale();
  }

  Widget _buildCameraContent() {
    // Show captured image with result
    if (_capturedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(-1.0, 1.0),
            child: Image.memory(_capturedImage!, fit: BoxFit.cover),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: EdenMindTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Analyzing your expression...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          if (_lastResult != null)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getEmotionColor(_lastResult!.emotion),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getEmotionEmoji(_lastResult!.emotion),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _lastResult!.emotion,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // Show live camera feed
    if (_isCameraActive) {
      return Stack(
        fit: StackFit.expand,
        children: [
          HtmlElementView(viewType: _viewId),
          // Camera overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: EdenMindTheme.primaryColor.withOpacity(0.5),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          // Face guide
          Center(
            child: Container(
              width: 200,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Position your face in the frame',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Show initializing state
    if (_isCameraInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: EdenMindTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Starting camera...',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Default state - prompt to start camera
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (_pulseController.value * 0.1),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: EdenMindTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.videocam_rounded,
                    size: 64,
                    color: EdenMindTheme.primaryColor,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Click "Start Camera" to begin\nemotion analysis',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    // After capture - show retry button
    if (_lastResult != null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _retryCapture,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
          style: OutlinedButton.styleFrom(
            foregroundColor: EdenMindTheme.primaryColor,
            side: BorderSide(color: EdenMindTheme.primaryColor),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }

    // Camera is active - show capture button
    if (_isCameraActive) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _captureAndAnalyze,
              icon: Icon(_isAnalyzing ? Icons.hourglass_empty : Icons.camera),
              label: Text(_isAnalyzing ? 'Analyzing...' : 'Capture Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _stopCamera,
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                side: BorderSide(color: Colors.grey[400]!),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Default - show start camera button
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isCameraInitializing ? null : _startCamera,
            icon: Icon(
              _isCameraInitializing ? Icons.hourglass_empty : Icons.videocam,
            ),
            label: Text(_isCameraInitializing ? 'Starting...' : 'Start Camera'),
            style: ElevatedButton.styleFrom(
              backgroundColor: EdenMindTheme.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildResultCard() {
    final result = _lastResult!;
    final emotionColor = _getEmotionColor(result.emotion);

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: emotionColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: emotionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getEmotionEmoji(result.emotion),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.emotion,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: emotionColor,
                          ),
                        ),
                        Text(
                          '${result.confidence.toStringAsFixed(1)}% confidence',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                result.empatheticMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: EdenMindTheme.textColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildEmotionBars(result.allEmotions),
            ],
          ),
        )
        .animate(controller: _resultController)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildEmotionBars(Map<String, double> emotions) {
    final sortedEmotions = emotions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emotion Breakdown',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        ...sortedEmotions.take(5).map((entry) {
          final percentage = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    _capitalize(entry.key),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: EdenMindTheme.primaryColor.withOpacity(
                            0.3 + (percentage / 100 * 0.7),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startChatWithMood,
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Talk to ZenBot about this'),
        style: ElevatedButton.styleFrom(
          backgroundColor: EdenMindTheme.secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EdenMindTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: EdenMindTheme.primaryColor,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Your Privacy is Protected',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: EdenMindTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We only analyze your facial expression to detect your mood. '
            'No images are stored or saved. Your emotional data stays private.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Colors.amber;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'anxious':
        return Colors.orange;
      case 'stressed':
        return Colors.deepOrange;
      case 'excited':
        return Colors.pink;
      case 'neutral':
      default:
        return EdenMindTheme.primaryColor;
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'anxious':
        return '😰';
      case 'stressed':
        return '😫';
      case 'excited':
        return '🤩';
      case 'neutral':
      default:
        return '😐';
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
}
