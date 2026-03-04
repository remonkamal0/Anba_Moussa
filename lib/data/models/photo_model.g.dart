// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhotoModel _$PhotoModelFromJson(Map<String, dynamic> json) => PhotoModel(
      id: json['id'] as String,
      albumId: json['album_id'] as String,
      imageUrl: json['image_url'] as String,
      titleAr: json['title_ar'] as String?,
      titleEn: json['title_en'] as String?,
      captionAr: json['caption_ar'] as String?,
      captionEn: json['caption_en'] as String?,
      sortOrder: (json['sort_order'] as num).toInt(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PhotoModelToJson(PhotoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'album_id': instance.albumId,
      'image_url': instance.imageUrl,
      'title_ar': instance.titleAr,
      'title_en': instance.titleEn,
      'caption_ar': instance.captionAr,
      'caption_en': instance.captionEn,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
