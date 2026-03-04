// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagModel _$TagModelFromJson(Map<String, dynamic> json) => TagModel(
      id: json['id'] as String,
      titleAr: json['title_ar'] as String?,
      titleEn: json['title_en'] as String?,
    );

Map<String, dynamic> _$TagModelToJson(TagModel instance) => <String, dynamic>{
      'id': instance.id,
      'title_ar': instance.titleAr,
      'title_en': instance.titleEn,
    };
