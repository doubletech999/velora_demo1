// lib/presentation/screens/home/widgets/search_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // تهيئة أدوات الاستجابة
    ResponsiveUtils.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => context.go('/search'),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.adaptive(12)),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(context.adaptive(12)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.magnifying_glass,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              size: context.iconSize(),
            ),
            SizedBox(width: context.sm),
            Expanded(
              child: Text(
                'ابحث عن مسار أو مكان...',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontSize: context.fontSize(16),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(context.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(context.adaptive(8)),
              ),
              child: Icon(
                PhosphorIcons.sliders,
                color: AppColors.primary,
                size: context.iconSize(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}