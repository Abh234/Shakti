import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'emergency_page.dart';
import 'profile_page.dart';

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
  int _callSeconds = 0;
  String _contactName = 'Mom';
  String _relation = 'Mom';

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _loadContact();
    _startCheckIn();
  }

  Future<void> _loadContact() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('emergency_name')?.trim();
    if (!mounted) return;
    setState(() {
      _relation = prefs.getString('emergency_relation') ?? 'Mom';
      _contactName =
          savedName != null && savedName.isNotEmpty ? savedName : _relation;
    });
  }

  Future<void> _startCheckIn() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.48);
    await _tts.speak(
      'Shakti emergency check. Are you safe? Tap safe code if this was accidental.',
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _callSeconds++);
      if (_secondsLeft <= 1) {
        timer.cancel();
        _activateEmergency();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _callTime {
    final min = (_callSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_callSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _cancelEmergency,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ),
              const SizedBox(height: 12),
              _buildAvatar(),
              const SizedBox(height: 14),
              Text(
                '$_contactName ❤️',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _callTime,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Auto emergency in $_secondsLeft sec',
                style: const TextStyle(
                  color: Color(0xFFE11D48),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              _buildCallGrid(),
              const Spacer(),
              GestureDetector(
                onTap: _cancelEmergency,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3B30).withOpacity(0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.call_end_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'End Call',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.97, end: 1.04).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF10B981)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _contactName.characters.first.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallGrid() {
    final actions = [
      _CallAction(Icons.mic_off_rounded, 'Mute', () {}),
      _CallAction(Icons.volume_up_rounded, 'Speaker', () {}),
      _CallAction(Icons.dialpad_rounded, 'Keypad', () {}),
      _CallAction(Icons.sos_rounded, 'Emergency\nTrigger', _activateEmergency,
          danger: true),
      _CallAction(Icons.note_alt_rounded, 'Notes', () {}),
      _CallAction(Icons.contacts_rounded, 'Contacts', () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
      }),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 22,
        crossAxisSpacing: 20,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: action.onTap,
          child: Column(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: action.danger
                      ? const Color(0xFFFFE4E6)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: action.danger
                        ? const Color(0xFFE11D48)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Icon(
                  action.icon,
                  color: action.danger
                      ? const Color(0xFFE11D48)
                      : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: action.danger
                      ? const Color(0xFFE11D48)
                      : const Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CallAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _CallAction(this.icon, this.label, this.onTap, {this.danger = false});
}
