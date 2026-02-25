import '../entities/track.dart';

abstract class TrackRepository {
  Future<List<Track>> getTracks({String? categoryId});
  Future<Track?> getTrackById(String id);
  Future<List<Track>> searchTracks(String query);
  Future<void> addToFavorites(String trackId);
  Future<void> removeFromFavorites(String trackId);
  Future<List<Track>> getFavoriteTracks();
  Future<bool> isFavorite(String trackId);
  Future<void> downloadTrack(String trackId);
  Future<List<Track>> getDownloadedTracks();
  Future<bool> isDownloaded(String trackId);
}
