import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Home is selected

  // Mock data
  final UserProfile _user = UserProfile(
    name: 'Alex Johnson',
    email: 'alex.johnson@example.com',
    avatarUrl: 'https://picsum.photos/seed/alex-avatar/100/100',
  );

  final List<Category> _categories = [
    Category(id: '1', name: 'Jazz', icon: Icons.music_note, color: Colors.purple),
    Category(id: '2', name: 'Rock', icon: Icons.music_note, color: Colors.red),
    Category(id: '3', name: 'Pop', icon: Icons.headphones, color: Colors.blue),
    Category(id: '4', name: 'Classical', icon: Icons.piano, color: Colors.green),
  ];

  final List<Song> _topSongs = [
    Song(
      id: '1',
      title: 'Midnight Dreams',
      artist: 'Luna Rose',
      album: 'Celestial',
      duration: '3:45',
      rank: 1,
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
      rank: 2,
      albumArtUrl: 'https://picsum.photos/seed/ocean-waves/60/60',
      isLiked: false,
      isDownloaded: false,
    ),
    Song(
      id: '3',
      title: 'Golden Hour',
      artist: 'Sunset Boulevard',
      album: 'Golden Memories',
      duration: '3:28',
      rank: 3,
      albumArtUrl: 'https://picsum.photos/seed/golden-hour/60/60',
      isLiked: true,
      isDownloaded: true,
    ),
    Song(
      id: '4',
      title: 'City Lights',
      artist: 'Urban Echo',
      album: 'Night Life',
      duration: '4:02',
      rank: 4,
      albumArtUrl: 'https://picsum.photos/seed/city-lights/60/60',
      isLiked: false,
      isDownloaded: false,
    ),
    Song(
      id: '5',
      title: 'Morning Coffee',
      artist: 'Cozy Vibes',
      album: 'Daily Rituals',
      duration: '3:15',
      rank: 5,
      albumArtUrl: 'https://picsum.photos/seed/morning-coffee/60/60',
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

  void _onMenuTapped() {
    Scaffold.of(context).openDrawer();
  }

  void _onSearchTapped() {
    context.go('/search');
  }

  void _onNotificationTapped() {
    // TODO: Navigate to notifications
    print('Notifications tapped');
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

  void _onViewAllCategories() {
    // TODO: Navigate to all categories
    print('View all categories');
  }

  void _onViewAllSongs() {
    // TODO: Navigate to all songs
    print('View all songs');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.mediumSpacing.r,
                vertical: AppConstants.smallSpacing.h,
              ),
              child: Row(
                children: [
                  // Hamburger menu
                  IconButton(
                    onPressed: _onMenuTapped,
                    icon: const Icon(Icons.menu, color: Colors.black),
                  ),

                  // Profile picture and greeting
                  Expanded(
                    child: Row(
                      children: [
                        // Profile picture
                        CircleAvatar(
                          radius: 20.r,
                          backgroundImage: NetworkImage(_user.avatarUrl),
                        ).animate().scale(
                          duration: AppConstants.defaultAnimationDuration,
                          curve: Curves.easeOut,
                        ),

                        SizedBox(width: AppConstants.smallSpacing.w),

                        // Welcome message
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back,',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.black,
                                ),
                              ).animate().fadeIn(
                                duration: AppConstants.defaultAnimationDuration,
                                delay: const Duration(milliseconds: 200),
                              ),
                              
                              Text(
                                _user.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ).animate().fadeIn(
                                duration: AppConstants.defaultAnimationDuration,
                                delay: const Duration(milliseconds: 400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search icon
                  IconButton(
                    onPressed: _onSearchTapped,
                    icon: const Icon(Icons.search, color: Colors.black),
                  ),

                  // Notification bell
                  IconButton(
                    onPressed: _onNotificationTapped,
                    icon: const Icon(Icons.notifications_none, color: Colors.black),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured section
                    _buildFeaturedSection(),

                    SizedBox(height: AppConstants.largeSpacing.h),

                    // Categories section
                    _buildCategoriesSection(),

                    SizedBox(height: AppConstants.largeSpacing.h),

                    // Top 10 Songs section
                    _buildTopSongsSection(),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B35).withOpacity(0.1),
            const Color(0xFFFF6B35).withOpacity(0.05),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: _onViewAllCategories,
                  child: Text(
                    'VIEW ALL',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFFF6B35),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppConstants.mediumSpacing.h),

            // Featured album card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Album image
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppConstants.mediumBorderRadius.r),
                    ),
                    child: Image.network(
                      'https://picsum.photos/seed/rnb-soul-hits/400/200',
                      height: 200.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  SizedBox(height: AppConstants.mediumSpacing.h),

                  // Album info
                  Padding(
                    padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Album: R&B Soul Hits',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ).animate().fadeIn(
                          duration: AppConstants.defaultAnimationDuration,
                          delay: const Duration(milliseconds: 200),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().scale(
              duration: AppConstants.defaultAnimationDuration,
              curve: Curves.easeOut,
            ),
          ],
        ),
      ).animate().slideX(
        duration: AppConstants.defaultAnimationDuration,
        delay: const Duration(milliseconds: 200),
        begin: -0.2,
        curve: Curves.easeOut,
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: _onViewAllCategories,
              child: Text(
                'VIEW ALL',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFFF6B35),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: AppConstants.mediumSpacing.h),

        // Category pills
        SizedBox(
          height: 50.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Padding(
                padding: EdgeInsets.only(right: AppConstants.smallSpacing.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.mediumSpacing.w,
                    vertical: AppConstants.smallSpacing.h,
                  ),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        category.icon,
                        color: category.color,
                        size: 20.w,
                      ),
                      SizedBox(width: AppConstants.extraSmallSpacing.w),
                      Text(
                        category.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: category.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().slideX(
      duration: AppConstants.defaultAnimationDuration,
      delay: const Duration(milliseconds: 400),
      begin: -0.2,
      curve: Curves.easeOut,
    );
  }

  Widget _buildTopSongsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top 10 Songs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: _onViewAllSongs,
              child: Text(
                'VIEW ALL',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFFF6B35),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: AppConstants.mediumSpacing.h),

        // Song list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _topSongs.length,
          itemBuilder: (context, index) {
            final song = _topSongs[index];
            return SongTile(
              song: song,
              onTap: () => _onSongTapped(song),
              onLike: (isLiked) => _onSongLiked(song, isLiked),
              onDownload: (isDownloaded) => _onSongDownloaded(song, isDownloaded),
              rank: song.rank,
            ).animate().slideX(
              duration: AppConstants.defaultAnimationDuration,
              delay: Duration(milliseconds: 600 + (index * 100)),
              begin: -0.2,
              curve: Curves.easeOut,
            );
          },
        ),
      ],
    ).animate().slideX(
      duration: AppConstants.defaultAnimationDuration,
      delay: const Duration(milliseconds: 600),
      begin: -0.2,
      curve: Curves.easeOut,
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
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;

  UserProfile({
    required this.name,
    required this.email,
    required this.avatarUrl,
  });
}

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String duration;
  final int rank;
  final String albumArtUrl;
  final bool isLiked;
  final bool isDownloaded;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.rank,
    required this.albumArtUrl,
    this.isLiked = false,
    this.isDownloaded = false,
  });
}

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final Function(bool) onLike;
  final Function(bool) onDownload;
  final int rank;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.onLike,
    required this.onDownload,
    required this.rank,
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
                '$rank',
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
        ],
      ),
      onTap: onTap,
    );
  }
}
