import 'package:flutter/material.dart';
import 'package:eden_mind_app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'chat_service.dart';
import 'dart:ui'; // For BackdropFilter
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'elevenlabs_tts_service.dart';

class ChatbotPage extends StatefulWidget {
  final String? initialMood;
  final String? initialMessage;

  const ChatbotPage({super.key, this.initialMood, this.initialMessage});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  ChatService get _chatService => context.read<ChatService>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // State variables for chat handling
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _conversations = [];
  int? _currentConversationId;
  bool _isLoading = false;
  bool _isMessagesLoading = false;

  // Voice chat state
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ElevenLabsTtsService _elevenLabsTts = ElevenLabsTtsService();
  bool _isListening = false;
  bool _voiceModeEnabled = false;
  bool _speechAvailable = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
    // Use mood-aware message if provided, otherwise default greeting
    if (widget.initialMessage != null && widget.initialMood != null) {
      _messages.add({
        'text': widget.initialMessage!,
        'isBot': true,
        'mood': widget.initialMood,
      });
    } else {
      _messages.add({
        'text':
            'Hello! I\'m ZenBot, your personal companion. How are you feeling today?',
        'isBot': true,
      });
    }
    _fetchConversations();
  }

  Future<void> _initVoice() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );
    
    // Set up ElevenLabs completion handler
    _elevenLabsTts.onSpeakingComplete = () {
      if (mounted) setState(() => _isSpeaking = false);
    };
    
    setState(() {});
  }

  Future<void> _speak(String text) async {
    if (_voiceModeEnabled) {
      // Clean markdown for speech
      final cleanText = text
          .replaceAll(RegExp(r'\*\*|\*|__|_|`|#'), '')
          .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '')
          .replaceAll(RegExp(r'\n+'), ' ');
      
      setState(() => _isSpeaking = true);
      
      await _elevenLabsTts.speak(cleanText);
    }
  }

  Future<void> _stopSpeaking() async {
    await _elevenLabsTts.stop();
    setState(() => _isSpeaking = false);
  }

  void _startListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    await _stopSpeaking();
    setState(() => _isListening = true);

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _controller.text = result.recognizedWords;
          setState(() => _isListening = false);
          if (result.recognizedWords.isNotEmpty) {
            _sendMessage();
          }
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _fetchConversations() async {
    try {
      final convs = await _chatService.getConversations();
      if (mounted) {
        setState(() {
          _conversations = convs;
        });
      }
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
    }
  }

  Future<void> _loadConversation(int id) async {
    if (_currentConversationId == id) return;

    setState(() {
      _isMessagesLoading = true;
      _currentConversationId = id;
      _messages.clear(); // Clear current messages
    });
    Navigator.pop(context); // Close drawer

    try {
      final messages = await _chatService.getMessages(id);
      if (mounted) {
        setState(() {
          _messages = messages
              .map(
                (m) => {
                  'text': m['content'],
                  'isBot': m['senderType'] == 'BOT',
                },
              )
              .toList();
          _isMessagesLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMessagesLoading = false;
          // Fallback/Error message
          _messages.add({
            'text': 'Failed to load conversation history.',
            'isBot': true,
          });
        });
      }
    }
  }

  void _startNewChat() {
    Navigator.pop(context); // Close drawer
    setState(() {
      _currentConversationId = null;
      _messages.clear();
      _messages.add({
        'text':
            'Hello! I\'m ZenBot, your personal companion. How are you feeling today?',
        'isBot': true,
      });
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isBot': false});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final result = await _chatService.sendMessage(
        text,
        conversationId: _currentConversationId,
      );

      if (mounted) {
        final botResponse = result['answer'] as String;
        setState(() {
          _messages.add({'text': botResponse, 'isBot': true});
          _isLoading = false;
          _currentConversationId =
              result['conversationId']; // Ensure ID is linked for subsequent messages
        });
        _scrollToBottom(); // Scroll after new message
        _fetchConversations(); // Refresh list to show updated timestamp/order or new chat
        _speak(botResponse); // Speak the response if voice mode enabled
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'text':
                'Sorry, I am having trouble connecting right now. Please try again later.',
            'isBot': true,
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EdenMindTheme.backgroundColor,
      drawer: _buildDrawer(), // Add Drawer
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isMessagesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(24),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return _buildTypingIndicator();
                        }
                        final message = _messages[index];
                        if (message['isBot']) {
                          return _buildBotMessage(message['text'], delay: 0.ms);
                        } else {
                          return _buildUserMessage(
                            message['text'],
                            delay: 0.ms,
                          );
                        }
                      },
                    ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
            ),
            child: Column(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Conversations',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: EdenMindTheme.textColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: _startNewChat,
                    icon: const Icon(Icons.add),
                    label: const Text("New Chat"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EdenMindTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _conversations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No conversations yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start chatting with ZenBot!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) {
                            final conv = _conversations[index];
                            final isActive =
                                conv['id'] == _currentConversationId;
                            final createdAt = conv['createdAt'] != null
                                ? _formatDate(conv['createdAt'])
                                : '';

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? EdenMindTheme.primaryColor.withValues(
                                        alpha: 0.1,
                                      )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  conv['title'] ?? 'Conversation ${conv['id']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isActive
                                        ? EdenMindTheme.primaryColor
                                        : EdenMindTheme.textColor,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  createdAt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? EdenMindTheme.primaryColor.withValues(
                                            alpha: 0.2,
                                          )
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.chat_bubble_outline,
                                    color: isActive
                                        ? EdenMindTheme.primaryColor
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _deleteConversation(conv['id']),
                                ),
                                onTap: () => _loadConversation(conv['id']),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> _deleteConversation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _chatService.deleteConversation(id);
        if (_currentConversationId == id) {
          _startNewChat();
        } else {
          _fetchConversations();
        }
      } catch (e) {
        debugPrint('Error deleting conversation: $e');
      }
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            // Use Builder to get context with Drawer
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(), // Open Drawer
              icon: const Icon(Icons.menu), // Changed to Menu icon
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () =>
                Navigator.pop(context), // Back button moved here or separate?
            // Original design had left back button. I'll put Back on right for now or handle navigation differently.
            // Let's keep a Back button maybe or assume Menu replaces it?
            // Standard pattern: Menu left, Actions right.
            // The user might want to go back to Dashboard. Let's make the right button 'Close' or 'Back'.
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAUjoZSD0Z1JZ3DnYJjDWgcUXZLhXIwDd94lBHx1PYegts1HLu7qllFbo7tYLdaw112irk9etRP26HOJbTEdGxhYNqkjzXVUPd8o2zTaxoTuU7tOpJ_uN5uHHfA73qYZcD5bWLxQAJXQnlsV1Wk9O7Q6XJPgJSPjN851jJ0GNxu6gYT_ORjdMnsB5YMQ2tBMmJEzsOnf8USSIDSHcKan6FlZIg1aesCDaQrO7fLIMjvVrmUXXHR4GEbj_EwOVYrASFQLlS1xe4JoQE',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
              bottomLeft: Radius.circular(8),
            ),
          ),
          child: const Text('Typing...', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildBotMessage(String message, {Duration? delay}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(
            bottom: 16,
          ), // Added margin to align with bubble
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAUjoZSD0Z1JZ3DnYJjDWgcUXZLhXIwDd94lBHx1PYegts1HLu7qllFbo7tYLdaw112irk9etRP26HOJbTEdGxhYNqkjzXVUPd8o2zTaxoTuU7tOpJ_uN5uHHfA73qYZcD5bWLxQAJXQnlsV1Wk9O7Q6XJPgJSPjN851jJ0GNxu6gYT_ORjdMnsB5YMQ2tBMmJEzsOnf8USSIDSHcKan6FlZIg1aesCDaQrO7fLIMjvVrmUXXHR4GEbj_EwOVYrASFQLlS1xe4JoQE',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: MarkdownBody(
              data: message,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 14,
                  color: EdenMindTheme.textColor,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: delay ?? 200.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildUserMessage(String message, {Duration? delay}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
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
    ).animate().fadeIn(duration: delay ?? 200.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice mode toggle row with stop button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _voiceModeEnabled ? Icons.volume_up : Icons.volume_off,
                size: 16,
                color: _voiceModeEnabled ? EdenMindTheme.primaryColor : Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                'Voice Response',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _voiceModeEnabled,
                onChanged: (value) {
                  setState(() => _voiceModeEnabled = value);
                  if (!value) _stopSpeaking();
                },
                activeColor: EdenMindTheme.primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              if (_isSpeaking) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _stopSpeaking,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stop, size: 14, color: Colors.red),
                        SizedBox(width: 4),
                        Text(
                          'Stop',
                          style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Microphone button
              GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isListening
                        ? Colors.red
                        : EdenMindTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: _isListening ? Colors.white : Colors.grey,
                  ),
                ),
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
                          controller: _controller,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? 'Listening...'
                                : 'Type or tap mic...',
                            hintStyle: TextStyle(
                              color: _isListening
                                  ? EdenMindTheme.primaryColor
                                  : Colors.grey[400],
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                          ),
                        ),
                      ),
                      if (_isListening)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      else
                        Icon(Icons.mood, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: EdenMindTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
