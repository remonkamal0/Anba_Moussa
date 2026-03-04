class AppNotification {
  final String id;
  final String kind;
  final String audience;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final String? imageUrl;
  final String? actionType;
  final String? externalUrl;
  final String? internalRoute;
  final String? internalId;
  final String? entityType;
  final String? entityId;
  final DateTime sentAt;
  final bool isRead;
  final DateTime? readAt;

  AppNotification({
    required this.id,
    required this.kind,
    required this.audience,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    this.imageUrl,
    this.actionType,
    this.externalUrl,
    this.internalRoute,
    this.internalId,
    this.entityType,
    this.entityId,
    required this.sentAt,
    this.isRead = false,
    this.readAt,
  });

  String getLocalizedTitle(String locale) => locale == 'ar' ? titleAr : titleEn;
  String getLocalizedBody(String locale) => locale == 'ar' ? bodyAr : bodyEn;

  AppNotification copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
      kind: kind,
      audience: audience,
      titleAr: titleAr,
      titleEn: titleEn,
      bodyAr: bodyAr,
      bodyEn: bodyEn,
      imageUrl: imageUrl,
      actionType: actionType,
      externalUrl: externalUrl,
      internalRoute: internalRoute,
      internalId: internalId,
      entityType: entityType,
      entityId: entityId,
      sentAt: sentAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}
