import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'meditation_session_page.dart';

class MeditationDetailPage extends StatelessWidget {
  final Map<String, dynamic> session;

  const MeditationDetailPage({super.key, required this.session});

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
                child: Column(
                  children: [
                    _buildHeroImage()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(),
                    _buildInfoSection()
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),
                    _buildStepsList()
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            ),
            _buildBottomButton()
                .animate()
                .fadeIn(delay: 600.ms)
                .slideY(begin: 1, end: 0),
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
                Icons.arrow_back_ios_new,
                size: 20,
                color: Color(0xFF12141D),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Text(
            'Morning Start',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF12141D),
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
                Icons.favorite_border,
                size: 24,
                color: Color(0xFF12141D),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: AssetImage('assets/images/meditation_hero.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            '${session['title']} Meditation',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF12141D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${session['duration']} • ${session['category']}',
            style: const TextStyle(fontSize: 14, color: Color(0xFFA1A4B2)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    final steps = [
      {
        'icon': Icons.self_improvement,
        'title': 'Step 1: Find a comfortable position',
        'description':
            'Sit or lie down in a quiet space where you won\'t be disturbed. Relax your body and close your eyes.',
      },
      {
        'icon': Icons.air,
        'title': 'Step 2: Focus on your breath',
        'description':
            'Take a few deep breaths, inhaling through your nose and exhaling through your mouth. Notice the sensation of the air.',
      },
      {
        'icon': Icons.graphic_eq,
        'title': 'Step 3: Listen to the sounds',
        'description':
            'Pay attention to the sounds around you without judgment. Let them come and go as you continue to breathe.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: steps.map((step) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA3A7F4).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    color: const Color(0xFFA3A7F4),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF12141D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['description'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFA1A4B2),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FD),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MeditationSessionPage(session: session),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA3A7F4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
            shadowColor: const Color(0xFFA3A7F4).withValues(alpha: 0.3),
          ),
          child: const Text(
            'Start Meditation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
