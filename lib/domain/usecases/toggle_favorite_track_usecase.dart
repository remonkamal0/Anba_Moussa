import '../entities/track.dart';
import '../repositories/track_repository.dart';

class ToggleFavoriteTrackUseCase {
  final TrackRepository repository;

  ToggleFavoriteTrackUseCase(this.repository);

  Future<void> execute(String trackId, bool isFavorite) async {
    if (isFavorite) {
      await repository.addToFavorites(trackId);
    } else {
      await repository.removeFromFavorites(trackId);
    }
  }
}
