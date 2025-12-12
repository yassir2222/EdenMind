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
  final Random _random = Random();
  late AnimationController _floatController;

  // Game State
  final List<ZenOrb> _orbs = [];
  ZenOrb? _selectedOrb;
  int _score = 0;
  int _level = 1;
  int _matchesNeeded = 4;
  int _matchesMade = 0;
  bool _showLevelComplete = false;
  bool _showHarmonyEffect = false;
  Offset _harmonyPosition = Offset.zero;
  Color _harmonyColor = Colors.white;

  // Orb colors palette - zen/calm colors
  final List<Color> _orbColors = [
    const Color(0xFF7C4DFF), // Purple
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFF7043), // Coral
    const Color(0xFF66BB6A), // Green
    const Color(0xFFFFCA28), // Amber
    const Color(0xFFEC407A), // Pink
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _startLevel();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _startLevel() {
    setState(() {
      _orbs.clear();
      _selectedOrb = null;
      _matchesMade = 0;
      _matchesNeeded = 4 + _level; // More orbs as level increases
      _showLevelComplete = false;
    });

    // Generate pairs of orbs
    final int pairsCount = _matchesNeeded;
    final List<Color> colorPool = [];

    for (int i = 0; i < pairsCount; i++) {
      final color = _orbColors[i % _orbColors.length];
      colorPool.add(color);
      colorPool.add(color); // Add pair
    }

    colorPool.shuffle(_random);

    // Create orbs at random positions
    for (int i = 0; i < colorPool.length; i++) {
      _orbs.add(
        ZenOrb(
          id: 'orb_$i',
          x: 0.15 + (_random.nextDouble() * 0.7),
          y: 0.2 + (_random.nextDouble() * 0.5),
          color: colorPool[i],
          floatOffset: _random.nextDouble() * 2 * pi,
          floatSpeed: 0.5 + (_random.nextDouble() * 0.5),
          size: 60 + (_random.nextDouble() * 20),
        ),
      );
    }
  }

  void _onOrbTap(ZenOrb orb) {
    if (_showLevelComplete) return;

    if (_selectedOrb == null) {
      // First selection
      setState(() {
        _selectedOrb = orb;
        orb.isSelected = true;
      });
    } else if (_selectedOrb!.id == orb.id) {
      // Deselect same orb
      setState(() {
        _selectedOrb!.isSelected = false;
        _selectedOrb = null;
      });
    } else {
      // Second selection - check for match
      if (_selectedOrb!.color == orb.color) {
        // Match found!
        _onMatch(_selectedOrb!, orb);
      } else {
        // No match - deselect first and select new
        setState(() {
          _selectedOrb!.isSelected = false;
          _selectedOrb = orb;
          orb.isSelected = true;
        });
      }
    }
  }

  void _onMatch(ZenOrb orb1, ZenOrb orb2) {
    // Calculate harmony effect position
    final midX = (orb1.x + orb2.x) / 2;
    final midY = (orb1.y + orb2.y) / 2;

    setState(() {
      _harmonyPosition = Offset(midX, midY);
      _harmonyColor = orb1.color;
      _showHarmonyEffect = true;
      _score += 100 * _level;
      _matchesMade++;

      // Remove matched orbs
      _orbs.removeWhere((o) => o.id == orb1.id || o.id == orb2.id);
      _selectedOrb = null;
    });

    // Hide harmony effect after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showHarmonyEffect = false;
        });
      }
    });

    // Check for level complete
    if (_orbs.isEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showLevelComplete = true;
          });
        }
      });
    }
  }

  void _nextLevel() {
    setState(() {
      _level++;
    });
    _startLevel();
  }

  void _restartGame() {
    setState(() {
      _level = 1;
      _score = 0;
    });
    _startLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animated gradient background
            _buildBackground(),

            // Floating particles (decorative)
            ..._buildParticles(),

            // Orbs
            ..._orbs.map((orb) => _buildOrb(orb)),

            // Harmony effect
            if (_showHarmonyEffect) _buildHarmonyEffect(),

            // HUD
            Positioned(top: 0, left: 0, right: 0, child: _buildHUD()),

            // Level Complete Overlay
            if (_showLevelComplete) _buildLevelComplete(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                sin(_floatController.value * 2 * pi) * 0.3,
                cos(_floatController.value * 2 * pi) * 0.3,
              ),
              radius: 1.5,
              colors: const [
                Color(0xFF2D2D44), // Dark purple-gray
                Color(0xFF1A1A2E), // Very dark blue
                Color(0xFF0F0F1A), // Almost black
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildParticles() {
    return List.generate(15, (index) {
      final x = _random.nextDouble();
      final y = _random.nextDouble();
      final size = 2 + _random.nextDouble() * 4;
      final opacity = 0.1 + _random.nextDouble() * 0.3;

      return Positioned(
        left: MediaQuery.of(context).size.width * x,
        top: MediaQuery.of(context).size.height * y,
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final offset =
                sin((_floatController.value + index * 0.1) * 2 * pi) * 10;
            return Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: opacity),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: opacity * 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildOrb(ZenOrb orb) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset =
            sin(
              (_floatController.value + orb.floatOffset) *
                  2 *
                  pi *
                  orb.floatSpeed,
            ) *
            15;

        return Positioned(
          left: orb.x * screenSize.width - orb.size / 2,
          top: orb.y * screenSize.height - orb.size / 2 + floatOffset,
          child: GestureDetector(
            onTap: () => _onOrbTap(orb),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: orb.size,
              height: orb.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  radius: 0.8,
                  colors: [
                    orb.color.withValues(alpha: 0.9),
                    orb.color,
                    orb.color.withValues(alpha: 0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: orb.color.withValues(
                      alpha: orb.isSelected ? 0.8 : 0.4,
                    ),
                    blurRadius: orb.isSelected ? 30 : 20,
                    spreadRadius: orb.isSelected ? 10 : 5,
                  ),
                ],
                border: orb.isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
              ),
              child: Center(
                child: Container(
                  width: orb.size * 0.3,
                  height: orb.size * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHarmonyEffect() {
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: _harmonyPosition.dx * screenSize.width - 75,
      top: _harmonyPosition.dy * screenSize.height - 75,
      child:
          Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _harmonyColor.withValues(alpha: 0.8),
                      _harmonyColor.withValues(alpha: 0.4),
                      _harmonyColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    "+${100 * _level}",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.5, 1.5),
                duration: 600.ms,
              )
              .fadeOut(delay: 400.ms, duration: 400.ms),
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                // Title and level
                Column(
                  children: [
                    Text(
                      "Harmonie Zen",
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        "Niveau $_level",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildGlassButton(
                  icon: Icons.refresh_rounded,
                  onTap: _restartGame,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Score and progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Score
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFCA28).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.stars_rounded,
                          color: Color(0xFFFFCA28),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "$_score",
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Progress
                  Row(
                    children: [
                      Text(
                        "Paires: $_matchesMade/$_matchesNeeded",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 60,
                        height: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: _matchesMade / _matchesNeeded,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF66BB6A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Instructions
            Text(
              "Tapez sur deux orbes de même couleur pour les fusionner",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
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
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelComplete() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Celebration icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFCA28),
                          const Color(0xFFFF9800),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFCA28).withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Harmonie Atteinte!",
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Niveau $_level complété",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Color(0xFFFFCA28),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Score: $_score",
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      // Restart button
                      OutlinedButton(
                        onPressed: _restartGame,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          "Recommencer",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Next Level button
                      ElevatedButton(
                        onPressed: _nextLevel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C4DFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                          shadowColor: const Color(
                            0xFF7C4DFF,
                          ).withValues(alpha: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Niveau ${_level + 1}",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
        ),
      ),
    );
  }
}

// Data model for Zen Orbs
class ZenOrb {
  final String id;
  double x;
  double y;
  final Color color;
  final double floatOffset;
  final double floatSpeed;
  final double size;
  bool isSelected;

  ZenOrb({
    required this.id,
    required this.x,
    required this.y,
    required this.color,
    required this.floatOffset,
    required this.floatSpeed,
    required this.size,
    this.isSelected = false,
  });
}
