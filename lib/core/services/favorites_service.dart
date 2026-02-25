import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/supabase_service.dart';
import '../utils/logger.dart';

class FavoritesService {
  final SupabaseService _supabaseService;
  final Logger _logger;
  Set<String> _favoriteTrackIds = {};

  // Stream controller
  final _favoritesController = StreamController<Set<String>>.broadcast();

  FavoritesService(this._supabaseService, this._logger);

  Stream<Set<String>> get favoritesStream => _favoritesController.stream;
  Set<String> get favoriteTrackIds => _favoriteTrackIds;

  // Initialize favorites
  Future<void> initialize() async {
    try {
      final ids = await getFavoriteTrackIds();
      _favoriteTrackIds = ids;
      _favoritesController.add(_favoriteTrackIds);
    } catch (e) {
      _logger.error('Failed to initialize favorites: $e');
    }
  }

  // Get favorite track IDs
  Future<Set<String>> getFavoriteTrackIds() async {
    try {
      final response = await _supabaseService.fetchMyFavoriteTrackIds();
      return Set<String>.from(response);
    } catch (e) {
      _logger.error('Failed to get favorite track IDs: $e');
      return {};
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String trackId) async {
    try {
      if (_favoriteTrackIds.contains(trackId)) {
        // Remove from favorites
        await _supabaseService.toggleFavorite(trackId: trackId, makeFavorite: false);
        _favoriteTrackIds.remove(trackId);
        _logger.info('Removed from favorites: $trackId');
      } else {
        // Add to favorites
        await _supabaseService.toggleFavorite(trackId: trackId, makeFavorite: true);
        _favoriteTrackIds.add(trackId);
        _logger.info('Added to favorites: $trackId');
      }
      
      _favoritesController.add(_favoriteTrackIds);
    } catch (e) {
      _logger.error('Failed to toggle favorite: $e');
    }
  }

  // Check if track is favorite
  bool isFavorite(String trackId) {
    return _favoriteTrackIds.contains(trackId);
  }

  // Add to favorites
  Future<void> addToFavorites(String trackId) async {
    if (!_favoriteTrackIds.contains(trackId)) {
      await toggleFavorite(trackId);
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String trackId) async {
    if (_favoriteTrackIds.contains(trackId)) {
      await toggleFavorite(trackId);
    }
  }

  // Clear all favorites
  Future<void> clearFavorites() async {
    try {
      for (final trackId in _favoriteTrackIds) {
        await _supabaseService.toggleFavorite(trackId: trackId, makeFavorite: false);
      }
      _favoriteTrackIds.clear();
      _favoritesController.add(_favoriteTrackIds);
      _logger.info('Cleared all favorites');
    } catch (e) {
      _logger.error('Failed to clear favorites: $e');
    }
  }

  // Get favorite tracks
  Future<List<Map<String, dynamic>>> getFavoriteTracks() async {
    try {
      final response = await _supabaseService.fetchMyFavoriteTracks();
      return response;
    } catch (e) {
      _logger.error('Failed to get favorite tracks: $e');
      return [];
    }
  }

  void dispose() {
    _favoritesController.close();
  }
}
