import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'models/community_models.dart'; // Replace import of community_page.dart with models

class SAChatPage extends StatefulWidget {
  final SATeamMember teamMember;

  const SAChatPage({super.key, required this.teamMember});

  @override
  State<SAChatPage> createState() => _SAChatPageState();
}

class _SAChatPageState extends State<SAChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Add initial greeting message from the team member
    Future.delayed(const Duration(milliseconds: 500), () {
      _addMessage(
        sender: widget.teamMember.name,
        text: widget.teamMember.presetMessages[0],
        isUser: false,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage({required String sender, required String text, required bool isUser}) {
    setState(() {
      _messages.add(ChatMessage(
        sender: sender,
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });
    
    // Scroll to the bottom after adding a message
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmitted(String text) {
    _messageController.clear();
    
    if (text.trim().isEmpty) return;
    
    // Add user message
    _addMessage(
      sender: 'You',
      text: text,
      isUser: true,
    );
    
    // Simulate team member response after a delay
    Future.delayed(const Duration(seconds: 1), () {
      final response = _getResponse();
      _addMessage(
        sender: widget.teamMember.name,
        text: response,
        isUser: false,
      );
    });
  }

  String _getResponse() {
    // Randomly select from preset messages (skipping the first which is used as greeting)
    final preset = widget.teamMember.presetMessages;
    if (preset.length > 1) {
      return preset[1 + (_messages.length % (preset.length - 1))];
    } else {
      return "I'm here to listen and support you.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.teamMember.bookColor,
              child: Text(
                widget.teamMember.name[0],
                style: const TextStyle(color: AppColors.white), // Use theme color
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.teamMember.name,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  widget.teamMember.specialty,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.primary, // Use theme color
        foregroundColor: AppColors.white, // Use theme color
      ),
      body: Column(
        children: [
          // Team member info card
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withOpacity(0.1), // Use theme color with opacity
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book icon - made even smaller
                Container(
                  height: 50, // Reduced from 60 to 50
                  width: 25, // Reduced from 30 to 25
                  decoration: BoxDecoration(
                    color: widget.teamMember.bookColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: const EdgeInsets.only(right: 16),
                ),
                // Bio text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.teamMember.bio,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is a supportive conversation. All chats are confidential.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Your conversation will appear here...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessage(message);
                    },
                  ),
          ),
          
          // Message input
          Container(
            decoration: const BoxDecoration(
              color: AppColors.white, // Use theme color
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackOpacity20, // Use theme color with opacity
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    Get.snackbar(
                      'Feature Notice',
                      'File attachments are not available in this version.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: AppColors.primary, // Use theme color
                  onPressed: () => _handleSubmitted(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: widget.teamMember.bookColor,
              radius: 16,
              child: Text(
                message.sender[0],
                style: const TextStyle(fontSize: 12, color: AppColors.white), // Use theme color
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.primary // Use theme color
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String sender;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
