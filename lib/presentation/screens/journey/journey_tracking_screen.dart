// lib/presentation/screens/journey/journey_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/guest_guard.dart';
import '../../../data/models/path_model.dart';
import '../../providers/journey_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'widgets/journey_completion_dialog.dart';

class JourneyTrackingScreen extends StatefulWidget {
  final PathModel path;

  const JourneyTrackingScreen({
    super.key,
    required this.path,
  });

  @override
  State<JourneyTrackingScreen> createState() => _JourneyTrackingScreenState();
}

class _JourneyTrackingScreenState extends State<JourneyTrackingScreen> {
  GoogleMapController? _mapController;
  bool _isJourneyStarted = false;
  bool _isJourneyPaused = false;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMapMarkersAndPath();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setupMapMarkersAndPath() {
    Set<Marker> markers = {};
    Set<Polyline> polylines = {};

    if (widget.path.coordinates.isNotEmpty) {
      // نقطة البداية
      markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: LatLng(
            widget.path.coordinates.first.latitude,
            widget.path.coordinates.first.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: AppLocalizations.ofOrThrow(context).get('start_point'),
            snippet: widget.path.nameAr,
          ),
        ),
      );

      // نقطة النهاية
      if (widget.path.coordinates.length > 1) {
        markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: LatLng(
              widget.path.coordinates.last.latitude,
              widget.path.coordinates.last.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: AppLocalizations.ofOrThrow(context).get('end_point'),
              snippet: AppLocalizations.ofOrThrow(context).get('final_destination'),
            ),
          ),
        );
      }

      // خط المسار
      polylines.add(
        Polyline(
          polylineId: const PolylineId('path'),
          points: widget.path.coordinates.map((coord) => 
            LatLng(coord.latitude, coord.longitude)
          ).toList(),
          color: AppColors.primary,
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  void _startLocationTracking() {
    if (!GuestGuard.check(context, feature: 'تتبع الرحلة')) {
      Navigator.of(context).pop();
      return;
    }
    final journeyProvider = Provider.of<JourneyProvider>(context, listen: false);
    journeyProvider.startJourney(widget.path);
  }

  void _startJourney() {
    if (!GuestGuard.check(context, feature: 'بدء الرحلة')) {
      return;
    }
    setState(() {
      _isJourneyStarted = true;
      _isJourneyPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isJourneyPaused) {
        setState(() {
          _elapsedTime = Duration(seconds: _elapsedTime.inSeconds + 1);
        });
      }
    });

    final journeyProvider = Provider.of<JourneyProvider>(context, listen: false);
    journeyProvider.resumeJourney();

    // تحريك الكاميرا إلى نقطة البداية
    if (_mapController != null && widget.path.coordinates.isNotEmpty) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            widget.path.coordinates.first.latitude,
            widget.path.coordinates.first.longitude,
          ),
          16.0,
        ),
      );
    }
  }

  void _pauseJourney() {
    setState(() {
      _isJourneyPaused = !_isJourneyPaused;
    });

    final journeyProvider = Provider.of<JourneyProvider>(context, listen: false);
    if (_isJourneyPaused) {
      journeyProvider.pauseJourney();
    } else {
      journeyProvider.resumeJourney();
    }
  }

  void _stopJourney() {
    _timer?.cancel();
    
    final journeyProvider = Provider.of<JourneyProvider>(context, listen: false);
    journeyProvider.stopJourney();

    _showJourneyCompletedDialog();
  }

  void _showJourneyCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JourneyCompletionDialog(
        path: widget.path,
        elapsedTime: _elapsedTime,
        onComplete: () {
          Navigator.of(context).pop(); // إغلاق الحوار
          Navigator.of(context).pop(); // العودة للصفحة السابقة
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.path.nameAr,
        actions: [
          if (_isJourneyStarted)
            IconButton(
              icon: Icon(
                PhosphorIcons.stop_circle,
                color: AppColors.error,
              ),
              onPressed: _stopJourney,
            ),
        ],
      ),
      body: Consumer<JourneyProvider>(
        builder: (context, journeyProvider, child) {
          return Column(
            children: [
              // معلومات الرحلة العلوية
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // الوقت المستغرق مع تصميم محسن
                    Container(
                      padding: const EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        _formatDuration(_elapsedTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // إحصائيات الرحلة
                    Builder(
                      builder: (context) {
                        final localizations = AppLocalizations.ofOrThrow(context);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              icon: PhosphorIcons.ruler,
                              label: localizations.get('distance'),
                              value: '${journeyProvider.distanceTraveled.toStringAsFixed(1)} ${localizations.get('km')}',
                              color: AppColors.tertiary,
                            ),
                            _StatItem(
                              icon: PhosphorIcons.gauge,
                              label: localizations.get('current_speed'),
                              value: '${journeyProvider.currentSpeed.toStringAsFixed(1)} ${localizations.get('km')}/${localizations.get('hours')}',
                              color: AppColors.secondary,
                            ),
                            _StatItem(
                              icon: PhosphorIcons.map_pin,
                              label: localizations.get('progress'),
                              value: '${journeyProvider.visitedCheckpoints}/${widget.path.coordinates.length}',
                              color: AppColors.success,
                            ),
                          ],
                        );
                      },
                    ),
                    
                    // شريط التقدم
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: journeyProvider.getCompletionPercentage(),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.success],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final localizations = AppLocalizations.ofOrThrow(context);
                        return Text(
                          localizations.get('completion_percentage').replaceAll('{percentage}', (journeyProvider.getCompletionPercentage() * 100).toStringAsFixed(1)),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // الخريطة مع التحسينات
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: widget.path.coordinates.isNotEmpty
                            ? LatLng(
                                widget.path.coordinates.first.latitude,
                                widget.path.coordinates.first.longitude,
                              )
                            : const LatLng(31.9522, 35.2332),
                        zoom: 14.0,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      compassEnabled: true,
                      rotateGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      tiltGesturesEnabled: false,
                      zoomGesturesEnabled: true,
                    ),
                  ),
                ),
              ),

              // أزرار التحكم المحسنة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.black.withOpacity(0.3) 
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      if (!_isJourneyStarted) ...[
                        // معلومات المسار قبل البدء
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIcons.info,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final localizations = AppLocalizations.ofOrThrow(context);
                                        return Text(
                                          localizations.get('path_info').replaceAll('{name}', widget.path.nameAr),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        );
                                      },
                                    ),
                                    Builder(
                                      builder: (context) {
                                        final localizations = AppLocalizations.ofOrThrow(context);
                                        return Text(
                                          localizations.get('path_info_full')
                                              .replaceAll('{distance}', widget.path.length.toString())
                                              .replaceAll('{hours}', widget.path.estimatedDuration.inHours.toString()),
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Builder(
                            builder: (context) {
                              final localizations = AppLocalizations.ofOrThrow(context);
                              return ElevatedButton.icon(
                                onPressed: _startJourney,
                                icon: const Icon(PhosphorIcons.play, size: 24),
                                label: Text(
                                  localizations.get('start_journey_button'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  shadowColor: AppColors.primary.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: _pauseJourney,
                                  icon: Icon(
                                    _isJourneyPaused 
                                        ? PhosphorIcons.play 
                                        : PhosphorIcons.pause,
                                    size: 20,
                                  ),
                                  label: Builder(
                                    builder: (context) {
                                      final localizations = AppLocalizations.ofOrThrow(context);
                                      return Text(
                                        _isJourneyPaused ? localizations.get('resume') : localizations.get('pause'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isJourneyPaused 
                                        ? AppColors.primary 
                                        : AppColors.warning,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: _stopJourney,
                                  icon: const Icon(PhosphorIcons.stop, size: 20),
                                  label: Builder(
                                    builder: (context) {
                                      final localizations = AppLocalizations.ofOrThrow(context);
                                      return Text(
                                        localizations.get('end_journey_button'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
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
}