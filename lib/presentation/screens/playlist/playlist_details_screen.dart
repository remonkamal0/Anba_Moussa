import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/app_drawer.dart';
import '../favorites/all_playlists_screen.dart' show Playlist;
import 'create_playlist_screen.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  final String playlistId;
  const PlaylistDetailsScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();



  final Set<int> _likedTracks = {0};
  final Set<int> _downloadedTracks = {};
  int? _playingTrackIndex;
  late List<_PlaylistTrack> _tracks;

  static const List<_PlaylistTrack> _defaultTracks = [
    _PlaylistTrack(title: 'Have You', artist: 'Madihu, Low G', duration: '3:50', coverUrl: 'https://picsum.photos/seed/track1/100/100'),
    _PlaylistTrack(title: 'Midnight City', artist: 'M83', duration: '4:03', coverUrl: 'https://picsum.photos/seed/track2/100/100'),
    _PlaylistTrack(title: 'Sunset Drive', artist: 'Various', duration: '3:22', coverUrl: 'https://picsum.photos/seed/track3/100/100'),
    _PlaylistTrack(title: 'Ocean Breeze', artist: 'Lo-Fi Beats', duration: '2:55', coverUrl: 'https://picsum.photos/seed/track4/100/100'),
    _PlaylistTrack(title: 'Golden Hour', artist: 'JVKE', duration: '4:11', coverUrl: 'https://picsum.photos/seed/track5/100/100'),
  ];

  @override
  void initState() {
    super.initState();
    _tracks = List.of(_defaultTracks); // Guaranteed growable list
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final cs = Theme.of(context).colorScheme;

    return ZoomDrawer(
      controller: _drawerController,
      style: DrawerStyle.defaultStyle,
      menuScreen: const AppDrawer(),
      isRtl: isRtl,
      borderRadius: 24,
      showShadow: true,
      angle: isRtl ? 12 : -12,
      drawerShadowsBackgroundColor: cs.surfaceContainerHighest,
      slideWidth: MediaQuery.of(context).size.width * 0.75,
      menuBackgroundColor: cs.surface,
      mainScreen: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
              color: cs.onSurface,
              size: 20.sp,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'ALBUM',
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
              icon: Icon(Icons.share_outlined, color: cs.onSurface, size: 22.sp),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: cs.onSurface, size: 22.sp),
              onPressed: () {
                final currentPlaylist = Playlist(
                  id: widget.playlistId,
                  title: 'Holy Hymns 2024',
                  songCount: _tracks.length,
                  coverImage: 'https://picsum.photos/seed/playlist/400/400',
                  isPublic: false,
                  date: 'Just now',
                );

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreatePlaylistScreen(
                      existingPlaylist: currentPlaylist,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero cover
              Container(
                margin: EdgeInsets.only(top: 24.h),
                width: 260.w,
                height: 260.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF6D5443), // Brownish color from mockup
                  borderRadius: BorderRadius.circular(32.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('P L A Y L I S T', style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.54), fontSize: 10.sp, letterSpacing: 3)),
                      SizedBox(height: 8.h),
                      Text('PLAYLIST COVER', style: TextStyle(color: cs.onPrimary, fontSize: 16.sp, letterSpacing: 1)),
                      Container(margin: EdgeInsets.only(top: 8.h), height: 1.h, width: 40.w, color: cs.onPrimary.withValues(alpha: 0.54)),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 32.h),

              // Title
              Text(
                'Holy Hymns 2024',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'Created by St. Mary Church • ${_tracks.length} Tracks',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),

              SizedBox(height: 24.h),

              // Action Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/player'),
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                        label: const Text('Play', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/player'),
                        icon: Icon(Icons.shuffle_rounded, color: cs.onSurface),
                        label: Text('Shuffle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cs.onSurface)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.onSurface,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: BorderSide(color: cs.outlineVariant, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Track list
              ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _tracks.length,
                itemBuilder: (ctx, i) {
                  final track = _tracks[i];
                  final isLiked = _likedTracks.contains(i);
                  final isDownloaded = _downloadedTracks.contains(i);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _playingTrackIndex = i;
                      });
                      context.push('/player?trackId=${i + 1}');
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      child: Row(
                        children: [
                          // Play Icon
                          Container(
                            width: 52.w,
                            height: 52.w,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(Icons.play_arrow_rounded, color: cs.primary, size: 28.sp),
                          ),
                          SizedBox(width: 16.w),
                        
                        // Title / Artist
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      track.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp,
                                        color: cs.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (i == 0) ...[
                                    SizedBox(width: 8.w),
                                    Icon(Icons.bar_chart_rounded, color: cs.primary, size: 20.sp),
                                  ]
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                track.artist,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(width: 12.w),

                        // Trailing: duration + play + heart + download
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Duration text
                            Text(
                              track.duration,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: cs.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            // Orange play circle button
                            GestureDetector(
                              onTap: () {
                                setState(() => _playingTrackIndex = i);
                                context.push('/player?trackId=${i + 1}');
                              },
                              child: Container(
                                width: 34.w,
                                height: 34.w,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20.sp),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            // Heart toggle
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isLiked) {
                                    _likedTracks.remove(i);
                                  } else {
                                    _likedTracks.add(i);
                                  }
                                });
                              },
                              child: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? cs.primary : cs.onSurface.withValues(alpha: 0.3),
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            // Download toggle
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isDownloaded) {
                                    _downloadedTracks.remove(i);
                                  } else {
                                    _downloadedTracks.add(i);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Downloading track...'), duration: Duration(seconds: 1)),
                                    );
                                  }
                                });
                              },
                              child: Icon(
                                isDownloaded ? Icons.download_done_rounded : Icons.file_download_outlined,
                                color: isDownloaded ? cs.primary : cs.onSurface.withValues(alpha: 0.3),
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            // Delete icon
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tracks.removeAt(i);
                                  _likedTracks.remove(i);
                                  _downloadedTracks.remove(i);
                                  if (_playingTrackIndex == i) _playingTrackIndex = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Track removed from playlist'), duration: Duration(seconds: 1)),
                                );
                              },
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red[Theme.of(context).brightness == Brightness.dark ? 200 : 300],
                                size: 22.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              ),
              
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistTrack {
  final String title;
  final String artist;
  final String duration;
  final String coverUrl;
  const _PlaylistTrack({
    required this.title,
    required this.artist,
    required this.duration,
    required this.coverUrl,
  });
}