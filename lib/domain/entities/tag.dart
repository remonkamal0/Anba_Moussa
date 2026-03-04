class Tag {
  final String id;
  final String titleAr;
  final String titleEn;

  Tag({
    required this.id,
    String? titleAr,
    String? titleEn,
  })  : titleAr = titleAr ?? '',
        titleEn = titleEn ?? '';

  String getLocalizedName(String locale) => locale == 'ar' ? (titleAr) : (titleEn);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Tag{id: $id, titleEn: $titleEn}';
  }
}
