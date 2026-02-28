import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/track.dart';
import '../../domain/entities/slider.dart' as entity;
import '../constants/app_constants.dart';
import '../../data/models/category_model.dart';
import '../../data/models/track_model.dart';
import '../../data/models/slider_model.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  DateTime? _lastResetEmailSentAt;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  SupabaseClient get client => Supabase.instance.client;

  // ----------------------------
  // Authentication
  // ----------------------------

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Supports metadata via [data] (user_metadata)
  /// Example:
  /// data: { "full_name": "...", "phone": "...", "church": "..." }
  Future<AuthResponse> signUpWithEmail(
      String email,
      String password, {
        Map<String, dynamic>? data,
      }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Password reset with local throttle + rate limit friendly messages
  Future<void> resetPassword(String email) async {
    // Local throttle (60s) to avoid spamming and 429
    final now = DateTime.now();
    if (_lastResetEmailSentAt != null) {
      final diff = now.difference(_lastResetEmailSentAt!);
      if (diff.inSeconds < 60) {
        throw Exception(
          'Please wait ${60 - diff.inSeconds}s before requesting another reset link.',
        );
      }
    }

    try {
      await client.auth.resetPasswordForEmail(email);
      _lastResetEmailSentAt = now;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (e.statusCode == '429' || msg.contains('rate limit')) {
        throw Exception('Too many requests. Please wait a few minutes and try again.');
      }
      rethrow;
    }
  }

  // ----------------------------
  // Profile management (SAFE with RLS)
  // ----------------------------

  String? get currentUserId => client.auth.currentUser?.id;

  bool get isAuthenticated => client.auth.currentUser != null;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Read my profile (returns null if not exists)
  Future<Map<String, dynamic>?> getMyProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final data = await client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Insert my profile once (requires authenticated + RLS policy: auth.uid() = id)
  Future<void> insertMyProfile({
    required String fullName,
    String? phone,
    String? church,
    String? gender,
    DateTime? birthDate,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    final payload = <String, dynamic>{
      'id': uid,
      'full_name': fullName.trim().isEmpty ? 'User' : fullName.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (phone != null && phone.trim().isNotEmpty) payload['phone'] = phone.trim();
    if (church != null && church.trim().isNotEmpty) payload['church'] = church.trim();
    if (gender != null && gender.trim().isNotEmpty) payload['gender'] = gender.trim();
    if (birthDate != null) payload['birth_date'] = birthDate.toIso8601String();

    await client.from('profiles').insert(payload);
  }

  /// Update my profile (only sends non-empty fields)
  Future<void> updateMyProfile({
    String? fullName,
    String? phone,
    String? church,
    String? gender,
    DateTime? birthDate,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    final update = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null && fullName.trim().isNotEmpty) update['full_name'] = fullName.trim();
    if (phone != null && phone.trim().isNotEmpty) update['phone'] = phone.trim();
    if (church != null && church.trim().isNotEmpty) update['church'] = church.trim();
    if (gender != null && gender.trim().isNotEmpty) update['gender'] = gender.trim();
    if (birthDate != null) update['birth_date'] = birthDate.toIso8601String();

    // If nothing besides updated_at, skip
    if (update.length == 1) return;

    await client.from('profiles').update(update).eq('id', uid);
  }

  /// Call this ONLY after successful login.
  /// - If profile not found: inserts it using metadata fallback.
  /// - If found: optionally fills missing fields from metadata.
  Future<void> ensureMyProfileExists({
    String? fallbackFullName,
    String? fallbackPhone,
    String? fallbackChurch,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    final user = client.auth.currentUser!;
    final meta = user.userMetadata ?? {};

    final metaFullName = (meta['full_name'] ?? fallbackFullName ?? '').toString();
    final metaPhone = (meta['phone'] ?? fallbackPhone ?? '').toString();
    final metaChurch = (meta['church'] ?? fallbackChurch ?? '').toString();
    final metaGender = (meta['gender'] ?? '').toString();
    final metaBirthDateStr = (meta['birth_date'] ?? '').toString();
    DateTime? metaBirthDate;
    if (metaBirthDateStr.isNotEmpty) {
      try {
        metaBirthDate = DateTime.parse(metaBirthDateStr);
      } catch (_) {}
    }

    final profile = await getMyProfile();

    if (profile == null) {
      await insertMyProfile(
        fullName: metaFullName.isNotEmpty ? metaFullName : 'User',
        phone: metaPhone,
        church: metaChurch,
        gender: metaGender,
        birthDate: metaBirthDate,
      );
      return;
    }

    // Fill missing fields only
    final currentName = (profile['full_name'] ?? '').toString();
    final currentPhone = (profile['phone'] ?? '').toString();
    final currentChurch = (profile['church'] ?? '').toString();
    final currentGender = (profile['gender'] ?? '').toString();
    final currentBirthDate = profile['birth_date'];

    await updateMyProfile(
      fullName: currentName.isNotEmpty ? null : metaFullName,
      phone: currentPhone.isNotEmpty ? null : metaPhone,
      church: currentChurch.isNotEmpty ? null : metaChurch,
      gender: currentGender.isNotEmpty ? null : metaGender,
      birthDate: currentBirthDate != null ? null : metaBirthDate,
    );
  }

  // ----------------------------
  // Notifications
  // ----------------------------

  Future<List<Map<String, dynamic>>> getNotifications({int limit = 20}) async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await client
        .from('notification_recipients')
        .select('''
          notifications!id,
          notifications!kind,
          notifications!audience,
          notifications!title_ar,
          notifications!title_en,
          notifications!body_ar,
          notifications!body_en,
          notifications!image_url,
          notifications!action_type,
          notifications!external_url,
          notifications!internal_route,
          notifications!internal_id,
          notifications!entity_type,
          notifications!entity_id,
          notifications!sent_at,
          notifications!created_at,
          notifications!updated_at,
          notification_recipients!is_read,
          notification_recipients!read_at,
          notification_recipients!created_at as recipient_created_at
        ''')
        .eq('notification_recipients.user_id', userId)
        .eq('notifications.is_active', true)
        .order('notification_recipients.created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final userId = currentUserId;
    if (userId == null) return;

    await client
        .from('notification_recipients')
        .update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    })
        .eq('notification_id', notificationId)
        .eq('user_id', userId);
  }

  Future<void> toggleFavorite({
    required String trackId,
    required bool makeFavorite,
  }) async {
    final uid = currentUserId;
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

  // ==================== DATA FETCHING ====================

  Future<Map<String, dynamic>?> fetchMyProfile() async {
    return await getMyProfile();
  }

  Future<List<entity.Slider>> fetchSliders() async {
    final response = await client
        .from('sliders')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (response as List).map((sliderMap) {
      final model = SliderModel.fromJson(sliderMap as Map<String, dynamic>);
      return entity.Slider(
        id: model.id,
        titleAr: model.titleAr,
        titleEn: model.titleEn,
        subtitleAr: model.subtitleAr,
        subtitleEn: model.subtitleEn,
        imageUrl: model.imageUrl,
        linkUrl: model.linkUrl,
        sortOrder: model.sortOrder,
        isActive: model.isActive,
      );
    }).toList();
  }

  Future<List<Category>> fetchCategories() async {
    final response = await client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (response as List).map((catMap) {
      final model = CategoryModel.fromJson(catMap as Map<String, dynamic>);
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
    }).toList();
  }

  Future<List<Track>> fetchTopTracks({int limit = 10}) async {
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

    return (response as List).map((trackMap) {
      final model = TrackModel.fromJson(trackMap as Map<String, dynamic>);
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

  Future<Set<String>> fetchMyFavoriteTrackIds() async {
    final uid = currentUserId;
    if (uid == null) return <String>{};

    final response = await client
        .from('favorites')
        .select('track_id')
        .eq('user_id', uid);

    return Set<String>.from(response.map((fav) => fav['track_id']));
  }

  Future<List<Map<String, dynamic>>> fetchMyFavoriteTracks() async {
    final uid = currentUserId;
    if (uid == null) return [];

    final response = await client
        .from('favorites')
        .select('''
          tracks!id,
          tracks!title_ar,
          tracks!title_en,
          tracks!speaker_ar,
          tracks!speaker_en,
          tracks!cover_image_url,
          tracks!audio_url,
          tracks!duration_seconds,
          favorites!created_at
        ''')
        .eq('user_id', uid)
        .order('favorites!created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<List<Map<String, dynamic>>> searchTracks(String query) async {
    final response = await client
        .from('tracks')
        .select('''
          id,
          title_ar,
          title_en,
          subtitle_ar,
          subtitle_en,
          speaker_ar,
          speaker_en,
          cover_image_url,
          audio_url,
          duration_seconds
        ''')
        .or('title_ar.ilike.%$query%,title_en.ilike.%$query%')
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(20);

    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<void> markAllNotificationsAsRead() async {
    final userId = currentUserId;
    if (userId == null) return;

    await client
        .from('notification_recipients')
        .update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    })
        .eq('user_id', userId)
        .eq('is_read', false);
  }
}

