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
import '../../providers/trips_provider.dart';
import '../../../data/models/trip_model.dart';
import '../../widgets/trips/trip_details_modal.dart';
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
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);

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
      print('   - المواقع: ${pathsProvider.sites.length}');
      print('   - المميزة: ${pathsProvider.featuredPaths.length}');
    }

    if (!tripsProvider.initialized && !tripsProvider.isLoading) {
      print('🔄 HomeScreen: تحميل الرحلات...');
      await tripsProvider.loadTrips();
    } else if (tripsProvider.adventureTrips.isEmpty &&
        !tripsProvider.isLoading) {
      print('🔄 HomeScreen: الرحلات فارغة - إعادة تحميل...');
      await tripsProvider.loadTrips();
    } else {
      print(
        '✅ HomeScreen: الرحلات محملة (${tripsProvider.adventureTrips.length})',
      );
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
          final tripsProvider = Provider.of<TripsProvider>(
            context,
            listen: false,
          );
          await Future.wait([
            pathsProvider.loadPaths(),
            tripsProvider.loadTrips(),
          ]);
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

                // الرحلات الشائعة
                const OptimizedTrendingPaths(),

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
          Consumer<TripsProvider>(
            builder: (context, tripsProvider, child) {
              if (!tripsProvider.initialized && !tripsProvider.isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  tripsProvider.loadTrips();
                });
              }

              if (tripsProvider.isLoading &&
                  tripsProvider.adventureTrips.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final trips = tripsProvider.adventureTrips.toList()
                ..sort(
                  (a, b) =>
                      (a.startDate ?? DateTime.now())
                          .compareTo(b.startDate ?? DateTime.now()),
                );
              final trendingTrips = trips.take(3).toList();

              if (trendingTrips.isEmpty) {
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
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: trendingTrips.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final trip = trendingTrips[index];
                    return SizedBox(
                      width: 280,
                      child: _TripTrendingCard(
                        trip: trip,
                        onTap: () => showTripDetailsModal(context, trip),
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

class _TripTrendingCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const _TripTrendingCard({
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: _TripCoverImage(imageUrl: trip.displayImage)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.75),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 18,
              right: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        PhosphorIcons.calendar_blank,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          trip.dateRange,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (trip.siteCount > 0)
                        _TripChip(label: '${trip.siteCount} موقع'),
                      if (trip.price != null)
                        _TripChip(label: '${trip.price!.toStringAsFixed(2)} \$'),
                      ...trip.activities.take(2).map(
                        (activity) => _TripChip(
                          label: activity.replaceAll('_', ' '),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCoverImage extends StatelessWidget {
  final String imageUrl;

  const _TripCoverImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _placeholder(spinner: true);
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder({bool spinner = false}) {
    return Container(
      color: AppColors.primary.withOpacity(0.15),
      child: Center(
        child:
            spinner
                ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(
                  PhosphorIcons.image,
                  color: Colors.white,
                  size: 36,
                ),
      ),
    );
  }
}

class _TripChip extends StatelessWidget {
  final String label;

  const _TripChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
