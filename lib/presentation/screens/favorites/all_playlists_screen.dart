import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class AllPlaylistsScreen extends StatefulWidget {
  const AllPlaylistsScreen({super.key});

  @override
  State<AllPlaylistsScreen> createState() => _AllPlaylistsScreenState();
}

class _AllPlaylistsScreenState extends State<AllPlaylistsScreen> {
  int _selectedIndex = 4; // Profile is selected

  final List<Playlist> _playlists = [
    Playlist(
      id: '1',
      title: 'My Favorites',
      songCount: 24,
      coverImage: 'https://picsum.photos/seed/favorites-playlist/200/200',
      isPublic: false,
      date: 'Updated today',
    ),
    Playlist(
      id: '2',
      title: 'Workout Mix',
      songCount: 18,
      coverImage: 'https://picsum.photos/seed/workout-mix/200/200',
      isPublic: true,
      date: '2 days ago',
    ),
    Playlist(
      id: '3',
      title: 'Sunday Chill',
      songCount: 32,
      coverImage: 'https://picsum.photos/seed/sunday-chill/200/200',
      isPublic: false,
      date: '1 week ago',
    ),
    Playlist(
      id: '4',
      title: 'Road Trip',
      songCount: 45,
      coverImage: 'https://picsum.photos/seed/road-trip/200/200',
      isPublic: true,
      date: '2 weeks ago',
    ),
    Playlist(
      id: '5',
      title: 'Study Session',
      songCount: 12,
      coverImage: 'https://picsum.photos/seed/study-session/200/200',
      isPublic: false,
      date: '3 weeks ago',
    ),
    Playlist(
      id: '6',
      title: 'Party Hits',
      songCount: 67,
      coverImage: 'https://picsum.photos/seed/party-hits/200/200',
      isPublic: true,
      date: '1 month ago',
    ),
  ];

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Navigate to different screens
  }

  void _onSearchTapped() {
    // TODO: Navigate to search screen
    print('Search tapped');
  }

  void _onCreatePlaylistTapped() {
    // TODO: Navigate to create playlist screen
    print('Create playlist tapped');
  }

  void _onPlaylistTapped(Playlist playlist) {
    // TODO: Navigate to playlist details
    print('Tapped playlist: ${playlist.title}');
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
          'All Playlists',
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
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search playlists...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: AppConstants.mediumSpacing.h),

            // Playlists grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.mediumSpacing.w,
                  mainAxisSpacing: AppConstants.mediumSpacing.h,
                  childAspectRatio: 0.8,
                ),
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  final playlist = _playlists[index];
                  return PlaylistCard(
                    playlist: playlist,
                    onTap: () => _onPlaylistTapped(playlist),
                  ).animate().scale(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: Duration(milliseconds: index * 100),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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

class Playlist {
  final String id;
  final String title;
  final int songCount;
  final String coverImage;
  final bool isPublic;
  final String date;

  Playlist({
    required this.id,
    required this.title,
    required this.songCount,
    required this.coverImage,
    required this.isPublic,
    required this.date,
  });
}

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
          color: Colors.white,
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
            // Cover image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppConstants.mediumBorderRadius.r),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(playlist.coverImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            SizedBox(height: AppConstants.smallSpacing.h),

            // Playlist info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppConstants.extraSmallSpacing.h),
                    Row(
                      children: [
                        Text(
                          '${playlist.songCount} songs',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        if (playlist.isPublic)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppConstants.smallSpacing.w,
                              vertical: AppConstants.extraSmallSpacing.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(
                                AppConstants.smallBorderRadius.r,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.public,
                                  color: Colors.white,
                                  size: 16.w,
                                ),
                                SizedBox(width: AppConstants.extraSmallSpacing.w),
                                Text(
                                  'Public',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: AppConstants.mediumSpacing.h),
                    Text(
                      playlist.date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
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
