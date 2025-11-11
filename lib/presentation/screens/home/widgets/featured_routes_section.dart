// lib/presentation/screens/home/widgets/featured_routes_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/path_model.dart';
import '../../../providers/paths_provider.dart';

/// قسم أبرز المسارات والتخييمات
class FeaturedRoutesSection extends StatelessWidget {
  const FeaturedRoutesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);

    return Consumer<PathsProvider>(
      builder: (context, pathsProvider, child) {
        // تحميل البيانات إذا لم تكن محملة
        if (!pathsProvider.initialized && !pathsProvider.isLoading) {
          Future.microtask(() => pathsProvider.loadPaths());
        }

        // جلب المسارات والتخييمات المميزة
        final featuredRoutes = pathsProvider.featuredPaths;
        final isLoading = pathsProvider.isLoading && featuredRoutes.isEmpty;

        if (isLoading) {
          return Container(
            height: 220,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (featuredRoutes.isEmpty) {
          // إظهار رسالة بدلاً من إخفاء القسم
          return Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                localizations.get('no_routes_available'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = (screenWidth * 0.75).clamp(240.0, 330.0);
        final listHeight = cardWidth * 9 / 16 + 120;

        return Container(
          margin: const EdgeInsets.only(top: 8, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        PhosphorIcons.map_pin,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.get('featured_routes'),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            localizations.get('best_routes_desc'),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/paths'),
                      child: Text(localizations.get('view_all')),
                    ),
                  ],
                ),
              ),
              if (pathsProvider.isLoading && featuredRoutes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (featuredRoutes.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      localizations.get('no_routes_available'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: listHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        featuredRoutes.length > 5 ? 5 : featuredRoutes.length,
                    itemBuilder: (context, index) {
                      final route = featuredRoutes[index];
                      return _RouteCard(
                        path: route,
                        onTap: () => context.go('/paths/${route.id}'),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RouteCard extends StatelessWidget {
  final PathModel path;
  final VoidCallback onTap;

  const _RouteCard({required this.path, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.75).clamp(240.0, 330.0);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        child: Card(
          margin: const EdgeInsetsDirectional.only(end: 12, top: 4, bottom: 4),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildImage(
                  path.images.isNotEmpty
                      ? path.images[0]
                      : 'assets/images/logo.png',
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLocalizedName(path, context),
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getLocalizedLocation(path, context),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Builder(
                        builder: (context) {
                          final localizations = AppLocalizations.ofOrThrow(
                            context,
                          );
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoChip(
                                icon: Icons.timer,
                                label:
                                    '${path.estimatedDuration.inHours} ${localizations.get('hours')}',
                              ),
                              _InfoChip(
                                icon: Icons.trending_up,
                                label: _getDifficultyText(
                                  path.difficulty,
                                  localizations,
                                ),
                                color: _getDifficultyColor(path.difficulty),
                              ),
                            ],
                          );
                        },
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
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          );
        },
      );
    }
  }

  String _getLocalizedName(PathModel path, BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? path.nameAr : path.name;
  }

  String _getLocalizedLocation(PathModel path, BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? path.locationAr : path.location;
  }

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
        return AppColors.success;
      case DifficultyLevel.medium:
        return AppColors.warning;
      case DifficultyLevel.hard:
        return AppColors.error;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color ?? AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
