import 'package:flutter/material.dart';
import 'search_result_card.dart';

class ChatInterface extends StatelessWidget {
  final List<Map<String, dynamic>> chatMessages;
  final List<Map<String, dynamic>> searchResults;
  final VoidCallback onVoiceInputStart;
  final Function(String) onMessageSend;
  final VoidCallback onClearResults;

  ChatInterface({
    required this.chatMessages,
    required this.searchResults,
    required this.onVoiceInputStart,
    required this.onMessageSend,
    required this.onClearResults,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: chatMessages.length,
            itemBuilder: (context, index) {
              final message = chatMessages[index];
              return ChatBubble(
                message: message['message'],
                isUser: message['isUser'],
              );
            },
          ),
        ),
        if (searchResults.isNotEmpty)
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return SearchResultCard(product: searchResults[index]);
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    fillColor: Colors.grey[800],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onSubmitted: onMessageSend,
                ),
              ),
              IconButton(
                icon: Icon(Icons.mic, color: Colors.yellow),
                onPressed: onVoiceInputStart,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Were the results accurate?', style: TextStyle(color: Colors.grey)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up, color: Colors.yellow),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_down, color: Colors.yellow),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  ChatBubble({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.yellow : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(color: isUser ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}