import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/tag.dart';

part 'tag_model.g.dart';

@JsonSerializable()
class TagModel {
  final String id;
  final String? slug;
  @JsonKey(name: 'title_ar')
  final String? titleAr;
  @JsonKey(name: 'title_en')
  final String? titleEn;

  TagModel({required this.id, this.slug, this.titleAr, this.titleEn});

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);
  Map<String, dynamic> toJson() => _$TagModelToJson(this);

  Tag toEntity() => Tag(
        id: id,
        slug: slug,
        titleAr: titleAr ?? '',
        titleEn: titleEn ?? '',
      );
}
