import 'package:flutter/material.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/usecases/get_categories_usecase.dart';
import '../../../core/utils/logger.dart';

enum LibraryStatus { loading, loaded, error }

class LibraryState {
  final LibraryStatus status;
  final List<Category> categories;
  final String? errorMessage;

  const LibraryState({
    required this.status,
    this.categories = const [],
    this.errorMessage,
  });

  const LibraryState.loading()
      : status = LibraryStatus.loading,
        categories = const [],
        errorMessage = null;

  const LibraryState.loaded(this.categories)
      : status = LibraryStatus.loaded,
        errorMessage = null;

  const LibraryState.error(this.errorMessage)
      : status = LibraryStatus.error,
        categories = const [];
}

class LibraryProvider extends ChangeNotifier {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final Logger _logger;

  LibraryState _state = const LibraryState.loading();
  LibraryState get state => _state;

  LibraryProvider({
    required GetCategoriesUseCase getCategoriesUseCase,
    required Logger logger,
  })  : _getCategoriesUseCase = getCategoriesUseCase,
        _logger = logger;

  Future<void> initialize() async {
    await fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      _state = const LibraryState.loading();
      notifyListeners();

      final categories = await _getCategoriesUseCase.execute();
      _state = LibraryState.loaded(categories);
    } catch (e, st) {
      _logger.error('Failed to fetch categories: $e', e, st);
      _state = LibraryState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }
}
