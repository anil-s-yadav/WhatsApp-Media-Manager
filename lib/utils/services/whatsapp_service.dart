import 'dart:developer';
import 'dart:typed_data';

// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class WhatsAppService {
  bool isValidWhatsAppUrl(String url) {
    return url.contains('whatsapp.com') || url.contains('wa.me');
  }

  Future<String?> extractMediaUrl(String url) async {
    try {
      // This is a placeholder for the actual implementation
      // You'll need to implement the logic to extract media URLs from WhatsApp links
      // This might involve:
      // 1. Making a request to the URL
      // 2. Parsing the response to find media URLs
      // 3. Handling different types of WhatsApp content (status, profile, etc.)

      // For now, we'll return null to indicate that the feature is not implemented
      return null;
    } catch (e) {
      print('Error extracting media URL: $e');
      return null;
    }
  }

  // Future<bool> downloadMedia(String url, String savePath) async {
  //   try {
  //     await _dio.download(url, savePath);
  //     return true;
  //   } catch (e) {
  //     print('Error downloading media: $e');
  //     return false;
  //   }
  // }

  Future<String?> getWhatsAppMediaPath() async {
    if (Platform.isAndroid) {
      // For Android 10 and above, we need to use the MediaStore API
      // For now, we'll try the common WhatsApp media paths
      final possiblePaths = [
        '/storage/emulated/0/WhatsApp/Media',
        '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media',
        '/storage/emulated/0/Android/data/com.whatsapp/files/WhatsApp/Media',
      ];

      for (var path in possiblePaths) {
        if (await Directory(path).exists()) {
          return path;
        }
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getWhatsAppMedia() async {
    List<Map<String, dynamic>> mediaList = [];

    try {
      final basePath = await getWhatsAppMediaPath();
      if (basePath == null) {
        print('WhatsApp media path not found');
        return mediaList;
      }

      print('Found WhatsApp media path: $basePath');

      // Get user preferences
      final prefs = await SharedPreferences.getInstance();
      final showSentFiles = prefs.getBool('show_sent_files') ?? false;
      final showPrivateFiles = prefs.getBool('show_private_files') ?? false;

      // Define WhatsApp media directories
      final directories = {
        'Images': '$basePath/WhatsApp Images',
        if (showSentFiles) 'Sent Images': '$basePath/WhatsApp Images/Sent',
        if (showPrivateFiles)
          'Private Images': '$basePath/WhatsApp Images/Private',
        'Videos': '$basePath/WhatsApp Video',
        'Status': '$basePath/.Statuses',
        'Profile Photos': '$basePath/WhatsApp Profile Photos',
        'Documents': '$basePath/WhatsApp Documents',
      };

      for (var entry in directories.entries) {
        final directory = Directory(entry.value);
        if (await directory.exists()) {
          print('Scanning directory: ${entry.value}');
          final files = await directory.list().toList();
          for (var file in files) {
            if (file is File) {
              final extension = file.path.split('.').last.toLowerCase();
              if (entry.key == 'Documents') {
                if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt']
                    .contains(extension)) {
                  mediaList.add({
                    'path': file.path,
                    'name': file.path.split('/').last,
                    'type': entry.key,
                    'extension': extension,
                    'size': await file.length(),
                    'lastModified': await file.lastModified(),
                  });
                }
              } else {
                if (['jpg', 'jpeg', 'png', 'mp4', 'gif'].contains(extension)) {
                  mediaList.add({
                    'path': file.path,
                    'name': file.path.split('/').last,
                    'type': entry.key,
                    'extension': extension,
                    'size': await file.length(),
                    'lastModified': await file.lastModified(),
                  });
                }
              }
            }
          }
        } else {
          print('Directory not found: ${entry.value}');
        }
      }

      // Sort by last modified date (newest first)
      mediaList.sort((a, b) => b['lastModified'].compareTo(a['lastModified']));
      print('Found ${mediaList.length} media files');
      return mediaList;
    } catch (e) {
      print('Error getting WhatsApp media: $e');
      return mediaList;
    }
  }

  Future<bool> copyToDownloads(Map<String, dynamic> media) async {
    try {
      final sourcePath = media['path'];
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        debugPrint('Source file does not exist: $sourcePath');
        return false;
      }

      // Create a more descriptive filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalName = media['name'];
      final extension = media['extension'];
      final fileName = '${originalName.split('.').first}_$timestamp.$extension';

      // Create downloads directory if it doesn't exist
      final downloadsDir =
          Directory('/storage/emulated/0/Download/WhatsApp Media Manager');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final targetPath = '${downloadsDir.path}/$fileName';

      // Copy the file
      await sourceFile.copy(targetPath);
      debugPrint('File copied successfully to: $targetPath');

      // Scan the file to make it visible in gallery/files
      try {
        await MediaScanner.loadMedia(path: targetPath);
        debugPrint('Media scan completed for: $targetPath');
      } catch (e) {
        debugPrint('Media scan error: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Error in copyToDownloads: $e');
      return false;
    }
  }

  Future<bool> deleteMedia(Map<String, dynamic> media) async {
    try {
      final file = File(media['path']);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      log('Error deleting file: $e');
      return false;
    }
  }

  String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<bool> openWhatsApp(String phoneNumber) async {
    final whatsappUrl = 'https://wa.me/$phoneNumber';
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      return await launchUrl(Uri.parse(whatsappUrl));
    }
    return false;
  }

  Future<bool> openWhatsAppStatus(String statusUrl) async {
    if (await canLaunchUrl(Uri.parse(statusUrl))) {
      return await launchUrl(Uri.parse(statusUrl));
    }
    return false;
  }
}
