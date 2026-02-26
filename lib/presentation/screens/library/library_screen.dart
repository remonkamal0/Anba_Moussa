import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<LibraryItem> _items = [
    LibraryItem(
      id: '1',
      title: 'Joy',
      year: '2020',
      imageUrl: 'https://picsum.photos/seed/joy/400/400',
      type: LibraryItemType.album,
    ),
    LibraryItem(
      id: '2',
      title: 'Chu',
      year: '2019',
      imageUrl: 'https://picsum.photos/seed/chu/400/400',
      type: LibraryItemType.album,
    ),
    LibraryItem(
      id: '3',
      title: 'To Y',
      year: '2023',
      imageUrl: 'https://picsum.photos/seed/toy/400/400',
      type: LibraryItemType.album,
    ),
    LibraryItem(
      id: '4',
      title: 'Salv',
      year: '2022',
      imageUrl: 'https://picsum.photos/seed/salv/400/400',
      type: LibraryItemType.album,
    ),
    LibraryItem(
      id: '5',
      title: 'New',
      year: '2024',
      imageUrl: 'https://picsum.photos/seed/newalbum/400/400',
      type: LibraryItemType.album,
    ),
  ];

  void _onItemTapped(LibraryItem item) {
    final params = Uri.encodeComponent;
    context.push(
      '/album/${item.id}'
          '?title=${params(item.title)}'
          '&imageUrl=${params(item.imageUrl)}'
          '&artist=${params("Various Artists")}'
          '&year=${params(item.year)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final gap = 12.w;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            final drawer = ZoomDrawer.of(context);
            if (drawer != null) drawer.toggle();
          },
        ),
        title: Text(
          'LIBARY',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: GridView.builder(
          itemCount: _items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            childAspectRatio: 1, // مربع زي الصورة
          ),
          itemBuilder: (context, index) {
            final item = _items[index];
            return _AlbumCard(
              item: item,
              onTap: () => _onItemTapped(item),
            )
                .animate()
                .fadeIn(
              duration: const Duration(milliseconds: 280),
              delay: Duration(milliseconds: index * 70),
              curve: Curves.easeOut,
            )
                .slideY(
              begin: 0.12,
              end: 0,
              duration: const Duration(milliseconds: 280),
              delay: Duration(milliseconds: index * 70),
              curve: Curves.easeOut,
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Album Card (مطابق للشكل المرسل)
// ---------------------------------------------------------------------------
class _AlbumCard extends StatelessWidget {
  final LibraryItem item;
  final VoidCallback onTap;

  const _AlbumCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),

            // Bottom capsule overlay
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Play button
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20.w,
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Title + Year
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            item.year,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------
class LibraryItem {
  final String id;
  final String title;
  final String year;
  final String imageUrl;
  final LibraryItemType type;

  LibraryItem({
    required this.id,
    required this.title,
    required this.year,
    required this.imageUrl,
    required this.type,
  });
}

enum LibraryItemType {
  album,
  playlist,
  artist,
}