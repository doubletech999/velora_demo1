import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool isOverlay;

  const LoadingIndicator({
    super.key,
    this.message,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicator = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isOverlay) {
      return Container(
        color: theme.brightness == Brightness.dark 
            ? Colors.black87.withOpacity(0.8)
            : Colors.black54,
        child: Center(child: indicator),
      );
    }

    return Center(child: indicator);
  }
}