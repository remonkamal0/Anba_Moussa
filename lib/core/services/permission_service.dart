import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  PermissionService._internal();
  static PermissionService get instance => _instance;

  /// طلب الـ permissions المطلوبة للتطبيق (إنترنت فقط — لا يحتاج runtime request)
  Future<bool> requestAllPermissions() async {
    // التطبيق يشتغل على ستريمينج من النت فقط
    // INTERNET و ACCESS_NETWORK_STATE بيتمنحوا تلقائياً من الـ Manifest
    return true;
  }

  /// فتح إعدادات التطبيق
  Future<void> openSettings() => openAppSettings();
}
