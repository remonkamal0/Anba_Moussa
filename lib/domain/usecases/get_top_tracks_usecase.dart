import '../entities/track.dart';
import '../repositories/track_repository.dart';

class GetTopTracksUseCase {
  final TrackRepository repository;

  GetTopTracksUseCase(this.repository);

  Future<List<Track>> execute() async {
    return await repository.getTracks(); // or a specific method for top tracks
  }
}
