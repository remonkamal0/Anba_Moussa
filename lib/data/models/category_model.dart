import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  final String id;
  final String slug;
  @JsonKey(name: 'title_ar')
  final String titleAr;
  @JsonKey(name: 'title_en')
  final String titleEn;
  @JsonKey(name: 'subtitle_ar')
  final String? subtitleAr;
  @JsonKey(name: 'subtitle_en')
  final String? subtitleEn;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.slug,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.imageUrl,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  String getLocalizedName(String locale) {
    return locale == 'ar' ? titleAr : titleEn;
  }

  String? getLocalizedSubtitle(String locale) {
    return locale == 'ar' ? subtitleAr : subtitleEn;
  }
}
