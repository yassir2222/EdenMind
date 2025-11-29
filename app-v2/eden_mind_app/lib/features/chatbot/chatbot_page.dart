import 'package:flutter/material.dart';
import 'package:eden_mind_app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EdenMindTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildBotMessage(
                    'Hello! I\'m ZenBot, your personal companion. How are you feeling today?',
                    delay: 200.ms,
                  ),
                  const SizedBox(height: 24),
                  _buildUserMessage(
                    'I\'m feeling a bit anxious about my upcoming presentation.',
                    delay: 600.ms,
                  ),
                  const SizedBox(height: 24),
                  _buildBotMessage(
                    'I understand. That sounds stressful. Let\'s try a quick breathing exercise together. Are you ready?',
                    delay: 1000.ms,
                  ),
                ],
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          Column(
            children: [
              Text(
                'ZenBot',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: EdenMindTheme.textColor,
                ),
              ),
              Text(
                'Online',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotMessage(String message, {Duration? delay}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAUjoZSD0Z1JZ3DnYJjDWgcUXZLhXIwDd94lBHx1PYegts1HLu7qllFbo7tYLdaw112irk9etRP26HOJbTEdGxhYNqkjzXVUPd8o2zTaxoTuU7tOpJ_uN5uHHfA73qYZcD5bWLxQAJXQnlsV1Wk9O7Q6XJPgJSPjN851jJ0GNxu6gYT_ORjdMnsB5YMQ2tBMmJEzsOnf8USSIDSHcKan6FlZIg1aesCDaQrO7fLIMjvVrmUXXHR4GEbj_EwOVYrASFQLlS1xe4JoQE'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: EdenMindTheme.textColor,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay).slideX(begin: -0.1, end: 0);
  }

  Widget _buildUserMessage(String message, {Duration? delay}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: EdenMindTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay).slideX(begin: 0.1, end: 0);
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: EdenMindTheme.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: EdenMindTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                    ),
                  ),
                  Icon(Icons.mood, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: EdenMindTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
