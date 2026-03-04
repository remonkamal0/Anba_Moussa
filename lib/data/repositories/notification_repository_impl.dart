import '../../core/network/supabase_service.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseService _supabaseService;

  NotificationRepositoryImpl(this._supabaseService);

  @override
  Future<List<AppNotification>> getNotifications({int limit = 20}) async {
    final raw = await _supabaseService.getNotifications(limit: limit);
    
    return raw.map((map) {
      final n = map['notifications'] as Map<String, dynamic>;
      final r = map['notification_recipients'] as Map<String, dynamic>?;
      
      return AppNotification(
        id: n['id'],
        kind: n['kind'] ?? 'system',
        audience: n['audience'] ?? 'all',
        titleAr: n['title_ar'] ?? '',
        titleEn: n['title_en'] ?? '',
        bodyAr: n['body_ar'] ?? '',
        bodyEn: n['body_en'] ?? '',
        imageUrl: n['image_url'],
        actionType: n['action_type'],
        externalUrl: n['external_url'],
        internalRoute: n['internal_route'],
        internalId: n['internal_id'],
        entityType: n['entity_type'],
        entityId: n['entity_id'],
        sentAt: DateTime.parse(n['sent_at'] ?? n['created_at']),
        isRead: r?['is_read'] ?? false,
        readAt: r?['read_at'] != null ? DateTime.parse(r!['read_at']) : null,
      );
    }).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _supabaseService.markNotificationAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    await _supabaseService.markAllNotificationsAsRead();
  }
}
