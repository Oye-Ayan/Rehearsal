import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechMetricsService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  
  String _currentTranscript = '';
  
  // Metrics tracking
  DateTime? _recordingStartTime;
  DateTime? _lastWordTime;
  int _pauseCount = 0;
  double _pauseDurationTotal = 0;
  
  final List<String> _fillers = ['um', 'uh', 'like', 'you know', 'so', 'basically'];

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  String get transcript => _currentTranscript;

  Future<void> init() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint('STT Status: $status');
          // We could track pause statuses here, but `speech_to_text` often
          // stops listening automatically on pauses unless configured otherwise.
        },
        onError: (errorNotification) {
          debugPrint('STT Error: $errorNotification');
        },
      );
    } catch (e) {
      debugPrint('Failed to init speech to text: $e');
      _isAvailable = false;
    }
    notifyListeners();
  }

  Future<void> startListening() async {
    if (!_isAvailable) return;
    
    _currentTranscript = '';
    _pauseCount = 0;
    _pauseDurationTotal = 0;
    _recordingStartTime = DateTime.now();
    _lastWordTime = _recordingStartTime;
    _isListening = true;
    notifyListeners();

    await _speech.listen(
      onResult: (result) {
        final now = DateTime.now();
        if (_lastWordTime != null) {
          final gap = now.difference(_lastWordTime!).inMilliseconds / 1000.0;
          if (gap > 1.5) {
            _pauseCount++;
            _pauseDurationTotal += gap;
          }
        }
        _lastWordTime = now;
        _currentTranscript = result.recognizedWords;
        notifyListeners();
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
        pauseFor: const Duration(seconds: 10),
        listenFor: const Duration(minutes: 3),
      ),
    );
  }

  Future<Map<String, dynamic>> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    }
    
    return _computeMetrics();
  }

  Map<String, dynamic> _computeMetrics() {
    final endTime = DateTime.now();
    final totalSeconds = _recordingStartTime != null 
        ? endTime.difference(_recordingStartTime!).inSeconds
        : 1;
        
    final safeSeconds = totalSeconds > 0 ? totalSeconds : 1;
    
    // Words Per Minute
    final words = _currentTranscript.trim().split(RegExp(r'\s+'));
    final wordCount = _currentTranscript.trim().isEmpty ? 0 : words.length;
    final wpm = ((wordCount / safeSeconds) * 60).round();
    
    // Filler Words
    int fillerCount = 0;
    final lowerTranscript = _currentTranscript.toLowerCase();
    for (final filler in _fillers) {
      // Simple string matching. A regex bounded by word boundaries is better.
      final matches = RegExp(r'\b' + filler + r'\b').allMatches(lowerTranscript);
      fillerCount += matches.length;
    }
    
    final fillerRate = (fillerCount / safeSeconds) * 60;
    
    // Speaking Ratio
    final speakingTime = safeSeconds - _pauseDurationTotal;
    final speakingRatio = (speakingTime / safeSeconds).clamp(0.0, 1.0);

    return {
      'transcriptText': _currentTranscript,
      'wpm': wpm,
      'fillerWordCount': fillerCount,
      'fillerWordRate': double.parse(fillerRate.toStringAsFixed(2)),
      'pauseCount': _pauseCount,
      'pauseDurationTotal': double.parse(_pauseDurationTotal.toStringAsFixed(2)),
      'speakingRatio': double.parse(speakingRatio.toStringAsFixed(2)),
    };
  }
}
