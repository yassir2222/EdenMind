import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GroundingInventoryPage extends StatefulWidget {
  const GroundingInventoryPage({super.key});

  @override
  State<GroundingInventoryPage> createState() => _GroundingInventoryPageState();
}

class _GroundingInventoryPageState extends State<GroundingInventoryPage>
    with TickerProviderStateMixin {
  // Theme colors matching EdenMindTheme
  static const Color primaryColor = Color(0xFFA3A7F4);
  static const Color secondaryColor = Color(0xFFF9D5A2);
  static const Color backgroundColor = Color(0xFFF7F8FD);
  static const Color textColor = Color(0xFF12141D);
  static const Color subTextColor = Color(0xFFA1A4B2);

  late AnimationController _pulseController;

  int _currentStep = 0; // 0: intro, 1-5: senses
  final List<SenseStep> _senseSteps = [
    SenseStep(
      count: 5,
      sense: 'VUE',
      icon: Icons.visibility_rounded,
      instruction: 'Observez 5 choses que vous voyez',
      hint: 'Les couleurs, les textures, les objets autour de vous...',
      color: primaryColor,
      gradient: [const Color(0xFFB8BBFA), primaryColor],
    ),
    SenseStep(
      count: 4,
      sense: 'TOUCHER',
      icon: Icons.pan_tool_rounded,
      instruction: 'Ressentez 4 choses que vous touchez',
      hint: 'La texture de vos vêtements, la température de l\'air...',
      color: const Color(0xFF4ECDC4),
      gradient: [const Color(0xFF72E2D8), const Color(0xFF4ECDC4)],
    ),
    SenseStep(
      count: 3,
      sense: 'OUÏE',
      icon: Icons.hearing_rounded,
      instruction: 'Écoutez 3 sons autour de vous',
      hint: 'Le vent, des voix lointaines, votre respiration...',
      color: const Color(0xFF6BCB77),
      gradient: [const Color(0xFF85E89D), const Color(0xFF6BCB77)],
    ),
    SenseStep(
      count: 2,
      sense: 'ODORAT',
      icon: Icons.air_rounded,
      instruction: 'Identifiez 2 odeurs',
      hint: 'Un parfum subtil, l\'air frais, une odeur familière...',
      color: secondaryColor,
      gradient: [const Color(0xFFFDEAC8), secondaryColor],
    ),
    SenseStep(
      count: 1,
      sense: 'GOÛT',
      icon: Icons.restaurant_rounded,
      instruction: 'Notez 1 goût',
      hint: 'Le goût dans votre bouche, une saveur récente...',
      color: const Color(0xFFFF6B6B),
      gradient: [const Color(0xFFFF8A8A), const Color(0xFFFF6B6B)],
    ),
  ];

  int _currentEntryCount = 0;
  bool _showCompletion = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  SenseStep get _currentSenseStep => _senseSteps[_currentStep - 1];

  void _startExercise() {
    setState(() {
      _currentStep = 1;
      _currentEntryCount = 0;
    });
  }

  void _addEntry() {
    if (_currentStep < 1 || _currentStep > 5) return;

    final requiredCount = _currentSenseStep.count;

    setState(() {
      _currentEntryCount++;

      if (_currentEntryCount >= requiredCount) {
        // Move to next step
        if (_currentStep < 5) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _currentStep++;
                _currentEntryCount = 0;
              });
            }
          });
        } else {
          // Completed all steps
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _showCompletion = true;
              });
            }
          });
        }
      }
    });
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _currentEntryCount = 0;
      _showCompletion = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _showCompletion
                  ? _buildCompletionScreen()
                  : _currentStep == 0
                  ? _buildIntroScreen()
                  : _buildExerciseScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: textColor),
            ),
          ),
          if (_currentStep >= 1 && !_showCompletion) _buildProgressIndicator(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(5, (index) {
        final isActive = index < _currentStep;
        final isCurrent = index == _currentStep - 1;
        final step = _senseSteps[index];

        return Container(
          width: isCurrent ? 32 : 24,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            gradient: isActive ? LinearGradient(colors: step.gradient) : null,
            color: isActive ? null : Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildIntroScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated circles representing the 5 senses
            SizedBox(
              height: 180,
              width: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center circle
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.self_improvement_rounded,
                        size: 32,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  // Surrounding senses circles
                  ...List.generate(5, (index) {
                    final step = _senseSteps[index];

                    return AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1.0 + (_pulseController.value * 0.1);
                        // Position in a circle
                        final positions = [
                          const Offset(0, -60), // Top
                          const Offset(57, -18), // Top Right
                          const Offset(35, 48), // Bottom Right
                          const Offset(-35, 48), // Bottom Left
                          const Offset(-57, -18), // Top Left
                        ];

                        return Positioned(
                          left: 90 + positions[index].dx - 22,
                          top: 90 + positions[index].dy - 22,
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: step.gradient),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: step.color.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${step.count}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ).animate().fadeIn().scale(),

            const SizedBox(height: 40),

            Text(
              'Technique 5-4-3-2-1',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            Text(
              'Un exercice d\'ancrage sensoriel pour calmer l\'anxiété et vous reconnecter au moment présent.',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: subTextColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 24),

            // Sense labels
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _senseSteps.map((step) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: step.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: step.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(step.icon, color: step.color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        step.sense,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: step.color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 48),

            GestureDetector(
              onTap: _startExercise,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Commencer',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseScreen() {
    final step = _currentSenseStep;
    final remaining = step.count - _currentEntryCount;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          // Large number display
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.05),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: step.gradient,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: step.color.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          step.icon,
                          size: 36,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        Text(
                          '$remaining',
                          style: GoogleFonts.poppins(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 32),

          // Sense name
          Text(
            step.sense,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
              color: step.color,
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 12),

          // Instruction
          Text(
            step.instruction,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          // Hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              step.hint,
              style: GoogleFonts.poppins(fontSize: 13, color: subTextColor),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const Spacer(),

          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(step.count, (index) {
              final isFilled = index < _currentEntryCount;
              return Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  gradient: isFilled
                      ? LinearGradient(colors: step.gradient)
                      : null,
                  color: isFilled ? null : Colors.grey.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color: step.color.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),

          const SizedBox(height: 32),

          // Tap button
          GestureDetector(
            onTap: _addEntry,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: step.gradient),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: step.color.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(step.icon, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'J\'ai identifié un élément',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF85E89D), Color(0xFF6BCB77)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6BCB77).withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(),

            const SizedBox(height: 40),

            Text(
              'Exercice Terminé',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            Text(
              'Vous êtes maintenant ancré dans le moment présent. Prenez quelques respirations profondes.',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: subTextColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 32),

            // Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Récapitulatif',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(5, (index) {
                    final step = _senseSteps[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: step.gradient),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${step.count}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(step.icon, color: step.color, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            step.sense,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.check_circle_rounded,
                            color: step.color,
                            size: 22,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

            const SizedBox(height: 32),

            GestureDetector(
              onTap: _reset,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  'Recommencer',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}

// Data Model
class SenseStep {
  final int count;
  final String sense;
  final IconData icon;
  final String instruction;
  final String hint;
  final Color color;
  final List<Color> gradient;

  SenseStep({
    required this.count,
    required this.sense,
    required this.icon,
    required this.instruction,
    required this.hint,
    required this.color,
    required this.gradient,
  });
}
