import '../entities/photo_album.dart';
import '../entities/photo.dart';

abstract class GalleryRepository {
  Future<List<PhotoAlbum>> getPhotoAlbums();
  Future<List<Photo>> getPhotosByAlbumId(String albumId);
}
