import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eden_mind_app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

  // State variables
  bool _isAnalyzing = false;
  bool _isServiceAvailable = false;
  bool _isCheckingService = true;
  FaceSentimentResult? _lastResult;
  String? _errorMessage;
  Uint8List? _capturedImage;

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
  }

  @override
  void dispose() {
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

  Future<void> _captureFromCamera() async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _lastResult = null;
    });

    try {
      // Use camera to capture image
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 600,
      );

      if (image == null) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = 'Photo capture cancelled';
        });
        return;
      }

      // Read image bytes
      final imageBytes = await image.readAsBytes();
      setState(() => _capturedImage = imageBytes);

      // Analyze emotion
      final result = await _sentimentService.analyzeEmotion(imageBytes);

      setState(() {
        _lastResult = result;
        _isAnalyzing = false;
      });

      // Trigger result animation
      _resultController.forward(from: 0);

      // Save mood to backend
      await _saveMood(result);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _lastResult = null;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 600,
      );

      if (image == null) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = 'No image selected';
        });
        return;
      }

      final imageBytes = await image.readAsBytes();
      setState(() => _capturedImage = imageBytes);

      final result = await _sentimentService.analyzeEmotion(imageBytes);

      setState(() {
        _lastResult = result;
        _isAnalyzing = false;
      });

      _resultController.forward(from: 0);
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
            onPressed: () => Navigator.pop(context),
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
          _buildImageArea(),
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

  Widget _buildImageArea() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: _buildImageContent(),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale();
  }

  Widget _buildImageContent() {
    if (_capturedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(_capturedImage!, fit: BoxFit.cover),
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

    // Default state
    return Column(
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
                  Icons.face_retouching_natural,
                  size: 64,
                  color: EdenMindTheme.primaryColor,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Take a selfie or choose a photo\nto analyze your emotions',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
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

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _captureFromCamera,
            icon: Icon(_isAnalyzing ? Icons.hourglass_empty : Icons.camera_alt),
            label: Text(_isAnalyzing ? 'Analyzing...' : 'Take a Selfie'),
            style: ElevatedButton.styleFrom(
              backgroundColor: EdenMindTheme.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isAnalyzing ? null : _pickFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              foregroundColor: EdenMindTheme.primaryColor,
              side: BorderSide(color: EdenMindTheme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
