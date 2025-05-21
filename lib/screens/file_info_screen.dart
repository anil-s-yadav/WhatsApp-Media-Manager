import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

class FileInfoScreen extends StatefulWidget {
  final File file;

  const FileInfoScreen({super.key, required this.file});

  @override
  State<FileInfoScreen> createState() => _FileInfoScreenState();
}

class _FileInfoScreenState extends State<FileInfoScreen> {
  Map<String, dynamic> _imageInfo = {};
  bool _isImage = false;

  @override
  void initState() {
    super.initState();
    _loadImageInfo();
  }

  Future<void> _loadImageInfo() async {
    final ext = p.extension(widget.file.path).toLowerCase();
    if ([".jpg", ".jpeg", ".png", ".gif"].contains(ext)) {
      _isImage = true;
      try {
        final bytes = await widget.file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          setState(() {
            _imageInfo = {
              'width': decoded.width,
              'height': decoded.height,
              'exif': decoded.exif.directories,
            };
          });
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final stat = widget.file.statSync();
    final sizeMB = (stat.size / (1024 * 1024)).toStringAsFixed(2);
    final modified = DateFormat('d MMM yyyy, h:mm a').format(stat.modified);
    final name = p.basename(widget.file.path);
    final path = widget.file.path;
    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202C33),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('File Info', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (_isImage)
            Center(
              child: Image.file(
                widget.file,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 24),
          _infoRow(Icons.insert_drive_file, 'Name', name),
          _infoRow(Icons.folder, 'Path', path),
          _infoRow(Icons.sd_storage, 'Size', '$sizeMB MB'),
          _infoRow(Icons.event, 'Modified', modified),
          if (_isImage && _imageInfo.isNotEmpty) ...[
            _infoRow(Icons.photo_size_select_large, 'Resolution',
                '${_imageInfo['width']} x ${_imageInfo['height']}'),
            if (_imageInfo['exif'] != null && _imageInfo['exif'] is Map)
              ..._exifRows(_imageInfo['exif'] as Map),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00A884)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _exifRows(Map exif) {
    final keys = [
      'Model',
      'Make',
      'FocalLength',
      'ISOSpeedRatings',
      'ExposureTime',
      'FNumber',
      'DateTimeOriginal'
    ];
    final labels = {
      'Model': 'Device',
      'Make': 'Brand',
      'FocalLength': 'Focal Length',
      'ISOSpeedRatings': 'ISO',
      'ExposureTime': 'Exposure',
      'FNumber': 'Aperture',
      'DateTimeOriginal': 'Taken',
    };
    return [
      for (final k in keys)
        if (exif[k] != null)
          _infoRow(Icons.info_outline, labels[k] ?? k, exif[k].toString()),
    ];
  }
}
