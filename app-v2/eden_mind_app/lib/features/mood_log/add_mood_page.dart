import 'package:flutter/material.dart';
import 'package:eden_mind_app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eden_mind_app/features/mood_log/mood_service.dart';

class AddMoodPage extends StatefulWidget {
  const AddMoodPage({super.key});

  @override
  State<AddMoodPage> createState() => _AddMoodPageState();
}

class _AddMoodPageState extends State<AddMoodPage> {
  int _selectedDayIndex = 3; // Default to current day
  String _selectedMood = 'Happy';
  final Set<String> _selectedActivities = {'Work'};
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _moods = [
    {
      'name': 'Happy',
      'icon': Icons.sentiment_very_satisfied,
      'color': Colors.amber,
    },
    {
      'name': 'Calm',
      'icon': Icons.self_improvement,
      'color': EdenMindTheme.primaryColor,
    },
    {'name': 'Sad', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.blue},
    {
      'name': 'Anxious',
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Colors.purple,
    },
    {'name': 'Tired', 'icon': Icons.bedtime, 'color': Colors.grey},
  ];

  final List<Map<String, dynamic>> _activities = [
    {'name': 'Work', 'icon': Icons.work_outline},
    {'name': 'Family', 'icon': Icons.groups_outlined},
    {'name': 'Exercise', 'icon': Icons.fitness_center},
    {'name': 'Sleep', 'icon': Icons.bedtime_outlined},
    {'name': 'Hobby', 'icon': Icons.palette_outlined},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    setState(() => _isLoading = true);
    try {
      await MoodService().saveMood(
        _selectedMood,
        _selectedActivities.toList(),
        _noteController.text,
      );
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving mood: $e')));
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
      backgroundColor: EdenMindTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EdenMindTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mood Log',
          style: TextStyle(
            color: EdenMindTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: EdenMindTheme.textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendarStrip(),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
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
                  const Text(
                    'How are you feeling today?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: EdenMindTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select the mood that best describes how you feel.',
                    style: TextStyle(
                      fontSize: 14,
                      color: EdenMindTheme.subTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildMoodSelector(),
                  const SizedBox(height: 32),
                  const Text(
                    'What have you been up to?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: EdenMindTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityChips(),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      filled: true,
                      fillColor: EdenMindTheme.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveMood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EdenMindTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor: EdenMindTheme.primaryColor.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Mood',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  late DateTime _currentDate;
  late List<DateTime> _currentWeek;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _generateCurrentWeek();
    // Set selected index to today (which should be the last day if we end on today, or find today in the list)
    // For "Current Week" (Mon-Sun), we find today's index.
    _selectedDayIndex = _currentWeek.indexWhere(
      (date) =>
          date.year == _currentDate.year &&
          date.month == _currentDate.month &&
          date.day == _currentDate.day,
    );
    if (_selectedDayIndex == -1) {
      _selectedDayIndex = 0; // Fallback
    }
  }

  void _generateCurrentWeek() {
    final now = DateTime.now();
    // Find the most recent Monday
    final currentWeekday = now.weekday;
    final firstDayOfWeek = now.subtract(Duration(days: currentWeekday - 1));
    _currentWeek = List.generate(7, (index) {
      return firstDayOfWeek.add(Duration(days: index));
    });
  }

  String _getMonthName(int month) {
    const months = [
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
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  Widget _buildCalendarStrip() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final monthName = _getMonthName(_currentDate.month);
    final year = _currentDate.year;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: EdenMindTheme.subTextColor,
                ),
                onPressed: () {
                  setState(() {
                    _currentDate = _currentDate.subtract(
                      const Duration(days: 7),
                    );
                    _generateCurrentWeek();
                    _selectedDayIndex = -1; // Reset selection or keep logic
                  });
                },
              ),
              Text(
                '$monthName $year',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: EdenMindTheme.textColor,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: EdenMindTheme.subTextColor,
                ),
                onPressed: () {
                  setState(() {
                    _currentDate = _currentDate.add(const Duration(days: 7));
                    _generateCurrentWeek();
                    _selectedDayIndex = -1;
                  });
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = _currentWeek[index];
              final isSelected = index == _selectedDayIndex;
              final isToday =
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = index),
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? EdenMindTheme.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    border: isToday && !isSelected
                        ? Border.all(color: EdenMindTheme.primaryColor)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        days[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : EdenMindTheme.subTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? EdenMindTheme.primaryColor
                                : EdenMindTheme.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _moods.map((mood) {
        final isSelected = _selectedMood == mood['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedMood = mood['name']),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? mood['color'].withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: mood['color'], width: 2)
                      : null,
                ),
                child: Icon(
                  mood['icon'],
                  size: 32,
                  color: isSelected
                      ? mood['color']
                      : EdenMindTheme.subTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mood['name'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? mood['color']
                      : EdenMindTheme.subTextColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityChips() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _activities.map((activity) {
        final isSelected = _selectedActivities.contains(activity['name']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedActivities.remove(activity['name']);
              } else {
                _selectedActivities.add(activity['name']);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? EdenMindTheme.primaryColor.withValues(alpha: 0.1)
                  : EdenMindTheme.backgroundColor,
              borderRadius: BorderRadius.circular(30),
              border: isSelected
                  ? Border.all(color: EdenMindTheme.primaryColor)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  activity['icon'],
                  size: 18,
                  color: isSelected
                      ? EdenMindTheme.primaryColor
                      : EdenMindTheme.subTextColor,
                ),
                const SizedBox(width: 8),
                Text(
                  activity['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? EdenMindTheme.primaryColor
                        : EdenMindTheme.textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
