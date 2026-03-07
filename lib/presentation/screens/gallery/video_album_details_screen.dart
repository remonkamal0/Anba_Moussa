import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../domain/entities/video_album.dart';
import '../../../domain/entities/video.dart';
import '../../providers/video_provider.dart';
import '../../widgets/common/error_handle_widget.dart';

class VideoAlbumDetailsScreen extends ConsumerStatefulWidget {
  final VideoAlbum album;

  const VideoAlbumDetailsScreen({super.key, required this.album});

  @override
  ConsumerState<VideoAlbumDetailsScreen> createState() => _VideoAlbumDetailsScreenState();
}

class _VideoAlbumDetailsScreenState extends ConsumerState<VideoAlbumDetailsScreen> {
  String _sortOrder = 'A-Z';

  List<Video> _sortVideos(List<Video> videos, String sortOrder, String locale) {
    final sortedVideos = List<Video>.from(videos);
    
    sortedVideos.sort((a, b) {
      final titleA = a.getLocalizedTitle(locale).toLowerCase();
      final titleB = b.getLocalizedTitle(locale).toLowerCase();
      
      if (sortOrder == 'A-Z') {
        return titleA.compareTo(titleB);
      } else {
        return titleB.compareTo(titleA);
      }
    });
    
    return sortedVideos;
  }

  void _showSortOptions() {
    final locale = Localizations.localeOf(context).languageCode;
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 100.w,
        MediaQuery.of(context).padding.top + 60.h,
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).padding.top + 200.h,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'A-Z',
          child: Row(
            children: [
              Radio<String>(
                value: 'A-Z',
                groupValue: _sortOrder,
                onChanged: (value) {
                  setState(() {
                    _sortOrder = value!;
                  });
                },
              ),
              SizedBox(width: 8.w),
              Text(
                locale == 'ar' ? 'من أ إلى ي' : 'A to Z',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Z-A',
          child: Row(
            children: [
              Radio<String>(
                value: 'Z-A',
                groupValue: _sortOrder,
                onChanged: (value) {
                  setState(() {
                    _sortOrder = value!;
                  });
                },
              ),
              SizedBox(width: 8.w),
              Text(
                locale == 'ar' ? 'من ي إلى أ' : 'Z to A',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final videosAsync = ref.watch(albumVideosProvider(widget.album.id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.primary, size: 20.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.album.getLocalizedTitle(locale),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [],
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
                  SizedBox(height: 4.h),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
            Expanded(
              child: videosAsync.when(
                data: (videos) {
                  if (videos.isEmpty) {
                    return Center(
                      child: Text(
                        locale == 'ar' ? 'لا توجد فيديوهات في هذا الألبوم' : 'No videos in this album',
                        style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
                      ),
                    );
                  }
                  final sortedVideos = _sortVideos(videos, _sortOrder, locale);
                  return ListView.separated(
                    padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 80.h),
                    itemCount: sortedVideos.length,
                    separatorBuilder: (context, index) => SizedBox(height: 24.h),
                    itemBuilder: (context, index) {
                      final video = sortedVideos[index];

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
                                    if (video.thumbnailUrl != null)
                                      CachedNetworkImage(
                                        imageUrl: video.thumbnailUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(color: Colors.grey[200]),
                                        errorWidget: (_, __, ___) => Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      )
                                    else
                                      Container(color: Colors.grey[200], child: Icon(Icons.video_library_rounded, color: cs.primary.withOpacity(0.2), size: 50.w)),
                                    Container(color: Colors.black.withOpacity(0.2)),
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
                                          color: cs.primary,
                                          size: 32.w,
                                        ),
                                      ),
                                    ),
                                    if (video.durationSeconds != null)
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
                                            '${(video.durationSeconds! ~/ 60)}:${(video.durationSeconds! % 60).toString().padLeft(2, '0')}',
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
                            Text(
                              video.getLocalizedTitle(locale),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: cs.onSurface,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            if (video.getLocalizedSubtitle(locale) != null)
                              Text(
                                video.getLocalizedSubtitle(locale)!,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface.withValues(alpha: 0.6),
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
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => ErrorHandleWidget(
          error: error,
          onRetry: () => ref.refresh(albumVideosProvider(widget.album.id)),
        ),      ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlaybackMockScreen extends StatefulWidget {
  final Video video;

  const VideoPlaybackMockScreen({super.key, required this.video});

  @override
  State<VideoPlaybackMockScreen> createState() => _VideoPlaybackMockScreenState();
}

class _VideoPlaybackMockScreenState extends State<VideoPlaybackMockScreen> {
  // Video Player (Normal)
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  
  // YouTube Player
  YoutubePlayerController? _youtubeController;
  
  bool _isInit = false;
  bool _isYoutube = false;

  @override
  void initState() {
    super.initState();
    _checkAndInitPlayer();
  }

  void _checkAndInitPlayer() {
    final videoUrl = widget.video.videoUrl;
    if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
      _isYoutube = true;
      _initYoutubePlayer(videoUrl);
    } else {
      _isYoutube = false;
      _initNormalPlayer(videoUrl);
    }
  }

  void _initYoutubePlayer(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
      setState(() {
        _isInit = true;
      });
    }
  }

  Future<void> _initNormalPlayer(String url) async {
    final cs = Theme.of(context).colorScheme;
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(color: cs.primary),
          ),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: cs.primary,
          handleColor: cs.primary,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white54,
        ),
      );

      setState(() {
        _isInit = true;
      });
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: cs.onSurface),
        title: Text(
          widget.video.getLocalizedTitle(locale),
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Area
          Container(
            height: 250.h,
            width: double.infinity,
            color: Colors.black,
            child: !_isInit
                ? Center(child: CircularProgressIndicator(color: cs.primary))
                : _isYoutube
                    ? YoutubePlayer(
                        controller: _youtubeController!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: cs.primary,
                      )
                    : _chewieController != null
                        ? Chewie(controller: _chewieController!)
                        : const Center(child: Icon(Icons.error, color: Colors.white)),
          ),
          
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.getLocalizedTitle(locale),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                if (widget.video.getLocalizedSubtitle(locale) != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    widget.video.getLocalizedSubtitle(locale)!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                SizedBox(height: 24.h),
                Text(
                  locale == 'ar' ? 'وصف الفيديو' : 'Video Description',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.video.getLocalizedDescription(locale) ??
                      (locale == 'ar' ? 'لا يوجد وصف متاح' : 'No description available'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: cs.onSurface.withValues(alpha: 0.8),
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


