import '../repositories/track_repository.dart';

class LogPlayEventUseCase {
  final TrackRepository repository;

  LogPlayEventUseCase(this.repository);

  Future<void> execute(String trackId) async {
    await repository.logPlayEvent(trackId);
  }
}
