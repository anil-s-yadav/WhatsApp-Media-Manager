import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'image_viewer_screen.dart';
import 'media_viewer_screen.dart';
import 'document_viewer_screen.dart';
import 'file_info_screen.dart';

class MyDownloadsScreen extends StatefulWidget {
  const MyDownloadsScreen({super.key});

  @override
  State<MyDownloadsScreen> createState() => _MyDownloadsScreenState();
}

class _MyDownloadsScreenState extends State<MyDownloadsScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dir =
          Directory('/storage/emulated/0/Download/WhatsApp Media Manager/');
      if (await dir.exists()) {
        final files = dir.listSync().whereType<File>().toList();
        setState(() {
          _files = files;
          _isLoading = false;
        });
      } else {
        setState(() {
          _files = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openFile(File file) {
    final extension =
        p.extension(file.path).replaceFirst('.', '').toLowerCase();
    final media = {
      'path': file.path,
      'name': p.basename(file.path),
      'extension': extension,
      'type': _getType(extension),
      'size': file.lengthSync(),
    };
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ImageViewerScreen(media: media, isMyDownloadPage: true),
        ),
      );
    } else if (['mp4'].contains(extension) || ['mkv'].contains(extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MediaViewerScreen(media: media, isMyDownloadPage: true),
        ),
      );
    } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt']
        .contains(extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DocumentViewerScreen(media: media, isMyDownloadPage: true),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unsupported file type.'),
        ),
      );
    }
  }

  String _getType(String extension) {
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) return 'Images';
    if (['mp4'].contains(extension)) return 'Videos';
    if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt']
        .contains(extension)) return 'Documents';
    return 'Other';
  }

  IconData _getIcon(String extension) {
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) return Icons.image;
    if (['mp4'].contains(extension)) return Icons.video_file;
    if (['pdf'].contains(extension)) return Icons.picture_as_pdf;
    if (['doc', 'docx'].contains(extension)) return Icons.description;
    if (['xls', 'xlsx'].contains(extension)) return Icons.table_chart;
    if (['ppt', 'pptx'].contains(extension)) return Icons.slideshow;
    if (['txt'].contains(extension)) return Icons.text_snippet;
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Downloads',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF202C33),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
          ),
        ],
      ),
      backgroundColor: const Color(0xFF111B21),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : _files.isEmpty
                  ? const Center(
                      child: Text(
                        'No files found in WhatsApp Download Manager.',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final file = _files[index] as File;
                        final extension = p
                            .extension(file.path)
                            .replaceFirst('.', '')
                            .toLowerCase();
                        final icon = _getIcon(extension);
                        final isImage =
                            ['jpg', 'jpeg', 'png', 'gif'].contains(extension);
                        // final isDocument = [
                        //   'pdf',
                        //   'doc',
                        //   'docx',
                        //   'xls',
                        //   'xlsx',
                        //   'ppt',
                        //   'pptx',
                        //   'txt'
                        // ].contains(extension);
                        // final isVideo = ['mp4'].contains(extension);

                        return GestureDetector(
                          onTap: () => _openFile(file),
                          onLongPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FileInfoScreen(file: file),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF202C33),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                    child: isImage
                                        ? Image.file(
                                            file,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: const Color(0xFF111B21),
                                            child: Center(
                                              child: Icon(
                                                icon,
                                                size: 48,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    p.basename(file.path),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
