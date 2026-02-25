class Playlist {
  final String id;
  final String? userId;
  final String ownerType;
  final bool isPublic;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    this.userId,
    required this.ownerType,
    required this.isPublic,
    required this.title,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Playlist{id: $id, title: $title, ownerType: $ownerType}';
  }
}
