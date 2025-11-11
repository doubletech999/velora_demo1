// lib/presentation/screens/explore/explore_screen.dart - النسخة النهائية
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/path_model.dart';
import '../../../data/models/activity_model.dart';
import '../../providers/paths_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import 'widgets/explore_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ActivityType? selectedActivity;
  DifficultyLevel? selectedDifficulty;
  String? selectedLocation;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<PathModel> _getFilteredPaths(List<PathModel> allPaths) {
    return allPaths.where((path) {
      // فلترة بناءً على البحث
      bool matchesSearch =
          _searchQuery.isEmpty ||
          path.nameAr.toLowerCase().contains(_searchQuery) ||
          path.name.toLowerCase().contains(_searchQuery) ||
          path.descriptionAr.toLowerCase().contains(_searchQuery) ||
          path.locationAr.toLowerCase().contains(_searchQuery);

      // فلترة بناءً على النشاط
      bool matchesActivity =
          selectedActivity == null ||
          path.activities.contains(selectedActivity);

      // فلترة بناءً على الصعوبة
      bool matchesDifficulty =
          selectedDifficulty == null || path.difficulty == selectedDifficulty;

      // فلترة بناءً على الموقع
      bool matchesLocation = selectedLocation == null;
      if (!matchesLocation && selectedLocation != null) {
        // Check if path location matches the selected region
        final locationAr = path.locationAr;
        if (selectedLocation == 'north') {
          matchesLocation =
              locationAr.contains('الشمال') || locationAr.contains('الجليل');
        } else if (selectedLocation == 'center') {
          matchesLocation =
              locationAr.contains('الوسط') ||
              locationAr.contains('رام الله') ||
              locationAr.contains('نابلس');
        } else if (selectedLocation == 'south') {
          matchesLocation =
              locationAr.contains('الجنوب') || locationAr.contains('الخليل');
        }
      }

      return matchesSearch &&
          matchesActivity &&
          matchesDifficulty &&
          matchesLocation;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          final pathsProvider = Provider.of<PathsProvider>(
            context,
            listen: false,
          );
          await pathsProvider.loadPaths();
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // شريط التطبيق
              SliverAppBar(
                expandedHeight: 60,
                pinned: true,
                backgroundColor: theme.colorScheme.surface,
                elevation: 0,
                title: Row(
                  children: [
                    Text(
                      AppLocalizations.ofOrThrow(context).get('explore'),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      PhosphorIcons.compass,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Stack(
                      children: [
                        Icon(PhosphorIcons.funnel, color: AppColors.primary),
                        if (selectedActivity != null ||
                            selectedDifficulty != null ||
                            selectedLocation != null)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: _showFilterBottomSheet,
                  ),
                ],
              ),

              // شريط البحث
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surface,
                  child: _buildSearchBar(context),
                ),
              ),

              // شريط التبويبات
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  Container(
                    color: theme.colorScheme.surface,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 3,
                        ),
                        insets: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      tabs: [
                        // التبويب الأساسي: المسارات والتخييم
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(PhosphorIcons.map_pin, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.ofOrThrow(
                                  context,
                                ).get('routes_camping_tab'),
                              ),
                            ],
                          ),
                        ),
                        // التبويب الثانوي: الأماكن السياحية
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(PhosphorIcons.buildings, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.ofOrThrow(
                                  context,
                                ).get('sites_tab'),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(PhosphorIcons.compass, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.ofOrThrow(
                                  context,
                                ).get('activities_tab'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Consumer<PathsProvider>(
            builder: (context, pathsProvider, child) {
              if (pathsProvider.isLoading) {
                return const LoadingIndicator();
              }

              final allPaths = pathsProvider.paths;
              final filteredSites = pathsProvider.filteredSites;
              final filteredRoutesAndCamping =
                  pathsProvider.filteredRoutesAndCamping;

              return TabBarView(
                controller: _tabController,
                children: [
                  // التبويب الأساسي: المسارات والتخييم
                  _buildRoutesAndCampingTab(filteredRoutesAndCamping),

                  // التبويب الثانوي: الأماكن السياحية
                  _buildSitesTab(filteredSites),

                  // تبويب الأنشطة
                  _buildActivitiesTab(allPaths),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppLocalizations.ofOrThrow(
            context,
          ).get('search_paths_placeholder'),
          hintStyle: TextStyle(
            color:
                isDark
                    ? theme.textTheme.bodyMedium?.color?.withOpacity(0.4)
                    : Colors.grey[400],
            fontSize: 15,
          ),
          prefixIcon: Icon(
            PhosphorIcons.magnifying_glass,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            size: 20,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      PhosphorIcons.x,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.6,
                      ),
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: TextStyle(fontSize: 15, color: theme.textTheme.bodyLarge?.color),
      ),
    );
  }

  Widget _buildSitesTab(List<PathModel> filteredSites) {
    final localizations = AppLocalizations.ofOrThrow(context);
    if (filteredSites.isEmpty) {
      return _buildEmptyState(
        icon: PhosphorIcons.buildings,
        title: localizations.get('no_sites_available'),
        subtitle: localizations.get('try_changing_filters'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: filteredSites.length,
      itemBuilder: (context, index) {
        final path = filteredSites[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ExploreCard(
            path: path,
            onTap: () => context.go('/paths/${path.id}'),
          ),
        );
      },
    );
  }

  Widget _buildRoutesAndCampingTab(List<PathModel> filteredRoutesAndCamping) {
    final localizations = AppLocalizations.ofOrThrow(context);
    if (filteredRoutesAndCamping.isEmpty) {
      return _buildEmptyState(
        icon: PhosphorIcons.map_pin,
        title: localizations.get('no_routes_available'),
        subtitle: localizations.get('try_changing_filters'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: filteredRoutesAndCamping.length,
      itemBuilder: (context, index) {
        final path = filteredRoutesAndCamping[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ExploreCard(
            path: path,
            onTap: () => context.go('/paths/${path.id}'),
          ),
        );
      },
    );
  }

  Widget _buildActivitiesTab(List<PathModel> allPaths) {
    final activities = ActivityModel.getAllActivities();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: context.verticalCardAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final pathsCount =
            allPaths
                .where(
                  (path) => path.activities.contains(
                    ActivityType.values.byName(activity.id),
                  ),
                )
                .length;

        return _buildActivityCard(activity, pathsCount);
      },
    );
  }

  Widget _buildActivityCard(ActivityModel activity, int pathsCount) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedActivity = ActivityType.values.byName(activity.id);
          _tabController.animateTo(0);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: activity.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(activity.icon, color: activity.color, size: 28),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  AppLocalizations.ofOrThrow(context).get(activity.id),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.ofOrThrow(context)
                    .get('path_count_available')
                    .replaceAll('{count}', pathsCount.toString()),
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: colorScheme.surface,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان والخط المؤشر
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.ofOrThrow(
                              context,
                            ).get('filter_results'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(PhosphorIcons.x),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // فلتر النشاط
                      Text(
                        AppLocalizations.ofOrThrow(
                          context,
                        ).get('filter_activity_type'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            ActivityType.values.map((activity) {
                              final isSelected = selectedActivity == activity;
                              return _buildFilterChip(
                                label: _getActivityText(activity, context),
                                isSelected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    setState(() {
                                      selectedActivity =
                                          selected ? activity : null;
                                    });
                                  });
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // فلتر الصعوبة
                      Text(
                        AppLocalizations.ofOrThrow(
                          context,
                        ).get('filter_difficulty_level'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            DifficultyLevel.values.map((difficulty) {
                              final isSelected =
                                  selectedDifficulty == difficulty;
                              final color = _getDifficultyColor(difficulty);
                              return _buildFilterChip(
                                label: _getDifficultyText(difficulty, context),
                                isSelected: isSelected,
                                color: color,
                                onSelected: (selected) {
                                  setModalState(() {
                                    setState(() {
                                      selectedDifficulty =
                                          selected ? difficulty : null;
                                    });
                                  });
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // فلتر المنطقة
                      Builder(
                        builder: (context) {
                          final localizations = AppLocalizations.ofOrThrow(
                            context,
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.get('region'),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children:
                                    ['north', 'center', 'south'].map((
                                      locationKey,
                                    ) {
                                      final location = localizations.get(
                                        locationKey,
                                      );
                                      final isSelected =
                                          selectedLocation == locationKey;
                                      return _buildFilterChip(
                                        label: location,
                                        isSelected: isSelected,
                                        onSelected: (selected) {
                                          setModalState(() {
                                            setState(() {
                                              selectedLocation =
                                                  selected ? locationKey : null;
                                            });
                                          });
                                        },
                                      );
                                    }).toList(),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40),

                      // عداد النتائج
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(
                            Theme.of(context).brightness == Brightness.dark
                                ? 0.2
                                : 0.05,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIcons.map_trifold,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Consumer<PathsProvider>(
                              builder: (context, provider, child) {
                                final filteredPaths = _getFilteredPaths(
                                  provider.paths,
                                );
                                final localizations =
                                    AppLocalizations.ofOrThrow(context);
                                return Text(
                                  localizations
                                      .get('path_count_available')
                                      .replaceAll(
                                        '{count}',
                                        filteredPaths.length.toString(),
                                      ),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // أزرار الإجراءات
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  selectedActivity = null;
                                  selectedDifficulty = null;
                                  selectedLocation = null;
                                });
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.ofOrThrow(
                                  context,
                                ).get('clear_filters'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.ofOrThrow(
                                  context,
                                ).get('apply_filters'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chipColor = color ?? AppColors.primary;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? chipColor : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: colorScheme.surface,
      selectedColor: chipColor.withOpacity(
        theme.brightness == Brightness.dark ? 0.2 : 0.1,
      ),
      checkmarkColor: chipColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(
          color: isSelected ? chipColor : colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      elevation: 0,
    );
  }

  String _getActivityText(ActivityType activity, BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    switch (activity) {
      case ActivityType.hiking:
        return localizations.get('hiking');
      case ActivityType.camping:
        return localizations.get('camping');
      case ActivityType.climbing:
        return localizations.get('climbing');
      case ActivityType.religious:
        return localizations.get('religious');
      case ActivityType.cultural:
        return localizations.get('cultural');
      case ActivityType.nature:
        return localizations.get('nature');
      case ActivityType.archaeological:
        return localizations.get('archaeological');
    }
  }

  String _getDifficultyText(DifficultyLevel difficulty, BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    switch (difficulty) {
      case DifficultyLevel.easy:
        return localizations.get('easy');
      case DifficultyLevel.medium:
        return localizations.get('medium');
      case DifficultyLevel.hard:
        return localizations.get('hard');
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return AppColors.difficultyEasy;
      case DifficultyLevel.medium:
        return AppColors.difficultyMedium;
      case DifficultyLevel.hard:
        return AppColors.difficultyHard;
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
