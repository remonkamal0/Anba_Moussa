class Track {
  final String id;
  final String categoryId;
  final String title;
  final String? subtitle;
  final String? description;
  final String? speaker;
  final String? coverImageUrl;
  final String audioUrl;
  final int? durationSeconds;
  final DateTime? publishedAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Track({
    required this.id,
    required this.categoryId,
    required this.title,
    this.subtitle,
    this.description,
    this.speaker,
    this.coverImageUrl,
    required this.audioUrl,
    this.durationSeconds,
    this.publishedAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

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
    return 'Track{id: $id, title: $title, categoryId: $categoryId}';
  }
}
