import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
//import 'package:record/record.dart';

class MediaCapturePage extends StatefulWidget {
  const MediaCapturePage({super.key});

  @override
  _MediaCapturePageState createState() => _MediaCapturePageState();
}

class _MediaCapturePageState extends State<MediaCapturePage> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  //final recorder = Record();
  bool isRecordingAudio = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<String> _getDirectory(String type) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/$type');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder.path;
  }

  Future<void> _takePhoto() async {
    await Permission.camera.request();
    final path = await _getDirectory('photos');
    final file = await _cameraController!.takePicture();
    await file.saveTo('$path/${DateTime.now().millisecondsSinceEpoch}.jpg');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('照片已儲存')));
  }

  Future<void> _recordVideo() async {
    await Permission.camera.request();
    final path = await _getDirectory('videos');
    final filePath = '$path/${DateTime.now().millisecondsSinceEpoch}.mp4';

    if (_cameraController!.value.isRecordingVideo) {
      final file = await _cameraController!.stopVideoRecording();
      await file.saveTo(filePath);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('影片已儲存')));
    } else {
      await _cameraController!.startVideoRecording();
    }

    setState(() {});
  }

  Future<void> _recordAudio() async {
    await Permission.microphone.request();
    final path = await _getDirectory('audios');
    final filePath = '$path/${DateTime.now().millisecondsSinceEpoch}.m4a';

    /*if (await recorder.isRecording()) {
      await recorder.stop();
      setState(() => isRecordingAudio = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('錄音已儲存')));
    } else {
      await recorder.start(path: filePath);
      setState(() => isRecordingAudio = true);
    }*/
  }

  @override
  /*void dispose() {
    _cameraController?.dispose();
    recorder.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('拍照 / 錄影 / 錄音')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: _takePhoto, child: Text('拍照')),
              ElevatedButton(
                onPressed: _recordVideo,
                child: Text(_cameraController!.value.isRecordingVideo ? '停止錄影' : '開始錄影'),
              ),
              ElevatedButton(
                onPressed: _recordAudio,
                child: Text(isRecordingAudio ? '停止錄音' : '錄音'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
