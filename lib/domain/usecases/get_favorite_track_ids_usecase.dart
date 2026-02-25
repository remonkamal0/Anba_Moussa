import '../repositories/track_repository.dart';

class GetFavoriteTrackIdsUseCase {
  final TrackRepository repository;

  GetFavoriteTrackIdsUseCase(this.repository);

  Future<Set<String>> execute() async {
    final tracks = await repository.getFavoriteTracks();
    return tracks.map((t) => t.id).toSet();
  }
}
