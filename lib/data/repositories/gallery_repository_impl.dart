import '../../domain/entities/photo_album.dart';
import '../../domain/entities/photo.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../datasources/remote_data_source.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final RemoteDataSource remoteDataSource;

  GalleryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PhotoAlbum>> getPhotoAlbums() async {
    return await remoteDataSource.getPhotoAlbums();
  }

  @override
  Future<List<Photo>> getPhotosByAlbumId(String albumId) async {
    return await remoteDataSource.getPhotosByAlbumId(albumId);
  }
}
