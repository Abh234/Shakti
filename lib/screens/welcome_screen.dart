import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  AnimationController? _fadeController;
  AnimationController? _slideController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  // --- Color Palette ---
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _primaryTextColor = Color(0xFF0F172A);
  static const Color _secondaryTextColor = Color(0xFF64748B);
  static const Color _gradientStart = Color(0xFF2563EB);
  static const Color _gradientEnd = Color(0xFF10B981);

  final List<Map<String, String>> slideContent = [
    {
      'image': 'assets/voiceAsistant.png',
      'title': 'AI Voice Shield',
      'subtitle': 'Real-time threat detection in any conversation.'
    },
    {
      'image': 'assets/sosimagewomen.png',
      'title': 'Secret SOS Command',
      'subtitle': 'Activate help discreetly with a hidden word.'
    },
    {
      'image': 'assets/legal.png',
      'title': 'Your Legal AI',
      'subtitle': 'Instant legal advice and emotional support, 24/7.'
    },
    {
      'image': 'assets/blackmail.png',
      'title': 'Anti-Blackmail Guard',
      'subtitle':
          'Detects and secures evidence from online threats and helps file complaints.'
    },
    {
      'image': 'assets/safelocation.png',
      'title': 'Safe Zone Mapping',
      'subtitle': 'Avoid high-crime areas with intelligent alerts.'
    },
    {
      'image': 'assets/health.png',
      'title': 'Smart Health Alerts',
      'subtitle': 'Automatic accident detection and medical assistance.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    try {
      _fadeController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );

      _slideController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _fadeController!,
        curve: Curves.easeInOut,
      ));

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController!,
        curve: Curves.easeOutCubic,
      ));

      _fadeController!.forward();
      _slideController!.forward();
    } catch (e) {
      // Handle any animation errors gracefully
    }
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _slideController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fadeController != null && !_fadeController!.isAnimating) {
      _fadeController!.forward();
    }
    if (_slideController != null && !_slideController!.isAnimating) {
      _slideController!.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    _buildHeader(),
                    _buildCarouselSection(screenHeight),
                    _buildCompactWelcomeSection(),
                    _buildBottomSection(),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Shakti',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: _primaryTextColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'AI-Powered Personal Safety',
              style: TextStyle(
                fontSize: 16,
                color: _secondaryTextColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselSection(double screenHeight) {
    return SlideTransition(
      position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
      child: Container(
        height: screenHeight * 0.38,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: FlutterCarousel(
                items: slideContent.map((content) {
                  return _buildCarouselItem(content);
                }).toList(),
                options: FlutterCarouselOptions(
                  height: double.infinity,
                  viewportFraction: 0.85,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                  autoPlayCurve: Curves.easeInOutCubic,
                  showIndicator: false,
                  onPageChanged: (index, reason) {
                    if (mounted) {
                      setState(() {
                        _currentIndex = index;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCarouselIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    try {
      if (imagePath.startsWith('assets/')) {
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      } else {
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[800],
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_gradientStart),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: child,
            );
          },
        );
      }
    } catch (e) {
      return Container(
        color: Colors.grey[800],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }

  Widget _buildCarouselItem(Map<String, String> content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(content['image']!),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content['subtitle']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: slideContent.asMap().entries.map((entry) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentIndex == entry.key ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentIndex == entry.key
                ? _gradientStart
                : const Color(0xFFCBD5E1),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactWelcomeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_gradientStart, _gradientEnd],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your AI Safety Guardian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Safe route, SOS, evidence mode, and voice control',
                  style: TextStyle(
                    fontSize: 13,
                    color: _secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _gradientEnd.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: _gradientStart,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  '50K+',
                  style: TextStyle(
                    fontSize: 12,
                    color: _gradientStart,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_gradientStart, _gradientEnd],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _gradientStart.withOpacity(0.24),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _navigateToLogin(),
                borderRadius: BorderRadius.circular(16),
                child: const Center(
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}
