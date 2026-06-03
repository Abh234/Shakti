import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'emergency_page.dart';

class EmergencyCheckInScreen extends StatefulWidget {
  const EmergencyCheckInScreen({super.key});

  @override
  State<EmergencyCheckInScreen> createState() => _EmergencyCheckInScreenState();
}

class _EmergencyCheckInScreenState extends State<EmergencyCheckInScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final FlutterTts _tts;
  Timer? _timer;
  int _secondsLeft = 8;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _startCheckIn();
  }

  Future<void> _startCheckIn() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.48);
    await _tts.speak(
      'Shakti emergency check. Are you safe? Say cancel or tap safe code if this was accidental.',
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        _activateEmergency();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _activateEmergency() async {
    await _tts.stop();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const EmergencyPage()),
    );
  }

  Future<void> _cancelEmergency() async {
    _timer?.cancel();
    await _tts.stop();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _cancelEmergency,
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ),
              const Spacer(),
              ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1.06).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 154,
                  height: 154,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE11D48),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE11D48).withOpacity(0.42),
                        blurRadius: 44,
                        spreadRadius: 14,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    color: Colors.white,
                    size: 74,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Shakti AI Check-In',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Emergency will activate in $_secondsLeft seconds',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: const Text(
                  '"Are you safe? If this was accidental, tap Safe Code. If not, stay on this screen and I will activate emergency mode."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.45,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cancelEmergency,
                      icon: const Icon(Icons.verified_user_rounded),
                      label: const Text('Safe Code'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF10B981)),
                        minimumSize: const Size.fromHeight(58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _activateEmergency,
                      icon: const Icon(Icons.sos_rounded),
                      label: const Text('Activate Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE11D48),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
