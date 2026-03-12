class Photo {
  final String id;
  final String albumId;
  final String imageUrl;
  final String? titleAr;
  final String? titleEn;
  final String? captionAr;
  final String? captionEn;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Photo({
    required this.id,
    required this.albumId,
    required this.imageUrl,
    this.titleAr,
    this.titleEn,
    this.captionAr,
    this.captionEn,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String? getLocalizedTitle(String locale) =>
      locale == 'ar' ? titleAr : titleEn;
  String? getLocalizedCaption(String locale) =>
      locale == 'ar' ? captionAr : captionEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Photo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Photo{id: $id, albumId: $albumId, imageUrl: $imageUrl}';
  }
}
