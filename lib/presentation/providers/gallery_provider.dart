import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/photo_album.dart';
import '../../domain/entities/photo.dart';

final photoAlbumsProvider =
    FutureProvider.autoDispose<List<PhotoAlbum>>((ref) async {
  return await sl.galleryRepository.getPhotoAlbums();
});

final albumPhotosProvider =
    FutureProvider.autoDispose.family<List<Photo>, String>((ref, albumId) async {
  return await sl.galleryRepository.getPhotosByAlbumId(albumId);
});
