class Video {
  final String id;
  final String albumId;
  final String titleAr;
  final String titleEn;
  final String? subtitleAr;
  final String? subtitleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String videoUrl;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final DateTime? publishedAt;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Video({
    required this.id,
    required this.albumId,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.videoUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.publishedAt,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String getLocalizedTitle(String locale) => locale == 'ar' ? titleAr : titleEn;
  String? getLocalizedSubtitle(String locale) => locale == 'ar' ? subtitleAr : subtitleEn;
  String? getLocalizedDescription(String locale) => locale == 'ar' ? descriptionAr : descriptionEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Video &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Video{id: $id, albumId: $albumId, titleAr: $titleAr}';
  }
}
