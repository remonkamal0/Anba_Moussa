import 'package:flutter/material.dart';
import 'video_album_details_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../widgets/common/app_drawer.dart';

class VideoGalleryScreen extends StatefulWidget {
  const VideoGalleryScreen({super.key});

  @override
  State<VideoGalleryScreen> createState() => _VideoGalleryScreenState();
}

class _VideoGalleryScreenState extends State<VideoGalleryScreen> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  final List<VideoAlbum> _videoAlbums = [
    VideoAlbum(
      id: '1',
      title: 'Church Sermons 2024',
      videoCount: 15,
      coverImage: 'https://picsum.photos/seed/church-sermons/800/800',
    ),
    VideoAlbum(
      id: '2',
      title: 'Live Hymns',
      videoCount: 42,
      coverImage: 'https://picsum.photos/seed/live-hymns/800/800',
    ),
    VideoAlbum(
      id: '3',
      title: 'Youth Conference',
      videoCount: 8,
      coverImage: 'https://picsum.photos/seed/youth-conf/800/800',
    ),
    VideoAlbum(
      id: '4',
      title: 'Special Choir',
      videoCount: 21,
      coverImage: 'https://picsum.photos/seed/special-choir/800/800',
    ),
    VideoAlbum(
      id: '5',
      title: 'Sunday School',
      videoCount: 12,
      coverImage: 'https://picsum.photos/seed/sunday-school/800/800',
    ),
    VideoAlbum(
      id: '6',
      title: 'Acoustic Worship',
      videoCount: 26,
      coverImage: 'https://picsum.photos/seed/acoustic-worship/800/800',
    ),
  ];

  void _onAlbumTapped(VideoAlbum album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoAlbumDetailsScreen(album: album),
      ),
    );
  }

  void _onSortTapped() {
    // TODO: sort action / bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sort clicked')),
    );
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
      borderRadius: 24.0,
      showShadow: true,
      angle: isRtl ? 10.0 : -10.0,
      drawerShadowsBackgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      slideWidth: MediaQuery.of(context).size.width * 0.75,
      menuBackgroundColor: Theme.of(context).colorScheme.surface,
      mainScreen: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu_rounded, color: cs.onSurface),
            onPressed: () => _drawerController.toggle?.call(),
          ),
          title: Text(
            'Video Gallery',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header like the screenshot
                SizedBox(height: 6.h),
                Text(
                  'ALL ALBUMS',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: cs.primary,
                  ),
                ),
                SizedBox(height: 6.h),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Video Collections',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),
                    ),

                    // Sort button
                    GestureDetector(
                      onTap: _onSortTapped,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: cs.outlineVariant),
                          boxShadow: [
                            BoxShadow(
                              color: cs.onSurface.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 16.w, color: cs.primary),
                            SizedBox(width: 6.w),
                            Text(
                              'Sort',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface.withValues(alpha: 0.87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.only(bottom: 14.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 14.h,
                      childAspectRatio: 0.78, // زي الصورة
                    ),
                    itemCount: _videoAlbums.length,
                    itemBuilder: (context, index) {
                      final album = _videoAlbums[index];

                      return VideoAlbumCard(
                        album: album,
                        onTap: () => _onAlbumTapped(album),
                      )
                          .animate()
                          .fadeIn(
                        duration: const Duration(milliseconds: 240),
                        delay: Duration(milliseconds: index * 70),
                        curve: Curves.easeOut,
                      )
                          .slideY(
                        begin: 0.08,
                        end: 0,
                        duration: const Duration(milliseconds: 240),
                        delay: Duration(milliseconds: index * 70),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------
class VideoAlbum {
  final String id;
  final String title;
  final int videoCount;
  final String coverImage;

  VideoAlbum({
    required this.id,
    required this.title,
    required this.videoCount,
    required this.coverImage,
  });
}

// ---------------------------------------------------------------------------
// Card (مطابق للصورة: play في النص + title + count برتقاني)
// ---------------------------------------------------------------------------
class VideoAlbumCard extends StatelessWidget {
  final VideoAlbum album;
  final VoidCallback onTap;

  const VideoAlbumCard({
    super.key,
    required this.album,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with centered play button
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: album.coverImage,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey[200]),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),

                    // subtle dark overlay like screenshot
                    Container(
                      color: Colors.black.withOpacity(0.08),
                    ),

                    // play button in center
                    Center(
                      child: Container(
                        width: 46.w,
                        height: 46.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: cs.primary,
                          size: 26.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Title
          Text(
            album.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 4.h),

          // Count (orange)
          Text(
            '${album.videoCount} Videos',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}