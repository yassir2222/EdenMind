import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final userProfile = authService.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF3F414E),
      ),
      body: Center(
        child: userProfile == null
            ? const Text('No user data')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF8E97FD),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userProfile['name'] ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3F414E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userProfile['email'] ?? 'No email',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFA1A4B2),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      await context.read<AuthService>().logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 32,
                      ),
                    ),
                    child: const Text('LOGOUT'),
                  ),
                ],
              ),
      ),
    );
  }
}
