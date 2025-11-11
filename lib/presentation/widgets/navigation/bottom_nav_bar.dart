// lib/presentation/widgets/navigation/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localizations = AppLocalizations.ofOrThrow(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(.1),
            offset: const Offset(0, -1),  // تغيير اتجاه الظل للأعلى
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => _onItemTapped(context, index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark ? theme.colorScheme.onSurface.withOpacity(0.6) : Colors.grey.shade600,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(PhosphorIcons.house),
                label: localizations.get('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(PhosphorIcons.map_pin),
                label: localizations.get('sites'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(PhosphorIcons.compass),
                label: localizations.get('explore'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(PhosphorIcons.map_pin),
                label: localizations.get('map'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(PhosphorIcons.user),
                label: localizations.get('profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/paths');
        break;
      case 2:
        context.go('/explore');
        break;
      case 3:
        context.go('/map');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}