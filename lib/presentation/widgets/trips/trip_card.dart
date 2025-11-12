// lib/presentation/widgets/trips/trip_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/trip_model.dart';

class TripListCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const TripListCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = trip.displayImage;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _TripImage(imageUrl: image),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(PhosphorIcons.calendar_blank, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          trip.dateRange,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(PhosphorIcons.map_pin, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${trip.siteCount} موقع',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      if (trip.price != null) ...[
                        const SizedBox(width: 16),
                        const Icon(PhosphorIcons.wallet, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${trip.price!.toStringAsFixed(2)} \$',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (trip.activities.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: trip.activities
                          .map(
                            (activity) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripImage extends StatelessWidget {
  final String imageUrl;

  const _TripImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: imageUrl.startsWith('http')
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _placeholder(spinner: true);
              },
            )
          : Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            ),
    );
  }

  Widget _placeholder({bool spinner = false}) {
    return Container(
      color: AppColors.primary.withOpacity(0.08),
      child: Center(
        child:
            spinner
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(
                  PhosphorIcons.image,
                  color: AppColors.primary,
                  size: 28,
                ),
      ),
    );
  }
}


