import 'package:camera/camera.dart';
import 'package:eden_mind_app/features/games/services/emotion_service.dart';
import 'package:eden_mind_app/features/games/services/face_detector_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class RealtimeEmotionPage extends StatefulWidget {
  const RealtimeEmotionPage({super.key});

  @override
  State<RealtimeEmotionPage> createState() => _RealtimeEmotionPageState();
}

class _RealtimeEmotionPageState extends State<RealtimeEmotionPage> {
  CameraController? _cameraController;
  final FaceDetectorService _faceDetectorService = FaceDetectorService();
  final EmotionService _emotionService = EmotionService();

  bool _isCameraInitialized = false;
  String? _detectedEmotion;
  List<Face> _faces = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Request permission
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      return;
    }

    // Load Model
    await _emotionService.loadModel();

    // Initialize Camera
    final cameras = await availableCameras();
    // Default to front camera
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    try {
      debugPrint("Initializing camera...");
      await _cameraController!.initialize();
      debugPrint("Camera initialized.");
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
      debugPrint("Starting image stream...");
      await _cameraController!.startImageStream(_processImage);
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  void _processImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      // 1. Detect Faces
      final faces = await _faceDetectorService.detectFacesFromImage(image);

      if (mounted) {
        setState(() {
          _faces = faces;
        });
      }

      // 2. Predict Emotion for the largest face
      if (faces.isNotEmpty) {
        debugPrint("Face detected! processing emotion...");
        final face = faces.first;
        final box = face.boundingBox;

        // Ensure coordinates are within image bounds (though service handles clamping, passing correct ROI helps)
        // With CameraImage (landscape/portrait issues), standard is:
        // Android Camera2 API images are usually landscape. FaceDetector coordinates might be rotated.
        // For MVP we assume FaceDetector coordinates map reasonably to the image stream buffer.

        final emotion = await _emotionService.predictEmotion(
          image,
          box.left.toInt(),
          box.top.toInt(),
          box.width.toInt(),
          box.height.toInt(),
        );

        if (mounted) {
          setState(() {
            _detectedEmotion = emotion;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _detectedEmotion = null;
          });
        }
      }
    } catch (e) {
      debugPrint("Processing error: $e");
    } finally {
      // Throttle slightly
      await Future.delayed(const Duration(milliseconds: 200));
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetectorService.dispose();
    _emotionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          CameraPreview(_cameraController!),

          // Overlay for Face Box (Optional, simplified)
          // Since mapping coordinates from camera frame (rotated/scaled) to UI is complex,
          // we stick to a fixed UI overlay for now.

          // Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                                Icons.circle,
                                color: Colors.redAccent,
                                size: 12,
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .fade(duration: 1.seconds),
                          const SizedBox(width: 8),
                          Text(
                            "LIVE",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Sheet with Emotion
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54, // Opaque fallback
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _detectedEmotion ?? "Detecting...",
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getEmotionColor(_detectedEmotion),
                      ),
                    ).animate().scale(duration: 300.ms),
                    const SizedBox(height: 8),
                    Text(
                      _faces.isEmpty
                          ? "Bring your face closer"
                          : "Analyzing your expression...",
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEmotionColor(String? emotion) {
    if (emotion == null) return Colors.white54;
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Colors.greenAccent;
      case 'sad':
        return Colors.blueGrey;
      case 'angry':
        return Colors.redAccent;
      case 'surprise':
        return Colors.orangeAccent;
      case 'fear':
        return Colors.purpleAccent;
      case 'neutral':
        return Colors.white;
      case 'disgust':
        return Colors.brown;
      default:
        return Colors.white;
    }
  }
}
