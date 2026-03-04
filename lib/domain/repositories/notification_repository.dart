import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications({int limit = 20});
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}
