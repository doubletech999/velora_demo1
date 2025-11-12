// lib/presentation/screens/paths/path_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/path_model.dart';
import '../../../data/models/trip_registration_model.dart';
import '../../providers/paths_provider.dart';
import '../../providers/saved_paths_provider.dart';
import '../../providers/trip_registration_provider.dart';
import '../../providers/reviews_provider.dart';
import '../../widgets/dialogs/trip_registration_dialog.dart';
import '../../widgets/dialogs/add_review_dialog.dart';
import '../../../core/utils/guest_guard.dart';
import '../../../data/models/review_model.dart';

class PathDetailsScreen extends StatefulWidget {
  final String pathId;

  const PathDetailsScreen({super.key, required this.pathId});

  @override
  State<PathDetailsScreen> createState() => _PathDetailsScreenState();
}

class _PathDetailsScreenState extends State<PathDetailsScreen>
    with SingleTickerProviderStateMixin {
  final PageController _imagePageController = PageController();
  bool _isDescriptionExpanded = false;
  PathModel? _path;
  bool _isLoading = true;
  bool _isBookablePath = true;
  bool _isSaved = false;
  List<TripRegistrationModel> _registeredTrips = [];

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut),
    );
    _loadPathDetails();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadPathDetails() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final pathsProvider = Provider.of<PathsProvider>(context, listen: false);
    final savedPathsProvider = Provider.of<SavedPathsProvider>(
      context,
      listen: false,
    );
    final tripProvider = Provider.of<TripRegistrationProvider>(
      context,
      listen: false,
    );
    final reviewsProvider = Provider.of<ReviewsProvider>(
      context,
      listen: false,
    );

    final path = pathsProvider.getPathById(widget.pathId);

    if (path != null) {
      final pathType = path.type?.toLowerCase();
      _isBookablePath = pathType != 'site';

      if (_isBookablePath) {
        await tripProvider.loadTrips();
        _registeredTrips = tripProvider.getTripsByPath(widget.pathId);
      } else {
        _registeredTrips = [];
      }

      // جلب التقييمات الفعلية من API
      // استخدام pathId كـ siteId لأن المسارات تُعامل كمواقع في API
      print('🔄 PathDetailsScreen: جلب التقييمات للمسار ${widget.pathId}');
      await reviewsProvider.fetchReviews(siteId: widget.pathId);
      await reviewsProvider.fetchReviewStats(siteId: widget.pathId);

      setState(() {
        _path = path;
        _isLoading = false;
        _isSaved = savedPathsProvider.isPathSaved(widget.pathId);
      });

      if (_isBookablePath) {
        _fabAnimationController.forward();
      }
    } else {
      if (mounted) {
        final localizations = AppLocalizations.ofOrThrow(context);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.get('path_not_found')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleSaved() {
    if (_path == null) return;

    if (!GuestGuard.check(context, feature: 'حفظ المسارات')) {
      return;
    }

    setState(() {
      _isSaved = !_isSaved;
    });

    final savedPathsProvider = Provider.of<SavedPathsProvider>(
      context,
      listen: false,
    );
    savedPathsProvider.toggleSavedPath(widget.pathId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSaved ? 'تم حفظ المسار' : 'تم إزالة المسار من المحفوظات',
        ),
        backgroundColor: _isSaved ? AppColors.success : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'تراجع',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _isSaved = !_isSaved;
            });
            savedPathsProvider.toggleSavedPath(widget.pathId);
          },
        ),
      ),
    );
  }

  void _showTripRegistrationDialog() {
    if (_path == null) return;

    if (!GuestGuard.check(context, feature: 'تسجيل الرحلة')) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => SimpleTripRegistrationDialog(
            path: _path!,
            onTripRegistered: () {
              _loadRegisteredTrips();
            },
          ),
    );
  }

  Future<void> _loadRegisteredTrips() async {
    final tripProvider = Provider.of<TripRegistrationProvider>(
      context,
      listen: false,
    );
    await tripProvider.loadTrips();
    final pathTrips = tripProvider.getTripsByPath(widget.pathId);
    setState(() {
      _registeredTrips = pathTrips;
    });
  }

  Future<void> _sharePath() async {
    if (_path == null) return;

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isArabic = languageProvider.isArabic;

    final String shareText = '''
🌟 ${isArabic ? 'اكتشف مسار رائع!' : 'Discover an amazing path!'}

📍 ${_getLocalizedName(context)}
${isArabic ? 'الموقع:' : 'Location:'} ${_getLocalizedLocation(context)}
📏 ${isArabic ? 'المسافة:' : 'Distance:'} ${_path!.length} ${isArabic ? 'كم' : 'km'}
⭐ ${isArabic ? 'التقييم:' : 'Rating:'} ${_path!.rating}/5

${isArabic ? _path!.descriptionAr : _path!.description}

#Velora #${isArabic ? 'استكشف_فلسطين' : 'DiscoverPalestine'} #${isArabic ? 'مغامرة' : 'Adventure'}
    ''';

    try {
      await Share.share(shareText);
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.ofOrThrow(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.get('share_error')}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final localizations = AppLocalizations.ofOrThrow(context);

    if (_isLoading || _path == null) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.get('path_details'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [_buildSliverAppBar(), _buildContentSliver()],
      ),
      floatingActionButton:
          _isBookablePath
              ? ScaleTransition(
                scale: _fabAnimation,
                child: FloatingActionButton.extended(
                  onPressed: _showTripRegistrationDialog,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  icon: const Icon(PhosphorIcons.clipboard_text),
                  label: Text(
                    localizations.get('register_for_trip'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
              : null,
      floatingActionButtonLocation:
          _isBookablePath ? FloatingActionButtonLocation.centerFloat : null,
    );
  }

  Widget _buildSliverAppBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(PhosphorIcons.caret_left),
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isSaved
                  ? PhosphorIcons.bookmark_simple_fill
                  : PhosphorIcons.bookmark_simple,
              color: _isSaved ? AppColors.primary : AppColors.primary,
            ),
            onPressed: _toggleSaved,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(PhosphorIcons.share),
            color: AppColors.primary,
            onPressed: _sharePath,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            _path!.images.isNotEmpty
                ? PageView.builder(
                  controller: _imagePageController,
                  itemCount: _path!.images.length,
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: 'path-image-${_path!.id}',
                      child: Image.asset(
                        _path!.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(PhosphorIcons.image, size: 48),
                          );
                        },
                      ),
                    );
                  },
                )
                : Container(
                  color: Colors.grey[200],
                  child: const Icon(PhosphorIcons.image, size: 48),
                ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),
            if (_path!.images.length > 1)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _imagePageController,
                    count: _path!.images.length,
                    effect: WormEffect(
                      dotColor: Colors.white.withOpacity(0.5),
                      activeDotColor: Colors.white,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 16,
              right: 16,
              child: Builder(
                builder: (context) {
                  final localizations = AppLocalizations.ofOrThrow(context);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(
                        _path!.difficulty,
                      ).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDifficultyIcon(_path!.difficulty),
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getDifficultyText(_path!.difficulty, localizations),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
                    _getLocalizedName(context),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        PhosphorIcons.map_pin,
                        size: 18,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _getLocalizedLocation(context),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
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

  Widget _buildContentSliver() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCards(),
            const SizedBox(height: 24),
            if (_isBookablePath && _registeredTrips.isNotEmpty) ...[
              _buildRegisteredTripsSection(),
              const SizedBox(height: 24),
            ],
            _buildDescription(),
            const SizedBox(height: 24),
            _buildMiniMap(),
            const SizedBox(height: 24),
            _buildActivities(),
            const SizedBox(height: 24),
            _buildGuide(),
            const SizedBox(height: 24),
            _buildWarnings(),
            const SizedBox(height: 24),
            _buildRatingSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisteredTripsSection() {
    final localizations = AppLocalizations.ofOrThrow(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIcons.clipboard_text,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.get('registration_requests'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _registeredTrips.length == 1
                          ? localizations
                              .get('registered_requests_count')
                              .replaceAll(
                                '{count}',
                                _registeredTrips.length.toString(),
                              )
                          : localizations
                              .get('registered_requests_count_plural')
                              .replaceAll(
                                '{count}',
                                _registeredTrips.length.toString(),
                              ),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _showRegisteredTripsBottomSheet,
                child: Text(localizations.get('view_all')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _registeredTrips.take(3).length,
              itemBuilder: (context, index) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                final trip = _registeredTrips[index];
                final screenWidth = MediaQuery.of(context).size.width;
                final cardWidth = (screenWidth * 0.6).clamp(
                  200.0,
                  280.0,
                ); // Responsive width
                return Container(
                  width: cardWidth,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              trip.organizerName.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.organizerName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  trip.organizerPhone,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.users,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${trip.numberOfParticipants} ${trip.numberOfParticipants == 1 ? 'شخص' : 'أشخاص'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.calendar,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${trip.createdAt.day}/${trip.createdAt.month}/${trip.createdAt.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(trip.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trip.status.displayNameAr,
                          style: TextStyle(
                            fontSize: 10,
                            color: _getStatusColor(trip.status),
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  Widget _buildInfoCards() {
    final localizations = AppLocalizations.ofOrThrow(context);

    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: PhosphorIcons.ruler,
            title: localizations.get('distance'),
            value: '${_path!.length} ${localizations.get('km')}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: PhosphorIcons.clock,
            title: localizations.get('duration'),
            value:
                '${_path!.estimatedDuration.inHours} ${localizations.get('hours')}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: PhosphorIcons.star,
            title: localizations.get('rating'),
            value: '${_path!.rating}',
            subtitle: '(${_path!.reviewCount})',
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final localizations = AppLocalizations.ofOrThrow(context);
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.get('description'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              child: Text(
                _isDescriptionExpanded
                    ? localizations.get('show_less')
                    : localizations.get('show_more'),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          languageProvider.isArabic ? _path!.descriptionAr : _path!.description,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: _isDescriptionExpanded ? null : 3,
          overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMiniMap() {
    final localizations = AppLocalizations.ofOrThrow(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.get('map'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
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
            child:
                _path!.coordinates.isNotEmpty
                    ? FlutterMap(
                      options: MapOptions(
                        initialCenter: _path!.coordinates.first,
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.velora',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _path!.coordinates,
                              color: AppColors.primary,
                              strokeWidth: 4.0,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            if (_path!.coordinates.isNotEmpty) ...[
                              Marker(
                                point: _path!.coordinates.first,
                                width: 40,
                                height: 40,
                                child: Icon(
                                  PhosphorIcons.map_pin_fill,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                              ),
                              if (_path!.coordinates.length > 1)
                                Marker(
                                  point: _path!.coordinates.last,
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    PhosphorIcons.flag_fill,
                                    color: AppColors.secondary,
                                    size: 30,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ],
                    )
                    : Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Text(localizations.get('no_coordinates')),
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () {
              context.go('/map');
            },
            icon: const Icon(PhosphorIcons.map_trifold),
            label: Text(localizations.get('show_full_map')),
          ),
        ),
      ],
    );
  }

  Widget _buildActivities() {
    final localizations = AppLocalizations.ofOrThrow(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.get('available_activities'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _path!.activities.map((activity) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getActivityColor(activity).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getActivityColor(activity).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getActivityIcon(activity),
                        size: 18,
                        color: _getActivityColor(activity),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getActivityText(activity, localizations),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _getActivityColor(activity),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildGuide() {
    final localizations = AppLocalizations.ofOrThrow(context);
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final guide = _path!.guide; // All routes have guides

    final guideName =
        languageProvider.isArabic
            ? (guide.nameAr ?? guide.name ?? '')
            : (guide.name ?? guide.nameAr ?? '');

    final guideBio =
        languageProvider.isArabic
            ? (guide.bioAr ?? guide.bio ?? '')
            : (guide.bio ?? guide.bioAr ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(PhosphorIcons.user_circle, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              localizations.get('trip_guide'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guide Name and Image
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child:
                        guide.imageUrl != null && guide.imageUrl!.isNotEmpty
                            ? ClipOval(
                              child: Image.network(
                                guide.imageUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    PhosphorIcons.user,
                                    color: AppColors.primary,
                                    size: 30,
                                  );
                                },
                              ),
                            )
                            : Icon(
                              PhosphorIcons.user,
                              color: AppColors.primary,
                              size: 30,
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (guideName.isNotEmpty)
                          Text(
                            guideName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        if (guide.rating != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                PhosphorIcons.star_fill,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                guide.rating!.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (guide.reviewCount != null) ...[
                                Text(
                                  ' (${guide.reviewCount})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (guideBio.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  guideBio,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
              const SizedBox(height: 16),
              // Guide Details
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  Builder(
                    builder: (context) {
                      final localizations = AppLocalizations.ofOrThrow(context);
                      return Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          if (guide.languages != null &&
                              guide.languages!.isNotEmpty)
                            _buildGuideInfoItem(
                              PhosphorIcons.translate,
                              localizations.get('languages'),
                              guide.languages!,
                            ),
                          if (guide.phone != null && guide.phone!.isNotEmpty)
                            _buildGuideInfoItem(
                              PhosphorIcons.phone,
                              localizations.get('phone_label'),
                              guide.phone!,
                            ),
                          _buildGuideInfoItem(
                            PhosphorIcons.currency_dollar,
                            localizations.get('route_price'),
                            '${guide.routePrice?.toStringAsFixed(0) ?? _path!.price.toStringAsFixed(0)} ${localizations.get('shekel')}',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuideInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildWarnings() {
    final localizations = AppLocalizations.ofOrThrow(context);
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.get('warnings_and_tips'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...(languageProvider.isArabic ? _path!.warningsAr : _path!.warnings)
            .map((warning) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      PhosphorIcons.warning,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.warning.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ],
    );
  }

  Widget _buildRatingSection() {
    final localizations = AppLocalizations.ofOrThrow(context);

    return Consumer<ReviewsProvider>(
      builder: (context, reviewsProvider, child) {
        // جلب التقييمات الفعلية - تحويل pathId إلى String للمقارنة
        final pathIdStr = widget.pathId.toString();
        final reviews =
            reviewsProvider.reviews.where((review) {
              // المقارنة مع siteId كـ String أو int
              final reviewSiteId = review.siteId?.toString() ?? '';
              return reviewSiteId == pathIdStr || reviewSiteId == widget.pathId;
            }).toList();

        print(
          '📊 PathDetailsScreen: عدد التقييمات المستخرجة: ${reviews.length}',
        );
        print('   pathId: ${widget.pathId}');
        print(
          '   جميع التقييمات في Provider: ${reviewsProvider.reviews.length}',
        );
        if (reviewsProvider.reviews.isNotEmpty) {
          print(
            '   أول siteId في التقييمات: ${reviewsProvider.reviews.first.siteId}',
          );
        }

        // حساب متوسط التقييمات من التقييمات الفعلية
        double averageRating = 0.0;
        if (reviews.isNotEmpty) {
          final totalRating = reviews.fold<double>(
            0.0,
            (sum, review) => sum + review.rating,
          );
          averageRating = totalRating / reviews.length;
          print('   متوسط التقييم: $averageRating');
        } else {
          // إذا لم تكن هناك تقييمات، استخدم rating من PathModel
          averageRating = _path?.rating ?? 0.0;
          print('   استخدام rating من PathModel: $averageRating');
        }

        final reviewCount =
            reviews.isNotEmpty ? reviews.length : (_path?.reviewCount ?? 0);
        print('   عدد التقييمات: $reviewCount');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.get('reviews'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (reviews.isNotEmpty)
                  TextButton.icon(
                    onPressed:
                        _path == null
                            ? null
                            : () {
                              final route =
                                  '/reviews/${_path!.id}?pathName=${Uri.encodeComponent(_getLocalizedName(context))}';
                              debugPrint('Navigating to: $route');
                              context.push(route);
                            },
                    icon: const Icon(PhosphorIcons.chat_circle_text),
                    label: Text(localizations.get('view_all')),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < averageRating.floor()
                                ? PhosphorIcons.star_fill
                                : (index == averageRating.floor() &&
                                    averageRating % 1 > 0)
                                ? PhosphorIcons.star_half
                                : PhosphorIcons.star,
                            color: Colors.amber,
                            size: 24,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$reviewCount ${localizations.get('reviews')}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    if (!GuestGuard.check(
                      context,
                      feature: 'إضافة التقييمات',
                    )) {
                      return;
                    }
                    showDialog(
                      context: context,
                      builder:
                          (context) => AddReviewDialog(
                            siteId: _path!.id,
                            pathName: _getLocalizedName(context),
                          ),
                    ).then((_) {
                      // إعادة جلب التقييمات بعد إضافة تقييم جديد
                      print(
                        '🔄 PathDetailsScreen: إعادة جلب التقييمات بعد إضافة تقييم جديد',
                      );
                      reviewsProvider.fetchReviews(siteId: widget.pathId);
                      reviewsProvider.fetchReviewStats(siteId: widget.pathId);
                      setState(() {}); // إعادة بناء الواجهة
                    });
                  },
                  icon: const Icon(PhosphorIcons.pencil_simple, size: 16),
                  label: Text(
                    localizations.get('add_review'),
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(100, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            // عرض قائمة التقييمات الفعلية (أول 3 تقييمات)
            if (reviews.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...reviews.take(3).map((review) => _buildReviewItem(review)),
              if (reviews.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: () {
                      final route =
                          '/reviews/${_path!.id}?pathName=${Uri.encodeComponent(_getLocalizedName(context))}';
                      context.push(route);
                    },
                    child: Text(
                      '${localizations.get('view_all')} (${reviews.length})',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
            ] else if (reviewCount == 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'لا توجد تقييمات بعد',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // صورة المستخدم (أو أيقونة)
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(
                  PhosphorIcons.user,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'مجهول',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating
                              ? PhosphorIcons.star_fill
                              : PhosphorIcons.star,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks ${weeks == 1 ? 'أسبوع' : 'أسابيع'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months ${months == 1 ? 'شهر' : 'أشهر'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years ${years == 1 ? 'سنة' : 'سنوات'}';
    }
  }

  void _showRegisteredTripsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final localizations = AppLocalizations.ofOrThrow(context);
                    final pathName = _getLocalizedName(context);
                    return Text(
                      localizations
                          .get('registration_requests_for_path')
                          .replaceAll('{path}', pathName),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _registeredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = _registeredTrips[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _showTripDetailsDialog(trip),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // الصورة الرمزية
                                CircleAvatar(
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.1),
                                  radius: 20,
                                  child: Text(
                                    trip.organizerName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // المحتوى الأساسي
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // الاسم
                                      Text(
                                        trip.organizerName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 6),
                                      // الهاتف
                                      Text(
                                        '📞 ${trip.organizerPhone}',
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 3),
                                      // البريد
                                      Text(
                                        '📧 ${trip.organizerEmail}',
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 3),
                                      // عدد الأشخاص
                                      Builder(
                                        builder: (context) {
                                          final localizations =
                                              AppLocalizations.ofOrThrow(
                                                context,
                                              );
                                          return Text(
                                            '👥 ${trip.numberOfParticipants} ${trip.numberOfParticipants == 1 ? localizations.get('person') : localizations.get('persons')}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // الحالة
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      trip.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    trip.status.displayNameAr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getStatusColor(trip.status),
                                      fontWeight: FontWeight.bold,
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
                ),
              ],
            ),
          ),
    );
  }

  void _showTripDetailsDialog(TripRegistrationModel trip) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              AppLocalizations.ofOrThrow(context).get('request_details'),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (context) {
                      final localizations = AppLocalizations.ofOrThrow(context);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDetailRow(
                            localizations.get('name_label'),
                            trip.organizerName,
                          ),
                          _buildDetailRow(
                            localizations.get('phone'),
                            trip.organizerPhone,
                          ),
                          _buildDetailRow(
                            localizations.get('email'),
                            trip.organizerEmail,
                          ),
                          _buildDetailRow(
                            localizations.get('number_of_participants_label'),
                            '${trip.numberOfParticipants} ${trip.numberOfParticipants == 1 ? localizations.get('person') : localizations.get('persons')}',
                          ),
                          _buildDetailRow(
                            localizations.get('registration_date_label'),
                            '${trip.createdAt.day}/${trip.createdAt.month}/${trip.createdAt.year}',
                          ),
                          if (trip.notes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              localizations.get('notes'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(trip.notes),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                localizations.get('status_label'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    trip.status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  trip.status.displayNameAr,
                                  style: TextStyle(
                                    color: _getStatusColor(trip.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              Builder(
                builder: (context) {
                  final localizations = AppLocalizations.ofOrThrow(context);
                  return TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(localizations.get('close')),
                  );
                },
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // Helper methods
  String _getDifficultyText(
    DifficultyLevel difficulty,
    AppLocalizations localizations,
  ) {
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

  IconData _getDifficultyIcon(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return PhosphorIcons.heart_straight;
      case DifficultyLevel.medium:
        return PhosphorIcons.lightning;
      case DifficultyLevel.hard:
        return PhosphorIcons.warning;
    }
  }

  String _getActivityText(
    ActivityType activity,
    AppLocalizations localizations,
  ) {
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

  IconData _getActivityIcon(ActivityType activity) {
    switch (activity) {
      case ActivityType.hiking:
        return PhosphorIcons.person_simple_walk;
      case ActivityType.camping:
        return PhosphorIcons.campfire;
      case ActivityType.climbing:
        return PhosphorIcons.mountains;
      case ActivityType.religious:
        return PhosphorIcons.star;
      case ActivityType.cultural:
        return PhosphorIcons.book_open;
      case ActivityType.nature:
        return PhosphorIcons.tree;
      case ActivityType.archaeological:
        return PhosphorIcons.buildings;
    }
  }

  Color _getActivityColor(ActivityType activity) {
    switch (activity) {
      case ActivityType.hiking:
        return Colors.green;
      case ActivityType.camping:
        return Colors.orange;
      case ActivityType.climbing:
        return Colors.red;
      case ActivityType.religious:
        return Colors.purple;
      case ActivityType.cultural:
        return Colors.blue;
      case ActivityType.nature:
        return Colors.teal;
      case ActivityType.archaeological:
        return Colors.brown;
    }
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return AppColors.warning;
      case TripStatus.approved:
        return AppColors.success;
      case TripStatus.rejected:
        return AppColors.error;
      case TripStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getLocalizedName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? _path!.nameAr : _path!.name;
  }

  String _getLocalizedLocation(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? _path!.locationAr : _path!.location;
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}
