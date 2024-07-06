import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VoiceInputWidget extends StatelessWidget {
  final String transcription;
  final Function(String) onTranscriptionUpdate;
  final Function(bool) onListeningStateChange;

  VoiceInputWidget({
    required this.transcription,
    required this.onTranscriptionUpdate,
    required this.onListeningStateChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          transcription,
          style: TextStyle(color: Colors.white, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        SvgPicture.asset(
          'assets/voice_waves.svg',
          width: 200,
          height: 100,
        ),
        SizedBox(height: 20),
        Text(
          'Listening...',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () => onListeningStateChange(false),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mic, size: 40),
          ),
        ),
      ],
    );
  }
}