import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';

class ShaktiPage extends StatelessWidget {
  const ShaktiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map Placeholder with rounded bottom
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Container(
                height: 350,
                color: Colors.blueGrey,
                child: const Center(
                  child: Text(
                    'Map Placeholder',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),

          // Scrollable content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 380),

                  // Emergency Swipe Button (always visible)
                  SwipeButton(
                    thumb: const Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 28,
                    ),
                    activeThumbColor: const Color.fromARGB(255, 29, 11, 11),
                    activeTrackColor: Colors.red.withOpacity(0.8),
                    height: 60,
                    child: const Text(
                      "Slide for Emergency",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onSwipe: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Emergency Activated"),
                          content: const Text(
                              "Your emergency feature has been triggered."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
