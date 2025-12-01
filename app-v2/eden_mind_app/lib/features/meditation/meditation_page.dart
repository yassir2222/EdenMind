import 'package:flutter/material.dart';
import 'meditation_detail_page.dart';

import 'package:flutter_animate/flutter_animate.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Guided', 'Sounds', 'Timer'];

  final List<Map<String, dynamic>> _sessions = [
    {
      'title': 'Morning Start',
      'duration': '10 min',
      'category': 'Focus',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAwyboGUvvaBFrDMMhr8UNrU7vOgpEBDvc-ntHuMmsCEGz2R2efhUCEGSHMSGPNj2j3gGW06Y8373T3WkWe26w_vUIUgf1jSHwcMN-wEavHQ18EROJZ7MxFnxxnp7qlOZyibXwiOR-VwvjOUywNY-cfdu3XGU09YUTft85nGak9C2YCtNK5tOGhIHRieol9fFmQKkr6xZy0hZAnABA2bHhA13qvjL-jHCZXtLCJNwoOMfeehGwQwBjqI3WQneqnoGYcQ9HwPsv5UQc',
      'color': Color(0xFFA3A7F4), // Primary from design
    },
    {
      'title': 'Stress Relief',
      'duration': '15 min',
      'category': 'Anxiety',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD8WsvCzqgGUB_QFmYoX6aSxG9J9-CLov_pvTQbtPZ29cUaiqvsEOnLA1XOm5aqs-SoZIF3jLTt7K0LxtwRnO2cFkA1ictmaUXLRp8t9gvbWLEYKILdTfFytVDL8N6CcVSoYDyFFkMh9Dg_hLnBt_H_B_d-oB4MB4925HVIKHQ-t7Vgx5Kd4D9omy9qtH8e7KyjZu7Y6UXHocISvdM7GTClEaAy6pmLjQM74QRHIqmXLdBCMy4KXikFGG63ZUlvyU2yy5sr0vmiy8Q',
      'color': Color(0xFFF9D5A2), // Secondary from design
    },
    {
      'title': 'Deep Sleep',
      'duration': '20 min',
      'category': 'Sleep',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuADmOCSygLpA6tdf_MvNGGV3QI9Kf-9wTVcSTvG2-itERbQ0EDrl66kailEaXI7eLbSPY0omy0X6oGjdFAtkcLLE-FI6bKezrelHVzDqauW4UcNDng82Iou-02-nKsaggZf3h2y_TruPzJKsFQim_yR1nJKeEwLOIfmrwhjG_wOn2o3sWnZQj2W3axI_M_4bPlOAWAErHERGwnlemn4mO-ZcFB3tCSzfCp9JIttedmLNUBea3sLQCYtn_M3CP62FzyLIr1Kryj_ZT4',
      'color': Color(0xFFA3A7F4), // Primary
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD), // Background from design
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
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
                        color: Color(0xFF12141D), // Text Primary
                        fontFamily:
                            'Manrope', // Assuming font is available or fallback
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(),
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
          Expanded(
            child: Text(
              'Meditation',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF12141D),
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDhbCOUCYEO9k6eLXvGgDF0NzDa3uARjoR5YX60q8p7WZDIbEpR68SbiflVfpbNZqlT9EPmYY0X1Pfxtxq31JGe4ccV1izEpgzC96gPJ9ssRbQOgbcOpI-9mWcyKAeqApESMcmRecHGs_AgFl3eUoL59Iwd2AHiYIoF9jeHQPa_2GlSUFGZGJq3tCsKZ9rJwU3aMQKs8ATn6ryfmJldkfEn0khsdM4d0Kh0suGqYc2UWoQkHpxFRZQWD2kkz5F81t-XFxohjlyilRk',
          ),
          fit: BoxFit.cover,
        ),
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
                              image: DecorationImage(
                                image: NetworkImage(session['image']),
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
                                  session['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF12141D),
                                  ),
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
                              color: session['color'],
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
