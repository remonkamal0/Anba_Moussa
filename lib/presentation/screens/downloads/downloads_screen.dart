import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final List<DownloadedSong> _downloadedSongs = [
    DownloadedSong(
      id: '1',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      size: '8.2 MB',
      albumArtUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&q=80',
    ),
    DownloadedSong(
      id: '2',
      title: 'Save Your Tears',
      artist: 'The Weeknd',
      size: '7.5 MB',
      albumArtUrl: 'https://images.unsplash.com/photo-1493225457124-b049d107fb7f?w=400&q=80',
    ),
    DownloadedSong(
      id: '3',
      title: 'Levitating',
      artist: 'Dua Lipa',
      size: '6.0 MB',
      albumArtUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&q=80',
    ),
    DownloadedSong(
      id: '4',
      title: 'Starboy',
      artist: 'The Weeknd ft. Daft Punk',
      size: '9.1 MB',
      albumArtUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80',
    ),
    DownloadedSong(
      id: '5',
      title: 'Peaches',
      artist: 'Justin Bieber',
      size: '8.4 MB',
      albumArtUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400&q=80',
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
          'Downloads',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _downloadedSongs.clear();
              });
            },
            child: Text(
              'Delete All',
              style: TextStyle(
                color: cs.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Storage Info Container
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL STORAGE',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '1.2 GB',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w900,
                                color: cs.onSurface,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'used',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.normal,
                                color: cs.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Circular Progress
                    SizedBox(
                      height: 50.w,
                      width: 50.w,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: 0.65, // 65% used example
                            strokeWidth: 6.w,
                            backgroundColor: cs.primary.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // List of downloaded songs
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                itemCount: _downloadedSongs.length,
                separatorBuilder: (context, index) => SizedBox(height: 24.h),
                itemBuilder: (context, index) {
                  final song = _downloadedSongs[index];
                  return Row(
                    children: [
                      // Square Cover Art with drop shadow
                      Container(
                        width: 65.w,
                        height: 65.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: CachedNetworkImage(
                            imageUrl: song.albumArtUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 16.w),
                      
                      // Title, Artist, Size
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: TextStyle(
                                fontSize: 16.sp,
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
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: cs.primary, size: 14.w),
                                SizedBox(width: 4.w),
                                Text(
                                  song.size,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Play Button
                      InkWell(
                        onTap: () {},
                        child: Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28.w),
                        ),
                      ),
                      
                      SizedBox(width: 16.w),
                      
                      // Delete Icon
                      InkWell(
                        onTap: () {
                          setState(() {
                            _downloadedSongs.removeAt(index);
                          });
                        },
                        child: Icon(Icons.delete_outline_rounded, color: cs.onSurface.withValues(alpha: 0.3), size: 28.w),
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

class DownloadedSong {
  final String id;
  final String title;
  final String artist;
  final String size;
  final String albumArtUrl;

  DownloadedSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.size,
    required this.albumArtUrl,
  });
}
