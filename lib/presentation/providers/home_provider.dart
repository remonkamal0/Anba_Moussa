import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/track.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/slider.dart' as entity;
import '../../../domain/usecases/get_top_tracks_usecase.dart';
import '../../../domain/usecases/get_categories_usecase.dart';
import '../../../domain/usecases/get_sliders_usecase.dart';
import '../../../domain/usecases/get_favorite_track_ids_usecase.dart';
import '../../../domain/usecases/toggle_favorite_track_usecase.dart';

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

  HomeState get state => _state;

  Future<void> initialize() async {
    try {
      _setState(const HomeState.loading());

      final tracks = await _getTopTracksUseCase.execute();
      final categories = await _getCategoriesUseCase.execute();
      final sliders = await _getSlidersUseCase.execute();
      final favoriteIds = await _getFavoriteTrackIdsUseCase.execute();

      _setState(HomeState.loaded(
        tracks: tracks,
        categories: categories,
        sliders: sliders,
        favoriteTrackIds: Set<String>.from(favoriteIds),
      ));
    } catch (e, st) {
      _logger.error('Failed to load home data', e, st);
      _setState(HomeState.error(e.toString()));
    }
  }

  Future<void> toggleFavorite(String trackId) async {
    final currentState = _state;
    try {
      final isFavorite = currentState.favoriteTrackIds.contains(trackId);
      await _toggleFavoriteTrackUseCase.execute(trackId, !isFavorite);

      final newFavoriteIds = await _getFavoriteTrackIdsUseCase.execute();
      _setState(currentState.copyWith(
        favoriteTrackIds: Set<String>.from(newFavoriteIds),
      ));
    } catch (e) {
      _logger.error('Failed to toggle favorite: $e');
    }
  }

  Future<void> playTrack(String trackId) async {
    try {
      _logger.info('Playing track: $trackId');
      // Play logic handled by the player provider
    } catch (e) {
      _logger.error('Failed to play track: $e');
    }
  }

  void onSliderChanged(int index) {
    _setState(_state.copyWith(currentIndex: index));
  }

  Future<void> refresh() async {
    await initialize();
  }

  void _setState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// Home State
// ---------------------------------------------------------------------------

enum HomeStatus { loading, loaded, error }

@immutable
class HomeState {
  final HomeStatus status;
  final List<Track> tracks;
  final List<Category> categories;
  final List<entity.Slider> sliders;
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
  })  : status = HomeStatus.loaded,
        message = null;

  const HomeState.error(this.message)
      : status = HomeStatus.error,
        tracks = const [],
        categories = const [],
        sliders = const [],
        favoriteTrackIds = const {},
        currentIndex = 0;

  HomeState copyWith({
    HomeStatus? status,
    List<Track>? tracks,
    List<Category>? categories,
    List<entity.Slider>? sliders,
    Set<String>? favoriteTrackIds,
    int? currentIndex,
    String? message,
  }) {
    return HomeState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      categories: categories ?? this.categories,
      sliders: sliders ?? this.sliders,
      favoriteTrackIds: favoriteTrackIds ?? this.favoriteTrackIds,
      currentIndex: currentIndex ?? this.currentIndex,
      message: message ?? this.message,
    );
  }

  T when<T>({
    required T Function() loading,
    required T Function(List<Track>, List<Category>, List<entity.Slider>,
            Set<String>, int)
        loaded,
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
