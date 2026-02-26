import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:just_audio/just_audio.dart';
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
  static const Color _accent = Color(0xFFFF6B35);
  static const _demoUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  final ZoomDrawerController _drawerController = ZoomDrawerController();
  late final AudioPlayer _audio;

  // Vinyl rotation controller
  late final AnimationController _vinylCtrl;

  // EQ bar controllers (5 bars, staggered durations)
  late final List<AnimationController> _eqCtrls;
  late final List<Animation<double>> _eqAnims;

  bool _isFavorite = false;
  bool _isDownloaded = false;
  bool _isShuffled = false;
  bool _isRepeating = false;
  Duration _position = const Duration(seconds: 45);
  Duration _duration = const Duration(seconds: 230);

  final Track _track = const Track(
    id: '1',
    title: 'Have you',
    artist: 'Madihu, Low G',
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

    _audio = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audio.setUrl(_demoUrl);
      _audio.durationStream.listen(
          (d) { if (d != null && mounted) setState(() => _duration = d); });
      _audio.positionStream.listen(
          (p) { if (mounted) setState(() => _position = p); });
      _audio.playingStream.listen((playing) {
        if (!mounted) return;
        if (playing) {
          _vinylCtrl.repeat();
          for (final c in _eqCtrls) c.repeat(reverse: true);
        } else {
          _vinylCtrl.stop();
          for (final c in _eqCtrls) c.stop();
        }
        // Keep mini player icon in sync
        final mini = ref.read(miniPlayerProvider);
        if (mini.isPlaying != playing) {
          ref.read(miniPlayerProvider.notifier).togglePlayPause();
        }
        setState(() {});
      });
      await _audio.play();
    } catch (_) {}
  }

  @override
  void dispose() {
    _vinylCtrl.dispose();
    for (final c in _eqCtrls) c.dispose();
    _audio.dispose();
    super.dispose();
  }

  bool get _isPlaying => _audio.playing;

  void _togglePlay() {
    _isPlaying ? _audio.pause() : _audio.play();
    setState(() {});
  }

  void _onSeek(double v) {
    _audio.seek(Duration(seconds: v.round()));
    setState(() => _position = Duration(seconds: v.round()));
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
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
      menuBackgroundColor: Colors.white,
      mainScreen: Scaffold(
        backgroundColor: Colors.white,
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
                            // ☰ Drawer toggle
                            IconButton(
                              onPressed: () =>
                                  _drawerController.toggle?.call(),
                              icon: Icon(Icons.menu_rounded,
                                  color: Colors.black87, size: 24.sp),
                            ),
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
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ← Back
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: Icon(
                                isRtl
                                    ? Icons.arrow_back_ios_rounded
                                    : Icons.arrow_back_ios_rounded,
                                color: Colors.black87,
                                size: 20.sp,
                              ),
                            ),
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
                                      color: _accent, width: 6),
                                ),
                              ),
                              // White gap
                              Container(
                                width: artSize * 0.87,
                                height: artSize * 0.87,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
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
                                  color: Colors.white,
                                  border: Border.all(
                                      color: _accent, width: 2),
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
                              _track.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    (sw * 0.085).clamp(24, 42).toDouble(),
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              _track.artist,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // ── 🎚 Equalizer bars ────────────────────────
                      _EqualizerBars(
                        eqAnims: _eqAnims,
                        isPlaying: _isPlaying,
                      ),

                      SizedBox(height: 10.h),

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
                                      activeTrackColor: _accent,
                                      inactiveTrackColor: Colors.grey[300],
                                      thumbColor: _accent,
                                      overlayColor:
                                          _accent.withOpacity(0.15),
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
                                          color: Colors.grey[600])),
                                  Text(_fmt(_duration),
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600])),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
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
                                    ? _accent
                                    : Colors.grey[400]!,
                                size: 26.sp,
                                onTap: () => setState(
                                    () => _isShuffled = !_isShuffled),
                              ),
                              _IBtn(
                                icon: Icons.skip_previous_rounded,
                                color: Colors.black87,
                                size: 34.sp,
                                onTap: () => _audio.seek(Duration.zero),
                              ),
                              // Play/Pause
                              Container(
                                width: 62.w,
                                height: 62.w,
                                decoration: BoxDecoration(
                                  color: _accent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _accent.withOpacity(0.35),
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
                                color: Colors.black87,
                                size: 34.sp,
                                onTap: () {},
                              ),
                              _IBtn(
                                icon: Icons.repeat_rounded,
                                color: _isRepeating
                                    ? _accent
                                    : Colors.grey[400]!,
                                size: 26.sp,
                                onTap: () => setState(
                                    () => _isRepeating = !_isRepeating),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),
                      const Spacer(),
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
                    color: const Color(0xFFFF6B35)
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
  final Color color;
  final double size;

  const _IBtn({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFFFF6B35),
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) =>
      IconButton(onPressed: onTap, icon: Icon(icon, color: color, size: size));
}

// ─── Track model ──────────────────────────────────────────────────────────────

class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String coverImageUrl;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.coverImageUrl,
  });
}