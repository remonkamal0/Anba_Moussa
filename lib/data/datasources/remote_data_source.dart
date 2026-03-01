import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/slider.dart' as entity_slider;
import '../../domain/entities/track.dart';
import '../models/category_model.dart';
import '../models/track_model.dart';
import '../models/photo_album_model.dart';
import '../models/photo_model.dart';
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
  Future<void> toggleFavorite({required String trackId, required bool makeFavorite});
  Future<List<Track>> searchTracks(String query);
  Future<Track?> getTrackById(String id);
  Future<List<Track>> getFavoriteTracks();
  Future<List<Track>> getTracks({String? categoryId});
  Future<List<PhotoAlbum>> getPhotoAlbums();
  Future<List<Photo>> getPhotosByAlbumId(String albumId);
  Future<List<VideoAlbum>> getVideoAlbums();
  Future<List<Video>> getVideosByAlbumId(String albumId);
}

class SupabaseRemoteDataSourceImpl implements RemoteDataSource {
  final SupabaseClient client;

  SupabaseRemoteDataSourceImpl({required this.client});

  String? _getCurrentUserId() => client.auth.currentUser?.id;

  Track _mapTrackModelToEntity(Map<String, dynamic> json) {
    final model = TrackModel.fromJson(json);
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
  }

  Category _mapCategoryModelToEntity(Map<String, dynamic> json) {
    final model = CategoryModel.fromJson(json);
    return Category(
      id: model.id,
      slug: model.slug,
      titleAr: model.titleAr,
      titleEn: model.titleEn,
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
    final response = await client
        .from('tracks')
        .select('''
          id,
          title_ar,
          title_en,
          subtitle_ar,
          subtitle_en,
          description_ar,
          description_en,
          speaker_ar,
          speaker_en,
          cover_image_url,
          audio_url,
          duration_seconds,
          published_at,
          is_active,
          created_at,
          updated_at,
          category_id
        ''')
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((trackMap) => _mapTrackModelToEntity(trackMap as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Category>> getCategories() async {
    final response = await client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (response as List).map((categoryMap) => _mapCategoryModelToEntity(categoryMap as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<entity_slider.Slider>> getSliders() async {
    final response = await client
        .from('sliders')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (response as List).map((map) => entity_slider.Slider.fromMap(map as Map<String, dynamic>)).toList();
  }

  @override
  Future<Set<String>> getFavoriteTrackIds() async {
    final uid = _getCurrentUserId();
    if (uid == null) return <String>{};

    final response = await client
        .from('favorites')
        .select('track_id')
        .eq('user_id', uid);

    return Set<String>.from((response as List).map((fav) => fav['track_id']));
  }

  @override
  Future<void> toggleFavorite({required String trackId, required bool makeFavorite}) async {
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
    final response = await client
        .from('tracks')
        .select('*')
        .eq('is_active', true)
        .or('title_ar.ilike.%$query%,title_en.ilike.%$query%')
        .order('created_at', ascending: false)
        .limit(20);

    return (response as List).map((json) => _mapTrackModelToEntity(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Track?> getTrackById(String id) async {
    final response = await client
        .from('tracks')
        .select('*')
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return _mapTrackModelToEntity(response);
  }

  @override
  Future<List<Track>> getFavoriteTracks() async {
    final uid = _getCurrentUserId();
    if (uid == null) return [];
    final response = await client
        .from('favorites')
        .select('tracks(*)')
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
        .select('*')
        .eq('is_active', true);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    
    final response = await query.order('created_at', ascending: false);

    return (response as List).map((json) => _mapTrackModelToEntity(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<PhotoAlbum>> getPhotoAlbums() async {
    final response = await client
        .from('photo_albums')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => PhotoAlbumModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<Photo>> getPhotosByAlbumId(String albumId) async {
    final response = await client
        .from('photos')
        .select()
        .eq('album_id', albumId)
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response as List)
        .map((json) => PhotoModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<VideoAlbum>> getVideoAlbums() async {
    final response = await client
        .from('video_albums')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => VideoAlbumModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<Video>> getVideosByAlbumId(String albumId) async {
    final response = await client
        .from('videos')
        .select()
        .eq('album_id', albumId)
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response as List)
        .map((json) => VideoModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }
}

