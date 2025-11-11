import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBack,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBackButton && canPop;
    final theme = Theme.of(context);

    return AppBar(
      elevation: elevation,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      centerTitle: true,
      leading: shouldShowBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: onBack ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      iconTheme: IconThemeData(color: theme.textTheme.bodyLarge?.color),
    );
  }
}