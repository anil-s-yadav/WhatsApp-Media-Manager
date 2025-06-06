import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/services/whatsapp_service.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'media_viewer_screen.dart';
import 'image_viewer_screen.dart';
import 'document_viewer_screen.dart';
import 'file_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _whatsappService = WhatsAppService();
  List<Map<String, dynamic>> _mediaFiles = [];
  List<Map<String, dynamic>> _filteredMediaFiles = [];
  bool _isLoading = false;
  String? _error;
  String _selectedType = 'All';
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
    });
    final hasPermissions = await _checkPermission();
    if (hasPermissions && mounted) {
      await _loadMediaFiles();
    } else {
      setState(() {
        _isLoading = false; // ensures UI unblocks
      });
    }
  }

  Future<bool> _checkPermission() async {
    try {
      // ✅ If already granted, return early
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Ask for manageExternalStorage if denied
      if (await Permission.manageExternalStorage.isDenied) {
        final manageStorage = await Permission.manageExternalStorage.request();
        if (!manageStorage.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Storage access permission is required'),
                backgroundColor: Colors.grey,
              ),
            );
          }
          return false;
        }
      }

      // Then check other permissions
      final statuses = await [
        Permission.storage,
        Permission.mediaLibrary,
        Permission.audio,
        Permission.videos,
      ].request();

      final allGranted = statuses.values
          .every((status) => status.isGranted || status.isLimited);

      if (!allGranted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All permissions are required to use this app'),
            backgroundColor: Colors.grey,
          ),
        );
      }

      return allGranted;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking permissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMediaFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final files = await _whatsappService.getWhatsAppMedia();
      if (mounted) {
        setState(() {
          _mediaFiles = files;
          _filteredMediaFiles = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _filteredMediaFiles = _mediaFiles.where((media) {
        final name = media['name'].toString().toLowerCase();
        final searchQuery = _searchController.text.toLowerCase();
        return name.contains(searchQuery);
      }).toList();
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _filteredMediaFiles = _mediaFiles;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filteredMediaFiles = _mediaFiles;
    });
  }

  Future<void> _copyToDownloads(Map<String, dynamic> media) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final success = await _whatsappService.copyToDownloads(media);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File copied to downloads successfully'),
              backgroundColor: Color(0xFF25D366),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Failed to copy file. Please check storage permissions.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMediaViewer(Map<String, dynamic> media) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (media['type'] == 'Images') {
            return ImageViewerScreen(media: media);
          } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt']
              .contains(media['extension'])) {
            return DocumentViewerScreen(media: media);
          } else {
            return MediaViewerScreen(media: media);
          }
        },
      ),
    );

    if (result == true) {
      await _copyToDownloads(media);
    }
  }

  List<Map<String, dynamic>> get _filteredMedia {
    final media = _isSearching ? _filteredMediaFiles : _mediaFiles;
    if (_selectedType == 'All') return media;
    if (_selectedType == 'Documents') {
      return media
          .where((media) => [
                'pdf',
                'doc',
                'docx',
                'xls',
                'xlsx',
                'ppt',
                'pptx',
                'txt'
              ].contains(media['extension']))
          .toList();
    }
    return media.where((media) => media['type'] == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202C33),
        iconTheme: const IconThemeData(color: Colors.white),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search media...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                autofocus: true,
              )
            : const Text(
                'WhatsApp Media',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
        centerTitle: true,
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _stopSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: _startSearch,
            ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadMediaFiles,
            ),
        ],
        bottom: _isSearching
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF00A884),
                labelColor: const Color(0xFF00A884),
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Images'),
                  Tab(text: 'Videos'),
                  Tab(text: 'Docs'),
                  Tab(text: 'Status'),
                ],
                onTap: (index) {
                  setState(() {
                    switch (index) {
                      case 0:
                        _selectedType = 'All';
                        break;
                      case 1:
                        _selectedType = 'Images';
                        break;
                      case 2:
                        _selectedType = 'Videos';
                        break;
                      case 3:
                        _selectedType = 'Documents';
                        break;
                      case 4:
                        _selectedType = 'Status';
                        break;
                    }
                  });
                },
              ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF202C33),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF00A884),
                    ),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WhatsApp Downloader',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "v 1.0.1(1)",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.download, color: Color(0xFF00A884)),
                    title: const Text('My Downloads',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/downloads');
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.settings, color: Color(0xFF00A884)),
                    title: const Text('Settings',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help, color: Color(0xFF00A884)),
                    title: const Text('How to use',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/howto');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline,
                        color: Color(0xFF00A884)),
                    title: const Text('About Us',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/about');
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.privacy_tip, color: Color(0xFF00A884)),
                    title: const Text('Privacy Policy',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/privacy');
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Text(
                "Legendary Software © 2025",
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00A884),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMediaFiles,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A884),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _filteredMedia.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isSearching ? Icons.search_off : Icons.folder_off,
                            color: Colors.white70,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isSearching
                                ? 'No results found'
                                : 'No media found',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadMediaFiles,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Reload Media',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
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
                      itemCount: _filteredMedia.length,
                      itemBuilder: (context, index) {
                        final media = _filteredMedia[index];
                        return MediaGridItem(
                          key: ValueKey(media['path']),
                          media: media,
                          onTap: () {
                            if (_selectedType == 'Status' ||
                                _selectedType == 'All') {
                              if (['jpg', 'jpeg', 'png', 'gif']
                                  .contains(media['extension'])) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ImageViewerScreen(media: media),
                                  ),
                                );
                              } else if (['mp4'].contains(media['extension'])) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MediaViewerScreen(media: media),
                                  ),
                                );
                              } else {
                                _showMediaViewer(media);
                              }
                            } else {
                              _showMediaViewer(media);
                            }
                          },
                          onLongPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FileInfoScreen(file: File(media['path'])),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }

  IconData _getDocumentIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({super.key, required this.videoPath});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    await _videoPlayerController.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio,
          child: VideoPlayer(_videoPlayerController),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  if (_isPlaying) {
                    _videoPlayerController.pause();
                  } else {
                    _videoPlayerController.play();
                  }
                  _isPlaying = !_isPlaying;
                });
              },
            ),
            ValueListenableBuilder(
              valueListenable: _videoPlayerController,
              builder: (context, VideoPlayerValue value, child) {
                return Text(
                  '${value.position.inMinutes}:${(value.position.inSeconds % 60).toString().padLeft(2, '0')} / '
                  '${value.duration.inMinutes}:${(value.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class MediaGridItem extends StatelessWidget {
  final Map<String, dynamic> media;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const MediaGridItem({
    super.key,
    required this.media,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = ['jpg', 'jpeg', 'png', 'gif'].contains(media['extension']);
    final isDocument = [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt'
    ].contains(media['extension']);
    final isVideo = ['mp4'].contains(media['extension']);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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
                        File(media['path']),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      )
                    : isDocument
                        ? Container(
                            color: const Color(0xFF2A3942),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getDocumentIcon(media['extension']),
                                  size: 48,
                                  color: const Color(0xFF00A884),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  media['extension'].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              const Icon(
                                Icons.video_file,
                                size: 48,
                                color: Colors.white70,
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${media['type']} • ${media['size']}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}
