import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'music_player_page.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  int _selectedDurationIndex = 0; // 0: Short, 1: Medium, 2: Long

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
                    _buildDurationTabs(),
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
                'https://lh3.googleusercontent.com/aida-public/AB6AXuD864XxsT3lAtOsXKAfQ3eZYFY1O95Gv1Dd7IC_L88x4wp-94xt_h-gT0prBgluiGwHNvLwUWJgMy3__ZqQ2egthRRwDnMDgUFGalMaL5CHYZEuQiqQ2rRxm6b9CGWm-iLwdjq5KgfdKQkuzKTwEEbHND142p3p_9A8GkAnJte8my8ib6ePTmaXxdkjFzjjfbbgLqcvqyKPNyWzJbMLTv0AFMp-fKxXMuP21rtXZntLINRLtAG1XAzs80zAh2XZI8sj_x3K0YLv68o',
                fit: BoxFit.cover,
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
                      // Check if we can pop, otherwise maybe switch tab or do nothing
                      // Since this is a tab, popping might not be what we want unless pushed
                      // But design has back button.
                      // For now, if it's in a tab, maybe this button is hidden or goes to "Home"?
                      // Let's assume it pops if pushed, or does nothing if root of tab.
                      // Actually, user might want to go back to Dashboard Home if they clicked Music tab?
                      // Standard tab behavior usually doesn't have back button to other tabs.
                      // But let's implement it as a back button.
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
                        icon: Icons.download_outlined,
                        onTap: () {},
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
          'Painting Forest',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF12141D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'SLEEP MUSIC',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFA1A4B2),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Ease the mind into a restful night's sleep with these deep, ambient tones.",
          style: GoogleFonts.poppins(
            fontSize: 16,
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
        _buildStatItem(Icons.favorite, '24,293 Favorites', Colors.redAccent),
        const SizedBox(width: 32),
        _buildStatItem(
          Icons.headset_mic,
          '42,108 Listening',
          const Color(0xFF12141D),
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

  Widget _buildDurationTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick a Duration',
          style: GoogleFonts.caveat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF12141D),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildTabItem('SHORT', 0),
            _buildTabItem('MEDIUM', 1),
            _buildTabItem('LONG', 2),
          ],
        ),
        Container(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
      ],
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedDurationIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDurationIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFFA3A7F4)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFFA3A7F4)
                  : const Color(0xFFA1A4B2),
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  final List<Track> _tracks = [
    Track(
      title: 'Night Island',
      duration: '10 MIN',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD864XxsT3lAtOsXKAfQ3eZYFY1O95Gv1Dd7IC_L88x4wp-94xt_h-gT0prBgluiGwHNvLwUWJgMy3__ZqQ2egthRRwDnMDgUFGalMaL5CHYZEuQiqQ2rRxm6b9CGWm-iLwdjq5KgfdKQkuzKTwEEbHND142p3p_9A8GkAnJte8my8ib6ePTmaXxdkjFzjjfbbgLqcvqyKPNyWzJbMLTv0AFMp-fKxXMuP21rtXZntLINRLtAG1XAzs80zAh2XZI8sj_x3K0YLv68o',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      description: 'Calming sounds of the night island.',
    ),
    Track(
      title: 'Sweet Sleep',
      duration: '15 MIN',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD8WsvCzqgGUB_QFmYoX6aSxG9J9-CLov_pvTQbtPZ29cUaiqvsEOnLA1XOm5aqs-SoZIF3jLTt7K0LxtwRnO2cFkA1ictmaUXLRp8t9gvbWLEYKILdTfFytVDL8N6CcVSoYDyFFkMh9Dg_hLnBt_H_B_d-oB4MB4925HVIKHQ-t7Vgx5Kd4D9omy9qtH8e7KyjZu7Y6UXHocISvdM7GTClEaAy6pmLjQM74QRHIqmXLdBCMy4KXikFGG63ZUlvyU2yy5sr0vmiy8Q',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      description: 'Drift into a sweet sleep with gentle melodies.',
    ),
    Track(
      title: 'Good Night',
      duration: '20 MIN',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuADmOCSygLpA6tdf_MvNGGV3QI9Kf-9wTVcSTvG2-itERbQ0EDrl66kailEaXI7eLbSPY0omy0X6oGjdFAtkcLLE-FI6bKezrelHVzDqauW4UcNDng82Iou-02-nKsaggZf3h2y_TruPzJKsFQim_yR1nJKeEwLOIfmrwhjG_wOn2o3sWnZQj2W3axI_M_4bPlOAWAErHERGwnlemn4mO-ZcFB3tCSzfCp9JIttedmLNUBea3sLQCYtn_M3CP62FzyLIr1Kryj_ZT4',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      description: 'Say goodnight to stress and anxiety.',
    ),
    Track(
      title: 'Moonlight Calm',
      duration: '12 MIN',
      imageUrl:
          'https://images.unsplash.com/photo-1532767153582-b1a0e5145009?q=80&w=2668&auto=format&fit=crop',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      description: 'Bathe in the soothing moonlight.',
    ),
    Track(
      title: 'Forest Rain',
      duration: '25 MIN',
      imageUrl:
          'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?q=80&w=2574&auto=format&fit=crop',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      description: 'Gentle rain falling in a lush forest.',
    ),
    Track(
      title: 'Ocean Waves',
      duration: '30 MIN',
      imageUrl:
          'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?q=80&w=2652&auto=format&fit=crop',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      description: 'Rhythmic waves crashing on the shore.',
    ),
    Track(
      title: 'Zen Garden',
      duration: '18 MIN',
      imageUrl:
          'https://images.unsplash.com/photo-1584715642381-6f1c4b452b1c?q=80&w=2670&auto=format&fit=crop',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      description: 'Find your center in a peaceful garden.',
    ),
    Track(
      title: 'Mountain Air',
      duration: '22 MIN',
      imageUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=2670&auto=format&fit=crop',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      description: 'Crisp, clean air from the mountain tops.',
    ),
    Track(
      title: 'River Flow',
      duration: '14 MIN',
      imageUrl:
          'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?q=80&w=2670&auto=format&fit=crop',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      description: 'A gentle river flowing downstream.',
    ),
    Track(
      title: 'Starry Night',
      duration: '28 MIN',
      imageUrl:
          'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=2670&auto=format&fit=crop',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
      description: 'Gaze at the stars and let go.',
    ),
  ];

  Widget _buildTrackList() {
    return Column(
      children: _tracks.map((track) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildTrackItem(
            track: track,
            isActive: false, // Logic for active track can be added later
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrackItem({required Track track, required bool isActive}) {
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
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Opacity(
          opacity: isActive ? 1.0 : 0.8,
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFA3A7F4).withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(track.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: isActive
                    ? const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFFA3A7F4),
                        size: 32,
                      )
                    : null,
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
                    ),
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
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FD),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFFA3A7F4),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn().slideX(),
    );
  }
}
