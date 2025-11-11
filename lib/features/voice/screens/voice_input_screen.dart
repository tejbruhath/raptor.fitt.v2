import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/theme/app_colors.dart';

class VoiceInputScreen extends StatefulWidget {
  final String mode; // 'workout' or 'nutrition'

  const VoiceInputScreen({
    super.key,
    required this.mode,
  });

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
              _confidence = result.confidence;
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Voice Input',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Voice visualization
            AvatarGlow(
              animate: _isListening,
              glowColor: AppColors.primary,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              child: GestureDetector(
                onTap: _listen,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening ? AppColors.primary : AppColors.surface,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    size: 50,
                    color: _isListening ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ).animate().scale(duration: 400.ms),
            
            const SizedBox(height: 32),
            
            // Instruction text
            Text(
              _isListening ? 'Listening...' : 'Tap to speak',
              style: TextStyle(
                fontSize: 18,
                color: _isListening ? AppColors.primary : AppColors.textSecondary,
                fontWeight: _isListening ? FontWeight.w600 : FontWeight.w400,
              ),
            ).animate().fadeIn(),
            
            const Spacer(),
            
            // Transcribed text
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(minHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.translate_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Transcription',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_confidence > 0) ...[
                        const Spacer(),
                        Text(
                          '${(_confidence * 100).toInt()}% confidence',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _text.isEmpty ? 'Your speech will appear here...' : _text,
                    style: TextStyle(
                      fontSize: 16,
                      color: _text.isEmpty 
                          ? AppColors.textSecondary 
                          : AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            // Action buttons
            if (_text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _text = '';
                            _confidence = 0;
                          });
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, _text);
                        },
                        child: const Text('Use Text'),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
