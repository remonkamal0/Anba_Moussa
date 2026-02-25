import '../entities/slider.dart';
import '../repositories/slider_repository.dart';

class GetSlidersUseCase {
  final SliderRepository repository;

  GetSlidersUseCase(this.repository);

  Future<List<Slider>> execute() async {
    return await repository.getSliders();
  }
}
