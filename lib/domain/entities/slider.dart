class Slider {
  final String id;
  final String titleAr;
  final String titleEn;
  final String? subtitleAr;
  final String? subtitleEn;
  final String? imageUrl;
  final String? linkUrl;
  final int? sortOrder;
  final bool isActive;

  const Slider({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.imageUrl,
    this.linkUrl,
    this.sortOrder,
    this.isActive = true,
  });

  factory Slider.fromMap(Map<String, dynamic> map) {
    return Slider(
      id: map['id'] as String,
      titleAr: map['title_ar'] as String? ?? '',
      titleEn: map['title_en'] as String? ?? '',
      subtitleAr: map['subtitle_ar'] as String?,
      subtitleEn: map['subtitle_en'] as String?,
      imageUrl: map['image_url'] as String?,
      linkUrl: map['link_url'] as String?,
      sortOrder: map['sort_order'] as int?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  String getLocalizedTitle(String locale) => locale == 'ar' ? titleAr : titleEn;
  String? getLocalizedSubtitle(String locale) => locale == 'ar' ? subtitleAr : subtitleEn;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title_ar': titleAr,
      'title_en': titleEn,
      'subtitle_ar': subtitleAr,
      'subtitle_en': subtitleEn,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  Slider copyWith({
    String? id,
    String? titleAr,
    String? titleEn,
    String? subtitleAr,
    String? subtitleEn,
    String? imageUrl,
    String? linkUrl,
    int? sortOrder,
    bool? isActive,
  }) {
    return Slider(
      id: id ?? this.id,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      subtitleAr: subtitleAr ?? this.subtitleAr,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      imageUrl: imageUrl ?? this.imageUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Slider && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Slider(id: $id, titleAr: $titleAr)';
  }
}
