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
}
