//import 'dart:convert';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsFlutter extends StatefulWidget {
  const GoogleMapsFlutter({super.key});

  @override
  State<GoogleMapsFlutter> createState() => _GoogleMapsFlutterState();
}

class _GoogleMapsFlutterState extends State<GoogleMapsFlutter> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(25.0215, 121.3345);
  static const LatLng destinaion = LatLng(25.0215, 121.3345);
  //LatLng myCurrentLocation = LatLng(25.0215, 121.3345);


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
        target: sourceLocation, zoom : 15
         ),
         markers: {
          Marker(
            markerId: MarkerId("source"), 
            position: sourceLocation,
          ),
          Marker(
            markerId: MarkerId("destination"), 
            position: destinaion,
          ),
         },
      )
    );
  }
}