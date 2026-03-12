import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/exceptions.dart';
import '../../core/services/connectivity_service.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/photo.dart';
import '../../domain/entities/photo_album.dart';
import '../../domain/entities/slider.dart' as entity_slider;
import '../../domain/entities/tag.dart';
import '../../domain/entities/track.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/video_album.dart';
import '../models/category_model.dart';
import '../models/photo_album_model.dart';
import '../models/photo_model.dart';
import '../models/slider_model.dart';
import '../models/tag_model.dart';
import '../models/track_model.dart';
import '../models/video_album_model.dart';
import '../models/video_model.dart';
import '../../domain/entities/photo_album.dart';
import '../../domain/entities/photo.dart';
import '../../domain/entities/video_album.dart';
import '../../domain/entities/video.dart';

abstract class RemoteDataSource {
  Future<List<Track>> getTopTracks({int limit = 10});
  Future<List<Category>> getCategories();
  Future<List<entity_slider.Slider>> getSliders();
  Future<Set<String>> getFavoriteTrackIds();
  Future<void> toggleFavorite({
    required String trackId,
    required bool makeFavorite,
  });
  Future<List<Track>> searchTracks(String query);
  Future<Track?> getTrackById(String id);
  Future<List<Track>> getFavoriteTracks();
  Future<List<Track>> getTracks({String? categoryId});
  Future<List<PhotoAlbum>> getPhotoAlbums();
  Future<List<Photo>> getPhotosByAlbumId(String albumId);
  Future<List<VideoAlbum>> getVideoAlbums();
  Future<List<Video>> getVideosByAlbumId(String albumId);
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);

  Future<Track> createTrack(Track track);
  Future<Track> updateTrack(Track track);
  Future<void> deleteTrack(String id);

  Future<Tag> createTag(Tag tag);
  Future<Tag> updateTag(Tag tag);
  Future<void> deleteTag(String id);
  Future<void> setTagTracks(String tagId, List<String> trackIds);

  Future<List<Tag>> getTags();

  Future<PhotoAlbum> createPhotoAlbum(PhotoAlbum album);
  Future<PhotoAlbum> updatePhotoAlbum(PhotoAlbum album);
  Future<void> deletePhotoAlbum(String id);

  Future<Photo> createPhoto(Photo photo);
  Future<Photo> updatePhoto(Photo photo);
  Future<void> deletePhoto(String id);

  Future<VideoAlbum> createVideoAlbum(VideoAlbum album);
  Future<VideoAlbum> updateVideoAlbum(VideoAlbum album);
  Future<void> deleteVideoAlbum(String id);

  Future<Video> createVideo(Video video);
  Future<Video> updateVideo(Video video);
  Future<void> deleteVideo(String id);
  Future<void> logPlayEvent(String trackId);
}

class SupabaseRemoteDataSourceImpl implements RemoteDataSource {
  final SupabaseClient client;
  final ConnectivityService _connectivityService;

  SupabaseRemoteDataSourceImpl({
    required this.client,
    required ConnectivityService connectivityService,
  }) : _connectivityService = connectivityService;

