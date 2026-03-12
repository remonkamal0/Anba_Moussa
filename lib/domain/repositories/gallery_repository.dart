import '../entities/photo_album.dart';
import '../entities/photo.dart';

abstract class GalleryRepository {
  Future<List<PhotoAlbum>> getPhotoAlbums();
  Future<List<Photo>> getPhotosByAlbumId(String albumId);
  Future<PhotoAlbum> createPhotoAlbum(PhotoAlbum album);
  Future<PhotoAlbum> updatePhotoAlbum(PhotoAlbum album);
  Future<void> deletePhotoAlbum(String id);
  Future<Photo> createPhoto(Photo photo);
  Future<Photo> updatePhoto(Photo photo);
  Future<void> deletePhoto(String id);
}
