// lib/presentation/screens/paths/widgets/path_details_map.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/maps_service.dart';
import '../../../../data/models/path_model.dart';

class PathDetailsMap extends StatefulWidget {
  final PathModel path;
  final double height;

  const PathDetailsMap({
    super.key,
    required this.path,
    this.height = 200,
  });

  @override
  State<PathDetailsMap> createState() => _PathDetailsMapState();
}

class _PathDetailsMapState extends State<PathDetailsMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMapData();
  }

  void _setupMapData() {
    Set<Marker> markers = {};
    Set<Polyline> polylines = {};

    if (widget.path.coordinates.isNotEmpty) {
      // إضافة marker لبداية المسار
      markers.add(
        MapsService.createMarker(
          markerId: 'start',
          position: LatLng(
            widget.path.coordinates.first.latitude,
            widget.path.coordinates.first.longitude,
          ),
          title: 'بداية المسار',
          snippet: widget.path.nameAr,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // إضافة marker لنهاية المسار إذا كان هناك أكثر من نقطة
      if (widget.path.coordinates.length > 1) {
        markers.add(
          MapsService.createMarker(
            markerId: 'end',
            position: LatLng(
              widget.path.coordinates.last.latitude,
              widget.path.coordinates.last.longitude,
            ),
            title: 'نهاية المسار',
            snippet: widget.path.nameAr,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }

      // إضافة polyline للمسار
      polylines.add(
        MapsService.createPolyline(
          polylineId: 'path',
          points: widget.path.coordinates.map((coord) => 
            LatLng(coord.latitude, coord.longitude)
          ).toList(),
          color: _getDifficultyColor(widget.path.difficulty),
          width: 5.0,
        ),
      );
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return AppColors.difficultyEasy;
      case DifficultyLevel.medium:
        return AppColors.difficultyMedium;
      case DifficultyLevel.hard:
        return AppColors.difficultyHard;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // تطبيق ستايل الدارك مود
    _setMapStyle();
    
    // تحريك الكاميرا لعرض المسار كاملاً
    if (widget.path.coordinates.isNotEmpty) {
      LatLngBounds bounds = MapsService.calculateBounds(
        widget.path.coordinates.map((coord) => 
          LatLng(coord.latitude, coord.longitude)
        ).toList(),
      );
      
      Future.delayed(const Duration(milliseconds: 500), () {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50.0),
        );
      });
    }
  }
  
  Future<void> _setMapStyle() async {
    if (_mapController != null) {
      try {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        // ستايل للدارك مود
        final String darkMapStyle = '''[
          {
            "elementType": "geometry",
            "stylers": [{"color": "#242f3e"}]
          },
          {
            "elementType": "labels.text.stroke",
            "stylers": [{"color": "#242f3e"}]
          },
          {
            "elementType": "labels.text.fill",
            "stylers": [{"color": "#746855"}]
          },
          {
            "featureType": "poi",
            "elementType": "labels",
            "stylers": [{"visibility": "off"}]
          }
        ]''';
        
        // ستايل للوضع الفاتح
        const String lightMapStyle = '''[
          {
            "featureType": "poi",
            "elementType": "labels",
            "stylers": [{"visibility": "off"}]
          }
        ]''';
        
        await _mapController!.setMapStyle(isDark ? darkMapStyle : lightMapStyle);
      } catch (e) {
        print('خطأ في تطبيق ستايل الخريطة: $e');
      }
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // إعادة تطبيق الستايل عند تغيير الثيم
    if (_mapController != null) {
      _setMapStyle();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.path.coordinates.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.map_pin,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'لا توجد إحداثيات للمسار',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.path.coordinates.first.latitude,
                  widget.path.coordinates.first.longitude,
                ),
                zoom: 13.0,
              ),
              markers: _markers,
              polylines: _polylines,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
            
            // مؤشر نوع المسار
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(widget.path.difficulty).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.map_trifold,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.path.length} كم',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // معلومات المسار
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.map_pin,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.path.locationAr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${widget.path.estimatedDuration.inHours} ساعات',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}