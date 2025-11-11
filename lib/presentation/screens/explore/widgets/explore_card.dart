// explore_card.dart - نسخة محدثة

import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/path_model.dart';

class ExploreCard extends StatelessWidget {
  final PathModel path;
  final VoidCallback? onTap;

  const ExploreCard({super.key, required this.path, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.go('/paths/${path.id}'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final imageWidth =
              isCompact
                  ? constraints.maxWidth
                  : (constraints.maxWidth * 0.35).clamp(120.0, 180.0);
          final imageHeight = isCompact ? imageWidth * 0.6 : 190.0;

          Widget buildInfo() {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _getLocalizedName(context),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(
                            path.difficulty,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getDifficultyText(path.difficulty, context),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getDifficultyColor(path.difficulty),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.map_pin,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _getLocalizedLocation(context),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final localizations = AppLocalizations.ofOrThrow(context);
                      return Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildStatItem(
                            icon: PhosphorIcons.ruler,
                            value: '${path.length}',
                            unit: localizations.get('km'),
                          ),
                          _buildStatItem(
                            icon: PhosphorIcons.clock,
                            value: '${path.estimatedDuration.inHours}',
                            unit: localizations.get('hours'),
                          ),
                          _buildStatItem(
                            icon: PhosphorIcons.star,
                            value: '${path.rating.toStringAsFixed(1)}',
                            unit: '(${path.reviewCount})',
                            color: Colors.amber,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          path.activities.take(3).map((activity) {
                            return Container(
                              margin: const EdgeInsetsDirectional.only(end: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getActivityColor(
                                  activity,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getActivityIcon(activity),
                                    size: 12,
                                    color: _getActivityColor(activity),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getActivityText(activity, context),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _getActivityColor(activity),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }

          return Card(
            clipBehavior: Clip.antiAlias,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                isCompact
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: _buildImage(
                            path.images.isNotEmpty
                                ? path.images[0]
                                : 'assets/images/logo.png',
                            width: imageWidth,
                            height: imageHeight,
                          ),
                        ),
                        buildInfo(),
                      ],
                    )
                    : SizedBox(
                      height: imageHeight,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: _buildImage(
                              path.images.isNotEmpty
                                  ? path.images[0]
                                  : 'assets/images/logo.png',
                              width: imageWidth,
                              height: imageHeight,
                            ),
                          ),
                          Expanded(child: buildInfo()),
                        ],
                      ),
                    ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String unit,
    Color? color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  String _getLocalizedName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? path.nameAr : path.name;
  }

  String _getLocalizedLocation(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? path.locationAr : path.location;
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

  Widget _buildImage(
    String imagePath, {
    required double width,
    required double height,
  }) {
    // التحقق إذا كانت الصورة URL أو asset
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Network Image
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
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
          return _buildFallbackImage(width, height);
        },
      );
    } else {
      // Asset Image
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage(width, height);
        },
      );
    }
  }

  Widget _buildFallbackImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(PhosphorIcons.image, color: Colors.grey, size: 40),
      ),
    );
  }
}
