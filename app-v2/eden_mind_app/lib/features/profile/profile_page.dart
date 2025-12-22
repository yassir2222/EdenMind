import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eden_mind_app/theme/app_theme.dart';
import '../auth/auth_service.dart';
import '../auth/login_page.dart';
import 'progress_page.dart';
import 'dart:developer';

class ProfilePage extends StatelessWidget {
  final ImagePicker? imagePicker;

  const ProfilePage({super.key, this.imagePicker});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final userProfile = authService.userProfile;

    String name = 'User';
    String email = userProfile?['sub'] ?? 'No email';
    String memberSince = 'October 2023'; // Default fallback

    if (userProfile != null) {
      log('userProfile Response: $userProfile', name: 'userProfile');
      // 1. Handle Name
      if (userProfile.containsKey('firstName') &&
          userProfile.containsKey('lastName')) {
        name = '${userProfile['firstName']} ${userProfile['lastName']}';
      } else if (userProfile.containsKey('sub')) {
        // Fallback: Derive from email if names are missing
        final String sub = userProfile['sub'];
        if (email == 'No email') email = sub;

        if (name == 'User') {
          if (sub.contains('@')) {
            final localPart = sub.split('@')[0];
            name = localPart
                .split(RegExp(r'[._]'))
                .map((word) {
                  if (word.isEmpty) return '';
                  return '${word[0].toUpperCase()}${word.substring(1)}';
                })
                .join(' ');
          } else {
            name = sub;
          }
        }
      }

      // 2. Handle Member Since Date
      if (userProfile.containsKey('createdAt')) {
        try {
          final DateTime createdAt = DateTime.parse(userProfile['createdAt']);
          final List<String> months = [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December',
          ];
          memberSince = '${months[createdAt.month - 1]} ${createdAt.year}';
        } catch (e) {
          debugPrint('Error parsing createdAt: $e');
        }
      }
    }

