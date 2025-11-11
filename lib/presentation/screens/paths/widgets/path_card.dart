// path_card.dart - نسخة محدثة

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/path_model.dart';
import '../../../../core/utils/responsive_utils.dart';

class PathCard extends StatelessWidget {
  final PathModel path;
  final VoidCallback? onTap;
  final bool isFeatured;

  const PathCard({
    super.key,
    required this.path,
    this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: GestureDetector(
        onTap: onTap ?? () => context.go('/paths/${path.id}'),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: isFeatured ? 6 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المسار مع تراكب تدرج اللون
              Stack(
                children: [
                  Hero(
                    tag: 'path-image-${path.id}',
                    child: SizedBox(
                      height: isFeatured ? 180 : 160,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: _buildImage(
                          path.images.isNotEmpty
                              ? path.images[0]
                              : 'assets/images/logo.png',
                        ),
                      ),
                    ),
                  ),

                  // تراكب تدرج لتحسين قراءة النص
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

                  // مستوى الصعوبة (عند الزاوية العلوية)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(
                          path.difficulty,
                        ).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getDifficultyIcon(path.difficulty),
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getDifficultyText(path.difficulty, context),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // المعلومات المهمة (على الصورة في الأسفل)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // اسم المسار
                          Text(
                            _getLocalizedName(context),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // الموقع
                          Row(
                            children: [
                              const Icon(
                                PhosphorIcons.map_pin,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _getLocalizedLocation(context),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
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

                  // أيقونة المفضلة
                  if (isFeatured)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          PhosphorIcons.star_fill,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              // تفاصيل المسار
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات المسار (وقت، مسافة، تقييم)
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                PhosphorIcons.clock,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Builder(
                                builder: (context) {
                                  final localizations =
                                      AppLocalizations.ofOrThrow(context);
                                  return Text(
                                    '${path.estimatedDuration.inHours} ${localizations.get('hours')}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                PhosphorIcons.ruler,
                                size: 16,
                                color: AppColors.tertiary,
                              ),
                              const SizedBox(width: 4),
                              Builder(
                                builder: (context) {
                                  final localizations =
                                      AppLocalizations.ofOrThrow(context);
                                  return Text(
                                    '${path.length} ${localizations.get('km')}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              PhosphorIcons.star_fill,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${path.rating}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '(${path.reviewCount})',
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // أنواع الأنشطة
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          path.activities.take(3).map((activity) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getActivityColor(
                                  activity,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getActivityIcon(activity),
                                    size: 14,
                                    color: _getActivityColor(activity),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getActivityText(activity, context),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: _getActivityColor(activity),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 12),

                    // السعر واسم المرشد
                    Row(
                      children: [
                        // اسم المرشد - عرض دائماً
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIcons.user,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    final locale = Localizations.localeOf(
                                      context,
                                    );
                                    final guideName =
                                        locale.languageCode == 'ar'
                                            ? (path.guide.nameAr ??
                                                path.guide.name ??
                                                'مرشد')
                                            : (path.guide.name ??
                                                path.guide.nameAr ??
                                                'Guide');

                                    return Text(
                                      guideName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // السعر
                        if (path.price > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.currency_dollar,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${path.price.toStringAsFixed(0)} ₪',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
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
      ),
    );
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

  String _getLocalizedName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? path.nameAr : path.name;
  }

  String _getLocalizedLocation(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? path.locationAr : path.location;
  }

  Widget _buildImage(String imagePath) {
    // التحقق إذا كانت الصورة URL أو asset
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Network Image
      return Image.network(
        imagePath,
        width: double.infinity,
        height: isFeatured ? 180 : 160,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: isFeatured ? 180 : 160,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          return Container(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            child: Icon(
              PhosphorIcons.image,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              size: 48,
            ),
          );
        },
      );
    } else {
      // Asset Image
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: isFeatured ? 180 : 160,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          return Container(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            child: Icon(
              PhosphorIcons.image,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              size: 48,
            ),
          );
        },
      );
    }
  }
}
