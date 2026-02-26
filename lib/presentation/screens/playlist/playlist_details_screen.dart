import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/app_drawer.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  final String playlistId;
  const PlaylistDetailsScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  static const Color _accent = Color(0xFFFF6B35);

  // Demo tracks list
  final List<_PlaylistTrack> _tracks = const [
    _PlaylistTrack(title: 'Have You', artist: 'Madihu, Low G', duration: '3:50'),
    _PlaylistTrack(title: 'Midnight City', artist: 'M83', duration: '4:03'),
    _PlaylistTrack(title: 'Sunset Drive', artist: 'Various', duration: '3:22'),
    _PlaylistTrack(title: 'Ocean Breeze', artist: 'Lo-Fi Beats', duration: '2:55'),
    _PlaylistTrack(title: 'Golden Hour', artist: 'JVKE', duration: '4:11'),
  ];

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return ZoomDrawer(
      controller: _drawerController,
      style: DrawerStyle.defaultStyle,
      menuScreen: const AppDrawer(),
      isRtl: isRtl,
      borderRadius: 24,
      showShadow: true,
      angle: isRtl ? 12 : -12,
      drawerShadowsBackgroundColor: Colors.grey[300]!,
      slideWidth: MediaQuery.of(context).size.width * 0.75,
      menuBackgroundColor: Colors.white,
      mainScreen: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu_rounded, color: Colors.black, size: 24.sp),
            onPressed: () => _drawerController.toggle?.call(),
          ),
          title: Text(
            'Playlist',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                isRtl
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 20.sp,
              ),
              onPressed: () => context.pop(),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playlist header
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  // Cover art
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(Icons.queue_music_rounded,
                        color: _accent, size: 48.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Playlist #${widget.playlistId}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${_tracks.length} tracks',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Play All button
                        SizedBox(
                          height: 36.h,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/player'),
                            icon: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white),
                            label: const Text('Play All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Track list
            Expanded(
              child: ListView.builder(
                itemCount: _tracks.length,
                itemBuilder: (ctx, i) {
                  final track = _tracks[i];
                  return ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                    leading: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      track.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      track.artist,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      track.duration,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () =>
                        context.push('/player?trackId=${i + 1}'),
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

class _PlaylistTrack {
  final String title;
  final String artist;
  final String duration;
  const _PlaylistTrack({
    required this.title,
    required this.artist,
    required this.duration,
  });
}