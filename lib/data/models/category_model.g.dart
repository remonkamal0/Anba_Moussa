// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String,
      subtitleAr: json['subtitle_ar'] as String?,
      subtitleEn: json['subtitle_en'] as String?,
      imageUrl: json['image_url'] as String?,
      sortOrder: (json['sort_order'] as num).toInt(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title_ar': instance.titleAr,
      'title_en': instance.titleEn,
      'subtitle_ar': instance.subtitleAr,
      'subtitle_en': instance.subtitleEn,
      'image_url': instance.imageUrl,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
