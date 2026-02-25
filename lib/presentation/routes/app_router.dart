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
import '../screens/profile/profile_screen.dart';
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
import '../screens/search/search_screen.dart';
import '../../core/constants/app_constants.dart';
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
        path: '/artist/:artistId',
        builder: (context, state) {
          final artistId = state.pathParameters['artistId']!;
          return ArtistDetailsScreen(artistId: artistId);
        },
      ),
      GoRoute(
        path: '/playlist/:playlistId',
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
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/all-playlists',
        builder: (context, state) => const AllPlaylistsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
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
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/album/:albumId',
        builder: (context, state) {
          final albumId = state.pathParameters['albumId']!;
          return AlbumDetailsScreen();
        },
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppConstants.playerRoute,
        builder: (context, state) {
          final trackId = state.uri.queryParameters['trackId'];
          return PlayerScreen(trackId: trackId);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
});
