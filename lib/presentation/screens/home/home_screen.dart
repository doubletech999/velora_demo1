// lib/presentation/screens/home/enhanced_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/paths_provider.dart';
import '../../providers/saved_paths_provider.dart';
import 'widgets/weather_widget.dart';
import 'widgets/achievement_progress_widget.dart';
import 'widgets/trending_paths_widget.dart';
import 'widgets/quick_stats_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<HomeScreen> 
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PageController _tipsController = PageController();
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  
  bool _isScrolled = false;
  int _currentTipIndex = 0;
  
  final List<Map<String, dynamic>> _dailyTips = [
    {
      'title': 'نصيحة اليوم',
      'content': 'احضر كمية كافية من الماء عند المشي لمسافات طويلة',
      'icon': PhosphorIcons.drop,
      'color': Colors.blue,
    },
    {
      'title': 'تذكير أمان',
      'content': 'أخبر أحداً عن خطة رحلتك قبل المغادرة',
      'icon': PhosphorIcons.shield_check,
      'color': Colors.green,
    },
    {
      'title': 'نصيحة بيئية',
      'content': 'لا تترك أي مخلفات واحرص على حماية الطبيعة',
      'icon': PhosphorIcons.leaf,
      'color': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
    _startTipsAnimation();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 100;
      });
    });
  }

  void _startTipsAnimation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _nextTip();
      }
    });
  }

  void _nextTip() {
    if (_currentTipIndex < _dailyTips.length - 1) {
      setState(() {
        _currentTipIndex++;
      });
      _tipsController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() {
        _currentTipIndex = 0;
      });
      _tipsController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _nextTip();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tipsController.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    
    final userProvider = Provider.of<UserProvider>(context);
    final pathsProvider = Provider.of<PathsProvider>(context);
    final savedPathsProvider = Provider.of<SavedPathsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // شريط التطبيق المحسن
          _buildEnhancedAppBar(context, userProvider, languageProvider),
          
          // محتوى الصفحة
          SliverToBoxAdapter(
            child: AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    // ويدجت الطقس
                    const WeatherWidget(),
                    
                    // الإحصائيات السريعة
                    QuickStatsWidget(
                      completedTrips: userProvider.user?.completedTrips ?? 0,
                      savedPaths: savedPathsProvider.savedPaths.length,
                      achievements: userProvider.user?.achievements ?? 0,
                    ),
                    
                    // نصائح يومية
                    _buildDailyTips(),
                    
                    // شريط البحث المحسن
                    _buildEnhancedSearchBar(),
                    
                    // المسارات الشائعة
                  //  const TrendingPathsWidget(),
                    
                    // تقدم الإنجازات
                    const AchievementProgressWidget(),
                    
                    // مسارات مقترحة بناءً على الموقع
                    _buildLocationBasedPaths(pathsProvider),
                    
                    // دعوة لاستكشاف مسارات جديدة
                    _buildExploreCallToAction(),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // زر عائم للاستكشاف السريع
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildEnhancedAppBar(
    BuildContext context,
    UserProvider userProvider,
    LanguageProvider languageProvider,
  ) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
                AppColors.tertiary.withOpacity(0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // شريط العلوي مع الترحيب
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: userProvider.user?.profileImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.network(
                                  userProvider.user!.profileImageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                userProvider.user?.name.substring(0, 1).toUpperCase() ?? 'ض',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              userProvider.user?.name ?? 'مستخدم ضيف',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // درجة الحرارة
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(PhosphorIcons.sun, color: Colors.orange, size: 16),
                            SizedBox(width: 4),
                            Text('24°C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // رسالة تحفيزية
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.1),
                              child: const Icon(
                                PhosphorIcons.heart_fill,
                                color: Colors.red,
                                size: 20,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'فلسطين تنتظرك لاستكشاف جمالها',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(PhosphorIcons.bell, color: Colors.white),
          onPressed: () {
            // فتح الإشعارات
          },
        ),
        IconButton(
          icon: const Icon(PhosphorIcons.gear, color: Colors.white),
          onPressed: () => context.go('/profile/settings'),
        ),
      ],
    );
  }

  Widget _buildDailyTips() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 100,
      child: PageView.builder(
        controller: _tipsController,
        itemCount: _dailyTips.length,
        itemBuilder: (context, index) {
          final tip = _dailyTips[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tip['color'].withOpacity(0.1),
                  tip['color'].withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: tip['color'].withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: tip['color'].withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tip['icon'],
                      color: tip['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tip['title'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: tip['color'],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['content'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => context.go('/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                PhosphorIcons.magnifying_glass,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'ابحث عن مسار، مكان أو تجربة...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIcons.microphone,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationBasedPaths(PathsProvider pathsProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                PhosphorIcons.map_pin,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'مسارات قريبة منك',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/paths'),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                final path = pathsProvider.paths.isNotEmpty 
                    ? pathsProvider.paths[index % pathsProvider.paths.length]
                    : null;
                
                if (path == null) {
                  return const SizedBox();
                }
                
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Image.asset(
                          path.images.isNotEmpty ? path.images[0] : 'assets/images/logo.png',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                path.nameAr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    PhosphorIcons.map_pin,
                                    color: Colors.white70,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${path.length} كم من موقعك',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreCallToAction() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tertiary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            PhosphorIcons.compass,
            color: AppColors.primary,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'اكتشف مسارات جديدة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'لديك مجموعة من المسارات الجديدة في انتظارك',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/explore'),
            icon: const Icon(PhosphorIcons.arrow_right),
            label: const Text('استكشف الآن'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_bounceController.value * 0.1),
          child: FloatingActionButton.extended(
            onPressed: () {
              _bounceController.forward().then((_) {
                _bounceController.reverse();
              });
              context.go('/explore');
            },
            backgroundColor: AppColors.secondary,
            icon: const Icon(PhosphorIcons.lightning),
            label: const Text('استكشاف سريع'),
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'صباح الخير';
    } else if (hour < 17) {
      return 'نهارك سعيد';
    } else {
      return 'مساء الخير';
    }
  }
}

// ويدجت الطقس
class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            PhosphorIcons.sun,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الطقس اليوم',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'مشمس، 24°C',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'مثالي للمشي والاستكشاف',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'رام الله',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}