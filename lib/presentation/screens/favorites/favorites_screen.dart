import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedIndex = 3; // Profile is selected
  bool _isShuffled = false;
  bool _isPlayingAll = false;

  final List<Song> _favoriteSongs = [
    Song(
      id: '1',
      title: 'Midnight Dreams',
      artist: 'Luna Rose',
      album: 'Celestial',
      duration: '3:45',
      albumArtUrl: 'https://picsum.photos/seed/midnight-dreams/60/60',
      isLiked: true,
      isDownloaded: true,
    ),
    Song(
      id: '2',
      title: 'Ocean Waves',
      artist: 'Blue Horizon',
      album: 'Serenity',
      duration: '4:12',
      albumArtUrl: 'https://picsum.photos/seed/ocean-waves/60/60',
      isLiked: true,
      isDownloaded: false,
    ),
    Song(
      id: '3',
      title: 'Golden Hour',
      artist: 'Sunset Boulevard',
      album: 'Golden Memories',
      duration: '3:28',
      albumArtUrl: 'https://picsum.photos/seed/golden-hour/60/60',
      isLiked: false,
      isDownloaded: true,
    ),
    Song(
      id: '4',
      title: 'City Lights',
      artist: 'Urban Echo',
      album: 'Night Life',
      duration: '4:02',
      albumArtUrl: 'https://picsum.photos/seed/city-lights/60/60',
      isLiked: true,
      isDownloaded: false,
    ),
    Song(
      id: '5',
      title: 'Morning Coffee',
      artist: 'Cozy Vibes',
      album: 'Daily Rituals',
      duration: '3:15',
      albumArtUrl: 'https://picsum.photos/seed/morning-coffee/60/60',
      isLiked: false,
      isDownloaded: true,
    ),
    Song(
      id: '6',
      title: 'Summer Breeze',
      artist: 'Tropical Winds',
      album: 'Island Paradise',
      duration: '3:52',
      albumArtUrl: 'https://picsum.photos/seed/summer-breeze/60/60',
      isLiked: true,
      isDownloaded: false,
    ),
    Song(
      id: '7',
      title: 'Evening Serenade',
      artist: 'Moonlight Sonata',
      album: 'Dusk Melodies',
      duration: '4:18',
      albumArtUrl: 'https://picsum.photos/seed/evening-serenade/60/60',
      isLiked: false,
      isDownloaded: true,
    ),
    Song(
      id: '8',
      title: 'Sacred Hymns',
      artist: 'Angel Voices',
      album: 'Heavenly Choir',
      duration: '5:30',
      albumArtUrl: 'https://picsum.photos/seed/sacred-hymns/60/60',
      isLiked: true,
      isDownloaded: false,
    ),
  ];

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Navigate to different screens
  }

  void _onPlayAll() {
    setState(() {
      _isPlayingAll = !_isPlayingAll;
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

  void _onSongTapped(Song song) {
    // TODO: Navigate to player or play song
    print('Playing song: ${song.title}');
  }

  void _onSongLiked(Song song, bool isLiked) {
    // TODO: Toggle favorite status
    print('${isLiked ? "Liked" : "Unliked"} song: ${song.title}');
  }

  void _onSongDownloaded(Song song, bool isDownloaded) {
    // TODO: Toggle download status
    print('${isDownloaded ? "Downloaded" : "Removed"} song: ${song.title}');
  }

  void _onSearchTapped() {
    // TODO: Navigate to search screen
    print('Search tapped');
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
          'Favorites',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _onSearchTapped,
            icon: const Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Header with play controls
            Container(
              padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
              ),
              child: Row(
                children: [
                  Text(
                    '${_favoriteSongs.length} Songs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  // Play All button
                  ElevatedButton(
                    onPressed: _onPlayAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
                      ),
                    ),
                    child: Text(
                      _isPlayingAll ? 'Pause All' : 'Play All',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: AppConstants.smallSpacing.w),
                  // Shuffle button
                  IconButton(
                    onPressed: _onShuffle,
                    icon: Icon(
                      Icons.shuffle,
                      color: _isShuffled ? const Color(0xFFFF6B35) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppConstants.mediumSpacing.h),

            // Songs list
            Expanded(
              child: ListView.builder(
                itemCount: _favoriteSongs.length,
                itemBuilder: (context, index) {
                  final song = _favoriteSongs[index];
                  return FavoriteSongTile(
                    song: song,
                    onTap: () => _onSongTapped(song),
                    onLike: (isLiked) => _onSongLiked(song, isLiked),
                    onDownload: (isDownloaded) => _onSongDownloaded(song, isDownloaded),
                    index: index + 1,
                  ).animate().slideX(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: Duration(milliseconds: index * 100),
                    begin: -0.2,
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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF6B35),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_outlined),
            activeIcon: Icon(Icons.library_music),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            activeIcon: Icon(Icons.video_library),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class FavoriteSongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final Function(bool) onLike;
  final Function(bool) onDownload;
  final int index;

  const FavoriteSongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.onLike,
    required this.onDownload,
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
                '${index + 1}',
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

          // Download button
          IconButton(
            onPressed: () => onDownload(!song.isDownloaded),
            icon: Icon(
              song.isDownloaded ? Icons.download_done : Icons.download,
              color: song.isDownloaded ? Colors.green : Colors.grey[600],
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

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String duration;
  final String albumArtUrl;
  final bool isLiked;
  final bool isDownloaded;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.albumArtUrl,
    this.isLiked = false,
    this.isDownloaded = false,
  });
}
