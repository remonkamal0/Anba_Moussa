class Slider {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? linkUrl;
  final int? sortOrder;
  final bool isActive;

  const Slider({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.linkUrl,
    this.sortOrder,
    this.isActive = true,
  });

  factory Slider.fromMap(Map<String, dynamic> map) {
    return Slider(
      id: map['id'] as String,
      title: (map['title_ar'] as String?) ?? (map['title_en'] as String?) ?? 'بدون عنوان',
      subtitle: (map['subtitle_ar'] as String?) ?? (map['subtitle_en'] as String?),
      imageUrl: map['image_url'] as String?,
      linkUrl: map['link_url'] as String?,
      sortOrder: map['sort_order'] as int?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  Slider copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? linkUrl,
    int? sortOrder,
    bool? isActive,
  }) {
    return Slider(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
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
    return 'Slider(id: $id, title: $title)';
  }
}
