import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  void _closeDrawer(BuildContext context) {
    final zoom = ZoomDrawer.of(context);
    if (zoom != null) zoom.close();
  }

  void _onNavigationItemTapped(BuildContext context, String route) {
    _closeDrawer(context);
    context.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final accentColor = ref.watch(accentColorProvider);

    final isDark = themeMode == ThemeMode.dark;

    final bg = isDark ? const Color(0xFF121212) : Colors.white;
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final divider = isDark ? Colors.white12 : const Color(0xFFE9EDF3);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ================= Header =================
            Container(
              width: double.infinity,
              color: surface,
              padding: EdgeInsetsDirectional.fromSTEB(22.w, 22.h, 22.w, 16.h),
              child: Row(
                children: [
                  Container(
                    width: 70.r,
                    height: 70.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.18),
                      border: Border.all(
                        color: isDark ? Colors.white12 : const Color(0xFFE6E6E6),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 32.r,
                      color: accentColor,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remon Kamal',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : const Color(0xFF1B2430),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'remon@example.com',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF7B8794),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(height: 1, color: divider),

            // ================= Content =================
            Expanded(
              child: Container(
                color: surface,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _settingsTile(
                      context,
                      isDark: isDark,
                      accentColor: accentColor,
                      icon: Icons.queue_music,
                      title: l10n.drawerMyPlaylists,
                      onTap: () {},
                    ),

                    _settingsTile(
                      context,
                      isDark: isDark,
                      accentColor: accentColor,
                      icon: Icons.translate_rounded,
                      title: l10n.drawerLanguage,
                      trailingText: locale.languageCode == 'ar'
                          ? l10n.drawerArabic
                          : l10n.drawerEnglish,
                      onTap: () {
                        final newLocale =
                            locale.languageCode == 'ar' ? 'en' : 'ar';
                        ref.read(localeProvider.notifier).changeLocale(newLocale);
                      },
                    ),

                    _settingsTile(
                      context,
                      isDark: isDark,
                      accentColor: accentColor,
                      icon: Icons.nights_stay_rounded,
                      title: l10n.drawerDarkMode,
                      onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
                    ),

                    // Theme section - Colors below title
                    _themeSection(
                      isDark: isDark,
                      accentColor: accentColor,
                      ref: ref,
                      label: l10n.drawerTheme,
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22.w),
                      child: Container(height: 1, color: divider),
                    ),

                    _settingsTile(
                      context,
                      isDark: isDark,
                      accentColor: accentColor,
                      icon: Icons.favorite_border_rounded,
                      title: l10n.drawerFavorites,
                      onTap: () => _onNavigationItemTapped(context, '/favorites'),
                    ),

                    _settingsTile(
                      context,
                      isDark: isDark,
                      accentColor: accentColor,
                      icon: Icons.download_rounded,
                      title: l10n.drawerDownloads,
                      onTap: () {},
                    ),

                    _settingsTile(
                      context,
                      isDark: isDark,
                      accentColor: accentColor,
                      icon: Icons.notifications_none_rounded,
                      title: l10n.drawerNotifications,
                      onTap: () => _onNavigationItemTapped(context, '/notifications'),
                    ),

                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 22.w),
                      child: Container(height: 1, color: divider),
                    ),

                    _settingsTile(
                      context,
                      isDark: isDark,
                      accentColor: Colors.red,
                      icon: Icons.delete_forever_rounded,
                      title: l10n.drawerDeleteAccount,
                      titleColor: Colors.red,
                      onTap: () {
                        // Implement delete account logic
                      },
                    ),

                    _settingsTile(
                      context,
                      isDark: isDark,
                      accentColor: accentColor,
                      icon: Icons.info_outline_rounded,
                      title: 'About Developer',
                      onTap: () {
                        _closeDrawer(context);
                        _showAboutDialog(context, accentColor);
                      },
                    ),

                    SizedBox(height: 18.h),
                  ],
                ),
              ),
            ),

            // ================= Logout Button =================
            Container(
              color: surface,
              padding: EdgeInsetsDirectional.fromSTEB(22.w, 10.h, 22.w, 18.h),
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _closeDrawer(context);
                    context.go('/login');
                  },
                  icon: Icon(Icons.logout, size: 20.r),
                  label: Text(
                    l10n.drawerLogOut,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor.withValues(alpha: 0.12),
                    foregroundColor: accentColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, Color accent) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Gradient header ──────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 28.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.headphones_rounded, color: Colors.white, size: 32.sp),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Anba Moussa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'About the Team',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Team cards ────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 8.h),
                child: Column(
                  children: [
                    _aboutCard(
                      role: 'UI/UX Designer',
                      name: 'Louis Samir',
                      icon: Icons.design_services_rounded,
                      roleColor: const Color(0xFF7C3AED),
                      roleBg: const Color(0xFFF3EEFF),
                    ),
                    SizedBox(height: 12.h),
                    _aboutCard(
                      role: 'Mobile Developer',
                      name: 'Remon Kamal',
                      icon: Icons.phone_android_rounded,
                      roleColor: accent,
                      roleBg: accent.withValues(alpha: 0.10),
                    ),
                  ],
                ),
              ),

              // ── Close button ──────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F5F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aboutCard({
    required String role,
    required String name,
    required IconData icon,
    required Color roleColor,
    required Color roleBg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE9EDF3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(color: roleBg, shape: BoxShape.circle),
            child: Icon(icon, color: roleColor, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: roleBg,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= Tile =================
  Widget _settingsTile(
    BuildContext context, {
    required bool isDark,
    required Color accentColor,
    required IconData icon,
    required String title,
    String? trailingText,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    final defaultTitleColor = isDark ? Colors.white : const Color(0xFF1B2430);
    final subColor = isDark ? Colors.white54 : const Color(0xFF8A97A6);

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsetsDirectional.symmetric(horizontal: 22.w, vertical: 6.h),

      leading: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: accentColor, size: 22.r),
      ),

      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: titleColor ?? defaultTitleColor,
        ),
      ),

      trailing: trailingText != null
          ? ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 90.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      trailingText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: subColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: subColor,
                    size: 22.r,
                  ),
                ],
              ),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: subColor,
              size: 22.r,
            ),
    );
  }

  // ================= Theme Section (Colors below title) =================
  Widget _themeSection({
    required bool isDark,
    required Color accentColor,
    required WidgetRef ref,
    required String label,
  }) {
    final titleColor = isDark ? Colors.white : const Color(0xFF1B2430);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(22.w, 8.h, 22.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.palette_outlined, color: accentColor, size: 22.r),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 58.w),
            child: _buildColorDots(ref),
          ),
        ],
      ),
    );
  }

  // ================= Dots =================
  Widget _buildColorDots(WidgetRef ref) {
    final colors = [
      {'name': 'orange', 'color': const Color(0xFFF16122)},
      {'name': 'blue', 'color': const Color(0xFF2E88FF)},
      {'name': 'green', 'color': const Color(0xFF00E676)},
      {'name': 'purple', 'color': const Color(0xFF8A2BE2)},
      {'name': 'pink', 'color': const Color(0xFFFF1493)},
    ];

    final currentAccent = ref.watch(accentColorProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: colors.map((c) {
          final color = c['color'] as Color;
          final name = c['name'] as String;
          final isSelected = currentAccent == color;

          return GestureDetector(
            onTap: () =>
                ref.read(accentColorProvider.notifier).changeAccentColor(name),
            child: Container(
              margin: EdgeInsetsDirectional.symmetric(horizontal: 5.w),
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
          ),
        );
        }).toList(),
      ),
    );
  }
}