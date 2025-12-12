import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class DistortionHunterPage extends StatefulWidget {
  const DistortionHunterPage({super.key});

  @override
  State<DistortionHunterPage> createState() => _DistortionHunterPageState();
}

class _DistortionHunterPageState extends State<DistortionHunterPage>
    with TickerProviderStateMixin {
  final Random _random = Random();
  late AnimationController _gameLoopController;

  // Game State
  final List<CloudEntity> _clouds = [];
  final List<SunEntity> _suns = [];
  int _score = 0;
  bool _isPaused = false;
  final bool _isGameOver = false;

  // Feedback State
  bool _showFeedbackOverlay = false;
  bool _feedbackIsSuccess = false;
  String _feedbackMessage = '';

  // Spawning
  Timer? _spawnTimer;
  final double _spawnRate = 3.5;

  @override
  void initState() {
    super.initState();
    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateGame);

    _startGame();
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _gameLoopController.repeat();
    _spawnTimer = Timer.periodic(
      Duration(milliseconds: (_spawnRate * 1000).toInt()),
      (timer) {
        if (!_isPaused && !_isGameOver) {
          _spawnCloud();
        }
      },
    );
  }

  void _spawnCloud() {
    setState(() {
      final double startX = _random.nextDouble() * 0.7 + 0.15;
      final thought = _gameData[_random.nextInt(_gameData.length)];

      _clouds.add(
        CloudEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          x: startX,
          y: -0.3,
          thought: thought,
          speed: 0.0015 + (_random.nextDouble() * 0.0015),
          scale: 0.8 + (_random.nextDouble() * 0.4),
        ),
      );
    });
  }

  void _updateGame() {
    if (_isPaused || _isGameOver) return;

    setState(() {
      for (var cloud in _clouds) {
        cloud.y += cloud.speed;
      }
      _clouds.removeWhere((cloud) => cloud.y > 1.2);
    });
  }

  void _pauseGame() {
    setState(() {
      _isPaused = true;
      _gameLoopController.stop();
    });
  }

  void _resumeGame() {
    setState(() {
      _isPaused = false;
      _gameLoopController.repeat();
    });
  }

  void _onCloudTap(CloudEntity cloud) {
    _pauseGame();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      isScrollControlled: true,
      builder: (context) => _buildWeaponSelectionSheet(cloud),
    ).then((_) {
      if (_isPaused && !_showFeedbackOverlay) {
        _resumeGame();
      }
    });
  }

  void _handleDistortionSelection(
    CloudEntity cloud,
    DistortionType selectedType,
  ) {
    Navigator.pop(context);

    if (selectedType == cloud.thought.correctDistortion) {
      _showFeedback(true, "Correct! ${cloud.thought.correctDistortion.label}");
      _transformCloudToSun(cloud);
    } else {
      _showFeedback(
        false,
        "Oops! It was ${cloud.thought.correctDistortion.label}",
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showFeedbackOverlay = false;
          });
          _resumeGame();
        }
      });
    }
  }

  void _showFeedback(bool success, String message) {
    setState(() {
      _showFeedbackOverlay = true;
      _feedbackIsSuccess = success;
      _feedbackMessage = message;
    });
  }

  void _transformCloudToSun(CloudEntity cloud) {
    setState(() {
      _clouds.remove(cloud);
      _suns.add(
        SunEntity(
          id: cloud.id,
          x: cloud.x,
          y: cloud.y,
          rationalThought: cloud.thought.rationalResponse,
        ),
      );
      _score++;
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _suns.removeWhere((s) => s.id == cloud.id);
          _showFeedbackOverlay = false;
        });
        _resumeGame();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1BFFFF), // Match bottom of gradient
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Premium Dynamic Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2E3192), // Deep calming blue
                      Color(0xFF1BFFFF), // Bright cyan accent
                    ],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
            // Soft overlay for depth
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

            // Game Elements
            ..._clouds.map((cloud) => _buildCloud(cloud)),
            ..._suns.map((sun) => _buildSun(sun)),

            // HUD - Fixed at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGlassButton(
                        icon: _isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        onTap: _isPaused ? _resumeGame : _pauseGame,
                      ),
                      _buildScoreBadge(),
                      _buildGlassButton(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Feedback Overlay
            if (_showFeedbackOverlay) _buildFeedbackOverlay(),

            // Pause Overlay
            if (_isPaused &&
                !_showFeedbackOverlay &&
                !ModalRoute.of(context)!.isCurrent)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pause_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'PAUSED',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.wb_sunny_rounded,
                color: Color(0xFFFFD700),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '$_score',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildCloud(CloudEntity cloud) {
    return Positioned(
      left: MediaQuery.of(context).size.width * cloud.x - (100 * cloud.scale),
      top: MediaQuery.of(context).size.height * cloud.y,
      child: GestureDetector(
        onTap: () => _onCloudTap(cloud),
        child:
            SizedBox(
                  width: 220 * cloud.scale,
                  height: 140 * cloud.scale,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cloud Shape with Shadow
                      CustomPaint(
                        size: Size(220 * cloud.scale, 140 * cloud.scale),
                        painter: CloudPainter(
                          color: Colors.white.withValues(alpha: 0.9),
                          shadowColor: const Color(
                            0xFF2E3192,
                          ).withValues(alpha: 0.3),
                        ),
                      ),
                      // Text Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          cloud.thought.negativeThought,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF4A5568),
                            fontSize: 14 * cloud.scale,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: 0,
                  end: 15,
                  duration: 4000.ms,
                  curve: Curves.easeInOut,
                ),
      ),
    );
  }

  Widget _buildSun(SunEntity sun) {
    return Positioned(
      left: MediaQuery.of(context).size.width * sun.x - 90,
      top: MediaQuery.of(context).size.height * sun.y,
      child:
          Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFFFF9C4),
                      Color(0xFFFFD700),
                      Color(0xFFFFA000),
                    ],
                    stops: [0.2, 0.6, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Color(0xFFE65100),
                          size: 36,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sun.rationalThought,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFBF360C),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate()
              .scale(duration: 800.ms, curve: Curves.elasticOut)
              .fadeIn()
              .shimmer(
                duration: 2000.ms,
                color: Colors.white.withValues(alpha: 0.6),
              ),
    );
  }

  Widget _buildWeaponSelectionSheet(CloudEntity cloud) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Identify the Distortion",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "What kind of thinking trap is this?",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF718096),
                ),
              ),
              const SizedBox(height: 32),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: DistortionType.values.map((type) {
                  return _buildDistortionOption(cloud, type);
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistortionOption(CloudEntity cloud, DistortionType type) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleDistortionSelection(cloud, type),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFFF7FAFC), const Color(0xFFEDF2F7)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA3A7F4).withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA3A7F4).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  type.icon,
                  size: 28,
                  color: const Color(0xFF5A67D8),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                type.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackOverlay() {
    return Center(
      child:
          ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _feedbackIsSuccess
                                ? const Color(0xFFC6F6D5)
                                : const Color(0xFFFED7D7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _feedbackIsSuccess
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            size: 48,
                            color: _feedbackIsSuccess
                                ? const Color(0xFF2F855A)
                                : const Color(0xFFC53030),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _feedbackIsSuccess ? 'Well Done!' : 'Not Quite',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _feedbackMessage,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: const Color(0xFF718096),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 300.ms),
    );
  }
}

class CloudPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  CloudPainter({required this.color, required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final path = Path();

    // More organic cloud shape
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.25, size.height * 0.6),
        radius: size.height * 0.45,
      ),
    );
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.5),
        radius: size.height * 0.55,
      ),
    );
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 0.6),
        radius: size.height * 0.4,
      ),
    );
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.55, size.height * 0.7),
        radius: size.height * 0.35,
      ),
    );

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Data Models ---

class CloudEntity {
  final String id;
  double x;
  double y;
  final ThoughtData thought;
  final double speed;
  final double scale;

  CloudEntity({
    required this.id,
    required this.x,
    required this.y,
    required this.thought,
    required this.speed,
    this.scale = 1.0,
  });
}

class SunEntity {
  final String id;
  final double x;
  final double y;
  final String rationalThought;

  SunEntity({
    required this.id,
    required this.x,
    required this.y,
    required this.rationalThought,
  });
}

class ThoughtData {
  final String negativeThought;
  final DistortionType correctDistortion;
  final String rationalResponse;

  const ThoughtData({
    required this.negativeThought,
    required this.correctDistortion,
    required this.rationalResponse,
  });
}

enum DistortionType {
  allOrNothing,
  overgeneralization,
  mentalFilter,
  mindReading,
}

extension DistortionTypeExtension on DistortionType {
  String get label {
    switch (this) {
      case DistortionType.allOrNothing:
        return 'All-or-Nothing';
      case DistortionType.overgeneralization:
        return 'Overgeneralization';
      case DistortionType.mentalFilter:
        return 'Mental Filter';
      case DistortionType.mindReading:
        return 'Mind Reading';
    }
  }

  IconData get icon {
    switch (this) {
      case DistortionType.allOrNothing:
        return Icons.filter_list_rounded;
      case DistortionType.overgeneralization:
        return Icons.trending_down_rounded;
      case DistortionType.mentalFilter:
        return Icons.filter_alt_rounded;
      case DistortionType.mindReading:
        return Icons.psychology_rounded;
    }
  }
}

// --- Game Data ---

const List<ThoughtData> _gameData = [
  ThoughtData(
    negativeThought: "I always mess things up.",
    correctDistortion: DistortionType.overgeneralization,
    rationalResponse: "I make mistakes sometimes, but I also succeed often.",
  ),
  ThoughtData(
    negativeThought: "If I'm not perfect, I'm a failure.",
    correctDistortion: DistortionType.allOrNothing,
    rationalResponse: "Progress is more important than perfection.",
  ),
  ThoughtData(
    negativeThought: "They didn't say hi, they must hate me.",
    correctDistortion: DistortionType.mindReading,
    rationalResponse: "They might just be busy or didn't see me.",
  ),
  ThoughtData(
    negativeThought: "My presentation had a typo, it was a disaster.",
    correctDistortion: DistortionType.mentalFilter,
    rationalResponse: "The typo was small, the rest went really well.",
  ),
  ThoughtData(
    negativeThought: "I'll never succeed at anything.",
    correctDistortion: DistortionType.overgeneralization,
    rationalResponse: "This is just one setback, not my whole future.",
  ),
];
