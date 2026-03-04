import '../entities/track.dart';
import '../repositories/track_repository.dart';

class GetTracksByCategoryUseCase {
  final TrackRepository repository;

  GetTracksByCategoryUseCase(this.repository);

  Future<List<Track>> execute(String categoryId) async {
    return await repository.getTracks(categoryId: categoryId);
  }
}
