import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/mini_player_provider.dart';
import '../../widgets/common/app_drawer.dart';

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
    this.imageUrl = 'https://picsum.photos/seed/violin/400/400',
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

  List<AlbumTrack> get _tracks => [
        AlbumTrack(
          id: '1',
          title: 'Sunset Boulevard',
          artist: widget.artist,
          duration: '3:42',
          coverImageUrl: 'https://picsum.photos/seed/sunset/60/60',
        ),
        AlbumTrack(
          id: '2',
          title: 'Waves of Ocean',
          artist: widget.artist,
          duration: '4:15',
          coverImageUrl: 'https://picsum.photos/seed/waves/60/60',
        ),
        AlbumTrack(
          id: '3',
          title: 'Golden Hour',
          artist: widget.artist,
          duration: '3:28',
          coverImageUrl: 'https://picsum.photos/seed/golden/60/60',
        ),
        AlbumTrack(
          id: '4',
          title: 'Midnight Dreams',
          artist: widget.artist,
          duration: '4:02',
          coverImageUrl: 'https://picsum.photos/seed/midnight/60/60',
        ),
        AlbumTrack(
          id: '5',
          title: 'Morning Coffee',
          artist: widget.artist,
          duration: '3:15',
          coverImageUrl: 'https://picsum.photos/seed/morning/60/60',
        ),
        AlbumTrack(
          id: '6',
          title: 'City Lights',
          artist: widget.artist,
          duration: '3:55',
          coverImageUrl: 'https://picsum.photos/seed/city/60/60',
        ),
      ];

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onTrackTapped(AlbumTrack track) {
    ref.read(miniPlayerProvider.notifier).play(
      MiniPlayerTrack(
        id: track.id,
        title: track.title,
        artist: track.artist,
        coverImageUrl: track.coverImageUrl,
      ),
    );
    context.push('/player?trackId=${track.id}');
  }

  void _onPlayAll() {
    final first = _tracks.first;
    ref.read(miniPlayerProvider.notifier).play(
      MiniPlayerTrack(
        id: first.id,
        title: first.title,
        artist: first.artist,
        coverImageUrl: first.coverImageUrl,
      ),
    );
    context.push('/player');
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final albumTracks = _tracks;
    return ZoomDrawer(
      controller: _drawerController,
      style: DrawerStyle.defaultStyle,
      menuScreen: const AppDrawer(),
      isRtl: isRtl,
      borderRadius: 24.0,
      showShadow: true,
      angle: isRtl ? 12.0 : -12.0,
      drawerShadowsBackgroundColor: Colors.grey[300]!,
      slideWidth: MediaQuery.of(context).size.width * 0.75,
      menuBackgroundColor: Colors.white,
      mainScreen: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          // Menu icon in leading → LEFT in English, RIGHT in Arabic (auto-mirrored)
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.black),
            onPressed: () => _drawerController.toggle?.call(),
          ),
          title: Text(
            'ALBUM DETAILS',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          actions: [
            // Back arrow in actions → RIGHT in English, LEFT in Arabic
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ],
        ),
        body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Album cover section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Album cover + floating play button
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 160.w,
                            height: 160.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.mediumBorderRadius.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.mediumBorderRadius.r),
                              child: widget.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: widget.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (ctx, url) => Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                                Icons.album,
                                                size: 48,
                                                color: Colors.grey),
                                          ),
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.album,
                                          size: 48, color: Colors.grey),
                                    ),
                            ),
                          ).animate().scale(
                                duration: AppConstants.defaultAnimationDuration,
                                curve: Curves.easeOut,
                              ),
                          // Floating play button
                          Positioned(
                            bottom: -14.w,
                            right: -14.w,
                            child: GestureDetector(
                              onTap: _onPlayAll,
                              child: Container(
                                width: 48.w,
                                height: 48.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF6B35),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x55FF6B35),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.play_arrow,
                                    color: Colors.white, size: 28.w),
                              ),
                            ).animate().fadeIn(
                                  duration: AppConstants.defaultAnimationDuration,
                                  delay: const Duration(milliseconds: 400),
                                ),
                          ),
                        ],
                      ),

                      SizedBox(width: AppConstants.largeSpacing.w),

                      // Album info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: AppConstants.smallSpacing.h),
                            Text(
                              widget.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                            ).animate().fadeIn(
                                  duration: AppConstants.defaultAnimationDuration,
                                  delay: const Duration(milliseconds: 200),
                                ),

                            SizedBox(height: AppConstants.smallSpacing.h),

                            Text(
                              widget.artist,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.grey[600]),
                            ).animate().fadeIn(
                                  duration: AppConstants.defaultAnimationDuration,
                                  delay: const Duration(milliseconds: 400),
                                ),

                            SizedBox(height: AppConstants.smallSpacing.h),

                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 14.w, color: Colors.grey[500]),
                                SizedBox(width: 4.w),
                                Text(
                                  widget.year,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                SizedBox(width: 12.w),
                                Icon(Icons.music_note_outlined,
                                    size: 14.w, color: Colors.grey[500]),
                                SizedBox(width: 4.w),
                                Text(
                                  '${albumTracks.length} Songs',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ).animate().fadeIn(
                                  duration: AppConstants.defaultAnimationDuration,
                                  delay: const Duration(milliseconds: 600),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppConstants.extraLargeSpacing.h + 8.h),

                  // Categories section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See All',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: const Color(0xFFFF6B35)),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(
                        duration: AppConstants.defaultAnimationDuration,
                        delay: const Duration(milliseconds: 800),
                      ),

                  SizedBox(height: AppConstants.smallSpacing.h),

                  // Category pills
                  SizedBox(
                    height: 40.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;
                        return Padding(
                          padding:
                              EdgeInsets.only(right: AppConstants.smallSpacing.w),
                          child: GestureDetector(
                            onTap: () => _onCategorySelected(category),
                            child: AnimatedContainer(
                              duration: AppConstants.defaultAnimationDuration,
                              padding: EdgeInsets.symmetric(
                                horizontal: AppConstants.mediumSpacing.w,
                                vertical: AppConstants.smallSpacing.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFF6B35)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: AppConstants.largeSpacing.h),

                  // Tracks header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tracks',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                      Text(
                        '${albumTracks.length} Songs',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ).animate().fadeIn(
                        duration: AppConstants.defaultAnimationDuration,
                        delay: const Duration(milliseconds: 1000),
                      ),

                  SizedBox(height: AppConstants.mediumSpacing.h),

                  // Track list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: albumTracks.length,
                    itemBuilder: (context, index) {
                      final track = albumTracks[index];
                      return TrackTile(
                        track: track,
                        onTap: () => _onTrackTapped(track),
                        index: index,
                      ).animate().slideX(
                            duration: AppConstants.defaultAnimationDuration,
                            delay: Duration(
                                milliseconds: 1200 + (index * 100)),
                            begin: -0.2,
                            curve: Curves.easeOut,
                          );
                    },
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
      ), // closes mainScreen Scaffold
    ); // closes ZoomDrawer
  }
}


// ──────────────────────────────────────────────────────────────
// Track Tile
// ──────────────────────────────────────────────────────────────
class TrackTile extends StatelessWidget {
  final AlbumTrack track;
  final VoidCallback onTap;
  final int index;

  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppConstants.smallSpacing.w,
        vertical: 2.h,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius.r),
        child: CachedNetworkImage(
          imageUrl: track.coverImageUrl,
          width: 48.w,
          height: 48.w,
          fit: BoxFit.cover,
          placeholder: (ctx, url) =>
              Container(color: Colors.grey[200], width: 48.w, height: 48.w),
        ),
      ),
      title: Text(
        track.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artist,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.grey[600]),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            track.duration,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(width: 4.w),
          IconButton(
            onPressed: onTap,
            icon: Icon(Icons.play_arrow,
                color: const Color(0xFFFF6B35), size: 22.w),
            tooltip: 'Play',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 4.w),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.favorite_border,
                color: Colors.grey[500], size: 20.w),
            tooltip: 'Favourite',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Data Models
// ──────────────────────────────────────────────────────────────
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
