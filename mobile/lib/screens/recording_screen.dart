import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../services/speech_metrics_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class RecordingScreen extends StatefulWidget {
  final Map<String, dynamic> question;
  final int questionIndex;
  final int totalQuestions;

  const RecordingScreen({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
  });

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  late SpeechMetricsService _speechMetricsService;
  late AnimationController _pulseController;
  
  bool _isRecording = false;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  int _secondsElapsed = 0;
  Timer? _timer;
  XFile? _recordedVideo;

  @override
  void initState() {
    super.initState();
    _speechMetricsService = SpeechMetricsService();
    _speechMetricsService.init();
    _initCamera();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Prefer front camera
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() => _isCameraReady = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || _isRecording) return;

    try {
      await _cameraController!.startVideoRecording();
      await _speechMetricsService.startListening();
      
      setState(() {
        _isRecording = true;
        _secondsElapsed = 0;
      });
      _pulseController.repeat(reverse: true);

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _secondsElapsed++);
        
        if (_secondsElapsed >= AppConstants.maxRecordingSeconds) {
          _stopRecording();
        }
      });
    } catch (e) {
      debugPrint('Recording error: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_isRecording) return;

    _timer?.cancel();
    _pulseController.stop();
    setState(() => _isProcessing = true);

    try {
      final video = await _cameraController!.stopVideoRecording();
      final metrics = await _speechMetricsService.stopListening();
      
      // Add fake media ref for now
      metrics['mediaRef'] = 'local-video-${DateTime.now().millisecondsSinceEpoch}.mp4';

      if (mounted) {
        // Fix for ProviderNotFoundException: API Service is not provided above this widget globally
        final authService = context.read<AuthService>();
        final apiService = ApiService(authService);
        final questionId = widget.question['id'];
        
        if (questionId == null) {
          throw Exception("Question ID is null. Cannot submit answer.");
        }
        
        await apiService.submitAnswer(questionId, metrics);
      }
      
      setState(() {
        _isRecording = false;
        _isProcessing = false;
        _recordedVideo = video;
      });

      if (mounted) {
        _showRecordingComplete();
      }
    } catch (e) {
      debugPrint('Stop recording error: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isRecording = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading answer: $e'),
            backgroundColor: AppTheme.errorRed,
          )
        );
      }
    }
  }

  void _showRecordingComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppTheme.surfaceDark.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 28),
              SizedBox(width: 10),
              Text('Answer Saved', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          content: Text(
            'Your answer for Question ${widget.questionIndex + 1} has been recorded (${_formatDuration(_secondsElapsed)}) and analyzed successfully.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _recordedVideo = null;
                  _secondsElapsed = 0;
                });
              },
              child: const Text('Re-record', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, _recordedVideo);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview (Full Screen)
          if (_isCameraReady && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppTheme.accentBlue),
              ),
            ),

          // Top Gradient overlay for clear text reading
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Top UI (Back, Timer, Status)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                GestureDetector(
                  onTap: () {
                    if (_isRecording) {
                      _stopRecording();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ),
                
                // Timer
                if (_isRecording || _secondsElapsed > 0)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? AppTheme.errorRed.withValues(alpha: 0.8)
                              : Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            if (_isRecording)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: 500.ms),
                            Text(
                              _formatDuration(_secondsElapsed),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // Question indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Q${widget.questionIndex + 1}/${widget.totalQuestions}',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom UI (Question & Controls)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Question text preview
                      Text(
                        widget.question['text'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 16, 
                          fontWeight: FontWeight.w500,
                          height: 1.5
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Record Button or Loading
                      if (_isProcessing)
                        const Column(
                          children: [
                            SizedBox(
                              height: 64,
                              width: 64,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(AppTheme.accentBlue),
                                strokeWidth: 3,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Analyzing Speech & Uploading...',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            GestureDetector(
                              onTap: _isRecording ? _stopRecording : _startRecording,
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: _isRecording ? 1.0 : 0.8), 
                                        width: 3
                                      ),
                                      boxShadow: _isRecording ? [
                                        BoxShadow(
                                          color: AppTheme.errorRed.withValues(alpha: 0.5 * _pulseController.value),
                                          blurRadius: 20 * _pulseController.value,
                                          spreadRadius: 10 * _pulseController.value,
                                        )
                                      ] : null,
                                    ),
                                    child: Center(
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        width: _isRecording ? 32 : 64,
                                        height: _isRecording ? 32 : 64,
                                        decoration: BoxDecoration(
                                          color: AppTheme.errorRed,
                                          borderRadius: BorderRadius.circular(_isRecording ? 8 : 32),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isRecording ? 'Tap to finish' : 'Tap to start recording',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
