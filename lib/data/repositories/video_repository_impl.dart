import '../../domain/entities/video_album.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/remote_data_source.dart';

class VideoRepositoryImpl implements VideoRepository {
  final RemoteDataSource remoteDataSource;

  VideoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<VideoAlbum>> getVideoAlbums() async {
    return await remoteDataSource.getVideoAlbums();
  }

  @override
  Future<List<Video>> getVideosByAlbumId(String albumId) async {
    return await remoteDataSource.getVideosByAlbumId(albumId);
  }

  @override
  Future<VideoAlbum> createVideoAlbum(VideoAlbum album) async {
    return await remoteDataSource.createVideoAlbum(album);
  }

  @override
  Future<VideoAlbum> updateVideoAlbum(VideoAlbum album) async {
    return await remoteDataSource.updateVideoAlbum(album);
  }

  @override
  Future<void> deleteVideoAlbum(String id) async {
    return await remoteDataSource.deleteVideoAlbum(id);
  }

  @override
  Future<Video> createVideo(Video video) async {
    return await remoteDataSource.createVideo(video);
  }

  @override
  Future<Video> updateVideo(Video video) async {
    return await remoteDataSource.updateVideo(video);
  }

  @override
  Future<void> deleteVideo(String id) async {
    return await remoteDataSource.deleteVideo(id);
  }
}
