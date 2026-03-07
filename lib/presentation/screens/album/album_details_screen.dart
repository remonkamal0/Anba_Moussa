import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/track.dart';
import '../../../domain/entities/tag.dart';
import '../../../core/di/service_locator.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import 'package:anba_moussa/core/theme/app_text_styles.dart';
import 'package:anba_moussa/presentation/providers/album_details_provider.dart';
import 'package:anba_moussa/presentation/providers/audio_provider.dart';
import 'package:anba_moussa/presentation/providers/favorites_provider.dart';
import 'package:anba_moussa/presentation/providers/downloads_provider.dart';
import 'package:anba_moussa/presentation/providers/mini_player_provider.dart';

class AlbumDetailsScreen extends ConsumerStatefulWidget {
  final String albumId;
  final String title;
  final String imageUrl;
  final String artist;
  final String year;

  const AlbumDetailsScreen({
    super.key,
    required this.albumId,
    required this.title,
    required this.imageUrl,
    this.artist = '',
    this.year = '',
  });

  @override
  ConsumerState<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends ConsumerState<AlbumDetailsScreen> {
  void _toast(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(12.w),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _onTrackTapped(Track track) {
    final audioState = ref.read(audioProvider);
    final isCurrentTrack = audioState.currentTrack?.id == track.id;

    if (isCurrentTrack) {
      ref.read(audioProvider.notifier).togglePlayPause();
    } else {
      final state = ref.read(albumDetailsProvider(widget.albumId));
      final index = state.allTracks.indexOf(track);
      if (index != -1) {
        ref.read(audioProvider.notifier).loadPlaylist(state.allTracks, index);
      }
      context.pushNamed('player', queryParameters: {'trackId': track.id});
    }
  }

  void _toggleLike(Track track) {
    ref.read(favoritesProvider.notifier).toggleFavorite(track);
    final isCurrentlyLiked = ref.read(favoritesProvider).tracks.any((t) => t.id == track.id);
    // Note: Since toggleFavorite is async, the toast might show old state if checked immediately, 
    // but usually it's fine for simple UI feedback.
    _toast(isCurrentlyLiked ? 'Removed from favorites ❤️‍🩹' : 'Added to favorites ❤️');
  }

  void _toggleDownload(Track track) async {
    final downloads = ref.read(downloadsProvider);
    final isDownloaded = downloads.downloadedTracks.any((t) => t.id == track.id);

    if (isDownloaded) {
      ref.read(downloadsProvider.notifier).removeDownload(track.id);
      _toast('The download was cancelled ⛔');
      return;
    }

    _toast('Loading… ⏳');
    try {
      await ref.read(downloadsProvider.notifier).downloadTrack(track);
      _toast('Downloaded ✅');
    } catch (e) {
      _toast('Error downloading: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(albumDetailsProvider(widget.albumId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'ALBUM DETAILS',
            style: TextStyle(
              fontSize: 12.sp,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: cs.onSurface),
              onPressed: () => context.push('/notifications'),
            ),
          ],
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? Center(child: Text(state.errorMessage!))
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroAlbumHeader(
                          title: widget.title,
                          artist: widget.artist,
                          imageUrl: widget.imageUrl,
                          tracksCount: state.allTracks.length,
                          onPlayTap: () {
                            if (state.allTracks.isNotEmpty) {
                              final firstTrack = state.allTracks.first;
                              final audioState = ref.read(audioProvider);
                              final isCurrentTrack = audioState.currentTrack?.id == firstTrack.id;

                              if (isCurrentTrack) {
                                ref.read(audioProvider.notifier).togglePlayPause();
                              } else {
                                _onTrackTapped(firstTrack);
                              }
                            }
                          },
                        )
                            .animate()
                            .fadeIn(duration: const Duration(milliseconds: 260))
                            .slideY(begin: 0.08, end: 0, duration: const Duration(milliseconds: 260)),

                        SizedBox(height: 26.h),

                        // Tags Filter
                        if (state.tags.isNotEmpty)
                          _TagsFilterRow(
                            tags: state.tags,
                            selectedTagId: state.selectedTagId,
                            onTagSelected: (tagId) => ref
                                .read(albumDetailsProvider(widget.albumId).notifier)
                                .filterByTag(tagId),
                          ),

                        SizedBox(height: 12.h),

                        // Tracks Section Header
                        if (state.filteredTracks.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 18.h, bottom: 12.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Tracks',
                                  style: AppTextStyles.getTitleLarge(context).copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18.sp,
                                  ),
                                ),
                                Text(
                                  '${state.filteredTracks.length} Songs',
                                  style: AppTextStyles.getLabelMedium(context).copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Tracks List
                        ListView.builder(
                          itemCount: state.filteredTracks.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final t = state.filteredTracks[index];
                            final progress = ref.watch(downloadsProvider).downloadProgress[t.id];
                            final audioState = ref.watch(audioProvider);
                            final isCurrentTrack = audioState.currentTrack?.id == t.id;
                            final isPlaying = audioState.isPlaying && isCurrentTrack;
                            final isLiked = ref.watch(favoritesProvider).tracks.any((fav) => fav.id == t.id);
                            final isDownloaded = ref.watch(downloadsProvider).downloadedTracks.any((fav) => fav.id == t.id);

                            return _TrackTile(
                              track: t,
                              index: index + 1,
                              isLiked: isLiked,
                              isDownloaded: isDownloaded,
                              progress: progress,
                              isPlaying: isPlaying,
                              isCurrent: isCurrentTrack,
                              onTap: () => _onTrackTapped(t),
                              onLike: () => _toggleLike(t),
                              onDownload: () => _toggleDownload(t),
                            )
                                .animate()
                                .fadeIn(duration: 220.ms, delay: (index * 50).ms)
                                .slideX(begin: -0.05, end: 0, duration: 220.ms, delay: (index * 50).ms);
                          },
                        ),

                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
      );
  }
}

