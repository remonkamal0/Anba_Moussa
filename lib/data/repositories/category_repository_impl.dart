import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final RemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Category>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    // Ideally add getting a single category to the RemoteDataSource,
    // but for now, fetch all and filter or add specific logic later.
    final list = await remoteDataSource.getCategories();
    try {
      return list.firstWhere((cat) => cat.id == id);
    } catch (_) {
      return null;
    }
  }
}
