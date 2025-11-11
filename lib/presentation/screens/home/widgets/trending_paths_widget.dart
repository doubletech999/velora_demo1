import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/path_model.dart';
import '../../../providers/paths_provider.dart';

class TrendingPathsWidget extends StatefulWidget {
  const TrendingPathsWidget({super.key});

  @override
  State<TrendingPathsWidget> createState() => _TrendingPathsWidgetState();
}

class _TrendingPathsWidgetState extends State<TrendingPathsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // تحميل البيانات بعد انتهاء البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final pathsProvider = Provider.of<PathsProvider>(context, listen: false);
    pathsProvider.initializeIfNeeded();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
            Consumer<PathsProvider>(
              builder: (context, pathsProvider, child) {
                // التحقق من التهيئة أولاً
                if (!pathsProvider.initialized) {
                  // إذا لم تكن مهيأة، قم بالتهيئة
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    pathsProvider.initializeIfNeeded();
                  });
                }

                if (pathsProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (pathsProvider.error != null) {
                  return Center(
                    child: Text(
                      localizations.get('paths_loading_error'),
                      style: TextStyle(color: AppColors.error),
                    ),
                  );
                }

                final trendingPaths = pathsProvider.paths.take(3).toList();

                if (trendingPaths.isEmpty) {
                  return Center(
                    child: Text(localizations.get('no_paths_empty')),
                  );
                }

                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: trendingPaths.length,
                    itemBuilder: (context, index) {
                      final path = trendingPaths[index];
                      return _buildTrendingPathCard(path, index);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingPathCard(PathModel path, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.75).clamp(
      260.0,
      320.0,
    ); // Responsive width
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => context.go('/paths/${path.id}'),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // صورة المسار
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.asset(
                  path.images.isNotEmpty
                      ? path.images[0]
                      : 'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        PhosphorIcons.image,
                        color: Colors.grey,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),

              // تدرج شفاف
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

              // ترقيم المسار الشائع
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // معلومات المسار
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLocalizedName(path, context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            PhosphorIcons.map_pin,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getLocalizedLocation(path, context),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
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
                              final localizations = AppLocalizations.ofOrThrow(
                                context,
                              );
                              return Flexible(
                                child: _buildInfoChip(
                                  PhosphorIcons.clock,
                                  '${path.estimatedDuration.inHours} ${localizations.get('hours').substring(0, 1)}',
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Builder(
                            builder: (context) {
                              final localizations = AppLocalizations.ofOrThrow(
                                context,
                              );
                              return Flexible(
                                child: _buildInfoChip(
                                  PhosphorIcons.ruler,
                                  '${path.length} ${localizations.get('km')}',
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  PhosphorIcons.star_fill,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${path.rating}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
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
}
