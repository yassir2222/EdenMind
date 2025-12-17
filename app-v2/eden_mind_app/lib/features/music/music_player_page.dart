import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class Track {
  final String title;
  final String duration;
  final String imageUrl;
  final String audioUrl;
  final String description;
  final String category;

  const Track({
    required this.title,
    required this.duration,
    required this.imageUrl,
    required this.audioUrl,
    required this.description,
    this.category = 'ambient',
  });
}

class MusicPlayerPage extends StatefulWidget {
  final Track track;
  final List<Track> recommendedTracks;
  final AudioPlayer? audioPlayer;

  const MusicPlayerPage({
    super.key,
    required this.track,
    this.recommendedTracks = const [],
    this.audioPlayer,
  });

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = widget.audioPlayer ?? AudioPlayer();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _durationSubscription = _audioPlayer.onDurationChanged.listen((
      newDuration,
    ) {
      setState(() {
        _duration = newDuration;
      });
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((
      newPosition,
    ) {
      setState(() {
        _position = newPosition;
      });
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _position = Duration.zero;
        _isPlaying = false;
      });
    });

    _playerStateChangeSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    // Auto-play when page opens
    // _playAudio(); // Optional: uncomment to auto-play
  }

  Future<void> _playAudio() async {
    // For now, using a placeholder if audioUrl is empty or invalid
    // In a real app, we'd handle errors gracefully
    if (widget.track.audioUrl.isNotEmpty) {
      await _audioPlayer.play(UrlSource(widget.track.audioUrl));
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _pauseAudio();
    } else {
      await _playAudio();
    }
  }

  Future<void> _seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> _seekRelative(Duration offset) async {
    final newPosition = _position + offset;
    if (newPosition < Duration.zero) {
      await _seek(Duration.zero);
    } else if (newPosition > _duration) {
      await _seek(_duration);
    } else {
      await _seek(newPosition);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMainPlayerCard(),
                    const SizedBox(height: 24),
                    _buildRecommendedSection(),
                  ],
                ),
              ),
            ),
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF12141D),
              ),
            ),
          ),
          Text(
            'Meditation',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF12141D),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.search, size: 20, color: Color(0xFF12141D)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPlayerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFA3A7F4).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            "Today's Pick",
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA1A4B2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.track.title,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF12141D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.track.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: const Color(0xFFA1A4B2),
            ),
          ),
          const SizedBox(height: 32),
          // Album Art
          Container(
            width: 192,
            height: 192,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(widget.track.imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA3A7F4).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: const Color(0xFFA1A4B2),
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: const Color(0xFFA1A4B2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
              activeTrackColor: const Color(0xFFA3A7F4),
              inactiveTrackColor: Colors.white,
            ),
            child: Slider(
              value: _position.inSeconds.toDouble().clamp(
                0.0,
                _duration.inSeconds.toDouble(),
              ),
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) {
                _seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
          const SizedBox(height: 32),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _seekRelative(const Duration(seconds: -10)),
                icon: const Icon(
                  Icons.replay_10,
                  size: 32,
                  color: Color(0xFF12141D),
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA3A7F4),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA3A7F4).withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: () => _seekRelative(const Duration(seconds: 10)),
                icon: const Icon(
                  Icons.forward_10,
                  size: 32,
                  color: Color(0xFF12141D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommended',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF12141D),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFA3A7F4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.recommendedTracks.map(
          (track) => _buildRecommendedItem(track),
        ),
      ],
    );
  }

  Widget _buildRecommendedItem(Track track) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(track.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF12141D),
                  ),
                ),
                Text(
                  track.duration,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: const Color(0xFFA1A4B2),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF9D5A2), // Secondary color
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Color(0xFF12141D),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
