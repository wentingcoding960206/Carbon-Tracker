/*import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => Timeline();
}

class Timeline extends State<TimelinePage> {
  DateTime selectedDate = DateTime.now();
  final List<Map<String, dynamic>> timelineData = [];
  final List<LatLng> routeCoords = [];
  GoogleMapController? mapController;
  Position? lastPosition;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  Future<void> _startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (lastPosition != null) {
        final speed = position.speed;
        String activity;
        IconData icon;
        if (speed < 1.5) {
          activity = "Walking";
          icon = Icons.directions_walk;
        } else if (speed < 6) {
          activity = "Cycling";
          icon = Icons.pedal_bike;
        } else {
          activity = "Driving";
          icon = Icons.directions_car;
        }

        timelineData.add({
          'time': DateFormat('HH:mm').format(DateTime.now()),
          'title': activity,
          'subtitle': "Lat: ${position.latitude}, Lng: ${position.longitude}",
          'icon': icon
        });
      }

      lastPosition = position;
      routeCoords.add(LatLng(position.latitude, position.longitude));
      setState(() {});
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // TODO: Load timeline data for the picked date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travel Timeline"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blueGrey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                Text("Entries: ${timelineData.length}"),
              ],
            ),
          ),
          SizedBox(
            height: 250,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(25.0330, 121.5654),
                zoom: 14,
              ),
              onMapCreated: (controller) => mapController = controller,
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  color: Colors.blue,
                  width: 5,
                  points: routeCoords,
                )
              },
              markers: routeCoords
                  .map((point) => Marker(
                        markerId: MarkerId(point.toString()),
                        position: point,
                      ))
                  .toSet(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: timelineData.length,
              itemBuilder: (context, index) {
                final item = timelineData[index];
                return TimelineTile(
                  alignment: TimelineAlign.manual,
                  lineXY: 0.2,
                  isFirst: index == 0,
                  isLast: index == timelineData.length - 1,
                  indicatorStyle: IndicatorStyle(
                    width: 20,
                    color: Colors.blue,
                    iconStyle: IconStyle(
                      iconData: item['icon'],
                      color: Colors.white,
                    ),
                  ),
                  beforeLineStyle: const LineStyle(color: Colors.grey),
                  endChild: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['time'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(item['title'],
                            style: const TextStyle(fontSize: 16)),
                        Text(item['subtitle'],
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}*/