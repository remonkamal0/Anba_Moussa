import 'package:json_annotation/json_annotation.dart';

part 'playlist_model.g.dart';

@JsonSerializable()
class PlaylistModel {
  final String id;
  final String? userId;
  final String ownerType;
  final bool isPublic;
  final String titleAr;
  final String titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlaylistModel({
    required this.id,
    this.userId,
    required this.ownerType,
    required this.isPublic,
    required this.titleAr,
    required this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) =>
      _$PlaylistModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistModelToJson(this);

  String getLocalizedName(String locale) {
    return locale == 'ar' ? titleAr : titleEn;
  }

  String? getLocalizedDescription(String locale) {
    return locale == 'ar' ? descriptionAr : descriptionEn;
  }
}
