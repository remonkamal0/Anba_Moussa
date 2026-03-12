import 'package:flutter/material.dart';
import 'video_album_details_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/common/app_drawer.dart';
import '../../../domain/entities/video_album.dart';
import '../../providers/video_provider.dart';
import '../../widgets/common/error_handle_widget.dart';

class VideoGalleryScreen extends ConsumerStatefulWidget {
  const VideoGalleryScreen({super.key});

  @override
  ConsumerState<VideoGalleryScreen> createState() => _VideoGalleryScreenState();
}

class _VideoGalleryScreenState extends ConsumerState<VideoGalleryScreen> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();
  String _sortOrder = 'A-Z'; // Default sort order

  void _onAlbumTapped(VideoAlbum album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoAlbumDetailsScreen(album: album),
      ),
    );
  }

  List<VideoAlbum> _sortAlbums(List<VideoAlbum> albums) {
    final sortedAlbums = List<VideoAlbum>.from(albums);
    final locale = Localizations.localeOf(context).languageCode;

    sortedAlbums.sort((a, b) {
      final titleA = a.getLocalizedTitle(locale).toLowerCase();
      final titleB = b.getLocalizedTitle(locale).toLowerCase();

      if (_sortOrder == 'A-Z') {
        return titleA.compareTo(titleB);
      } else {
        return titleB.compareTo(titleA);
      }
    });

    return sortedAlbums;
  }

  void _showSortOptions() {
    final locale = Localizations.localeOf(context).languageCode;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 100.w,
        MediaQuery.of(context).padding.top + 60.h,
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).padding.top + 200.h,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'A-Z',
          child: Row(
            children: [
              Radio<String>(
                value: 'A-Z',
                groupValue: _sortOrder,
                onChanged: (value) {
                  setState(() {
                    _sortOrder = value!;
                  });
                },
              ),
              SizedBox(width: 8.w),
              Text(
                locale == 'ar' ? 'من أ إلى ي' : 'A to Z',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Z-A',
          child: Row(
            children: [
              Radio<String>(
                value: 'Z-A',
                groupValue: _sortOrder,
                onChanged: (value) {
                  setState(() {
                    _sortOrder = value!;
                  });
                },
              ),
              SizedBox(width: 8.w),
              Text(
                locale == 'ar' ? 'من ي إلى أ' : 'Z to A',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onSortTapped() {
    _showSortOptions();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final albumsAsync = ref.watch(videoAlbumsProvider);

    return ZoomDrawer(
      controller: _drawerController,
      style: DrawerStyle.defaultStyle,
      menuScreen: const AppDrawer(),
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
            icon: Icon(Icons.menu_rounded, color: cs.primary, size: 22.w),
            onPressed: () => _drawerController.toggle?.call(),
          ),
          title: Text(
            locale == 'ar' ? 'معرض الفيديو' : 'Video Gallery',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Text(
                  locale == 'ar' ? 'جميع الألبومات' : 'ALL ALBUMS',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: cs.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                SizedBox(height: 14.h),
                Expanded(
                  child: albumsAsync.when(
                    data: (albums) {
                      if (albums.isEmpty) {
                        return Center(
                          child: Text(
                            locale == 'ar'
                                ? 'لا توجد ألبومات فيديو حالياً'
                                : 'No video albums found',
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.5),
                            ),
                          ),
                        );
                      }
                      final sortedAlbums = _sortAlbums(albums);
                      return RefreshIndicator(
                        onRefresh: () async =>
                            ref.refresh(videoAlbumsProvider),
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 14.h),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14.w,
                                mainAxisSpacing: 14.h,
                                childAspectRatio:
                                    0.72, // Balanced for 1:1 image + text
                              ),
                          itemCount: sortedAlbums.length,
                          itemBuilder: (context, index) {
                            final album = sortedAlbums[index];
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
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => ErrorHandleWidget(
                      error: error,
                      onRetry: () => ref.refresh(videoAlbumsProvider),
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
// Card (مطابق للصورة: play في النص + title + count برتقاني)
// ---------------------------------------------------------------------------
class VideoAlbumCard extends StatelessWidget {
  final VideoAlbum album;
  final VoidCallback onTap;

  const VideoAlbumCard({super.key, required this.album, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image with centered play button - Fixed 1:1 Aspect Ratio
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (album.coverImageUrl != null)
                      CachedNetworkImage(
                        imageUrl: album.coverImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey[100]),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey[100],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      Container(color: Colors.grey[100]),

                    // play button in center
                    Center(
                      child: Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: cs.primary,
                          size: 30.w,
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
