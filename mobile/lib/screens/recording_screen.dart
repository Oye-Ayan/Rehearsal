import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../services/speech_metrics_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/tts_service.dart';

class RecordingScreen extends StatefulWidget {
  final Map<String, dynamic> question;
  final int questionIndex;
  final int totalQuestions;
  final bool isAudioOnly;

  const RecordingScreen({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    this.isAudioOnly = false,
  });

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  late SpeechMetricsService _speechMetricsService;
  late AnimationController _pulseController;
  
  late bool _audioOnlyMode;
  bool _isRecording = false;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  int _secondsElapsed = 0;
  Timer? _timer;
  XFile? _recordedVideo;

  @override
  void initState() {
    super.initState();
    _audioOnlyMode = widget.isAudioOnly;
    _speechMetricsService = SpeechMetricsService();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _initPermissionsAndMedia();
  }

  Future<void> _initPermissionsAndMedia() async {
    if (_audioOnlyMode) {
      final micStatus = await Permission.microphone.request();
      if (micStatus.isGranted) {
        await _speechMetricsService.init();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required for audio recording.')),
          );
          Navigator.pop(context);
        }
      }
    } else {
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      if (statuses[Permission.microphone]!.isGranted) {
        await _speechMetricsService.init();
        if (statuses[Permission.camera]!.isGranted) {
          await _initCamera();
        } else {
          // Fallback to audio only if camera permission denied
          setState(() => _audioOnlyMode = true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required to record your answer.')),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _audioOnlyMode = true);
        return;
      }

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
      if (mounted) {
        setState(() => _audioOnlyMode = true);
      }
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;

    try {
      await TTSService().stop();
      if (!_audioOnlyMode && _cameraController != null && _isCameraReady) {
        await _cameraController!.startVideoRecording();
      }
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
    if (!_isRecording) return;

    _timer?.cancel();
    _pulseController.stop();
    setState(() => _isProcessing = true);

    try {
      if (!_audioOnlyMode && _cameraController != null && _cameraController!.value.isRecordingVideo) {
        _recordedVideo = await _cameraController!.stopVideoRecording();
      }

      final metrics = await _speechMetricsService.stopListening();
      metrics['mediaRef'] = _recordedVideo != null 
          ? 'local-video-${DateTime.now().millisecondsSinceEpoch}.mp4'
          : 'local-audio-${DateTime.now().millisecondsSinceEpoch}.m4a';

      if (mounted) {
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
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AlertDialog(
          backgroundColor: AppTheme.surfaceDark.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Answer Saved',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Text(
            'Your answer for Question ${widget.questionIndex + 1} (${_audioOnlyMode ? 'Audio' : 'Video'}, ${_formatDuration(_secondsElapsed)}) has been recorded and analyzed.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), height: 1.5, fontSize: 14),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          // Background: Camera Preview or Liquid Glass Audio Wave
          if (!_audioOnlyMode && _isCameraReady && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            _buildLiquidGlassAudioBackground(),

          // Overlay Header & Controls
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        ),
                        onPressed: () {
                          if (_isRecording) {
                            _stopRecording();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const Spacer(),
                      
                      // Audio / Video Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _isRecording ? null : () => setState(() => _audioOnlyMode = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _audioOnlyMode ? AppTheme.accentBlue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.mic_rounded, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('Audio', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _isRecording ? null : () async {
                                if (_cameraController == null) {
                                  await _initCamera();
                                } else {
                                  setState(() => _audioOnlyMode = false);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !_audioOnlyMode ? AppTheme.accentBlue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.videocam_rounded, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('Video', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Timer Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isRecording ? AppTheme.errorRed : Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            if (_isRecording) ...[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              _formatDuration(_secondsElapsed),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Question Box (Liquid Glass Overlay)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppTheme.glassCard(
                    isDark: true,
                    blur: 20,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentBlue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'Q${widget.questionIndex + 1} of ${widget.totalQuestions}',
                                style: const TextStyle(color: AppTheme.accentBlue, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.question['text'] ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Record / Stop Control
                Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: AppTheme.accentBlue)
                      : GestureDetector(
                          onTap: _isRecording ? _stopRecording : _startRecording,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 1.0, end: 1.1).animate(_pulseController),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isRecording ? AppTheme.errorRed : AppTheme.accentBlue,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isRecording ? AppTheme.errorRed : AppTheme.accentBlue).withValues(alpha: 0.4),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidGlassAudioBackground() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: const Color(0xFF09090B),
          ),
        ),
        Center(
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final val = _isRecording ? _pulseController.value : 0.0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 260 + (val * 40),
                    height: 260 + (val * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentBlue.withValues(alpha: 0.08 + (val * 0.1)),
                    ),
                  ),
                  Container(
                    width: 180 + (val * 20),
                    height: 180 + (val * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentIndigo.withValues(alpha: 0.15 + (val * 0.1)),
                    ),
                  ),
                  AppTheme.glassCard(
                    isDark: true,
                    blur: 24,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isRecording ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
                          color: AppTheme.accentBlue,
                          size: 56,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isRecording ? 'Listening & Analyzing...' : 'Ready for Audio Answer',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
