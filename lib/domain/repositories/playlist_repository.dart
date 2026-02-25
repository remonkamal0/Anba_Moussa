import '../entities/playlist.dart';

abstract class PlaylistRepository {
  Future<List<Playlist>> getPlaylists();
  Future<Playlist?> getPlaylistById(String id);
}
