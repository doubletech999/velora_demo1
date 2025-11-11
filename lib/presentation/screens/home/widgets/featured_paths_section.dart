import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/path_model.dart';
import '../../../providers/paths_provider.dart';

class FeaturedPathsSection extends StatelessWidget {
  const FeaturedPathsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    
    return Consumer<PathsProvider>(
      builder: (context, pathsProvider, child) {
        final featuredPaths = pathsProvider.featuredPaths;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.get('featured_paths'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.go('/paths'),
                    child: Text(localizations.get('view_all')),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: featuredPaths.length,
                itemBuilder: (context, index) {
                  final path = featuredPaths[index];
                  return _FeaturedPathCard(
                    path: path,
                    onTap: () => context.go('/path/${path.id}'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FeaturedPathCard extends StatelessWidget {
  final dynamic path;
  final VoidCallback onTap;

  const _FeaturedPathCard({
    required this.path,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.75).clamp(260.0, 320.0); // Responsive width
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(left: 16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: path.images[0],
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
              Padding(
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.ofOrThrow(context);
                            return _InfoChip(
                              icon: Icons.timer,
                              label: '${path.estimatedDuration.inHours} ${localizations.get('hours')}',
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.ofOrThrow(context);
                            return _InfoChip(
                              icon: Icons.trending_up,
                              label: _getDifficultyText(path.difficulty, localizations),
                              color: _getDifficultyColor(path.difficulty),
                            );
                          },
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

  String _getLocalizedName(PathModel path, BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? path.nameAr : path.name;
  }
  
  String _getLocalizedLocation(PathModel path, BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? path.locationAr : path.location;
  }
  
  String _getDifficultyText(DifficultyLevel difficulty, AppLocalizations localizations) {
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

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}