// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackModel _$TrackModelFromJson(Map<String, dynamic> json) => TrackModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String,
      subtitleAr: json['subtitle_ar'] as String?,
      subtitleEn: json['subtitle_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      speakerAr: json['speaker_ar'] as String?,
      speakerEn: json['speaker_en'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      audioUrl: json['audio_url'] as String,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TrackModelToJson(TrackModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'title_ar': instance.titleAr,
      'title_en': instance.titleEn,
      'subtitle_ar': instance.subtitleAr,
      'subtitle_en': instance.subtitleEn,
      'description_ar': instance.descriptionAr,
      'description_en': instance.descriptionEn,
      'speaker_ar': instance.speakerAr,
      'speaker_en': instance.speakerEn,
      'cover_image_url': instance.coverImageUrl,
      'audio_url': instance.audioUrl,
      'duration_seconds': instance.durationSeconds,
      'published_at': instance.publishedAt?.toIso8601String(),
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
