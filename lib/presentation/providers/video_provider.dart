import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/video_album.dart';
import '../../domain/entities/video.dart';

final videoAlbumsProvider =
    FutureProvider.autoDispose<List<VideoAlbum>>((ref) async {
  return await sl.videoRepository.getVideoAlbums();
});

final albumVideosProvider =
    FutureProvider.autoDispose.family<List<Video>, String>((ref, albumId) async {
  return await sl.videoRepository.getVideosByAlbumId(albumId);
});
