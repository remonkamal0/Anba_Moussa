import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';

class AlbumDetailsScreen extends StatefulWidget {
  const AlbumDetailsScreen({super.key});

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  String _selectedCategory = 'Rock';

  final List<String> _categories = ['Rock', 'Pop', 'Chill', 'Jazz'];

  final Album _album = Album(
    id: '1',
    title: 'Island Getaway',
    artist: 'Olivia Lyric',
    coverImageUrl: 'https://picsum.photos/seed/violin/400/400',
    totalSongs: 12,
  );

  final List<Track> _tracks = [
    Track(
      id: '1',
      title: 'Sunset Boulevard',
      artist: 'Olivia Lyric',
      duration: '3:42',
      coverImageUrl: 'https://picsum.photos/seed/sunset/60/60',
    ),
    Track(
      id: '2',
      title: 'Waves of Ocean',
      artist: 'Olivia Lyric',
      duration: '4:15',
      coverImageUrl: 'https://picsum.photos/seed/waves/60/60',
    ),
    Track(
      id: '3',
      title: 'Golden Hour',
      artist: 'Olivia Lyric',
      duration: '3:28',
      coverImageUrl: 'https://picsum.photos/seed/golden/60/60',
    ),
    Track(
      id: '4',
      title: 'Midnight Dreams',
      artist: 'Olivia Lyric',
      duration: '4:02',
      coverImageUrl: 'https://picsum.photos/seed/midnight/60/60',
    ),
    Track(
      id: '5',
      title: 'Morning Coffee',
      artist: 'Olivia Lyric',
      duration: '3:15',
      coverImageUrl: 'https://picsum.photos/seed/morning/60/60',
    ),
    Track(
      id: '6',
      title: 'City Lights',
      artist: 'Olivia Lyric',
      duration: '3:55',
      coverImageUrl: 'https://picsum.photos/seed/city/60/60',
    ),
  ];

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onTrackTapped(Track track) {
    // TODO: Navigate to player
    print('Playing track: ${track.title}');
  }

  void _onPlayAll() {
    // TODO: Play all tracks
    print('Playing all tracks');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'ALBUM DETAILS',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album cover section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album cover
                Stack(
                  children: [
                    Container(
                      width: 160.w,
                      height: 160.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(_album.coverImageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ).animate().scale(
                      duration: AppConstants.defaultAnimationDuration,
                      curve: Curves.easeOut,
                    ),
                    // Floating play button
                    Positioned(
                      bottom: -10.w,
                      right: -10.w,
                      child: FloatingActionButton(
                        onPressed: _onPlayAll,
                        backgroundColor: const Color(0xFFFF6B35),
                        child: const Icon(Icons.play_arrow, color: Colors.white),
                      ).animate().fadeIn(
                        duration: AppConstants.defaultAnimationDuration,
                        delay: const Duration(milliseconds: 400),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: AppConstants.mediumSpacing.w),

                // Album info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppConstants.largeSpacing.h),
                      Text(
                        _album.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ).animate().fadeIn(
                        duration: AppConstants.defaultAnimationDuration,
                        delay: const Duration(milliseconds: 200),
                      ),

                      SizedBox(height: AppConstants.smallSpacing.h),

                      Text(
                        _album.artist,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ).animate().fadeIn(
                        duration: AppConstants.defaultAnimationDuration,
                        delay: const Duration(milliseconds: 400),
                      ),

                      SizedBox(height: AppConstants.smallSpacing.h),

                      Text(
                        '${_album.totalSongs} Songs',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ).animate().fadeIn(
                        duration: AppConstants.defaultAnimationDuration,
                        delay: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: AppConstants.extraLargeSpacing.h),

            // Categories section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all categories
                  },
                  child: Text(
                    'See All',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFFF6B35),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(
              duration: AppConstants.defaultAnimationDuration,
              delay: const Duration(milliseconds: 800),
            ),

            SizedBox(height: AppConstants.mediumSpacing.h),

            // Category pills
            SizedBox(
              height: 40.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: EdgeInsets.only(right: AppConstants.smallSpacing.w),
                    child: GestureDetector(
                      onTap: () => _onCategorySelected(category),
                      child: AnimatedContainer(
                        duration: AppConstants.defaultAnimationDuration,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.mediumSpacing.w,
                          vertical: AppConstants.smallSpacing.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: AppConstants.largeSpacing.h),

            // Tracks section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tracks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${_album.totalSongs} Songs',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ).animate().fadeIn(
              duration: AppConstants.defaultAnimationDuration,
              delay: const Duration(milliseconds: 1000),
            ),

            SizedBox(height: AppConstants.mediumSpacing.h),

            // Track list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tracks.length,
              itemBuilder: (context, index) {
                final track = _tracks[index];
                return TrackTile(
                  track: track,
                  onTap: () => _onTrackTapped(track),
                  index: index,
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: Duration(milliseconds: 1200 + (index * 100)),
                  begin: -0.2,
                  curve: Curves.easeOut,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  final int index;

  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppConstants.mediumSpacing.w,
        vertical: AppConstants.smallSpacing.h,
      ),
      leading: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius.r),
          image: DecorationImage(
            image: CachedNetworkImageProvider(track.coverImageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        track.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artist,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            track.duration,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: AppConstants.smallSpacing.w),
          IconButton(
            onPressed: () {
              // TODO: Play track
            },
            icon: Icon(
              Icons.play_arrow,
              color: Colors.grey[600],
              size: 20.w,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Toggle favorite
            },
            icon: Icon(
              Icons.favorite_border,
              color: Colors.grey[600],
              size: 20.w,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Download track
            },
            icon: Icon(
              Icons.download,
              color: Colors.grey[600],
              size: 20.w,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class Album {
  final String id;
  final String title;
  final String artist;
  final String coverImageUrl;
  final int totalSongs;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverImageUrl,
    required this.totalSongs,
  });
}

class Track {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final String coverImageUrl;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.coverImageUrl,
  });
}
