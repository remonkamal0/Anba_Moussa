import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import '../../providers/audio_provider.dart';
import '../../providers/mini_player_provider.dart';
import '../../widgets/common/app_drawer.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String? trackId;
  const PlayerScreen({super.key, this.trackId});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with TickerProviderStateMixin {
  // No longer using static const cs.primary, using Theme.of(context).colorScheme.primary instead.
  static const _demoUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  final ZoomDrawerController _drawerController = ZoomDrawerController();
  // Vinyl rotation controller
  late final AnimationController _vinylCtrl;

  // EQ bar controllers (5 bars, staggered durations)
  late final List<AnimationController> _eqCtrls;
  late final List<Animation<double>> _eqAnims;

  bool _isFavorite = false;
  bool _isDownloaded = false;
  bool _isShuffled = false;
  bool _isRepeating = false;
  double _volume = 0.7;

  // Cached notifier references — must be set in initState, NOT accessed in dispose().
  late final MiniPlayerNotifier _miniPlayerNotifier;
  late final AudioNotifier _audioNotifier;

  final Track _track = const Track(
    id: '1',
    titleAr: 'Have you',
    titleEn: 'Have you',
    speakerAr: 'Madihu, Low G',
    speakerEn: 'Madihu, Low G',
    album: "Madihu's best songs",
    coverImageUrl: 'https://picsum.photos/seed/cityscape/800/800',
  );

  @override
  void initState() {
    super.initState();

    // Vinyl — one full rotation every 14 seconds (slow & smooth)
    _vinylCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    // 5 EQ bars with different oscillation speeds
    const durations = [380, 520, 290, 450, 340];
    _eqCtrls = List.generate(durations.length, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durations[i]),
      )..repeat(reverse: true);
    });
    _eqAnims = _eqCtrls
        .map((c) => Tween<double>(begin: 0.15, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();

    // Cache notifiers while ref is valid (cannot use ref in dispose)
    _miniPlayerNotifier = ref.read(miniPlayerProvider.notifier);
    _audioNotifier = ref.read(audioProvider.notifier);

    _initVolume();

    // Load audio only if not already playing this track
    final currentUrl = ref.read(audioProvider).currentUrl;
    if (currentUrl != _demoUrl) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _audioNotifier.loadAndPlay(
          _demoUrl,
          MiniPlayerTrack(
            id: _track.id,
            titleAr: _track.titleAr,
            titleEn: _track.titleEn,
            speakerAr: _track.speakerAr,
            speakerEn: _track.speakerEn,
            coverImageUrl: _track.coverImageUrl,
          ),
        );
      });
    }

    // Hide MiniPlayer while we're on this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _miniPlayerNotifier.hide();
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
    // Cancel volume listener safely — flutter_volume_controller may throw
    // MissingPluginException on some platforms/emulators.
    try {
      FlutterVolumeController.removeListener();
    } catch (_) {}

    _vinylCtrl.dispose();
    for (final c in _eqCtrls) c.dispose();

    // NOTE: We intentionally do NOT dispose _audioNotifier.player here.
    // The AudioPlayer lives in the shared audioProvider which persists beyond
    // this screen, allowing the MiniPlayer to keep controlling playback.

    // Show MiniPlayer when leaving the screen (deferred so Riverpod is happy).
    Future(() => _miniPlayerNotifier.show());
    super.dispose();
  }

  void _togglePlay() => _audioNotifier.togglePlayPause();

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
    final _position = audioState.position;
    final _duration = audioState.duration;
    final _isPlaying = audioState.isPlaying;

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final sw = MediaQuery.of(context).size.width;
    final artSize = (sw * 0.72).clamp(180.0, 320.0);

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
        body: SafeArea(
          child: LayoutBuilder(
            builder: (ctx, box) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: 8.h),

                      // ── Top row ──────────────────────────────────
                      // Always: [☰ menu | center | ← back]
                      // LTR → menu LEFT, back RIGHT  ✓
                      // RTL → Row reverses → menu RIGHT, back LEFT ✓
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: Icon(
                                isRtl
                                    ? Icons.arrow_back_ios_rounded
                                    : Icons.arrow_back_ios_rounded,
                                color: cs.onSurface,
                                size: 20.sp,
                              ),
                            ),
                            // ☰ Drawer toggle
                            // IconButton(
                            //   onPressed: () =>
                            //       _drawerController.toggle?.call(),
                            //   icon: Icon(Icons.menu_rounded,
                            //       color: Colors.black87, size: 24.sp),
                            // ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'PLAYING FROM',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    _track.album,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ← Back

                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // ── Spinning vinyl album art ─────────────────
                      AnimatedBuilder(
                        animation: _vinylCtrl,
                        builder: (_, child) => Transform.rotate(
                          angle: _vinylCtrl.value * 2 * math.pi,
                          child: child,
                        ),
                        child: SizedBox(
                          width: artSize,
                          height: artSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Orange ring
                              Container(
                                width: artSize,
                                height: artSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: cs.primary, width: 6),
                                ),
                              ),
                              // White gap
                              Container(
                                width: artSize * 0.87,
                                height: artSize * 0.87,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cs.surface,
                                ),
                              ),
                              // Cover image
                              Container(
                                width: artSize * 0.75,
                                height: artSize * 0.75,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        _track.coverImageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Centre hole
                              Container(
                                width: artSize * 0.08,
                                height: artSize * 0.08,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cs.surface,
                                  border: Border.all(
                                      color: cs.primary, width: 2),
                                ),
                              ),
                            ],
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
                              _track.titleAr, // Or use a localization helper if available here
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    (sw * 0.085).clamp(24, 42).toDouble(),
                                fontWeight: FontWeight.w900,
                                color: cs.onSurface,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              _track.speakerAr,
                              style: TextStyle(
                                fontSize: 15.sp,
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
                          _IBtn(
                            icon: _isDownloaded
                                ? Icons.download_done_rounded
                                : Icons.download_rounded,
                            onTap: () => setState(
                                () => _isDownloaded = !_isDownloaded),
                          ),
                          SizedBox(width: 20.w),
                          _IBtn(
                            icon: _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            onTap: () =>
                                setState(() => _isFavorite = !_isFavorite),
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
                                onTap: () => setState(
                                    () => _isShuffled = !_isShuffled),
                              ),
                              _IBtn(
                                icon: Icons.skip_previous_rounded,
                                color: cs.onSurface,
                                size: 34.sp,
                                onTap: () => _audioNotifier.seek(Duration.zero),
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
                                onTap: () {},
                              ),
                              _IBtn(
                                icon: Icons.repeat_rounded,
                                color: _isRepeating
                                    ? cs.primary
                                    : Colors.grey[400]!,
                                size: 26.sp,
                                onTap: () => setState(
                                    () => _isRepeating = !_isRepeating),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // ── Volume slider ────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
                          children: [
                            Icon(Icons.volume_down_rounded,
                                color: cs.onSurface.withValues(alpha: 0.4), size: 20.sp),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4.h,
                                  activeTrackColor: cs.primary,
                                  inactiveTrackColor: cs.outlineVariant,
                                  thumbColor: cs.primary,
                                  overlayColor: cs.primary.withOpacity(0.15),
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 7.r),
                                ),
                                child: Slider(
                                  value: _volume,
                                  min: 0,
                                  max: 1,
                                  onChanged: (v) {
                                    setState(() => _volume = v);
                                    _audioNotifier.setVolume(v);
                                  },
                                ),
                              ),
                            ),
                            Icon(Icons.volume_up_rounded,
                                color: cs.onSurface.withValues(alpha: 0.4), size: 20.sp),
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

// ─── Track model ──────────────────────────────────────────────────────────────

class Track {
  final String id;
  final String titleAr;
  final String titleEn;
  final String speakerAr;
  final String speakerEn;
  final String album;
  final String coverImageUrl;

  const Track({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.speakerAr,
    required this.speakerEn,
    required this.album,
    required this.coverImageUrl,
  });
}
