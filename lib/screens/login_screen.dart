import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'customer_map_tab.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- Consistent Color Palette ---
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _primaryTextColor = Color(0xFF0F172A);
  static const Color _secondaryTextColor = Color(0xFF64748B);
  static const Color _gradientStart = Color(0xFF2563EB);
  static const Color _gradientEnd = Color(0xFF10B981);

  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (!context.mounted) return;
      
      if (userCredential != null) {
        // Success
        HapticFeedback.mediumImpact();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CustomerMapTab()),
        );
      } else {
        // Cancelled
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in cancelled.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isLoading = false);
      debugPrint('Google Sign-In Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _buildHeader(screenWidth, screenHeight),
                    SizedBox(height: screenHeight * 0.05),
                    _buildLoginSection(),
                    const Spacer(),
                    _buildFooter(),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Image.asset(
          'assets/logo.png',
          width: screenWidth * 0.35,
          height: screenWidth * 0.35,
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _gradientStart,
              _gradientEnd,
            ],
          ).createShader(bounds),
          child: Text(
            'Shakti',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2.0,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              color: _gradientEnd,
              size: 18,
            ),
            SizedBox(width: 12),
            Text(
              'Your Safety, Our Priority',
              style: TextStyle(
                fontSize: 16,
                color: _secondaryTextColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginSection() {
    return Column(
      children: [
        const SizedBox(height: 32),
        _buildEnhancedGoogleLoginButton(),
        const SizedBox(height: 16),
        _buildDemoLoginButton(),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: const Color(0xFFE2E8F0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Secure & Private',
                style: TextStyle(
                  fontSize: 12,
                  color: _secondaryTextColor.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: const Color(0xFFE2E8F0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTrustIndicator(Icons.security, 'Secure'),
            const SizedBox(width: 16),
            _buildTrustIndicator(Icons.verified, 'Verified'),
            const SizedBox(width: 16),
            _buildTrustIndicator(Icons.shield, 'Protected'),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedGoogleLoginButton() {
    return Container(
      width: double.infinity,
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleGoogleLogin,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4285F4))
                        )
                      : const Text(
                          'G',
                          style: TextStyle(
                            color: Color(0xFF4285F4),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Continue with Google',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _primaryTextColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: _secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoLoginButton() {
    return Container(
      width: double.infinity,
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _gradientStart,
            _gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _gradientStart.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CustomerMapTab()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(
                  Icons.shield_rounded,
                  size: 32,
                  color: Colors.white,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Explore Demo Map',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 13,
              color: _secondaryTextColor,
              height: 1.5,
              letterSpacing: 0.2,
            ),
            children: [
              TextSpan(
                text: 'By continuing, you accept our ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: 'Terms of Service',
                style: TextStyle(
                  color: _gradientEnd,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(
                text: ' and ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: _gradientEnd,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrustIndicator(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: _gradientEnd,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _secondaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showComingSoonSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _gradientStart,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
