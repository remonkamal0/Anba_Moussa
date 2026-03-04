import '../repositories/track_repository.dart';

class PlayTrackUseCase {
  final TrackRepository repository;

  PlayTrackUseCase(this.repository);

  Future<void> execute(String trackId) async {
    await repository.logPlayEvent(trackId);
  }
}
