import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/di/service_locator.dart';
import '../../providers/admin/admin_video_provider.dart';
import 'admin_video_albums_screen.dart'; // To get albums

final adminVideoProvider =
    ChangeNotifierProvider<AdminVideoProvider>((ref) {
  return sl.adminVideoProvider;
});

class AdminVideosScreen extends ConsumerStatefulWidget {
  const AdminVideosScreen({super.key});

  @override
  ConsumerState<AdminVideosScreen> createState() => _AdminVideosScreenState();
}

class _AdminVideosScreenState extends ConsumerState<AdminVideosScreen> {
  String? _selectedAlbumId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminVideoAlbumProvider); // load albums
    });
  }

  @override
  Widget build(BuildContext context) {
    final albumProvider = ref.watch(adminVideoAlbumProvider);
    final videoProvider = ref.watch(adminVideoProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminVideos),
        actions: [
          if (_selectedAlbumId != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  context.push('/admin/videos/new?albumId=$_selectedAlbumId'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedAlbumId,
              decoration: InputDecoration(
                labelText: l10n.adminSelectVideoAlbum,
                border: const OutlineInputBorder(),
              ),
              items: albumProvider.albums
                  .map(
                    (a) =>
                        DropdownMenuItem(value: a.id, child: Text(a.titleAr)),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedAlbumId = v);
                if (v != null) {
                  ref.read(adminVideoProvider).loadVideos(v);
                }
              },
            ),
          ),
          Expanded(
            child: _selectedAlbumId == null
                ? Center(
                    child: Text(
                      l10n.adminSelectToView(l10n.adminVideo.toLowerCase()),
                    ),
                  )
                : videoProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : videoProvider.error != null
                ? Center(
                    child: Text(
                      '${l10n.errorOccurred}: ${videoProvider.error}',
                    ),
                  )
                : ListView.builder(
                    itemCount: videoProvider.videos.length,
                    itemBuilder: (context, index) {
                      final video = videoProvider.videos[index];
                      return ListTile(
                        leading: video.thumbnailUrl != null
                            ? Image.network(
                                video.thumbnailUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.video_file),
                              )
                            : const Icon(Icons.video_file, size: 50),
                        title: Text(video.titleAr),
                        subtitle: Text(video.subtitleAr ?? video.titleEn),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                context.push(
                                  '/admin/videos/edit',
                                  extra: {
                                    'video': video,
                                    'albumId': _selectedAlbumId,
                                  },
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
                                        l10n.adminVideo.toLowerCase(),
                                        video.titleAr,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(l10n.dialogCancel),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          l10n.delete,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await ref
                                      .read(adminVideoProvider)
                                      .deleteVideo(video.id);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
