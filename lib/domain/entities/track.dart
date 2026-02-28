class Track {
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
  final String? imageUrl;
  final String audioUrl;
  final int? durationSeconds;
  final DateTime? publishedAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Track({
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
    this.imageUrl,
    required this.audioUrl,
    this.durationSeconds,
    this.publishedAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String getLocalizedTitle(String locale) => locale == 'ar' ? titleAr : titleEn;
  String? getLocalizedSubtitle(String locale) => locale == 'ar' ? subtitleAr : subtitleEn;
  String? getLocalizedDescription(String locale) => locale == 'ar' ? descriptionAr : descriptionEn;
  String? getLocalizedSpeaker(String locale) => locale == 'ar' ? speakerAr : speakerEn;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Track{id: $id, titleAr: $titleAr, categoryId: $categoryId}';
  }
}
