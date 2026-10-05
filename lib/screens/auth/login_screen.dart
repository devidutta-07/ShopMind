import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final UserProfile? profile = await _authService.signInWithGoogle();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (profile != null) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.updateUserProfile(profile);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in failed or cancelled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Top Ambient Glow Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.8),
                  radius: 0.8,
                  colors: [
                    Color(0x1F27272A),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Concentric Emblem with Mascot
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer Ring
                              Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF27272A),
                                    width: 1,
                                  ),
                                ),
                              ),
                              // Middle Ring
                              Container(
                                width: 190,
                                height: 190,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF27272A).withAlpha(180),
                                    width: 1,
                                  ),
                                ),
                              ),
                              // Inner Precision Accent Ring
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF3F3F46).withAlpha(150),
                                    width: 1,
                                  ),
                                ),
                              ),

                              // Central Mascot Container
                              Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                  border: Border.all(
                                    color: const Color(0xFF27272A),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withAlpha(20),
                                      blurRadius: 30,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: ClipOval(
                                  child: SvgPicture.asset(
                                    'assets/logo.svg',
                                    fit: BoxFit.contain,
                                    placeholderBuilder: (context) => const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  ),
                                ),
                              ),

                              // Top Left Verification Badge
                              Positioned(
                                top: 20,
                                left: 20,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                    border: Border.all(
                                      color: Colors.white.withAlpha(230),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(150),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),

                              // Bottom Right Currency Token Badge
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                    border: Border.all(
                                      color: Colors.white.withAlpha(230),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(150),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '₹',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title & Subtitle
                        const Text(
                          'ShopMind',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Plan Your Spending',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFA1A1AA),
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.3,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Feature Pill Badge
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0A),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF27272A),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Smart Budget Engine',
                                  style: TextStyle(
                                    color: Color(0xFFA1A1AA),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    '•',
                                    style: TextStyle(
                                      color: Color(0xFF52525B),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Offline Ready',
                                  style: TextStyle(
                                    color: Color(0xFFA1A1AA),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Google Sign-In Button
                        _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _handleGoogleSignIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 4,
                                    shadowColor: Colors.white.withAlpha(20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Google 'G' Mark
                                      SvgPicture.string(
                                        '''<svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                          <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#000000"/>
                                          <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#000000"/>
                                          <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z" fill="#000000"/>
                                          <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z" fill="#000000"/>
                                        </svg>''',
                                        width: 20,
                                        height: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF18181B),
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                        const SizedBox(height: 24),

                        // Footer Terms Notice
                        const Text(
                          'By continuing, you agree to our Terms & Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF71717A),
                            height: 1.4,
                          ),
                        ),
                      ],
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
}
