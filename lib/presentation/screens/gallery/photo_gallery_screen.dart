import 'package:flutter/material.dart';
import 'photo_album_details_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../widgets/common/app_drawer.dart';
import '../../../domain/entities/photo_album.dart';
import '../../providers/gallery_provider.dart';

class PhotoGalleryScreen extends ConsumerStatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  ConsumerState<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends ConsumerState<PhotoGalleryScreen> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();

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
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final albumsAsync = ref.watch(photoAlbumsProvider);

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
          backgroundColor: cs.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.primary, size: 22.w),
            onPressed: () => _drawerController.toggle?.call(),
          ),
          title: Text(
            locale == 'ar' ? 'معرض الصور' : 'Photo Gallery',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert_rounded, color: cs.primary, size: 24.w),
              onPressed: () {},
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                Text(
                  locale == 'ar' ? 'تصفح الألبومات' : 'Browse Albums',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: 14.h),
                Expanded(
                  child: albumsAsync.when(
                    data: (albums) {
                      if (albums.isEmpty) {
                        return Center(
                          child: Text(
                            locale == 'ar' ? 'لا توجد ألبومات حالياً' : 'No albums found',
                            style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
                          ),
                        );
                      }
                      return GridView.builder(
                        padding: EdgeInsets.only(bottom: 14.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14.w,
                          mainAxisSpacing: 14.h,
                          childAspectRatio: 0.72, // Balanced for 1:1 image + text
                        ),
                        itemCount: albums.length,
                        itemBuilder: (context, index) {
                          final album = albums[index];

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
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Text(err.toString()),
                    ),
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
    final locale = Localizations.localeOf(context).languageCode;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image - Fixed 1:1 Aspect Ratio
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: album.coverImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: album.coverImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.grey[100]),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Title
          Flexible(
            child: Text(
              album.getLocalizedTitle(locale),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          if (album.getLocalizedSubtitle(locale) != null)
            Flexible(
              child: Text(
                album.getLocalizedSubtitle(locale)!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: cs.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}