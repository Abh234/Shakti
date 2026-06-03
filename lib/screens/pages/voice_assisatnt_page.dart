import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const Color _voiceBackground = Color(0xFF000000);
const Color _voiceSurface = Color(0xFF111111);
const Color _voiceElevated = Color(0xFF1A1A1A);
const Color _voiceBorder = Color(0xFF2A2A2A);
const Color _voicePrimaryText = Colors.white;
const Color _voiceSecondaryText = Color(0xFFBDBDBD);
const Color _voiceAccent = Color(0xFFFF69B4);
const Color _voiceAccentDeep = Color(0xFF8B5CF6);

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  _AIAssistantScreenState createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  bool _isResponding = false;
  bool _isProcessing = false;
  bool _isOnHold = false;

  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _breathingController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _breathingAnimation;

  final String _serverUrl =
      'https://samay-verse-womensafety-backend-chatbot.hf.space/chat';

  List<String> _sentencesToSpeak = [];
  int _currentSentenceIndex = 0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    _initAnimations();
    _initTts();

    // Auto-start listening on app launch
    Future.delayed(const Duration(milliseconds: 500), () {
      _startListening();
    });
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _breathingAnimation = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  void _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() {
      setState(() => _isResponding = true);
    });

    _tts.setCompletionHandler(() {
      _currentSentenceIndex++;
      if (_currentSentenceIndex < _sentencesToSpeak.length) {
        _speakResponse();
      } else {
        setState(() {
          _isResponding = false;
        });
        _sentencesToSpeak = [];
        _currentSentenceIndex = 0;
        if (!_isOnHold) {
          _startListening();
        }
      }
    });

    _tts.setErrorHandler((msg) {
      setState(() {
        _isResponding = false;
      });
      if (!_isOnHold) {
        _startListening();
      }
    });
  }

  void _startListening() async {
    if (!_isListening && !_isProcessing && !_isOnHold) {
      bool available = await _speech.initialize(
        onError: (error) {
          setState(() {
            _isListening = false;
          });
          _tts.speak('Speech recognition error. Please try again.');
          Future.delayed(const Duration(seconds: 2), () {
            if (!_isOnHold) {
              _startListening();
            }
          });
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
        });

        _speech.listen(
          onResult: (result) {
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              _processVoiceCommand(result.recognizedWords);
              _stopListening();
            }
          },
          partialResults: true,
          localeId: 'en_US',
          cancelOnError: false,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        );
      } else {
        _tts.speak('Unable to start voice recognition');
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _processVoiceCommand(String command) async {
    if (command.trim().isEmpty) {
      if (!_isOnHold) {
        _startListening();
      }
      return;
    }

    setState(() {
      _isProcessing = true;
      _isListening = false;
    });

    try {
      final response = await http
          .post(
            Uri.parse(_serverUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': command}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        final reply = data['reply'] ??
            'I apologize, but I couldn\'t process that request.';

        _sentencesToSpeak = _splitIntoSentences(reply);
        _currentSentenceIndex = 0;

        setState(() {
          _isProcessing = false;
        });

        _speakResponse();
      } else {
        _tts.speak(
            'I\'m experiencing technical difficulties. Please try again.');
        setState(() {
          _isProcessing = false;
        });
        if (!_isOnHold) {
          _startListening();
        }
      }
    } catch (e) {
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage =
            'Connection timeout. Please check your internet and try again.';
      } else {
        errorMessage =
            'I\'m having trouble connecting. Please try again later.';
      }

      _tts.speak(errorMessage);
      setState(() {
        _isProcessing = false;
      });
      if (!_isOnHold) {
        _startListening();
      }
    }
  }

  Future<void> _speakResponse() async {
    if (_currentSentenceIndex < _sentencesToSpeak.length) {
      final sentence = _sentencesToSpeak[_currentSentenceIndex].trim();
      if (sentence.isNotEmpty) {
        await _tts.speak(sentence);
      } else {
        _currentSentenceIndex++;
        _speakResponse();
      }
    }
  }

  List<String> _splitIntoSentences(String text) {
    return text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  void _holdAssistant() {
    setState(() {
      _isOnHold = !_isOnHold;
      if (_isOnHold) {
        _stopListening();
        _tts.stop();
      } else {
        _startListening();
      }
    });
  }

  void _stopAssistant() {
    _stopListening();
    _tts.stop();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _pulseController.dispose();
    _rotationController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    if (_isListening) {
      return _voiceAccent.withOpacity(0.8);
    } else if (_isProcessing || _isResponding) {
      return _voiceAccentDeep.withOpacity(0.8);
    } else if (_isOnHold) {
      return Colors.grey.withOpacity(0.8);
    } else {
      return _voiceAccent.withOpacity(0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _voiceBackground,
      body: Stack(
        children: [
          // Top bar
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _voiceSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _voiceBorder),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: _voicePrimaryText,
                      size: 20,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getStatusColor().withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isOnHold ? 'On Hold' : 'Live',
                          style: const TextStyle(
                            color: _voicePrimaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _voiceSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _voiceBorder),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: _voiceSecondaryText,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          // Main animation area
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _pulseController,
                _rotationController,
                _breathingController,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening
                      ? _pulseAnimation.value
                      : _isProcessing || _isResponding
                          ? _breathingAnimation.value
                          : 1.0,
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: GeminiStylePainter(
                      animationValue: _rotationController.value,
                      pulseValue: _pulseAnimation.value,
                      isListening: _isListening,
                      isResponding: _isResponding,
                      isProcessing: _isProcessing,
                      isOnHold: _isOnHold,
                    ),
                  ),
                );
              },
            ),
          ),
          // Status text
          if (_isOnHold)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 200),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _voiceSurface,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: _voiceBorder),
                    ),
                    child: const Text(
                      'Assistant is on hold',
                      style: TextStyle(
                        color: _voicePrimaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'To continue your chat, tap on the Live button',
                    style: TextStyle(
                      color: _voiceSecondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          // Bottom buttons
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomButton(
                  icon: Icons.videocam_outlined,
                  isActive: false,
                  onTap: () {},
                ),
                _buildBottomButton(
                  icon: Icons.screen_share_outlined,
                  isActive: false,
                  onTap: () {},
                ),
                _buildMainButton(),
                _buildBottomButton(
                  icon: Icons.close,
                  isActive: false,
                  isDestructive: true,
                  onTap: _stopAssistant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive
              ? _voiceAccentDeep.withOpacity(0.18)
              : _voiceSurface,
          shape: BoxShape.circle,
          border: Border.all(color: _voiceBorder),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isDestructive ? Colors.redAccent : _voicePrimaryText,
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    return GestureDetector(
      onTap: _holdAssistant, // This will now toggle the hold function
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 75,
            width: 75,
            decoration: BoxDecoration(
              color:
                  _isOnHold ? _voiceElevated : _voiceAccent.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
          ),
          CircleAvatar(
            backgroundColor: _isOnHold ? _voiceElevated : _voiceAccent,
            radius: 30,
            child: Icon(
              _isOnHold ? Icons.pause : Icons.mic_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class GeminiStylePainter extends CustomPainter {
  final double animationValue;
  final double pulseValue;
  final bool isListening;
  final bool isResponding;
  final bool isProcessing;
  final bool isOnHold;

  GeminiStylePainter({
    required this.animationValue,
    required this.pulseValue,
    required this.isListening,
    required this.isResponding,
    required this.isProcessing,
    required this.isOnHold,
  });

  Color _getMainColor() {
    if (isOnHold) {
      return Colors.grey.withOpacity(0.6);
    } else if (isListening) {
      return _voiceAccent.withOpacity(0.75);
    } else if (isProcessing || isResponding) {
      return _voiceAccentDeep.withOpacity(0.75);
    }
    return _voiceAccent.withOpacity(0.75);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final micRadius = size.width * 0.4;

    if (isOnHold) {
      final holdPaint = Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, micRadius * 1.5, holdPaint);
    } else if (isListening) {
      for (int i = 0; i < 3; i++) {
        final ringRadius =
            micRadius * (1.1 + (i * 0.2)) * (0.8 + 0.2 * pulseValue);
        final ringPaint = Paint()
          ..color = _voiceAccent.withOpacity(0.3 - i * 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(center, ringRadius, ringPaint);
      }
    } else if (isProcessing || isResponding) {
      final ringCount = 10;
      for (int i = 0; i < ringCount; i++) {
        final angle = (animationValue * 2 * math.pi) + (i * 2 * math.pi / 2);
        final ringRadius = micRadius * (1.1 + (math.sin(angle) * 0.05));
        final ringPaint = Paint()
          ..color = _getMainColor().withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(center, ringRadius, ringPaint);
      }
    }

    // Central microphone icon area
    final centralPaint = Paint()
      ..color = _getMainColor()
      ..style = PaintingStyle.fill;

    final centralRadius = micRadius * 0.4;
    canvas.drawCircle(center, centralRadius, centralPaint);

    // Dots animation for processing/responding
    if (isProcessing || isResponding) {
      _drawActivityDots(canvas, center, centralRadius);
    }
  }

  void _drawActivityDots(Canvas canvas, Offset center, double radius) {
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final angle = (animationValue * 2 * math.pi) + (i * 2 * math.pi / 3);
      final dotRadius = radius * 0.7;
      final dotSize = 4 + (math.sin(animationValue * 4 * math.pi + i) * 2);

      final dotOffset = Offset(
        center.dx + math.cos(angle) * dotRadius * 0.5,
        center.dy + math.sin(angle) * dotRadius * 0.5,
      );

      canvas.drawCircle(dotOffset, dotSize / 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
