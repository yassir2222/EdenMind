import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eden_mind_app/config/app_config.dart';
import 'meditation_detail_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MeditationPage extends StatefulWidget {
  final http.Client? httpClient;

  const MeditationPage({super.key, this.httpClient});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Guided', 'Sounds', 'Timer'];

  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;
  String? _error;

  // Default images for different categories
  final Map<String, String> _categoryImages = {
    'meditation':
        'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400',
    'relaxation':
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    'motivation':
        'https://images.unsplash.com/photo-1519834785169-98be25ec3f84?w=400',
    'ambient':
        'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?w=400',
    'sleep':
        'https://images.unsplash.com/photo-1511295742362-92c96b1cf484?w=400',
  };

  final Map<String, Color> _categoryColors = {
    'meditation': const Color(0xFFA3A7F4),
    'relaxation': const Color(0xFF82C9D0),
    'motivation': const Color(0xFFF9D5A2),
    'ambient': const Color(0xFFB8A5E0),
    'sleep': const Color(0xFF7986CB),
  };

  @override
  void initState() {
    super.initState();
    _loadMeditationTracks();
  }

  Future<void> _loadMeditationTracks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = widget.httpClient ?? http.Client();
      final response = await client.get(
        Uri.parse('${AppConfig.baseUrl}/music/tracks'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _sessions = data.map((track) {
            final category = track['category'] ?? 'ambient';
            return {
              'title': track['title'] ?? 'Unknown',
              'duration': track['duration'] ?? '5 min',
              'durationSeconds': track['durationSeconds'] ?? 300,
              'category': _getCategoryLabel(category),
              'categoryKey': category,
              'image': _categoryImages[category] ?? _categoryImages['ambient']!,
              'color': _categoryColors[category] ?? _categoryColors['ambient']!,
              'audioUrl':
                  'http://${AppConfig.serverIp}:${AppConfig.serverPort}${track['url']}',
              'fileName': track['fileName'],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load tracks';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error';
        _isLoading = false;
      });
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'meditation':
        return 'Focus';
      case 'relaxation':
        return 'Calm';
      case 'motivation':
        return 'Energy';
      case 'sleep':
        return 'Sleep';
      default:
        return 'Ambient';
    }
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFA3A7F4),
                      ),
                    )
                  : _error != null
                  ? _buildErrorWidget()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroSection()
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(),
                          const SizedBox(height: 24),
                          const Text(
                            'Find Your Inner Peace',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF12141D),
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideX(),
                          const SizedBox(height: 8),
                          Text(
                            '${_sessions.length} meditation tracks available',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFA1A4B2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFilterChips().animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 24),
                          _buildSessionList(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Color(0xFFA1A4B2)),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            style: const TextStyle(fontSize: 16, color: Color(0xFFA1A4B2)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMeditationTracks,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA3A7F4),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
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
                Icons.arrow_back_ios_new,
                size: 20,
                color: Color(0xFF12141D),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Expanded(
            child: Text(
              'Meditation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF12141D),
              ),
            ),
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
                Icons.refresh,
                size: 20,
                color: Color(0xFF12141D),
              ),
              onPressed: _loadMeditationTracks,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA3A7F4), Color(0xFF7B7FE0)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.self_improvement,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Daily Meditation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Take a moment to breathe and relax',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: List.generate(_filters.length, (index) {
        final isSelected = _selectedFilterIndex == index;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFA3A7F4) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFA3A7F4).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFFA1A4B2),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSessionList() {
    if (_sessions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No meditation tracks available.\nAdd MP3 files to the music folder.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFA1A4B2)),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(_sessions.length, (index) {
        final session = _sessions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MeditationDetailPage(session: session),
                ),
              );
            },
            child:
                Container(
                      padding: const EdgeInsets.all(12),
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
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  session['color'] as Color,
                                  (session['color'] as Color).withValues(
                                    alpha: 0.7,
                                  ),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF12141D),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${session['duration']} • ${session['category']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFA1A4B2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: session['color'] as Color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (session['color'] as Color).withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (400 + (index * 100)).ms)
                    .slideY(begin: 0.2, end: 0),
          ),
        );
      }),
    );
  }
}
