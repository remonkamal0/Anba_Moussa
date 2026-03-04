import '../entities/video_album.dart';
import '../entities/video.dart';

abstract class VideoRepository {
  Future<List<VideoAlbum>> getVideoAlbums();
  Future<List<Video>> getVideosByAlbumId(String albumId);
}
