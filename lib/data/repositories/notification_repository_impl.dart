import '../../core/network/supabase_service.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseService _supabaseService;

  NotificationRepositoryImpl(this._supabaseService);

  @override
  Future<List<AppNotification>> getNotifications({int limit = 20}) async {
    final raw = await _supabaseService.getNotifications(limit: limit);

    return raw.map((map) {
      final nJson = map['notifications'] as Map<String, dynamic>;
      final isRead = map['is_read'] as bool? ?? false;
      final readAtStr = map['read_at'] as String?;
      final readAt = readAtStr != null ? DateTime.parse(readAtStr) : null;

      return NotificationModel.fromJson(
        nJson,
      ).toEntity(isRead: isRead, readAt: readAt);
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