// ─────────────────────────────────────────────
// Hero Header: Play button + badge تحت الزرار
// ─────────────────────────────────────────────
class _HeroAlbumHeader extends StatelessWidget {
  final String title;
  final String artist;
  final String imageUrl;
  final int tracksCount;
  final VoidCallback onPlayTap;

  const _HeroAlbumHeader({
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.tracksCount,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Big cover
        Container(
          height: 260.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Theme.of(context).colorScheme.surfaceVariant),
              errorWidget: (_, __, ___) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ),

        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.black.withOpacity(0.58),
                  Colors.black.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Text overlay
        Positioned(
          left: 18.w,
          right: 18.w,
          bottom: 20.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 26.sp,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                artist,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
}

// ─────────────────────────────────────────────
// Track Card (بدون تمييز)
// ─────────────────────────────────────────────
class _TrackTile extends StatelessWidget {
  final Track track;
  final int index;
  final bool isLiked;
  final bool isDownloaded;
  final double? progress;
  final bool isPlaying;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onDownload;

  const _TrackTile({
    required this.track,
    required this.index,
    required this.isLiked,
    required this.isDownloaded,
    this.progress,
    this.isPlaying = false,
    this.isCurrent = false,
    required this.onTap,
    required this.onLike,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final orange = cs.primary;
    final locale = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
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
            onTap: onTap,
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
                          image: track.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(track.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: track.imageUrl == null
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
                          style: AppTextStyles.getTitleMedium(context).copyWith(
                            color: isCurrent ? orange : cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          track.getLocalizedSpeaker(locale) ?? 'Unknown Speaker',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.getBodyMedium(context).copyWith(
                            color: isCurrent ? orange.withValues(alpha: 0.7) : cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        if (track.tags.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: track.tags.map((tag) => Container(
                                margin: EdgeInsets.only(right: 6.w),
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(color: orange.withValues(alpha: 0.1)),
                                ),
                                child: Text(
                                  tag.getLocalizedName(locale),
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: orange,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _IconAction(
                        icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isLiked ? orange : cs.onSurface.withValues(alpha: 0.3),
                        onTap: onLike,
                      ),
                      SizedBox(width: 2.w),
                      progress != null
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 2,
                                color: orange,
                              ),
                            )
                          : _IconAction(
                              icon: isDownloaded ? Icons.download_done_rounded : Icons.file_download_outlined,
                              color: isDownloaded ? orange : cs.onSurface.withValues(alpha: 0.3),
                              onTap: onDownload,
                            ),
                      SizedBox(width: 6.w),
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
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: isCurrent ? Colors.white : cs.onSurface.withValues(alpha: 0.4),
                          size: 24.w,
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
  }
}

class _TagsFilterRow extends StatelessWidget {
  final List<Tag> tags;
  final String? selectedTagId;
  final Function(String?) onTagSelected;

  const _TagsFilterRow({
    required this.tags,
    required this.selectedTagId,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 48.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedTagId == null;
            return _TagChip(
              label: 'All',
              isSelected: isSelected,
              onTap: () => onTagSelected(null),
            );
          }

          final tag = tags[index - 1];
          final isSelected = selectedTagId == tag.id;

          return _TagChip(
            label: tag.getLocalizedName(locale),
            isSelected: isSelected,
            onTap: () => onTagSelected(tag.id),
          );
        },
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final orange = cs.primary;

    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? orange : cs.surface,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? orange.withValues(alpha: 0.3)
                    : cs.onSurface.withValues(alpha: 0.05),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Text(
            label,
            style: AppTextStyles.getLabelLarge(context).copyWith(
              color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.9),
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
      ).animate(target: isSelected ? 1 : 0)
       .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 200.ms),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 18.r,
      child: Icon(icon, size: 22.w, color: color),
    );
  }
}
