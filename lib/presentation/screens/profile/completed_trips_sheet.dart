// lib/presentation/widgets/profile/completed_trips_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/paths_provider.dart';
import '../../screens/paths/widgets/path_card.dart';

class CompletedTripsSheet extends StatelessWidget {
  const CompletedTripsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pathsProvider = Provider.of<PathsProvider>(context);
    // للتوضيح: نأخذ أول 3 مسارات كرحلات مكتملة
    final completedPaths = pathsProvider.paths.take(3).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // مؤشر السحب والعنوان
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.ofOrThrow(context).get('completed_trips_title'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(PhosphorIcons.x),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // قائمة الرحلات
          Expanded(
            child: completedPaths.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.check_circle,
                          size: 64,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.ofOrThrow(context).get('no_completed_trips'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.ofOrThrow(context).get('start_first_trip_now'),
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            context.go('/paths');
                          },
                          icon: const Icon(PhosphorIcons.map_trifold),
                          label: Text(AppLocalizations.ofOrThrow(context).get('explore_paths')),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: completedPaths.length,
                    itemBuilder: (context, index) {
                      final path = completedPaths[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: PathCard(
                          path: path,
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/paths/${path.id}');
                          },
                        ),
                      );
                    },
                  ),
          ),
          
          // إحصائيات في الأسفل
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Builder(
                  builder: (context) {
                    final localizations = AppLocalizations.ofOrThrow(context);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatChip(
                          icon: PhosphorIcons.check_circle,
                          label: localizations.get('completed'),
                          value: completedPaths.length.toString(),
                          color: AppColors.success,
                        ),
                        _StatChip(
                          icon: PhosphorIcons.clock,
                          label: localizations.get('total_time'),
                          value: '${completedPaths.fold<int>(0, (sum, path) => sum + path.estimatedDuration.inHours)} ${localizations.get('hours')}',
                          color: AppColors.primary,
                        ),
                        _StatChip(
                          icon: PhosphorIcons.ruler,
                          label: localizations.get('total_distance_label'),
                          value: '${completedPaths.fold<double>(0, (sum, path) => sum + path.length).toStringAsFixed(1)} ${localizations.get('km')}',
                          color: AppColors.tertiary,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}