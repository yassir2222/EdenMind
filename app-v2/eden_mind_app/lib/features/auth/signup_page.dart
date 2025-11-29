import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import '../dashboard/dashboard_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    setState(() => _isLoading = true);
    try {
      // Keycloak handles registration via the login page usually, or we can add a specific param.
      // For now, we redirect to the standard login flow where users can choose to register.
      await context.read<AuthService>().login();
      if (mounted && context.read<AuthService>().isAuthenticated) {
        // Clear stack and go to dashboard
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/calm_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Image.asset('assets/images/app_logo.png'),
                    ),
                    const SizedBox(height: 30),

                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: const Color(0xFF3F414E),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Start your mindfulness journey today',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFA1A4B2),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Signup Button
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E97FD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 48,
                          ),
                          elevation: 5,
                          shadowColor: const Color(
                            0xFF8E97FD,
                          ).withValues(alpha: 0.4),
                        ),
                        child: const Text(
                          'SIGN UP WITH KEYCLOAK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),
                    Text(
                      'OR REGISTER WITH',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA1A4B2),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(
                          Icons.facebook,
                          const Color(0xFF7583CA),
                        ),
                        const SizedBox(width: 20),
                        _buildSocialIcon(
                          Icons.g_mobiledata,
                          const Color(0xFF3F414E),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ALREADY HAVE AN ACCOUNT? ',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFA1A4B2),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'LOG IN',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF8E97FD),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
