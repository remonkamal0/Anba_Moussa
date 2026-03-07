import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import '../../providers/audio_provider.dart';
import '../../providers/mini_player_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/downloads_provider.dart';
import '../../../domain/entities/track.dart';
import '../../widgets/common/app_drawer.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String? trackId;
  const PlayerScreen({super.key, this.trackId});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with TickerProviderStateMixin {
  final ZoomDrawerController _drawerController = ZoomDrawerController();
  // Vinyl rotation controller
  late final AnimationController _vinylCtrl;

  // EQ bar controllers (5 bars, staggered durations)
  late final List<AnimationController> _eqCtrls;
  late final List<Animation<double>> _eqAnims;



  bool _isShuffled = false;
  bool _isRepeating = false;
  double _volume = 0.7;
  double _volumeBeforeMute = 0.7;
  bool _isMuted = false;

  final GlobalKey _volumeIconKey = GlobalKey();
  OverlayEntry? _volumeOverlay;

  // Cached notifier references — must be set in initState, NOT accessed in dispose().
  late final MiniPlayerNotifier _miniPlayerNotifier;
  late final AudioNotifier _audioNotifier;

  @override
  void initState() {
    super.initState();

    // Vinyl — one full rotation every 14 seconds (slow & smooth)
    _vinylCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    // 5 EQ bars with different oscillation speeds
    const durations = [380, 520, 290, 450, 340];
    _eqCtrls = List.generate(durations.length, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durations[i]),
      );
    });
    _eqAnims = _eqCtrls
        .map((c) => Tween<double>(begin: 0.15, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();

    // Cache notifiers while ref is valid (cannot use ref in dispose)
    _miniPlayerNotifier = ref.read(miniPlayerProvider.notifier);
    _audioNotifier = ref.read(audioProvider.notifier);

    _initVolume();

    // Listen to playback state to start/stop animations
    ref.listenManual(
      audioProvider.select((s) => s.isPlaying),
      (prev, isPlaying) {
        if (isPlaying) {
          _vinylCtrl.repeat();
          for (final c in _eqCtrls) c.repeat(reverse: true);
        } else {
          _vinylCtrl.stop();
          for (final c in _eqCtrls) c.stop();
        }
      },
      fireImmediately: true,
    );

    // The track is already loaded by the screen that navigated here (e.g. AlbumDetails)
    // We just ensure the mini player is visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _miniPlayerNotifier.show();
    });
  }

  /// Read the current device media volume and listen to hardware buttons
  Future<void> _initVolume() async {
    try {
      FlutterVolumeController.updateShowSystemUI(true);
    } catch (_) {}

    try {
      FlutterVolumeController.addListener((vol) {
        if (mounted) setState(() => _volume = vol);
      })?.onError((_) {});
    } catch (_) {}

    try {
      final vol = await FlutterVolumeController.getVolume();
      if (mounted && vol != null) setState(() => _volume = vol);
    } catch (_) {}
  }

  @override
  void dispose() {
    _hideVolumeOverlay();
    // Cancel volume listener safely — flutter_volume_controller may throw
    // MissingPluginException on some platforms/emulators.
    try {
      FlutterVolumeController.removeListener();
    } catch (_) {}

    _vinylCtrl.dispose();
    for (final c in _eqCtrls) c.dispose();

    // NOTE: We intentionally do NOT dispose _audioNotifier.player here.
    super.dispose();
  }

  void _togglePlay() => _audioNotifier.togglePlayPause();

  void _hideVolumeOverlay() {
    _volumeOverlay?.remove();
    _volumeOverlay = null;
  }

  void _showVolumeOverlay() {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final renderObject = _volumeIconKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;

    final iconBox = renderObject;
    final iconSize = iconBox.size;
    final iconOffset = iconBox.localToGlobal(Offset.zero);
    final screen = MediaQuery.of(context).size;

    const popupWidth = 220.0;
    const popupHeight = 52.0;
    const verticalGap = 10.0;

    final left = (iconOffset.dx + (iconSize.width / 2) - (popupWidth / 2))
        .clamp(12.0, screen.width - popupWidth - 12.0);
    final top = (iconOffset.dy - popupHeight - verticalGap).clamp(12.0, screen.height - popupHeight - 12.0);

    _volumeOverlay = OverlayEntry(
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideVolumeOverlay,
                behavior: HitTestBehavior.translucent,
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: popupWidth,
              height: popupHeight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SliderTheme(
                      data: SliderTheme.of(ctx).copyWith(
                        trackHeight: 4.h,
                        activeTrackColor: cs.primary,
                        inactiveTrackColor: cs.outlineVariant,
                        thumbColor: cs.primary,
                        overlayColor: cs.primary.withOpacity(0.15),
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 7.r,
                        ),
                      ),
                      child: Slider(
                        value: _volume.clamp(0.0, 1.0),
                        min: 0,
                        max: 1,
                        onChanged: (v) {
                          final vv = v.clamp(0.0, 1.0);
                          setState(() {
                            _volume = vv;
                            _isMuted = vv == 0;
                            if (!_isMuted) _volumeBeforeMute = vv;
                          });
                          _audioNotifier.setVolume(vv);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_volumeOverlay!);
  }

  void _onVolumeIconPressed() {
    if (_volumeOverlay == null) {
      _showVolumeOverlay();
      return;
    }
    _toggleMute();
  }

  void _toggleMute() {
    if (_isMuted) {
      final restored = _volumeBeforeMute.clamp(0.0, 1.0);
      setState(() {
        _isMuted = false;
        _volume = restored;
      });
      _audioNotifier.setVolume(restored);
      return;
    }

    final current = _volume.clamp(0.0, 1.0);
    if (current > 0) _volumeBeforeMute = current;
    setState(() {
      _isMuted = true;
      _volume = 0;
    });
    _audioNotifier.setVolume(0);
  }

  void _onSeek(double v) => _audioNotifier.seek(Duration(seconds: v.round()));

  String _fmt(Duration d) {
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final audioState = ref.watch(audioProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final _position = audioState.position;
    final _duration = audioState.duration;
    final _isPlaying = audioState.isPlaying;
    final _isShuffled = audioState.isShuffleModeEnabled;
    final _isRepeating = audioState.loopMode != LoopMode.off;

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final sw = MediaQuery.of(context).size.width;
    final artSize = (sw * 0.60).clamp(160.0, 280.0);

    return ZoomDrawer(
      controller: _drawerController,
      style: DrawerStyle.defaultStyle,
      menuScreen: const AppDrawer(),
      isRtl: isRtl,
      borderRadius: 24,
      showShadow: true,
      angle: isRtl ? 12 : -12,
      drawerShadowsBackgroundColor: Colors.grey[300]!,
      slideWidth: sw * 0.75,
      menuBackgroundColor: cs.surface,
      mainScreen: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            audioState.currentTrack?.getLocalizedTitle(locale) ?? '...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (ctx, box) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // ── Fixed square album art ───────────────────
                      SizedBox(
                        width: artSize,
                        height: artSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26.r),
                          child: audioState.currentTrack?.coverImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: audioState.currentTrack!.coverImageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: cs.surfaceVariant,
                                    child: Center(
                                      child: SizedBox(
                                        width: 22.w,
                                        height: 22.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: cs.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: cs.surfaceVariant,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.music_note,
                                      size: artSize * 0.4,
                                      color: cs.primary,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: cs.surfaceVariant,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.music_note,
                                    size: artSize * 0.4,
                                    color: cs.primary,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // ── Title + artist ───────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            Text(
                              audioState.currentTrack?.getLocalizedTitle(locale) ?? '...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              audioState.currentTrack?.getLocalizedSpeaker(locale) ?? '...',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 5.h),


                      // ── Download + Favourite ─────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (audioState.currentTrack != null)
                            Consumer(
                              builder: (context, ref, child) {
                                final downloads = ref.watch(downloadsProvider);
                                final isDownloaded = downloads.downloadedTracks.any((t) => t.id == audioState.currentTrack!.id);
                                final progress = downloads.downloadProgress[audioState.currentTrack!.id];
                                
                                if (progress != null) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 24.w,
                                        height: 24.w,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 2,
                                          color: cs.primary,
                                        ),
                                      ),
                                      Text(
                                        '${(progress * 100).toInt()}%',
                                        style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  );
                                }
                                
                                return _IBtn(
                                  icon: isDownloaded
                                      ? Icons.download_done_rounded
                                      : Icons.download_rounded,
                                  color: isDownloaded ? cs.primary : Colors.grey[400],
                                  onTap: () {
                                    if (!isDownloaded) {
                                      final mini = audioState.currentTrack!;
                                      // Reconstruct a Track entity for the provider
                                      final t = Track(
                                        id: mini.id,
                                        titleAr: mini.titleAr,
                                        titleEn: mini.titleEn,
                                        speakerAr: mini.speakerAr,
                                        speakerEn: mini.speakerEn,
                                        audioUrl: mini.audioUrl,
                                        imageUrl: mini.coverImageUrl,
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                        isActive: true,
                                        categoryId: '',
                                      );
                                      ref.read(downloadsProvider.notifier).downloadTrack(t);
                                    } else {
                                      ref.read(downloadsProvider.notifier).removeDownload(audioState.currentTrack!.id);
                                    }
                                  },
                                );
                              },
                            ),
                          SizedBox(width: 20.w),
                          if (audioState.currentTrack != null)
                            _IBtn(
                              icon: ref.watch(favoritesProvider).tracks.any((t) => t.id == audioState.currentTrack!.id)
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              onTap: () {
                                final mini = audioState.currentTrack!;
                                final t = Track(
                                  id: mini.id,
                                  titleAr: mini.titleAr,
                                  titleEn: mini.titleEn,
                                  speakerAr: mini.speakerAr,
                                  speakerEn: mini.speakerEn,
                                  audioUrl: mini.audioUrl,
                                  imageUrl: mini.coverImageUrl,
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  isActive: true,
                                  categoryId: '',
                                );
                                ref.read(favoritesProvider.notifier).toggleFavorite(t);
                              },
                            ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // ── Progress slider ──────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 4.h,
                                      activeTrackColor: cs.primary,
                                      inactiveTrackColor: cs.outlineVariant,
                                      thumbColor: cs.primary,
                                      overlayColor:
                                          cs.primary.withOpacity(0.15),
                                      thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 7.r),
                                    ),
                                    child: Slider(
                                      value: _position.inSeconds
                                          .clamp(0, _duration.inSeconds)
                                          .toDouble(),
                                      max: _duration.inSeconds
                                          .toDouble()
                                          .clamp(1, double.infinity),
                                      onChanged: _onSeek,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 6.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_fmt(_position),
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: cs.onSurface.withValues(alpha: 0.6))),
                                  Text(_fmt(_duration),
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: cs.onSurface.withValues(alpha: 0.6))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 14.h),

                      // ── Controls card ────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Container(
                          height: 88.h,
                          decoration: BoxDecoration(
                            color: cs.surfaceVariant,
                            borderRadius: BorderRadius.circular(28.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.07),
                                blurRadius: 30,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                _IBtn(
                                  icon: Icons.shuffle_rounded,
                                  color: _isShuffled
                                      ? cs.primary
                                      : Colors.grey[400]!,
                                  size: 26.sp,
                                  onTap: () => _audioNotifier.toggleShuffle(),
                                ),
                                _IBtn(
                                  icon: Icons.skip_previous_rounded,
                                  color: cs.onSurface,
                                  size: 34.sp,
                                  onTap: () => _audioNotifier.skipBackward(),
                                ),
                                // Play/Pause
                                Container(
                                  width: 62.w,
                                  height: 62.w,
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: cs.primary.withOpacity(0.35),
                                        blurRadius: 22,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed: _togglePlay,
                                    icon: Icon(
                                      _isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 32.sp,
                                    ),
                                  ),
                                ),
                                _IBtn(
                                  icon: Icons.skip_next_rounded,
                                  color: cs.onSurface,
                                  size: 34.sp,
                                  onTap: () => _audioNotifier.skipForward(),
                                ),
                                _IBtn(
                                  icon: Icons.repeat_rounded,
                                  color: _isRepeating
                                      ? cs.primary
                                      : Colors.grey[400]!,
                                  size: 26.sp,
                                  onTap: () => _audioNotifier.toggleRepeat(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // ── Volume slider ────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.volume_down_rounded,
                              color: cs.onSurface.withValues(alpha: 0.4),
                              size: 20.sp,
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4.h,
                                  activeTrackColor: cs.primary,
                                  inactiveTrackColor: cs.outlineVariant,
                                  thumbColor: cs.primary,
                                  overlayColor: cs.primary.withOpacity(0.15),
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 7.r,
                                  ),
                                ),
                                child: Slider(
                                  value: _volume.clamp(0.0, 1.0),
                                  min: 0,
                                  max: 1,
                                  onChanged: (v) {
                                    final vv = v.clamp(0.0, 1.0);
                                    setState(() {
                                      _volume = vv;
                                      _isMuted = vv == 0;
                                      if (!_isMuted) _volumeBeforeMute = vv;
                                    });
                                    _audioNotifier.setVolume(vv);
                                  },
                                ),
                              ),
                            ),
                            Icon(
                              Icons.volume_up_rounded,
                              color: cs.onSurface.withValues(alpha: 0.4),
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                      // space so controls don't hide behind MiniPlayer
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Horizontal Equalizer Bars ────────────────────────────────────────────────

class _EqualizerBars extends StatelessWidget {
  final List<Animation<double>> eqAnims;
  final bool isPlaying;

  const _EqualizerBars({required this.eqAnims, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(eqAnims.length, (i) {
          return AnimatedBuilder(
            animation: eqAnims[i],
            builder: (_, __) {
              final h = (32 * eqAnims[i].value).clamp(4.0, 32.0);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 5,
                  height: h,
                  decoration: BoxDecoration(
                    color: cs.primary
                        .withOpacity(0.6 + 0.4 * eqAnims[i].value),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ─── Icon button helper ────────────────────────────────────────────────────────

class _IBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double size;

  const _IBtn({
    required this.icon,
    required this.onTap,
    this.color,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: color ?? cs.primary,
        size: size,
      ),
    );
  }
}

