import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GratitudeJarPage extends StatefulWidget {
  const GratitudeJarPage({super.key});

  @override
  State<GratitudeJarPage> createState() => _GratitudeJarPageState();
}

class _GratitudeJarPageState extends State<GratitudeJarPage>
    with TickerProviderStateMixin {
  // Theme colors matching EdenMindTheme
  static const Color primaryColor = Color(0xFFA3A7F4);
  static const Color secondaryColor = Color(0xFFF9D5A2);
  static const Color backgroundColor = Color(0xFFF7F8FD);
  static const Color textColor = Color(0xFF12141D);
  static const Color subTextColor = Color(0xFFA1A4B2);

  late AnimationController _floatController;
  final TextEditingController _textController = TextEditingController();
  final List<GratitudeNote> _notes = [];
  Timer? _celebrationTimer;
  bool _showInput = false;
  bool _showCelebration = false;

  // Beautiful note colors
  final List<Color> _noteColors = [
    const Color(0xFFFFE066), // Yellow
    const Color(0xFFFF8A8A), // Pink
    const Color(0xFF90CAF9), // Blue
    const Color(0xFF85E89D), // Green
    const Color(0xFFFFB74D), // Orange
    const Color(0xFFC9A7C7), // Purple
    const Color(0xFF4DD0E1), // Cyan
    primaryColor,
    secondaryColor,
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _textController.dispose();
    _celebrationTimer?.cancel();
    super.dispose();
  }

  void _addGratitude() {
    if (_textController.text.trim().isEmpty) return;

    final random = Random();
    setState(() {
      _notes.add(
        GratitudeNote(
          text: _textController.text.trim(),
          color: _noteColors[random.nextInt(_noteColors.length)],
          rotation: (random.nextDouble() - 0.5) * 0.3,
          xOffset: (random.nextDouble() - 0.5) * 40,
        ),
      );
      _textController.clear();
      _showInput = false;

      // Show celebration every 3 notes
      if (_notes.length % 3 == 0) {
        _showCelebration = true;
        _celebrationTimer?.cancel();
        _celebrationTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _showCelebration = false);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildJarArea()),
                _buildBottomSection(),
              ],
            ),
          ),
          if (_showInput) _buildInputOverlay(),
          if (_showCelebration) _buildCelebrationOverlay(),
        ],
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
          Column(
            children: [
              Text(
                'Le Bocal de Gratitude',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                '${_notes.length} gratitudes',
                style: GoogleFonts.poppins(fontSize: 12, color: subTextColor),
              ),
            ],
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildJarArea() {
    return Center(
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 5 * sin(_floatController.value * 2 * pi)),
            child: child,
          );
        },
        child: Container(
          width: 280,
          height: 380,
          margin: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Jar body
              Container(
                width: 220,
                height: 300,
                margin: const EdgeInsets.only(top: 50),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17),
                    bottomLeft: Radius.circular(57),
                    bottomRight: Radius.circular(57),
                  ),
                  child: Stack(
                    children: [
                      // Fill level indicator
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: min(_notes.length * 25.0, 280),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                secondaryColor.withValues(alpha: 0.2),
                                secondaryColor.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Notes inside jar
                      ..._buildJarNotes(),
                    ],
                  ),
                ),
              ),
              // Jar lid
              Positioned(
                top: 30,
                child: Container(
                  width: 180,
                  height: 35,
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: secondaryColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Lid top
              Positioned(
                top: 10,
                child: Container(
                  width: 100,
                  height: 30,
                  decoration: BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 16,
                    ),
                  ),
                ),
              ),
              // Empty state
              if (_notes.isEmpty)
                Positioned(
                  top: 150,
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 48,
                        color: subTextColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ajoutez votre\npremière gratitude',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: subTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ).animate().fadeIn(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildJarNotes() {
    final displayNotes = _notes.length > 8
        ? _notes.sublist(_notes.length - 8)
        : _notes;

    return displayNotes.asMap().entries.map((entry) {
      final index = entry.key;
      final note = entry.value;
      final bottomOffset = 20.0 + (index * 30);

      return Positioned(
        bottom: bottomOffset,
        left: 20 + note.xOffset,
        right: 20 - note.xOffset,
        child: Transform.rotate(
          angle: note.rotation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: note.color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: note.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              note.text.length > 20
                  ? '${note.text.substring(0, 20)}...'
                  : note.text,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _getContrastColor(note.color),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ).animate(delay: (index * 100).ms).fadeIn().slideY(begin: 0.5),
      );
    }).toList();
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? textColor : Colors.white;
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Inspirational quote
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.format_quote_rounded,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _getInspirationalQuote(),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: subTextColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Add button
          GestureDetector(
            onTap: () => setState(() => _showInput = true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Ajouter une gratitude',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInspirationalQuote() {
    final quotes = [
      'La gratitude transforme ce que nous avons en suffisance.',
      'Chaque jour est une nouvelle chance de dire merci.',
      'La joie est la plus simple forme de gratitude.',
      'Un cœur reconnaissant est un cœur heureux.',
      'La gratitude ouvre la porte à l\'abondance.',
    ];
    return quotes[_notes.length % quotes.length];
  }

  Widget _buildInputOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pour quoi êtes-vous\nreconnaissant(e) ?',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Même les petites choses comptent',
                style: GoogleFonts.poppins(fontSize: 14, color: subTextColor),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _textController,
                autofocus: true,
                maxLength: 50,
                decoration: InputDecoration(
                  hintText: 'Ex: Le sourire d\'un ami...',
                  hintStyle: GoogleFonts.poppins(color: subTextColor),
                  filled: true,
                  fillColor: backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  counterStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: subTextColor,
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 16, color: textColor),
                onSubmitted: (_) => _addGratitude(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _textController.clear();
                        setState(() => _showInput = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Annuler',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: subTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _addGratitude,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Ajouter',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(48),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 10,
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
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.celebration_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .shake(delay: 300.ms),
              const SizedBox(height: 24),
              Text(
                'Magnifique ! 🎉',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Votre bocal se remplit\nde gratitude !',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: subTextColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
      ),
    );
  }
}

// Data Model
class GratitudeNote {
  final String text;
  final Color color;
  final double rotation;
  final double xOffset;

  GratitudeNote({
    required this.text,
    required this.color,
    required this.rotation,
    required this.xOffset,
  });
}
