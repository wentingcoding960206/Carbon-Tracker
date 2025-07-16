// 👉 新增這個檔案或放進你主程式最下方（可分檔）
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

class PostItem {
  final LatLng location;
  final String? imagePath;
  final String? audioPath;
  final String? noteText;

  PostItem({
    required this.location,
    this.imagePath,
    this.audioPath,
    this.noteText,
  });
}

class PostManager {
  final BuildContext context;
  final Set<Marker> markers;
  final List<PostItem> posts;
  final void Function(void Function()) setState;

  final Record _recorder = Record();
  bool isRecording = false;

  PostManager({
    required this.context,
    required this.markers,
    required this.posts,
    required this.setState,
  });

  Future<LatLng?> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.camera);

    if (file == null) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}.${file.path.split(".").last}';
    final String newPath = '${appDir.path}/$fileName';
    final savedFile = await File(file.path).copy(newPath);

    final LatLng? loc = await _getCurrentLocation();
    if (loc == null) return;

    final post = PostItem(location: loc, imagePath: savedFile.path);
    _addPostMarker(post);
  }

  Future<void> startOrStopRecording() async {
    if (isRecording) {
      final path = await _recorder.stop();
      isRecording = false;
      final loc = await _getCurrentLocation();
      if (loc == null || path == null) return;
      final post = PostItem(location: loc, audioPath: path);
      _addPostMarker(post);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        path: filePath,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );
      isRecording = true;
    }
  }

  void saveNote(String noteText) async {
    final loc = await _getCurrentLocation();
    if (loc == null) return;
    final post = PostItem(location: loc, noteText: noteText);
    _addPostMarker(post);
  }

  void _addPostMarker(PostItem item) {
    final markerId = MarkerId(DateTime.now().toIso8601String());
    final marker = Marker(
      markerId: markerId,
      position: item.location,
      infoWindow: InfoWindow(
        title: "查看內容",
        onTap: () => _showPostDetail(item),
      ),
    );

    setState(() {
      posts.add(item);
      markers.add(marker);
    });
  }

  void _showPostDetail(PostItem item) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.imagePath != null) Image.file(File(item.imagePath!)),
              if (item.audioPath != null)
                Text('🎙 錄音檔：${item.audioPath!}'),
              if (item.noteText != null) Text('📝 ${item.noteText!}'),
            ],
          ),
        );
      },
    );
  }
}