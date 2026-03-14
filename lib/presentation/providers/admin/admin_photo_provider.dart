import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/photo.dart';
import '../../../../domain/repositories/gallery_repository.dart';

class AdminPhotoProvider extends ChangeNotifier {
  final GalleryRepository _repository;
  final Logger _logger;

  bool _isLoading = false;
  List<Photo> _photos = [];
  String? _error;

  AdminPhotoProvider({
    required GalleryRepository repository,
    required Logger logger,
  }) : _repository = repository,
       _logger = logger;

  bool get isLoading => _isLoading;
  List<Photo> get photos => _photos;
  String? get error => _error;

  Future<void> loadPhotos(String albumId) async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _repository.getPhotosByAlbumId(albumId);
      _photos = data;
    } catch (e, st) {
      _logger.error('Failed to load photos', e, st);
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createPhoto(Photo photo) async {
    _setLoading(true);
    _error = null;
    try {
      final newPhoto = await _repository.createPhoto(photo);
      _photos.insert(0, newPhoto);
      return true;
    } catch (e, st) {
      _logger.error('Failed to create photo', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePhoto(Photo photo) async {
    _setLoading(true);
    _error = null;
    try {
      final updatedPhoto = await _repository.updatePhoto(photo);
      final index = _photos.indexWhere((p) => p.id == updatedPhoto.id);
      if (index != -1) {
        _photos[index] = updatedPhoto;
      }
      return true;
    } catch (e, st) {
      _logger.error('Failed to update photo', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePhoto(String id) async {
    _setLoading(true);
    _error = null;
    try {
      await _repository.deletePhoto(id);
      _photos.removeWhere((p) => p.id == id);
      return true;
    } catch (e, st) {
      _logger.error('Failed to delete photo', e, st);
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
