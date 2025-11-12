import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';

import '../../providers/trips_provider.dart';
import '../../providers/paths_provider.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/models/path_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/path_card.dart';
import '../../widgets/trips/trip_card.dart';
import '../../widgets/trips/trip_details_modal.dart';

class PathsScreen extends StatefulWidget {
  const PathsScreen({super.key});

  @override
  State<PathsScreen> createState() => _PathsScreenState();
}

class _EmptyRoutesPlaceholder extends StatelessWidget {
  final VoidCallback onExploreTap;
  final VoidCallback onReload;

  const _EmptyRoutesPlaceholder({
    required this.onExploreTap,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: width > 600 ? width * 0.2 : 24,
        vertical: 48,
      ),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              PhosphorIcons.path,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد رحلات متاحة الآن',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'يمكنك إعادة تحميل البيانات أو الانتقال إلى صفحة استكشف لاختيار اقتراحات أخرى.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onReload,
                icon: const Icon(PhosphorIcons.arrow_counter_clockwise),
                label: const Text('إعادة تحميل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onExploreTap,
                icon: const Icon(PhosphorIcons.compass),
                label: const Text('الانتقال إلى استكشف'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PathsScreenState extends State<PathsScreen> {
  @override
  void initState() {
    super.initState();
    // Load paths when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripsProvider>(context, listen: false).initializeIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.get('paths'))),
      body: Consumer2<TripsProvider, PathsProvider>(
        builder: (context, tripsProvider, pathsProvider, child) {
          final List<TripModel> trips = tripsProvider.adventureTrips;
          final List<PathModel> fallbackPaths =
              pathsProvider.filteredRoutesAndCamping;

          final bool hasTrips = trips.isNotEmpty;
          final bool hasFallbackPaths = fallbackPaths.isNotEmpty;

          if (tripsProvider.isLoading && !hasTrips && !hasFallbackPaths) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!hasTrips && hasFallbackPaths) {
            return RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  tripsProvider.loadTrips(),
                  pathsProvider.loadPaths(),
                ]);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: fallbackPaths.length,
                itemBuilder:
                    (context, index) => PathCard(path: fallbackPaths[index]),
              ),
            );
          }

          if (!hasTrips) {
            return _EmptyRoutesPlaceholder(
              onExploreTap: () => context.go('/explore'),
              onReload: () => tripsProvider.loadTrips(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await tripsProvider.loadTrips();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                final fallbackPath = tripsProvider.getFallbackPath(trip.id);
                final registrationPathId =
                    fallbackPath?.id ?? trip.primarySiteId;
                VoidCallback? onRegister;
                if (registrationPathId != null &&
                    registrationPathId.isNotEmpty) {
                  onRegister = () => context.go('/paths/$registrationPathId');
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TripListCard(
                    trip: trip,
                    onTap:
                        () => showTripDetailsModal(
                          context,
                          trip,
                          onRegister: onRegister,
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
