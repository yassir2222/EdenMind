import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:eden_mind_app/features/notifications/notification_service.dart';

class MeditationSessionPage extends StatefulWidget {
  final Map<String, dynamic> session;
  final AudioPlayer? audioPlayer;
  final NotificationService? notificationService;

  const MeditationSessionPage({
    super.key,
    required this.session,
    this.audioPlayer,
    this.notificationService,
  });

  @override
  State<MeditationSessionPage> createState() => _MeditationSessionPageState();
}

class _MeditationSessionPageState extends State<MeditationSessionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late AudioPlayer _audioPlayer;
  late NotificationService _notificationService;
  bool _isPlaying = false;
  Duration _totalDuration = const Duration(minutes: 10);
  Duration _currentPosition = Duration.zero;
  bool _isMuted = false;
  bool _isAudioLoading = false;
  bool _hasNotifiedCompletion = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = widget.audioPlayer ?? AudioPlayer();
    _notificationService = widget.notificationService ?? NotificationService();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Parse duration from session data
    if (widget.session['durationSeconds'] != null) {
      _totalDuration = Duration(
        seconds: widget.session['durationSeconds'] as int,
      );
    } else if (widget.session['duration'] != null) {
      final durationStr = widget.session['duration'] as String;
      final minutes = int.tryParse(durationStr.split(' ')[0]) ?? 10;
      _totalDuration = Duration(minutes: minutes);
    }

    _setupAudioPlayer();
  }

  Future<void> _setupAudioPlayer() async {
    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (_isPlaying) {
            _breathController.repeat(reverse: true);
          } else {
            _breathController.stop();
          }
        });
      }
    });

    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
          _breathController.stop();
        });

        // Send notification for meditation completion
        if (!_hasNotifiedCompletion) {
          _hasNotifiedCompletion = true;
          final sessionName = widget.session['title'] ?? 'Meditation';
          final minutes = _totalDuration.inMinutes;
          _notificationService.notifyMeditationCompleted(sessionName, minutes);

          // Show completion dialog
          _showCompletionDialog();
        }
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            const Text('Well Done! 🧘'),
          ],
        ),
        content: Text(
          'You completed a ${_totalDuration.inMinutes}-minute meditation session. '
          'Your mind and body thank you!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to meditation list
            },
            child: const Text('Back to Meditations'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA3A7F4),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final audioUrl = widget.session['audioUrl'] as String?;
    if (audioUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio available for this session')),
      );
      return;
    }

    setState(() => _isAudioLoading = true);

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_currentPosition == Duration.zero) {
          await _audioPlayer.play(UrlSource(audioUrl));
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isAudioLoading = false);
      }
    }
  }

  Future<void> _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    await _audioPlayer.setVolume(_isMuted ? 0.0 : 1.0);
  }

  Future<void> _seekBackward() async {
    final newPosition = _currentPosition - const Duration(seconds: 10);
    await _audioPlayer.seek(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
  }

  Future<void> _seekForward() async {
    final newPosition = _currentPosition + const Duration(seconds: 10);
    await _audioPlayer.seek(
      newPosition > _totalDuration ? _totalDuration : newPosition,
    );
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
    final color = widget.session['color'] as Color? ?? const Color(0xFFA3A7F4);

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
                  Text(
                    _isPlaying ? 'Breathe...' : 'Press play to start',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF12141D),
                    ),
                  ).animate().fadeIn().slideY(begin: -0.5, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    _isPlaying
                        ? 'Follow the rhythm of the music.'
                        : widget.session['title'] ?? 'Meditation',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFA1A4B2),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 48),
                  _buildBreathingCircle(remainingTime, color),
                ],
              ),
            ),
            _buildControls(color),
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
              onPressed: () {
                _audioPlayer.stop();
                Navigator.pop(context);
              },
            ),
          ),
          Column(
            children: [
              Text(
                widget.session['title'] ?? 'Meditation',
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
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(widget.session['title'] ?? 'Meditation'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category: ${widget.session['category'] ?? 'Ambient'}',
                        ),
                        Text(
                          'Duration: ${widget.session['duration'] ?? 'Unknown'}',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingCircle(Duration remainingTime, Color color) {
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
                  color: color.withValues(alpha: 0.1),
                ),
              ),
              // Inner glow
              Container(
                width: 240 + (_breathController.value * 30),
                height: 240 + (_breathController.value * 30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
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
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isAudioLoading)
                        CircularProgressIndicator(color: color)
                      else ...[
                        Text(
                          _formatDuration(remainingTime),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF12141D),
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
                    ],
                  ),
                ),
              ),
              // Progress indicator ring
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: _totalDuration.inSeconds > 0
                      ? _currentPosition.inSeconds / _totalDuration.inSeconds
                      : 0,
                  strokeWidth: 4,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls(Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: const Color(0xFFA1A4B2),
                ),
                onPressed: _toggleMute,
              ),
              IconButton(
                icon: const Icon(Icons.replay_10, color: Color(0xFFA1A4B2)),
                onPressed: _seekBackward,
              ),
              GestureDetector(
                onTap: _isAudioLoading ? null : _togglePlay,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _isAudioLoading
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.forward_10, color: Color(0xFFA1A4B2)),
                onPressed: _seekForward,
              ),
              IconButton(
                icon: const Icon(Icons.stop, color: Color(0xFFA1A4B2)),
                onPressed: () async {
                  await _audioPlayer.stop();
                  setState(() {
                    _currentPosition = Duration.zero;
                  });
                },
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
                    activeTrackColor: color,
                    inactiveTrackColor: color.withValues(alpha: 0.2),
                    thumbColor: color,
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    value: _currentPosition.inSeconds.toDouble().clamp(
                      0,
                      _totalDuration.inSeconds.toDouble(),
                    ),
                    max: _totalDuration.inSeconds.toDouble(),
                    onChanged: (value) async {
                      await _audioPlayer.seek(Duration(seconds: value.toInt()));
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
