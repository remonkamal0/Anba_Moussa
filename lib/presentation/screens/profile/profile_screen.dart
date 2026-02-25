import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'EN';
  String _selectedAccentColor = 'orange';

  final UserProfile _user = UserProfile(
    name: 'Alex Rivera',
    email: 'alex.rivera@example.com',
  );

  void _onLanguageTap() {
    // TODO: Show language selector
    print('Language tapped');
  }

  void _onThemeTap() {
    // TODO: Show theme selector
    print('Theme tapped');
  }

  void _onAccentColorTap(String color) {
    setState(() {
      _selectedAccentColor = color;
    });
    // TODO: Apply accent color
  }

  void _onMyPlaylists() {
    // TODO: Navigate to playlists
    print('My playlists');
  }

  void _onFavorites() {
    // TODO: Navigate to favorites
    print('Favorites');
  }

  void _onDownloads() {
    // TODO: Navigate to downloads
    print('Downloads');
  }

  void _onNotifications() {
    // TODO: Navigate to notifications
    print('Notifications');
  }

  void _onLogout() async {
    // TODO: Implement logout
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // TODO: Clear session and navigate to login
      print('Logging out...');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
          child: Column(
            children: [
              // User info section
              Container(
                padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
                ),
                child: Column(
                  children: [
                    // User avatar
                    CircleAvatar(
                      radius: 40.r,
                      backgroundColor: const Color(0xFFFF6B35),
                      child: Text(
                        _user.name.split(' ').map((name) => name[0]).join(''),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().scale(
                      duration: AppConstants.defaultAnimationDuration,
                      curve: Curves.easeOut,
                    ),

                    SizedBox(height: AppConstants.mediumSpacing.h),

                    // User name
                    Text(
                      _user.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ).animate().fadeIn(
                      duration: AppConstants.defaultAnimationDuration,
                      delay: const Duration(milliseconds: 200),
                    ),

                    SizedBox(height: AppConstants.smallSpacing.h),

                    // User email
                    Text(
                      _user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ).animate().fadeIn(
                      duration: AppConstants.defaultAnimationDuration,
                      delay: const Duration(milliseconds: 400),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppConstants.largeSpacing.h),

              // Menu items
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuItem(
                      icon: Icons.playlist_play,
                      title: 'My Playlists',
                      onTap: _onMyPlaylists,
                      delay: const Duration(milliseconds: 600),
                    ),
                    _buildMenuItem(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: _selectedLanguage,
                      onTap: _onLanguageTap,
                      delay: const Duration(milliseconds: 800),
                    ),
                    _buildMenuItem(
                      icon: _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      title: 'Dark Mode',
                      onTap: () {
                        setState(() {
                          _isDarkMode = !_isDarkMode;
                        });
                        // TODO: Apply theme
                      },
                      delay: const Duration(milliseconds: 1000),
                    ),
                    _buildMenuItem(
                      icon: Icons.palette,
                      title: 'Theme',
                      customWidget: _buildAccentColorSelector(),
                      onTap: _onThemeTap,
                      delay: const Duration(milliseconds: 1200),
                    ),
                    _buildMenuItem(
                      icon: Icons.favorite,
                      title: 'Favorites',
                      onTap: _onFavorites,
                      delay: const Duration(milliseconds: 1400),
                    ),
                    _buildMenuItem(
                      icon: Icons.download,
                      title: 'Downloads',
                      onTap: _onDownloads,
                      delay: const Duration(milliseconds: 1600),
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: _onNotifications,
                      delay: const Duration(milliseconds: 1800),
                    ),
                  ],
                ),
              ),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppConstants.mediumSpacing.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
                    ),
                  ),
                  child: Text(
                    'Log Out',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 2000),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? customWidget,
    Duration? delay,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.smallSpacing.h),
      child: ListTile(
        contentPadding: EdgeInsets.all(AppConstants.mediumSpacing.r),
        leading: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius.r),
          ),
          child: Icon(
            icon,
            color: Colors.grey[700],
            size: 20.w,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            : customWidget,
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ).animate().slideX(
        duration: AppConstants.defaultAnimationDuration,
        delay: delay ?? Duration.zero,
        begin: 0.2,
        curve: Curves.easeOut,
      ),
    );
  }

  Widget _buildAccentColorSelector() {
    final colors = {
      'orange': const Color(0xFFFF6B35),
      'blue': const Color(0xFF4A90E2),
      'green': const Color(0xFF4CAF50),
      'yellow': const Color(0xFFFFC107),
    };

    return Row(
      children: colors.entries.map((entry) {
        final colorName = entry.key;
        final color = entry.value;
        final isSelected = _selectedAccentColor == colorName;
        return GestureDetector(
          onTap: () => _onAccentColorTap(colorName),
          child: Container(
            width: 24.w,
            height: 24.w,
            margin: EdgeInsets.only(right: AppConstants.extraSmallSpacing.w),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.black, width: 2.w)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class UserProfile {
  final String name;
  final String email;

  UserProfile({
    required this.name,
    required this.email,
  });
}
