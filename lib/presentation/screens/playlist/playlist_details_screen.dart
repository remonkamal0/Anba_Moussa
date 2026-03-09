import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/playlists_provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/downloads_provider.dart';
import 'create_playlist_screen.dart';

class PlaylistDetailsScreen extends ConsumerStatefulWidget {
  final String playlistId;
  const PlaylistDetailsScreen({super.key, required this.playlistId});

  @override
  ConsumerState<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends ConsumerState<PlaylistDetailsScreen> {

  void _openEdit(PlaylistModel playlist) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => CreatePlaylistScreen(
          existingPlaylist: playlist,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    
    // Watch the specific playlist details from the list
    final playlistState = ref.watch(playlistsProvider);
    final playlist = playlistState.playlists
        .where((p) => p.id == widget.playlistId)
        .firstOrNull;

    // Watch the tracks for this playlist
    final tracksAsync = ref.watch(playlistTracksProvider(widget.playlistId));
    
    // Watch current audio state to show "playing" indicator
    final audioState = ref.watch(audioProvider);

    if (playlist == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          playlist.getLocalizedTitle(locale).toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
            letterSpacing: 2,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: cs.onSurface, size: 22.sp),
            onPressed: () => _openEdit(playlist),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Hero Cover (Screenshot Style) ────────────────────────────────
            Container(
              margin: EdgeInsets.only(top: 24.h),
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [cs.primary.withValues(alpha: 0.9), cs.primary.withValues(alpha: 0.6)],
                ),
                borderRadius: BorderRadius.circular(32.r),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  )
                ]
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(playlistIcon(playlist.iconName), color: Colors.white, size: 80.sp),
                    SizedBox(height: 16.h),
                    Text(
                      playlist.getLocalizedTitle(locale).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 12.h),
                      height: 2.h,
                      width: 40.w,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 32.h),

            // ── Title & Meta ────────────────────────────────────────────────
            Text(
              playlist.getLocalizedTitle(locale),
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              '${playlist.ownerType == 'official' ? AppLocalizations.of(context)!.playlistCreatedByOfficial : AppLocalizations.of(context)!.playlistCreatedByMe} ${AppLocalizations.of(context)!.playlistTracksCount(playlist.trackCount)}',
              style: TextStyle(
                fontSize: 13.sp,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),

            SizedBox(height: 24.h),

            // ── Action Buttons ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        tracksAsync.whenData((tracks) {
                          if (tracks.isNotEmpty) {
                            final entityTracks = tracks.map((t) => t.toEntity()).toList();
                            ref.read(audioProvider.notifier).loadPlaylist(entityTracks, 0);
                          }
                        });
                      },
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      label: Text(AppLocalizations.of(context)!.playlistPlay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        tracksAsync.whenData((tracks) {
                          if (tracks.isNotEmpty) {
                            final entityTracks = tracks.map((t) => t.toEntity()).toList();
                            final shuffled = List.of(entityTracks)..shuffle();
                            ref.read(audioProvider.notifier).loadPlaylist(shuffled, 0);
                          }
                        });
                      },
                      icon: Icon(Icons.shuffle_rounded, color: cs.onSurface, size: 20.sp),
                      label: Text(AppLocalizations.of(context)!.playlistShuffle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cs.onSurface)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.onSurface,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: cs.onSurface.withValues(alpha: 0.1), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ── Track List ──────────────────────────────────────────────────
            tracksAsync.when(
              data: (tracks) => ListView.builder(
                padding: EdgeInsets.only(bottom: 40.h),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: tracks.length,
                itemBuilder: (ctx, i) {
                  final track = tracks[i];
                  final isPlaying = audioState.currentTrack?.id == track.id;
                  final isLiked = ref.watch(favoritesProvider.notifier).isFavorite(track.id);
                  final isDownloaded = ref.watch(downloadsProvider.notifier).isDownloaded(track.id);

                  final entityTracks = tracks.map((t) => t.toEntity()).toList();
                  final orange = cs.primary;
                  final isCurrent = isPlaying;
                  final progress = ref.watch(downloadsProvider).downloadProgress[track.id];

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent ? orange.withValues(alpha: 0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: isCurrent ? [
                          BoxShadow(
                            color: orange.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ] : null,
                        border: isCurrent 
                          ? Border.all(color: orange.withValues(alpha: 0.15), width: 1.5)
                          : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(24.r),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24.r),
                          onTap: () {
                             if (isCurrent) {
                               ref.read(audioProvider.notifier).togglePlayPause();
                             } else {
                               ref.read(audioProvider.notifier).loadPlaylist(entityTracks, i);
                             }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                            child: Row(
                              children: [
                                // Thumbnail with Visualizer
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 54.w,
                                      height: 54.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16.r),
                                        color: cs.surfaceVariant,
                                        image: track.coverImageUrl != null
                                            ? DecorationImage(
                                                image: CachedNetworkImageProvider(track.coverImageUrl!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: track.coverImageUrl == null
                                          ? Icon(Icons.music_note, color: orange, size: 24.w)
                                          : null,
                                    ),
                                    if (isPlaying)
                                      Container(
                                        width: 54.w,
                                        height: 54.w,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(16.r),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.bar_chart_rounded,
                                            color: Colors.white,
                                            size: 28.w,
                                          ).animate(onPlay: (controller) => controller.repeat())
                                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 600.ms, curve: Curves.easeInOut)
                                            .then()
                                            .scale(begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.easeInOut),
                                        ),
                                      ),
                                  ],
                                ),
                                
                                SizedBox(width: 14.w),

                                // Title & Artist
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        track.getLocalizedTitle(locale),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: isCurrent ? orange : cs.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        track.getLocalizedSpeaker(locale) ?? AppLocalizations.of(context)!.unknownSpeaker,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isCurrent ? orange.withValues(alpha: 0.7) : cs.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Actions
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(track.toEntity()),
                                      child: Icon(
                                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        color: isLiked ? orange : cs.onSurface.withValues(alpha: 0.3),
                                        size: 20.w,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    progress != null
                                        ? SizedBox(
                                            width: 18.w,
                                            height: 18.w,
                                            child: CircularProgressIndicator(
                                              value: progress,
                                              strokeWidth: 2,
                                              color: orange,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              if (!isDownloaded) {
                                                ref.read(downloadsProvider.notifier).downloadTrack(track.toEntity());
                                              }
                                            },
                                            child: Icon(
                                              isDownloaded ? Icons.download_done_rounded : Icons.file_download_outlined,
                                              color: isDownloaded ? orange : cs.onSurface.withValues(alpha: 0.3),
                                              size: 20.w,
                                            ),
                                          ),
                                    SizedBox(width: 6.w),
                                    GestureDetector(
                                      onTap: () {
                                         ref.read(playlistsProvider.notifier).removeTrack(playlist.id, track.id);
                                         ref.invalidate(playlistTracksProvider(widget.playlistId));
                                      },
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red.withValues(alpha: 0.6),
                                        size: 20.w,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: isCurrent ? orange : cs.surfaceVariant,
                                        borderRadius: BorderRadius.circular(12.r),
                                        boxShadow: isCurrent
                                            ? [
                                                BoxShadow(
                                                  color: orange.withOpacity(0.35),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Icon(
                                        (audioState.isPlaying && isCurrent) ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                        color: isCurrent ? Colors.white : cs.onSurface.withValues(alpha: 0.4),
                                        size: 20.w,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              )),
              error: (err, stack) => Center(child: Text(AppLocalizations.of(context)!.playlistErrorLoadingTracks)),
            ),
          ],
        ),
      ),
    );
  }
}