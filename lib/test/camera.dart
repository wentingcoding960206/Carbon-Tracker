import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;

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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('照片已儲存')));
  }

  Future<void> _recordVideo() async {
    await Permission.camera.request();
    final path = await _getDirectory('videos');
    final filePath = '$path/${DateTime.now().millisecondsSinceEpoch}.mp4';

    if (_cameraController!.value.isRecordingVideo) {
      final file = await _cameraController!.stopVideoRecording();
      await file.saveTo(filePath);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('影片已儲存')));
    } else {
      await _cameraController!.startVideoRecording();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('拍照 / 錄影')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: _takePhoto, child: const Text('拍照')),
              ElevatedButton(
                onPressed: _recordVideo,
                child: Text(_cameraController!.value.isRecordingVideo ? '停止錄影' : '開始錄影'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
