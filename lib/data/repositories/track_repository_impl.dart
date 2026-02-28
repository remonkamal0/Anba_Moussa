import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';
import '../datasources/remote_data_source.dart';
import '../../core/network/supabase_service.dart';
import '../models/track_model.dart';

class TrackRepositoryImpl implements TrackRepository {
  final RemoteDataSource remoteDataSource;
  final SupabaseService _supabaseService; // Kept for now just for downloads handling if that's not in remote data source

  TrackRepositoryImpl(this.remoteDataSource, this._supabaseService);

  @override
  Future<List<Track>> getTracks({String? categoryId}) async {
    return await remoteDataSource.getTracks(categoryId: categoryId);
  }

  @override
  Future<Track?> getTrackById(String id) async {
    return await remoteDataSource.getTrackById(id);
  }

  @override
  Future<List<Track>> searchTracks(String query) async {
    return await remoteDataSource.searchTracks(query);
  }

  @override
  Future<void> addToFavorites(String trackId) async {
    await remoteDataSource.toggleFavorite(trackId: trackId, makeFavorite: true);
  }

  @override
  Future<void> removeFromFavorites(String trackId) async {
    await remoteDataSource.toggleFavorite(trackId: trackId, makeFavorite: false);
  }

  @override
  Future<List<Track>> getFavoriteTracks() async {
    return await remoteDataSource.getFavoriteTracks();
  }

  @override
  Future<bool> isFavorite(String trackId) async {
    final ids = await remoteDataSource.getFavoriteTrackIds();
    return ids.contains(trackId);
  }

  // --- Downloads (still using supabase service directly for now due to lack of local DB abstractions) ---
  @override
  Future<void> downloadTrack(String trackId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) throw Exception('User not authenticated');
    await _supabaseService.client.from('downloads').insert({
      'user_id': userId,
      'track_id': trackId,
    });
  }

  @override
  Future<List<Track>> getDownloadedTracks() async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) return [];
    final response = await _supabaseService.client
        .from('downloads')
        .select('tracks(*)')
        .eq('user_id', userId);

    final data = response as List<dynamic>;
    return data.map((json) {
      final trackJson = (json as Map<String, dynamic>)['tracks'] as Map<String, dynamic>;
      final model = TrackModel.fromJson(trackJson);
      return Track(
        id: model.id,
        categoryId: model.categoryId,
        titleAr: model.titleAr ?? model.titleEn ?? '',
        titleEn: model.titleEn ?? model.titleAr ?? '',
        subtitleAr: model.subtitleAr,
        subtitleEn: model.subtitleEn,
        descriptionAr: model.descriptionAr,
        descriptionEn: model.descriptionEn,
        speakerAr: model.speakerAr,
        speakerEn: model.speakerEn,
        imageUrl: model.coverImageUrl,
        audioUrl: model.audioUrl,
        durationSeconds: model.durationSeconds,
        publishedAt: model.publishedAt,
        isActive: model.isActive,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );
    }).toList();
  }

  @override
  Future<bool> isDownloaded(String trackId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) return false;
    final response = await _supabaseService.client
        .from('downloads')
        .select('id')
        .eq('user_id', userId)
        .eq('track_id', trackId)
        .maybeSingle();

    return response != null;
  }
}
