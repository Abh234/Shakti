import 'dart:async';

import 'package:flutter/material.dart';

class EvidenceModeScreen extends StatefulWidget {
  const EvidenceModeScreen({super.key});

  @override
  State<EvidenceModeScreen> createState() => _EvidenceModeScreenState();
}

class _EvidenceModeScreenState extends State<EvidenceModeScreen> {
  late final Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _time {
    final min = (_seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('AI Evidence Mode'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCameraMock(),
              const SizedBox(height: 18),
              _buildAnalysisCard(),
              const SizedBox(height: 18),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraMock() {
    return AspectRatio(
      aspectRatio: 9 / 14,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.videocam_rounded,
                color: Colors.white24,
                size: 92,
              ),
            ),
            Positioned(
              top: 18,
              left: 18,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'REC $_time',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Text(
                'Camera preview placeholder. Add real camera package after UI demo is locked.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    final items = [
      ('Person detected', 'Active', Icons.person_search_rounded),
      ('Crowd density', 'Low', Icons.groups_rounded),
      ('Risk score', '87%', Icons.warning_amber_rounded),
      ('Evidence backup', 'Ready', Icons.cloud_done_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Monitoring',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFEFF6FF),
                child: Icon(item.$3, color: const Color(0xFF2563EB)),
              ),
              title: Text(
                item.$1,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              trailing: Text(
                item.$2,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text('Secure Evidence'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.stop_circle_rounded),
            label: const Text('Stop'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE11D48),
              side: const BorderSide(color: Color(0xFFFDA4AF)),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
