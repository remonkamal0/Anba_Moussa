// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoModel _$VideoModelFromJson(Map<String, dynamic> json) => VideoModel(
  id: json['id'] as String,
  albumId: json['album_id'] as String,
  titleAr: json['title_ar'] as String,
  titleEn: json['title_en'] as String,
  subtitleAr: json['subtitle_ar'] as String?,
  subtitleEn: json['subtitle_en'] as String?,
  descriptionAr: json['description_ar'] as String?,
  descriptionEn: json['description_en'] as String?,
  videoUrl: json['video_url'] as String,
  thumbnailUrl: json['thumbnail_url'] as String?,
  durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
  sortOrder: (json['sort_order'] as num).toInt(),
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$VideoModelToJson(VideoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'album_id': instance.albumId,
      'title_ar': instance.titleAr,
      'title_en': instance.titleEn,
      'subtitle_ar': instance.subtitleAr,
      'subtitle_en': instance.subtitleEn,
      'description_ar': instance.descriptionAr,
      'description_en': instance.descriptionEn,
      'video_url': instance.videoUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'duration_seconds': instance.durationSeconds,
      'published_at': instance.publishedAt?.toIso8601String(),
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
