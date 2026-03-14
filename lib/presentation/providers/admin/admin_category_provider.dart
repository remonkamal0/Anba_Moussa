import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/category.dart';
import '../../../../domain/repositories/category_repository.dart';

class AdminCategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;
  final Logger _logger;

  bool _isLoading = false;
  List<Category> _categories = [];
  String? _error;

  AdminCategoryProvider({
    required CategoryRepository repository,
    required Logger logger,
  }) : _repository = repository,
       _logger = logger;

  bool get isLoading => _isLoading;
  List<Category> get categories => _categories;
  String? get error => _error;

  Future<void> loadCategories() async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _repository.getCategories();
      _categories = data;
    } catch (e, st) {
      _logger.error('Failed to load categories', e, st);
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCategory(Category category) async {
    _setLoading(true);
    _error = null;
    try {
      final newCategory = await _repository.createCategory(category);
      _categories.insert(0, newCategory);
      return true;
    } catch (e, st) {
      _logger.error('Failed to create category', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCategory(Category category) async {
    _setLoading(true);
    _error = null;
    try {
      final updatedCategory = await _repository.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }
      return true;
    } catch (e, st) {
      _logger.error('Failed to update category', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCategory(String id) async {
    _setLoading(true);
    _error = null;
    try {
      await _repository.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      return true;
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        _error = 'category_has_tracks'; // Special code for localization
      } else {
        _error = e.toString();
      }
      _logger.error('Failed to delete category', e);
      return false;
    } catch (e, st) {
      _logger.error('Failed to delete category', e, st);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
