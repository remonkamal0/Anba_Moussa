// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_album_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoAlbumModel _$VideoAlbumModelFromJson(Map<String, dynamic> json) =>
    VideoAlbumModel(
      id: json['id'] as String,
      slug: json['slug'] as String?,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String,
      subtitleAr: json['subtitle_ar'] as String?,
      subtitleEn: json['subtitle_en'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      sortOrder: (json['sort_order'] as num).toInt(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$VideoAlbumModelToJson(VideoAlbumModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title_ar': instance.titleAr,
      'title_en': instance.titleEn,
      'subtitle_ar': instance.subtitleAr,
      'subtitle_en': instance.subtitleEn,
      'cover_image_url': instance.coverImageUrl,
      'description_ar': instance.descriptionAr,
      'description_en': instance.descriptionEn,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
