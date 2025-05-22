import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../services/whatsapp_service.dart';

class MediaViewerScreen extends StatefulWidget {
  final Map<String, dynamic> media;

  const MediaViewerScreen({
    super.key,
    required this.media,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late VideoPlayerController? _videoPlayerController;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    if (!_isImage) {
      _initializePlayer();
    }
  }

  bool get _isImage =>
      ['jpg', 'jpeg', 'png', 'gif'].contains(widget.media['extension']);

  Future<void> _initializePlayer() async {
    _videoPlayerController =
        VideoPlayerController.file(File(widget.media['path']));
    await _videoPlayerController!.initialize();
    await _videoPlayerController!.play();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // backgroundColor: Colors.white70,
        title: Text(
          widget.media['name'],
          style: const TextStyle(
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
              onPressed: () {
                Share.shareXFiles([XFile(widget.media['path'])]);
              },
              icon: const Icon(
                Icons.share,
                color: Color.fromARGB(255, 5, 77, 31),
                size: 20,
              )),
          TextButton.icon(
            onPressed: () async {
              final result =
                  await WhatsAppService().copyToDownloads(widget.media);
              // final result = await _saveMediaToCustomDownloads(
              //     widget.media['path'], widget.media['name']);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: Durations.medium3,
                    content: Text(result
                        ? 'Video saved successfully!'
                        : 'Failed to save video.'),
                    backgroundColor: result ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            label: const Text('Save to Downloads'),
            icon: const Icon(Icons.download),
          )
        ],
      ),
      body: Stack(
        children: [
          // Media content
          Center(
            child: _isImage
                ? InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(
                      File(widget.media['path']),
                      fit: BoxFit.contain,
                    ),
                  )
                : _isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController!),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00A884),
                        ),
                      ),
          ),

          // Top bar

          // Bottom bar
          if (!_isImage && _isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Video progress
                    ValueListenableBuilder(
                      valueListenable: _videoPlayerController!,
                      builder: (context, VideoPlayerValue value, child) {
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12,
                                ),
                                activeTrackColor: const Color(0xFF00A884),
                                inactiveTrackColor: Colors.white24,
                                thumbColor: const Color(0xFF00A884),
                                overlayColor:
                                    const Color(0xFF00A884).withOpacity(0.2),
                              ),
                              child: Slider(
                                value: value.position.inMilliseconds.toDouble(),
                                min: 0,
                                max: value.duration.inMilliseconds.toDouble(),
                                onChanged: (newValue) {
                                  _videoPlayerController!.seekTo(
                                    Duration(milliseconds: newValue.toInt()),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(value.position),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(value.duration),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Video controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isPlaying) {
                                _videoPlayerController!.pause();
                              } else {
                                _videoPlayerController!.play();
                              }
                              _isPlaying = !_isPlaying;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Action buttons
        ],
      ),
    );
  }

  // Future<void> _openDocument(BuildContext context) async {
  //   try {
  //     final file = File(widget.media['path']);
  //     if (!await file.exists()) {
  //       throw Exception('File not found');
  //     }

  //     // Get the Downloads directory
  //     Directory? downloadsDir;
  //     if (Platform.isAndroid) {
  //       downloadsDir =
  //           Directory('/storage/emulated/0/DownloadWhatsApp Media Manager/');
  //     } else {
  //       downloadsDir = await getDownloadsDirectory();
  //     }

  //     final newPath = p.join(downloadsDir!.path, p.basename(file.path));
  //     final publicFile = await file.copy(newPath);

  //     final result = await OpenFile.open(publicFile.path);
  //     if (result.type != ResultType.done) {
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('No app found to open this file'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error opening file: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  // Future<bool> _saveMediaToCustomDownloads(
  //     String sourcePath, String fileName) async {
  //   try {
  //     final directory =
  //         Directory('/storage/emulated/0/Download/WhatsApp Download Manager/');
  //     if (!await directory.exists()) {
  //       await directory.create(recursive: true);
  //     }
  //     final newPath = '${directory.path}/$fileName';
  //     await File(sourcePath).copy(newPath);
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }
}
