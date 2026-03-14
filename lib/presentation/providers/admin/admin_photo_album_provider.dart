import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/photo_album.dart';
import '../../../../domain/repositories/gallery_repository.dart';

class AdminPhotoAlbumProvider extends ChangeNotifier {
  final GalleryRepository _repository;
  final Logger _logger;

  bool _isLoading = false;
  List<PhotoAlbum> _albums = [];
  String? _error;

  AdminPhotoAlbumProvider({
    required GalleryRepository repository,
    required Logger logger,
  }) : _repository = repository,
       _logger = logger;

  bool get isLoading => _isLoading;
  List<PhotoAlbum> get albums => _albums;
  String? get error => _error;

  Future<void> loadAlbums() async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _repository.getPhotoAlbums();
      _albums = data;
    } catch (e, st) {
      _logger.error('Failed to load photo albums', e, st);
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAlbum(PhotoAlbum album) async {
    _setLoading(true);
    _error = null;
    try {
      final newAlbum = await _repository.createPhotoAlbum(album);
      _albums.insert(0, newAlbum);
      return true;
    } catch (e, st) {
      _logger.error('Failed to create photo album', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAlbum(PhotoAlbum album) async {
    _setLoading(true);
    _error = null;
    try {
      final updatedAlbum = await _repository.updatePhotoAlbum(album);
      final index = _albums.indexWhere((a) => a.id == updatedAlbum.id);
      if (index != -1) {
        _albums[index] = updatedAlbum;
      }
      return true;
    } catch (e, st) {
      _logger.error('Failed to update photo album', e, st);
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
      await _repository.deletePhotoAlbum(id);
      _albums.removeWhere((a) => a.id == id);
      return true;
    } catch (e, st) {
      _logger.error('Failed to delete photo album', e, st);
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
