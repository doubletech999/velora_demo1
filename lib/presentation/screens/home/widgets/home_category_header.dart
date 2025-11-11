// lib/presentation/screens/home/widgets/home_category_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class HomeCategoryHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final IconData? icon;

  const HomeCategoryHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          if (onViewAll != null)
            TextButton.icon(
              onPressed: onViewAll,
              icon: const Icon(
                PhosphorIcons.arrow_square_out,
                size: 18,
              ),
              label: Text(localizations.get('view_all')),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}