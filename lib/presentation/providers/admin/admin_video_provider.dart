import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/video.dart';
import '../../../../domain/repositories/video_repository.dart';

class AdminVideoProvider extends ChangeNotifier {
  final VideoRepository _repository;
  final Logger _logger;

  bool _isLoading = false;
  List<Video> _videos = [];
  String? _error;

  AdminVideoProvider({
    required VideoRepository repository,
    required Logger logger,
  }) : _repository = repository,
       _logger = logger;

  bool get isLoading => _isLoading;
  List<Video> get videos => _videos;
  String? get error => _error;

  Future<void> loadVideos(String albumId) async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _repository.getVideosByAlbumId(albumId);
      _videos = data;
    } catch (e, st) {
      _logger.error('Failed to load videos', e, st);
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createVideo(Video video) async {
    _setLoading(true);
    _error = null;
    try {
      final newVideo = await _repository.createVideo(video);
      _videos.insert(0, newVideo);
      return true;
    } catch (e, st) {
      _logger.error('Failed to create video', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateVideo(Video video) async {
    _setLoading(true);
    _error = null;
    try {
      final updatedVideo = await _repository.updateVideo(video);
      final index = _videos.indexWhere((v) => v.id == updatedVideo.id);
      if (index != -1) {
        _videos[index] = updatedVideo;
      }
      return true;
    } catch (e, st) {
      _logger.error('Failed to update video', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteVideo(String id) async {
    _setLoading(true);
    _error = null;
    try {
      await _repository.deleteVideo(id);
      _videos.removeWhere((v) => v.id == id);
      return true;
    } catch (e, st) {
      _logger.error('Failed to delete video', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
