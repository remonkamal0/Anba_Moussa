import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminDashboardTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAdminThemeCard(
            context,
            icon: Icons.album,
            title: l10n.adminManageCategories,
            onTap: () => context.push('/admin/categories'),
          ),
          const SizedBox(height: 16),
          _buildAdminThemeCard(
            context,
            icon: Icons.audiotrack,
            title: l10n.adminManageTracks,
            onTap: () => context.push('/admin/tracks'),
          ),
          const SizedBox(height: 16),
          _buildAdminThemeCard(
            context,
            icon: Icons.label,
            title: l10n.adminManageTags,
            onTap: () => context.push('/admin/tags'),
          ),
          const SizedBox(height: 16),
          _buildAdminThemeCard(
            context,
            icon: Icons.photo_album,
            title: l10n.adminPhotoAlbums,
            onTap: () => context.push('/admin/photo-albums'),
          ),
          const SizedBox(height: 16),
          _buildAdminThemeCard(
            context,
            icon: Icons.photo,
            title: l10n.adminPhotos,
            onTap: () => context.push('/admin/photos'),
          ),
          const SizedBox(height: 16),
          _buildAdminThemeCard(
            context,
            icon: Icons.video_library,
            title: l10n.adminVideoAlbums,
            onTap: () => context.push('/admin/video-albums'),
          ),
          const SizedBox(height: 16),
          _buildAdminThemeCard(
            context,
            icon: Icons.video_file,
            title: l10n.adminVideos,
            onTap: () => context.push('/admin/videos'),
          ),
          const SizedBox(height: 16),
          _buildAdminThemeCard(
            context,
            icon: Icons.notifications,
            title: l10n.adminSendNotification,
            onTap: () => context.push('/admin/send-notification'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminThemeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
