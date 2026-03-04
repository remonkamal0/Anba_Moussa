import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/tag.dart';

part 'tag_model.g.dart';

@JsonSerializable()
class TagModel {
  final String id;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  @JsonKey(name: 'name_en')
  final String? nameEn;

  TagModel({
    required this.id,
    this.nameAr,
    this.nameEn,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) => _$TagModelFromJson(json);
  Map<String, dynamic> toJson() => _$TagModelToJson(this);

  Tag toEntity() => Tag(
        id: id,
        nameAr: nameAr ?? '',
        nameEn: nameEn ?? '',
      );
}
