import 'package:flutter/material.dart';
import 'package:eden_mind_app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'notification_service.dart';

enum NotificationType { reminder, achievement, tip, update, meditation }

class NotificationsPage extends StatefulWidget {
  final NotificationService? notificationService;

  const NotificationsPage({super.key, this.notificationService});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.notificationService ?? NotificationService();
    _loadNotifications();
  }

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First, try to init sample notifications for new users
      await _service.initSampleNotifications();

      // Then load all notifications
      final notifications = await _service.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _service.markAsRead(id);
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['isRead'] = true;
          _notifications[index]['read'] = true;
        }
      });
    } catch (e) {
      _showError('Failed to mark as read');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      setState(() {
        for (var notification in _notifications) {
          notification['isRead'] = true;
          notification['read'] = true;
        }
      });
      _showSuccess('All notifications marked as read');
    } catch (e) {
      _showError('Failed to mark all as read');
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      await _service.deleteNotification(id);
      setState(() {
        _notifications.removeWhere((n) => n['id'] == id);
      });
    } catch (e) {
      _showError('Failed to delete notification');
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text('This will delete all your notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.clearAll();
        setState(() => _notifications.clear());
        _showSuccess('All notifications cleared');
      } catch (e) {
        _showError('Failed to clear notifications');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  int get _unreadCount => _notifications
      .where((n) => n['isRead'] == false || n['read'] == false)
      .length;

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
                  ? _buildErrorState()
                  : _notifications.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: EdenMindTheme.primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _buildNotificationCard(notification, index)
                              .animate()
                              .fadeIn(delay: (100 * index).ms)
                              .slideX(begin: 0.1, end: 0);
                        },
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_unreadCount > 0)
                  Text(
                    '$_unreadCount unread',
                    style: TextStyle(
                      fontSize: 12,
                      color: EdenMindTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (_notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.done_all, size: 22),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
              color: EdenMindTheme.primaryColor,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep, size: 22),
              tooltip: 'Clear all',
              onPressed: _clearAll,
              color: Colors.grey,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load notifications',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: EdenMindTheme.primaryColor,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: EdenMindTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 48,
              color: EdenMindTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF12141D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up!",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final id = notification['id'] as int;
    final isRead =
        notification['isRead'] == true || notification['read'] == true;
    final type = _parseType(notification['type']);

    return Dismissible(
      key: Key(id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (_) => _deleteNotification(id),
      child: GestureDetector(
        onTap: () => _markAsRead(id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isRead
                ? null
                : Border.all(
                    color: EdenMindTheme.primaryColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: const Color(0xFF12141D),
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: EdenMindTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notification['createdAt']),
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  NotificationType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'reminder':
        return NotificationType.reminder;
      case 'achievement':
        return NotificationType.achievement;
      case 'tip':
        return NotificationType.tip;
      case 'update':
        return NotificationType.update;
      case 'meditation':
        return NotificationType.meditation;
      default:
        return NotificationType.tip;
    }
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (type) {
      case NotificationType.reminder:
        icon = Icons.alarm;
        color = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.1);
        break;
      case NotificationType.achievement:
        icon = Icons.emoji_events;
        color = Colors.amber;
        bgColor = Colors.amber.withValues(alpha: 0.1);
        break;
      case NotificationType.tip:
        icon = Icons.lightbulb_outline;
        color = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.1);
        break;
      case NotificationType.update:
        icon = Icons.new_releases;
        color = EdenMindTheme.primaryColor;
        bgColor = EdenMindTheme.primaryColor.withValues(alpha: 0.1);
        break;
      case NotificationType.meditation:
        icon = Icons.self_improvement;
        color = Colors.teal;
        bgColor = Colors.teal.withValues(alpha: 0.1);
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
