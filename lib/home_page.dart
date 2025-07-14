//import 'package:carbon_tracker/camera.dart';
import 'package:flutter/material.dart';
import 'semi_circle_menu.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' hide PermissionStatus;



void main() {
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

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;

  final LatLng _fallbackLocation = LatLng(25.033964, 121.564468); // Taipei 101
  LatLng? _userLocation = LatLng(25.033964, 121.564468);

  final Location _locationService = Location();

  @override
  void initState() {
    super.initState();
    _recorder = Record();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocation();
    });
  }

  Future<void> _initLocation() async {
    //print('Requesting permission...');
    try {
      final permissionStatus = await _locationService.requestPermission();
      //print('Permission status: $permissionStatus');

      bool serviceEnabled = await _locationService.serviceEnabled();
      //print('Service enabled before request: $serviceEnabled');

      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        //rint('Service enabled after request: $serviceEnabled');
      }

      if (permissionStatus == PermissionStatus.granted && serviceEnabled) {
        final locationData = await _locationService.getLocation();
        print(
          'Got location: ${locationData.latitude}, ${locationData.longitude}',
        );
        setState(() {
          _userLocation = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
        });
      } else {
        //print('Permission denied or service not enabled');

        setState(() {
          _userLocation = _fallbackLocation;
        });
      }
    } catch (e) {
      //print('Error while requesting location: $e');

      setState(() {
        _userLocation = _fallbackLocation;
      });
    }
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
    } catch (e) {
      //print('Could not get current location: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    _locationService.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        final newPos = LatLng(locationData.latitude!, locationData.longitude!);
        mapController.animateCamera(CameraUpdate.newLatLng(newPos));
      }
    });
  }

    final ImagePicker _picker = ImagePicker();
    File? _mediaFile;
    bool _isVideo = false;

    Future<void> _pickMedia(bool isVideo) async {
      final XFile? file = isVideo
          ? await _picker.pickVideo(source: ImageSource.camera)
          : await _picker.pickImage(source: ImageSource.camera);

      if (file != null) {
        setState(() {
          _mediaFile = File(file.path);
          _isVideo = isVideo;
        });
      }
    }

    late Record _recorder;          // 初始化位置：initState() 裡記得加上 _recorder = Record();
    bool _isRecording = false;      // 是否正在錄音
    String? _recordedPath;          // 錄音檔路徑

    void _toggleRecording() async {
      if (_isRecording) {
        final path = await _recorder.stop();
        print('✅ 錄音停止：$path');
        setState(() {
          _isRecording = false;
          _recordedPath = path;
        });
      } else {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          print('❌ 沒有麥克風權限');
          return;
        }

        final dir = await getApplicationDocumentsDirectory();
        final filePath =
            '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          path: filePath,
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          samplingRate: 44100,
        );

        print('🎙️ 開始錄音，儲存於：$filePath');
        setState(() {
          _isRecording = true;
          _recordedPath = filePath;
        });
      }
    }

    void _showNoteSheet() {
      TextEditingController _noteController = TextEditingController();

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'location', 
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Write something',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      String note = _noteController.text;
                      // TODO: 存記事
                      print('保存記事：$note');
                      Navigator.pop(context);
                    },
                    child: Text('post'),
                  ),
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
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          child: Row(
            children: [
              Icon(CupertinoIcons.list_bullet, size: 20),
              SizedBox(width: 8),
              Text('note'),
            ],
          ),
          onPressed: () {
            _showNoteSheet();
          },
        ),
        CupertinoActionSheetAction(
          child: Row(
            children: [
              Icon(CupertinoIcons.camera, size: 20),
              SizedBox(width: 8),
              Text('Photo'),
            ],
          ),
          onPressed: () {
            Navigator.pop(context);
            _pickMedia(false);
          },
        ),
        /*CupertinoActionSheetAction(
          child: Row(
            children: [
              Icon(CupertinoIcons.videocam, size: 20),
              SizedBox(width: 8),
              Text('Video'),
            ],
          ),
          onPressed: () {
            Navigator.pop(context);
            _pickMedia(true); 
          },
        ),*/
        CupertinoActionSheetAction(
          
          child: Row(
            children: [
              Icon(CupertinoIcons.mic, size: 20),
              SizedBox(width: 8),
              Text('Record'),
            ],
          ),
          onPressed: () {
            Navigator.pop(context);
            _toggleRecording();
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDestructiveAction: true,
        child: Text('Cancel'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
  );
    }


  /*final ImagePicker _picker = ImagePicker();
    File? _imageFile;

    Future<void> _takePhoto() async {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
      }
    }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _userLocation!,
              zoom: 16,
            ),
          
          
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          /*Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 860,
              width: double.infinity,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 14,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
            ),
          ), 
*/
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
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CameraPage()),
                  );*/
                  //_takePhoto();
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
                Icons.flight,
                Icons.directions_car,
                Icons.directions_walk,
                Icons.directions_bike,
                Icons.two_wheeler,
                Icons.train,
                Icons.subway,
              ],
              radius: 80,
              onItemTap: (index) {
                print('Tapped on $index');
              },
            ),
          ),
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width / 2 - 70,
            child: GestureDetector(
              onTap: _relocateToUser,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.navigation_sharp,
                  color: Colors.white,
                  size: 70,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 5 - 50,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.access_time_outlined),
              iconSize: 50,
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
                splashColor: Colors.green.shade300.withValues(alpha: 0.6),
                highlightColor: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 30,
                  backgroundImage: AssetImage("assets/leaderboard.png"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}