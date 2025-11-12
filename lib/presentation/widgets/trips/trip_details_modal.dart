// lib/presentation/widgets/trips/trip_details_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/trip_model.dart';

Future<void> showTripDetailsModal(
  BuildContext context,
  TripModel trip, {
  VoidCallback? onRegister,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final sites = trip.sites;
      final activities = trip.activities;

      return DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        initialChildSize: 0.75,
        minChildSize: 0.45,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        trip.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(PhosphorIcons.x),
                    ),
                  ],
                ),
                if (trip.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Text(
                    trip.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
                const SizedBox(height: 16),
                _TripInfoRow(
                  icon: PhosphorIcons.calendar_blank,
                  title: 'التواريخ',
                  value: trip.dateRange,
                  helper:
                      trip.durationInDays > 0 ? '${trip.durationInDays} يوم' : null,
                ),
                if (trip.durationText?.isNotEmpty == true)
                  _TripInfoRow(
                    icon: PhosphorIcons.timer,
                    title: 'المدة',
                    value: trip.durationText!,
                  ),
                if (trip.price != null)
                  _TripInfoRow(
                    icon: PhosphorIcons.currency_dollar,
                    title: 'السعر',
                    value: '${trip.price!.toStringAsFixed(2)} \$',
                  ),
                if (trip.guideName?.isNotEmpty == true)
                  _TripInfoRow(
                    icon: PhosphorIcons.user_circle,
                    title: 'الدليل',
                    value: trip.guideName!,
                  ),
                if (trip.travelerName?.isNotEmpty == true)
                  _TripInfoRow(
                    icon: PhosphorIcons.airplane_tilt,
                    title: 'الرحالة',
                    value: trip.travelerName!,
                    helper: trip.travelerEmail,
                  ),
                if (trip.customRoute?.isNotEmpty == true) ...[
                  const SizedBox(height: 18),
                  Text(
                    'وصف المسار / التخييم',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.15),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      trip.customRoute!,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                ],
                if (activities.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'الأنشطة المتضمنة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: activities
                        .map(
                          (activity) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              activity.replaceAll('_', ' '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (sites.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'المواقع المدرجة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...sites.map(
                    (site) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          PhosphorIcons.map_pin,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(site.displayName),
                      subtitle: site.locationAr != null
                          ? Text(
                              site.locationAr!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
                if (onRegister != null) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(PhosphorIcons.clipboard_text),
                      label: const Text(
                        'تسجيل في الرحلة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        onRegister();
                      },
                    ),
                  ),
                ],
                if (onRegister == null) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(PhosphorIcons.clipboard_text),
                      label: const Text('التسجيل غير متاح لهذه الرحلة حالياً'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: null,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}

class _TripInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? helper;

  const _TripInfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (helper != null && helper!.isNotEmpty)
                  Text(
                    helper!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black45,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

