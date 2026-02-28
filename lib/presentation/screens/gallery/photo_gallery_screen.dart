import 'package:flutter/material.dart';
import 'photo_album_details_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../../core/constants/app_constants.dart';
import '../../widgets/common/app_drawer.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  final List<PhotoAlbum> _albums = [
    PhotoAlbum(
      id: '1',
      title: 'Church Events 2024',
      photoCount: 48,
      coverImage: 'https://picsum.photos/seed/church-events-2024/600/600',
    ),
    PhotoAlbum(
      id: '2',
      title: 'Live Concerts',
      photoCount: 120,
      coverImage: 'https://picsum.photos/seed/live-concerts/600/600',
    ),
    PhotoAlbum(
      id: '3',
      title: 'Behind the Scenes',
      photoCount: 32,
      coverImage: 'https://picsum.photos/seed/behind/600/600',
    ),
    PhotoAlbum(
      id: '4',
      title: 'Album Launch',
      photoCount: 15,
      coverImage: 'https://picsum.photos/seed/launch/600/600',
    ),
    PhotoAlbum(
      id: '5',
      title: 'Summer Tour',
      photoCount: 84,
      coverImage: 'https://picsum.photos/seed/summer-tour/600/600',
    ),
    PhotoAlbum(
      id: '6',
      title: 'Acoustic Sessions',
      photoCount: 26,
      coverImage: 'https://picsum.photos/seed/acoustic/600/600',
    ),
  ];

  void _onAlbumTapped(PhotoAlbum album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoAlbumDetailsScreen(album: album),
      ),
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
      drawerShadowsBackgroundColor: cs.onSurface.withOpacity(0.1),
      slideWidth: MediaQuery.of(context).size.width * 0.75,
      menuBackgroundColor: cs.surface,
      mainScreen: Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(
          backgroundColor: cs.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu_rounded, color: cs.onSurface),
            onPressed: () => _drawerController.toggle?.call(),
          ),
          title: Text(
            'Photo Gallery',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.more_vert_rounded, color: Colors.black),
            //   onPressed: () {},
            // ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6.h),
                Text(
                  'Browse Albums',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 14.h),

                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.only(bottom: 14.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 14.h,
                      // نفس إحساس الصورة: كارت أطول شوية
                      childAspectRatio: 0.78,
                    ),
                    itemCount: _albums.length,
                    itemBuilder: (context, index) {
                      final album = _albums[index];

                      return PhotoAlbumCard(
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
// Models
// ---------------------------------------------------------------------------
class PhotoAlbum {
  final String id;
  final String title;
  final int photoCount;
  final String coverImage;

  PhotoAlbum({
    required this.id,
    required this.title,
    required this.photoCount,
    required this.coverImage,
  });
}

// ---------------------------------------------------------------------------
// Card (مطابق للصورة)
// ---------------------------------------------------------------------------
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
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: CachedNetworkImage(
                  imageUrl: album.coverImage,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[200]),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 4.h),

          // Photos count (orange)
          Text(
            '${album.photoCount} Photos',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}