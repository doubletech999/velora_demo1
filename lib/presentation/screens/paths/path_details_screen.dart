// lib/presentation/screens/paths/path_details_screen.dart - مُصحح
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/path_model.dart';
import '../../providers/paths_provider.dart';
import '../../providers/saved_paths_provider.dart';
import '../../widgets/common/custom_app_bar.dart';

class PathDetailsScreen extends StatefulWidget {
  final String pathId;

  const PathDetailsScreen({super.key, required this.pathId});

  @override
  State<PathDetailsScreen> createState() => _PathDetailsScreenState();
}

class _PathDetailsScreenState extends State<PathDetailsScreen> {
  final PageController _imagePageController = PageController();
  int _currentImagePage = 0;
  bool _isDescriptionExpanded = false;
  PathModel? _path; // جعلها nullable
  bool _isLoading = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadPathDetails();
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

    final path = pathsProvider.getPathById(widget.pathId);

    if (path != null) {
      setState(() {
        _path = path;
        _isLoading = false;
        _isSaved = savedPathsProvider.isPathSaved(widget.pathId);
      });
    } else {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على المسار'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleSaved() {
    if (_path == null) return;

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

  void _startJourney() {
    if (_path == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(PhosphorIcons.map_pin, color: AppColors.primary, size: 28),
                const SizedBox(width: 8),
                const Text('بدء الرحلة'),
              ],
            ),
            content: SingleChildScrollView(
              // إضافة ScrollView للحوار
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'هل أنت مستعد لبدء رحلتك إلى ${_path!.nameAr}؟',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
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
                      children: [
                        Icon(
                          PhosphorIcons.info,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تأكد من أن لديك إنترنت وبطارية كافية لتتبع الرحلة',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('المسافة:'),
                            Text(
                              '${_path!.length} كم',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الوقت المتوقع:'),
                            Text(
                              '${_path!.estimatedDuration.inHours} ساعات',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الصعوبة:'),
                            Text(
                              _getDifficultyText(_path!.difficulty),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getDifficultyColor(_path!.difficulty),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/journey/${_path!.id}');
                },
                icon: const Icon(PhosphorIcons.play),
                label: const Text('ابدأ الآن'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);

    if (_isLoading || _path == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المسار')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // شريط التطبيق
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                shape: BoxShape.circle,
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
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
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
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(PhosphorIcons.share),
                  color: AppColors.primary,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ميزة المشاركة قريباً...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // عرض شرائح الصور
                  _path!.images.isNotEmpty
                      ? PageView.builder(
                        controller: _imagePageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImagePage = index;
                          });
                        },
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
                                  child: const Icon(
                                    PhosphorIcons.image,
                                    size: 48,
                                  ),
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

                  // تراكب تدرج
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

                  // مؤشر الصفحات
                  if (_path!.images.length > 1)
                    Positioned(
                      bottom: 16,
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

                  // مستوى الصعوبة
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(
                          _path!.difficulty,
                        ).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
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
                            _getDifficultyText(_path!.difficulty),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

          // محتوى الصفحة
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان والموقع
                  Text(
                    _path!.nameAr,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.map_pin,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        // إضافة Expanded هنا
                        child: Text(
                          _path!.locationAr,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // بطاقات المعلومات
                  _buildInfoCards(),
                  const SizedBox(height: 24),

                  // الوصف
                  _buildDescription(),
                  const SizedBox(height: 24),

                  // الخريطة المصغرة
                  _buildMiniMap(),
                  const SizedBox(height: 24),

                  // الأنشطة
                  _buildActivities(),
                  const SizedBox(height: 24),

                  // التحذيرات
                  _buildWarnings(),
                  const SizedBox(height: 24),

                  // التقييمات
                  _buildRatingSection(),
                  const SizedBox(height: 32),

                  // زر بدء الرحلة
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _startJourney,
                      icon: const Icon(PhosphorIcons.map_trifold),
                      label: const Text(
                        'ابدأ الرحلة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: PhosphorIcons.ruler,
            title: 'المسافة',
            value: '${_path!.length} كم',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: PhosphorIcons.clock,
            title: 'المدة',
            value: '${_path!.estimatedDuration.inHours} ساعات',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: PhosphorIcons.star,
            title: 'التقييم',
            value: '${_path!.rating}',
            subtitle: '(${_path!.reviewCount})',
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الوصف', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              child: Text(
                _isDescriptionExpanded ? 'عرض أقل' : 'عرض المزيد',
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
          _path!.descriptionAr,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: _isDescriptionExpanded ? null : 3,
          overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMiniMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الخريطة', style: Theme.of(context).textTheme.titleLarge),
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
                      child: const Center(
                        child: Text('لا توجد إحداثيات للمسار'),
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
            label: const Text('عرض الخريطة بشكل كامل'),
          ),
        ),
      ],
    );
  }

  Widget _buildActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الأنشطة المتاحة', style: Theme.of(context).textTheme.titleLarge),
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
                        _getActivityText(activity),
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

  Widget _buildWarnings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تحذيرات وإرشادات', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ..._path!.warningsAr.map((warning) {
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
                Icon(PhosphorIcons.warning, color: AppColors.warning, size: 20),
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
        }).toList(),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('التقييمات', style: Theme.of(context).textTheme.titleLarge),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ميزة التقييمات قريباً...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(PhosphorIcons.chat_circle_text),
              label: const Text('عرض الكل'),
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
                  '${_path!.rating}',
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
                        index < _path!.rating.floor()
                            ? PhosphorIcons.star_fill
                            : (index == _path!.rating.floor() &&
                                _path!.rating % 1 > 0)
                            ? PhosphorIcons.star_half
                            : PhosphorIcons.star,
                        color: Colors.amber,
                        size: 24,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_path!.reviewCount} تقييم',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ميزة إضافة التقييم قريباً...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(PhosphorIcons.pencil_simple, size: 16),
              label: const Text('أضف تقييمك', style: TextStyle(fontSize: 12)),
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
      ],
    );
  }

  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'سهل';
      case DifficultyLevel.medium:
        return 'متوسط';
      case DifficultyLevel.hard:
        return 'صعب';
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

  String _getActivityText(ActivityType activity) {
    switch (activity) {
      case ActivityType.hiking:
        return 'المشي';
      case ActivityType.camping:
        return 'التخييم';
      case ActivityType.climbing:
        return 'التسلق';
      case ActivityType.religious:
        return 'ديني';
      case ActivityType.cultural:
        return 'ثقافي';
      case ActivityType.nature:
        return 'طبيعة';
      case ActivityType.archaeological:
        return 'أثري';
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
