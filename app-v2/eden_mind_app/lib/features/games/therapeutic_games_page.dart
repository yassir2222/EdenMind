import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'breathing_game_page.dart';
import 'distortion_hunter_page.dart';
import 'serenity_tower_page.dart';

class TherapeuticGamesPage extends StatelessWidget {
  const TherapeuticGamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildTitleSection()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 32),
              _buildGamesGrid(context)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCircleButton(
          icon: Icons.chevron_left,
          onTap: () {
            // If pushed, pop. If tab, maybe switch tab or do nothing?
            // Assuming it might be used as a standalone page too.
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          iconSize: 32,
        ),
        _buildCircleButton(icon: Icons.more_horiz, onTap: () {}, iconSize: 24),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required double iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF12141D), size: iconSize),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Therapeutic Games',
          style: GoogleFonts.manrope(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.5,
            color: const Color(0xFF12141D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Engage your mind, find your calm.',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            height: 1.5,
            color: const Color(0xFFA1A4B2),
          ),
        ),
      ],
    );
  }

  Widget _buildGamesGrid(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          child: Column(
            children: [
              _buildGameCard(
                title: 'Le Jardin du Souffle',
                subtitle: 'Cardiac Coherence',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCmgmvnXd7Y_vpRXe6xoHXItSrSAtRY0UUZ19PId_7ZOaAWdez8xmNcoqUWXtvD2BHUg9m6ELqbIOGMY9ZrWdyXhoM2lQi519bugffftpZ8yvhaWYIgK10SYJPznsDxWMzN1v3AGNWrpUAAjG-Q9aUe1Zh0le8qCXGiYaZeEiIcBXZA7O9BF2c_xcBwsplmMrzexnX84SOVaXQSSvmP5VCuwEalQDZAQrZWUi2sqdOcRkRzv3pyjnsiIGa0Bh5KZyE9rZunBXgLMjA',
                aspectRatio: 3 / 4,
                backgroundColor: const Color(0xFFEBEBFF),
              ),
              const SizedBox(height: 16),
              _buildGameCard(
                title: 'La Tour de Sérénité',
                subtitle: 'Focus & Flow',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAiyM3GMbjBRRkalKkzHDvWdf4IpyklHTPwV7OSrplElJzJOyWNx0crow9TSMWVrbvqbSZXRGWGuXmMzv58c55LQX9eULzcpjqAz_UmhHAk-iE2G6amEDsPyuYGV3-DIzSKadmmIWJGCkODLbCcGQZc3Oc6i20U9oNjxfU_Mi93J60u7FLL4xuX87-2sGVzwxx2hZ6PGVDsgHk1hMtcnLwlWDv7YtgWhFSViE4lhl4c8sn-i9bui8p9wJKj-QLSSmlmYnyqL042J2s',
                aspectRatio: 1.0,
                backgroundColor: const Color(0xFFFFEFE2),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SerenityTowerPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildGameCard(
                title: "L'Inventaire d'Ancrage",
                subtitle: '5-4-3-2-1 Technique',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBaF8hexDeY039pBmyCENvdxe-qgq1QlNab__4rYmpaoQwD1QGw7MlFL8gNbUQ9QBvWuB_c8C9We4vnD6tBhvAidsA0_mcRT1TrgHcS_Rv2iyqU6Ny3NCN29NeLhp1ZANbNwTIG2HvXs3A1O7COXR_MnYAE13KrDymxAcQeRe0k9DIBKt9crEKE96ITe96r3-HJIjfaGn4hv-5EilP4nt9ZWgk3G-28Sqp3NKFmg22Zhku4PCGKBLTMZoeBBdc-yo5sQzgzG07pbVE',
                aspectRatio: 3 / 4,
                backgroundColor: const Color(0xFFE5F5FC),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Right Column
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 32), // Offset for masonry effect
              _buildGameCard(
                title: 'Chasseur de Distorsions',
                subtitle: 'CBT',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCWgaPHi6B-xDC9XXX2E-IHD-HTQj4n7eoNefluppp_YoGE7BaxsdfXjJtBBOf8Lv-TiSs5KVWuY1ppQkmR6Jtriq3djLaCYbb_3yVdEcCK3HKF50-6QZGSfYkyZcK8LAALIPrEsmiCiuFg5jooU_-sMChjyv3XebiYKSARUbzUaHIH6pxo3rMKRAVI6X9mEHI595uxlN2vh39uAy407cvHC4Zy-kDt2VPSRoPDG4zVij2qE44qHdv9agoqB36yjUhZxn4CpfXKM4o',
                aspectRatio: 1.0,
                backgroundColor: const Color(0xFFEBF9F4),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DistortionHunterPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildGameCard(
                title: 'Mosaïque des Émotions',
                subtitle: 'Visual Journaling',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCKkc5HDLzYZzOVpnafHxzW8BSv5yKvB-NA0jAIX3UcG-x_QzCzcAResTKo3Be1LjMCsoIXnymWKVYVi9HTnZhoQUNwKt_WVgwGNLv0y-J7BcUNfQtdw7HqWvpDx0wUvy4UiiroXxnheEY4RDtBy1SvovzWz0zwY8jlaLd0VDTnY7T6H7NvMHJi_uUK7-2Lj7es28kkaGEDirMaan_UXVkwdO84cLVxdfNCvbFOld3NmVU9NkwoLzRC4X6OVdw7FPtk2vrbYQw7MjE',
                aspectRatio: 3 / 4,
                backgroundColor: const Color(0xFFFBE5E5),
              ),
              const SizedBox(height: 16),
              _buildGameCard(
                title: 'Deep Breathing',
                subtitle: 'Relaxation',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBWnIfK5KXrVxBRNp5cxzlcpNSxoVowNR1_rAjrrYktZxEER5PmlogBXNq1I_N48DMZAi48EK91e4HQtU0KrGoX4mjKgEjXQF9wON0BAnVzgdja86_hRaNMb7mhw1u17PuuIUtBRrD832FbcfDTeF1Mv4YOGhDxs7Yy8IvHIPzhdgDvI6jZSiqGIRpqTKFSu9Xs_TdZW0CBCOOgxIHB46Nbf5doxrMqeuPZKRZwRx_zTzNk1CtxJ7MLxJBCgyocsneJL5fdvy185ZI',
                aspectRatio: 1.0,
                backgroundColor: const Color(0xFFA3A7F4).withValues(alpha: 0.1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BreathingGamePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required double aspectRatio,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: Image.network(imageUrl, fit: BoxFit.cover)),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
