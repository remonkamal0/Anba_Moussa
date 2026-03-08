import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/downloads_provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/mini_player_provider.dart';
import '../../../domain/entities/track.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/common/mini_player.dart';
import '../../widgets/common/confirm_dialog.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final downloads = ref.watch(downloadsProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.drawerDownloads,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          if (downloads.downloadedTracks.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirm = await showConfirmDialog(
                  context,
                  title: AppLocalizations.of(context)!.deleteAllDownloadsTitle,
                  content: AppLocalizations.of(context)!.deleteAllDownloadsContent,
                  cancelText: AppLocalizations.of(context)!.dialogCancel,
                  confirmText: AppLocalizations.of(context)!.deleteAll,
                );

                if (confirm == true) {
                  for (final t in downloads.downloadedTracks) {
                    ref.read(downloadsProvider.notifier).removeDownload(t.id);
                  }
                }
              },
              child: Text(
                AppLocalizations.of(context)!.deleteAll,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: downloads.downloadedTracks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_for_offline_outlined, size: 64.sp, color: cs.onSurface.withValues(alpha: 0.2)),
                        SizedBox(height: 16.h),
                        Text(
                          AppLocalizations.of(context)!.noDownloadsYet,
                          style: TextStyle(fontSize: 16.sp, color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Storage Info Container
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.offlineTracks,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      color: cs.onSurface.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '${downloads.downloadedTracks.length}',
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w900,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        AppLocalizations.of(context)!.tracksCount,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.normal,
                                          color: cs.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              // Download Icon
                              Icon(Icons.download_done_rounded, color: cs.primary, size: 32.sp),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      // List of downloaded songs
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
                          itemCount: downloads.downloadedTracks.length,
                          separatorBuilder: (context, index) => SizedBox(height: 24.h),
                          itemBuilder: (context, index) {
                            final track = downloads.downloadedTracks[index];
                            return Row(
                              children: [
                                // Square Cover Art with drop shadow
                                Container(
                                  width: 65.w,
                                  height: 65.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: cs.primary.withValues(alpha: 0.2),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14.r),
                                    child: CachedNetworkImage(
                                      imageUrl: track.imageUrl ?? '',
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(color: cs.surfaceVariant),
                                      errorWidget: (_, __, ___) => Container(color: cs.surfaceVariant, child: const Icon(Icons.music_note)),
                                    ),
                                  ),
                                ),
                                
                                SizedBox(width: 16.w),
                                
                                // Title, Artist, Size
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        track.getLocalizedTitle(locale),
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: cs.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        track.getLocalizedSpeaker(locale) ?? AppLocalizations.of(context)!.unknownSpeaker,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: cs.onSurface.withValues(alpha: 0.5),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: cs.primary, size: 14.w),
                                          SizedBox(width: 4.w),
                                            Text(
                                              AppLocalizations.of(context)!.offline,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                color: cs.primary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Play Button
                                Consumer(
                                  builder: (context, ref, _) {
                                    final audioState = ref.watch(audioProvider);
                                    final isCurrentTrack = audioState.currentTrack?.id == track.id;
                                    final isPlaying = audioState.isPlaying && isCurrentTrack;

                                    return InkWell(
                                      onTap: () {
                                        if (isCurrentTrack) {
                                          ref.read(audioProvider.notifier).togglePlayPause();
                                        } else {
                                          ref.read(audioProvider.notifier).loadPlaylist(downloads.downloadedTracks, index);
                                        }
                                      },
                                      child: Container(
                                        width: 44.w,
                                        height: 44.w,
                                        decoration: BoxDecoration(
                                          color: cs.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: cs.primary.withValues(alpha: 0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 28.w,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                
                                SizedBox(width: 16.w),
                                
                                // Delete Icon
                                InkWell(
                                  onTap: () async {
                                    final confirm = await showConfirmDialog(
                                      context,
                                      title: AppLocalizations.of(context)!.deleteDownloadTitle,
                                      content: AppLocalizations.of(context)!.deleteDownloadContent,
                                      cancelText: AppLocalizations.of(context)!.dialogCancel,
                                      confirmText: AppLocalizations.of(context)!.delete,
                                    );

                                    if (confirm == true) {
                                      ref.read(downloadsProvider.notifier).removeDownload(track.id);
                                    }
                                  },
                                  child: Icon(Icons.delete_outline_rounded, color: cs.onSurface.withValues(alpha: 0.3), size: 28.w),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          // Mini Player
          Positioned(
            left: 0,
            right: 0,
            bottom: 16.h,
            child: const MiniPlayer(),
          ),
        ],
      ),
    );
  }
}
