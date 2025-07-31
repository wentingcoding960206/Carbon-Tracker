import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RouteMap extends StatefulWidget {
  final Set<Marker> markers;
  final ValueChanged<bool>? onRecordingChanged;
  const RouteMap({
    super.key,
    required this.markers,
    required this.onRecordingChanged,
  });

  @override
  RouteMapState createState() => RouteMapState();
}

class RouteData {
  List<LatLng> points;
  int iconIndex;

  RouteData(this.points, this.iconIndex);
}

class RouteMapState extends State<RouteMap> {

  double _calculateTotalDistance(List<LatLng> path) {
    double totalDistance = 0.0;

    for (int i = 0; i < path.length - 1; i++) {
      totalDistance += _coordinateDistance(
        path[i].latitude,
        path[i].longitude,
        path[i + 1].latitude,
        path[i + 1].longitude,
      );
    }

    return totalDistance;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371000; // 地球半徑（公尺）
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }


  late GoogleMapController _mapController;
  final Location _location = Location();

  final List<RouteData> _allRoutes = [];
  List<LatLng> _currentRoutePoints = [];

  final Set<Polyline> _polylines = {};

  bool isRecording = false;
  int? _currentIconIndex;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void addLocation(LatLng location) {
    setState(() {
      _currentRoutePoints.add(location);
      _allRoutes[_allRoutes.length - 1].points = List.from(_currentRoutePoints);
      _updatePolylines();
    });
  }

  Future<void> _loadRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('routes') ?? [];
    _allRoutes.clear();
    for (var jsonStr in jsonList) {
      var routeJson = jsonDecode(jsonStr);
      int iconIndex = routeJson['iconIndex'];
      List<dynamic> pointsJson = routeJson['points'];
      List<LatLng> routePoints = pointsJson
          .map((p) => LatLng(p['lat'] as double, p['lng'] as double))
          .toList();

      _allRoutes.add(RouteData(routePoints, iconIndex));
    }
    _updatePolylines();
  }

  Future<void> _saveRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = _allRoutes.map((routeData) {
      return jsonEncode({
        'iconIndex': routeData.iconIndex,
        'points': routeData.points
            .map((point) => {'lat': point.latitude, 'lng': point.longitude})
            .toList(),
      });
    }).toList();
    await prefs.setStringList('routes', jsonList);
  }

  void _updatePolylines() {
    _polylines.clear();
    for (int i = 0; i < _allRoutes.length; i++) {
      final route = _allRoutes[i];
      _polylines.add(
        Polyline(
          polylineId: PolylineId("route_$i"),
          color: _getColorByIcon(route.iconIndex),
          width: 6,
          points: route.points,
        ),
      );
    }
    setState(() {});
  }

  Color _getColorByIcon(int iconIndex) {
    switch (iconIndex) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.red;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.brown;
      case 6:
        return Colors.cyan;
      default:
        return Colors.black;
    }
  }

  int _getIntervalByIcon(int index) {
    switch (index) {
      case 0:
        return 1000;
      case 1:
        return 2000;
      case 2:
        return 3000;
      case 3:
        return 1500;
      case 4:
        return 1200;
      case 5:
        return 1800;
      case 6:
        return 1800;
      default:
        return 1000;
    }
  }

  Future<bool> _checkPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    final permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      final permReq = await _location.requestPermission();
      if (permReq != PermissionStatus.granted) return false;
    }
    return true;
  }

  Future<void> startRecording({required int iconIndex}) async {
    if (isRecording) return;

    final permissionOk = await _checkPermissions();
    if (!permissionOk) {
      debugPrint("Location permission/service not granted");
      return;
    }

    _currentIconIndex = iconIndex;
    int interval = _getIntervalByIcon(iconIndex);

    _currentRoutePoints = [];
    _allRoutes.add(RouteData(_currentRoutePoints, iconIndex));
    isRecording = true;
    widget.onRecordingChanged?.call(isRecording);

    _location.changeSettings(interval: interval, distanceFilter: 0);

    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (!isRecording) return;

      if (locationData.latitude != null && locationData.longitude != null) {
        LatLng newPoint = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );

        _currentRoutePoints.add(newPoint);
        _allRoutes[_allRoutes.length - 1].points = List.from(
          _currentRoutePoints,
        );

        _updatePolylines();

        if (_currentRoutePoints.length == 1) {
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(newPoint, 16),
          );
        }
      }
    });

    setState(() {});
  }

  Future<void> stopRecording() async {
    if (!isRecording) return;

    isRecording = false;
    widget.onRecordingChanged?.call(isRecording);
    await _saveRoutes();

    await _locationSubscription?.cancel();
    _locationSubscription = null;

  final distance = _calculateTotalDistance(_currentRoutePoints);
  debugPrint('🟢 你這次共走了：${distance.toStringAsFixed(2)} 公尺');

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("紀錄完成"),
      content: Text("你這次走了 ${distance.toStringAsFixed(2)} 公尺"),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () => Navigator.pop(context),
        )
      ],
    ),
  );


    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: widget.markers,
      initialCameraPosition: const CameraPosition(
        target: LatLng(25.033964, 121.564468),
        zoom: 14,
      ),
      onMapCreated: _onMapCreated,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      polylines: _polylines,
    );
  }
}
