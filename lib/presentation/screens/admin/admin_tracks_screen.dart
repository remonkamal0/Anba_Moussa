import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/di/service_locator.dart';
import '../../providers/admin/admin_track_provider.dart';

final adminTrackProvider = ChangeNotifierProvider<AdminTrackProvider>((ref) {
  return sl.adminTrackProvider..loadTracks();
});

class AdminTracksScreen extends ConsumerWidget {
  const AdminTracksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(adminTrackProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminManageTracks),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/tracks/new'),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text('${l10n.errorOccurred}: ${provider.error}'))
          : ListView.builder(
              itemCount: provider.tracks.length,
              itemBuilder: (context, index) {
                final track = provider.tracks[index];
                return ListTile(
                  leading: track.imageUrl != null
                      ? Image.network(
                          track.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.audiotrack),
                        )
                      : const Icon(Icons.audiotrack, size: 50),
                  title: Text(track.titleAr),
                  subtitle: Text(
                    track.subtitleAr ?? track.speakerAr ?? track.titleEn,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          context.push('/admin/tracks/edit', extra: track);
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
                                  l10n.adminTrack.toLowerCase(),
                                  track.titleAr,
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
                                .read(adminTrackProvider)
                                .deleteTrack(track.id);
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
