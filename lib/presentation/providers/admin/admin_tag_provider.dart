import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/tag.dart';
import '../../../../domain/repositories/tag_repository.dart';

class AdminTagProvider extends ChangeNotifier {
  final TagRepository _repository;
  final Logger _logger;

  bool _isLoading = false;
  List<Tag> _tags = [];
  String? _error;

  AdminTagProvider({required TagRepository repository, required Logger logger})
    : _repository = repository,
      _logger = logger;

  bool get isLoading => _isLoading;
  List<Tag> get tags => _tags;
  String? get error => _error;

  Future<void> loadTags() async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _repository.getTags();
      _tags = data;
    } catch (e, st) {
      _logger.error('Failed to load tags', e, st);
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTag(Tag tag) async {
    _setLoading(true);
    _error = null;
    try {
      final newTag = await _repository.createTag(tag);
      _tags.insert(0, newTag);
      return true;
    } catch (e, st) {
      _logger.error('Failed to create tag', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTag(Tag tag) async {
    _setLoading(true);
    _error = null;
    try {
      final updatedTag = await _repository.updateTag(tag);
      final index = _tags.indexWhere((t) => t.id == updatedTag.id);
      if (index != -1) {
        _tags[index] = updatedTag;
      }
      return true;
    } catch (e, st) {
      _logger.error('Failed to update tag', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTag(String id) async {
    _setLoading(true);
    _error = null;
    try {
      await _repository.deleteTag(id);
      _tags.removeWhere((t) => t.id == id);
      return true;
    } catch (e, st) {
      _logger.error('Failed to delete tag', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> setTagTracks(String tagId, List<String> trackIds) async {
    _setLoading(true);
    _error = null;
    try {
      await _repository.setTagTracks(tagId, trackIds);
      return true;
    } catch (e, st) {
      _logger.error('Failed to set tag tracks', e, st);
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
