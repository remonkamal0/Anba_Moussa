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

  Future<void> updateUserPassword(String newPassword) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    
    await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
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

    // Step 1: Fetch all active notifications (all audiences)
    final publicRaw = await client
        .from('notifications')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(limit);

    // Step 2: Fetch this user's notification_recipients (for read-status overlay)
    final recipientRaw = await client
        .from('notification_recipients')
        .select('notification_id, is_read, read_at')
        .eq('user_id', userId);

    // Build a lookup map: notification_id -> recipient row
    final recipientMap = <String, Map<String, dynamic>>{};
    for (final r in recipientRaw) {
      final id = r['notification_id'] as String?;
      if (id != null) recipientMap[id] = Map<String, dynamic>.from(r);
    }

    // Step 3: Build unified list
    // Show notification if:
    //   - audience == 'all'  → visible to everyone
    //   - audience == 'specific' and user has a recipient row
    final result = <Map<String, dynamic>>[];

    for (final n in publicRaw) {
      final id = n['id'] as String?;
      if (id == null) continue;

      final audience = n['audience'] as String? ?? 'all';
      final hasRecipientRow = recipientMap.containsKey(id);

      // Skip specific-audience notifications that are not addressed to this user
      if (audience != 'all' && !hasRecipientRow) continue;

      final recipient = hasRecipientRow ? recipientMap[id] : null;
      result.add({
        'is_read': recipient?['is_read'] ?? false,
        'read_at': recipient?['read_at'],
        'notifications': Map<String, dynamic>.from(n),
      });
    }

    // Sort by sent_at or created_at descending
    result.sort((a, b) {
      final aDate = (a['notifications']['sent_at'] ?? a['notifications']['created_at']) as String?;
      final bDate = (b['notifications']['sent_at'] ?? b['notifications']['created_at']) as String?;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return result.take(limit).toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final userId = currentUserId;
    if (userId == null) return;

    await client
        .from('notification_recipients')
        .upsert({
          'notification_id': notificationId,
          'user_id': userId,
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        });
  }

  /// Inserts a new notification into `notifications`.
  /// If [audience] is 'specific', you must provide [recipientUserIds].
  Future<void> sendNotification({
    required String titleAr,
    required String titleEn,
    String? bodyAr,
    String? bodyEn,
    String kind = 'general',
    String audience = 'all',
    String actionType = 'none',
    String? internalRoute,
    String? internalId,
    String? externalUrl,
    String? imageUrl,
    List<String> recipientUserIds = const [],
  }) async {
    final now = DateTime.now().toIso8601String();

    final response = await client
        .from('notifications')
        .insert({
          'title_ar': titleAr,
          'title_en': titleEn,
          if (bodyAr != null) 'body_ar': bodyAr,
          if (bodyEn != null) 'body_en': bodyEn,
          'kind': kind,
          'audience': audience,
          'action_type': actionType,
          if (internalRoute != null) 'internal_route': internalRoute,
          if (internalId != null) 'internal_id': internalId,
          if (externalUrl != null) 'external_url': externalUrl,
          if (imageUrl != null) 'image_url': imageUrl,
          'is_active': true,
          'sent_at': now,
        })
        .select('id')
        .single();

    final notificationId = response['id'] as String;

    // If specific audience, insert recipient rows
    if (audience == 'specific' && recipientUserIds.isNotEmpty) {
      final rows = recipientUserIds.map((uid) => {
        'notification_id': notificationId,
        'user_id': uid,
        'is_read': false,
      }).toList();
      await client.from('notification_recipients').insert(rows);
    }
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
        titleAr: model.titleAr ?? '',
        titleEn: model.titleEn ?? '',
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
        audioUrl: model.audioUrl ?? '',
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

    // 1. Fetch current visible notifications (similar to getNotifications but just IDs)
    final notifications = await getNotifications(limit: 50);
    final unreadIds = notifications
        .where((n) => !(n['is_read'] as bool))
        .map((n) => n['notifications']['id'] as String)
        .toList();

    if (unreadIds.isEmpty) return;

    // 2. Upsert read status for all unread notifications
    final now = DateTime.now().toIso8601String();
    final rows = unreadIds.map((id) => {
      'notification_id': id,
      'user_id': userId,
      'is_read': true,
      'read_at': now,
    }).toList();

    await client.from('notification_recipients').upsert(rows);
  }
}

