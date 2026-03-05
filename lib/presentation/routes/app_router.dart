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
import '../../domain/entities/photo_album.dart';
import '../../domain/entities/video_album.dart';
import '../widgets/layout/main_layout.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.onboardingRoute,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
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
        path: '/admin/send-notification',
        redirect: (context, state) async {
          // Guard: only allow users with role = 'admin'
          final profile = await SupabaseService.instance.getMyProfile();
          final role = profile?['role'] as String? ?? 'user';
          if (role != 'admin') return '/home';
          return null; // allow
        },
        builder: (context, state) => const SendNotificationScreen(),
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
            path: '/photo-gallery',
            builder: (context, state) => const PhotoGalleryScreen(),
          ),
          GoRoute(
            path: '/video-gallery',
            builder: (context, state) => const VideoGalleryScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/album/:albumId',
        parentNavigatorKey: _rootNavigatorKey,
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
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
  State<_PhotoAlbumDeepLinkScreen> createState() => _PhotoAlbumDeepLinkScreenState();
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
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _album == null) return Scaffold(body: Center(child: Text(_error ?? 'Not found')));
    return PhotoAlbumDetailsScreen(album: _album);
  }
}

class _VideoAlbumDeepLinkScreen extends StatefulWidget {
  final String albumId;
  const _VideoAlbumDeepLinkScreen({required this.albumId});

  @override
  State<_VideoAlbumDeepLinkScreen> createState() => _VideoAlbumDeepLinkScreenState();
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
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _album == null) return Scaffold(body: Center(child: Text(_error ?? 'Not found')));
    return VideoAlbumDetailsScreen(album: _album);
  }
}
