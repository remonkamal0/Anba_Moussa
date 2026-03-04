import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/audio_provider.dart';
import '../../providers/mini_player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(miniPlayerProvider);
    final track = state.track;
    final locale = Localizations.localeOf(context).languageCode;

    if (!state.isVisible || track == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: GestureDetector(
        onTap: () => context.push(AppConstants.playerRoute),
        child: Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E2632)
                : const Color(0xFF1B2340),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Album thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: track.coverImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: track.coverImageUrl,
                        width: 40.w,
                        height: 40.w,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => _placeholder(),
                      )
                    : _placeholder(),
              ),

              SizedBox(width: 12.w),

              // Title & artist
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.getLocalizedTitle(locale),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      track.getLocalizedSpeaker(locale),
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Previous, Play/Pause, Next controls forced to LTR
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Previous
                    _ControlBtn(
                      icon: Icons.skip_previous_rounded,
                      onTap: () => ref.read(audioProvider.notifier).skipBackward(),
                    ),
                    // Play / Pause — wired to audio provider
                    GestureDetector(
                      onTap: () =>
                          ref.read(audioProvider.notifier).togglePlayPause(),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          state.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20.w,
                        ),
                      ),
                    ),
                    // Next
                    _ControlBtn(
                      icon: Icons.skip_next_rounded,
                      onTap: () => ref.read(audioProvider.notifier).skipForward(),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 6.w),

              // ✕ Dismiss button
              GestureDetector(
                onTap: () =>
                    ref.read(audioProvider.notifier).stop(),
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 18.w,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 40.w,
        height: 40.w,
        color: Colors.white12,
        child: const Icon(Icons.music_note, color: Colors.white54),
      );
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ControlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 28.w),
      ),
    );
  }
}
