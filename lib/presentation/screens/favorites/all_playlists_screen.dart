import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../playlist/create_playlist_screen.dart';
import '../playlist/playlist_details_screen.dart';
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
      title: 'Vibe Check',
      songCount: 24,
      coverImage: 'https://picsum.photos/seed/favorites-playlist/400/400',
      isPublic: false,
      date: 'Updated today',
    ),
    Playlist(
      id: '2',
      title: 'Sunset Beats',
      songCount: 18,
      coverImage: 'https://picsum.photos/seed/workout-mix/400/400',
      isPublic: true,
      date: '2 days ago',
    ),
    Playlist(
      id: '3',
      title: 'Deep Focus',
      songCount: 42,
      coverImage: 'https://picsum.photos/seed/sunday-chill/400/400',
      isPublic: false,
      date: '1 week ago',
    ),
    Playlist(
      id: '4',
      title: 'Morning Coffee',
      songCount: 12,
      coverImage: 'https://picsum.photos/seed/road-trip/400/400',
      isPublic: true,
      date: '2 weeks ago',
    ),
    Playlist(
      id: '5',
      title: 'Road Trip',
      songCount: 56,
      coverImage: 'https://picsum.photos/seed/study-session/400/400',
      isPublic: false,
      date: '3 weeks ago',
    ),
    Playlist(
      id: '6',
      title: 'Chill Mix',
      songCount: 31,
      coverImage: 'https://picsum.photos/seed/party-hits/400/400',
      isPublic: true,
      date: '1 month ago',
    ),
  ];

  // void _onBottomNavTapped removed

  void _onSearchTapped() {
    // TODO: Navigate to search screen
    print('Search tapped');
  }

  void _onCreatePlaylistTapped() async {
    final newPlaylist = await Navigator.of(context).push<Playlist>(
      MaterialPageRoute(
        builder: (context) => const CreatePlaylistScreen(),
      ),
    );
    
    if (newPlaylist != null) {
      setState(() {
        _playlists.insert(0, newPlaylist);
      });
    }
  }

  void _onPlaylistTapped(Playlist playlist) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaylistDetailsScreen(
          playlistId: playlist.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'All Playlists',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _onSearchTapped,
            icon: Icon(Icons.search, color: cs.onSurface),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search your playlists',
                    hintStyle: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.4),
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(Icons.search, color: cs.onSurface.withValues(alpha: 0.4), size: 20.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Playlists grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int cols = 2;
                  if (constraints.maxWidth >= 1024) cols = 4;
                  else if (constraints.maxWidth >= 600) cols = 3;
                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 24.h,
                      childAspectRatio: 0.75, // Adjust for image taking more space
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreatePlaylistTapped,
        backgroundColor: const Color(0xFFF36A31), // Orange from design
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r), // Highly rounded corners
                image: DecorationImage(
                  image: NetworkImage(playlist.coverImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Playlist info (Title strictly, song count slightly lighter)
          Text(
            playlist.title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: 4.h),
          
          Text(
            '${playlist.songCount} songs',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
