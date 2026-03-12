import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/supabase_service.dart';
import '../../data/models/track_model.dart';

// ─── Icon catalogue ────────────────────────────────────────────────────────────
/// Map of identifier → IconData used both in the picker and when rendering cards.
const Map<String, IconData> playlistIconMap = {
  'music_note': Icons.music_note_rounded,
  'headphones': Icons.headphones_rounded,
  'star': Icons.star_rounded,
  'favorite': Icons.favorite_rounded,
  'playlist_play': Icons.playlist_play_rounded,
  'queue_music': Icons.queue_music_rounded,
  'mic': Icons.mic_rounded,
  'radio': Icons.radio_rounded,
  'library_music': Icons.library_music_rounded,
  'album': Icons.album_rounded,
  'church': Icons.church_rounded,
  'self_improvement': Icons.self_improvement_rounded,
  'nightlife': Icons.nightlife_rounded,
  'celebration': Icons.celebration_rounded,
  'spa': Icons.spa_rounded,
  'sunny': Icons.wb_sunny_rounded,
};

IconData playlistIcon(String? name) =>
    playlistIconMap[name] ?? Icons.music_note_rounded;

// ─── Model ─────────────────────────────────────────────────────────────────────
class PlaylistModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? iconName; // stored in image_url column
  final bool isPublic;
  final String? userId;
  final String ownerType;
  final DateTime createdAt;
  int trackCount;

  PlaylistModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.iconName,
    required this.isPublic,
    this.userId,
    required this.ownerType,
    required this.createdAt,
    this.trackCount = 0,
  });

  String getLocalizedTitle(String langCode) =>
      langCode == 'ar' ? titleAr : titleEn;

  factory PlaylistModel.fromJson(Map<String, dynamic> json) => PlaylistModel(
    id: json['id'] as String,
    titleAr: json['title_ar'] as String? ?? '',
    titleEn: json['title_en'] as String? ?? '',
    descriptionAr: json['description_ar'] as String?,
    descriptionEn: json['description_en'] as String?,
    iconName: json['image_url'] as String?,
    isPublic: json['is_public'] as bool? ?? false,
    userId: json['user_id'] as String?,
    ownerType: json['owner_type'] as String? ?? 'user',
    createdAt: DateTime.parse(json['created_at'] as String),
    trackCount: (json['track_count'] as int?) ?? 0,
  );
}

// ─── State ─────────────────────────────────────────────────────────────────────
class PlaylistsState {
  final bool isLoading;
  final List<PlaylistModel> playlists;
  final String? error;

  const PlaylistsState({
    this.isLoading = false,
    this.playlists = const [],
    this.error,
  });

  PlaylistsState copyWith({
    bool? isLoading,
    List<PlaylistModel>? playlists,
    String? error,
  }) => PlaylistsState(
    isLoading: isLoading ?? this.isLoading,
    playlists: playlists ?? this.playlists,
    error: error,
  );
}

// ─── Notifier ──────────────────────────────────────────────────────────────────
class PlaylistsNotifier extends StateNotifier<PlaylistsState> {
  PlaylistsNotifier() : super(const PlaylistsState()) {
    fetch();
  }

  final _client = SupabaseService.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  // ── Fetch user playlists ───────────────────────────────────────────────────
  Future<void> fetch() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rows = await _client
          .from('playlists')
          .select('*, playlist_tracks(count)')
          .eq('user_id', _userId!)
          .eq('owner_type', 'user')
          .order('created_at', ascending: false);

      final playlists = (rows as List).map((r) {
        final m = PlaylistModel.fromJson(r as Map<String, dynamic>);
        // Supabase returns count as [{ count: N }]
        final countList = r['playlist_tracks'] as List?;
        m.trackCount = countList?.isNotEmpty == true
            ? (countList![0]['count'] as int? ?? 0)
            : 0;
        return m;
      }).toList();

