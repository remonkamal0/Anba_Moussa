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

  @override
  Future<PhotoAlbum> createPhotoAlbum(PhotoAlbum album) async {
    return await remoteDataSource.createPhotoAlbum(album);
  }

  @override
  Future<PhotoAlbum> updatePhotoAlbum(PhotoAlbum album) async {
    return await remoteDataSource.updatePhotoAlbum(album);
  }

  @override
  Future<void> deletePhotoAlbum(String id) async {
    return await remoteDataSource.deletePhotoAlbum(id);
  }

  @override
  Future<Photo> createPhoto(Photo photo) async {
    return await remoteDataSource.createPhoto(photo);
  }

  @override
  Future<Photo> updatePhoto(Photo photo) async {
    return await remoteDataSource.updatePhoto(photo);
  }

  @override
  Future<void> deletePhoto(String id) async {
    return await remoteDataSource.deletePhoto(id);
  }
}
