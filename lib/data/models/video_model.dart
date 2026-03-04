import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/video.dart';

part 'video_model.g.dart';

@JsonSerializable()
class VideoModel {
  final String id;
  @JsonKey(name: 'album_id')
  final String albumId;
  @JsonKey(name: 'title_ar')
  final String titleAr;
  @JsonKey(name: 'title_en')
  final String titleEn;
  @JsonKey(name: 'subtitle_ar')
  final String? subtitleAr;
  @JsonKey(name: 'subtitle_en')
  final String? subtitleEn;
  @JsonKey(name: 'description_ar')
  final String? descriptionAr;
  @JsonKey(name: 'description_en')
  final String? descriptionEn;
  @JsonKey(name: 'video_url')
  final String videoUrl;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  VideoModel({
    required this.id,
    required this.albumId,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.videoUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.publishedAt,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoModelToJson(this);

  Video toEntity() => Video(
        id: id,
        albumId: albumId,
        titleAr: titleAr,
        titleEn: titleEn,
        subtitleAr: subtitleAr,
        subtitleEn: subtitleEn,
        descriptionAr: descriptionAr,
        descriptionEn: descriptionEn,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        durationSeconds: durationSeconds,
        publishedAt: publishedAt,
        sortOrder: sortOrder,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
