import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/di/service_locator.dart';
import '../../providers/admin/admin_photo_provider.dart';
import 'admin_photo_albums_screen.dart'; // To get albums

final adminPhotoProvider =
    ChangeNotifierProvider<AdminPhotoProvider>((ref) {
  return sl.adminPhotoProvider;
});

class AdminPhotosScreen extends ConsumerStatefulWidget {
  const AdminPhotosScreen({super.key});

  @override
  ConsumerState<AdminPhotosScreen> createState() => _AdminPhotosScreenState();
}

class _AdminPhotosScreenState extends ConsumerState<AdminPhotosScreen> {
  String? _selectedAlbumId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPhotoAlbumProvider); // load albums
    });
  }

  @override
  Widget build(BuildContext context) {
    final albumProvider = ref.watch(adminPhotoAlbumProvider);
    final photoProvider = ref.watch(adminPhotoProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminPhotos),
        actions: [
          if (_selectedAlbumId != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  context.push('/admin/photos/new?albumId=$_selectedAlbumId'),
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
                labelText: l10n.adminSelectAlbum,
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
                  ref.read(adminPhotoProvider).loadPhotos(v);
                }
              },
            ),
          ),
          Expanded(
            child: _selectedAlbumId == null
                ? Center(
                    child: Text(
                      l10n.adminSelectToView(l10n.adminPhoto.toLowerCase()),
                    ),
                  )
                : photoProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : photoProvider.error != null
                ? Center(
                    child: Text(
                      '${l10n.errorOccurred}: ${photoProvider.error}',
                    ),
                  )
                : ListView.builder(
                    itemCount: photoProvider.photos.length,
                    itemBuilder: (context, index) {
                      final photo = photoProvider.photos[index];
                      return ListTile(
                        leading: Image.network(
                          photo.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image),
                        ),
                        title: Text(photo.titleAr ?? 'No Title'),
                        subtitle: Text(photo.captionAr ?? photo.titleEn ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                context.push(
                                  '/admin/photos/edit',
                                  extra: {
                                    'photo': photo,
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
                                        l10n.adminPhoto.toLowerCase(),
                                        photo.titleAr ?? '',
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
                                      .read(adminPhotoProvider)
                                      .deletePhoto(photo.id);
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
