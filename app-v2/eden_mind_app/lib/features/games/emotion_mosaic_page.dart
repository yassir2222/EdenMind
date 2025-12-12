import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmotionMosaicPage extends StatefulWidget {
  const EmotionMosaicPage({super.key});

  @override
  State<EmotionMosaicPage> createState() => _EmotionMosaicPageState();
}

class _EmotionMosaicPageState extends State<EmotionMosaicPage>
    with TickerProviderStateMixin {
  // Theme colors matching EdenMindTheme
  static const Color primaryColor = Color(0xFFA3A7F4);
  static const Color secondaryColor = Color(0xFFF9D5A2);
  static const Color backgroundColor = Color(0xFFF7F8FD);
  static const Color textColor = Color(0xFF12141D);
  static const Color subTextColor = Color(0xFFA1A4B2);

  final List<EmotionTile> _emotions = [
    EmotionTile(
      name: 'Joie',
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xFFFFD93D),
      gradient: [const Color(0xFFFFE066), const Color(0xFFFFA500)],
    ),
    EmotionTile(
      name: 'Paix',
      icon: Icons.spa_rounded,
      color: const Color(0xFF6BCB77),
      gradient: [const Color(0xFF85E89D), const Color(0xFF3CB371)],
    ),
    EmotionTile(
      name: 'Amour',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFFF6B6B),
      gradient: [const Color(0xFFFF8A8A), const Color(0xFFE91E63)],
    ),
    EmotionTile(
      name: 'Espoir',
      icon: Icons.lightbulb_rounded,
      color: const Color(0xFF4ECDC4),
      gradient: [const Color(0xFF72E2D8), const Color(0xFF00CED1)],
    ),
    EmotionTile(
      name: 'Gratitude',
      icon: Icons.volunteer_activism_rounded,
      color: primaryColor,
      gradient: [const Color(0xFFB8BBFA), primaryColor],
    ),
    EmotionTile(
      name: 'Sérénité',
      icon: Icons.water_drop_rounded,
      color: const Color(0xFF74B9FF),
      gradient: [const Color(0xFF90CAF9), const Color(0xFF2196F3)],
    ),
    EmotionTile(
      name: 'Curiosité',
      icon: Icons.explore_rounded,
      color: secondaryColor,
      gradient: [const Color(0xFFFDEAC8), secondaryColor],
    ),
    EmotionTile(
      name: 'Fierté',
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFFE17055),
      gradient: [const Color(0xFFF08A6E), const Color(0xFFCD5C5C)],
    ),
    EmotionTile(
      name: 'Tendresse',
      icon: Icons.child_care_rounded,
      color: const Color(0xFFFFB8D1),
      gradient: [const Color(0xFFFFCCE5), const Color(0xFFFF69B4)],
    ),
  ];

  final List<SelectedEmotion> _selectedEmotions = [];
  int _currentStep = 0; // 0: intro, 1: select, 2: mosaic

  void _selectEmotion(EmotionTile emotion) {
    setState(() {
      _selectedEmotions.add(SelectedEmotion(emotion: emotion, intensity: 0.7));
    });
  }

  void _removeEmotion(int index) {
    setState(() {
      _selectedEmotions.removeAt(index);
    });
  }

  void _startSelection() {
    setState(() {
      _currentStep = 1;
    });
  }

  void _generateMosaic() {
    if (_selectedEmotions.isEmpty) return;
    setState(() {
      _currentStep = 2;
    });
  }

  void _reset() {
    setState(() {
      _selectedEmotions.clear();
      _currentStep = 0;
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
              child: _currentStep == 0
                  ? _buildIntroScreen()
                  : _currentStep == 1
                  ? _buildSelectionScreen()
                  : _buildMosaicScreen(),
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
          Text(
            'Mosaïque des Émotions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (_currentStep == 1 && _selectedEmotions.isNotEmpty)
            GestureDetector(
              onTap: _generateMosaic,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Créer',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildIntroScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Beautiful intro icon
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withValues(alpha: 0.2),
                        secondaryColor.withValues(alpha: 0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.palette_rounded,
                    size: 60,
                    color: primaryColor,
                  ),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(),

            const SizedBox(height: 40),

            Text(
              'Exprimez vos émotions',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            Text(
              'Créez une mosaïque unique qui représente votre état émotionnel actuel. Choisissez les couleurs qui résonnent avec vous.',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: subTextColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 48),

            GestureDetector(
              onTap: _startSelection,
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
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionScreen() {
    return Column(
      children: [
        // Selected emotions preview
        if (_selectedEmotions.isNotEmpty)
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedEmotions.length,
              itemBuilder: (context, index) {
                final selected = _selectedEmotions[index];
                return GestureDetector(
                  onTap: () => _removeEmotion(index),
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: selected.emotion.gradient,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: selected.emotion.color.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            selected.emotion.icon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
                );
              },
            ),
          ),

        const SizedBox(height: 24),

        // Instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Touchez les émotions qui vous habitent',
            style: GoogleFonts.poppins(fontSize: 15, color: subTextColor),
          ),
        ),

        const SizedBox(height: 24),

        // Emotion Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _emotions.length,
              itemBuilder: (context, index) {
                final emotion = _emotions[index];
                final isSelected = _selectedEmotions.any(
                  (e) => e.emotion.name == emotion.name,
                );

                return GestureDetector(
                  onTap: () => _selectEmotion(emotion),
                  child:
                      Container(
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: emotion.gradient,
                                    )
                                  : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? emotion.color
                                    : Colors.grey.withValues(alpha: 0.2),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? emotion.color.withValues(alpha: 0.3)
                                      : Colors.black.withValues(alpha: 0.05),
                                  blurRadius: isSelected ? 16 : 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  emotion.icon,
                                  size: 36,
                                  color: isSelected
                                      ? Colors.white
                                      : emotion.color,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  emotion.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : textColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(delay: (index * 50).ms)
                          .fadeIn()
                          .scale(begin: const Offset(0.8, 0.8)),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMosaicScreen() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return AspectRatio(
                      aspectRatio: 1,
                      child: _buildMosaicGrid(constraints),
                    );
                  },
                ),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          ),
        ),

        // Legend
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Votre Palette Émotionnelle',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _selectedEmotions.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: e.emotion.gradient),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: e.emotion.color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(e.emotion.icon, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          e.emotion.name,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _reset,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Nouvelle Mosaïque',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMosaicGrid(BoxConstraints constraints) {
    final gridSize = 6;
    final tileSize = constraints.maxWidth / gridSize;
    final random = Random(42);

    return Stack(
      children: List.generate(gridSize * gridSize, (index) {
        final row = index ~/ gridSize;
        final col = index % gridSize;
        final emotionIndex = random.nextInt(_selectedEmotions.length);
        final emotion = _selectedEmotions[emotionIndex].emotion;

        return Positioned(
              left: col * tileSize,
              top: row * tileSize,
              width: tileSize,
              height: tileSize,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: emotion.gradient,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
            .animate(delay: (index * 20).ms)
            .fadeIn()
            .scale(begin: const Offset(0.5, 0.5));
      }),
    );
  }
}

// Data Models
class EmotionTile {
  final String name;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  EmotionTile({
    required this.name,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}

class SelectedEmotion {
  final EmotionTile emotion;
  final double intensity;

  SelectedEmotion({required this.emotion, required this.intensity});
}
