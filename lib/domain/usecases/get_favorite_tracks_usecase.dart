import '../entities/track.dart';
import '../repositories/track_repository.dart';

class GetFavoriteTracksUseCase {
  final TrackRepository repository;

  GetFavoriteTracksUseCase(this.repository);

  Future<List<Track>> execute() async {
    return await repository.getFavoriteTracks();
  }
}
