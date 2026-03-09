import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'core/di/service_locator.dart';
import 'l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/network/supabase_service.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/services/permission_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('downloads');

  // Initialize Supabase
  await SupabaseService.instance.initialize();

  // Initialize Service Locator
  sl.init();

  // Initialize Notifications
  await NotificationService.instance.initialize();

  // Configure Audio Session
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  // Listen to audio session events (e.g., unplugging headphones)
  session.becomingNoisyEventStream.listen((_) {
    // This is handled by default in just_audio_background if configured,
    // but explicit handling can be added here if needed.
  });

  // Request runtime permissions (internet only needed now)
  await PermissionService.instance.requestAllPermissions();

  // Initialize just_audio_background (Must be before runApp)
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.anba_moussa.audio.channel.audio',
    androidNotificationChannelName: 'Anba Moussa Audio',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
    notificationColor: const Color(0xFF1E88E5),
  );

  runApp(
    ProviderScope(
      child: const MelodixApp(),
    ),
  );
}

class MelodixApp extends ConsumerStatefulWidget {
  const MelodixApp({super.key});

  @override
  ConsumerState<MelodixApp> createState() => _MelodixAppState();
}

class _MelodixAppState extends ConsumerState<MelodixApp> {
  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    NotificationService.instance.onTap.listen((data) {
      final router = ref.read(appRouterProvider);
      _handleNavigation(router, data);
    });
  }

  void _handleNavigation(GoRouter router, Map<String, dynamic> data) {
    final String? route = data['internal_route'];
    final String? id = data['internal_id'] ?? data['id'];
    
    if (route == null) return;

    if (route.contains('/:')) {
      // Handle parameterized routes
      if (id != null) {
        final target = route.replaceAll(RegExp(r'/:[^/]+'), '/$id');
        router.push(target);
      }
    } else {
      router.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    final accentColor = ref.watch(accentColorProvider);
    final appRouter = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(accentColor: accentColor, locale: locale),
          darkTheme: AppTheme.dark(accentColor: accentColor, locale: locale),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: appRouter,
        );
      },
    );
  }
}
