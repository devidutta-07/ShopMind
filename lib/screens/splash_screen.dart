import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'main_screen.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _progressPercent = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {
          _progressPercent = (_progressAnimation.value * 100).toInt();
        });
      });

    _animationController.forward();

    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final provider = Provider.of<AppProvider>(context, listen: false);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              provider.userProfile.isLoggedIn
                  ? const MainScreen()
                  : const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Radial Spotlight
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 0.8,
                  colors: [
                    Color(0x0EFFFFFF),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Center Mascot Hero (Scrollable if height constrained)
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Mascot Ring Container
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
                                      color: Colors.white.withAlpha(18),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                // Secondary Inner Ring
                                Container(
                                  width: 176,
                                  height: 176,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withAlpha(30),
                                      width: 1,
                                    ),
                                  ),
                                ),

                                // Mascot Central Badge
                                Container(
                                  width: 144,
                                  height: 144,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF09090B),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(51),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(200),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: ClipOval(
                                    child: SvgPicture.asset(
                                      'assets/logo.svg',
                                      fit: BoxFit.contain,
                                      placeholderBuilder: (context) => Container(
                                        color: Colors.black,
                                        child: const Icon(
                                          Icons.shopping_bag_outlined,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Top Left Checklist Badge
                                Positioned(
                                  top: 24,
                                  left: 24,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF09090B),
                                      border: Border.all(
                                        color: Colors.white.withAlpha(64),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),

                                // Bottom Right Currency Badge
                                Positioned(
                                  bottom: 24,
                                  right: 24,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '₹',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Brand Typography
                          const Text(
                            'ShopMind',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Mindful spending. Effortless lists.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFA1A1AA),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Status Pill
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF09090B),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withAlpha(26),
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
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      '•',
                                      style: TextStyle(
                                        color: Color(0xFF71717A),
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
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer Progress & Security Meta
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // Progress label & percent
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: const [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Syncing your smart budget...',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFFD4D4D8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$_progressPercent%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Linear Progress Track
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: const Color(0xFF18181B),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 3,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Security Badge
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.shield_outlined,
                              size: 13,
                              color: Color(0xFFA1A1AA),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'ENCRYPTED & LOCAL-FIRST  |  SHOPMIND OS v2.4',
                              style: TextStyle(
                                color: Color(0xFF71717A),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
