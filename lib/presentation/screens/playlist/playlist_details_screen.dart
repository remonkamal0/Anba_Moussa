import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  final String playlistId;
  
  const PlaylistDetailsScreen({
    super.key,
    required this.playlistId,
  });

  @override
  State<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  bool _isPlaying = false;
  bool _isShuffled = false;
  bool _isLiked = false;

  final Playlist _playlist = Playlist(
    id: '1',
    title: 'Summer Vibes',
    description: 'Perfect summer playlist with upbeat tracks to keep you energized all season long',
    coverImage: 'https://picsum.photos/seed/summer-vibes/400/400',
    songCount: 24,
    duration: '1h 32m',
    creator: 'Alex Johnson',
    isPublic: true,
    createdDate: 'June 2024',
    likes: 156,
  );

  final List<Song> _songs = [
    Song(
      id: '1',
      title: 'Midnight Dreams',
      artist: 'Luna Rose',
      album: 'Celestial',
      duration: '3:45',
      albumArtUrl: 'https://picsum.photos/seed/midnight-dreams/60/60',
      isLiked: true,
    ),
    Song(
      id: '2',
      title: 'Ocean Waves',
      artist: 'Blue Horizon',
      album: 'Serenity',
      duration: '4:12',
      albumArtUrl: 'https://picsum.photos/seed/ocean-waves/60/60',
      isLiked: false,
    ),
    Song(
      id: '3',
      title: 'Golden Hour',
      artist: 'Sunset Boulevard',
      album: 'Golden Memories',
      duration: '3:28',
      albumArtUrl: 'https://picsum.photos/seed/golden-hour/60/60',
      isLiked: true,
    ),
    Song(
      id: '4',
      title: 'Summer Breeze',
      artist: 'Tropical Winds',
      album: 'Island Paradise',
      duration: '3:52',
      albumArtUrl: 'https://picsum.photos/seed/summer-breeze/60/60',
      isLiked: false,
    ),
    Song(
      id: '5',
      title: 'Beach Days',
      artist: 'Coastal Vibes',
      album: 'Ocean Dreams',
      duration: '4:05',
      albumArtUrl: 'https://picsum.photos/seed/beach-days/60/60',
      isLiked: true,
    ),
    Song(
      id: '6',
      title: 'Sunset Drive',
      artist: 'Evening Groove',
      album: 'Twilight Sessions',
      duration: '3:18',
      albumArtUrl: 'https://picsum.photos/seed/sunset-drive/60/60',
      isLiked: false,
    ),
  ];

  void _onPlayAll() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // TODO: Play all songs
    print('Play all songs');
  }

  void _onShuffle() {
    setState(() {
      _isShuffled = !_isShuffled;
    });
    // TODO: Toggle shuffle mode
    print('Toggle shuffle: $_isShuffled');
  }

  void _onLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    // TODO: Like/unlike playlist
    print('Like playlist: $_isLiked');
  }

  void _onDownload() {
    // TODO: Download playlist
    print('Download playlist');
  }

  void _onShare() {
    // TODO: Share playlist
    print('Share playlist');
  }

  void _onSongTapped(Song song) {
    // TODO: Navigate to player or play song
    print('Playing song: ${song.title}');
  }

  void _onSongLiked(Song song, bool isLiked) {
    // TODO: Toggle favorite status
    print('${isLiked ? "Liked" : "Unliked"} song: ${song.title}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App bar with cover image
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                onPressed: _onShare,
                icon: const Icon(Icons.share, color: Colors.black),
              ),
              IconButton(
                onPressed: _onDownload,
                icon: const Icon(Icons.download, color: Colors.black),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Cover image
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_playlist.coverImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Playlist info
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and creator
                  Text(
                    _playlist.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 200),
                  ),

                  SizedBox(height: AppConstants.smallSpacing.h),

                  Row(
                    children: [
                      Text(
                        'by ${_playlist.creator}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_playlist.isPublic) ...[
                        SizedBox(width: AppConstants.smallSpacing.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppConstants.smallSpacing.w,
                            vertical: AppConstants.extraSmallSpacing.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius.r),
                          ),
                          child: Text(
                            'Public',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 400),
                  ),

                  SizedBox(height: AppConstants.mediumSpacing.h),

                  // Description
                  Text(
                    _playlist.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 600),
                  ),

                  SizedBox(height: AppConstants.mediumSpacing.h),

                  // Stats
                  Row(
                    children: [
                      Text(
                        '${_playlist.songCount} songs',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: AppConstants.mediumSpacing.w),
                      Text(
                        _playlist.duration,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: AppConstants.mediumSpacing.w),
                      Text(
                        '${_playlist.likes} likes',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 800),
                  ),

                  SizedBox(height: AppConstants.largeSpacing.h),

                  // Action buttons
                  Row(
                    children: [
                      // Play button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _onPlayAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: AppConstants.mediumSpacing.h),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 24.w,
                              ),
                              SizedBox(width: AppConstants.smallSpacing.w),
                              Text(
                                _isPlaying ? 'Pause' : 'Play',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(
                          duration: AppConstants.defaultAnimationDuration,
                          delay: const Duration(milliseconds: 1000),
                          curve: Curves.easeOut,
                        ),
                      ),

                      SizedBox(width: AppConstants.mediumSpacing.w),

                      // Shuffle button
                      IconButton(
                        onPressed: _onShuffle,
                        icon: Icon(
                          Icons.shuffle,
                          color: _isShuffled ? const Color(0xFFFF6B35) : Colors.grey[600],
                          size: 24.w,
                        ),
                      ).animate().scale(
                        duration: AppConstants.defaultAnimationDuration,
                        delay: const Duration(milliseconds: 1200),
                        curve: Curves.easeOut,
                      ),

                      // Like button
                      IconButton(
                        onPressed: _onLike,
                        icon: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : Colors.grey[600],
                          size: 24.w,
                        ),
                      ).animate().scale(
                        duration: AppConstants.defaultAnimationDuration,
                        delay: const Duration(milliseconds: 1400),
                        curve: Curves.easeOut,
                      ),
                    ],
                  ),

                  SizedBox(height: AppConstants.largeSpacing.h),

                  // Songs header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Songs',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Download all',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 1600),
                  ),
                ],
              ),
            ),
          ),

          // Songs list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = _songs[index];
                return PlaylistSongTile(
                  song: song,
                  onTap: () => _onSongTapped(song),
                  onLike: (isLiked) => _onSongLiked(song, isLiked),
                  index: index + 1,
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: Duration(milliseconds: 1800 + (index * 100)),
                  begin: -0.2,
                  curve: Curves.easeOut,
                );
              },
              childCount: _songs.length,
            ),
          ),
        ],
      ),
    );
  }
}

