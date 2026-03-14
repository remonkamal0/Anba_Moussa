import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/di/service_locator.dart';
import '../../providers/admin/admin_video_album_provider.dart';

final adminVideoAlbumProvider =
    ChangeNotifierProvider<AdminVideoAlbumProvider>((ref) {
  return sl.adminVideoAlbumProvider..loadAlbums();
});

class AdminVideoAlbumsScreen extends ConsumerWidget {
  const AdminVideoAlbumsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(adminVideoAlbumProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminVideoAlbums),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/video-albums/new'),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text('${l10n.errorOccurred}: ${provider.error}'))
          : ListView.builder(
              itemCount: provider.albums.length,
              itemBuilder: (context, index) {
                final album = provider.albums[index];
                return ListTile(
                  leading: album.coverImageUrl != null
                      ? Image.network(
                          album.coverImageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.video_library),
                        )
                      : const Icon(Icons.video_library, size: 50),
                  title: Text(album.titleAr),
                  subtitle: Text(album.titleEn),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          context.push(
                            '/admin/video-albums/edit',
                            extra: album,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.adminConfirmDelete),
                              content: Text(
                                l10n.adminDeleteConfirm(
                                  l10n.adminVideoAlbum.toLowerCase(),
                                  album.titleAr,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(l10n.dialogCancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    l10n.delete,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref
                                .read(adminVideoAlbumProvider)
                                .deleteAlbum(album.id);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
