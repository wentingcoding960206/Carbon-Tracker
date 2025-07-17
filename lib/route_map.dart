import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RouteMap extends StatefulWidget {
  const RouteMap({super.key});

  @override
  RouteMapState createState() => RouteMapState();
}

class RouteMapState extends State<RouteMap> {
  late GoogleMapController _mapController;
  final Location _location = Location();

  final List<List<LatLng>> _allRoutePoints = [];
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

  Future<void> _loadRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('routes') ?? [];
    _allRoutePoints.clear();
    for (var jsonStr in jsonList) {
      List<dynamic> pointsJson = jsonDecode(jsonStr);
      List<LatLng> routePoints = pointsJson
          .map((p) => LatLng(p['lat'] as double, p['lng'] as double))
          .toList();
      _allRoutePoints.add(routePoints);
    }
    _updatePolylines();
  }

  Future<void> _saveRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = _allRoutePoints.map((route) {
      return jsonEncode(route
          .map((point) => {'lat': point.latitude, 'lng': point.longitude})
          .toList());
    }).toList();
    await prefs.setStringList('routes', jsonList);
  }

  void _updatePolylines() {
    _polylines.clear();
    for (int i = 0; i < _allRoutePoints.length; i++) {
      _polylines.add(Polyline(
        polylineId: PolylineId("route_$i"),
        color: Colors.blue,
        width: 6,
        points: _allRoutePoints[i],
      ));
    }
    setState(() {});
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
    _allRoutePoints.add(_currentRoutePoints);

    _location.changeSettings(interval: interval, distanceFilter: 0);

    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (!isRecording) return;

      if (locationData.latitude != null && locationData.longitude != null) {
        LatLng newPoint = LatLng(locationData.latitude!, locationData.longitude!);
        _currentRoutePoints.add(newPoint);
        _updatePolylines();

        if (_currentRoutePoints.length == 1) {
          _mapController.animateCamera(CameraUpdate.newLatLngZoom(newPoint, 16));
        }
      }
    });

    isRecording = true;
    setState(() {});
  }

  Future<void> stopRecording() async {
    if (!isRecording) return;

    isRecording = false;
    await _saveRoutes();

    await _locationSubscription?.cancel();
    _locationSubscription = null;

    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
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
