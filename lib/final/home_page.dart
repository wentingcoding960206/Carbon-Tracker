import 'package:carbon_tracker/database_helper.dart';
import 'package:carbon_tracker/route_map.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'semi_circle_menu.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;
import 'package:audioplayers/audioplayers.dart';
//import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class PostData {
  final LatLng location;
  final String type;
  final String content;

  PostData({required this.location, required this.type, required this.content});
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;

  final Set<Marker> _markers = {};
  final List<PostData> _posts = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  final LatLng _fallbackLocation = LatLng(25.033964, 121.564468);
  LatLng? _userLocation = LatLng(25.033964, 121.564468);

  final Location _locationService = Location();

  int selectedIconIndex = 0;
  final GlobalKey<RouteMapState> _mapKey = GlobalKey<RouteMapState>();

  void _logAllEntries() async {
    final entries = await DatabaseHelper().getEntries();
    for (var entry in entries) {
      print('📝 Entry:');
      print('Type: ${entry['type']}');
      print('Path: ${entry['path']}');
      print('Note: ${entry['note']}');
      print('Timestamp: ${entry['timestamp']}');
      print('latitude: ${entry['latitude']}');
      print('longitude: ${entry['longitude']}');
      print('-------------------------');
    }
  }

  @override
  void initState() {
    super.initState();
    print('initState reached');
    _recorder = Record();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Post frame callback started');
      try {
        print('Calling _initLocation...');
        await _initLocation();
        print('_initLocation completed');

        print('Calling getEntries...');
        final entries = await DatabaseHelper().getEntries();
        print('Entries loaded: ${entries.length}');
        for (var e in entries) {
          print('Entry: $e');
        }

        print('Calling _loadMarkersFromDB...');
        await _loadMarkersFromDB();
        print('_loadMarkersFromDB completed');
      } catch (e, st) {
        print('Error in postFrameCallback: $e');
        print(st);
      }
    });

  }

  Future<void> _initLocation() async {
    try {
      print('Requesting permission...');
      PermissionStatus permissionStatus;
      try {
        permissionStatus = await _locationService.requestPermission();
        print('Permission status: $permissionStatus');
      } catch (e) {
        print('Error requesting permission: $e');
        rethrow;
      }

      bool serviceEnabled;
      try {
        serviceEnabled = await _locationService.serviceEnabled();
        print('Service enabled: $serviceEnabled');
      } catch (e) {
        print('Error checking service enabled: $e');
        rethrow;
      }

      if (!serviceEnabled) {
        try {
          print('Requesting service enable...');
          serviceEnabled = await _locationService.requestService();
          print('Service enabled after request: $serviceEnabled');
        } catch (e) {
          print('Error requesting service enable: $e');
          rethrow;
        }
      }

      if (permissionStatus == PermissionStatus.granted && serviceEnabled) {
        try {
          print('Getting location...');
          final locationData = await _locationService.getLocation().timeout(
            Duration(seconds: 10),
          );
          print('Location data: $locationData');
          setState(() {
            _userLocation = LatLng(
              locationData.latitude!,
              locationData.longitude!,
            );
          });
        } catch (e) {
          print('Error getting location or timeout: $e');
          setState(() {
            _userLocation = _fallbackLocation;
          });
        }

      } else {
        print('Permission denied or service disabled');
        setState(() {
          _userLocation = _fallbackLocation;
        });
      }
    } catch (e, st) {
      print('Error in _initLocation: $e');
      print(st);
      setState(() {
        _userLocation = _fallbackLocation;
      });
    }
  }

  Future<void> _loadMarkersFromDB() async {
    await _initLocation();
    final entries = await DatabaseHelper().getEntries();
    print('Loaded entries count: ${entries.length}'); // DEBUG

    final Map<String, List<PostData>> grouped = {};

    for (var entry in entries) {
      final lat = entry['latitude'];
      final lng = entry['longitude'];
      final key = '$lat,$lng';

      final post = PostData(
        location: LatLng(lat, lng),
        type: entry['type'],
        content: entry['type'] == 'note' ? entry['note'] : entry['path'],
      );

      grouped.putIfAbsent(key, () => []).add(post);
    }

    setState(() {
      _markers.clear();
      grouped.forEach((key, posts) {
        _markers.add(
          Marker(
            markerId: MarkerId(key),
            position: posts[0].location,
            onTap: () => _showPostsListSheet(posts),
          ),
        );
      });
    });

    print('Markers loaded: ${_markers.length}'); // DEBUG
  }


  Future<void> _relocateToUser() async {
    try {
      final locationData = await _locationService.getLocation();
      final currentLocation = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      setState(() {
        _userLocation = currentLocation;
      });
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation, zoom: 16),
        ),
      );
    } catch (e) {}
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    _locationService.onLocationChanged.listen((locationData) {
      final newPos = LatLng(locationData.latitude!, locationData.longitude!);
      mapController.animateCamera(CameraUpdate.newLatLng(newPos));

      // Forward to RouteMap
      if (_mapKey.currentState?.isRecording ?? false) {
        _mapKey.currentState?.addLocation(newPos);
      }
    });


    // _locationService.onLocationChanged.listen((locationData) {
    //   if (locationData.latitude != null && locationData.longitude != null) {
    //     final newPos = LatLng(locationData.latitude!, locationData.longitude!);
    //     mapController.animateCamera(CameraUpdate.newLatLng(newPos));
    //   }
    // });
  }

  final ImagePicker _picker = ImagePicker();
  File? _mediaFile;
  final bool _isVideo = false;

  Future<void> _pickMedia(bool isVideo) async {
    final XFile? file = isVideo
        ? await _picker.pickVideo(source: ImageSource.camera)
        : await _picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final String newPath = path.join(appDir.path, fileName);
      final savedFile = await File(file.path).copy(newPath);

      await DatabaseHelper().insertEntry({
        'type': isVideo ? 'video' : 'image',
        'path': newPath,
        'note': '',
        'latitude': _userLocation!.latitude,
        'longitude': _userLocation!.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });

      _logAllEntries();

      await _loadMarkersFromDB();
    }
  }

  late Record _recorder;
  bool _isRecording = false;
  String? _recordedPath;

  void _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      await DatabaseHelper().insertEntry({
        'type': 'audio',
        'path': path,
        'note': '',
        'latitude': _userLocation!.latitude,
        'longitude': _userLocation!.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });

      _logAllEntries();

      await _loadMarkersFromDB();
      setState(() {
        _isRecording = false;
        _recordedPath = path;
      });
    } else {
      final status = await Permission.microphone.request();
      if (!status.isGranted) return;

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        path: filePath,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );

      setState(() {
        _isRecording = true;
        _recordedPath = filePath;
      });
    }
  }

  void _showNoteSheet() {
    TextEditingController noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noteController,
                maxLines: null,
                decoration: InputDecoration(hintText: 'Write something'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String note = noteController.text;
                  if (_userLocation != null && note.isNotEmpty) {
                    await DatabaseHelper().insertEntry({
                      'type': 'note',
                      'path': '',
                      'note': note,
                      'latitude': _userLocation!.latitude,
                      'longitude': _userLocation!.longitude,
                      'timestamp': DateTime.now().toIso8601String(),
                    });

                    print("${_userLocation!.latitude} ${_userLocation!.longitude}");

                    _logAllEntries();

                    await _loadMarkersFromDB();
                    Navigator.pop(context);
                  }
                },
                child: Text('Post'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMediaOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Choose'),
        actions: [
          CupertinoActionSheetAction(
            child: Text('Note'),
            onPressed: () {
              Navigator.pop(context);
              _showNoteSheet();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Photo'),
            onPressed: () {
              Navigator.pop(context);
              _pickMedia(false);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Record'),
            onPressed: () {
              Navigator.pop(context);
              _toggleRecording();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ),
    );
  }

  void _showPostsListSheet(List<PostData> posts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.8;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: height,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return ListTile(
                          title: Text(post.type),
                          subtitle: Text(post.content),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await DatabaseHelper().deleteEntry(post.content);
                              await _loadMarkersFromDB();

                              // IMPORTANT: call setModalState here, inside StatefulBuilder
                              setModalState(() {
                                posts.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    if (_userLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          RouteMap(key: _mapKey, markers: _markers,  onRecordingChanged: (recording) {
              setState(() {
                // just to trigger rebuild for icon color update
              });
            },
          ),


          // GoogleMap(
          //   onMapCreated: _onMapCreated,
          //   initialCameraPosition: CameraPosition(
          //     target: _userLocation!,
          //     zoom: 16,
          //   ),
          //   markers: _markers,
          //   myLocationEnabled: true,
          //   myLocationButtonEnabled: false,
          // ),

          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: IconButton(
                icon: Icon(Icons.person_2_outlined),
                iconSize: 40,
                onPressed: () {},
              ),
            ),
          ),

          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 90),
              child: IconButton(
                icon: Icon(Icons.camera_alt_outlined),
                iconSize: 40,
                onPressed: () {
                  _showMediaOptions(context);
                },
              ),
            ),
          ),

          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: IconButton(
                icon: Icon(Icons.edit),
                iconSize: 40,
                onPressed: () {},
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.green.shade300,
            ),
          ),

          Positioned(
            bottom: 90,
            left: MediaQuery.of(context).size.width / 2 - 92,
            child: SemiCircleMenu(
              icons: [
                Icons.flight,//255g/km
                Icons.directions_car,//110g/km
                Icons.directions_walk,//0
                Icons.directions_bike,//19.7g/km
                Icons.two_wheeler,//100g.km
                Icons.train,//35g/km
                Icons.subway,//40g/km
              ],
              radius: 80,
              onItemTap: (index) {
                setState(() {
                  selectedIconIndex = index;
                });
                print('Tapped on $index');
              }, distanceInMeters: 0.0, userId: '',//0.0->null
            ),
          ),

          // Positioned(
          //   bottom: 30,
          //   left: MediaQuery.of(context).size.width / 2 - 70,
          //   child: GestureDetector(
          //     onTap: _relocateToUser,
          //     child: CircleAvatar(
          //       radius: 70,
          //       backgroundColor: Colors.black,
          //       child: Icon(
          //         Icons.navigation_sharp,
          //         color: Colors.white,
          //         size: 70,
          //       ),
          //     ),
          //   ),
          // ),

          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 79,
            child: IconButton(
              onPressed: () {
                if (_mapKey.currentState != null) {
                  final isRecording = _mapKey.currentState!.isRecording;

                  setState(() {
                    if (isRecording) {
                      _mapKey.currentState!.stopRecording();
                    } else {
                      _mapKey.currentState!.startRecording(
                        iconIndex: selectedIconIndex,
                      );
                    }
                  });
                }
              },

              icon: CircleAvatar(
                radius: 70,
                backgroundColor: _mapKey.currentState?.isRecording == true
                    ? Colors.red
                    : Colors.black,
                child: const Icon(
                  Icons.navigation_sharp,
                  color: Colors.white,
                  size: 70,
                ),
              ),
            ),
          ),


          Positioned(
            bottom: 20,
            right: MediaQuery.of(context).size.width / 5 - 40,
            child: Material(
              color: Colors.transparent,
              elevation: 0,
              shape: CircleBorder(),
              child: InkWell(
                onTap: () {},
                splashColor: Colors.green.shade300.withOpacity(0.6),
                highlightColor: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 30,
                  //backgroundImage: AssetImage("assets/leaderboard.png"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

