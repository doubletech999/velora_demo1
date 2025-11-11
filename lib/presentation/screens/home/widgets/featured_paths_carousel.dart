// featured_paths_carousel.dart - نسخة محدثة

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/path_model.dart';

class FeaturedPathsCarousel extends StatelessWidget {
  final List<PathModel> paths;

  const FeaturedPathsCarousel({
    super.key,
    required this.paths,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: paths.length,
        itemBuilder: (context, index) {
          final path = paths[index];
          return _FeaturedPathCard(
            path: path,
            isFirst: index == 0,
            onTap: () => context.go('/paths/${path.id}'),
          );
        },
      ),
    );
  }
}

class _FeaturedPathCard extends StatelessWidget {
  final PathModel path;
  final bool isFirst;
  final VoidCallback onTap;

  const _FeaturedPathCard({
    required this.path,
    this.isFirst = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final cardWidth = (screenWidth * 0.75).clamp(260.0, 320.0); // Responsive width
          return Container(
            width: cardWidth,
            margin: EdgeInsets.only(right: 16, top: isFirst ? 0 : 8, bottom: isFirst ? 8 : 0),
            child: Stack(
              children: [
            // بطاقة خلفية لتأثير التظليل
            if (isFirst)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
            
            // البطاقة الرئيسية
            Container(
              height: 240,
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
                child: Stack(
                  children: [
                    // صورة المسار
                    Hero(
                      tag: 'path-image-${path.id}',
                      child: Image.asset(
                        path.images.isNotEmpty ? path.images[0] : 'assets/images/logo.png',
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 240,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                PhosphorIcons.image,
                                color: Colors.grey,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // تدرج شفاف للصورة لتحسين قراءة النص
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
                    
                    // أيقونة مسار مميز
                    if (isFirst)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                PhosphorIcons.star_fill,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'مميز',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // مؤشر الصعوبة
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(path.difficulty).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getDifficultyIcon(path.difficulty),
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getDifficultyText(path.difficulty),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // معلومات المسار (في الجزء السفلي من البطاقة)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // الاسم
                            Text(
                              _getLocalizedName(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _getLocalizedLocation(context),
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
                            
                            // معلومات إضافية
                            Row(
                              children: [
                                Flexible(
                                  child: _InfoChip(
                                    icon: PhosphorIcons.clock,
                                    label: '${path.estimatedDuration.inHours} ساعات',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: _InfoChip(
                                    icon: PhosphorIcons.ruler,
                                    label: '${path.length} كم',
                                  ),
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
              ],
            ),
          );
        },
      ),
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
        return AppColors.success; // أخضر للسهل
      case DifficultyLevel.medium:
        return AppColors.warning; // أصفر للمتوسط
      case DifficultyLevel.hard:
        return AppColors.error; // أحمر للصعب
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
  
  String _getLocalizedName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? path.nameAr : path.name;
  }
  
  String _getLocalizedLocation(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? path.locationAr : path.location;
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}