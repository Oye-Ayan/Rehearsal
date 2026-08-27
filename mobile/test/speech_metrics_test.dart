import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mock Speech Metrics Calculation', () {
    // A simplified test mirroring the internal logic of SpeechMetricsService
    // to verify math without needing to mock the platform STT channel.
    
    const transcript = "um I think like the answer is basically you know correct";
    const totalSeconds = 10;
    
    final words = transcript.trim().split(RegExp(r'\s+'));
    final wordCount = transcript.trim().isEmpty ? 0 : words.length;
    final wpm = ((wordCount / totalSeconds) * 60).round();
    
    // Fillers logic
    final fillers = ['um', 'uh', 'like', 'you know', 'so', 'basically'];
    int fillerCount = 0;
    final lowerTranscript = transcript.toLowerCase();
    
    for (final filler in fillers) {
      final matches = RegExp(r'\b' + filler + r'\b').allMatches(lowerTranscript);
      fillerCount += matches.length;
    }
    
    final fillerRate = (fillerCount / totalSeconds) * 60;

    expect(wordCount, 11);
    expect(wpm, 66); 
    expect(fillerCount, 4); // 'um', 'like', 'basically', 'you know'
    expect(fillerRate, 24.0);
  });
}
