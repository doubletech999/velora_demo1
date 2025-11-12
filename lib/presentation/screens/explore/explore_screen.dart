import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/path_model.dart';
import '../../../data/models/trip_model.dart';
import '../../providers/paths_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/trips/trip_card.dart';
import '../../widgets/trips/trip_details_modal.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  final TextEditingController _searchController = TextEditingController();

  int _selectedCategory = 0;
  String _searchQuery = '';

  final List<_CategoryItem> _categories = const [
    _CategoryItem(icon: PhosphorIcons.map_trifold_bold, label: 'رحلات'),
    _CategoryItem(icon: PhosphorIcons.buildings_bold, label: 'سياحة'),
    _CategoryItem(icon: Icons.restaurant, label: 'مطاعم'),
    _CategoryItem(icon: Icons.hotel, label: 'فنادق'),
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PathsProvider>().initializeIfNeeded();
      context.read<TripsProvider>().initializeIfNeeded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final localizations = AppLocalizations.ofOrThrow(context);
    final pathsProvider = context.watch<PathsProvider>();
    final tripsProvider = context.watch<TripsProvider>();

    final bool pathsLoading =
        pathsProvider.isLoading && !pathsProvider.initialized;
    final bool pathsHasError =
        !pathsLoading &&
        pathsProvider.error != null &&
        pathsProvider.error!.isNotEmpty;

    final List<TripModel> trips =
        _applyTripSearch(tripsProvider.adventureTrips).toList();
    final bool tripsLoading = tripsProvider.isLoading && trips.isEmpty;
    final bool tripsHasError = tripsProvider.error != null && trips.isEmpty;

    final List<PathModel> sites =
        _applySearch(pathsProvider.filteredSites).toList();
    final List<PathModel> restaurants =
        _applySearch(pathsProvider.filteredRestaurants).toList();
    final List<PathModel> hotels =
        _applySearch(pathsProvider.filteredHotels).toList();

    final sections = [
      _SectionData(
        sliderTitle: 'أماكن سياحية مميزة',
        listTitle: 'أماكن سياحية',
        emptyMessage: 'لا توجد أماكن سياحية متاحة حالياً.',
        items: sites,
      ),
      _SectionData(
        sliderTitle: 'مطاعم ننصح بها',
        listTitle: 'مطاعم مميزة',
        emptyMessage: 'لا توجد مطاعم متاحة حالياً.',
        items: restaurants,
      ),
      _SectionData(
        sliderTitle: 'فنادق مختارة',
        listTitle: 'فنادق للإقامة',
        emptyMessage: 'لا توجد فنادق متاحة حالياً.',
        items: hotels,
      ),
    ];

    final bool onTripsCategory = _selectedCategory == 0;
    final List<_SectionData> secondarySections =
        onTripsCategory
            ? sections
            : [
              for (int i = 0; i < sections.length; i++)
                if (i != _selectedCategory - 1) sections[i],
            ];

    final bool hasAnyItems =
        onTripsCategory
            ? trips.isNotEmpty
            : sections[_selectedCategory - 1].items.isNotEmpty;
    final bool isLoadingSelected =
        onTripsCategory
            ? tripsLoading
            : pathsLoading && !sections[_selectedCategory - 1].items.isNotEmpty;
    final bool hasErrorSelected =
        onTripsCategory
            ? tripsHasError
            : pathsHasError &&
                !sections[_selectedCategory - 1].items.isNotEmpty;

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            if (_searchQuery.isNotEmpty) _buildActiveSearchChip(),
            SizedBox(
              height: context.responsive(mobile: 16, tablet: 24, desktop: 32),
            ),
            _buildCategoryBar(),
            SizedBox(
              height: context.responsive(mobile: 16, tablet: 24, desktop: 32),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (onTripsCategory) {
                    if (tripsLoading && trips.isEmpty) {
                      return const LoadingIndicator(
                        message: 'جاري تحميل الرحلات...',
                      );
                    }

                    if (tripsHasError && trips.isEmpty) {
                      return _buildErrorState(
                        tripsProvider.error ?? 'فشل تحميل الرحلات',
                        localizations,
                      );
                    }

                    if (!tripsLoading && trips.isEmpty) {
                      return _buildEmptyState(localizations);
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsive(
                          mobile: 20,
                          tablet: MediaQuery.of(context).size.width * 0.1,
                          desktop: MediaQuery.of(context).size.width * 0.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('رحلات مميزة'),
                          SizedBox(
                            height: context.responsive(
                              mobile: 12,
                              tablet: 16,
                              desktop: 20,
                            ),
                          ),
                          _buildTripSlider(trips),
                          SizedBox(
                            height: context.responsive(
                              mobile: 24,
                              tablet: 32,
                              desktop: 40,
                            ),
                          ),
                          _buildSectionTitle('جميع الرحلات'),
                          SizedBox(
                            height: context.responsive(
                              mobile: 12,
                              tablet: 16,
                              desktop: 20,
                            ),
                          ),
                          _buildTripList(trips),
                          SizedBox(
                            height: context.responsive(
                              mobile: 40,
                              tablet: 48,
                              desktop: 56,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (isLoadingSelected && !hasAnyItems) {
                    return const LoadingIndicator(
                      message: 'جاري تحميل البيانات...',
                    );
                  }

                  if (hasErrorSelected && !hasAnyItems) {
                    return _buildErrorState(
                      pathsProvider.error ?? 'فشل تحميل البيانات',
                      localizations,
                    );
                  }

                  if (!isLoadingSelected && !hasAnyItems) {
                    return _buildEmptyState(localizations);
                  }

                  final primarySection = sections[_selectedCategory - 1];

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsive(
                        mobile: 20,
                        tablet: MediaQuery.of(context).size.width * 0.1,
                        desktop: MediaQuery.of(context).size.width * 0.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(primarySection.sliderTitle),
                        SizedBox(
                          height: context.responsive(
                            mobile: 12,
                            tablet: 16,
                            desktop: 20,
                          ),
                        ),
                        _buildSlider(
                          _topPaths(primarySection.items),
                          pathsLoading,
                          pathsHasError,
                          primarySection.emptyMessage,
                        ),
                        SizedBox(
                          height: context.responsive(
                            mobile: 24,
                            tablet: 32,
                            desktop: 40,
                          ),
                        ),
                        for (final section in secondarySections) ...[
                          _buildSectionTitle(section.listTitle),
                          SizedBox(
                            height: context.responsive(
                              mobile: 12,
                              tablet: 16,
                              desktop: 20,
                            ),
                          ),
                          _buildHighlightsGrid(
                            section.items,
                            pathsLoading,
                            pathsHasError,
                            section.emptyMessage,
                          ),
                          SizedBox(
                            height: context.responsive(
                              mobile: 24,
                              tablet: 32,
                              desktop: 40,
                            ),
                          ),
                        ],
                        SizedBox(
                          height: context.responsive(
                            mobile: 40,
                            tablet: 48,
                            desktop: 56,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive(
          mobile: 20,
          tablet: MediaQuery.of(context).size.width * 0.1,
          desktop: MediaQuery.of(context).size.width * 0.2,
        ),
        vertical: 8,
      ),
      child: Row(
        children: [
          _roundIconButton(
            icon: PhosphorIcons.sliders_horizontal_bold,
            onTap: () => _showMessage('الإعدادات قيد التطوير حالياً'),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? surfaceColor.withOpacity(0.7) : theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: isDark
                  ? Border.all(color: Colors.white.withOpacity(0.06))
                  : null,
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', width: 28, height: 28),
                const SizedBox(width: 8),
                Text(
                  'Velora',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _roundIconButton(
            icon: PhosphorIcons.magnifying_glass_bold,
            onTap: () => _openSearchSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSearchChip() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive(
          mobile: 20,
          tablet: MediaQuery.of(context).size.width * 0.1,
          desktop: MediaQuery.of(context).size.width * 0.2,
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Chip(
          avatar: const Icon(PhosphorIcons.magnifying_glass, size: 18),
          backgroundColor: isDark
              ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
              : theme.colorScheme.surface,
          label: Text('بحث: $_searchQuery'),
          deleteIcon: const Icon(Icons.close),
          onDeleted: () => _searchController.clear(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          labelStyle: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unselectedBackground = isDark
        ? theme.colorScheme.surfaceVariant.withOpacity(0.35)
        : theme.cardColor;
    final unselectedForeground =
        isDark ? theme.colorScheme.onSurface : AppColors.primary;

    return SizedBox(
      height: 72,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final bool isSelected = index == _selectedCategory;
          final Color backgroundColor =
              isSelected ? AppColors.primary : unselectedBackground;
          final Color foregroundColor =
              isSelected ? theme.colorScheme.onPrimary : unselectedForeground;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = index;
              });
            },
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(22),
                border: isSelected || !isDark
                    ? null
                    : Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                boxShadow: isSelected && !isDark
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon, color: foregroundColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    category.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _categories.length,
      ),
    );
  }

  List<PathModel> _topPaths(List<PathModel> source) {
    final List<PathModel> sorted = List<PathModel>.from(source);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(5).toList();
  }

  Iterable<TripModel> _applyTripSearch(List<TripModel> source) {
    if (_searchQuery.isEmpty) {
      return source;
    }
    final query = _searchQuery;
    return source.where((trip) {
      final fields = <String>[
        trip.name,
        if (trip.description != null) trip.description!,
        if (trip.customRoute != null) trip.customRoute!,
        if (trip.guideName != null) trip.guideName!,
        if (trip.travelerName != null) trip.travelerName!,
        ...trip.activities,
        ...trip.sites.map((site) => site.displayName),
      ];
      return fields.any((field) => field.toLowerCase().contains(query));
    });
  }

  Widget _buildSlider(
    List<PathModel> paths,
    bool isLoading,
    bool hasError,
    String emptyMessage,
  ) {
    final sliderHeight = context.responsive(
      mobile: 220.0,
      tablet: 320.0,
      desktop: 360.0,
    );

    if (isLoading && paths.isEmpty) {
      return SizedBox(height: sliderHeight, child: const LoadingIndicator());
    }

    if (paths.isEmpty) {
      return _buildPlaceholderCard(
        sliderHeight,
        message: hasError ? 'تعذّر تحميل البيانات.' : emptyMessage,
      );
    }

    return Column(
      children: [
        SizedBox(
          height: sliderHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (value) => _currentPage.value = value,
            itemCount: paths.length,
            itemBuilder:
                (context, index) => _SliderCard(
                  path: paths[index],
                  onTap: () => context.push('/paths/${paths[index].id}'),
                  onFavorite:
                      () => _showMessage(
                        'تم حفظ ${paths[index].nameAr} في المفضلة',
                      ),
                  tags: _activityTags(paths[index]).take(3).toList(),
                ),
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<int>(
          valueListenable: _currentPage,
          builder: (context, value, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(paths.length, (index) {
                final isActive = index == value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: isActive ? 18 : 8,
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTripSlider(List<TripModel> trips) {
    final sliderTrips = trips.take(5).toList();
    final sliderHeight = context.responsive(
      mobile: 230.0,
      tablet: 320.0,
      desktop: 360.0,
    );

    if (sliderTrips.isEmpty) {
      return _buildPlaceholderCard(
        sliderHeight,
        message: 'لا توجد رحلات متاحة حالياً.',
      );
    }

    return Column(
      children: [
        SizedBox(
          height: sliderHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (value) => _currentPage.value = value,
            itemCount: sliderTrips.length,
            itemBuilder:
                (context, index) => _TripSliderCard(
                  trip: sliderTrips[index],
                  onTap: () => _showTripDetails(sliderTrips[index]),
                  tags: _tripTags(sliderTrips[index]).take(4).toList(),
                ),
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<int>(
          valueListenable: _currentPage,
          builder: (context, value, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(sliderTrips.length, (index) {
                final isActive = index == value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: isActive ? 18 : 8,
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTripList(List<TripModel> trips) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final trip = trips[index];
        return TripListCard(trip: trip, onTap: () => _showTripDetails(trip));
      },
    );
  }

  Widget _buildHighlightsGrid(
    List<PathModel> paths,
    bool isLoading,
    bool hasError,
    String emptyMessage,
  ) {
    final crossAxisCount = context.responsive(mobile: 2, tablet: 3, desktop: 4);
    final spacing = context.responsive(
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );

    if (isLoading && paths.isEmpty) {
      return const LoadingIndicator();
    }

    if (paths.isEmpty) {
      return _buildPlaceholderCard(
        180,
        message:
            hasError
                ? 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.'
                : emptyMessage,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.95,
      ),
      itemCount: paths.length,
      itemBuilder: (context, index) {
        final path = paths[index];
        return _HighlightCard(
          path: path,
          tags: _activityTags(path).take(2).toList(),
          onTap: () => context.push('/paths/${path.id}'),
        );
      },
    );
  }

  Widget _buildPlaceholderCard(double height, {required String message}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.white70;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.08))
            : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ) ??
                TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildErrorState(String error, AppLocalizations localizations) {
    final theme = Theme.of(context);
    final secondaryColor =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
            Colors.white70;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              PhosphorIcons.warning_circle_bold,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ أثناء تحميل البيانات',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
            Colors.white70;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive(
          mobile: 24,
          tablet: width * 0.2,
          desktop: width * 0.25,
        ),
        vertical: context.responsive(mobile: 56, tablet: 80, desktop: 96),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceVariant.withOpacity(0.35)
                  : theme.cardColor,
              shape: BoxShape.circle,
              border: isDark
                  ? Border.all(color: Colors.white.withOpacity(0.08))
                  : null,
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: const Icon(
              PhosphorIcons.map_trifold_bold,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'لم نعثر على شيء هنا بعد!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'يمكنك إعادة تعيين البحث أو تبديل التصنيف لرؤية أماكن أكثر تشويقاً.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: secondaryColor,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(PhosphorIcons.arrow_counter_clockwise),
                label: const Text('إعادة التصفية'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openSearchSheet,
                icon: const Icon(PhosphorIcons.magnifying_glass),
                label: const Text('تعديل البحث'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? theme.colorScheme.surfaceVariant.withOpacity(0.45)
        : theme.cardColor;
    final iconColor =
        isDark ? theme.colorScheme.onSurface : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: isDark
              ? Border.all(color: Colors.white.withOpacity(0.05))
              : null,
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Icon(icon, color: iconColor),
      ),
    );
  }

  void _openSearchSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        final theme = Theme.of(sheetContext);
        final isDark = theme.brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: bottomInset + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'ابحث عن مسار أو موقع...',
                  prefixIcon: const Icon(PhosphorIcons.magnifying_glass),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(PhosphorIcons.x_circle),
                            onPressed: () => _searchController.clear(),
                          )
                          : null,
                  filled: true,
                  fillColor: isDark
                      ? theme.colorScheme.surfaceVariant.withOpacity(0.6)
                      : theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => Navigator.of(sheetContext).pop(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'نتائج تظهر مباشرة أثناء الكتابة.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('مسح'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 0;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  Iterable<PathModel> _applySearch(List<PathModel> source) {
    if (_searchQuery.isEmpty) {
      return source;
    }
    return source.where(_matchesSearch);
  }

  void _showTripDetails(TripModel trip) {
    final tripsProvider = context.read<TripsProvider>();
    final fallbackPath = tripsProvider.getFallbackPath(trip.id);
    final registrationPathId = fallbackPath?.id ?? trip.primarySiteId;

    VoidCallback? onRegister;
    if (registrationPathId != null && registrationPathId.isNotEmpty) {
      onRegister = () => context.push('/paths/$registrationPathId');
    }

    showTripDetailsModal(context, trip, onRegister: onRegister);
  }

  bool _matchesSearch(PathModel path) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery;
    final fields = [path.name, path.nameAr, path.location, path.locationAr];
    return fields.any((value) => value.toLowerCase().contains(query));
  }

  Iterable<String> _activityTags(PathModel path) {
    return path.activities
        .map(_activityLabel)
        .where((label) => label.isNotEmpty);
  }

  String _activityLabel(ActivityType activity) {
    switch (activity) {
      case ActivityType.hiking:
        return 'مسار';
      case ActivityType.camping:
        return 'تخييم';
      case ActivityType.climbing:
        return 'تسلق';
      case ActivityType.religious:
        return 'زيارات دينية';
      case ActivityType.cultural:
        return 'ثقافية';
      case ActivityType.nature:
        return 'طبيعة';
      case ActivityType.archaeological:
        return 'آثار';
    }
  }

  Iterable<String> _tripTags(TripModel trip) sync* {
    if (trip.siteCount > 0) {
      yield '${trip.siteCount} موقع';
    }
    if (trip.durationInDays > 0) {
      yield '${trip.durationInDays} يوم';
    }
    for (final activity in trip.activities) {
      yield activity.replaceAll('_', ' ');
    }
  }
}

class _CategoryItem {
  final IconData icon;
  final String label;

  const _CategoryItem({required this.icon, required this.label});
}

class _SectionData {
  final String sliderTitle;
  final String listTitle;
  final String emptyMessage;
  final List<PathModel> items;

  _SectionData({
    required this.sliderTitle,
    required this.listTitle,
    required this.emptyMessage,
    required this.items,
  });
}

class _SliderCard extends StatelessWidget {
  final PathModel path;
  final List<String> tags;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const _SliderCard({
    required this.path,
    required this.tags,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        path.images.isNotEmpty ? path.images.first : 'assets/images/logo.png';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labelBackground = isDark
        ? theme.colorScheme.surface.withOpacity(0.85)
        : Colors.white.withOpacity(0.9);
    final tagBackground = isDark
        ? theme.colorScheme.surface.withOpacity(0.75)
        : Colors.white.withOpacity(0.85);
    final tagTextStyle = theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: AppColors.primary,
        );
    final favoriteBackground = isDark
        ? theme.colorScheme.surface.withOpacity(0.75)
        : Colors.white.withOpacity(0.9);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 16,
    );
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _PathImage(imageUrl: imageUrl),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: labelBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                path.nameAr.isNotEmpty ? path.nameAr : path.name,
                style: titleStyle,
              ),
            ),
          ),
          if (tags.isNotEmpty)
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: tagBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              tag,
                              style: tagTextStyle,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          Positioned(
            top: 16,
            left: 16,
            child: InkWell(
              onTap: onFavorite,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: favoriteBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIcons.heart_straight_bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripSliderCard extends StatelessWidget {
  final TripModel trip;
  final List<String> tags;
  final VoidCallback onTap;

  const _TripSliderCard({
    required this.trip,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = trip.displayImage;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labelBackground = isDark
        ? theme.colorScheme.surface.withOpacity(0.85)
        : Colors.white.withOpacity(0.9);
    final tagBackground = isDark
        ? theme.colorScheme.surface.withOpacity(0.75)
        : Colors.white.withOpacity(0.85);
    final tagTextStyle = theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: AppColors.primary,
        );
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _PathImage(imageUrl: imageUrl),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: labelBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                trip.dateRange,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Text(
              trip.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 12,
                    color: Colors.black54,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (tags.isNotEmpty)
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: tagBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              tag,
                              style: tagTextStyle,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final PathModel path;
  final List<String> tags;
  final VoidCallback onTap;

  const _HighlightCard({
    required this.path,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        path.images.isNotEmpty ? path.images.first : 'assets/images/logo.png';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        theme.textTheme.bodySmall?.color?.withOpacity(0.7) ??
            Colors.white70;
    final reviewColor =
        theme.textTheme.bodySmall?.color?.withOpacity(0.6) ??
            Colors.white60;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(color: Colors.white.withOpacity(0.08))
              : null,
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: _PathImage(imageUrl: imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    path.nameAr.isNotEmpty ? path.nameAr : path.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        PhosphorIcons.map_pin,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          path.locationAr.isNotEmpty
                              ? path.locationAr
                              : path.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: secondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children:
                        tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        PhosphorIcons.star_fill,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        path.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${path.reviewCount})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: reviewColor,
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

class _PathImage extends StatelessWidget {
  final String imageUrl;

  const _PathImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/logo.png', fit: BoxFit.cover);
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) =>
              Image.asset('assets/images/logo.png', fit: BoxFit.cover),
    );
  }
}
