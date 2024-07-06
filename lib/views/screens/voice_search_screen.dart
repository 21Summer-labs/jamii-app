import 'package:flutter/material.dart';
import '../widgets/voice_input_widget.dart';
import '../widgets/chat_interface.dart';
import '../actions/voice_search_actions.dart';

class VoiceSearchScreen extends StatefulWidget {
  @override
  _VoiceSearchScreenState createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen> {
  bool isListening = false;
  String transcription = '';
  List<Map<String, dynamic>> chatMessages = [];
  List<Map<String, dynamic>> searchResults = [];

  void updateListeningState(bool listening) {
    setState(() {
      isListening = listening;
    });
  }

  void updateTranscription(String text) {
    setState(() {
      transcription = text;
    });
  }

  void addChatMessage(String message, bool isUser) {
    setState(() {
      chatMessages.add({
        'message': message,
        'isUser': isUser,
      });
    });
  }

  void updateSearchResults(List<Map<String, dynamic>> results) {
    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: isListening
            ? VoiceInputWidget(
                transcription: transcription,
                onTranscriptionUpdate: updateTranscription,
                onListeningStateChange: updateListeningState,
              )
            : ChatInterface(
                chatMessages: chatMessages,
                searchResults: searchResults,
                onVoiceInputStart: () => updateListeningState(true),
                onMessageSend: (message) {
                  addChatMessage(message, true);
                  performSearch(message, updateSearchResults);
                },
                onClearResults: () => updateSearchResults([]),
              ),
      ),
    );
  }
}