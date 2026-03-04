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
}
