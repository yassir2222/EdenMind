import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  int _pairCount = 6; // Default 6 pairs (12 cards)
  bool _gameStarted = false;
  List<MemoryCard> _cards = [];
  int? _firstFlippedIndex;
  int? _secondFlippedIndex;
  bool _isChecking = false;
  int _moves = 0;
  int _matchedPairs = 0;
  int _seconds = 0;
  Timer? _timer;

  // Therapeutic symbols with calming colors
  final List<Map<String, dynamic>> _symbols = [
    {'icon': Icons.local_florist, 'color': const Color(0xFFE91E63), 'name': 'Flower'},
    {'icon': Icons.favorite, 'color': const Color(0xFFF44336), 'name': 'Heart'},
    {'icon': Icons.wb_sunny, 'color': const Color(0xFFFF9800), 'name': 'Sun'},
    {'icon': Icons.nightlight_round, 'color': const Color(0xFF9C27B0), 'name': 'Moon'},
    {'icon': Icons.star, 'color': const Color(0xFFFFEB3B), 'name': 'Star'},
    {'icon': Icons.eco, 'color': const Color(0xFF4CAF50), 'name': 'Leaf'},
    {'icon': Icons.water_drop, 'color': const Color(0xFF2196F3), 'name': 'Water'},
    {'icon': Icons.spa, 'color': const Color(0xFF00BCD4), 'name': 'Spa'},
    {'icon': Icons.self_improvement, 'color': const Color(0xFF8E97FD), 'name': 'Zen'},
    {'icon': Icons.cloud, 'color': const Color(0xFF90CAF9), 'name': 'Cloud'},
    {'icon': Icons.pets, 'color': const Color(0xFF795548), 'name': 'Paw'},
    {'icon': Icons.music_note, 'color': const Color(0xFF673AB7), 'name': 'Music'},
  ];

  final List<Map<String, dynamic>> _difficulties = [
    {'pairs': 4, 'label': 'Easy', 'grid': 2, 'description': '8 cards'},
    {'pairs': 6, 'label': 'Medium', 'grid': 3, 'description': '12 cards'},
    {'pairs': 8, 'label': 'Hard', 'grid': 4, 'description': '16 cards'},
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    // Create pairs of cards
    final shuffledSymbols = List<Map<String, dynamic>>.from(_symbols)..shuffle();
    final selectedSymbols = shuffledSymbols.take(_pairCount).toList();

    _cards = [];
    for (int i = 0; i < selectedSymbols.length; i++) {
      // Add two cards for each symbol (pair)
      _cards.add(MemoryCard(id: i * 2, symbolIndex: i, symbol: selectedSymbols[i]));
      _cards.add(MemoryCard(id: i * 2 + 1, symbolIndex: i, symbol: selectedSymbols[i]));
    }
    _cards.shuffle(Random());

    setState(() {
      _gameStarted = true;
      _moves = 0;
      _matchedPairs = 0;
      _seconds = 0;
      _firstFlippedIndex = null;
      _secondFlippedIndex = null;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _onCardTap(int index) {
    if (_isChecking) return;
    if (_cards[index].isMatched) return;
    if (_cards[index].isFlipped) return;
    if (_firstFlippedIndex == index) return;

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      _secondFlippedIndex = index;
      _moves++;
      _checkMatch();
    }
  }

  void _checkMatch() async {
    _isChecking = true;

    await Future.delayed(const Duration(milliseconds: 800));

    final first = _cards[_firstFlippedIndex!];
    final second = _cards[_secondFlippedIndex!];

    if (first.symbolIndex == second.symbolIndex) {
      // Match found!
      setState(() {
        first.isMatched = true;
        second.isMatched = true;
        _matchedPairs++;
      });

      if (_matchedPairs == _pairCount) {
        _timer?.cancel();
        _showVictoryDialog();
      }
    } else {
      // No match - flip back
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        first.isFlipped = false;
        second.isFlipped = false;
      });
    }

    _firstFlippedIndex = null;
    _secondFlippedIndex = null;
    _isChecking = false;
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8E97FD).withValues(alpha: 0.2),
                    const Color(0xFFE8D7FF).withValues(alpha: 0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_alt,
                color: Color(0xFF8E97FD),
                size: 60,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'Well Done! 🧠',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF12141D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your memory is sharp!',
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: const Color(0xFFA1A4B2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatChip(Icons.timer, _formatTime(_seconds)),
                _buildStatChip(Icons.touch_app, '$_moves moves'),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _gameStarted = false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: Color(0xFF8E97FD)),
                    ),
                    child: Text(
                      'Menu',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8E97FD),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _startGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E97FD),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Play Again',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF8E97FD)),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF12141D),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: _gameStarted ? _buildGameBoard() : _buildMenuScreen(),
      ),
    );
  }

  Widget _buildMenuScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildTitleSection()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.2, end: 0),
          const SizedBox(height: 40),
          _buildDifficultySelection()
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms),
          const SizedBox(height: 40),
          _buildPreview()
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms),
          const SizedBox(height: 40),
          _buildStartButton()
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left, color: Color(0xFF12141D), size: 32),
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.help_outline, color: Color(0xFF12141D), size: 24),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8E97FD).withValues(alpha: 0.3),
                const Color(0xFFE8D7FF).withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.psychology, color: Color(0xFF8E97FD), size: 40),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Memory Match',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF12141D),
                ),
              ),
              Text(
                'Train your brain, find peace',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: const Color(0xFFA1A4B2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Difficulty',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF12141D),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: _difficulties.map((diff) {
            final isSelected = _pairCount == diff['pairs'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _pairCount = diff['pairs']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: diff != _difficulties.last ? 12 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF8E97FD), Color(0xFFAEB6FF)],
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF8E97FD).withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        diff['label'],
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF12141D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        diff['description'],
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : const Color(0xFFA1A4B2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Symbols Preview',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF12141D),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _symbols.take(_pairCount).map((symbol) {
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (symbol['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  symbol['icon'] as IconData,
                  color: symbol['color'] as Color,
                  size: 28,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8E97FD),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          shadowColor: const Color(0xFF8E97FD).withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 28),
            const SizedBox(width: 8),
            Text(
              'Start Game',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoard() {
    return Column(
      children: [
        _buildGameHeader(),
        _buildStatsBar(),
        Expanded(child: _buildCardGrid()),
      ],
    );
  }

  Widget _buildGameHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              _timer?.cancel();
              setState(() => _gameStarted = false);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_left, color: Color(0xFF12141D), size: 32),
            ),
          ),
          Text(
            'Memory Match',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF12141D),
            ),
          ),
          GestureDetector(
            onTap: _startGame,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, color: Color(0xFF12141D), size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.timer, _formatTime(_seconds), 'Time'),
          Container(width: 1, height: 30, color: const Color(0xFFE5E5E5)),
          _buildStatItem(Icons.touch_app, '$_moves', 'Moves'),
          Container(width: 1, height: 30, color: const Color(0xFFE5E5E5)),
          _buildStatItem(Icons.check_circle, '$_matchedPairs/$_pairCount', 'Pairs'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF8E97FD)),
            const SizedBox(width: 6),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF12141D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            color: const Color(0xFFA1A4B2),
          ),
        ),
      ],
    );
  }

  Widget _buildCardGrid() {
    final crossAxisCount = _pairCount <= 4 ? 4 : (_pairCount <= 6 ? 4 : 4);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardSize = (constraints.maxWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
          
          return Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: List.generate(_cards.length, (index) {
                return SizedBox(
                  width: cardSize,
                  height: cardSize,
                  child: _buildCard(index),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          final rotate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final isBack = rotate.value > pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(rotate.value),
                child: isBack ? _buildCardBack() : child,
              );
            },
          );
        },
        child: card.isFlipped || card.isMatched
            ? _buildCardFront(card)
            : _buildCardBack(),
      ),
    );
  }

  Widget _buildCardFront(MemoryCard card) {
    return AnimatedContainer(
      key: ValueKey('front_${card.id}'),
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: card.isMatched
            ? (card.symbol['color'] as Color).withValues(alpha: 0.2)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: card.isMatched
              ? (card.symbol['color'] as Color)
              : const Color(0xFFE5E5E5),
          width: card.isMatched ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: card.isMatched
                ? (card.symbol['color'] as Color).withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: card.isMatched ? 15 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          card.symbol['icon'] as IconData,
          color: card.symbol['color'] as Color,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      key: const ValueKey('back'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E97FD), Color(0xFFAEB6FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E97FD).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.psychology,
          color: Colors.white.withValues(alpha: 0.5),
          size: 32,
        ),
      ),
    );
  }
}

class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget? child;
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    this.child,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder2(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilder2 extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder2({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

class MemoryCard {
  final int id;
  final int symbolIndex;
  final Map<String, dynamic> symbol;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.symbolIndex,
    required this.symbol,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
