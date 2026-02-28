import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class ArtistDetailsScreen extends StatefulWidget {
  final String artistId;
  
  const ArtistDetailsScreen({
    super.key,
    required this.artistId,
  });

  @override
  State<ArtistDetailsScreen> createState() => _ArtistDetailsScreenState();
}

class _ArtistDetailsScreenState extends State<ArtistDetailsScreen> {
  bool _isFollowing = false;
  bool _isPlaying = false;

  final Artist _artist = Artist(
    id: '1',
    name: 'The Weeknd',
    image: 'https://picsum.photos/seed/the-weeknd/400/400',
    followers: '12.5M',
    monthlyListeners: '45.2M',
    verified: true,
    description: 'Abel Tesfaye, known professionally as The Weeknd, is a Canadian singer, songwriter, and record producer. Known for his dark R&B music and distinctive vocal style.',
    genres: ['R&B', 'Pop', 'Alternative'],
  );

  final List<Album> _albums = [
    Album(
      id: '1',
      title: 'After Hours',
      year: '2020',
      coverImage: 'https://picsum.photos/seed/after-hours/200/200',
      songCount: 14,
    ),
    Album(
      id: '2',
      title: 'Dawn FM',
      year: '2022',
      coverImage: 'https://picsum.photos/seed/dawn-fm/200/200',
      songCount: 16,
    ),
    Album(
      id: '3',
      title: 'Starboy',
      year: '2016',
      coverImage: 'https://picsum.photos/seed/starboy/200/200',
      songCount: 18,
    ),
    Album(
      id: '4',
      title: 'Beauty Behind the Madness',
      year: '2015',
      coverImage: 'https://picsum.photos/seed/beauty-madness/200/200',
      songCount: 13,
    ),
  ];

  final List<Song> _popularSongs = [
    Song(
      id: '1',
      title: 'Blinding Lights',
      album: 'After Hours',
      duration: '3:20',
      plays: '3.2B',
      coverImage: 'https://picsum.photos/seed/blinding-lights/60/60',
    ),
    Song(
      id: '2',
      title: 'Save Your Tears',
      album: 'After Hours',
      duration: '3:35',
      plays: '2.8B',
      coverImage: 'https://picsum.photos/seed/save-tears/60/60',
    ),
    Song(
      id: '3',
      title: 'Starboy',
      album: 'Starboy',
      duration: '3:50',
      plays: '2.5B',
      coverImage: 'https://picsum.photos/seed/starboy-song/60/60',
    ),
    Song(
      id: '4',
      title: 'Can\'t Feel My Face',
      album: 'Beauty Behind the Madness',
      duration: '3:30',
      plays: '2.1B',
      coverImage: 'https://picsum.photos/seed/cant-feel-face/60/60',
    ),
    Song(
      id: '5',
      title: 'The Hills',
      album: 'Beauty Behind the Madness',
      duration: '4:02',
      plays: '1.9B',
      coverImage: 'https://picsum.photos/seed/the-hills/60/60',
    ),
  ];

