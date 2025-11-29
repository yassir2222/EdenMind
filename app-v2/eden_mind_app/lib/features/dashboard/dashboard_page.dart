import 'package:flutter/material.dart';
import 'package:eden_mind_app/theme/app_theme.dart';
import 'package:eden_mind_app/features/chatbot/chatbot_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EdenMindTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.2, end: 0),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting()
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 30),
                    _buildActionGrid(
                      context,
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).scale(),
                    const SizedBox(height: 30),
                    _buildDailyCalm()
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 30),
                    _buildRecommendedSection().animate().fadeIn(
                      delay: 800.ms,
                      duration: 600.ms,
                    ),
                    const SizedBox(height: 100), // Spacing for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar()
          .animate()
          .fadeIn(delay: 1000.ms, duration: 600.ms)
          .slideY(begin: 1, end: 0),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.spa, color: EdenMindTheme.primaryColor, size: 32),
              const SizedBox(width: 8),
              Text(
                'MindWell',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: EdenMindTheme.textColor,
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey[600],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, Sarah',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: EdenMindTheme.textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'How are you feeling today?',
          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: 'AI Chatbot',
            subtitle: 'Talk it out',
            icon: Icons.smart_toy_outlined,
            color: Colors.deepPurple.withOpacity(0.1),
            iconBgColor: EdenMindTheme.primaryColor,
            buttonText: 'Start',
            buttonColor: EdenMindTheme.primaryColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatbotPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            title: 'Mood Log',
            subtitle: 'Track feelings',
            icon: Icons.mood,
            color: Colors.amber.withOpacity(0.1),
            iconBgColor: EdenMindTheme.secondaryColor,
            buttonText: 'Log',
            buttonColor: EdenMindTheme.secondaryColor,
            onTap: () {
              // Navigate to Mood Log
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconBgColor,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: EdenMindTheme.textColor,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCalm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3F414E), // Dark slate color
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Calm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Take a 5-min break',
                style: TextStyle(fontSize: 14, color: Colors.grey[300]),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended for you',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: EdenMindTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRecommendedCard(
                title: 'Calm Music',
                subtitle: 'Listen',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB1ezywX7QFy2SDh4LMhZ8emDFn_4y--GR-MgjyUXxmIeTu-n5bq2jnoQhCiv3ajqArDg_gS0pLosmQqYkt1CX4lbNnCJKiPeyEJ2DNi9m7ZQbXnk0R3gw5jBNTJwzZIkH0Mf_X1cFlzg3jtNBIpdUulFA8JMFKjnQUywO54llVkj-CiKD83WTsF6hQlw-L9kPk3HhZK_tph8oCYSD78PvqMSKdpRmedsntuBmjV_IiucGUX0MMMOR9dZxuOzoBhI0JwD-OTMEB9x4',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRecommendedCard(
                title: 'Meditation',
                subtitle: 'Focus',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB3DtKan55pNQOyhQnAKZURdLaUGoSpUjbPRXdM6uw3uIjP62x2_eN1OoMrQmCPVnQOKPJjgoEwPXwWTwahxAO-D9EVfiBZBM51k0P1PTfEu4rRN7kYXtbx0F68yGn2d3T4TuIY9RX8P6RsXsw17BioiwOtj1Es96C_SK0jmVQuVu9p6TbqDktn4igtLe4HYnF2BMCJf1X9zsuko408RjaJ3heqIVemagyb9h-FbPsWF4I0erZO2MEpGlsplNKzf8Yq19bF7N5lGGY',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendedCard({
    required String title,
    required String subtitle,
    required String imageUrl,
  }) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: true,
              ),
              _buildNavItem(
                icon: Icons.psychology_outlined,
                label: 'Exercises',
              ),
              _buildNavItem(icon: Icons.music_note_outlined, label: 'Music'),
              _buildNavItem(icon: Icons.person_outline, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? EdenMindTheme.primaryColor : Colors.grey[400],
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? EdenMindTheme.primaryColor : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
