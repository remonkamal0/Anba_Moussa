import '../entities/track.dart';
import '../repositories/track_repository.dart';

class GetTopTracksUseCase {
  final TrackRepository repository;

  GetTopTracksUseCase(this.repository);

  Future<List<Track>> execute({int limit = 10}) async {
    return await repository.getTopTracks(limit: limit);
  }
}
