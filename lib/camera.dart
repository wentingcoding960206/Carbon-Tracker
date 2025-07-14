import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
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
              onPressed: _takePhoto,
              child: Text('拍照'),
            ),
          ],
        ),
      ),
    );
  }
}



/*import 'dart:io';
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