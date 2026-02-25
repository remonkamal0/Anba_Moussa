import '../../domain/entities/slider.dart';
import '../../domain/repositories/slider_repository.dart';
import '../datasources/remote_data_source.dart';

class SliderRepositoryImpl implements SliderRepository {
  final RemoteDataSource remoteDataSource;

  SliderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Slider>> getSliders() async {
    return await remoteDataSource.getSliders();
  }
}
