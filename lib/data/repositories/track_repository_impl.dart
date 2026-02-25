import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';
import '../models/track_model.dart';
import '../../core/network/supabase_service.dart';

class TrackRepositoryImpl implements TrackRepository {
  final SupabaseService _supabaseService;

  TrackRepositoryImpl(this._supabaseService);

  @override
  Future<List<Track>> getTracks({String? categoryId}) async {
    final query = _supabaseService.client
        .from('tracks')
        .select('*')
        .eq('is_active', true)
        .order('created_at', ascending: false);

    final response = categoryId != null
        ? await query.eq('category_id', categoryId)
        : await query;

    final data = response as List<dynamic>;
    return data.map((json) {
      final model = TrackModel.fromJson(json as Map<String, dynamic>);
      return Track(
        id: model.id,
        categoryId: model.categoryId,
        title: model.getLocalizedName('en') ?? '', // TODO: Get from locale provider
        subtitle: model.getLocalizedSubtitle('en') ?? '',
        description: model.getLocalizedDescription('en') ?? '',
        speaker: model.getLocalizedSpeaker('en') ?? '',
        coverImageUrl: model.coverImageUrl,
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
  Future<Track?> getTrackById(String id) async {
    final response = await _supabaseService.client
        .from('tracks')
        .select('*')
        .eq('id', id)
        .single();

    if (response == null) return null;

    final model = TrackModel.fromJson(response as Map<String, dynamic>);
    return Track(
      id: model.id,
      categoryId: model.categoryId,
      title: model.getLocalizedName('en') ?? '', // TODO: Get from locale provider
      subtitle: model.getLocalizedSubtitle('en') ?? '',
      description: model.getLocalizedDescription('en') ?? '',
      speaker: model.getLocalizedSpeaker('en') ?? '',
      coverImageUrl: model.coverImageUrl,
      audioUrl: model.audioUrl,
      durationSeconds: model.durationSeconds,
      publishedAt: model.publishedAt,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  @override
  Future<List<Track>> searchTracks(String query) async {
    final response = await _supabaseService.client
        .from('tracks')
        .select('*')
        .eq('is_active', true)
        .or('title_ar.ilike.%$query%,title_en.ilike.%$query%')
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;
    return data.map((json) {
      final model = TrackModel.fromJson(json as Map<String, dynamic>);
      return Track(
        id: model.id,
        categoryId: model.categoryId,
        title: model.getLocalizedName('en') ?? '', // TODO: Get from locale provider
        subtitle: model.getLocalizedSubtitle('en') ?? '',
        description: model.getLocalizedDescription('en') ?? '',
        speaker: model.getLocalizedSpeaker('en') ?? '',
        coverImageUrl: model.coverImageUrl,
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
  Future<void> addToFavorites(String trackId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) throw Exception('User not authenticated');
    await _supabaseService.client.from('favorites').insert({
      'user_id': userId,
      'track_id': trackId,
    });
  }

  @override
  Future<void> removeFromFavorites(String trackId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) throw Exception('User not authenticated');
    await _supabaseService.client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('track_id', trackId);
  }

  @override
  Future<List<Track>> getFavoriteTracks() async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) return [];
    final response = await _supabaseService.client
        .from('favorites')
        .select('tracks(*)')
        .eq('user_id', userId);

    final data = response as List<dynamic>;
    return data.map((json) {
      final trackJson = (json as Map<String, dynamic>)['tracks'] as Map<String, dynamic>;
      final model = TrackModel.fromJson(trackJson);
      return Track(
        id: model.id,
        categoryId: model.categoryId,
        title: model.getLocalizedName('en') ?? '', // TODO: Get from locale provider
        subtitle: model.getLocalizedSubtitle('en') ?? '',
        description: model.getLocalizedDescription('en') ?? '',
        speaker: model.getLocalizedSpeaker('en') ?? '',
        coverImageUrl: model.coverImageUrl,
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
  Future<bool> isFavorite(String trackId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) return false;
    final response = await _supabaseService.client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('track_id', trackId)
        .maybeSingle();

    return response != null;
  }

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
        title: model.getLocalizedName('en') ?? '', // TODO: Get from locale provider
        subtitle: model.getLocalizedSubtitle('en') ?? '',
        description: model.getLocalizedDescription('en') ?? '',
        speaker: model.getLocalizedSpeaker('en') ?? '',
        coverImageUrl: model.coverImageUrl,
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
