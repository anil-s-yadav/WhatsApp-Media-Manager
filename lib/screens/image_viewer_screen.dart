import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

import '../utils/services/whatsapp_service.dart';

class ImageViewerScreen extends StatefulWidget {
  final Map<String, dynamic> media;
  final bool isMyDownloadPage;

  const ImageViewerScreen(
      {super.key, required this.media, this.isMyDownloadPage = false});

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  bool _showControls = true;
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _baseOffset = Offset.zero;
  double _baseScale = 1.0;

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _scale;
    _baseOffset = _offset;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_baseScale * details.scale).clamp(0.5, 4.0);
      _offset = _baseOffset + details.focalPointDelta;
    });
  }

  void _resetZoom() {
    setState(() {
      _scale = 1.0;
      _offset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onDoubleTap: _resetZoom,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Transform(
              transform: Matrix4.identity()
                ..translate(_offset.dx, _offset.dy)
                ..scale(_scale),
              child: Center(
                child: Image.file(
                  File(widget.media['path']),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Gradient Overlay
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // Controls
            if (_showControls) ...[
              // Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 40,
                    bottom: 10,
                    left: 10,
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.media['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () async {
                          await Share.shareXFiles(
                            [XFile(widget.media['path'])],
                            text: 'Check out this image!',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Controls
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _scale = (_scale - 0.5).clamp(0.5, 4.0);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A884).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF00A884),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_out, color: Color(0xFF00A884)),
                            SizedBox(width: 8),
                            Text('Zoom Out',
                                style: TextStyle(
                                    color: Color(0xFF00A884),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _scale = (_scale + 0.5).clamp(0.5, 4.0);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A884).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF00A884),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in, color: Color(0xFF00A884)),
                            SizedBox(width: 8),
                            Text('Zoom In',
                                style: TextStyle(
                                    color: Color(0xFF00A884),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    !widget.isMyDownloadPage
                        ? InkWell(
                            onTap: () async {
                              final result = await WhatsAppService()
                                  .copyToDownloads(widget.media);
                              // final result = await _saveMediaToCustomDownloads(
                              //     widget.media['path'], widget.media['name']);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result
                                        ? 'Image saved successfully!'
                                        : 'Failed to save image.'),
                                    backgroundColor:
                                        result ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00A884).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF00A884),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save_alt,
                                      color: Color(0xFF00A884)),
                                  SizedBox(width: 8),
                                  Text('Save',
                                      style: TextStyle(
                                          color: Color(0xFF00A884),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
