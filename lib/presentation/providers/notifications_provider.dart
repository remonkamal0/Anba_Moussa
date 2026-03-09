import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/service_locator.dart';

final unreadNotificationsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  try {
    final notifications = await sl.getNotificationsUseCase.execute();
    return notifications.where((element) => !element.isRead).length;
  } catch (e) {
    return 0; // fallback gracefully if network fails
  }
});
