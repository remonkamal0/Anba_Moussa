import '../../domain/entities/notification.dart';

class NotificationModel {
  final String id;
  final String kind;
  final String audience;
  final String titleAr;
  final String titleEn;
  final String? bodyAr;
  final String? bodyEn;
  final String? imageUrl;
  final String? actionType;
  final String? externalUrl;
  final String? internalRoute;
  final String? internalId;
  final String? entityType;
  final String? entityId;
  final DateTime? sentAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.kind,
    required this.audience,
    required this.titleAr,
    required this.titleEn,
    this.bodyAr,
    this.bodyEn,
    this.imageUrl,
    this.actionType,
    this.externalUrl,
    this.internalRoute,
    this.internalId,
    this.entityType,
    this.entityId,
    this.sentAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      kind: json['kind'] ?? 'general',
      audience: json['audience'] ?? 'all',
      titleAr: json['title_ar'] ?? '',
      titleEn: json['title_en'] ?? '',
      bodyAr: json['body_ar'],
      bodyEn: json['body_en'],
      imageUrl: json['image_url'],
      actionType: json['action_type'] ?? 'none',
      externalUrl: json['external_url'],
      internalRoute: json['internal_route'],
      internalId: json['internal_id'],
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  AppNotification toEntity({bool isRead = false, DateTime? readAt}) {
    return AppNotification(
      id: id,
      kind: kind,
      audience: audience,
      titleAr: titleAr,
      titleEn: titleEn,
      bodyAr: bodyAr ?? '',
      bodyEn: bodyEn ?? '',
      imageUrl: imageUrl,
      actionType: actionType,
      externalUrl: externalUrl,
      internalRoute: internalRoute,
      internalId: internalId,
      entityType: entityType,
      entityId: entityId,
      sentAt: sentAt ?? createdAt,
      isRead: isRead,
      readAt: readAt,
    );
  }
}
