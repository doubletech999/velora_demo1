// lib/presentation/screens/trips/my_trips_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/trip_model.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/trips/trip_card.dart';
import '../../widgets/trips/trip_stats_card.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showStats = false;

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'القادمة', 'icon': PhosphorIcons.calendar},
    {'title': 'الجارية', 'icon': PhosphorIcons.play},
    {'title': 'المكتملة', 'icon': PhosphorIcons.check_circle},
    {'title': 'الكل', 'icon': PhosphorIcons.list},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    
    // Load trips when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      tripProvider.refreshTrips();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'رحلاتي',
        actions: [
          IconButton(
            icon: Icon(
              _showStats ? PhosphorIcons.list : PhosphorIcons.chart_bar,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _showStats = !_showStats;
              });
            },
          ),
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          if (tripProvider.isLoading) {
            return const LoadingIndicator(message: 'جاري تحميل الرحلات...');
          }

          if (tripProvider.error != null) {
            return _buildErrorState(tripProvider.error!, () {
              tripProvider.refreshTrips();
            });
          }

          return Column(
            children: [
              // Statistics card (toggle visibility)
              if (_showStats) ...[
                TripStatsCard(statistics: tripProvider.getTripStatistics()),
                const SizedBox(height: 8),
              ],

              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                  tabs: _tabs.map((tab) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tab['icon'], size: 16),
                        const SizedBox(width: 4),
                        Text(tab['title']),
                      ],
                    ),
                  )).toList(),
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTripsList(tripProvider.upcomingTrips, TripStatus.planned),
                    _buildTripsList(tripProvider.ongoingTrips, TripStatus.ongoing),
                    _buildTripsList(tripProvider.completedTrips, TripStatus.completed),
                    _buildTripsList(tripProvider.trips, null),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/paths'); // Navigate to paths to select one for new trip
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(PhosphorIcons.plus),
        label: const Text('رحلة جديدة'),
      ),
    );
  }

  Widget _buildTripsList(List<Trip> trips, TripStatus? filterStatus) {
    if (trips.isEmpty) {
      return _buildEmptyState(filterStatus);
    }

    return RefreshIndicator(
      onRefresh: () async {
        final tripProvider = Provider.of<TripProvider>(context, listen: false);
        await tripProvider.refreshTrips();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: TripCard(
              trip: trip,
              onTap: () => _showTripDetails(trip),
              onStatusChange: (newStatus) => _updateTripStatus(trip, newStatus),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(TripStatus? status) {
    String title;
    String subtitle;
    IconData icon;

    switch (status) {
      case TripStatus.planned:
        title = 'لا توجد رحلات قادمة';
        subtitle = 'خطط لرحلتك القادمة واستكشف المسارات الجديدة';
        icon = PhosphorIcons.calendar;
        break;
      case TripStatus.ongoing:
        title = 'لا توجد رحلات جارية';
        subtitle = 'عندما تبدأ رحلة ستظهر هنا';
        icon = PhosphorIcons.play;
        break;
      case TripStatus.completed:
        title = 'لا توجد رحلات مكتملة';
        subtitle = 'أكمل رحلتك الأولى لتراها هنا';
        icon = PhosphorIcons.check_circle;
        break;
      default:
        title = 'لا توجد رحلات';
        subtitle = 'ابدأ بتسجيل رحلتك الأولى';
        icon = PhosphorIcons.map_trifold;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/paths'),
              icon: const Icon(PhosphorIcons.plus),
              label: const Text('تسجيل رحلة جديدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.warning_circle,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل الرحلات',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(PhosphorIcons.arrow_clockwise),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTripDetails(Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TripDetailsSheet(trip: trip),
    );
  }

  Future<void> _updateTripStatus(Trip trip, TripStatus newStatus) async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    
    bool success = false;
    switch (newStatus) {
      case TripStatus.ongoing:
        success = await tripProvider.startTrip(trip.id);
        break;
      case TripStatus.completed:
        success = await tripProvider.completeTrip(trip.id);
        break;
      case TripStatus.cancelled:
        success = await tripProvider.cancelTrip(trip.id);
        break;
      default:
        return;
    }
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث حالة الرحلة بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في تحديث الرحلة'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}

// Trip Details Bottom Sheet
class _TripDetailsSheet extends StatelessWidget {
  final Trip trip;

  const _TripDetailsSheet({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: trip.getStatusColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIcons.calendar_check,
                    color: trip.getStatusColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.pathName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trip.pathLocation,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: trip.getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trip.getStatusText(),
                    style: TextStyle(
                      color: trip.getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip info
                _buildInfoRow(
                  PhosphorIcons.activity,
                  'نوع النشاط',
                  trip.getActivityTypeText(),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  PhosphorIcons.calendar,
                  'تاريخ الرحلة',
                  trip.getFormattedDateTime(),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  PhosphorIcons.clock,
                  'المدة المتوقعة',
                  '${trip.estimatedDurationHours} ساعات',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  PhosphorIcons.users,
                  'المشاركون',
                  trip.participants.isNotEmpty
                      ? trip.participants.join(', ')
                      : '${trip.participantCount} مشارك',
                ),
                
                if (trip.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    PhosphorIcons.note,
                    'الملاحظات',
                    trip.notes,
                  ),
                ],
                
                // Path details
                const SizedBox(height: 20),
                const Text(
                  'تفاصيل المسار',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPathInfo(PhosphorIcons.ruler, '${trip.pathLength} كم'),
                    const SizedBox(width: 20),
                    _buildPathInfo(PhosphorIcons.trend_up_thin, trip.pathDifficulty),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Action buttons based on status
                _buildActionButtons(context, trip),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPathInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Trip trip) {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    
    switch (trip.status) {
      case TripStatus.planned:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final success = await tripProvider.startTrip(trip.id);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم بدء الرحلة!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                icon: const Icon(PhosphorIcons.play),
                label: const Text('بدء الرحلة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final success = await tripProvider.cancelTrip(trip.id);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(PhosphorIcons.x),
                label: const Text('إلغاء الرحلة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        );
        
      case TripStatus.ongoing:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final success = await tripProvider.completeTrip(trip.id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم إكمال الرحلة بنجاح! 🎉'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            icon: const Icon(PhosphorIcons.check_circle),
            label: const Text('إكمال الرحلة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
        
      case TripStatus.completed:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(PhosphorIcons.check_circle),
            label: const Text('رحلة مكتملة'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
        
      case TripStatus.cancelled:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(PhosphorIcons.x_circle),
            label: const Text('رحلة ملغية'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
    }
  }
}