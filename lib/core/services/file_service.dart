import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

enum FileType {
  image,
  document,
  video,
  audio,
  archive,
  other,
}

class UploadedFile {
  final String id;
  final String name;
  final String url;
  final FileType type;
  final int size;
  final DateTime uploadedAt;
  final String? thumbnail;
  final Map<String, dynamic>? metadata;

  UploadedFile({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedAt,
    this.thumbnail,
    this.metadata,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class FileService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UploadedFile?> uploadFile(File file, {Map<String, dynamic>? metadata}) async {
    try {
      // Mock implementation - in a real app, you'd upload to cloud storage
      await Future.delayed(const Duration(seconds: 2));
      
      final fileType = _getFileType(file.path);
      final fileId = DateTime.now().millisecondsSinceEpoch.toString();
      
      return UploadedFile(
        id: fileId,
        name: file.path.split('/').last,
        url: 'https://storage.example.com/files/$fileId',
        type: fileType,
        size: await file.length(),
        uploadedAt: DateTime.now(),
        thumbnail: fileType == FileType.image ? 'https://storage.example.com/thumbnails/$fileId' : null,
        metadata: metadata,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<UploadedFile>> getUserFiles() async {
    try {
      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 500));
      
      return [
        UploadedFile(
          id: '1',
          name: 'project_screenshot.png',
          url: 'https://picsum.photos/seed/file1/400/300.jpg',
          type: FileType.image,
          size: 1024 * 500,
          uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
          thumbnail: 'https://picsum.photos/seed/file1/200/150.jpg',
        ),
        UploadedFile(
          id: '2',
          name: 'requirements.pdf',
          url: 'https://example.com/files/requirements.pdf',
          type: FileType.document,
          size: 1024 * 1024 * 2,
          uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteFile(String fileId) async {
    try {
      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      return false;
    }
  }

  FileType _getFileType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return FileType.image;
    } else if (['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(extension)) {
      return FileType.document;
    } else if (['mp4', 'avi', 'mov', 'wmv', 'flv'].contains(extension)) {
      return FileType.video;
    } else if (['mp3', 'wav', 'ogg', 'flac'].contains(extension)) {
      return FileType.audio;
    } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
      return FileType.archive;
    } else {
      return FileType.other;
    }
  }
}
