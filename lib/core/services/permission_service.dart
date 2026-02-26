import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  PermissionService._internal();
  static PermissionService get instance => _instance;

  /// طلب كل الـ permissions المطلوبة للتطبيق
  Future<bool> requestAllPermissions() async {
    if (!Platform.isAndroid) return true;

    final permissions = _getRequiredPermissions();
    final statuses = await permissions.request();

    final allGranted = statuses.values.every(
      (status) => status.isGranted || status.isLimited,
    );

    return allGranted;
  }

  /// جلب قائمة الـ permissions المطلوبة حسب إصدار Android
  List<Permission> _getRequiredPermissions() {
    return [
      Permission.photos,        // READ_MEDIA_IMAGES (Android 13+)
      Permission.videos,        // READ_MEDIA_VIDEO  (Android 13+)
      Permission.audio,         // READ_MEDIA_AUDIO  (Android 13+)
      Permission.storage,       // READ/WRITE_EXTERNAL_STORAGE (Android 12-)
      Permission.camera,        // CAMERA
      Permission.microphone,    // RECORD_AUDIO (للتسجيل إن وُجد)
    ];
  }

  /// التحقق ما إذا كانت permissions الميديا ممنوحة
  Future<bool> hasMediaPermissions() async {
    if (!Platform.isAndroid) return true;

    final photos = await Permission.photos.isGranted;
    final videos = await Permission.videos.isGranted;
    final audio  = await Permission.audio.isGranted;
    final storage = await Permission.storage.isGranted;

    // يكفي أي من المجموعتين (حسب إصدار Android)
    return (photos && videos && audio) || storage;
  }

  /// التحقق من صلاحية النت (لا تحتاج runtime request)
  Future<bool> hasInternetPermission() async {
    // INTERNET permission تُمنح تلقائياً عند الإضافة في Manifest
    return true;
  }

  /// فتح إعدادات التطبيق عند رفض المستخدم
  Future<void> openSettings() => openAppSettings();
}
