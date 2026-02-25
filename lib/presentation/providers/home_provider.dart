import 'package:flutter/material.dart' hide Slider;
import '../../../core/utils/logger.dart';
import '../../domain/entities/track.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/slider.dart';
import '../../domain/usecases/get_top_tracks_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_sliders_usecase.dart';
import '../../domain/usecases/get_favorite_track_ids_usecase.dart';
import '../../domain/usecases/toggle_favorite_track_usecase.dart';

class HomeProvider extends ChangeNotifier {
  final GetTopTracksUseCase _getTopTracksUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetSlidersUseCase _getSlidersUseCase;
  final GetFavoriteTrackIdsUseCase _getFavoriteTrackIdsUseCase;
  final ToggleFavoriteTrackUseCase _toggleFavoriteTrackUseCase;
  final Logger _logger;

  HomeState _state = const HomeState.loading();

  HomeProvider({
    required GetTopTracksUseCase getTopTracksUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetSlidersUseCase getSlidersUseCase,
    required GetFavoriteTrackIdsUseCase getFavoriteTrackIdsUseCase,
    required ToggleFavoriteTrackUseCase toggleFavoriteTrackUseCase,
    required Logger logger,
  })  : _getTopTracksUseCase = getTopTracksUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        _getSlidersUseCase = getSlidersUseCase,
        _getFavoriteTrackIdsUseCase = getFavoriteTrackIdsUseCase,
        _toggleFavoriteTrackUseCase = toggleFavoriteTrackUseCase,
        _logger = logger;

  // State
  HomeState get state => _state;

  // Initialization
  Future<void> initialize() async {
    try {
      _setState(const HomeState.loading());
      
      final tracks = await _getTopTracksUseCase.execute(); // Or pass limit if added to use case
      final categories = await _getCategoriesUseCase.execute();
      final sliders = await _getSlidersUseCase.execute();
      final favoriteIds = await _getFavoriteTrackIdsUseCase.execute();

      _setState(HomeState.loaded(
        tracks: tracks,
        categories: categories,
        sliders: sliders,
        favoriteTrackIds: favoriteIds,
      ));
    } catch (e) {
      _logger.log('Failed to load home data: $e', level: 'ERROR');
      _setState(HomeState.error(e.toString()));
    }
  }

  // Track actions
  Future<void> toggleFavorite(String trackId) async {
    try {
      // First let's find if it was a favorite to toggle it.
      // Or we wait, ToggleFavoriteTrackUseCase expects isFavorite boolean now.
      // So we need to check current state.
      bool isCurrentlyFavorite = false;
      _state.when(
        loading: () {},
        loaded: (tracks, categories, sliders, favoriteIds, currentIndex) {
          isCurrentlyFavorite = favoriteIds.contains(trackId);
        },
        error: (message) {},
      );

      await _toggleFavoriteTrackUseCase.execute(trackId, !isCurrentlyFavorite);
      final newFavoriteIds = await _getFavoriteTrackIdsUseCase.execute();
      
      _state.when(
        loading: () {},
        loaded: (tracks, categories, sliders, favoriteIds, currentIndex) {
          _setState(HomeState.loaded(
            tracks: tracks,
            categories: categories,
            sliders: sliders,
            favoriteTrackIds: newFavoriteIds,
            currentIndex: currentIndex,
          ));
        },
        error: (message) {},
      );
    } catch (e) {
      _logger.log('Failed to toggle favorite: $e', level: 'ERROR');
    }
  }

  Future<void> playTrack(String trackId) async {
    try {
      // Original code was toggling favorite when playing. Assuming that's what was intended.
      await _toggleFavoriteTrackUseCase.execute(trackId, true);
      _logger.log('Playing track: $trackId', level: 'INFO');
    } catch (e) {
      _logger.log('Failed to play track: $e', level: 'ERROR');
    }
  }

  // Slider actions
  void onSliderChanged(int index) {
    _state.when(
      loading: () {},
      loaded: (tracks, categories, sliders, favoriteIds, currentIndex) {
        _setState(HomeState.loaded(
          tracks: tracks,
          categories: categories,
          sliders: sliders,
          favoriteTrackIds: favoriteIds,
          currentIndex: index,
        ));
      },
      error: (message) {},
    );
  }

  // Refresh data
  Future<void> refresh() async {
    await initialize();
  }

  void _setState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }
}

// Home state
class HomeState {
  final HomeStatus status;
  final List<Track> tracks;
  final List<Category> categories;
  final List<Slider> sliders;
  final Set<String> favoriteTrackIds;
  final int currentIndex;
  final String? message;

  const HomeState({
    required this.status,
    this.tracks = const [],
    this.categories = const [],
    this.sliders = const [],
    this.favoriteTrackIds = const {},
    this.currentIndex = 0,
    this.message,
  });

  const HomeState.loading() 
      : status = HomeStatus.loading,
        tracks = const [],
        categories = const [],
        sliders = const [],
        favoriteTrackIds = const {},
        currentIndex = 0,
        message = null;

  const HomeState.loaded({
    required this.tracks,
    required this.categories,
    required this.sliders,
    required this.favoriteTrackIds,
    this.currentIndex = 0,
  }) : status = HomeStatus.loaded, message = null;

  const HomeState.error(this.message) 
      : status = HomeStatus.error,
        tracks = const [],
        categories = const [],
        sliders = const [],
        favoriteTrackIds = const {},
        currentIndex = 0;

  T when<T>({
    required T Function() loading,
    required T Function(List<Track>, List<Category>, List<Slider>, Set<String>, int) loaded,
    required T Function(String) error,
  }) {
    switch (status) {
      case HomeStatus.loading:
        return loading();
      case HomeStatus.loaded:
        return loaded(tracks, categories, sliders, favoriteTrackIds, currentIndex);
      case HomeStatus.error:
        return error(message ?? 'Unknown error');
    }
  }
}

enum HomeStatus { loading, loaded, error }

