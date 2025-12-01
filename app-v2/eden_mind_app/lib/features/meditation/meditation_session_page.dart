import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MeditationSessionPage extends StatefulWidget {
  final Map<String, dynamic> session;

  const MeditationSessionPage({super.key, required this.session});

  @override
  State<MeditationSessionPage> createState() => _MeditationSessionPageState();
}

class _MeditationSessionPageState extends State<MeditationSessionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  Timer? _timer;
  bool _isPlaying = false;
  Duration _totalDuration = const Duration(minutes: 10);
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    // Parse duration from session data if possible, else default to 10 min
    // Assuming format "10 min"
    if (widget.session['duration'] != null) {
      final durationStr = widget.session['duration'] as String;
      final minutes = int.tryParse(durationStr.split(' ')[0]) ?? 10;
      _totalDuration = Duration(minutes: minutes);
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _breathController.repeat(reverse: true);
        _startTimer();
      } else {
        _breathController.stop();
        _timer?.cancel();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentPosition < _totalDuration) {
          _currentPosition += const Duration(seconds: 1);
        } else {
          _isPlaying = false;
          _breathController.stop();
          _timer?.cancel();
        }
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final remainingTime = _totalDuration - _currentPosition;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Inhale... Exhale...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF12141D),
                    ),
                  ).animate().fadeIn().slideY(begin: -0.5, end: 0),
                  const SizedBox(height: 8),
                  const Text(
                    'Follow the rhythm of your breath.',
                    style: TextStyle(fontSize: 16, color: Color(0xFFA1A4B2)),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 48),
                  _buildBreathingCircle(remainingTime),
                ],
              ),
            ),
            _buildControls(remainingTime),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 24,
                color: Color(0xFFA1A4B2),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Column(
            children: [
              Text(
                widget.session['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF12141D),
                ),
              ),
              const Text(
                'Meditation Session',
                style: TextStyle(fontSize: 14, color: Color(0xFFA1A4B2)),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.info_outline,
                size: 24,
                color: Color(0xFFA1A4B2),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingCircle(Duration remainingTime) {
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        return SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 280 + (_breathController.value * 20),
                height: 280 + (_breathController.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA3A7F4).withValues(alpha: 0.1),
                ),
              ),
              // Inner glow
              Container(
                width: 240 + (_breathController.value * 30),
                height: 240 + (_breathController.value * 30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA3A7F4).withValues(alpha: 0.2),
                ),
              ),
              // Main circle
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA3A7F4).withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDuration(remainingTime),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF12141D),
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const Text(
                        'Remaining',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFA1A4B2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Progress indicator ring
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value:
                      1.0 -
                      (_currentPosition.inSeconds / _totalDuration.inSeconds),
                  strokeWidth: 4,
                  backgroundColor: const Color(
                    0xFFA3A7F4,
                  ).withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFA3A7F4),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls(Duration remainingTime) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.shuffle, color: Color(0xFFA1A4B2)),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.replay_10, color: Color(0xFFA1A4B2)),
                onPressed: () {
                  setState(() {
                    final newSeconds = _currentPosition.inSeconds - 10;
                    _currentPosition = Duration(
                      seconds: newSeconds < 0 ? 0 : newSeconds,
                    );
                  });
                },
              ),
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA3A7F4),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA3A7F4).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.forward_10, color: Color(0xFFA1A4B2)),
                onPressed: () {
                  setState(() {
                    final newSeconds = _currentPosition.inSeconds + 10;
                    _currentPosition = Duration(
                      seconds: newSeconds > _totalDuration.inSeconds
                          ? _totalDuration.inSeconds
                          : newSeconds,
                    );
                  });
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: Color(0xFFA1A4B2),
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(fontSize: 12, color: Color(0xFFA1A4B2)),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFA3A7F4),
                    inactiveTrackColor: const Color(
                      0xFFA3A7F4,
                    ).withValues(alpha: 0.2),
                    thumbColor: const Color(0xFFA3A7F4),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    value: _currentPosition.inSeconds.toDouble(),
                    max: _totalDuration.inSeconds.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _currentPosition = Duration(seconds: value.toInt());
                      });
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: const TextStyle(fontSize: 12, color: Color(0xFFA1A4B2)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
