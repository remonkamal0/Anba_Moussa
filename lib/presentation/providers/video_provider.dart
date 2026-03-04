import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/video_album.dart';
import '../../domain/entities/video.dart';

final videoAlbumsProvider = FutureProvider<List<VideoAlbum>>((ref) async {
  return await sl.videoRepository.getVideoAlbums();
});

final albumVideosProvider = FutureProvider.family<List<Video>, String>((ref, albumId) async {
  return await sl.videoRepository.getVideosByAlbumId(albumId);
});