    return Scaffold(
      backgroundColor: EdenMindTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildProfileHeader(context, name, userProfile?['avatarUrl']),
              const SizedBox(height: 20),
              _buildProgressButton(context),
              const SizedBox(height: 24),
              _buildInfoSection(name, email, memberSince),
              const SizedBox(height: 32),
              _buildPersonalInfoSection(context, userProfile),
              const SizedBox(height: 32),
              _buildSettingsSection(context),
              const SizedBox(height: 32),
              _buildSupportSection(context),
              const SizedBox(height: 32),
              _buildLogoutButton(context),
              const SizedBox(height: 40),
            ],
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

  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String? avatarUrl,
  ) {
    return Column(
      children: [
        Stack(
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
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : null,
                onBackgroundImageError:
                    (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? (exception, stackTrace) {
                        debugPrint('Avatar load error: $exception');
                      }
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
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
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showImagePickerOptions(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: EdenMindTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
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

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(context, ImageSource.camera);
              },
            ),
            if (context.read<AuthService>().userProfile?['avatarUrl'] != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _removeImage(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = imagePicker ?? ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        // if (!context.mounted) return;

        // Show loading indicator
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Uploading image...')));

        final authService = context.read<AuthService>();

        // Read file as bytes (works for both web and mobile)
        final bytes = await pickedFile.readAsBytes();
        final filename = pickedFile.name.isNotEmpty
            ? pickedFile.name
            : 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final imageUrl = await authService.uploadImageBytes(bytes, filename);

        if (imageUrl != null) {
          await authService.updateProfile(avatarUrl: imageUrl);
          // if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // }
        }
      }
    } catch (e) {
      // if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      // }
    }
  }

  Future<void> _removeImage(BuildContext context) async {
    try {
      final authService = context.read<AuthService>();
      // We can pass empty string or null depending on backend handling.
      // Let's assume empty string clears it or we need a specific way.
      // Based on typical implementations, setting it to null or empty string works.
      await authService.updateProfile(avatarUrl: '');

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile image removed')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error removing image: $e')));
      }
    }
  }

  Widget _buildProgressButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProgressPage()),
            );
          },
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
              // border: Border.all(color: EdenMindTheme.primaryColor.withValues(alpha: 0.2)),
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

  Widget _buildPersonalInfoSection(
    BuildContext context,
    Map<String, dynamic>? userProfile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EdenMindTheme.textColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: EdenMindTheme.primaryColor),
                onPressed: () =>
                    _showEditProfileBottomSheet(context, userProfile),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildInfoCard(
                Icons.cake_outlined,
                'Birthday',
                userProfile?['birthday'] ?? 'Not set',
              ),
              _buildInfoCard(
                Icons.family_restroom_outlined,
                'Family',
                userProfile?['familySituation'] ?? 'Not set',
              ),
              _buildInfoCard(
                Icons.work_outline,
                'Work Type',
                userProfile?['workType'] ?? 'Not set',
              ),
              _buildInfoCard(
                Icons.access_time,
                'Work Hours',
                userProfile?['workHours'] ?? 'Not set',
              ),
              _buildInfoCard(
                Icons.child_care,
                'Children',
                userProfile?['childrenCount']?.toString() ?? 'Not set',
              ),
              _buildInfoCard(
                Icons.public,
                'Country',
                userProfile?['country'] ?? 'Not set',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: EdenMindTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: EdenMindTheme.subTextColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: EdenMindTheme.textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showEditProfileBottomSheet(
    BuildContext context,
    Map<String, dynamic>? userProfile,
  ) {
    final birthdayController = TextEditingController(
      text: userProfile?['birthday'],
    );
    final familyController = TextEditingController(
      text: userProfile?['familySituation'],
    );
    final workTypeController = TextEditingController(
      text: userProfile?['workType'],
    );
    final workHoursController = TextEditingController(
      text: userProfile?['workHours'],
    );
    final childrenController = TextEditingController(
      text: userProfile?['childrenCount']?.toString(),
    );
    final countryController = TextEditingController(
      text: userProfile?['country'],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: EdenMindTheme.textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Form Stats
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('Birthday'),
                    _buildTextField(
                      controller: birthdayController,
                      hint: 'YYYY-MM-DD',
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 20),
                    _buildInputLabel('Family Situation'),
                    _buildTextField(
                      controller: familyController,
                      hint: 'e.g. Married, Single',
                      icon: Icons.family_restroom,
                    ),
                    const SizedBox(height: 20),
                    _buildInputLabel('Work Type'),
                    _buildTextField(
                      controller: workTypeController,
                      hint: 'e.g. Engineer, Student',
                      icon: Icons.work_outline,
                    ),
                    const SizedBox(height: 20),
                    _buildInputLabel('Work Hours'),
                    _buildTextField(
                      controller: workHoursController,
                      hint: 'e.g. 9-5, Flexible',
                      icon: Icons.access_time,
                    ),
                    const SizedBox(height: 20),
                    _buildInputLabel('Number of Children'),
                    _buildTextField(
                      controller: childrenController,
                      hint: '0',
                      icon: Icons.child_care,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    _buildInputLabel('Country'),
                    _buildTextField(
                      controller: countryController,
                      hint: 'Current residence',
                      icon: Icons.public,
                    ),
                    const SizedBox(height: 40), // Spacer for bottom
                  ],
                ),
              ),
            ),
            // Save Button
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await context.read<AuthService>().updateProfile(
                        birthday: birthdayController.text.isEmpty
                            ? null
                            : birthdayController.text,
                        familySituation: familyController.text.isEmpty
                            ? null
                            : familyController.text,
                        workType: workTypeController.text.isEmpty
                            ? null
                            : workTypeController.text,
                        workHours: workHoursController.text.isEmpty
                            ? null
                            : workHoursController.text,
                        childrenCount: int.tryParse(childrenController.text),
                        country: countryController.text.isEmpty
                            ? null
                            : countryController.text,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated!')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EdenMindTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: EdenMindTheme.textColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, color: EdenMindTheme.textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
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
            await Navigator.of(context).pushAndRemoveUntil(
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
