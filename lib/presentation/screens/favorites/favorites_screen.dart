import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<FavoriteSong> _favoriteSongs = [
    FavoriteSong(
      id: '1',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      isLiked: true,
      albumArtUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&q=80',
    ),
    FavoriteSong(
      id: '2',
      title: 'Stay',
      artist: 'The Kid LAROI & Justin Bieber',
      isLiked: true,
      albumArtUrl: 'https://images.unsplash.com/photo-1493225457124-b049d107fb7f?w=400&q=80',
    ),
    FavoriteSong(
      id: '3',
      title: 'Levitating',
      artist: 'Dua Lipa',
      isLiked: true,
      albumArtUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&q=80',
    ),
    FavoriteSong(
      id: '4',
      title: 'Bad Habits',
      artist: 'Ed Sheeran',
      isLiked: true,
      albumArtUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80',
    ),
    FavoriteSong(
      id: '5',
      title: 'Save Your Tears',
      artist: 'The Weeknd & Ariana Grande',
      isLiked: true,
      albumArtUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400&q=80',
    ),
    FavoriteSong(
      id: '6',
      title: 'Good 4 U',
      artist: 'Olivia Rodrigo',
      isLiked: true,
      albumArtUrl: 'https://images.unsplash.com/photo-1516280440502-a2fc978b7b20?w=400&q=80',
    ),
    FavoriteSong(
      id: '7',
      title: 'Heat Waves',
      artist: 'Glass Animals',
      isLiked: true,
      albumArtUrl: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Favorites',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: cs.onSurface, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action Buttons Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                      label: Text(
                        'Play All',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        elevation: 4,
                        shadowColor: cs.primary.withOpacity(0.5),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.shuffle_rounded, color: cs.primary, size: 20),
                      label: Text(
                        'Shuffle',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary.withValues(alpha: 0.1), // Lighter dynamic bg
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Liked Songs Count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: Text(
                '${_favoriteSongs.length} LIKED SONGS',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            
            // List of Favorite Songs
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                itemCount: _favoriteSongs.length,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final song = _favoriteSongs[index];
                  return Row(
                    children: [
                      // Circular Cover Art
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: song.albumArtUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 16.w),
                      
                      // Title and Artist
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              song.artist,
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
                      
                      // Action Icons (Like, Download, Play)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            color: cs.primary,
                            size: 20.w,
                          ),
                          SizedBox(width: 16.w),
                           Icon(
                            Icons.arrow_circle_down_rounded,
                            color: cs.onSurface.withValues(alpha: 0.3),
                            size: 22.w,
                          ),
                          SizedBox(width: 16.w),
                          Icon(
                            Icons.play_circle_outline_rounded,
                            color: cs.onSurface,
                            size: 24.w,
                          ),
                        ],
                      ),
                    ],
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

class FavoriteSong {
  final String id;
  final String title;
  final String artist;
  final bool isLiked;
  final String albumArtUrl;

  FavoriteSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.isLiked,
    required this.albumArtUrl,
  });
}
