// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackModel _$TrackModelFromJson(Map<String, dynamic> json) => TrackModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      titleAr: json['titleAr'] as String,
      titleEn: json['titleEn'] as String,
      subtitleAr: json['subtitleAr'] as String?,
      subtitleEn: json['subtitleEn'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      speakerAr: json['speakerAr'] as String?,
      speakerEn: json['speakerEn'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      audioUrl: json['audioUrl'] as String,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TrackModelToJson(TrackModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'titleAr': instance.titleAr,
      'titleEn': instance.titleEn,
      'subtitleAr': instance.subtitleAr,
      'subtitleEn': instance.subtitleEn,
      'descriptionAr': instance.descriptionAr,
      'descriptionEn': instance.descriptionEn,
      'speakerAr': instance.speakerAr,
      'speakerEn': instance.speakerEn,
      'coverImageUrl': instance.coverImageUrl,
      'audioUrl': instance.audioUrl,
      'durationSeconds': instance.durationSeconds,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
