import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class AlbumDetailsScreen extends ConsumerStatefulWidget {
  final String albumId;
  final String title;
  final String imageUrl;
  final String artist;
  final String year;

  const AlbumDetailsScreen({
    super.key,
    this.albumId = '1',
    this.title = 'Island Getaway',
    this.imageUrl = 'https://picsum.photos/seed/violin/800/800',
    this.artist = 'Olivia Lyric',
    this.year = '2023',
  });

  @override
  ConsumerState<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends ConsumerState<AlbumDetailsScreen> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  String _selectedCategory = 'Rock';
  final List<String> _categories = ['Rock', 'Pop', 'Chill', 'Jazz'];

  // حالات محلية للأكشن (مفضلة/تحميل) لكل تراك
  final Set<String> _likedTrackIds = {};
  final Set<String> _downloadedTrackIds = {};

  List<AlbumTrack> get _tracks => [
    AlbumTrack(
      id: '1',
      title: 'Sunset Boulevard',
      artist: widget.artist,
      duration: '3:42',
      coverImageUrl: 'https://picsum.photos/seed/sunset/120/120',
    ),
    AlbumTrack(
      id: '2',
      title: 'Waves of Ocean',
      artist: widget.artist,
      duration: '4:15',
      coverImageUrl: 'https://picsum.photos/seed/waves/120/120',
    ),
    AlbumTrack(
      id: '3',
      title: 'Golden Hour',
      artist: widget.artist,
      duration: '2:58',
      coverImageUrl: 'https://picsum.photos/seed/golden/120/120',
    ),
    AlbumTrack(
      id: '4',
      title: 'Midnight Dreams',
      artist: widget.artist,
      duration: '5:21',
      coverImageUrl: 'https://picsum.photos/seed/midnight/120/120',
    ),
  ];

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

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
  }

  void _onTrackTapped(AlbumTrack track) {
    // هنا تقدر تربط miniPlayerProvider لو عندك
    context.push('/player?trackId=${track.id}');
  }

  void _onPlayAll() {
    final first = _tracks.first;
    _onTrackTapped(first);
  }

  void _toggleLike(AlbumTrack track) {
    setState(() {
      if (_likedTrackIds.contains(track.id)) {
        _likedTrackIds.remove(track.id);
        _toast('Removed from favorites ❤️‍🩹');
      } else {
        _likedTrackIds.add(track.id);
        _toast('Added to favoritesة ❤️');
      }
    });
  }

  void _toggleDownload(AlbumTrack track) async {
    // هنا عملنا اكشن UI فوري + محاكاة تحميل (Fake)
    if (_downloadedTrackIds.contains(track.id)) {
      setState(() => _downloadedTrackIds.remove(track.id));
      _toast('The download was cancelled ⛔');
      return;
    }

    _toast('Loading… ⏳');

    // محاكاة وقت تحميل بسيط
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() => _downloadedTrackIds.add(track.id));
    _toast('Downloaded ✅');
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final cs = Theme.of(context).colorScheme;

    return ZoomDrawer(
      controller: _drawerController,
      style: DrawerStyle.defaultStyle,
      menuScreen: const _DrawerPlaceholder(),
      isRtl: isRtl,
      borderRadius: 24.0,
      showShadow: true,
      angle: isRtl ? 10.0 : -10.0,
      drawerShadowsBackgroundColor: cs.onSurface.withValues(alpha: 0.1),
      slideWidth: MediaQuery.of(context).size.width * 0.75,
      menuBackgroundColor: cs.surface,
      mainScreen: Scaffold(
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
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.more_horiz_rounded, color: Colors.black),
          //     onPressed: () {},
          //   ),
          // ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Header + Play Button + Tracks Count Badge (مخفي تحت زرار التشغيل)
              _HeroAlbumHeader(
                title: widget.title,
                artist: widget.artist,
                imageUrl: widget.imageUrl,
                tracksCount: _tracks.length,
                onPlayTap: _onPlayAll,
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 260))
                  .slideY(begin: 0.08, end: 0, duration: const Duration(milliseconds: 260)),

              SizedBox(height: 26.h),

              // Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              SizedBox(
                height: 38.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == _selectedCategory;

                    return GestureDetector(
                      onTap: () => _onCategorySelected(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.87),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 18.h),

              // Tracks header (اختياري: لو عايز تخفي عدد التراكات هنا كمان سيبه كده)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tracks',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  // ممكن تشيل السطرين دول لو مش عايز يظهر عدد التراكات هنا
                  Text(
                    '${_tracks.length} Songs',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // Track list (كلهم نفس الشكل بدون تمييز)
              ListView.separated(
                itemCount: _tracks.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final t = _tracks[index];

                  final isLiked = _likedTrackIds.contains(t.id);
                  final isDownloaded = _downloadedTrackIds.contains(t.id);

                  return TrackCard(
                    track: t,
                    isLiked: isLiked,
                    isDownloaded: isDownloaded,
                    onTap: () => _onTrackTapped(t),
                    onLike: () => _toggleLike(t),
                    onDownload: () => _toggleDownload(t),
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 220), delay: Duration(milliseconds: 70 * index))
                      .slideX(begin: -0.05, end: 0, duration: const Duration(milliseconds: 220), delay: Duration(milliseconds: 70 * index));
                },
              ),

              SizedBox(height: 18.h),
            ],
          ),
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
                offset: const Offset(0, 10),
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

        // Floating play button
        Positioned(
          right: 22.w,
          bottom: -28.h,
          child: Column(
            children: [
              GestureDetector(
                onTap: onPlayTap,
                child: Container(
                  width: 60.w,
                  height: 60.w,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34.w,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
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
class TrackCard extends StatelessWidget {
  final AlbumTrack track;
  final bool isLiked;
  final bool isDownloaded;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onDownload;

  const TrackCard({
    super.key,
    required this.track,
    required this.onTap,
    required this.onLike,
    required this.onDownload,
    this.isLiked = false,
    this.isDownloaded = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              // cover thumb
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: track.coverImageUrl,
                  width: 48.w,
                  height: 48.w,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[200], width: 48.w, height: 48.w),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    width: 48.w,
                    height: 48.w,
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // title + artist + duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface.withValues(alpha: 0.87),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        Text(
                          track.duration,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // actions
              _IconAction(
                icon: Icons.play_circle_fill_rounded,
                color: cs.primary,
                onTap: onTap,
              ),
              SizedBox(width: 10.w),

              _IconAction(
                icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isLiked ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
                onTap: onLike,
              ),
              SizedBox(width: 10.w),

              _IconAction(
                icon: isDownloaded ? Icons.download_done_rounded : Icons.file_download_outlined,
                color: isDownloaded ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
                onTap: onDownload,
              ),
            ],
          ),
        ),
      ),
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

// Placeholder Drawer (بدل AppDrawer لو مش موجود)
class _DrawerPlaceholder extends StatelessWidget {
  const _DrawerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Menu', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900)),
            SizedBox(height: 14.h),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => ZoomDrawer.of(context)?.close(),
            ),
            ListTile(
              leading: const Icon(Icons.library_music),
              title: const Text('Library'),
              onTap: () => ZoomDrawer.of(context)?.close(),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class AlbumTrack {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final String coverImageUrl;

  AlbumTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.coverImageUrl,
  });
}