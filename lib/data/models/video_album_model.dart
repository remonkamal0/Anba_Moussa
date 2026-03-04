import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/video_album.dart';

part 'video_album_model.g.dart';

@JsonSerializable()
class VideoAlbumModel {
  final String id;
  final String? slug;
  @JsonKey(name: 'title_ar')
  final String titleAr;
  @JsonKey(name: 'title_en')
  final String titleEn;
  @JsonKey(name: 'subtitle_ar')
  final String? subtitleAr;
  @JsonKey(name: 'subtitle_en')
  final String? subtitleEn;
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;
  @JsonKey(name: 'description_ar')
  final String? descriptionAr;
  @JsonKey(name: 'description_en')
  final String? descriptionEn;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  VideoAlbumModel({
    required this.id,
    this.slug,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.coverImageUrl,
    this.descriptionAr,
    this.descriptionEn,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VideoAlbumModel.fromJson(Map<String, dynamic> json) =>
      _$VideoAlbumModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoAlbumModelToJson(this);

  VideoAlbum toEntity() => VideoAlbum(
        id: id,
        slug: slug,
        titleAr: titleAr,
        titleEn: titleEn,
        subtitleAr: subtitleAr,
        subtitleEn: subtitleEn,
        coverImageUrl: coverImageUrl,
        descriptionAr: descriptionAr,
        descriptionEn: descriptionEn,
        sortOrder: sortOrder,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
