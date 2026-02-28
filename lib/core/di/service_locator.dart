import '../../core/network/supabase_service.dart';
import '../../core/utils/logger.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/track_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/slider_repository_impl.dart';
import '../../data/repositories/playlist_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../domain/repositories/slider_repository.dart';
import '../../domain/repositories/track_repository.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_favorite_track_ids_usecase.dart';
import '../../domain/usecases/get_favorite_tracks_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/get_sliders_usecase.dart';
import '../../domain/usecases/get_top_tracks_usecase.dart';
import '../../domain/usecases/play_track_usecase.dart';
import '../../domain/usecases/toggle_favorite_track_usecase.dart';
import '../../domain/usecases/get_tracks_by_category_usecase.dart';
import '../../presentation/providers/home_provider.dart';
import '../../presentation/providers/library_provider.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Core
  late final Logger logger;
  late final SupabaseService supabaseService;

  // Data Sources
  late final RemoteDataSource remoteDataSource;

  // Repositories
  late final TrackRepository trackRepository;
  late final CategoryRepository categoryRepository;
  late final SliderRepository sliderRepository;
  late final PlaylistRepository playlistRepository;
  late final NotificationRepository notificationRepository;

  // Use Cases
  late final GetTopTracksUseCase getTopTracksUseCase;
  late final GetCategoriesUseCase getCategoriesUseCase;
  late final GetSlidersUseCase getSlidersUseCase;
  late final GetFavoriteTrackIdsUseCase getFavoriteTrackIdsUseCase;
  late final ToggleFavoriteTrackUseCase toggleFavoriteTrackUseCase;
  late final GetFavoriteTracksUseCase getFavoriteTracksUseCase;
  late final PlayTrackUseCase playTrackUseCase;
  late final GetTracksByCategoryUseCase getTracksByCategoryUseCase;
  late final GetNotificationsUseCase getNotificationsUseCase;

  void init() {
    // Core
    logger = Logger();
    supabaseService = SupabaseService.instance;

    // Data Sources
    remoteDataSource = SupabaseRemoteDataSourceImpl(client: supabaseService.client);

    // Repositories
    trackRepository = TrackRepositoryImpl(remoteDataSource, supabaseService);
    categoryRepository = CategoryRepositoryImpl(remoteDataSource: remoteDataSource);
    sliderRepository = SliderRepositoryImpl(remoteDataSource: remoteDataSource);
    playlistRepository = PlaylistRepositoryImpl(remoteDataSource: remoteDataSource);
    notificationRepository = NotificationRepositoryImpl(supabaseService);

    // Use Cases
    getTopTracksUseCase = GetTopTracksUseCase(trackRepository);
    getCategoriesUseCase = GetCategoriesUseCase(categoryRepository);
    getSlidersUseCase = GetSlidersUseCase(sliderRepository);
    getFavoriteTrackIdsUseCase = GetFavoriteTrackIdsUseCase(trackRepository);
    toggleFavoriteTrackUseCase = ToggleFavoriteTrackUseCase(trackRepository);
    getFavoriteTracksUseCase = GetFavoriteTracksUseCase(trackRepository);
    playTrackUseCase = PlayTrackUseCase(trackRepository);
    getTracksByCategoryUseCase = GetTracksByCategoryUseCase(trackRepository);
    getNotificationsUseCase = GetNotificationsUseCase(notificationRepository);
  }

  // Providers Factory (creates new instances or returns singletons as needed)
  HomeProvider get homeProvider => HomeProvider(
    getTopTracksUseCase: getTopTracksUseCase,
    getCategoriesUseCase: getCategoriesUseCase,
    getSlidersUseCase: getSlidersUseCase,
    getFavoriteTrackIdsUseCase: getFavoriteTrackIdsUseCase,
    toggleFavoriteTrackUseCase: toggleFavoriteTrackUseCase,
    logger: logger,
  );

  LibraryProvider get libraryProvider => LibraryProvider(
    getCategoriesUseCase: getCategoriesUseCase,
    logger: logger,
  );
}

final sl = ServiceLocator();
