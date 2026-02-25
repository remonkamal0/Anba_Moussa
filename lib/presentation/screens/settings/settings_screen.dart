import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoPlayEnabled = true;
  bool _downloadOverWifi = true;
  bool _highQualityAudio = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';
  String _selectedAudioQuality = 'Normal';

  List<SettingsSection> get _sections => [
    SettingsSection(
      title: 'Account',
      items: [
        SettingsItem(
          icon: Icons.person,
          title: 'Profile',
          subtitle: 'Manage your profile information',
          onTap: 'profile',
        ),
        SettingsItem(
          icon: Icons.security,
          title: 'Privacy & Security',
          subtitle: 'Control your privacy settings',
          onTap: 'privacy',
        ),
        SettingsItem(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Manage notification preferences',
          onTap: 'notifications',
        ),
      ],
    ),
    SettingsSection(
      title: 'Playback',
      items: [
        SettingsItem(
          icon: Icons.play_arrow,
          title: 'Audio Quality',
          subtitle: '$_selectedAudioQuality quality',
          onTap: 'audio-quality',
        ),
        SettingsItem(
          icon: Icons.download,
          title: 'Downloads',
          subtitle: 'Download settings',
          onTap: 'downloads',
        ),
        SettingsItem(
          icon: Icons.autorenew,
          title: 'Auto-play',
          subtitle: 'Automatically play similar songs',
          onTap: 'autoplay',
        ),
      ],
    ),
    SettingsSection(
      title: 'Display',
      items: [
        SettingsItem(
          icon: Icons.palette,
          title: 'Theme',
          subtitle: '$_selectedTheme theme',
          onTap: 'theme',
        ),
        SettingsItem(
          icon: Icons.language,
          title: 'Language',
          subtitle: '$_selectedLanguage',
          onTap: 'language',
        ),
        SettingsItem(
          icon: Icons.font_download,
          title: 'Font Size',
          subtitle: 'Medium',
          onTap: 'font-size',
        ),
      ],
    ),
    SettingsSection(
      title: 'Storage',
      items: [
        SettingsItem(
          icon: Icons.storage,
          title: 'Storage Usage',
          subtitle: '2.3 GB used',
          onTap: 'storage',
        ),
        SettingsItem(
          icon: Icons.clear_all,
          title: 'Clear Cache',
          subtitle: 'Free up storage space',
          onTap: 'clear-cache',
        ),
      ],
    ),
    SettingsSection(
      title: 'About',
      items: [
        SettingsItem(
          icon: Icons.info,
          title: 'About Melodix',
          subtitle: 'Version 1.0.0',
          onTap: 'about',
        ),
        SettingsItem(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: 'help',
        ),
        SettingsItem(
          icon: Icons.description,
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          onTap: 'terms',
        ),
        SettingsItem(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: 'privacy-policy',
        ),
      ],
    ),
  ];

  void _onItemTapped(String route) {
    switch (route) {
      case 'profile':
        context.go('/profile/edit');
        break;
      case 'privacy':
        // TODO: Navigate to privacy settings
        print('Privacy settings');
        break;
      case 'notifications':
        // TODO: Navigate to notification settings
        print('Notification settings');
        break;
      case 'audio-quality':
        _showAudioQualityDialog();
        break;
      case 'downloads':
        _showDownloadsDialog();
        break;
      case 'autoplay':
        setState(() {
          _autoPlayEnabled = !_autoPlayEnabled;
        });
        break;
      case 'theme':
        _showThemeDialog();
        break;
      case 'language':
        _showLanguageDialog();
        break;
      case 'font-size':
        _showFontSizeDialog();
        break;
      case 'storage':
        // TODO: Navigate to storage settings
        print('Storage settings');
        break;
      case 'clear-cache':
        _showClearCacheDialog();
        break;
      case 'about':
        _showAboutDialog();
        break;
      case 'help':
        // TODO: Navigate to help screen
        print('Help & support');
        break;
      case 'terms':
        // TODO: Navigate to terms screen
        print('Terms of service');
        break;
      case 'privacy-policy':
        // TODO: Navigate to privacy policy screen
        print('Privacy policy');
        break;
    }
  }

  void _showAudioQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Low', 'Normal', 'High', 'Very High'].map((quality) {
            return RadioListTile<String>(
              title: Text(quality),
              value: quality,
              groupValue: _selectedAudioQuality,
              onChanged: (value) {
                setState(() {
                  _selectedAudioQuality = value!;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDownloadsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Download over Wi-Fi only'),
              value: _downloadOverWifi,
              onChanged: (value) {
                setState(() {
                  _downloadOverWifi = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('High quality audio'),
              value: _highQualityAudio,
              onChanged: (value) {
                setState(() {
                  _highQualityAudio = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Light', 'Dark', 'System'].map((theme) {
            return RadioListTile<String>(
              title: Text(theme),
              value: theme,
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Arabic', 'Spanish', 'French'].map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Small', 'Medium', 'Large'].map((size) {
            return RadioListTile<String>(
              title: Text(size),
              value: size,
              groupValue: 'Medium',
              onChanged: (value) {
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will remove all cached data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Melodix'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Melodix v1.0.0'),
            SizedBox(height: 8),
            Text('Your Religious Music Experience'),
            SizedBox(height: 8),
            Text('© 2024 Melodix Inc.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
          itemCount: _sections.length,
          itemBuilder: (context, sectionIndex) {
            final section = _sections[sectionIndex];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppConstants.mediumSpacing.h,
                  ),
                  child: Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: Duration(milliseconds: sectionIndex * 200),
                  ),
                ),

                // Section items
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: section.items.asMap().entries.map((entry) {
                      final itemIndex = entry.key;
                      final item = entry.value;
                      final isLast = itemIndex == section.items.length - 1;

                      return SettingsItemTile(
                        item: item,
                        onTap: () => _onItemTapped(item.onTap),
                        showDivider: !isLast,
                      ).animate().slideX(
                        duration: AppConstants.defaultAnimationDuration,
                        delay: Duration(milliseconds: (sectionIndex * 200) + (itemIndex * 100)),
                        begin: -0.2,
                        curve: Curves.easeOut,
                      );
                    }).toList(),
                  ),
                ),

                if (sectionIndex < _sections.length - 1)
                  SizedBox(height: AppConstants.largeSpacing.h),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SettingsSection {
  final String title;
  final List<SettingsItem> items;

  SettingsSection({
    required this.title,
    required this.items,
  });
}

class SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String onTap;

  SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class SettingsItemTile extends StatelessWidget {
  final SettingsItem item;
  final VoidCallback onTap;
  final bool showDivider;

  const SettingsItemTile({
    super.key,
    required this.item,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius.r),
            ),
            child: Icon(
              item.icon,
              color: const Color(0xFFFF6B35),
              size: 20.w,
            ),
          ),
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            item.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 16,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.grey[200],
            indent: 72.w,
          ),
      ],
    );
  }
}
