import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'pages/home_page.dart';
import 'pages/chatbot_page.dart';
import 'pages/shakti_page.dart';
import 'pages/emergency_page.dart';
import 'pages/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _pageIndex = 2; // Set initial index to 2 for "Shakti"

  // --- Consistent Dark Theme Color ---
  static const Color _navBarColor = Color(0xFF100C14);

  // Pages for each navigation item
  final List<Widget> _pages = [
    const HomePage(),
    const ChatbotPage(),
    const ShaktiPage(),
    const EmergencyPage(),
    const ProfilePage(),
  ];

  // A list of the icons to be used
  final List<IconData> _icons = [
    Icons.home_filled,
    Icons.chat_bubble_outline_rounded,
    Icons.shield_rounded,
    Icons.warning_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(255, 0, 0, 0),
            ],
          ),
        ),
        child: _pages[_pageIndex],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _pageIndex,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.transparent,
        color: _navBarColor,
        items: [
          for (int i = 0; i < _icons.length; i++)
            CurvedNavigationBarItem(
              child: _pageIndex == i
                  ? Transform.translate(
                      offset: const Offset(0, 10),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 36, 24, 31),
                              Color.fromARGB(255, 102, 88, 105)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(_icons[i], color: Colors.white, size: 30),
                      ),
                    )
                  : Icon(_icons[i], color: Colors.white),
              label: ['Home', 'Chat', 'Shakti', 'Emergency', 'Profile'][i],
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
