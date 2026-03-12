import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track.dart';
import '../../core/di/service_locator.dart';

class FavoritesState {
  final List<Track> tracks;
  final bool isLoading;
  final String? error;

  FavoritesState({this.tracks = const [], this.isLoading = false, this.error});

  FavoritesState copyWith({
    List<Track>? tracks,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier() : super(FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true);
    try {
      final tracks = await sl.getFavoriteTracksUseCase.execute();
      state = state.copyWith(tracks: tracks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleFavorite(Track track) async {
    final isFavorite = state.tracks.any((t) => t.id == track.id);
    try {
      await sl.toggleFavoriteTrackUseCase.execute(track.id, !isFavorite);
      if (isFavorite) {
        state = state.copyWith(
          tracks: state.tracks.where((t) => t.id != track.id).toList(),
        );
      } else {
        state = state.copyWith(tracks: [...state.tracks, track]);
      }
    } catch (e) {
      // Handle error (maybe revert state or show toast)
    }
  }

  bool isFavorite(String trackId) {
    return state.tracks.any((t) => t.id == trackId);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
      return FavoritesNotifier();
    });
