import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/track.dart';

class DownloadService {
  static final DownloadService instance = DownloadService._();
  DownloadService._();

  final Dio _dio = Dio();
  final Box _box = Hive.box('downloads');

  Future<void> downloadTrack(Track track, Function(double progress) onProgress) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final savePath = '${appDocDir.path}/downloads/${track.id}.mp3';
      
      // Ensure directory exists
      final dir = Directory('${appDocDir.path}/downloads');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      await _dio.download(
        track.audioUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      // Save metadata to Hive
      await _box.put(track.id, {
        'path': savePath,
        'id': track.id,
        'titleAr': track.titleAr,
        'titleEn': track.titleEn,
        'speakerAr': track.speakerAr,
        'speakerEn': track.speakerEn,
        'imageUrl': track.imageUrl,
      });
    } catch (e) {
      rethrow;
    }
  }

  bool isDownloaded(String trackId) {
    return _box.containsKey(trackId);
  }

  String? getLocalPath(String trackId) {
    final data = _box.get(trackId);
    if (data is Map) {
      final path = data['path'] as String?;
      if (path != null && File(path).existsSync()) {
        return path;
      }
    }
    return null;
  }

  Track? getTrack(String trackId) {
    final data = _box.get(trackId);
    if (data is Map) {
      return Track(
        id: data['id'] ?? '',
        categoryId: '',
        titleAr: data['titleAr'] ?? '',
        titleEn: data['titleEn'] ?? '',
        audioUrl: '', 
        imageUrl: data['imageUrl'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        speakerAr: data['speakerAr'],
        speakerEn: data['speakerEn'],
      );
    }
    return null;
  }

  Future<void> deleteDownload(String trackId) async {
    final data = _box.get(trackId);
    if (data is Map) {
      final path = data['path'] as String?;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    await _box.delete(trackId);
  }

  List<String> getAllDownloadedIds() {
    return _box.keys.cast<String>().toList();
  }
}
