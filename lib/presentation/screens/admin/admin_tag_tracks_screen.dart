import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/tag.dart';
import '../../../../domain/entities/track.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/admin/admin_track_provider.dart';
import '../../providers/admin/admin_tag_provider.dart';
import 'admin_tracks_screen.dart'; // Contains adminTrackProvider
import 'admin_tags_screen.dart'; // Contains adminTagProvider

class AdminTagTracksScreen extends ConsumerStatefulWidget {
  final Tag tag;

  const AdminTagTracksScreen({super.key, required this.tag});

  @override
  ConsumerState<AdminTagTracksScreen> createState() =>
      _AdminTagTracksScreenState();
}

class _AdminTagTracksScreenState extends ConsumerState<AdminTagTracksScreen> {
  final Set<String> _selectedTrackIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Always load all tracks to ensure data is fresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trackProvider = ref.read(adminTrackProvider);
      trackProvider.loadTracks().then((_) {
        if (mounted) {
          _populateSelectedTracks(ref.read(adminTrackProvider).tracks);
        }
      });
    });
  }

  void _populateSelectedTracks(List<Track> tracks) {
    setState(() {
      for (final track in tracks) {
        if (track.tags.any((t) => t.id == widget.tag.id)) {
          _selectedTrackIds.add(track.id);
        }
      }
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final tagProvider = ref.read(adminTagProvider);

    final success = await tagProvider.setTagTracks(
      widget.tag.id,
      _selectedTrackIds.toList(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.adminLinkTracksSuccess)));
      // Reload tracks so the UI reflects the new tags correctly across the app
      ref.read(adminTrackProvider).loadTracks();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trackProvider = ref.watch(adminTrackProvider);
    final tagProvider = ref.watch(adminTagProvider);

    final filteredTracks = trackProvider.tracks.where((track) {
      final query = _searchQuery.toLowerCase();
      final titleAr = track.titleAr.toLowerCase();
      final titleEn = track.titleEn.toLowerCase();
      return titleAr.contains(query) || titleEn.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.adminLinkTracks}: ${widget.tag.getLocalizedName(l10n.localeName)}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: tagProvider.isLoading ? null : _save,
          ),
        ],
      ),
      body: trackProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: l10n.adminSearchTracks,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTracks.length,
                    itemBuilder: (context, index) {
                      final track = filteredTracks[index];
                      final isSelected = _selectedTrackIds.contains(track.id);

                      return CheckboxListTile(
                        title: Text(track.getLocalizedTitle(l10n.localeName)),
                        subtitle:
                            track.getLocalizedSpeaker(l10n.localeName) != null
                            ? Text(track.getLocalizedSpeaker(l10n.localeName)!)
                            : null,
                        value: isSelected,
                        secondary: track.imageUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(track.imageUrl!),
                              )
                            : const CircleAvatar(child: Icon(Icons.music_note)),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedTrackIds.add(track.id);
                            } else {
                              _selectedTrackIds.remove(track.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                if (tagProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
}
