import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PuzzleBoardPage extends StatefulWidget {
  final String imagePath;
  final String imageName;
  final int gridSize;

  const PuzzleBoardPage({
    super.key,
    required this.imagePath,
    required this.imageName,
    required this.gridSize,
  });

  @override
  State<PuzzleBoardPage> createState() => _PuzzleBoardPageState();
}

class _PuzzleBoardPageState extends State<PuzzleBoardPage> {
  List<int> _pieces = [];
  int _moves = 0;
  int _seconds = 0;
  Timer? _timer;
  bool _isLoading = true;
  bool _isCompleted = false;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _initializePuzzle();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializePuzzle() async {
    // Load image
    final ByteData data = await rootBundle.load(widget.imagePath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    _image = frame.image;

    // Initialize pieces in order
    final totalPieces = widget.gridSize * widget.gridSize;
    _pieces = List.generate(totalPieces, (index) => index);

    // Shuffle pieces (ensuring solvability)
    _shufflePieces();

    // Start timer
    _startTimer();

    setState(() => _isLoading = false);
  }

  void _shufflePieces() {
    final random = Random();
    // Perform random swaps to shuffle
    for (int i = 0; i < _pieces.length * 10; i++) {
      final idx1 = random.nextInt(_pieces.length);
      final idx2 = random.nextInt(_pieces.length);
      final temp = _pieces[idx1];
      _pieces[idx1] = _pieces[idx2];
      _pieces[idx2] = temp;
    }
    
    // Check if already solved and reshuffle if needed
    if (_checkWin()) {
      _shufflePieces();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _swapPieces(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;

    setState(() {
      final temp = _pieces[fromIndex];
      _pieces[fromIndex] = _pieces[toIndex];
      _pieces[toIndex] = temp;
      _moves++;
    });

    if (_checkWin()) {
      _timer?.cancel();
      setState(() => _isCompleted = true);
      _showVictoryDialog();
    }
  }

  bool _checkWin() {
    for (int i = 0; i < _pieces.length; i++) {
      if (_pieces[i] != i) return false;
    }
    return true;
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
                color: const Color(0xFF8E97FD).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Color(0xFFFFD700),
                size: 60,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'Congratulations! 🎉',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF12141D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You completed the puzzle!',
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
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: Color(0xFF8E97FD)),
                    ),
                    child: Text(
                      'Exit',
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
                      _resetPuzzle();
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

  void _resetPuzzle() {
    setState(() {
      _moves = 0;
      _seconds = 0;
      _isCompleted = false;
      _shufflePieces();
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF8E97FD)))
                  : _buildPuzzleBoard(),
            ),
            _buildReferenceImage(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
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
          Text(
            widget.imageName,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF12141D),
            ),
          ),
          GestureDetector(
            onTap: _resetPuzzle,
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
          Container(
            width: 1,
            height: 30,
            color: const Color(0xFFE5E5E5),
          ),
          _buildStatItem(Icons.touch_app, '$_moves', 'Moves'),
          Container(
            width: 1,
            height: 30,
            color: const Color(0xFFE5E5E5),
          ),
          _buildStatItem(Icons.grid_view, '${widget.gridSize}×${widget.gridSize}', 'Grid'),
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

  Widget _buildPuzzleBoard() {
    if (_image == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardSize = min(constraints.maxWidth, constraints.maxHeight - 50);
          final pieceSize = boardSize / widget.gridSize;

          return Center(
            child: Container(
              width: boardSize,
              height: boardSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.gridSize,
                  ),
                  itemCount: _pieces.length,
                  itemBuilder: (context, index) {
                    return _buildPuzzlePiece(index, pieceSize);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPuzzlePiece(int currentIndex, double pieceSize) {
    final pieceValue = _pieces[currentIndex];
    final isCorrect = pieceValue == currentIndex;

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        _swapPieces(details.data, currentIndex);
      },
      builder: (context, candidateData, rejectedData) {
        return Draggable<int>(
          data: currentIndex,
          feedback: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: pieceSize,
              height: pieceSize,
              child: _buildPieceImage(pieceValue, pieceSize),
            ),
          ),
          childWhenDragging: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF8E97FD).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: candidateData.isNotEmpty
                  ? Border.all(color: const Color(0xFF8E97FD), width: 2)
                  : _isCompleted && isCorrect
                      ? Border.all(color: Colors.green, width: 2)
                      : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _buildPieceImage(pieceValue, pieceSize),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPieceImage(int pieceIndex, double pieceSize) {
    if (_image == null) return const SizedBox();

    final row = pieceIndex ~/ widget.gridSize;
    final col = pieceIndex % widget.gridSize;
    
    final srcWidth = _image!.width / widget.gridSize;
    final srcHeight = _image!.height / widget.gridSize;
    final srcX = col * srcWidth;
    final srcY = row * srcHeight;

    return CustomPaint(
      size: Size(pieceSize, pieceSize),
      painter: PuzzlePiecePainter(
        image: _image!,
        srcRect: Rect.fromLTWH(srcX, srcY, srcWidth, srcHeight),
      ),
    );
  }

  Widget _buildReferenceImage() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Reference Image',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: const Color(0xFFA1A4B2),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PuzzlePiecePainter extends CustomPainter {
  final ui.Image image;
  final Rect srcRect;

  PuzzlePiecePainter({required this.image, required this.srcRect});

  @override
  void paint(Canvas canvas, Size size) {
    final destRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, srcRect, destRect, Paint());
  }

  @override
  bool shouldRepaint(covariant PuzzlePiecePainter oldDelegate) {
    return oldDelegate.srcRect != srcRect || oldDelegate.image != image;
  }
}
