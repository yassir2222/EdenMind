import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:eden_mind_app/config/app_config.dart';
import 'package:eden_mind_app/theme/app_theme.dart';

class ProgressPage extends StatefulWidget {
  final http.Client? client;
  final FlutterSecureStorage? secureStorage;

  const ProgressPage({super.key, this.client, this.secureStorage});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late final FlutterSecureStorage _secureStorage;
  late final http.Client _client;
  Map<String, dynamic>? _progressData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _secureStorage = widget.secureStorage ?? const FlutterSecureStorage();
    _client = widget.client ?? http.Client();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _client.get(
        Uri.parse('${AppConfig.baseUrl}/progress'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _progressData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load progress');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EdenMindTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFA3A7F4),
                      ),
                    )
                  : _error != null
                  ? _buildErrorWidget()
                  : RefreshIndicator(
                      onRefresh: _loadProgress,
                      color: EdenMindTheme.primaryColor,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWellnessScore()
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .scale(),
                            const SizedBox(height: 24),
                            _buildStatsGrid()
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideY(begin: 0.1, end: 0),
                            const SizedBox(height: 24),
                            _buildAchievementsSection()
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.1, end: 0),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: EdenMindTheme.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'My Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProgress),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load progress'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProgress,
            style: ElevatedButton.styleFrom(
              backgroundColor: EdenMindTheme.primaryColor,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessScore() {
    final score = _progressData?['wellnessScore'] ?? 0;
    final userName = _progressData?['userName'] ?? 'User';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EdenMindTheme.primaryColor,
            EdenMindTheme.primaryColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EdenMindTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Hello, $userName!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                children: [
                  Text(
                    score.toString(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Wellness Score',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _getScoreMessage(score),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreMessage(int score) {
    if (score >= 80) {
      return "Amazing! You're doing great on your wellness journey! 🌟";
    }
    if (score >= 60) return "Good progress! Keep up the great work! 💪";
    if (score >= 40) return "You're on the right track. Keep going! 🚀";
    if (score >= 20) return "Every step counts. Let's build momentum! 🌱";
    return "Start your wellness journey today! 🌅";
  }

  Widget _buildStatsGrid() {
    final moodLogs = _progressData?['totalMoodLogs'] ?? 0;
    final conversations = _progressData?['totalConversations'] ?? 0;
    final messages = _progressData?['totalMessages'] ?? 0;
    final streak = _progressData?['moodStreak'] ?? 0;
    final days = _progressData?['daysSinceRegistration'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF12141D),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.mood,
                value: moodLogs.toString(),
                label: 'Mood Logs',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                value: '$streak days',
                label: 'Current Streak',
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.chat_bubble_outline,
                value: conversations.toString(),
                label: 'Conversations',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.message_outlined,
                value: messages.toString(),
                label: 'Messages',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Icons.calendar_today,
          value: '$days days',
          label: 'Member Since',
          color: EdenMindTheme.primaryColor,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF12141D),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = _progressData?['achievements'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF12141D),
              ),
            ),
            Text(
              '${achievements.where((a) => a['unlocked'] == true).length}/${achievements.length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...achievements.map((achievement) {
          final unlocked = achievement['unlocked'] == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: unlocked ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: unlocked
                  ? Border.all(
                      color: EdenMindTheme.primaryColor.withValues(alpha: 0.3),
                      width: 2,
                    )
                  : null,
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: EdenMindTheme.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? EdenMindTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      achievement['icon'] ?? '🏆',
                      style: TextStyle(
                        fontSize: 24,
                        color: unlocked ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['name'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: unlocked
                              ? const Color(0xFF12141D)
                              : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        achievement['description'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                if (unlocked)
                  Icon(Icons.check_circle, color: EdenMindTheme.primaryColor)
                else
                  Icon(Icons.lock_outline, color: Colors.grey[400]),
              ],
            ),
          );
        }),
      ],
    );
  }
}
