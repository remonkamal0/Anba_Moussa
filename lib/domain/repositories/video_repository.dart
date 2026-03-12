import '../entities/video_album.dart';
import '../entities/video.dart';

abstract class VideoRepository {
  Future<List<VideoAlbum>> getVideoAlbums();
  Future<List<Video>> getVideosByAlbumId(String albumId);
  Future<VideoAlbum> createVideoAlbum(VideoAlbum album);
  Future<VideoAlbum> updateVideoAlbum(VideoAlbum album);
  Future<void> deleteVideoAlbum(String id);
  Future<Video> createVideo(Video video);
  Future<Video> updateVideo(Video video);
  Future<void> deleteVideo(String id);
}
