import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '錄音測試',
      home: Scaffold(
        appBar: AppBar(title: const Text('錄音按鈕')),
        body: const Center(child: RecordButton()),
      ),
    );
  }
}

class RecordButton extends StatefulWidget {
  const RecordButton({super.key});
  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  final Record _recorder = Record();
  bool _isRecording = false;
  String? _filePath;

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _filePath = path;
      });
      print('✅ 錄音完成，檔案儲存在：$path');
    } else {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        print('❌ 沒有取得麥克風權限');
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

      setState(() {
        _isRecording = true;
        _filePath = filePath;
      });
      print('🎙️ 開始錄音...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _toggleRecording,
          child: Text(_isRecording ? '停止錄音' : '開始錄音'),
        ),
        const SizedBox(height: 20),
        if (_filePath != null) Text('錄音檔路徑：\n$_filePath'),
      ],
    );
  }
}



/*import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

final record = AudioRecorder();
String? _audioPath;

Future<void> _startRecording() async {
  final status = await Permission.microphone.request();
  if (!status.isGranted) {
    print('未取得錄音權限');
    return;
  }

  final dir = await getApplicationDocumentsDirectory();
  final filepath = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

  await record.start(const RecordConfig(), path: filepath);
  print('錄音中...');
}

Future<void> _stopRecording() async {
  final path = await record.stop();
  print('錄音結束：$path');
  _audioPath = path;
}

class _CameraPageState extends State<CameraPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('拍照示範'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile == null
                ? Text('尚未拍照')
                : Image.file(
                    _imageFile!,
                    width: 300,
                    height: 400,
                    fit: BoxFit.cover,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startRecording();
            ),
          ],
        ),
      ),
    );
  }
}



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PhotoAlbumPage extends StatefulWidget {
  @override
  _PhotoAlbumPageState createState() => _PhotoAlbumPageState();
}

class _PhotoAlbumPageState extends State<PhotoAlbumPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  // 載入本地照片
  Future<void> _loadPhotos() async {
    final dir = await getApplicationDocumentsDirectory();
    final albumDir = Directory(path.join(dir.path, 'my_album'));

    if (await albumDir.exists()) {
      final files = albumDir.listSync();
      List<File> photos = [];
      for (var f in files) {
        if (f is File && _isImageFile(f.path)) {
          photos.add(f);
        }
      }
      setState(() {
        _photos = photos;
      });
    }
  }

  bool _isImageFile(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ['.png', '.jpg', '.jpeg', '.gif'].contains(ext);
  }

  // 拍照並存到相簿資料夾
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final albumDir = Directory(path.join(dir.path, 'my_album'));
    if (!await albumDir.exists()) {
      await albumDir.create(recursive: true);
    }

    // 存檔名稱，使用時間避免重複
    final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}';
    final savedPath = path.join(albumDir.path, fileName);

    final savedFile = await File(photo.path).copy(savedPath);

    setState(() {
      _photos.add(savedFile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('本地相簿'),
      ),
      body: _photos.isEmpty
          ? Center(child: Text('尚無照片，請拍照'))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoPreviewPage(photo: photo),
                      ),
                    );
                  },
                  child: Image.file(
                    photo,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhoto,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}

class PhotoPreviewPage extends StatelessWidget {
  final File photo;
  const PhotoPreviewPage({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.file(photo),
      ),
    );
  }
}
*/