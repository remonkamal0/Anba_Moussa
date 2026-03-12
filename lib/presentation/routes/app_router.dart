import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_view.dart';
import '../screens/player/player_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/album/album_details_screen.dart';
import '../screens/artist/artist_details_screen.dart';
import '../screens/playlist/playlist_details_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/create_account_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/gallery/photo_gallery_screen.dart';
import '../screens/gallery/video_gallery_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/favorites/all_playlists_screen.dart';
import '../screens/downloads/downloads_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/admin/send_notification_screen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/supabase_service.dart';
import '../screens/gallery/photo_album_details_screen.dart';
import '../screens/gallery/video_album_details_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_categories_screen.dart';
import '../screens/admin/admin_category_form_screen.dart';
import '../screens/admin/admin_tracks_screen.dart';
import '../screens/admin/admin_track_form_screen.dart';
import '../screens/admin/admin_tags_screen.dart';
import '../screens/admin/admin_tag_form_screen.dart';
import '../screens/admin/admin_tag_tracks_screen.dart';
import '../screens/admin/admin_photo_albums_screen.dart';
import '../screens/admin/admin_photo_album_form_screen.dart';
import '../screens/admin/admin_photos_screen.dart';
import '../screens/admin/admin_photo_form_screen.dart';
import '../screens/admin/admin_video_albums_screen.dart';
import '../screens/admin/admin_video_album_form_screen.dart';
import '../screens/admin/admin_videos_screen.dart';
import '../screens/admin/admin_video_form_screen.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/track.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/photo.dart';
import '../../domain/entities/photo_album.dart';
import '../../domain/entities/video_album.dart';
import '../../domain/entities/video.dart';
import '../widgets/layout/main_layout.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppConstants.onboardingRoute,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.onboardingRoute,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/create-account',
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/admin',
        redirect: (context, state) async {
          // Guard: only allow users with role = 'admin'
          final profile = await SupabaseService.instance.getMyProfile();
          final role = profile?['role'] as String? ?? 'user';
          if (role != 'admin') return AppConstants.homeRoute;
          if (state.uri.path == '/admin') return '/admin/dashboard';
          return null; // allow
        },
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: 'send-notification',
            builder: (context, state) => const SendNotificationScreen(),
          ),
          GoRoute(
            path: 'categories',
            builder: (context, state) => const AdminCategoriesScreen(),
          ),
          GoRoute(
            path: 'categories/new',
            builder: (context, state) => const AdminCategoryFormScreen(),
          ),
          GoRoute(
            path: 'categories/edit',
            builder: (context, state) =>
                AdminCategoryFormScreen(category: state.extra as Category),
          ),
          GoRoute(
            path: 'tracks',
            builder: (context, state) => const AdminTracksScreen(),
          ),
          GoRoute(
            path: 'tracks/new',
            builder: (context, state) => const AdminTrackFormScreen(),
          ),
          GoRoute(
            path: 'tracks/edit',
            builder: (context, state) =>
                AdminTrackFormScreen(track: state.extra as Track),
          ),
          GoRoute(
            path: 'tags',
            builder: (context, state) => const AdminTagsScreen(),
          ),
          GoRoute(
            path: 'tags/new',
            builder: (context, state) => const AdminTagFormScreen(),
          ),
          GoRoute(
            path: 'tags/edit',
            builder: (context, state) =>
                AdminTagFormScreen(tag: state.extra as Tag),
          ),
          GoRoute(
            path: 'tags/link',
            builder: (context, state) =>
                AdminTagTracksScreen(tag: state.extra as Tag),
          ),
          GoRoute(
            path: 'photo-albums',
            builder: (context, state) => const AdminPhotoAlbumsScreen(),
          ),
          GoRoute(
            path: 'photo-albums/new',
            builder: (context, state) => const AdminPhotoAlbumFormScreen(),
          ),
          GoRoute(
            path: 'photo-albums/edit',
            builder: (context, state) =>
                AdminPhotoAlbumFormScreen(album: state.extra as PhotoAlbum),
          ),
          GoRoute(
            path: 'photos',
            builder: (context, state) => const AdminPhotosScreen(),
          ),
          GoRoute(
            path: 'photos/new',
            builder: (context, state) => AdminPhotoFormScreen(
              albumId: state.uri.queryParameters['albumId']!,
            ),
          ),
          GoRoute(
            path: 'photos/edit',
            builder: (context, state) {
              final map = state.extra as Map<String, dynamic>;
              return AdminPhotoFormScreen(
                photo: map['photo'] as Photo,
                albumId: map['albumId'] as String,
              );
            },
          ),
          GoRoute(
            path: 'video-albums',
            builder: (context, state) => const AdminVideoAlbumsScreen(),
          ),
          GoRoute(
            path: 'video-albums/new',
            builder: (context, state) => const AdminVideoAlbumFormScreen(),
          ),
          GoRoute(
            path: 'video-albums/edit',
            builder: (context, state) =>
                AdminVideoAlbumFormScreen(album: state.extra as VideoAlbum),
          ),
          GoRoute(
            path: 'videos',
            builder: (context, state) => const AdminVideosScreen(),
          ),
          GoRoute(
            path: 'videos/new',
            builder: (context, state) => AdminVideoFormScreen(
              albumId: state.uri.queryParameters['albumId']!,
            ),
          ),
          GoRoute(
            path: 'videos/edit',
            builder: (context, state) {
              final map = state.extra as Map<String, dynamic>;
              return AdminVideoFormScreen(
                video: map['video'] as Video,
                albumId: map['albumId'] as String,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/artist/:artistId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final artistId = state.pathParameters['artistId']!;
          return ArtistDetailsScreen(artistId: artistId);
        },
      ),
      GoRoute(
        path: '/playlist/:playlistId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final playlistId = state.pathParameters['playlistId']!;
          return PlaylistDetailsScreen(playlistId: playlistId);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/favorites',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/all-playlists',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AllPlaylistsScreen(),
      ),
      GoRoute(
        path: '/downloads',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DownloadsScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: AppConstants.homeRoute,
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: AppConstants.photoGalleryRoute,
            builder: (context, state) => const PhotoGalleryScreen(),
          ),
          GoRoute(
            path: AppConstants.videoGalleryRoute,
            builder: (context, state) => const VideoGalleryScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/album/:albumId',
            builder: (context, state) {
              final albumId = state.pathParameters['albumId']!;
              final title = state.uri.queryParameters['title'] ?? 'Album';
              final imageUrl = state.uri.queryParameters['imageUrl'] ?? '';
              final artist = state.uri.queryParameters['artist'] ?? '';
              final year = state.uri.queryParameters['year'] ?? '';
              return AlbumDetailsScreen(
                albumId: albumId,
                title: title,
                imageUrl: imageUrl,
                artist: artist,
                year: year,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppConstants.playerRoute,
        name: 'player',
        builder: (context, state) {
          final trackId = state.uri.queryParameters['trackId'];
          return PlayerScreen(trackId: trackId);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/photo-album/:albumId',
        builder: (context, state) {
          final albumId = state.pathParameters['albumId']!;
          return _PhotoAlbumDeepLinkScreen(albumId: albumId);
        },
      ),
      GoRoute(
        path: '/video-album/:albumId',
        builder: (context, state) {
          final albumId = state.pathParameters['albumId']!;
          return _VideoAlbumDeepLinkScreen(albumId: albumId);
        },
      ),
      GoRoute(
        path: '/video/:videoId',
        builder: (context, state) {
          final videoId = state.pathParameters['videoId']!;
          return _VideoDeepLinkScreen(videoId: videoId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.path}')),
    ),
  );
});

// ---------------------------------------------------------------------------
// Helpers for Gallery Deep Links
// ---------------------------------------------------------------------------

class _PhotoAlbumDeepLinkScreen extends StatefulWidget {
  final String albumId;
  const _PhotoAlbumDeepLinkScreen({required this.albumId});

  @override
  State<_PhotoAlbumDeepLinkScreen> createState() =>
      _PhotoAlbumDeepLinkScreenState();
}

class _PhotoAlbumDeepLinkScreenState extends State<_PhotoAlbumDeepLinkScreen> {
  bool _isLoading = true;
  String? _error;
  var _album;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await SupabaseService.instance.client
          .from('photo_albums')
          .select()
          .eq('id', widget.albumId)
          .maybeSingle();
      if (res != null) {
        // Need to import PhotoAlbumModel or parse manually.
        // We'll parse it simply:
        _album = _parsePhotoAlbum(res);
      } else {
        _error = 'Album not found';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  PhotoAlbum _parsePhotoAlbum(Map<String, dynamic> json) {
    return PhotoAlbum(
      id: json['id'],
      slug: json['slug'],
      titleAr: json['title_ar'] ?? '',
      titleEn: json['title_en'] ?? '',
      subtitleAr: json['subtitle_ar'],
      subtitleEn: json['subtitle_en'],
      coverImageUrl: json['cover_image_url'],
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _album == null)
      return Scaffold(body: Center(child: Text(_error ?? 'Not found')));
    return PhotoAlbumDetailsScreen(album: _album);
  }
}

class _VideoAlbumDeepLinkScreen extends StatefulWidget {
  final String albumId;
  const _VideoAlbumDeepLinkScreen({required this.albumId});

  @override
  State<_VideoAlbumDeepLinkScreen> createState() =>
      _VideoAlbumDeepLinkScreenState();
}

class _VideoAlbumDeepLinkScreenState extends State<_VideoAlbumDeepLinkScreen> {
  bool _isLoading = true;
  String? _error;
  var _album;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await SupabaseService.instance.client
          .from('video_albums')
          .select()
          .eq('id', widget.albumId)
          .maybeSingle();
      if (res != null) {
        _album = _parseVideoAlbum(res);
      } else {
        _error = 'Album not found';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  VideoAlbum _parseVideoAlbum(Map<String, dynamic> json) {
    return VideoAlbum(
      id: json['id'],
      slug: json['slug'],
      titleAr: json['title_ar'] ?? '',
      titleEn: json['title_en'] ?? '',
      subtitleAr: json['subtitle_ar'],
      subtitleEn: json['subtitle_en'],
      coverImageUrl: json['cover_image_url'],
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _album == null)
      return Scaffold(body: Center(child: Text(_error ?? 'Not found')));
    return VideoAlbumDetailsScreen(album: _album);
  }
}

class _VideoDeepLinkScreen extends StatefulWidget {
  final String videoId;
  const _VideoDeepLinkScreen({required this.videoId});

  @override
  State<_VideoDeepLinkScreen> createState() => _VideoDeepLinkScreenState();
}

class _VideoDeepLinkScreenState extends State<_VideoDeepLinkScreen> {
  bool _isLoading = true;
  String? _error;
  dynamic _video;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await SupabaseService.instance.client
          .from('videos')
          .select()
          .eq('id', widget.videoId)
          .maybeSingle();
      if (res != null) {
        _video = _parseVideo(res);
      } else {
        _error = 'Video not found';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  dynamic _parseVideo(Map<String, dynamic> json) {
    // Basic mapping to domain Video entity
    return Video(
      id: json['id'],
      albumId: json['album_id'],
      titleAr: json['title_ar'] ?? '',
      titleEn: json['title_en'] ?? '',
      subtitleAr: json['subtitle_ar'],
      subtitleEn: json['subtitle_en'],
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      durationSeconds: json['duration_seconds'],
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _video == null)
      return Scaffold(body: Center(child: Text(_error ?? 'Not found')));
    return VideoPlaybackMockScreen(video: _video);
  }
}
