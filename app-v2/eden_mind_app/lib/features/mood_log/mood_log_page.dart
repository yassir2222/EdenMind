import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eden_mind_app/theme/app_theme.dart';
import 'add_mood_page.dart';
import 'mood_service.dart';
import 'package:provider/provider.dart';

class MoodLogPage extends StatefulWidget {
  const MoodLogPage({super.key});

  @override
  State<MoodLogPage> createState() => _MoodLogPageState();
}

class _MoodLogPageState extends State<MoodLogPage> {
  List<dynamic> _moods = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    try {
      final moods = await context.read<MoodService>().getMoods();
      if (mounted) {
        setState(() {
          _moods = moods;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EdenMindTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _moods.isEmpty
                      ? const Center(child: Text('No mood logs yet.'))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Column(
                            children: List.generate(_moods.length, (index) {
                              final mood = _moods[index];
                              final isLast = index == _moods.length - 1;
                              final alignment = index % 2 == 0
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft;

                              return _buildTimelineItem(
                                context,
                                moodData: mood,
                                isLast: isLast,
                                alignment: alignment,
                              );
                            }),
                          ),
                        ),
                ),
              ],
            ),
            Positioned(
              bottom: 96,
              right: 24,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddMoodPage(),
                    ),
                  );
                  if (result == true) {
                    _loadMoods(); // Refresh list
                  }
                },
                backgroundColor: EdenMindTheme.primaryColor,
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (Navigator.of(context).canPop())
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: EdenMindTheme.textColor,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How are you feeling?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: EdenMindTheme.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your Mood History',
                  style: TextStyle(
                    fontSize: 16,
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

  Widget _buildTimelineItem(
    BuildContext context, {
    required Map<String, dynamic> moodData,
    required bool isLast,
    required Alignment alignment,
  }) {
    final moodType = moodData['emotionType'] ?? 'Unknown';
    final activitiesStr = moodData['activities'] as String? ?? '';
    final activities = activitiesStr.isNotEmpty
        ? activitiesStr.split(',')
        : <String>[];
    final recordedAtStr = moodData['recordedAt'] as String?;
    final recordedAt = recordedAtStr != null
        ? DateTime.parse(recordedAtStr)
        : DateTime.now();
    final time =
        "${_getMonthName(recordedAt.month)} ${recordedAt.day}, ${recordedAt.hour.toString().padLeft(2, '0')}:${recordedAt.minute.toString().padLeft(2, '0')}";

    // Determine icon and color based on moodType
    IconData icon;
    Color color;
    switch (moodType) {
      case 'Happy':
        icon = Icons.sentiment_very_satisfied;
        color = Colors.amber;
        break;
      case 'Calm':
        icon = Icons.self_improvement;
        color = EdenMindTheme.primaryColor;
        break;
      case 'Sad':
        icon = Icons.sentiment_dissatisfied;
        color = Colors.blue;
        break;
      case 'Anxious':
        icon = Icons.sentiment_very_dissatisfied;
        color = Colors.purple;
        break;
      case 'Tired':
        icon = Icons.bedtime;
        color = Colors.grey;
        break;
      default:
        icon = Icons.sentiment_neutral;
        color = Colors.grey;
    }

    return IntrinsicHeight(
      child: Stack(
        children: [
          // Center Line
          if (!isLast)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Container(width: 2, color: const Color(0xFFEAEBF1)),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Row(
              mainAxisAlignment: alignment == Alignment.centerRight
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                // Spacer for the other side
                if (alignment == Alignment.centerRight) const Spacer(),

                // Card
                SizedBox(
                      width:
                          MediaQuery.of(context).size.width *
                          0.42, // Approx 50% - padding
                      child: Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, color: color, size: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        moodType,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: EdenMindTheme.textColor,
                                        ),
                                      ),
                                      Text(
                                        time,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: EdenMindTheme.subTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (activities.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: activities.map((activity) {
                                  return Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 120,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: EdenMindTheme.backgroundColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getActivityIcon(activity),
                                          size: 14,
                                          color: EdenMindTheme.textColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            activity.trim(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: EdenMindTheme.textColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(
                      begin: alignment == Alignment.centerRight ? 0.2 : -0.2,
                      end: 0,
                    ),

                if (alignment == Alignment.centerLeft) const Spacer(),
              ],
            ),
          ),

          // Center Dot
          Positioned(
            top: 24, // Align with the top of the card roughly
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: EdenMindTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'work':
        return Icons.work_outline;
      case 'family':
        return Icons.people_outline;
      case 'exercise':
        return Icons.fitness_center;
      case 'sleep':
        return Icons.bedtime_outlined;
      case 'hobby':
        return Icons.palette_outlined;
      default:
        return Icons.circle;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }
}
