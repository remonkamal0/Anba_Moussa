import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/downloads_provider.dart';
import '../../providers/audio_provider.dart';
import '../../../domain/entities/track.dart';
import '../../../l10n/app_localizations.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  void _playAll(WidgetRef ref, BuildContext context, List<Track> favorites, {bool shuffle = false}) {
    if (favorites.isEmpty) return;
    
    final tracksToPlay = [...favorites];
    if (shuffle) tracksToPlay.shuffle();
    
    ref.read(audioProvider.notifier).loadPlaylist(tracksToPlay, 0);
    context.push('/player');
  }

  void _onTrackTapped(WidgetRef ref, BuildContext context, List<Track> favorites, int index) {
    final track = favorites[index];
    final audioState = ref.read(audioProvider);
    final isCurrentTrack = audioState.currentTrack?.id == track.id;

    if (isCurrentTrack) {
      ref.read(audioProvider.notifier).togglePlayPause();
    } else {
      ref.read(audioProvider.notifier).loadPlaylist(favorites, index);
      context.push('/player');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final favState = ref.watch(favoritesProvider);
    final favorites = favState.tracks;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.drawerFavorites,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (favorites.isNotEmpty) ...[
              // Action Buttons Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _playAll(ref, context, favorites),
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                        label: Text(
                          AppLocalizations.of(context)!.playAll,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          elevation: 4,
                          shadowColor: cs.primary.withOpacity(0.5),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _playAll(ref, context, favorites, shuffle: true),
                        icon: Icon(Icons.shuffle_rounded, color: cs.primary, size: 20),
                        label: Text(
                          AppLocalizations.of(context)!.shuffle,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary.withOpacity(0.1),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Liked Songs Count
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                child: Text(
                  AppLocalizations.of(context)!.likedTracksCount(favorites.length).toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ],
            
            // List of Favorite Songs
            Expanded(
              child: favState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : favorites.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.noFavoritesYet,
                            style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                          itemCount: favorites.length,
                          separatorBuilder: (context, index) => SizedBox(height: 16.h),
                          itemBuilder: (context, index) {
                            final song = favorites[index];
                            return InkWell(
                              onTap: () => _onTrackTapped(ref, context, favorites, index),
                              child: Row(
                                children: [
                                  // Circular Cover Art
                                  Container(
                                    width: 56.w,
                                    height: 56.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: song.imageUrl != null
                                          ? CachedNetworkImage(
                                              imageUrl: song.imageUrl!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(color: cs.surfaceVariant),
                                              errorWidget: (context, url, error) => const Icon(Icons.music_note),
                                            )
                                          : const Icon(Icons.music_note),
                                    ),
                                  ),
                                  
                                  SizedBox(width: 16.w),
                                  
                                  // Title and Artist
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.getLocalizedTitle(locale),
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            color: cs.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          song.getLocalizedSpeaker(locale) ?? '',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: cs.onSurface.withOpacity(0.5),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Action Icons (Like, Download, Play)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.favorite_rounded,
                                          color: cs.primary,
                                          size: 20.w,
                                        ),
                                        onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(song),
                                      ),
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final downloads = ref.watch(downloadsProvider);
                                          final isDownloaded = downloads.downloadedTracks.any((t) => t.id == song.id);
                                          final progress = downloads.downloadProgress[song.id];

                                          if (progress != null) {
                                            return SizedBox(
                                              width: 20.w,
                                              height: 20.w,
                                              child: CircularProgressIndicator(
                                                value: progress,
                                                strokeWidth: 2,
                                                color: cs.primary,
                                              ),
                                            );
                                          }

                                          return IconButton(
                                            icon: Icon(
                                              isDownloaded ? Icons.download_done_rounded : Icons.download_outlined,
                                              color: isDownloaded ? cs.primary : cs.onSurface.withOpacity(0.3),
                                              size: 22.w,
                                            ),
                                            onPressed: () {
                                              if (isDownloaded) {
                                                ref.read(downloadsProvider.notifier).removeDownload(song.id);
                                              } else {
                                                ref.read(downloadsProvider.notifier).downloadTrack(song);
                                              }
                                            },
                                          );
                                        },
                                      ),
                                      SizedBox(width: 4.w),
                                      Consumer(
                                        builder: (context, ref, _) {
                                          final audioState = ref.watch(audioProvider);
                                          final isCurrentTrack = audioState.currentTrack?.id == song.id;
                                          final isPlaying = audioState.isPlaying && isCurrentTrack;

                                          return GestureDetector(
                                            onTap: () {
                                              if (isCurrentTrack) {
                                                ref.read(audioProvider.notifier).togglePlayPause();
                                              } else {
                                                _onTrackTapped(ref, context, favorites, index);
                                              }
                                            },
                                            child: Icon(
                                              isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_outline_rounded,
                                              color: isPlaying ? cs.primary : cs.onSurface,
                                              size: 26.w,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
