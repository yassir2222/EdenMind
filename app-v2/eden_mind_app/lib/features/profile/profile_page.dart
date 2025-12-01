import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eden_mind_app/theme/app_theme.dart';
import '../auth/auth_service.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final userProfile = authService.userProfile;
    final name = userProfile?['name'] ?? 'User';
    final email = userProfile?['email'] ?? 'No email';
    // Static fallback as per design request
    const memberSince = 'October 2023';

    return Scaffold(
      backgroundColor: EdenMindTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children:
                [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      _buildProfileHeader(name, userProfile?['avatarUrl']),
                      const SizedBox(height: 20),
                      _buildProgressButton(context),
                      const SizedBox(height: 24),
                      _buildInfoSection(name, email, memberSince),
                      const SizedBox(height: 32),
                      _buildSettingsSection(context),
                      const SizedBox(height: 32),
                      _buildSupportSection(context),
                      const SizedBox(height: 32),
                      _buildLogoutButton(context),
                      const SizedBox(height: 40),
                    ]
                    .animate(interval: 50.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: EdenMindTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String name, String? avatarUrl) {
    return Column(
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: EdenMindTheme.primaryColor,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Hello, $name',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: EdenMindTheme.textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Let's check in on your progress",
          style: const TextStyle(
            fontSize: 16,
            color: EdenMindTheme.subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: EdenMindTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
          ),
          child: const Text(
            'View My Progress',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String name, String email, String memberSince) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
        child: Column(
          children: [
            _buildInfoTile(Icons.person_outline, name, 'Full Name'),
            const Divider(height: 1, indent: 60),
            _buildInfoTile(Icons.mail_outline, email, 'Email'),
            const Divider(height: 1, indent: 60),
            _buildInfoTile(
              Icons.calendar_today_outlined,
              memberSince,
              'Member Since',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: EdenMindTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: EdenMindTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: EdenMindTheme.textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: EdenMindTheme.subTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: EdenMindTheme.textColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
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
            child: Column(
              children: [
                _buildSwitchTile(
                  Icons.notifications_outlined,
                  'Push Notifications',
                  true,
                ),
                const Divider(height: 1, indent: 60),
                _buildNavTile(Icons.lock_outline, 'Account Security'),
                const Divider(height: 1, indent: 60),
                _buildNavTile(
                  Icons.credit_card_outlined,
                  'Manage Subscription',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Support & Legal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: EdenMindTheme.textColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
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
            child: Column(
              children: [
                _buildNavTile(Icons.help_outline, 'Help & Support'),
                const Divider(height: 1, indent: 60),
                _buildNavTile(Icons.gavel_outlined, 'Privacy Policy'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: EdenMindTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: EdenMindTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: EdenMindTheme.textColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {},
            activeTrackColor: EdenMindTheme.primaryColor,
            thumbColor: WidgetStateProperty.all(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(IconData icon, String title) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: EdenMindTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: EdenMindTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: EdenMindTheme.textColor,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: EdenMindTheme.subTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () async {
          await context.read<AuthService>().logout();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        },
        child: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: EdenMindTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
