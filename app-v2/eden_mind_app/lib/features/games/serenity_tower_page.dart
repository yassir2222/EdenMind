import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SerenityTowerPage extends StatefulWidget {
  const SerenityTowerPage({super.key});

  @override
  State<SerenityTowerPage> createState() => _SerenityTowerPageState();
}

class _SerenityTowerPageState extends State<SerenityTowerPage>
    with TickerProviderStateMixin {
  late AnimationController _gameLoopController;
  final Random _random = Random();

  // Game State
  final List<StoneEntity> _stones = [];
  StoneEntity? _activeStone;

  bool _isGameOver = false;
  final bool _isPaused = false;
  double _stability = 1.0; // 1.0 = perfectly stable, 0.0 = collapse

  // Physics Constants
  static const double _gravity = 0.5;
  static const double _friction = 0.9;
  static const double _groundY = 0.85; // % of screen height

  @override
  void initState() {
    super.initState();
    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateGame);

    _spawnNewStone();
    _startGame();
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    super.dispose();
  }

  void _startGame() {
    _gameLoopController.repeat();
  }

  void _spawnNewStone() {
    // Spawn a stone at the top
    setState(() {
      _activeStone = StoneEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        x: 0.5, // Center
        y: 0.15, // Top area
        width: 0.2 + (_random.nextDouble() * 0.1), // Random width
        height: 0.1 + (_random.nextDouble() * 0.05), // Random height
        color: _getRandomStoneColor(),
        points: _generateOrganicShape(),
      );
    });
  }

  Color _getRandomStoneColor() {
    final colors = [
      const Color(0xFF8D6E63), // Brown
      const Color(0xFFA1887F), // Light Brown
      const Color(0xFF795548), // Dark Brown
      const Color(0xFFBCAAA4), // Beige
      const Color(0xFF5D4037), // Darker Brown
      const Color(0xFF78909C), // Blue Grey (Stone-like)
    ];
    return colors[_random.nextInt(colors.length)];
  }

  List<Offset> _generateOrganicShape() {
    // Generate a somewhat irregular polygon/blob for the stone
    // This is a simplified version, just a perturbed rectangle for now
    return [
      const Offset(0, 0),
      const Offset(1, 0),
      const Offset(1, 1),
      const Offset(0, 1),
    ];
  }

  void _updateGame() {
    if (_isPaused || _isGameOver) return;

    setState(() {
      // Physics Step
      for (var stone in _stones) {
        _applyPhysics(stone);
      }

      // Check Stability
      _checkStability();
    });
  }

  void _applyPhysics(StoneEntity stone) {
    if (stone.isHeld) return;

    // Apply Gravity
    stone.vy += _gravity * 0.01;
    stone.y += stone.vy;

    // Ground Collision
    if (stone.y + stone.height >= _groundY) {
      stone.y = _groundY - stone.height;
      stone.vy = 0;
      stone.vx *= _friction; // Apply friction
      stone.isGrounded = true;
    } else {
      stone.isGrounded = false;
    }

    // Simple Stack Collision (Very basic AABB for now)
    for (var other in _stones) {
      if (stone == other) continue;

      // Check if stone is above other
      if (stone.y < other.y &&
          stone.y + stone.height > other.y &&
          stone.x < other.x + other.width &&
          stone.x + stone.width > other.x) {
        stone.y = other.y - stone.height;
        stone.vy = 0;
        stone.vx *= _friction;
        stone.isGrounded = true;
      }
    }
  }

  void _checkStability() {
    if (_stones.isEmpty) {
      _stability = 1.0;
      return;
    }

    // Calculate Center of Mass (CoM) of the stack
    double totalMass = 0;
    double weightedX = 0;

    // Find the base stone (lowest one)
    StoneEntity? baseStone;
    double maxY = -1;

    for (var stone in _stones) {
      // Simple mass approximation based on area
      double mass = stone.width * stone.height;
      totalMass += mass;
      weightedX += (stone.x + stone.width / 2) * mass;

      if (stone.y > maxY) {
        maxY = stone.y;
        baseStone = stone;
      }
    }

    if (baseStone == null || totalMass == 0) return;

    double comX = weightedX / totalMass;

    // Check if CoM is within the base support
    // For simplicity, we assume the "base" is the bottom-most stone's width
    // In a real tower, we'd check each level, but this is a good approximation for "overall" balance
    double baseLeft = baseStone.x;
    double baseRight = baseStone.x + baseStone.width;

    // Calculate stability score
    // 1.0 if CoM is perfectly centered in base
    // 0.0 if CoM is at the edge
    // < 0.0 if CoM is outside (collapse)

    double distToEdge = min((comX - baseLeft).abs(), (baseRight - comX).abs());
    double halfBase = baseStone.width / 2;

    if (comX < baseLeft || comX > baseRight) {
      _stability = 0.0;
      _triggerCollapse();
    } else {
      _stability = (distToEdge / halfBase).clamp(0.0, 1.0);
    }
  }

  void _triggerCollapse() {
    if (_isGameOver) return;
    // Make stones fall
    for (var stone in _stones) {
      stone.isGrounded = false;
      stone.vx = (stone.x - 0.5) * 0.1; // Explode outwards slightly
    }
    _isGameOver = true;
  }

  void _onPanStart(DragStartDetails details) {
    if (_activeStone == null) return;

    // Check if touch is inside active stone (simplified)
    // In a real scenario, we'd check screen coordinates vs stone rect
    setState(() {
      _activeStone!.isHeld = true;
      _activeStone!.vx = 0;
      _activeStone!.vy = 0;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeStone == null || !_activeStone!.isHeld) return;

    final screenSize = MediaQuery.of(context).size;

    setState(() {
      _activeStone!.x += details.delta.dx / screenSize.width;
      _activeStone!.y += details.delta.dy / screenSize.height;

      // Velocity tracking for "throw" or "drop" momentum
      _activeStone!.vx = details.delta.dx / screenSize.width;
      _activeStone!.vy = details.delta.dy / screenSize.height;
    });

    // Speed check
    double speed = details.delta.distance;
    if (speed > 20) {
      // Too fast!
      setState(() {
        _activeStone!.isUnstable = true;
      });
    } else {
      if (_activeStone!.isUnstable) {
        setState(() {
          _activeStone!.isUnstable = false;
        });
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_activeStone == null) return;

    setState(() {
      _activeStone!.isHeld = false;
      // Transfer velocity
      _activeStone!.vx =
          details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width *
          0.01;
      _activeStone!.vy =
          details.velocity.pixelsPerSecond.dy /
          MediaQuery.of(context).size.height *
          0.01;

      // If dropped near the stack, add to stones list and spawn new one
      if (_activeStone!.y > 0.4) {
        _stones.add(_activeStone!);
        _activeStone = null;

        // Delay spawn
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_isGameOver) {
            _spawnNewStone();
          }
        });
      } else {
        // Reset position if dropped too high/invalid
        _activeStone!.x = 0.5;
        _activeStone!.y = 0.15;
        _activeStone!.vx = 0;
        _activeStone!.vy = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          _buildBackground(),

          // Game Layer
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              color: Colors.transparent, // Hit test
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  // Ground
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: MediaQuery.of(context).size.height * (1 - _groundY),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Stones
                  ..._stones.map((s) => _buildStone(s)),
                  if (_activeStone != null) _buildStone(_activeStone!),
                ],
              ),
            ),
          ),

          // HUD
          _buildHUD(),

          // Game Over Overlay
          if (_isGameOver)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Tower Collapsed",
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF455A64),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Breathe. Focus. Try again.",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: const Color(0xFF78909C),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _stones.clear();
                              _isGameOver = false;
                              _stability = 1.0;
                              _spawnNewStone();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D6E63),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            "Restart",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn().scale(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE0F7FA), // Zen Cyan Light
            Color(0xFFE1F5FE), // Light Blue
            Color(0xFFF3E5F5), // Light Purple
          ],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(color: Colors.white.withValues(alpha: 0.3)),
      ),
    );
  }

  Widget _buildStone(StoneEntity stone) {
    final screenSize = MediaQuery.of(context).size;
    return Positioned(
      left: stone.x * screenSize.width,
      top: stone.y * screenSize.height,
      width: stone.width * screenSize.width,
      height: stone.height * screenSize.height,
      child: CustomPaint(painter: StonePainter(color: stone.color)),
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                Text(
                  "Serenity Tower",
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF455A64),
                    letterSpacing: 1.2,
                  ),
                ),
                _buildGlassButton(
                  icon: Icons.refresh_rounded,
                  onTap: () {
                    setState(() {
                      _stones.clear();
                      _spawnNewStone();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Stability Meter (Placeholder)
            Container(
              height: 6,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _stability,
                child: Container(
                  decoration: BoxDecoration(
                    color: _stability > 0.5 ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: const Color(0xFF455A64), size: 24),
          ),
        ),
      ),
    );
  }
}

class StonePainter extends CustomPainter {
  final Color color;

  StonePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Organic shape using Bezier curves
    final path = Path();
    path.moveTo(size.width * 0.2, 0);
    path.quadraticBezierTo(
      size.width * 0.8,
      -size.height * 0.1,
      size.width,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 1.1,
      size.height * 0.8,
      size.width * 0.7,
      size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 1.1,
      0,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      -size.width * 0.1,
      size.height * 0.2,
      size.width * 0.2,
      0,
    );
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.addOval(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.2,
        size.width * 0.3,
        size.height * 0.2,
      ),
    );
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StoneEntity {
  final String id;
  double x; // 0.0 to 1.0 (screen width)
  double y; // 0.0 to 1.0 (screen height)
  double width; // 0.0 to 1.0
  double height; // 0.0 to 1.0
  double vx;
  double vy;
  final Color color;
  final List<Offset> points;
  bool isHeld;
  bool isGrounded;
  bool isUnstable;

  StoneEntity({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
    required this.points,
    this.vx = 0,
    this.vy = 0,
    this.isHeld = false,
    this.isGrounded = false,
    this.isUnstable = false,
  });
}
