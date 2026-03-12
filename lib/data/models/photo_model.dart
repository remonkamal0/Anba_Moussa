import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/photo.dart';

part 'photo_model.g.dart';

@JsonSerializable()
class PhotoModel {
  final String id;
  @JsonKey(name: 'album_id')
  final String albumId;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @JsonKey(name: 'title_ar')
  final String? titleAr;
  @JsonKey(name: 'title_en')
  final String? titleEn;
  @JsonKey(name: 'caption_ar')
  final String? captionAr;
  @JsonKey(name: 'caption_en')
  final String? captionEn;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  PhotoModel({
    required this.id,
    required this.albumId,
    required this.imageUrl,
    this.titleAr,
    this.titleEn,
    this.captionAr,
    this.captionEn,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) =>
      _$PhotoModelFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoModelToJson(this);

  Photo toEntity() => Photo(
    id: id,
    albumId: albumId,
    imageUrl: imageUrl,
    titleAr: titleAr,
    titleEn: titleEn,
    captionAr: captionAr,
    captionEn: captionEn,
    sortOrder: sortOrder,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