  Future<void> _checkConnectivity() async {
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw NoInternetException();
    }
  }

  String? _getCurrentUserId() => client.auth.currentUser?.id;

  Track _mapTrackModelToEntity(Map<String, dynamic> json) {
    try {
      final model = TrackModel.fromJson(json);

      // Extract tags from nested join result: track_tags(tags(*))
      List<Tag> tags = [];
      if (json['track_tags'] != null && json['track_tags'] is List) {
        final trackTags = json['track_tags'] as List<dynamic>;
        for (var tt in trackTags) {
          if (tt is Map) {
            final tagData = tt['tags'];
            if (tagData != null) {
              if (tagData is Map<String, dynamic>) {
                tags.add(TagModel.fromJson(tagData).toEntity());
              } else if (tagData is List && tagData.isNotEmpty) {
                final firstTag = tagData.first;
                if (firstTag is Map<String, dynamic>) {
                  tags.add(TagModel.fromJson(firstTag).toEntity());
                }
              }
            }
          }
        }
      }

      return Track(
        id: model.id,
        categoryId: model.categoryId,
        titleAr: model.titleAr ?? '',
        titleEn: model.titleEn ?? '',
        subtitleAr: model.subtitleAr,
        subtitleEn: model.subtitleEn,
        descriptionAr: model.descriptionAr,
        descriptionEn: model.descriptionEn,
        speakerAr: model.speakerAr,
        speakerEn: model.speakerEn,
        imageUrl: model.coverImageUrl,
        audioUrl: model.audioUrl ?? '',
        durationSeconds: model.durationSeconds,
        publishedAt: model.publishedAt,
        isActive: model.isActive,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        tags: tags,
      );
    } catch (e, stack) {
      print(
        'Error parsing track in _mapTrackModelToEntity: $e\n$stack\nJSON: $json',
      );
      rethrow;
    }
  }

  Category _mapCategoryModelToEntity(Map<String, dynamic> json) {
    final model = CategoryModel.fromJson(json);
    return Category(
      id: model.id,
      slug: model.slug,
      titleAr: model.titleAr ?? '',
      titleEn: model.titleEn ?? '',
      subtitleAr: model.subtitleAr,
      subtitleEn: model.subtitleEn,
      imageUrl: model.imageUrl,
      sortOrder: model.sortOrder,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  @override
  Future<List<Track>> getTopTracks({int limit = 10}) async {
    await _checkConnectivity();
    try {
      // 1. Fetch all active track IDs
      final idsResponse = await client
          .from('tracks')
          .select('id')
          .eq('is_active', true);

      final List<String> allIds = (idsResponse as List)
          .map((e) => e['id'] as String)
          .toList();

      if (allIds.isEmpty) return [];

      // 2. Shuffle and take the requested limit
      allIds.shuffle();
      final selectedIds = allIds.take(limit).toList();

      // 3. Fetch full track details with tags for these random IDs
      final tracksResponse = await client
          .from('tracks')
          .select('''
            *,
            track_tags(tags(*))
          ''')
          .inFilter('id', selectedIds);

      final List<Track> tracks = (tracksResponse as List)
          .map(
            (trackMap) =>
                _mapTrackModelToEntity(trackMap as Map<String, dynamic>),
          )
          .toList();

      // Ensure they remain in the shuffled order
      tracks.sort(
        (a, b) =>
            selectedIds.indexOf(a.id).compareTo(selectedIds.indexOf(b.id)),
      );

      return tracks;
    } catch (e) {
      print('Error fetching random tracks: $e');
      return [];
    }
  }

  @override
  Future<void> logPlayEvent(String trackId) async {
    // تم إلغاء التسجيل في قاعدة البيانات بناءً على طلبك
    // final uid = _getCurrentUserId();
    // try {
    //   final Map<String, dynamic> data = {'track_id': trackId};
    //   if (uid != null) data['user_id'] = uid;
    //   await client.from('play_events').insert(data);
    // } catch (e) {
    //   print('ERROR: Supabase log catch: $e');
    // }
  }

  @override
  Future<List<Category>> getCategories() async {
    await _checkConnectivity();
    final response = await client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (categoryMap) =>
              _mapCategoryModelToEntity(categoryMap as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<entity_slider.Slider>> getSliders() async {
    await _checkConnectivity();
    final response = await client
        .from('sliders')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => entity_slider.Slider.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Set<String>> getFavoriteTrackIds() async {
    final uid = _getCurrentUserId();
    if (uid == null) return <String>{};

    await _checkConnectivity();
    final response = await client
        .from('favorites')
        .select('track_id')
        .eq('user_id', uid);

    return Set<String>.from((response as List).map((fav) => fav['track_id']));
  }

  @override
  Future<void> toggleFavorite({
    required String trackId,
    required bool makeFavorite,
  }) async {
    final uid = _getCurrentUserId();
    if (uid == null) return;

    if (makeFavorite) {
      await client.from('favorites').upsert({
        'user_id': uid,
        'track_id': trackId,
      });
    } else {
      await client
          .from('favorites')
          .delete()
          .eq('user_id', uid)
          .eq('track_id', trackId);
    }
  }

  @override
  Future<List<Track>> searchTracks(String query) async {
    await _checkConnectivity();
    final response = await client
        .from('tracks')
        .select('*, track_tags(tags(*))')
        .eq('is_active', true)
        .or('title_ar.ilike.%$query%,title_en.ilike.%$query%')
        .order('created_at', ascending: false)
        .limit(20);

    return (response as List)
        .map((json) => _mapTrackModelToEntity(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Track?> getTrackById(String id) async {
    await _checkConnectivity();
    final response = await client
        .from('tracks')
        .select('*, track_tags(tags(*))')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return _mapTrackModelToEntity(response);
  }

  @override
  Future<List<Track>> getFavoriteTracks() async {
    final uid = _getCurrentUserId();
    if (uid == null) return [];
    await _checkConnectivity();
    final response = await client
        .from('favorites')
        .select('tracks(*, track_tags(tags(*)))')
        .eq('user_id', uid);

    return (response as List).map((json) {
      final trackJson = json['tracks'] as Map<String, dynamic>;
      return _mapTrackModelToEntity(trackJson);
    }).toList();
  }

  @override
  Future<List<Track>> getTracks({String? categoryId}) async {
    var query = client
        .from('tracks')
        .select('*, track_tags(tags(*))')
        .eq('is_active', true);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((json) => _mapTrackModelToEntity(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PhotoAlbum>> getPhotoAlbums() async {
    await _checkConnectivity();
    final response = await client
        .from('photo_albums')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (json) =>
              PhotoAlbumModel.fromJson(json as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<List<Photo>> getPhotosByAlbumId(String albumId) async {
    await _checkConnectivity();
    final response = await client
        .from('photos')
        .select()
        .eq('album_id', albumId)
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response as List)
        .map(
          (json) =>
              PhotoModel.fromJson(json as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<List<VideoAlbum>> getVideoAlbums() async {
    await _checkConnectivity();
    final response = await client
        .from('video_albums')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (json) =>
              VideoAlbumModel.fromJson(json as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<List<Video>> getVideosByAlbumId(String albumId) async {
    await _checkConnectivity();
    final response = await client
        .from('videos')
        .select()
        .eq('album_id', albumId)
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response as List)
        .map(
          (json) =>
              VideoModel.fromJson(json as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<Category> createCategory(Category category) async {
    await _checkConnectivity();
    final data = {
      'slug': category.slug,
      'title_ar': category.titleAr,
      'title_en': category.titleEn,
      'subtitle_ar': category.subtitleAr,
      'subtitle_en': category.subtitleEn,
      'image_url': category.imageUrl,
      'sort_order': category.sortOrder,
      'is_active': category.isActive,
    };
    final response = await client
        .from('categories')
        .insert(data)
        .select()
        .single();
    return _mapCategoryModelToEntity(response);
  }

  @override
  Future<Category> updateCategory(Category category) async {
    await _checkConnectivity();
    final data = {
      'slug': category.slug,
      'title_ar': category.titleAr,
      'title_en': category.titleEn,
      'subtitle_ar': category.subtitleAr,
      'subtitle_en': category.subtitleEn,
      'image_url': category.imageUrl,
      'sort_order': category.sortOrder,
      'is_active': category.isActive,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    final response = await client
        .from('categories')
        .update(data)
        .eq('id', category.id)
        .select()
        .single();
    return _mapCategoryModelToEntity(response);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _checkConnectivity();
    await client.from('categories').delete().eq('id', id);
  }

  @override
  Future<Track> createTrack(Track track) async {
    await _checkConnectivity();
    final data = {
      'category_id': track.categoryId,
      'title_ar': track.titleAr,
      'title_en': track.titleEn,
      'subtitle_ar': track.subtitleAr,
      'subtitle_en': track.subtitleEn,
      'description_ar': track.descriptionAr,
      'description_en': track.descriptionEn,
      'speaker_ar': track.speakerAr,
      'speaker_en': track.speakerEn,
      'cover_image_url': track.imageUrl,
      'audio_url': track.audioUrl,
      'duration_seconds': track.durationSeconds,
      'published_at': track.publishedAt?.toUtc().toIso8601String(),
      'is_active': track.isActive,
    };
    final response = await client
        .from('tracks')
        .insert(data)
        .select('*, track_tags(tags(*))')
        .single();
    return _mapTrackModelToEntity(response);
  }

  @override
  Future<Track> updateTrack(Track track) async {
    await _checkConnectivity();
    final data = {
      'category_id': track.categoryId,
      'title_ar': track.titleAr,
      'title_en': track.titleEn,
      'subtitle_ar': track.subtitleAr,
      'subtitle_en': track.subtitleEn,
      'description_ar': track.descriptionAr,
      'description_en': track.descriptionEn,
      'speaker_ar': track.speakerAr,
      'speaker_en': track.speakerEn,
      'cover_image_url': track.imageUrl,
      'audio_url': track.audioUrl,
      'duration_seconds': track.durationSeconds,
      'published_at': track.publishedAt?.toUtc().toIso8601String(),
      'is_active': track.isActive,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    final response = await client
        .from('tracks')
        .update(data)
        .eq('id', track.id)
        .select('*, track_tags(tags(*))')
        .single();
    return _mapTrackModelToEntity(response);
  }

  @override
  Future<void> deleteTrack(String id) async {
    await _checkConnectivity();
    await client.from('tracks').delete().eq('id', id);
  }

  @override
  Future<Tag> createTag(Tag tag) async {
    await _checkConnectivity();
    final data = {
      'slug': tag.slug,
      'title_ar': tag.titleAr,
      'title_en': tag.titleEn,
    };
    final response = await client.from('tags').insert(data).select().single();
    return TagModel.fromJson(response).toEntity();
  }

  @override
  Future<Tag> updateTag(Tag tag) async {
    await _checkConnectivity();
    final data = {'title_ar': tag.titleAr, 'title_en': tag.titleEn};
    final response = await client
        .from('tags')
        .update(data)
        .eq('id', tag.id)
        .select()
        .single();
    return TagModel.fromJson(response).toEntity();
  }

  @override
  Future<void> deleteTag(String id) async {
    await _checkConnectivity();
    await client.from('tags').delete().eq('id', id);
  }

  @override
  Future<void> setTagTracks(String tagId, List<String> trackIds) async {
    await _checkConnectivity();

    // First, delete all existing links for this tag
    await client.from('track_tags').delete().eq('tag_id', tagId);

    // If there are new tracks, insert them
    if (trackIds.isNotEmpty) {
      final List<Map<String, dynamic>> data = trackIds
          .map((trackId) => {'tag_id': tagId, 'track_id': trackId})
          .toList();
      await client.from('track_tags').insert(data);
    }
  }

  @override
  Future<List<Tag>> getTags() async {
    await _checkConnectivity();
    final response = await client
        .from('tags')
        .select()
        .order('title_ar', ascending: true);
    return (response as List)
        .map((e) => TagModel.fromJson(e).toEntity())
        .toList();
  }

  @override
  Future<PhotoAlbum> createPhotoAlbum(PhotoAlbum album) async {
    await _checkConnectivity();
    final data = {
      'slug': album.slug,
      'title_ar': album.titleAr,
      'title_en': album.titleEn,
      'subtitle_ar': album.subtitleAr,
      'subtitle_en': album.subtitleEn,
      'cover_image_url': album.coverImageUrl,
      'description_ar': album.descriptionAr,
      'description_en': album.descriptionEn,
      'sort_order': album.sortOrder,
      'is_active': album.isActive,
    };
    final response = await client
        .from('photo_albums')
        .insert(data)
        .select()
        .single();
    return PhotoAlbumModel.fromJson(response).toEntity();
  }

  @override
  Future<PhotoAlbum> updatePhotoAlbum(PhotoAlbum album) async {
    await _checkConnectivity();
    final data = {
      'slug': album.slug,
      'title_ar': album.titleAr,
      'title_en': album.titleEn,
      'subtitle_ar': album.subtitleAr,
      'subtitle_en': album.subtitleEn,
      'cover_image_url': album.coverImageUrl,
      'description_ar': album.descriptionAr,
      'description_en': album.descriptionEn,
      'sort_order': album.sortOrder,
      'is_active': album.isActive,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    final response = await client
        .from('photo_albums')
        .update(data)
        .eq('id', album.id)
        .select()
        .single();
    return PhotoAlbumModel.fromJson(response).toEntity();
  }

  @override
  Future<void> deletePhotoAlbum(String id) async {
    await _checkConnectivity();
    await client.from('photo_albums').delete().eq('id', id);
  }

  @override
  Future<Photo> createPhoto(Photo photo) async {
    await _checkConnectivity();
    final data = {
      'album_id': photo.albumId,
      'image_url': photo.imageUrl,
      'title_ar': photo.titleAr,
      'title_en': photo.titleEn,
      'caption_ar': photo.captionAr,
      'caption_en': photo.captionEn,
      'sort_order': photo.sortOrder,
      'is_active': photo.isActive,
    };
    final response = await client.from('photos').insert(data).select().single();
    return PhotoModel.fromJson(response).toEntity();
  }

  @override
  Future<Photo> updatePhoto(Photo photo) async {
    await _checkConnectivity();
    final data = {
      'album_id': photo.albumId,
      'image_url': photo.imageUrl,
      'title_ar': photo.titleAr,
      'title_en': photo.titleEn,
      'caption_ar': photo.captionAr,
      'caption_en': photo.captionEn,
      'sort_order': photo.sortOrder,
      'is_active': photo.isActive,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    final response = await client
        .from('photos')
        .update(data)
        .eq('id', photo.id)
        .select()
        .single();
    return PhotoModel.fromJson(response).toEntity();
  }

  @override
  Future<void> deletePhoto(String id) async {
    await _checkConnectivity();
    await client.from('photos').delete().eq('id', id);
  }

  @override
  Future<VideoAlbum> createVideoAlbum(VideoAlbum album) async {
    await _checkConnectivity();
    final data = {
      'slug': album.slug,
      'title_ar': album.titleAr,
      'title_en': album.titleEn,
      'subtitle_ar': album.subtitleAr,
      'subtitle_en': album.subtitleEn,
      'cover_image_url': album.coverImageUrl,
      'description_ar': album.descriptionAr,
      'description_en': album.descriptionEn,
      'sort_order': album.sortOrder,
      'is_active': album.isActive,
    };
    final response = await client
        .from('video_albums')
        .insert(data)
        .select()
        .single();
    return VideoAlbumModel.fromJson(response).toEntity();
  }

  @override
  Future<VideoAlbum> updateVideoAlbum(VideoAlbum album) async {
    await _checkConnectivity();
    final data = {
      'slug': album.slug,
      'title_ar': album.titleAr,
      'title_en': album.titleEn,
      'subtitle_ar': album.subtitleAr,
      'subtitle_en': album.subtitleEn,
      'cover_image_url': album.coverImageUrl,
      'description_ar': album.descriptionAr,
      'description_en': album.descriptionEn,
      'sort_order': album.sortOrder,
      'is_active': album.isActive,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    final response = await client
        .from('video_albums')
        .update(data)
        .eq('id', album.id)
        .select()
        .single();
    return VideoAlbumModel.fromJson(response).toEntity();
  }

  @override
  Future<void> deleteVideoAlbum(String id) async {
    await _checkConnectivity();
    await client.from('video_albums').delete().eq('id', id);
  }

  @override
  Future<Video> createVideo(Video video) async {
    await _checkConnectivity();
    final data = {
      'album_id': video.albumId,
      'title_ar': video.titleAr,
      'title_en': video.titleEn,
      'subtitle_ar': video.subtitleAr,
      'subtitle_en': video.subtitleEn,
      'description_ar': video.descriptionAr,
      'description_en': video.descriptionEn,
      'video_url': video.videoUrl,
      'thumbnail_url': video.thumbnailUrl,
      'duration_seconds': video.durationSeconds,
      'published_at': video.publishedAt?.toUtc().toIso8601String(),
      'sort_order': video.sortOrder,
      'is_active': video.isActive,
    };
    final response = await client.from('videos').insert(data).select().single();
    return VideoModel.fromJson(response).toEntity();
  }

  @override
  Future<Video> updateVideo(Video video) async {
    await _checkConnectivity();
    final data = {
      'album_id': video.albumId,
      'title_ar': video.titleAr,
      'title_en': video.titleEn,
      'subtitle_ar': video.subtitleAr,
      'subtitle_en': video.subtitleEn,
      'description_ar': video.descriptionAr,
      'description_en': video.descriptionEn,
      'video_url': video.videoUrl,
      'thumbnail_url': video.thumbnailUrl,
      'duration_seconds': video.durationSeconds,
      'published_at': video.publishedAt?.toUtc().toIso8601String(),
      'sort_order': video.sortOrder,
      'is_active': video.isActive,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    final response = await client
        .from('videos')
        .update(data)
        .eq('id', video.id)
        .select()
        .single();
    return VideoModel.fromJson(response).toEntity();
  }

  @override
  Future<void> deleteVideo(String id) async {
    await _checkConnectivity();
    await client.from('videos').delete().eq('id', id);
  }
}
