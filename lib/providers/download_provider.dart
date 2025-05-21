import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class DownloadProvider with ChangeNotifier {
  bool _isLoading = false;
  String _downloadPath = '';
  List<String> _downloadedFiles = [];
  String? _error;

  bool get isLoading => _isLoading;
  String get downloadPath => _downloadPath;
  List<String> get downloadedFiles => _downloadedFiles;
  String? get error => _error;

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Request manage external storage permission
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      }

      // If manage external storage is denied, try requesting storage permissions
      if (await Permission.storage.isGranted) {
        return true;
      }

      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      // For Android 13 and above, request media permissions
      if (await Permission.photos.isGranted) {
        return true;
      }

      final photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted) {
        return true;
      }

      return false;
    } else {
      // For iOS, request photos permission
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  Future<void> initialize() async {
    try {
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        _error =
            'Storage permission denied. Please grant permission in app settings.';
        notifyListeners();
        return;
      }

      if (Platform.isAndroid) {
        // For Android, use external storage directory
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          _downloadPath = '${directory.path}/WhatsApp Downloads';
          await Directory(_downloadPath).create(recursive: true);
          _loadDownloadedFiles();
        }
      } else {
        // For iOS, use documents directory
        final directory = await getApplicationDocumentsDirectory();
        _downloadPath = '${directory.path}/WhatsApp Downloads';
        await Directory(_downloadPath).create(recursive: true);
        _loadDownloadedFiles();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _loadDownloadedFiles() async {
    try {
      final directory = Directory(_downloadPath);
      if (await directory.exists()) {
        _downloadedFiles =
            await directory
                .list()
                .where((entity) => entity is File)
                .map((entity) => entity.path)
                .toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> downloadFile(String url, String fileName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final dio = Dio();
      final filePath = '$_downloadPath/$fileName';

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          // You can add progress tracking here if needed
        },
      );

      await _loadDownloadedFiles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        await _loadDownloadedFiles();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
