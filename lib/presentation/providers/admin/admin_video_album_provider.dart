import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/video_album.dart';
import '../../../../domain/repositories/video_repository.dart';

class AdminVideoAlbumProvider extends ChangeNotifier {
  final VideoRepository _repository;
  final Logger _logger;

  bool _isLoading = false;
  List<VideoAlbum> _albums = [];
  String? _error;

  AdminVideoAlbumProvider({
    required VideoRepository repository,
    required Logger logger,
  }) : _repository = repository,
       _logger = logger;

  bool get isLoading => _isLoading;
  List<VideoAlbum> get albums => _albums;
  String? get error => _error;

  Future<void> loadAlbums() async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _repository.getVideoAlbums();
      _albums = data;
    } catch (e, st) {
      _logger.error('Failed to load video albums', e, st);
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAlbum(VideoAlbum album) async {
    _setLoading(true);
    _error = null;
    try {
      final newAlbum = await _repository.createVideoAlbum(album);
      _albums.insert(0, newAlbum);
      return true;
    } catch (e, st) {
      _logger.error('Failed to create video album', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAlbum(VideoAlbum album) async {
    _setLoading(true);
    _error = null;
    try {
      final updatedAlbum = await _repository.updateVideoAlbum(album);
      final index = _albums.indexWhere((a) => a.id == updatedAlbum.id);
      if (index != -1) {
        _albums[index] = updatedAlbum;
      }
      return true;
    } catch (e, st) {
      _logger.error('Failed to update video album', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAlbum(String id) async {
    _setLoading(true);
    _error = null;
    try {
      await _repository.deleteVideoAlbum(id);
      _albums.removeWhere((a) => a.id == id);
      return true;
    } catch (e, st) {
      _logger.error('Failed to delete video album', e, st);
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