  void _onFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    // TODO: Follow/unfollow artist
    print('Follow artist: $_isFollowing');
  }

  void _onPlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // TODO: Play artist's popular songs
    print('Play artist: $_isPlaying');
  }

  void _onAlbumTapped(Album album) {
    // TODO: Navigate to album details
    print('Tapped album: ${album.title}');
  }

  void _onSongTapped(Song song) {
    // TODO: Navigate to player or play song
    print('Playing song: ${song.title}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with artist image
          SliverAppBar(
            expandedHeight: 350.h,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: cs.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Share artist
                  print('Share artist');
                },
                icon: Icon(Icons.share, color: cs.onSurface),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Artist image
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_artist.image),
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
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Artist info
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Artist name and verified badge
                  Row(
                    children: [
                      Text(
                        _artist.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ).animate().fadeIn(
                        duration: AppConstants.defaultAnimationDuration,
                        delay: const Duration(milliseconds: 200),
                      ),
                      if (_artist.verified) ...[
                        SizedBox(width: AppConstants.smallSpacing.w),
                        Icon(
                          Icons.verified,
                          color: cs.primary,
                          size: 24.w,
                        ).animate().fadeIn(
                          duration: AppConstants.defaultAnimationDuration,
                          delay: const Duration(milliseconds: 400),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: AppConstants.smallSpacing.h),

                  // Stats
                  Row(
                    children: [
                      Text(
                        '${_artist.followers} followers',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(width: AppConstants.largeSpacing.w),
                      Text(
                        '${_artist.monthlyListeners} monthly listeners',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 600),
                  ),

                  SizedBox(height: AppConstants.mediumSpacing.h),

                  // Genres
                  Wrap(
                    spacing: AppConstants.smallSpacing.w,
                    runSpacing: AppConstants.smallSpacing.h,
                    children: _artist.genres.map((genre) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.mediumSpacing.w,
                          vertical: AppConstants.smallSpacing.h,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
                        ),
                        child: Text(
                          genre,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 800),
                  ),

                  SizedBox(height: AppConstants.mediumSpacing.h),

                  // Description
                  Text(
                    _artist.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 1000),
                  ),

                  SizedBox(height: AppConstants.largeSpacing.h),

                  // Action buttons
                  Row(
                    children: [
                      // Play button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _onPlay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
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
                          delay: const Duration(milliseconds: 1200),
                          curve: Curves.easeOut,
                        ),
                      ),

                      SizedBox(width: AppConstants.mediumSpacing.w),

                      // Follow button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _onFollow,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: AppConstants.mediumSpacing.h),
                          ),
                          child: Text(
                            _isFollowing ? 'Following' : 'Follow',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate().scale(
                          duration: AppConstants.defaultAnimationDuration,
                          delay: const Duration(milliseconds: 1400),
                          curve: Curves.easeOut,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppConstants.extraLargeSpacing.h),

                  // Popular songs header
                  Text(
                    'Popular Songs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 1600),
                  ),
                ],
              ),
            ),
          ),

          // Popular songs list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = _popularSongs[index];
                return PopularSongTile(
                  song: song,
                  onTap: () => _onSongTapped(song),
                  index: index + 1,
                ).animate().slideX(
                  duration: AppConstants.defaultAnimationDuration,
                  delay: Duration(milliseconds: 1800 + (index * 100)),
                  begin: -0.2,
                  curve: Curves.easeOut,
                );
              },
              childCount: _popularSongs.length,
            ),
          ),

          // Albums section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppConstants.largeSpacing.h),
                  Text(
                    'Albums',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 2300),
                  ),
                  SizedBox(height: AppConstants.mediumSpacing.h),
                ],
              ),
            ),
          ),

          // Albums grid
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.mediumSpacing.r),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.mediumSpacing.w,
                mainAxisSpacing: AppConstants.mediumSpacing.h,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final album = _albums[index];
                  return AlbumCard(
                    album: album,
                    onTap: () => _onAlbumTapped(album),
                  ).animate().scale(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: Duration(milliseconds: 2400 + (index * 100)),
                    curve: Curves.easeOut,
                  );
                },
                childCount: _albums.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Artist {
  final String id;
  final String name;
  final String image;
  final String followers;
  final String monthlyListeners;
  final bool verified;
  final String description;
  final List<String> genres;

  Artist({
    required this.id,
    required this.name,
    required this.image,
    required this.followers,
    required this.monthlyListeners,
    required this.verified,
    required this.description,
    required this.genres,
  });
}

class Album {
  final String id;
  final String title;
  final String year;
  final String coverImage;
  final int songCount;

  Album({
    required this.id,
    required this.title,
    required this.year,
    required this.coverImage,
    required this.songCount,
  });
}

class Song {
  final String id;
  final String title;
  final String album;
  final String duration;
  final String plays;
  final String coverImage;

  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.duration,
    required this.plays,
    required this.coverImage,
  });
}

class PopularSongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final int index;

  const PopularSongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.all(AppConstants.mediumSpacing.r),
      leading: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius.r),
          image: DecorationImage(
            image: NetworkImage(song.coverImage),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        song.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.plays} plays • ${song.duration}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          color: cs.primary,
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
      onTap: onTap,
    );
  }
}

class AlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;

  const AlbumCard({
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
          color: Theme.of(context).colorScheme.surface,
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppConstants.extraSmallSpacing.h),

                    Text(
                      '${album.year} • ${album.songCount} songs',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
