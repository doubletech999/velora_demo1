// lib/presentation/screens/map/map_screen.dart - إصلاح التضارب
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart'
    hide ActivityType; // إخفاء ActivityType من geolocator

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/maps_service.dart';
import '../../../data/models/path_model.dart'; // ActivityType من هنا
import '../../providers/paths_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import 'widgets/map_control_button.dart';
import 'widgets/path_info_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final bool _useFlutterMap;
  gmap.GoogleMapController? _mapController;
  final fm.MapController _flutterMapController = fm.MapController();
  bool _isLoading = true;
  bool _showPathsFilter = false;
  String? _selectedPathId;

  // الموقع الحالي
  gmap.LatLng _currentLocation = MapsService.palestineCenter;
  Position? _userPosition;

  // Markers و Polylines
  Set<gmap.Marker> _markers = {};
  Set<gmap.Polyline> _polylines = {};
  List<PathModel> _visiblePaths = [];
  latlng.LatLng _fallbackCenter = latlng.LatLng(
    MapsService.palestineCenter.latitude,
    MapsService.palestineCenter.longitude,
  );
  double _fallbackZoom = 8.0;

  // فلترة المسارات
  DifficultyLevel? _selectedDifficulty;
  ActivityType? _selectedActivity; // هذا من path_model.dart

  @override
  void initState() {
    super.initState();
    _useFlutterMap = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // الحصول على الموقع الحالي
      Position? position = await MapsService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _userPosition = position;
          _currentLocation = gmap.LatLng(position.latitude, position.longitude);
          if (_useFlutterMap) {
            _fallbackCenter = latlng.LatLng(
              position.latitude,
              position.longitude,
            );
            _fallbackZoom = 13.0;
          }
        });
        if (_useFlutterMap) {
          _moveFallbackMap(_fallbackCenter, zoom: _fallbackZoom);
        }
      }

      // تحميل المسارات
      await _loadPaths();
    } catch (e) {
      print('خطأ في تهيئة الخريطة: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (_useFlutterMap) {
        _moveFallbackMap(_fallbackCenter, zoom: _fallbackZoom);
      }
    }
  }

  Future<void> _loadPaths() async {
    final pathsProvider = Provider.of<PathsProvider>(context, listen: false);

    if (!pathsProvider.initialized && !pathsProvider.isLoading) {
      await pathsProvider.loadPaths();
    }

    final paths = pathsProvider.paths;

    await _updateMapData(paths);
  }

  Future<void> _updateMapData(List<PathModel> paths) async {
    Set<gmap.Marker> markers = {};
    Set<gmap.Polyline> polylines = {};

    // إضافة marker لموقع المستخدم
    if (_userPosition != null) {
      markers.add(
        MapsService.createMarker(
          markerId: 'user_location',
          position: gmap.LatLng(
            _userPosition!.latitude,
            _userPosition!.longitude,
          ),
          title: 'موقعك الحالي',
          icon: gmap.BitmapDescriptor.defaultMarkerWithHue(
            gmap.BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    // تطبيق الفلترة
    final filteredPaths =
        paths.where((path) {
          if (_selectedDifficulty != null &&
              path.difficulty != _selectedDifficulty) {
            return false;
          }

          if (_selectedActivity != null &&
              !path.activities.contains(_selectedActivity)) {
            return false;
          }

          return true;
        }).toList();

    // إضافة markers و polylines للمسارات
    for (int i = 0; i < filteredPaths.length; i++) {
      final path = filteredPaths[i];

      if (path.coordinates.isNotEmpty) {
        // إضافة marker لبداية المسار
        markers.add(
          MapsService.createMarker(
            markerId: 'path_start_${path.id}',
            position: gmap.LatLng(
              path.coordinates.first.latitude,
              path.coordinates.first.longitude,
            ),
            title: path.nameAr,
            snippet: path.locationAr,
            icon: gmap.BitmapDescriptor.defaultMarkerWithHue(
              _getDifficultyHue(path.difficulty),
            ),
            onTap: () => _onMarkerTap(path),
          ),
        );

        // إضافة marker لنهاية المسار
        if (path.coordinates.length > 1) {
          markers.add(
            MapsService.createMarker(
              markerId: 'path_end_${path.id}',
              position: gmap.LatLng(
                path.coordinates.last.latitude,
                path.coordinates.last.longitude,
              ),
              title: 'نهاية ${path.nameAr}',
              icon: gmap.BitmapDescriptor.defaultMarkerWithHue(
                gmap.BitmapDescriptor.hueGreen,
              ),
            ),
          );
        }

        // إضافة polyline للمسار
        polylines.add(
          MapsService.createPolyline(
            polylineId: 'path_${path.id}',
            points:
                path.coordinates
                    .map(
                      (coord) => gmap.LatLng(coord.latitude, coord.longitude),
                    )
                    .toList(),
            color:
                path.id == _selectedPathId
                    ? AppColors.secondary
                    : _getDifficultyColor(path.difficulty),
            width: path.id == _selectedPathId ? 6.0 : 4.0,
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
      _visiblePaths = filteredPaths;
    });
  }

  Widget _buildGoogleMap(SettingsProvider settingsProvider) {
    return gmap.GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: gmap.CameraPosition(
        target: _currentLocation,
        zoom: 8.0,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapType: _getMapType(settingsProvider.mapType),
      onTap: (gmap.LatLng position) {
        setState(() {
          _selectedPathId = null;
        });
        _loadPaths(); // إعادة تحميل لإزالة التحديد
      },
      compassEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
  }

  Widget _buildFlutterMap() {
    return fm.FlutterMap(
      mapController: _flutterMapController,
      options: fm.MapOptions(
        initialCenter: _fallbackCenter,
        initialZoom: _fallbackZoom,
        minZoom: 3,
        maxZoom: 18,
        interactionOptions: const fm.InteractionOptions(
          flags:
              fm.InteractiveFlag.pinchZoom |
              fm.InteractiveFlag.drag |
              fm.InteractiveFlag.doubleTapZoom |
              fm.InteractiveFlag.flingAnimation,
        ),
        onTap: (tapPosition, point) {
          setState(() {
            _selectedPathId = null;
          });
          _loadPaths();
        },
        onPositionChanged: (position, hasGesture) {
          _fallbackCenter = position.center;
          _fallbackZoom = position.zoom;
        },
      ),
      children: [
        fm.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.velora.app',
          retinaMode: true,
        ),
        if (_buildFlutterPolylines().isNotEmpty)
          fm.PolylineLayer(polylines: _buildFlutterPolylines()),
        if (_buildFlutterMarkers().isNotEmpty)
          fm.MarkerLayer(markers: _buildFlutterMarkers()),
      ],
    );
  }

  List<fm.Marker> _buildFlutterMarkers() {
    final markers = <fm.Marker>[];

    if (_userPosition != null) {
      markers.add(
        fm.Marker(
          point: latlng.LatLng(
            _userPosition!.latitude,
            _userPosition!.longitude,
          ),
          width: 46,
          height: 46,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.6),
                width: 2,
              ),
            ),
            child: const Icon(
              PhosphorIcons.navigation_arrow,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      );
    }

    for (final path in _visiblePaths) {
      if (path.coordinates.isEmpty) continue;

      final start = path.coordinates.first;
      final difficultyColor = _getDifficultyColor(path.difficulty);

      markers.add(
        fm.Marker(
          point: latlng.LatLng(start.latitude, start.longitude),
          width: 48,
          height: 48,
          child: _buildPathMarker(
            color: difficultyColor,
            label: path.nameAr,
            isSelected: path.id == _selectedPathId,
          ),
        ),
      );

      if (path.coordinates.length > 1) {
        final end = path.coordinates.last;
        markers.add(
          fm.Marker(
            point: latlng.LatLng(end.latitude, end.longitude),
            width: 40,
            height: 40,
            child: _buildPathMarker(
              color: AppColors.success,
              icon: PhosphorIcons.flag_checkered,
              isSelected: path.id == _selectedPathId,
            ),
          ),
        );
      }
    }

    return markers;
  }

  List<fm.Polyline> _buildFlutterPolylines() {
    final polylines = <fm.Polyline>[];

    for (final path in _visiblePaths) {
      if (path.coordinates.length < 2) continue;
      final points =
          path.coordinates
              .map((coord) => latlng.LatLng(coord.latitude, coord.longitude))
              .toList();
      polylines.add(
        fm.Polyline(
          points: points,
          color:
              path.id == _selectedPathId
                  ? AppColors.secondary
                  : _getDifficultyColor(path.difficulty),
          strokeWidth: path.id == _selectedPathId ? 6 : 4,
        ),
      );
    }

    return polylines;
  }

  Widget _buildPathMarker({
    required Color color,
    String? label,
    IconData icon = PhosphorIcons.map_pin_fill,
    bool isSelected = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.25) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(isSelected ? 0.7 : 0.4),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          if (label != null) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _moveFallbackMap(latlng.LatLng target, {double? zoom}) {
    _fallbackCenter = target;
    if (zoom != null) {
      _fallbackZoom = zoom;
    }
    _flutterMapController.move(_fallbackCenter, _fallbackZoom);
  }

  void _changeZoom(bool zoomIn) {
    if (_useFlutterMap) {
      final delta = zoomIn ? 1.0 : -1.0;
      final newZoom = (_fallbackZoom + delta).clamp(3.0, 18.0);
      _moveFallbackMap(_fallbackCenter, zoom: newZoom);
      return;
    }

    if (_mapController == null) return;
    _mapController!.animateCamera(
      zoomIn ? gmap.CameraUpdate.zoomIn() : gmap.CameraUpdate.zoomOut(),
    );
  }

  double _getDifficultyHue(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return gmap.BitmapDescriptor.hueGreen;
      case DifficultyLevel.medium:
        return gmap.BitmapDescriptor.hueOrange;
      case DifficultyLevel.hard:
        return gmap.BitmapDescriptor.hueRed;
    }
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

  void _onMapCreated(gmap.GoogleMapController controller) {
    _mapController = controller;

    // تطبيق الستايل المخصص للخريطة
    _setMapStyle();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // إعادة تطبيق الستايل عند تغيير الثيم
    if (_mapController != null) {
      _setMapStyle();
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
            "featureType": "administrative.locality",
            "elementType": "labels.text.fill",
            "stylers": [{"color": "#d59563"}]
          },
          {
            "featureType": "poi",
            "elementType": "labels.text.fill",
            "stylers": [{"color": "#d59563"}]
          },
          {
            "featureType": "poi.park",
            "elementType": "geometry",
            "stylers": [{"color": "#263c3f"}]
          },
          {
            "featureType": "poi.park",
            "elementType": "labels.text.fill",
            "stylers": [{"color": "#6b9a76"}]
          },
          {
            "featureType": "road",
            "elementType": "geometry",
            "stylers": [{"color": "#38414e"}]
          },
          {
            "featureType": "road",
            "elementType": "geometry.stroke",
            "stylers": [{"color": "#212a37"}]
          },
          {
            "featureType": "road",
            "elementType": "labels.text.fill",
            "stylers": [{"color": "#9ca5b3"}]
          },
          {
            "featureType": "road.highway",
            "elementType": "geometry",
            "stylers": [{"color": "#746855"}]
          },
          {
            "featureType": "road.highway",
            "elementType": "geometry.stroke",
            "stylers": [{"color": "#1f2835"}]
          },
          {
            "featureType": "road.highway",
            "elementType": "labels.text.fill",
            "stylers": [{"color": "#f3d19c"}]
          },
          {
            "featureType": "transit",
            "elementType": "geometry",
            "stylers": [{"color": "#2f3948"}]
          },
          {
            "featureType": "transit.station",
            "elementType": "labels.text.fill",
            "stylers": [{"color": "#d59563"}]
          },
          {
            "featureType": "water",
            "elementType": "geometry",
            "stylers": [{"color": "#17263c"}]
          },
          {
            "featureType": "water",
            "elementType": "labels.text.fill",
            "stylers": [{"color": "#515c6d"}]
          },
          {
            "featureType": "water",
            "elementType": "labels.text.stroke",
            "stylers": [{"color": "#17263c"}]
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

        await _mapController!.setMapStyle(
          isDark ? darkMapStyle : lightMapStyle,
        );
      } catch (e) {
        print('خطأ في تطبيق ستايل الخريطة: $e');
      }
    }
  }

  void _onMarkerTap(PathModel path) {
    setState(() {
      _selectedPathId = path.id;
    });

    // تحديث المسارات على الخريطة
    _updateMapData(Provider.of<PathsProvider>(context, listen: false).paths);

    if (path.coordinates.isNotEmpty) {
      if (_useFlutterMap) {
        final target = latlng.LatLng(
          path.coordinates.first.latitude,
          path.coordinates.first.longitude,
        );
        _moveFallbackMap(target, zoom: 14.0);
      } else if (_mapController != null) {
        _mapController!.animateCamera(
          gmap.CameraUpdate.newLatLngZoom(
            gmap.LatLng(
              path.coordinates.first.latitude,
              path.coordinates.first.longitude,
            ),
            14.0,
          ),
        );
      }
    }

    // عرض معلومات المسار
    _showPathInfoBottomSheet(path);
  }

  void _showPathInfoBottomSheet(PathModel path) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => PathInfoBottomSheet(
            path: path,
            onViewDetails: () {
              Navigator.of(context).pop();
              context.go('/paths/${path.id}');
            },
          ),
    );
  }

  void _togglePathsFilter() {
    setState(() {
      _showPathsFilter = !_showPathsFilter;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedDifficulty = null;
      _selectedActivity = null;
    });
    _loadPaths();
  }

  Future<void> _centerUserLocation() async {
    if (_useFlutterMap) {
      if (_userPosition != null) {
        _moveFallbackMap(
          latlng.LatLng(_userPosition!.latitude, _userPosition!.longitude),
          zoom: 15.0,
        );
      } else {
        final position = await MapsService.getCurrentLocation();
        if (position != null) {
          setState(() {
            _userPosition = position;
            _currentLocation = gmap.LatLng(
              position.latitude,
              position.longitude,
            );
          });
          _moveFallbackMap(
            latlng.LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          );
          _loadPaths();
        } else {
          _moveFallbackMap(
            latlng.LatLng(
              MapsService.palestineCenter.latitude,
              MapsService.palestineCenter.longitude,
            ),
            zoom: 8.0,
          );
        }
      }
      return;
    }

    if (_mapController == null) return;

    if (_userPosition != null) {
      await _mapController!.animateCamera(
        gmap.CameraUpdate.newLatLngZoom(
          gmap.LatLng(_userPosition!.latitude, _userPosition!.longitude),
          15.0,
        ),
      );
    } else {
      Position? position = await MapsService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _userPosition = position;
          _currentLocation = gmap.LatLng(position.latitude, position.longitude);
        });

        await _mapController!.animateCamera(
          gmap.CameraUpdate.newLatLngZoom(_currentLocation, 15.0),
        );

        _loadPaths();
      } else {
        await _mapController!.animateCamera(
          gmap.CameraUpdate.newLatLngZoom(MapsService.palestineCenter, 8.0),
        );
      }
    }
  }

  Future<void> _fitAllPaths() async {
    final pathsProvider = Provider.of<PathsProvider>(context, listen: false);
    final paths = pathsProvider.paths;

    if (_useFlutterMap) {
      if (paths.isEmpty) {
        _moveFallbackMap(_fallbackCenter, zoom: _fallbackZoom);
        return;
      }

      final points = <latlng.LatLng>[];
      for (final path in paths) {
        points.addAll(
          path.coordinates.map(
            (coord) => latlng.LatLng(coord.latitude, coord.longitude),
          ),
        );
      }

      if (points.isEmpty) return;

      final bounds = fm.LatLngBounds.fromPoints(points);
      _flutterMapController.fitCamera(
        fm.CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
      );
      _fallbackCenter = _flutterMapController.camera.center;
      _fallbackZoom = _flutterMapController.camera.zoom;
      return;
    }

    if (_mapController == null || paths.isEmpty) return;

    final allPoints = <gmap.LatLng>[];
    for (var path in paths) {
      allPoints.addAll(
        path.coordinates.map(
          (coord) => gmap.LatLng(coord.latitude, coord.longitude),
        ),
      );
    }

    if (allPoints.isNotEmpty) {
      gmap.LatLngBounds bounds = MapsService.calculateBounds(allPoints);
      await _mapController!.animateCamera(
        gmap.CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.ofOrThrow(context).get('map')),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showPathsFilter
                  ? PhosphorIcons.funnel_fill
                  : PhosphorIcons.funnel,
              color: _showPathsFilter ? AppColors.primary : null,
            ),
            onPressed: _togglePathsFilter,
          ),
        ],
      ),
      body: Stack(
        children: [
          _useFlutterMap
              ? _buildFlutterMap()
              : _buildGoogleMap(settingsProvider),

          // مؤشر التحميل
          if (_isLoading)
            const LoadingIndicator(message: 'جاري تحميل الخريطة...'),

          // فلترة المسارات
          if (_showPathsFilter)
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'فلتر المسارات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(PhosphorIcons.x),
                            onPressed: _togglePathsFilter,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // فلتر مستوى الصعوبة
                      const Text(
                        'مستوى الصعوبة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            DifficultyLevel.values.map((difficulty) {
                              return FilterChip(
                                label: Text(
                                  _getDifficultyText(difficulty, context),
                                ),
                                selected: _selectedDifficulty == difficulty,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedDifficulty =
                                        selected ? difficulty : null;
                                  });
                                  _loadPaths();
                                },
                                selectedColor: _getDifficultyColor(
                                  difficulty,
                                ).withOpacity(0.3),
                                checkmarkColor: _getDifficultyColor(difficulty),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // فلتر نوع النشاط
                      const Text(
                        'نوع النشاط',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            ActivityType.values.map((activity) {
                              return FilterChip(
                                label: Text(
                                  _getActivityText(activity, context),
                                ),
                                selected: _selectedActivity == activity,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedActivity =
                                        selected ? activity : null;
                                  });
                                  _loadPaths();
                                },
                                selectedColor: AppColors.primary.withOpacity(
                                  0.2,
                                ),
                                checkmarkColor: AppColors.primary,
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // زر مسح الفلاتر
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _clearFilters,
                          child: Text(
                            AppLocalizations.ofOrThrow(
                              context,
                            ).get('clear_filters'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // أزرار تحكم الخريطة
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // زوم إن
                MapControlButton(
                  icon: PhosphorIcons.plus,
                  onPressed: () => _changeZoom(true),
                ),
                const SizedBox(height: 8),

                // زوم آوت
                MapControlButton(
                  icon: PhosphorIcons.minus,
                  onPressed: () => _changeZoom(false),
                ),
                const SizedBox(height: 8),

                // الموقع الحالي
                MapControlButton(
                  icon: PhosphorIcons.map_pin,
                  onPressed: _centerUserLocation,
                ),
                const SizedBox(height: 8),

                // عرض جميع المسارات
                MapControlButton(
                  icon: PhosphorIcons.map_trifold,
                  onPressed: _fitAllPaths,
                ),
                const SizedBox(height: 8),

                // تغيير نوع الخريطة
                if (!_useFlutterMap)
                  MapControlButton(
                    icon:
                        settingsProvider.mapType == 'satellite'
                            ? PhosphorIcons.map_pin
                            : PhosphorIcons.stack,
                    onPressed: () {
                      final newType =
                          settingsProvider.mapType == 'satellite'
                              ? 'standard'
                              : 'satellite';
                      settingsProvider.setMapType(newType);
                    },
                  ),
              ],
            ),
          ),

          // معلومات إضافية
          Positioned(
            bottom: 24,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.7)
                        : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.5)
                            : Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Consumer<PathsProvider>(
                builder: (context, pathsProvider, child) {
                  final filteredCount =
                      pathsProvider.paths.where((path) {
                        if (_selectedDifficulty != null &&
                            path.difficulty != _selectedDifficulty) {
                          return false;
                        }
                        if (_selectedActivity != null &&
                            !path.activities.contains(_selectedActivity)) {
                          return false;
                        }
                        return true;
                      }).length;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.map_pin,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$filteredCount مسار',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  gmap.MapType _getMapType(String mapType) {
    switch (mapType) {
      case 'satellite':
        return gmap.MapType.satellite;
      case 'terrain':
        return gmap.MapType.terrain;
      case 'hybrid':
        return gmap.MapType.hybrid;
      default:
        return gmap.MapType.normal;
    }
  }

  String _getDifficultyText(DifficultyLevel difficulty, BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    switch (difficulty) {
      case DifficultyLevel.easy:
        return localizations.get('easy');
      case DifficultyLevel.medium:
        return localizations.get('medium');
      case DifficultyLevel.hard:
        return localizations.get('hard');
    }
  }

  String _getActivityText(ActivityType activity, BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    switch (activity) {
      case ActivityType.hiking:
        return localizations.get('hiking');
      case ActivityType.camping:
        return localizations.get('camping');
      case ActivityType.climbing:
        return localizations.get('climbing');
      case ActivityType.religious:
        return localizations.get('religious');
      case ActivityType.cultural:
        return localizations.get('cultural');
      case ActivityType.nature:
        return localizations.get('nature');
      case ActivityType.archaeological:
        return localizations.get('archaeological');
    }
  }
}
