import 'package:json_annotation/json_annotation.dart';

part 'track_model.g.dart';

@JsonSerializable()
class TrackModel {
  final String id;
  final String categoryId;
  final String titleAr;
  final String titleEn;
  final String? subtitleAr;
  final String? subtitleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? speakerAr;
  final String? speakerEn;
  final String? coverImageUrl;
  final String audioUrl;
  final int? durationSeconds;
  final DateTime? publishedAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrackModel({
    required this.id,
    required this.categoryId,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.speakerAr,
    this.speakerEn,
    this.coverImageUrl,
    required this.audioUrl,
    this.durationSeconds,
    this.publishedAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) =>
      _$TrackModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrackModelToJson(json);

  String getLocalizedName(String locale) {
    return locale == 'ar' ? titleAr : titleEn;
  }

  String? getLocalizedSubtitle(String locale) {
    return locale == 'ar' ? subtitleAr : subtitleEn;
  }

  String? getLocalizedDescription(String locale) {
    return locale == 'ar' ? descriptionAr : descriptionEn;
  }

  String? getLocalizedSpeaker(String locale) {
    return locale == 'ar' ? speakerAr : speakerEn;
  }

  Duration? get duration => durationSeconds != null 
      ? Duration(seconds: durationSeconds!) 
      : null;

  String get formattedDuration {
    if (durationSeconds == null) return '--:--';
    
    final duration = Duration(seconds: durationSeconds!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
