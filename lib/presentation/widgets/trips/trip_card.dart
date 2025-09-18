// lib/presentation/widgets/trips/trip_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/trip_model.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;
  final Function(TripStatus)? onStatusChange;

  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with path name and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.pathName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.map_pin,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                trip.pathLocation,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: trip.getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: trip.getStatusColor().withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      trip.getStatusText(),
                      style: TextStyle(
                        color: trip.getStatusColor(),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Trip details row
              Row(
                children: [
                  _buildInfoItem(
                    PhosphorIcons.activity,
                    trip.getActivityTypeText(),
                    trip.getStatusColor(),
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    PhosphorIcons.calendar,
                    '${trip.scheduledDate.day}/${trip.scheduledDate.month}',
                    AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    PhosphorIcons.clock,
                    '${trip.estimatedDurationHours}س',
                    AppColors.tertiary,
                  ),
                  const Spacer(),
                  _buildInfoItem(
                    PhosphorIcons.users,
                    '${trip.participantCount}',
                    AppColors.secondary,
                  ),
                ],
              ),
              
              // Show time until trip for upcoming trips
              if (trip.isUpcoming && trip.timeUntilTrip.inHours > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        PhosphorIcons.timer,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getTimeUntilText(trip.timeUntilTrip),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Notes preview if available
              if (trip.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  trip.notes,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getTimeUntilText(Duration duration) {
    if (duration.inDays > 0) {
      return 'خلال ${duration.inDays} أيام';
    } else if (duration.inHours > 0) {
      return 'خلال ${duration.inHours} ساعات';
    } else if (duration.inMinutes > 0) {
      return 'خلال ${duration.inMinutes} دقائق';
    } else {
      return 'الآن';
    }
  }
}

// ================================================================
// lib/presentation/widgets/trips/trip_stats_card.dart
class TripStatsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const TripStatsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.chart_bar,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'إحصائيات الرحلات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Main stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'المكتملة',
                  '${statistics['completed']}',
                  PhosphorIcons.check_circle,
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'القادمة',
                  '${statistics['upcoming']}',
                  PhosphorIcons.calendar,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'الجارية',
                  '${statistics['ongoing']}',
                  PhosphorIcons.play,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'المجموع',
                  '${statistics['totalTrips']}',
                  PhosphorIcons.list,
                  AppColors.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Additional stats
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.ruler,
                        color: AppColors.tertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إجمالي المسافة',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${statistics['totalDistance'].toStringAsFixed(1)} كم',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.trophy,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نشاط مفضل',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _getMostFrequentActivity(statistics['activityBreakdown']),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
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
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getMostFrequentActivity(Map<TripActivityType, int>? breakdown) {
    if (breakdown == null || breakdown.isEmpty) return 'لا يوجد';
    
    TripActivityType mostFrequent = breakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    switch (mostFrequent) {
      case TripActivityType.hiking:
        return 'مشي';
      case TripActivityType.camping:
        return 'تخييم';
      case TripActivityType.religious:
        return 'ديني';
      case TripActivityType.cultural:
        return 'ثقافي';
      case TripActivityType.other:
        return 'آخر';
    }
  }
}