// lib/presentation/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // للتأكد من أن الشاشة بالوضع العمودي
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // إعداد متحكم الحركة
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    _checkFirstLaunch();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstLaunch() async {
    // نتأكد من انتهاء الرسوم المتحركة قبل الانتقال
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // تهيئة UserProvider أولاً
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.initialized) {
      await userProvider.initialize();
    }

    // انتظار قليلاً للتأكد من اكتمال التهيئة
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool(AppConstants.firstLaunchKey) ?? true;

    if (isFirstLaunch) {
      await prefs.setBool(AppConstants.firstLaunchKey, false);
      context.go('/onboarding');
    } else {
      // التحقق من حالة تسجيل الدخول بعد التهيئة
      final isLoggedIn = userProvider.isLoggedIn;
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (isLoggedIn && rememberMe) {
        // إذا كان المستخدم مسجل دخول و "تذكرني" مفعل، انتقل للصفحة الرئيسية
        print(
          '✅ SplashScreen: المستخدم مسجل دخول مع "تذكرني" - الانتقال للصفحة الرئيسية',
        );
        context.go('/');
      } else {
        // إذا لم يكن "تذكرني" مفعل أو المستخدم غير مسجل دخول، انتقل لصفحة تسجيل الدخول
        print(
          '⚠️ SplashScreen: المستخدم غير مسجل دخول أو "تذكرني" غير مفعل - الانتقال لصفحة تسجيل الدخول',
        );
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // احصل على حجم الشاشة للتكيف مع جميع الأجهزة
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.primary.withOpacity(0.6),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: screenSize.width * 0.4,
                        height: screenSize.width * 0.4,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // App Name
                      Text(
                        'Velora',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.1,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Slogan
                      Text(
                        'استكشف فلسطين',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: screenSize.width * 0.05,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: screenSize.height * 0.1),

                      // Loading Indicator
                      SizedBox(
                        width: screenSize.width * 0.2,
                        height: screenSize.width * 0.2,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
