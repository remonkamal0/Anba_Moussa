import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/track.dart';
import 'tag_model.dart';

part 'track_model.g.dart';

@JsonSerializable()
class TrackModel {
  final String id;
  @JsonKey(name: 'category_id')
  final String categoryId;
  @JsonKey(name: 'title_ar')
  final String? titleAr; // DB: text
  @JsonKey(name: 'title_en')
  final String? titleEn; // DB: text
  @JsonKey(name: 'subtitle_ar')
  final String? subtitleAr;
  @JsonKey(name: 'subtitle_en')
  final String? subtitleEn;
  @JsonKey(name: 'description_ar')
  final String? descriptionAr;
  @JsonKey(name: 'description_en')
  final String? descriptionEn;
  @JsonKey(name: 'speaker_ar')
  final String? speakerAr;
  @JsonKey(name: 'speaker_en')
  final String? speakerEn;
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;
  @JsonKey(name: 'audio_url')
  final String? audioUrl;
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final List<TagModel>? tags;

  TrackModel({
    required this.id,
    required this.categoryId,
    this.titleAr,
    this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.speakerAr,
    this.speakerEn,
    this.coverImageUrl,
    this.audioUrl,
    this.durationSeconds,
    this.publishedAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.tags,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) =>
      _$TrackModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrackModelToJson(this);

  String getLocalizedTitle(String locale) {
    if (locale == 'ar') return titleAr ?? '';
    return titleEn ?? '';
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

  Track toEntity() {
    return Track(
      id: id,
      categoryId: categoryId,
      titleAr: titleAr ?? '',
      titleEn: titleEn ?? '',
      subtitleAr: subtitleAr,
      subtitleEn: subtitleEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      speakerAr: speakerAr,
      speakerEn: speakerEn,
      imageUrl: coverImageUrl,
      audioUrl: audioUrl ?? '',
      durationSeconds: durationSeconds,
      publishedAt: publishedAt,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags?.map((t) => t.toEntity()).toList() ?? [],
    );
  }
}
