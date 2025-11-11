// lib/presentation/screens/auth/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  int _currentPage = 0;
  final int _numPages = 3;
  bool _isLastPage = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'استكشف فلسطين',
      'titleEn': 'Explore Palestine',
      'description':
          'اكتشف أجمل المسارات والمناطق السياحية في فلسطين، بطريقة سهلة ومبسطة.',
      'descriptionEn':
          'Discover the most beautiful routes and tourist areas in Palestine, in an easy and simple way.',
      'color': AppColors.primary,
      'gradientColors': [
        AppColors.primary,
        AppColors.primary.withOpacity(0.7),
        AppColors.secondary.withOpacity(0.5),
      ],
      'icon': PhosphorIcons.compass,
      'bgIcon': PhosphorIcons.map_pin,
      'highlights': ['خرائط تفاعلية', 'وجهات مختارة بعناية', 'قصص محلية ملهمة'],
    },
    {
      'title': 'تنوع المسارات',
      'titleEn': 'Diverse Paths',
      'description':
          'مجموعة متنوعة من المسارات المناسبة لجميع المستويات والاهتمامات، من المشي البسيط إلى التسلق الصعب.',
      'descriptionEn':
          'A variety of paths suitable for all levels and interests, from simple walking to difficult climbing.',
      'color': AppColors.secondary,
      'gradientColors': [
        AppColors.secondary,
        AppColors.secondary.withOpacity(0.7),
        AppColors.tertiary.withOpacity(0.5),
      ],
      'icon': PhosphorIcons.mountains,
      'bgIcon': PhosphorIcons.tree,
      'highlights': ['مسارات جبلية', 'أنشطة عائلية', 'مخيمات ومبيت'],
    },
    {
      'title': 'خطط رحلتك',
      'titleEn': 'Plan Your Trip',
      'description':
          'احفظ المسارات المفضلة لديك، واطلع على تفاصيل الطرق والإحداثيات، وشارك تجاربك مع الآخرين.',
      'descriptionEn':
          'Save your favorite routes, view path details and coordinates, and share your experiences with others.',
      'color': AppColors.tertiary,
      'gradientColors': [
        AppColors.tertiary,
        AppColors.tertiary.withOpacity(0.7),
        AppColors.primary.withOpacity(0.5),
      ],
      'icon': PhosphorIcons.map_trifold,
      'bgIcon': PhosphorIcons.calendar,
      'highlights': [
        'احفظ المفضلة بسهولة',
        'تنبيهات الطقس الذكية',
        'شارك تجاربك مع الأصدقاء',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();

    // إعداد متحكم الرسوم المتحركة للشفافية
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // إعداد متحكم الرسوم المتحركة للحجم
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimationController.forward();
    _scaleAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = page == _numPages - 1;
    });

    // إعادة تشغيل الرسوم المتحركة عند تغيير الصفحة
    _fadeAnimationController.reset();
    _scaleAnimationController.reset();
    _fadeAnimationController.forward();
    _scaleAnimationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _numPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingCompletedKey, true);

    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // خلفية متدرجة ديناميكية
          Builder(
            builder: (context) {
              final currentData = _onboardingData[_currentPage];
              final rawGradientColors =
                  currentData['gradientColors'] as List<Color>;
              final backgroundColors = [
                ...rawGradientColors.map(
                  (color) =>
                      isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
                ),
                isDark ? Colors.grey[900]! : Colors.white,
              ];
              final stops = List<double>.generate(
                backgroundColors.length,
                (index) => index / (backgroundColors.length - 1),
              );

              return AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: backgroundColors,
                    stops: stops,
                  ),
                ),
              );
            },
          ),

          // أيقونات خلفية متحركة
          ...List.generate(3, (index) {
            final currentData = _onboardingData[_currentPage];
            final bgIcon = currentData['bgIcon'] as IconData;
            final bgColor = currentData['color'] as Color;

            return Positioned(
              top: (index * 150.0) % screenSize.height,
              right: (index * 100.0) % screenSize.width,
              child: AnimatedOpacity(
                opacity: _currentPage == index ? 0.03 : 0.01,
                duration: const Duration(milliseconds: 500),
                child: Icon(bgIcon, size: 200, color: bgColor),
              ),
            );
          }),

          SafeArea(
            child: Column(
              children: [
                // زر التخطي
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // مساحة فارغة للتوازن
                      const SizedBox(width: 80),

                      // شعار التطبيق
                      Builder(
                        builder: (context) {
                          final currentData = _onboardingData[_currentPage];
                          final currentColor = currentData['color'] as Color;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: currentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: currentColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.map_pin,
                                  color: currentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Velora',
                                  style: TextStyle(
                                    color: currentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // زر التخطي
                      Builder(
                        builder: (context) {
                          final currentData = _onboardingData[_currentPage];
                          final currentColor = currentData['color'] as Color;

                          return AnimatedOpacity(
                            opacity: _isLastPage ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isLastPage ? null : _skipOnboarding,
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: currentColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: currentColor.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    'تخطي',
                                    style: TextStyle(
                                      color: currentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // محتوى الصفحات
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _numPages,
                    itemBuilder: (context, index) {
                      return _buildOnboardingPage(index);
                    },
                  ),
                ),

                // التنقل بين الصفحات
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    children: [
                      // مؤشر الصفحات
                      Builder(
                        builder: (context) {
                          final currentData = _onboardingData[_currentPage];
                          final currentColor = currentData['color'] as Color;

                          return SmoothPageIndicator(
                            controller: _pageController,
                            count: _numPages,
                            effect: ExpandingDotsEffect(
                              activeDotColor: currentColor,
                              dotColor: Colors.grey[300]!,
                              dotHeight: 8,
                              dotWidth: 8,
                              expansionFactor: 4,
                              spacing: 8,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // زر التالي/ابدأ الآن
                      Builder(
                        builder: (context) {
                          final currentData = _onboardingData[_currentPage];
                          final currentColor = currentData['color'] as Color;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: _isLastPage ? double.infinity : 70,
                            height: 70,
                            child: Material(
                              color: currentColor,
                              borderRadius: BorderRadius.circular(35),
                              elevation: 8,
                              shadowColor: currentColor.withOpacity(0.5),
                              child: InkWell(
                                onTap: _nextPage,
                                borderRadius: BorderRadius.circular(35),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(35),
                                    gradient: LinearGradient(
                                      colors: [
                                        currentColor,
                                        currentColor.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                  child:
                                      _isLastPage
                                          ? Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'ابدأ الآن',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    PhosphorIcons.arrow_right,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          : const Center(
                                            child: Icon(
                                              PhosphorIcons.arrow_right,
                                              size: 28,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),
                            ),
                          );
                        },
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

  Widget _buildOnboardingPage(int index) {
    final data = _onboardingData[index];
    final color = data['color'] as Color;
    final icon = data['icon'] as IconData;
    final bgIcon = data['bgIcon'] as IconData;
    final highlights =
        (data['highlights'] as List<String>?) ?? const <String>[];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight;
            final isCompactHeight = maxHeight < 640;
            final baseHero = isCompactHeight ? 96.0 : 130.0;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompactHeight ? 22 : 32,
                vertical: isCompactHeight ? 24 : 36,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: isCompactHeight ? 12 : 28),
                  _buildHeroIcon(
                    color: color,
                    icon: icon,
                    bgIcon: bgIcon,
                    diameter: baseHero,
                  ),
                  SizedBox(height: isCompactHeight ? 24 : 36),
                  _buildTitle(text: data['title'] as String, color: color),
                  const SizedBox(height: 16),
                  _buildDescription(text: data['description'] as String),
                  if (highlights.isNotEmpty) ...[
                    SizedBox(height: isCompactHeight ? 20 : 30),
                    _buildHighlights(color: color, highlights: highlights),
                  ],
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroIcon({
    required Color color,
    required IconData icon,
    required IconData bgIcon,
    required double diameter,
  }) {
    final haloDiameter = diameter + 60;

    return SizedBox(
      width: haloDiameter,
      height: haloDiameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: haloDiameter,
            height: haloDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color.withOpacity(0.2), Colors.transparent],
              ),
            ),
          ),
          Container(
            width: diameter + 28,
            height: diameter + 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.18),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 26,
                  spreadRadius: 2,
                  offset: const Offset(0, 18),
                ),
              ],
              border: Border.all(color: color.withOpacity(0.35), width: 3),
            ),
          ),
          Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.65)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: diameter * 0.48),
          ),
          Positioned(
            bottom: -diameter * 0.15,
            child: Icon(
              bgIcon,
              size: diameter * 0.7,
              color: color.withOpacity(0.14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle({required String text, required Color color}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription({required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
          height: 1.8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHighlights({
    required Color color,
    required List<String> highlights,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children:
          highlights.map((item) {
            return Chip(
              elevation: 0,
              backgroundColor: color.withOpacity(0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              label: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
    );
  }
}
