class SliderModel {
  final String id;
  final String? imageUrl;
  final String? titleAr;
  final String? titleEn;
  final String? subtitleAr;
  final String? subtitleEn;
  final String? linkUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SliderModel({
    required this.id,
    this.imageUrl,
    this.titleAr,
    this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.linkUrl,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) => SliderModel(
    id: json['id'] as String,
    imageUrl: json['image_url'] as String?,
    titleAr: json['title_ar'] as String?,
    titleEn: json['title_en'] as String?,
    subtitleAr: json['subtitle_ar'] as String?,
    subtitleEn: json['subtitle_en'] as String?,
    linkUrl: json['link_url'] as String?,
    sortOrder: json['sort_order'] as int? ?? 0,
    isActive: json['is_active'] as bool? ?? true,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'image_url': imageUrl,
    'title_ar': titleAr,
    'title_en': titleEn,
    'subtitle_ar': subtitleAr,
    'subtitle_en': subtitleEn,
    'link_url': linkUrl,
    'sort_order': sortOrder,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  String getLocalizedTitle(String locale) {
    return locale == 'ar' ? (titleAr ?? '') : (titleEn ?? '');
  }

  String? getLocalizedSubtitle(String locale) {
    return locale == 'ar' ? subtitleAr : subtitleEn;
  }
}
