class PhotoAlbum {
  final String id;
  final String? slug;
  final String titleAr;
  final String titleEn;
  final String? subtitleAr;
  final String? subtitleEn;
  final String? coverImageUrl;
  final String? descriptionAr;
  final String? descriptionEn;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PhotoAlbum({
    required this.id,
    this.slug,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.coverImageUrl,
    this.descriptionAr,
    this.descriptionEn,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String getLocalizedTitle(String locale) => locale == 'ar' ? titleAr : titleEn;
  String? getLocalizedSubtitle(String locale) =>
      locale == 'ar' ? subtitleAr : subtitleEn;
  String? getLocalizedDescription(String locale) =>
      locale == 'ar' ? descriptionAr : descriptionEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoAlbum && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PhotoAlbum{id: $id, titleAr: $titleAr, slug: $slug}';
  }
}
