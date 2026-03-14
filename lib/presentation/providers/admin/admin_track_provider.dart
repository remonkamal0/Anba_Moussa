import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/repositories/track_repository.dart';

class AdminTrackProvider extends ChangeNotifier {
  final TrackRepository _repository;
  final Logger _logger;

  bool _isLoading = false;
  List<Track> _tracks = [];
  String? _error;

  AdminTrackProvider({
    required TrackRepository repository,
    required Logger logger,
  }) : _repository = repository,
       _logger = logger;

  bool get isLoading => _isLoading;
  List<Track> get tracks => _tracks;
  String? get error => _error;

  Future<void> loadTracks() async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _repository.getTracks();
      _tracks = data;
    } catch (e, st) {
      _logger.error('Failed to load tracks', e, st);
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTrack(Track track) async {
    _setLoading(true);
    _error = null;
    try {
      final newTrack = await _repository.createTrack(track);
      _tracks.insert(0, newTrack);
      return true;
    } catch (e, st) {
      _logger.error('Failed to create track', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTrack(Track track) async {
    _setLoading(true);
    _error = null;
    try {
      final updatedTrack = await _repository.updateTrack(track);
      final index = _tracks.indexWhere((t) => t.id == updatedTrack.id);
      if (index != -1) {
        _tracks[index] = updatedTrack;
      }
      return true;
    } catch (e, st) {
      _logger.error('Failed to update track', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTrack(String id) async {
    _setLoading(true);
    _error = null;
    try {
      await _repository.deleteTrack(id);
      _tracks.removeWhere((t) => t.id == id);
      return true;
    } catch (e, st) {
      _logger.error('Failed to delete track', e, st);
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