      state = state.copyWith(isLoading: false, playlists: playlists);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Create ─────────────────────────────────────────────────────────────────
  Future<PlaylistModel?> createPlaylist({
    required String titleAr,
    required String titleEn,
    String? iconName,
    bool isPublic = false,
  }) async {
    if (_userId == null) return null;
    try {
      final row = await _client
          .from('playlists')
          .insert({
            'user_id': _userId,
            'owner_type': 'user',
            'title_ar': titleAr,
            'title_en': titleEn,
            'image_url': iconName,
            'is_public': isPublic,
          })
          .select()
          .single();

      final created = PlaylistModel.fromJson(row as Map<String, dynamic>);
      state = state.copyWith(playlists: [created, ...state.playlists]);
      return created;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // ── Update ─────────────────────────────────────────────────────────────────
  Future<void> updatePlaylist({
    required String id,
    required String titleAr,
    required String titleEn,
    String? iconName,
    bool? isPublic,
  }) async {
    try {
      await _client
          .from('playlists')
          .update({
            'title_ar': titleAr,
            'title_en': titleEn,
            'image_url': iconName,
            if (isPublic != null) 'is_public': isPublic,
          })
          .eq('id', id);

      final updated = state.playlists.map((p) {
        if (p.id != id) return p;
        return PlaylistModel(
          id: p.id,
          titleAr: titleAr,
          titleEn: titleEn,
          descriptionAr: p.descriptionAr,
          descriptionEn: p.descriptionEn,
          iconName: iconName,
          isPublic: isPublic ?? p.isPublic,
          userId: p.userId,
          ownerType: p.ownerType,
          createdAt: p.createdAt,
          trackCount: p.trackCount,
        );
      }).toList();

      state = state.copyWith(playlists: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  Future<void> deletePlaylist(String id) async {
    try {
      await _client.from('playlists').delete().eq('id', id);
      state = state.copyWith(
        playlists: state.playlists.where((p) => p.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ── Tracks ─────────────────────────────────────────────────────────────────
  Future<void> addTrack(String playlistId, String trackId) async {
    try {
      final pos = await _client
          .from('playlist_tracks')
          .select('position')
          .eq('playlist_id', playlistId)
          .order('position', ascending: false)
          .limit(1);
      final nextPos = pos.isEmpty ? 0 : ((pos[0]['position'] as int) + 1);

      await _client.from('playlist_tracks').insert({
        'playlist_id': playlistId,
        'track_id': trackId,
        'position': nextPos,
      });
      _incrementCount(playlistId);
    } catch (_) {}
  }

  Future<void> removeTrack(String playlistId, String trackId) async {
    try {
      await _client
          .from('playlist_tracks')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('track_id', trackId);
      _decrementCount(playlistId);
    } catch (_) {}
  }

  void _incrementCount(String id) {
    state = state.copyWith(
      playlists: state.playlists.map((p) {
        if (p.id != id) return p;
        p.trackCount++;
        return p;
      }).toList(),
    );
  }

  void _decrementCount(String id) {
    state = state.copyWith(
      playlists: state.playlists.map((p) {
        if (p.id != id) return p;
        if (p.trackCount > 0) p.trackCount--;
        return p;
      }).toList(),
    );
  }
}

// ─── Providers ─────────────────────────────────────────────────────────────────
final playlistsProvider =
    StateNotifierProvider<PlaylistsNotifier, PlaylistsState>(
      (ref) => PlaylistsNotifier(),
    );

/// Fetches all tracks associated with a specific playlist.
final playlistTracksProvider = FutureProvider.family<List<TrackModel>, String>((
  ref,
  playlistId,
) async {
  final client = SupabaseService.instance.client;
  final rows = await client
      .from('playlist_tracks')
      .select('*, tracks(*)')
      .eq('playlist_id', playlistId)
      .order('position', ascending: true);

  return (rows as List).map((r) {
    final trackJson = r['tracks'] as Map<String, dynamic>;
    return TrackModel.fromJson(trackJson);
  }).toList();
});
