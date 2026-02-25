import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/app_drawer.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  int _selectedIndex = 2; // Gallery is selected

  final List<PhotoAlbum> _albums = [
    PhotoAlbum(
      id: '1',
      title: 'Summer Memories',
      photoCount: 24,
      coverImage: 'https://picsum.photos/seed/summer-memories/200/200',
      date: 'July 2024',
    ),
    PhotoAlbum(
      id: '2',
      title: 'Church Events',
      photoCount: 48,
      coverImage: 'https://picsum.photos/seed/church-events/200/200',
      date: 'June 2024',
    ),
    PhotoAlbum(
      id: '3',
      title: 'Family Gatherings',
      photoCount: 36,
      coverImage: 'https://picsum.photos/seed/family-gatherings/200/200',
      date: 'May 2024',
    ),
    PhotoAlbum(
      id: '4',
      title: 'Nature Walks',
      photoCount: 18,
      coverImage: 'https://picsum.photos/seed/nature-walks/200/200',
      date: 'April 2024',
    ),
    PhotoAlbum(
      id: '5',
      title: 'Concert Photos',
      photoCount: 72,
      coverImage: 'https://picsum.photos/seed/concert-photos/200/200',
      date: 'August 2024',
    ),
    PhotoAlbum(
      id: '6',
      title: 'Travel Diary',
      photoCount: 45,
      coverImage: 'https://picsum.photos/seed/travel-diary/200/200',
      date: 'September 2024',
    ),
  ];

  // void _onBottomNavTapped removed

  void _onAlbumTapped(PhotoAlbum album) {
    // TODO: Navigate to album details
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
          'Photo Gallery',
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
                    hintText: 'Search photos...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: AppConstants.mediumSpacing.h),

            // Albums grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.mediumSpacing.w,
                  mainAxisSpacing: AppConstants.mediumSpacing.h,
                  childAspectRatio: 0.8,
                ),
                itemCount: _albums.length,
                itemBuilder: (context, index) {
                  final album = _albums[index];
                  return PhotoAlbumCard(
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

class PhotoAlbum {
  final String id;
  final String title;
  final int photoCount;
  final String coverImage;
  final String date;

  PhotoAlbum({
    required this.id,
    required this.title,
    required this.photoCount,
    required this.coverImage,
    required this.date,
  });
}

class PhotoAlbumCard extends StatelessWidget {
  final PhotoAlbum album;
  final VoidCallback onTap;

  const PhotoAlbumCard({
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
            // Album cover
            Expanded(
              flex: 3,
              child: Container(
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
            ),

            SizedBox(height: AppConstants.smallSpacing.h),

            // Album info
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
                      '${album.photoCount} photos',
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
