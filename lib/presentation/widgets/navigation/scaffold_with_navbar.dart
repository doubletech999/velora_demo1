// lib/presentation/widgets/navigation/scaffold_with_navbar.dart
import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final String location;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
    required this.location,
  });

  // تعديل في lib/presentation/widgets/navigation/scaffold_with_navbar.dart
  @override
  Widget build(BuildContext context) {
    // التحقق من وجود شريط تنقل في الصفحة الحالية
    final bool needsNavBar =
        !location.contains('/paths/') &&
        !location.contains('/profile/settings') &&
        !location.contains('/search');

    return Scaffold(
      body: SafeArea(child: child),
      // إظهار شريط التنقل فقط إذا كانت الصفحة الحالية تتطلب ذلك
      bottomNavigationBar:
          needsNavBar
              ? BottomNavBar(currentIndex: _calculateSelectedIndex(location))
              : null,
      extendBody: needsNavBar,
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/')) {
      if (location == '/') return 0;

      final mainRoute = location.split('/')[1];

      switch (mainRoute) {
        case '':
          return 0;
        case 'paths':
          return 1;
        case 'explore':
          return 2;
        case 'map':
          return 3;
        case 'profile':
          return 4;
        default:
          return 0;
      }
    }
    return 0;
  }
}
