import 'package:flutter/material.dart';

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool _answered = false;
  String _caller = 'Mom';

  final List<String> _callers = const [
    'Mom',
    'Brother',
    'Best Friend',
    'Police Helpline',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('Fake Call'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _answered ? _buildActiveCall() : _buildIncomingCall(),
        ),
      ),
    );
  }

  Widget _buildIncomingCall() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_pin_rounded, color: Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _caller,
                    isExpanded: true,
                    items: _callers
                        .map(
                          (name) => DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _caller = value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        CircleAvatar(
          radius: 58,
          backgroundColor: const Color(0xFFEFF6FF),
          child: Text(
            _caller.characters.first,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _caller,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Incoming call',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _callButton(
              Icons.call_end_rounded,
              const Color(0xFFE11D48),
              () => Navigator.pop(context),
            ),
            _callButton(
              Icons.call_rounded,
              const Color(0xFF10B981),
              () => setState(() => _answered = true),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActiveCall() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(Icons.graphic_eq_rounded, color: Color(0xFF10B981), size: 72),
        const SizedBox(height: 18),
        Text(
          'On call with $_caller',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '“Yes, I am almost there. Stay on the line with me.”',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.call_end_rounded),
          label: const Text('End Fake Call'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _callButton(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 8,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 74,
          height: 74,
          child: Icon(icon, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}
