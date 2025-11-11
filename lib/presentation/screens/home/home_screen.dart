// lib/presentation/screens/home/home_screen.dart - نسخة محسنة للأداء
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/user_provider.dart';
import '../../providers/paths_provider.dart';
import '../../providers/saved_paths_provider.dart';
import 'widgets/weather_widget.dart';
import 'widgets/quick_stats_widget.dart';
import 'widgets/featured_routes_section.dart';
import 'widgets/featured_sites_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  // الحفاظ على حالة الصفحة لتجنب إعادة البناء
  @override
  bool get wantKeepAlive => true;

  // تحسين التحكم في الرسوم المتحركة
  late final ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _setupScrollListener();

    // تحميل البيانات بشكل تدريجي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataGradually();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isScrolled = _scrollController.offset > 100;
      if (isScrolled != _isScrolled) {
        setState(() {
          _isScrolled = isScrolled;
        });
      }
    });
  }

  Future<void> _loadDataGradually() async {
    // تحميل البيانات الأساسية أولاً
    final pathsProvider = Provider.of<PathsProvider>(context, listen: false);

    // تحميل البيانات إذا لم تكن محملة أو لم يتم التهيئة
    if (!pathsProvider.initialized && !pathsProvider.isLoading) {
      print('🔄 HomeScreen: بدء تحميل البيانات...');
      await pathsProvider.loadPaths();
    } else if (pathsProvider.paths.isEmpty &&
        pathsProvider.sites.isEmpty &&
        pathsProvider.routesAndCamping.isEmpty) {
      print('🔄 HomeScreen: البيانات فارغة - إعادة تحميل...');
      await pathsProvider.loadPaths();
    } else {
      print('✅ HomeScreen: البيانات محملة بالفعل');
      print('   - المسارات: ${pathsProvider.routesAndCamping.length}');
      print('   - المواقع: ${pathsProvider.sites.length}');
      print('   - المميزة: ${pathsProvider.featuredPaths.length}');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // مطلوب لـ AutomaticKeepAliveClientMixin

    ResponsiveUtils.init(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          final pathsProvider = Provider.of<PathsProvider>(
            context,
            listen: false,
          );
          await pathsProvider.loadPaths();
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // شريط التطبيق المحسن
            _buildOptimizedAppBar(context),

            // محتوى الصفحة مع lazy loading
            SliverList(
              delegate: SliverChildListDelegate([
                // ويدجت الطقس
                const WeatherWidget(),

                // الإحصائيات السريعة
                _buildQuickStats(),

                // نصائح يومية مبسطة
                _buildSimpleTips(),

                // شريط البحث
                _buildSearchBar(),

                // أبرز المسارات (تحميل مُحسن)
                const FeaturedRoutesSection(),

                // أبرز المواقع السياحية
                const FeaturedSitesSection(),

                // دعوة للاستكشاف
                _buildExploreCallToAction(),

                const SizedBox(height: 100),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizedAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180, // تقليل الارتفاع
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // معلومات المستخدم مبسطة
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              userProvider.user?.name
                                      .substring(0, 1)
                                      .toUpperCase() ??
                                  'ض',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  userProvider.user?.name ?? 'مستخدم ضيف',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // رسالة تحفيزية مبسطة
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              PhosphorIcons.heart_fill,
                              color: Colors.red,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'فلسطين تنتظرك لاستكشاف جمالها',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(PhosphorIcons.bell, color: Colors.white),
          onPressed: () {
            // الإشعارات
          },
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Consumer3<UserProvider, SavedPathsProvider, PathsProvider>(
      builder: (
        context,
        userProvider,
        savedPathsProvider,
        pathsProvider,
        child,
      ) {
        return QuickStatsWidget(
          completedTrips: userProvider.user?.completedTrips ?? 0,
          savedPaths: savedPathsProvider.savedPaths.length,
          achievements: userProvider.user?.achievements ?? 0,
        );
      },
    );
  }

  Widget _buildSimpleTips() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: const Row(
        children: [
          Icon(PhosphorIcons.lightbulb, color: Colors.blue, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'احرص على أخذ كمية كافية من الماء عند المشي',
              style: TextStyle(fontSize: 14, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => context.go('/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
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

  Widget _buildExploreCallToAction() {
    final localizations = AppLocalizations.ofOrThrow(context);

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
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          const Icon(PhosphorIcons.compass, color: AppColors.primary, size: 48),
          const SizedBox(height: 12),
          Text(
            localizations.get('discover_new_paths'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.get('new_paths_message'),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/explore'),
            icon: const Icon(PhosphorIcons.arrow_right),
            label: Text(localizations.get('explore_now')),
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

// ويدجت محسنة للمسارات الشائعة
class OptimizedTrendingPaths extends StatelessWidget {
  const OptimizedTrendingPaths({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                PhosphorIcons.trend_up,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.get('trending_paths'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/paths'),
                child: Text(localizations.get('view_all')),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // استخدام FutureBuilder للتحميل المحسن
          Consumer<PathsProvider>(
            builder: (context, pathsProvider, child) {
              // Load paths if not already loaded
              if (!pathsProvider.initialized && !pathsProvider.isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  pathsProvider.loadPaths();
                });
              }

              // Show loading while fetching
              if (pathsProvider.isLoading &&
                  pathsProvider.featuredPaths.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Use featuredPaths (المسارات والتخييمات المميزة) if available
              // Otherwise use routesAndCamping sorted by rating
              final allPaths =
                  pathsProvider.featuredPaths.isNotEmpty
                      ? pathsProvider.featuredPaths
                      : pathsProvider.routesAndCamping;

              // Sort by rating if using regular paths
              final sortedPaths =
                  allPaths.toList()
                    ..sort((a, b) => b.rating.compareTo(a.rating));
              final trendingPaths = sortedPaths.take(3).toList();

              if (trendingPaths.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      localizations.get('no_paths_empty'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: trendingPaths.length,
                  itemBuilder: (context, index) {
                    final path = trendingPaths[index];
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => context.go('/paths/${path.id}'),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              // صورة المسار
                              SizedBox(
                                height: 180,
                                width: double.infinity,
                                child: Image.asset(
                                  path.images.isNotEmpty
                                      ? path.images[0]
                                      : 'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          PhosphorIcons.image,
                                          color: Colors.grey,
                                          size: 48,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // تدرج شفاف
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                      stops: const [0.6, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // معلومات المسار
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        path.nameAr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                                          Expanded(
                                            child: Text(
                                              path.locationAr,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
