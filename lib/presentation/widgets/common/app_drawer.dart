import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _onNavigationItemTapped(BuildContext context, String route) {
    Navigator.of(context).pop(); // Close drawer
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header with user profile
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppConstants.largeSpacing.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF6B35),
                  const Color(0xFFFF8C42),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: ClipOval(
                    child: Image.network(
                      'https://picsum.photos/seed/user-avatar/100/100',
                      width: 80.w,
                      height: 80.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 40.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).animate().scale(
                  duration: AppConstants.defaultAnimationDuration,
                  curve: Curves.easeOut,
                ),

                SizedBox(height: AppConstants.mediumSpacing.h),

                // User name
                Text(
                  'Alex Johnson',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 200),
                ),

                SizedBox(height: AppConstants.extraSmallSpacing.h),

                // User email
                Text(
                  'alex.johnson@example.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ).animate().fadeIn(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 400),
                ),
              ],
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Home
                _buildDrawerItem(
                  context,
                  icon: Icons.home_outlined,
                  title: 'Home',
                  route: '/',
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 600),
                  begin: -0.2,
                  curve: Curves.easeOut,
                ),

                // Library
                _buildDrawerItem(
                  context,
                  icon: Icons.library_music_outlined,
                  title: 'Library',
                  route: '/library',
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 700),
                  begin: -0.2,
                  curve: Curves.easeOut,
                ),

                // Favorites
                _buildDrawerItem(
                  context,
                  icon: Icons.favorite_outline,
                  title: 'Favorites',
                  route: '/favorites',
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 800),
                  begin: -0.2,
                  curve: Curves.easeOut,
                ),

                // All Playlists
                _buildDrawerItem(
                  context,
                  icon: Icons.playlist_play_outlined,
                  title: 'All Playlists',
                  route: '/all-playlists',
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 900),
                  begin: -0.2,
                  curve: Curves.easeOut,
                ),

                // Photo Gallery
                _buildDrawerItem(
                  context,
                  icon: Icons.photo_library_outlined,
                  title: 'Photo Gallery',
                  route: '/photo-gallery',
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 1000),
                  begin: -0.2,
                  curve: Curves.easeOut,
                ),

                // Video Gallery
                _buildDrawerItem(
                  context,
                  icon: Icons.video_library_outlined,
                  title: 'Video Gallery',
                  route: '/video-gallery',
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 1100),
                  begin: -0.2,
                  curve: Curves.easeOut,
                ),

                // Notifications
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  route: '/notifications',
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 1200),
                  begin: -0.2,
                  curve: Curves.easeOut,
                ),

                // Divider
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.mediumSpacing.r,
                    vertical: AppConstants.mediumSpacing.h,
                  ),
                  child: Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                  ),
                ),

                // Profile
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Profile',
                  route: '/profile',
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 1300),
                  begin: -0.2,
                  curve: Curves.easeOut,
                ),

                // Settings
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  route: '/profile/edit',
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 1400),
                  begin: -0.2,
                  curve: Curves.easeOut,
                ),

                // Divider
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.mediumSpacing.r,
                    vertical: AppConstants.mediumSpacing.h,
                  ),
                  child: Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                  ),
                ),

                // Help & Support
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  route: '/help',
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 1500),
                  begin: -0.2,
                  curve: Curves.easeOut,
                ),

                // About
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  route: '/about',
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: const Duration(milliseconds: 1600),
                  begin: -0.2,
                  curve: Curves.easeOut,
                ),
              ],
            ),
          ),

          // Logout button
          Container(
            padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.red,
                size: 24.w,
              ),
              title: Text(
                'Logout',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                // TODO: Implement logout
                context.go('/login');
              },
            ).animate().slideX(
              duration: AppConstants.defaultAnimationDuration,
              delay: const Duration(milliseconds: 1700),
              begin: -0.2,
              curve: Curves.easeOut,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.black,
        size: 24.w,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      onTap: () => _onNavigationItemTapped(context, route),
    );
  }
}
