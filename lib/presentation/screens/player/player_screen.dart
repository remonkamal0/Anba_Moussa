import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';

class PlayerScreen extends StatefulWidget {
  final String? trackId;

  const PlayerScreen({super.key, this.trackId});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isPlaying = false;
  bool _isFavorite = false;
  bool _isDownloaded = false;
  bool _isShuffled = false;
  bool _isRepeating = false;
  double _currentPosition = 45.0; // 00:45 in seconds
  double _totalDuration = 230.0; // 03:50 in seconds
  double _volume = 0.7;

  final Track _currentTrack = Track(
    id: '1',
    title: 'Have you',
    artist: 'Madihu, Low G',
    album: "Madihu's best songs",
    coverImageUrl: 'https://picsum.photos/seed/cityscape/400/400',
    duration: '3:50',
  );

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _toggleDownload() {
    setState(() {
      _isDownloaded = !_isDownloaded;
    });
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffled = !_isShuffled;
    });
  }

  void _toggleRepeat() {
    setState(() {
      _isRepeating = !_isRepeating;
    });
  }

  void _onPrevious() {
    // TODO: Implement previous track
    print('Previous track');
  }

  void _onNext() {
    // TODO: Implement next track
    print('Next track');
  }

  void _onSeek(double value) {
    setState(() {
      _currentPosition = value;
    });
  }

  void _onVolumeChanged(double value) {
    setState(() {
      _volume = value;
    });
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.round());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top padding
            SizedBox(height: AppConstants.mediumSpacing.h),

            // Album art and info
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.largeSpacing.r),
                child: Column(
                  children: [
                    // Album art with orange ring
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 300,
                        maxHeight: 300,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Orange ring
                          Container(
                            width: 280.w,
                            height: 280.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFF6B35),
                                width: 4.w,
                              ),
                            ),
                          ),
                          // Album art
                          Container(
                            width: 260.w,
                            height: 260.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(_currentTrack.coverImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(
                      duration: AppConstants.defaultAnimationDuration,
                      curve: Curves.easeOut,
                    ),

                    SizedBox(height: AppConstants.largeSpacing.h),

                    // Track info
                    Column(
                      children: [
                        Text(
                          _currentTrack.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(
                          duration: AppConstants.defaultAnimationDuration,
                          delay: const Duration(milliseconds: 200),
                        ),

                        SizedBox(height: AppConstants.smallSpacing.h),

                        Text(
                          '${_currentTrack.artist} • ${_currentTrack.album}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(
                          duration: AppConstants.defaultAnimationDuration,
                          delay: const Duration(milliseconds: 400),
                        ),

                        SizedBox(height: AppConstants.mediumSpacing.h),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Download button
                            IconButton(
                              onPressed: _toggleDownload,
                              icon: Icon(
                                _isDownloaded ? Icons.download_done : Icons.download,
                                color: Colors.grey[700],
                                size: 24.w,
                              ),
                            ).animate().fadeIn(
                              duration: AppConstants.defaultAnimationDuration,
                              delay: const Duration(milliseconds: 600),
                            ),

                            SizedBox(width: AppConstants.largeSpacing.w),

                            // Favorite button
                            IconButton(
                              onPressed: _toggleFavorite,
                              icon: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.grey[700],
                                size: 24.w,
                              ),
                            ).animate().fadeIn(
                              duration: AppConstants.defaultAnimationDuration,
                              delay: const Duration(milliseconds: 800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Progress section
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.largeSpacing.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Progress bar
                    Row(
                      children: [
                        Icon(
                          Icons.volume_down,
                          color: Colors.grey[600],
                          size: 20.w,
                        ),
                        SizedBox(width: AppConstants.smallSpacing.w),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                              trackHeight: 4.h,
                              activeTrackColor: const Color(0xFFFF6B35),
                              inactiveTrackColor: Colors.grey[300],
                              thumbColor: const Color(0xFFFF6B35),
                            ),
                            child: Slider(
                              value: _currentPosition,
                              max: _totalDuration,
                              onChanged: _onSeek,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppConstants.smallSpacing.h),

                    // Time labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_currentPosition),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          _formatDuration(_totalDuration),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Control buttons
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.largeSpacing.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle
                        IconButton(
                          onPressed: _toggleShuffle,
                          icon: Icon(
                            Icons.shuffle,
                            color: _isShuffled ? const Color(0xFFFF6B35) : Colors.grey[600],
                            size: 24.w,
                          ),
                        ),

                        // Previous
                        IconButton(
                          onPressed: _onPrevious,
                          icon: Icon(
                            Icons.skip_previous,
                            color: Colors.black,
                            size: 32.w,
                          ),
                        ),

                        // Play/Pause
                        Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _togglePlayPause,
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32.w,
                            ),
                          ),
                        ),

                        // Next
                        IconButton(
                          onPressed: _onNext,
                          icon: Icon(
                            Icons.skip_next,
                            color: Colors.black,
                            size: 32.w,
                          ),
                        ),

                        // Repeat
                        IconButton(
                          onPressed: _toggleRepeat,
                          icon: Icon(
                            Icons.repeat,
                            color: _isRepeating ? const Color(0xFFFF6B35) : Colors.grey[600],
                            size: 24.w,
                          ),
                        ),
                      ],
                    ),
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
        currentIndex: 1, // Library is selected
        onTap: (index) {
          // TODO: Navigate to different screens
        },
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

class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String coverImageUrl;
  final String duration;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.coverImageUrl,
    required this.duration,
  });
}