class Playlist {
  final String id;
  final String title;
  final String description;
  final String coverImage;
  final int songCount;
  final String duration;
  final String creator;
  final bool isPublic;
  final String createdDate;
  final int likes;

  Playlist({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.songCount,
    required this.duration,
    required this.creator,
    required this.isPublic,
    required this.createdDate,
    required this.likes,
  });
}

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String duration;
  final String albumArtUrl;
  final bool isLiked;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.albumArtUrl,
    this.isLiked = false,
  });
}

class PlaylistSongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final Function(bool) onLike;
  final int index;

  const PlaylistSongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.onLike,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(AppConstants.mediumSpacing.r),
      leading: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius.r),
          image: DecorationImage(
            image: NetworkImage(song.albumArtUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        song.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist} • ${song.album}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rank badge
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(width: AppConstants.smallSpacing.w),

          // Duration
          Text(
            song.duration,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),

          SizedBox(width: AppConstants.smallSpacing.w),

          // Like button
          IconButton(
            onPressed: () => onLike(!song.isLiked),
            icon: Icon(
              song.isLiked ? Icons.favorite : Icons.favorite_border,
              color: song.isLiked ? Colors.red : Colors.grey[600],
              size: 20.w,
            ),
          ),

          // Play button
          IconButton(
            onPressed: () {
              // TODO: Play song
              print('Play song: ${song.title}');
            },
            icon: const Icon(Icons.play_arrow, color: Colors.black),
            iconSize: 24.w,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
