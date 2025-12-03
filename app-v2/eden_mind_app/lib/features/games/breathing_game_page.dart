import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class BreathingGamePage extends StatefulWidget {
  const BreathingGamePage({super.key});

  @override
  State<BreathingGamePage> createState() => _BreathingGamePageState();
}

class _BreathingGamePageState extends State<BreathingGamePage>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _gameTimer;
  int _elapsedSeconds = 0;
  int _score = 0;
  bool _isInhaling = false;
  bool _isPlaying = false;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4 seconds inhale/exhale
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Inhale complete, switch to exhale logic if auto-looping,
        // but here we want user control.
        // For this game: "Tap & Hold to Inhale".
        // So when holding, it animates forward. When released, it animates reverse.
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _gameTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _showOverlay = false;
      _isPlaying = true;
      _elapsedSeconds = 0;
      _score = 0;
    });
    _startTimer();
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _onInhaleStart() async {
    if (!_isPlaying) return;
    setState(() {
      _isInhaling = true;
    });
    _breathingController.forward();
    // Play inhale sound
    try {
      await _audioPlayer.stop();
      // await _audioPlayer.play(AssetSource('sounds/inhale.mp3'));
      // Placeholder for sound logic
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _onExhaleStart() async {
    if (!_isPlaying) return;
    setState(() {
      _isInhaling = false;
      // Simple score increment for completing a cycle (mock logic)
      if (_breathingController.value > 0.8) {
        _score += 100;
      }
    });
    _breathingController.reverse();
    // Play exhale sound
    try {
      await _audioPlayer.stop();
      // await _audioPlayer.play(AssetSource('sounds/exhale.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  String _formatTime(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: Stack(
        children: [
          // Background Illustration
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBWnIfK5KXrVxBRNp5cxzlcpNSxoVowNR1_rAjrrYktZxEER5PmlogBXNq1I_N48DMZAi48EK91e4HQtU0KrGoX4mjKgEjXQF9wON0BAnVzgdja86_hRaNMb7mhw1u17PuuIUtBRrD832FbcfDTeF1Mv4YOGhDxs7Yy8IvHIPzhdgDvI6jZSiqGIRpqTKFSu9Xs_TdZW0CBCOOgxIHB46Nbf5doxrMqeuPZKRZwRx_zTzNk1CtxJ7MLxJBCgyocsneJL5fdvy185ZI',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatusBar(),
                        const Spacer(),
                        _buildBreathingArea(),
                        const Spacer(),
                        Text(
                              'Tap & Hold to Inhale',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: const Color(0xFFA1A4B2),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .fade(duration: 1200.ms, begin: 0.5, end: 1.0),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showOverlay) _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            icon: Icons.chevron_left,
            onTap: () => Navigator.pop(context),
            iconSize: 32,
          ),
          Text(
            'Deep Breathing Game',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF12141D),
            ),
          ),
          _buildCircleButton(
            icon: Icons.settings_outlined,
            onTap: () {},
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required double iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Colors
              .transparent, // Transparent in design? Or white? Design has transparent header bg but buttons might be.
          // Design header buttons look like simple icons, but let's stick to the style.
          // Actually design shows just icons.
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: const Color(0xFF12141D), size: iconSize),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SCORE',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFA1A4B2),
              ),
            ),
            Text(
              '$_score',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF12141D),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'TIME',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFA1A4B2),
              ),
            ),
            Text(
              _formatTime(_elapsedSeconds),
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF12141D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreathingArea() {
    return GestureDetector(
      onTapDown: (_) => _onInhaleStart(),
      onTapUp: (_) => _onExhaleStart(),
      onTapCancel: () => _onExhaleStart(),
      child: SizedBox(
        width: 320,
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Guidance Ring
            Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFA3A7F4).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),
            // Target Zone Ring (Dashed)
            SizedBox(
              width: 272, // 85% of 320
              height: 272,
              child: CustomPaint(
                painter: DashedCirclePainter(
                  color: const Color(0xFFF9D5A2),
                  strokeWidth: 2,
                  dashPattern: [8, 6],
                ),
              ),
            ),
            // Main Breathing Circle
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 213, // 2/3 of 320
                    height: 213,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA3A7F4),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA3A7F4).withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isInhaling ? 'Inhale...' : 'Exhale...',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA3A7F4).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.air, // Closest to 'pulmonology'
                      size: 40,
                      color: Color(0xFFA3A7F4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Breathing Game',
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF12141D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Match your breath to the circle. Hold to breathe in, release to breathe out.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: const Color(0xFFA1A4B2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA3A7F4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: const Color(
                          0xFFA3A7F4,
                        ).withValues(alpha: 0.3),
                      ),
                      child: Text(
                        'Start',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashPattern = const [5, 5],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path dashedPath = _createDashedPath(path);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      int index = 0;
      while (distance < metric.length) {
        final double len = dashPattern[index % dashPattern.length];
        if (distance + len > metric.length) {
          dest.addPath(
            metric.extractPath(distance, metric.length),
            Offset.zero,
          );
          break;
        }
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += len;
        index++;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashPattern != dashPattern;
  }
}
