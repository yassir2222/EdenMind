import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
              _buildGamesGrid()
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

  Widget _buildGamesGrid() {
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
              _buildNewGameCard(),
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
                onTap: () {},
                splashColor: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewGameCard() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFA3A7F4).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFA3A7F4).withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle
                .solid, // Flutter doesn't support dashed border natively easily without a package or custom painter.
            // I'll stick to solid for now or use a custom painter if strictly needed, but solid with low opacity is often close enough for MVP.
            // Actually, I can use a CustomPaint for dashed border if I want to be perfect.
            // Let's try to be perfect.
          ),
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: const Color(0xFFA3A7F4).withValues(alpha: 0.3),
            strokeWidth: 2,
            dashPattern: [6, 4],
            radius: const Radius.circular(24),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New Game',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFA3A7F4),
                  ),
                ),
                Text(
                  'Coming Soon',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA3A7F4).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final Radius radius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1,
    this.dashPattern = const [5, 3],
    this.radius = Radius.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          radius,
        ),
      );

    final Path dashedPath = _createDashedPath(path);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      int index = 0;
      while (distance < metric.length) {
        final double len = dashPattern[index % dashPattern.length];
        if (distance + len > metric.length) {
          dest.addPath(
            metric.extractPath(distance, metric.length),
            Offset.zero,
          );
          break;
        }
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += len;
        index++;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashPattern != dashPattern ||
        oldDelegate.radius != radius;
  }
}
