import 'package:speech_to_text/speech_to_text.dart' as stt;

Future<void> startListening(
  Function(String) onTranscriptionUpdate,
  Function(bool) onListeningStateChange,
) async {
  final speech = stt.SpeechToText();
  bool available = await speech.initialize();
  if (available) {
    onListeningStateChange(true);
    speech.listen(
      onResult: (result) => onTranscriptionUpdate(result.recognizedWords),
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 5),
      partialResults: true,
      onSoundLevelChange: (level) => print(level),
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }
}

Future<void> performSearch(
  String query,
  Function(List<Map<String, dynamic>>) updateSearchResults,
) async {
  // Simulated search results
  await Future.delayed(Duration(seconds: 1));
  updateSearchResults([
    {
      'name': 'Vibrant Trainer 1',
      'price': 64.50,
      'imageUrl': 'https://example.com/trainer1.jpg',
      'rating': 4.5,
    },
    {
      'name': 'Colorful Sneaker 2',
      'price': 95.95,
      'imageUrl': 'https://example.com/sneaker2.jpg',
      'rating': 4.2,
    },
    // Add more mock results as needed
  ]);
}