class Tag {
  final String id;
  final String nameAr;
  final String nameEn;

  Tag({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  String getLocalizedName(String locale) => locale == 'ar' ? nameAr : nameEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Tag{id: $id, nameEn: $nameEn}';
  }
}
