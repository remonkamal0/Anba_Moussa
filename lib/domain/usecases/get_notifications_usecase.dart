import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<AppNotification>> execute({int limit = 20}) async {
    return await repository.getNotifications(limit: limit);
  }
}
