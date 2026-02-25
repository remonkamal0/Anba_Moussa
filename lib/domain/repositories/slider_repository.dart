import '../entities/slider.dart';

abstract class SliderRepository {
  Future<List<Slider>> getSliders();
}
