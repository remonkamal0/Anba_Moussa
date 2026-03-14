import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../network/supabase_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp()` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  late final FirebaseMessaging _fcm;
  late final FlutterLocalNotificationsPlugin _localNotifications;

  // Stream for notification taps
  final _onTapController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onTap => _onTapController.stream;

  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription =
      'This channel is used for important notifications.';

  Future<void> initialize() async {
    try {
      // 1. Initialize Firebase
      await Firebase.initializeApp();
      _fcm = FirebaseMessaging.instance;
      _localNotifications = FlutterLocalNotificationsPlugin();

      // 2. Set background handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 3. Setup Local Notifications
      await _setupLocalNotifications();

      // 4. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        _showLocalNotification(message);
      });

      // 5. Handle notification taps
      // When the app is opened from a terminated state via a notification
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageTap(initialMessage.data);
      }

      // When the app is in the background and opened via a notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessageTap(message.data);
      });

      // 6. Request permissions (for iOS and Android 13+)
      await requestPermissions();

      // 7. Save token if user is logged in
      await saveTokenToSupabase();
    } catch (e) {
      print("Firebase initialization skipped or failed: $e");
      print(
        "Note: Push notifications require google-services.json (Android) and GoogleService-Info.plist (iOS).",
      );
    }
  }

  Future<void> saveTokenToSupabase() async {
    try {
      final token = await getToken();
      if (token != null && SupabaseService.instance.isAuthenticated) {
        final uid = SupabaseService.instance.currentUserId;
        if (uid != null) {
          await SupabaseService.instance.client
              .from('profiles')
              .update({'fcm_token': token})
              .eq('id', uid);
        }
      }
    } catch (e) {
      print("Error saving FCM token to Supabase: $e");
    }
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null) {
          final data = jsonDecode(details.payload!) as Map<String, dynamic>;
          _handleMessageTap(data);
        }
      },
    );

    // Create High Importance Channel for Android
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDescription,
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
              showBadge: true,
            ),
          );
    }
  }

  Future<void> requestPermissions() async {
    // iOS
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Android 13+ handled by permission_handler or native request
    // Local notifications permission
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null && !kIsWeb) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            icon: android.smallIcon,
            playSound: true,
            visibility: NotificationVisibility.public, // Show on lock screen
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleMessageTap(Map<String, dynamic> data) {
    print("Notification Tapped with data: $data");
    _onTapController.add(data);
  }

  void dispose() {
    _onTapController.close();
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
