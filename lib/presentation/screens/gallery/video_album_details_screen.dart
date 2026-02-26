import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'video_gallery_screen.dart';

class VideoAlbumDetailsScreen extends StatelessWidget {
  final VideoAlbum album;

  const VideoAlbumDetailsScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    // Generate mock videos for the album
    final List<Map<String, dynamic>> videos = List.generate(
      album.videoCount,
      (index) => {
        'title': 'Video Title ${index + 1}',
        'date': 'March ${24 - (index % 10)}, 2024',
        'views': '${(index % 5) + 1}.${index % 9}k views',
        'duration': '${(index % 10) + 5}:${((index * 13) % 40) + 10}',
        'thumbnail': 'https://picsum.photos/seed/${album.title.replaceAll(' ', '')}-vid$index/600/350',
      },
    );

    // Some custom titles based on index for the mock
    if (videos.isNotEmpty) videos[0]['title'] = 'The Power of Faith';
    if (videos.length > 1) videos[1]['title'] = 'Walking Together';
    if (videos.length > 2) videos[2]['title'] = 'Songs of Praise 2024';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFFFF6B35), size: 20.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              album.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            Text(
              'VIDEO ALBUM',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  Text(
                    '${album.videoCount} VIDEOS',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: const Color(0xFFFF6B35),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          album.title,
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1A1D28),
                          ),
                        ),
                      ),
                      // Sort button
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(color: const Color(0xFFEFEFEF)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.swap_vert_rounded, size: 16.w, color: const Color(0xFFFF6B35)),
                              SizedBox(width: 6.w),
                              Text(
                                'Sort',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFFF6B35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
            
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 80.h),
                itemCount: videos.length,
                separatorBuilder: (context, index) => SizedBox(height: 24.h),
                itemBuilder: (context, index) {
                  final video = videos[index];
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlaybackMockScreen(video: video),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Thumbnail
                      Container(
                        height: 190.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: video['thumbnail'],
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(color: Colors.grey[200]),
                                errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                              
                              // Dark overlay
                              Container(color: Colors.black.withOpacity(0.2)),
                              
                              // Play Button
                              Center(
                                child: Container(
                                  width: 52.w,
                                  height: 52.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: const Color(0xFFFF6B35),
                                    size: 32.w,
                                  ),
                                ),
                              ),
                              
                              // Duration Chip
                              Positioned(
                                bottom: 12.h,
                                right: 12.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    video['duration'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 12.h),
                      
                      // Video Title
                      Text(
                        video['title'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A1D28),
                        ),
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Date and Views
                      Text(
                        '${video['date']} • ${video['views']}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    ),
                  ).animate().fadeIn(
                    duration: const Duration(milliseconds: 300),
                    delay: Duration(milliseconds: (index % 5) * 80),
                  ).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: const Duration(milliseconds: 300),
                    delay: Duration(milliseconds: (index % 5) * 80),
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
}

class VideoPlaybackMockScreen extends StatefulWidget {
  final Map<String, dynamic> video;

  const VideoPlaybackMockScreen({super.key, required this.video});

  @override
  State<VideoPlaybackMockScreen> createState() => _VideoPlaybackMockScreenState();
}

class _VideoPlaybackMockScreenState extends State<VideoPlaybackMockScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    // using a reliable sample video URL
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    );

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
        ),
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFFF6B35),
        handleColor: const Color(0xFFFF6B35),
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white54,
      ),
    );

    setState(() {
      _isInit = true;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(widget.video['title'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250.h,
            width: double.infinity,
            color: Colors.black,
            child: _isInit && _chewieController != null
                ? Chewie(controller: _chewieController!)
                : const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video['title'],
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1D28),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${widget.video['date']} • ${widget.video['views']}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Video Description',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1D28),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'This is a placeholder description for the video. In a real application, this space would contain details about the sermon, hymns, or event shown in the video, providing more context or links to related material.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


