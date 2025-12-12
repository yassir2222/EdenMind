import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import 'music_player_page.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  int _selectedCategoryIndex = 0;
  List<Track> _tracks = [];
  bool _isLoading = true;
  String? _error;

  final List<MusicCategory> _categories = [
    MusicCategory(id: 'all', name: 'TOUS', icon: Icons.music_note_rounded),
    MusicCategory(
      id: 'meditation',
      name: 'MÉDITATION',
      icon: Icons.self_improvement_rounded,
    ),
    MusicCategory(
      id: 'relaxation',
      name: 'RELAXATION',
      icon: Icons.spa_rounded,
    ),
    MusicCategory(
      id: 'motivation',
      name: 'MOTIVATION',
      icon: Icons.bolt_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/music/tracks'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _tracks = data
              .map(
                (json) => Track(
                  title: json['title'] ?? 'Unknown',
                  duration: json['duration'] ?? '5 min',
                  imageUrl: _getImageForCategory(json['category'] ?? 'ambient'),
                  audioUrl:
                      'http://${AppConfig.serverIp}:${AppConfig.serverPort}${json['url']}',
                  description: _getDescriptionForCategory(
                    json['category'] ?? 'ambient',
                  ),
                  category: json['category'] ?? 'ambient',
                ),
              )
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur de chargement';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les pistes';
        _isLoading = false;
      });
    }
  }

  String _getImageForCategory(String category) {
    switch (category) {
      case 'meditation':
        return 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400';
      case 'relaxation':
        return 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?w=400';
      case 'motivation':
        return 'https://images.unsplash.com/photo-1533073526757-2c8ca1df9f1c?w=400';
      case 'sleep':
        return 'https://images.unsplash.com/photo-1507400492013-162706c8c05e?w=400';
      default:
        return 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400';
    }
  }

  String _getDescriptionForCategory(String category) {
    switch (category) {
      case 'meditation':
        return 'Musique apaisante pour la méditation et la pleine conscience.';
      case 'relaxation':
        return 'Sons relaxants pour réduire le stress et l\'anxiété.';
      case 'motivation':
        return 'Mélodies inspirantes pour booster votre énergie.';
      case 'sleep':
        return 'Ambiances douces pour faciliter l\'endormissement.';
      default:
        return 'Musique d\'ambiance pour accompagner votre journée.';
    }
  }

  List<Track> get _filteredTracks {
    if (_selectedCategoryIndex == 0) return _tracks;
    final categoryId = _categories[_selectedCategoryIndex].id;
    return _tracks.where((t) => t.category == categoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Transform.translate(
              offset: const Offset(0, -48),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F8FD),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(),
                    const SizedBox(height: 24),
                    _buildStatsRow(),
                    const SizedBox(height: 32),
                    _buildCategoryTabs(),
                    const SizedBox(height: 24),
                    _buildTrackList(),
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
    return SizedBox(
      height: 420,
      child: Stack(
        children: [
          // Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              child: Image.network(
                'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFA3A7F4),
                        const Color(0xFFA3A7F4).withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          // Overlay Buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGlassButton(
                    icon: Icons.arrow_back,
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  Row(
                    children: [
                      _buildGlassButton(
                        icon: Icons.favorite_border,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _buildGlassButton(
                        icon: Icons.refresh_rounded,
                        onTap: _loadTracks,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF12141D), size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Espace Zen',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF12141D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'MUSIQUE THÉRAPEUTIQUE',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFA1A4B2),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Détendez-vous avec notre collection de musiques apaisantes pour la méditation et le bien-être.",
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: const Color(0xFF12141D).withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem(
          Icons.music_note_rounded,
          '${_tracks.length} Pistes',
          const Color(0xFFA3A7F4),
        ),
        const SizedBox(width: 32),
        _buildStatItem(
          Icons.category_rounded,
          '${_categories.length - 1} Catégories',
          const Color(0xFFF9D5A2),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF12141D),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégories',
          style: GoogleFonts.caveat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF12141D),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return _buildCategoryChip(category, index);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(MusicCategory category, int index) {
    final isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA3A7F4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFA3A7F4).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFFA1A4B2),
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFFA1A4B2),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: Color(0xFFA3A7F4)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: const Color(0xFFA1A4B2),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFFA1A4B2),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadTracks,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA3A7F4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredTracks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.music_off_rounded,
                size: 48,
                color: const Color(0xFFA1A4B2),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune piste dans cette catégorie',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFFA1A4B2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _filteredTracks.asMap().entries.map((entry) {
        final index = entry.key;
        final track = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildTrackItem(track: track, index: index),
        );
      }).toList(),
    );
  }

  Widget _buildTrackItem({required Track track, required int index}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerPage(
              track: track,
              recommendedTracks: _tracks
                  .where((t) => t != track)
                  .take(2)
                  .toList(),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFA3A7F4).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(track.imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(track.category),
                  color: const Color(0xFFA3A7F4),
                  size: 24,
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
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF12141D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            track.category,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          track.category.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(track.category),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        track.duration,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA1A4B2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFA3A7F4),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA3A7F4).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'relaxation':
        return Icons.spa_rounded;
      case 'motivation':
        return Icons.bolt_rounded;
      case 'sleep':
        return Icons.bedtime_rounded;
      default:
        return Icons.music_note_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'meditation':
        return const Color(0xFF4ECDC4);
      case 'relaxation':
        return const Color(0xFF6BCB77);
      case 'motivation':
        return const Color(0xFFF9D5A2);
      case 'sleep':
        return const Color(0xFF74B9FF);
      default:
        return const Color(0xFFA3A7F4);
    }
  }
}

class MusicCategory {
  final String id;
  final String name;
  final IconData icon;

  MusicCategory({required this.id, required this.name, required this.icon});
}
