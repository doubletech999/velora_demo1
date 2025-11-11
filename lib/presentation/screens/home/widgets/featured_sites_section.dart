// lib/presentation/screens/home/widgets/featured_sites_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/path_model.dart';
import '../../../providers/paths_provider.dart';

/// قسم أبرز المواقع السياحية
class FeaturedSitesSection extends StatelessWidget {
  const FeaturedSitesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);

    return Consumer<PathsProvider>(
      builder: (context, pathsProvider, child) {
        // تحميل البيانات إذا لم تكن محملة
        if (!pathsProvider.initialized && !pathsProvider.isLoading) {
          Future.microtask(() => pathsProvider.loadPaths());
        }

        // جلب المواقع السياحية وترتيبها حسب التقييم
        final allSites = pathsProvider.sites;
        final featuredSites =
            allSites.toList()..sort((a, b) => b.rating.compareTo(a.rating));
        final topSites = featuredSites.take(5).toList();
        final isLoading = pathsProvider.isLoading && allSites.isEmpty;

        if (isLoading) {
          return Container(
            height: 220,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (topSites.isEmpty) {
          // إظهار رسالة بدلاً من إخفاء القسم
          return Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                localizations.get('no_sites_available'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = (screenWidth * 0.75).clamp(240.0, 330.0);
        final listHeight = cardWidth * 9 / 16 + 110;

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
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        PhosphorIcons.buildings,
                        color: AppColors.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.get('featured_sites'),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            localizations.get('best_sites_desc'),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/explore'),
                      child: Text(localizations.get('view_all')),
                    ),
                  ],
                ),
              ),
              if (pathsProvider.isLoading && topSites.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (topSites.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      localizations.get('no_sites_available'),
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
                    itemCount: topSites.length,
                    itemBuilder: (context, index) {
                      final site = topSites[index];
                      return _SiteCard(
                        path: site,
                        onTap: () => context.go('/paths/${site.id}'),
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

class _SiteCard extends StatelessWidget {
  final PathModel path;
  final VoidCallback onTap;

  const _SiteCard({required this.path, required this.onTap});

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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text(
                            path.rating.toStringAsFixed(1),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
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
}
