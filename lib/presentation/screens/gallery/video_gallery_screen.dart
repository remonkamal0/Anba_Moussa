import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/app_drawer.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class VideoGalleryScreen extends StatefulWidget {
  const VideoGalleryScreen({super.key});

  @override
  State<VideoGalleryScreen> createState() => _VideoGalleryScreenState();
}

class _VideoGalleryScreenState extends State<VideoGalleryScreen> {
  int _selectedIndex = 3; // Videos is selected

  final List<VideoAlbum> _videoAlbums = [
    VideoAlbum(
      id: '1',
      title: 'Worship Services',
      videoCount: 12,
      coverImage: 'https://picsum.photos/seed/worship-services/200/200',
      date: 'July 2024',
    ),
    VideoAlbum(
      id: '2',
      title: 'Sermon Series',
      videoCount: 8,
      coverImage: 'https://picsum.photos/seed/sermon-series/200/200',
      date: 'June 2024',
    ),
    VideoAlbum(
      id: '3',
      title: 'Youth Events',
      videoCount: 15,
      coverImage: 'https://picsum.photos/seed/youth-events/200/200',
      date: 'May 2024',
    ),
    VideoAlbum(
      id: '4',
      title: 'Music Concerts',
      videoCount: 20,
      coverImage: 'https://picsum.photos/seed/music-concerts/200/200',
      date: 'August 2024',
    ),
    VideoAlbum(
      id: '5',
      title: 'Bible Studies',
      videoCount: 6,
      coverImage: 'https://picsum.photos/seed/bible-studies/200/200',
      date: 'April 2024',
    ),
    VideoAlbum(
      id: '6',
      title: 'Community Outreach',
      videoCount: 10,
      coverImage: 'https://picsum.photos/seed/community-outreach/200/200',
      date: 'March 2024',
    ),
  ];

  // void _onBottomNavTapped removed

  void _onAlbumTapped(VideoAlbum album) {
    // TODO: Navigate to video album details
    print('Tapped album: ${album.title}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                if (ZoomDrawer.of(context) != null) {
                  ZoomDrawer.of(context)!.toggle();
                }
              },
            );
          }
        ),
        title: Text(
          'Video Gallery',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search videos...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: AppConstants.mediumSpacing.h),

            // Video albums grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.mediumSpacing.w,
                  mainAxisSpacing: AppConstants.mediumSpacing.h,
                  childAspectRatio: 0.8,
                ),
                itemCount: _videoAlbums.length,
                itemBuilder: (context, index) {
                  final album = _videoAlbums[index];
                  return VideoAlbumCard(
                    album: album,
                    onTap: () => _onAlbumTapped(album),
                  ).animate().scale(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: Duration(milliseconds: index * 100),
                    curve: Curves.easeOut,
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

class VideoAlbum {
  final String id;
  final String title;
  final int videoCount;
  final String coverImage;
  final String date;

  VideoAlbum({
    required this.id,
    required this.title,
    required this.videoCount,
    required this.coverImage,
    required this.date,
  });
}

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail with play button overlay
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppConstants.mediumBorderRadius.r),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(album.coverImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Play button overlay
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppConstants.smallSpacing.h),

            // Video info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      album.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppConstants.extraSmallSpacing.h),

                    Text(
                      '${album.videoCount} videos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: AppConstants.extraSmallSpacing.h),

                    Text(
                      album.date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
