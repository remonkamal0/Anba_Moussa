import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_profile_provider.dart';
import 'confirm_dialog.dart';

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

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = cs.surface;
    final surface = cs.surface;
    final divider = cs.outlineVariant;

    final userProfile = ref.watch(userProfileProvider);

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        if (userProfile.email.isNotEmpty)
                          Text(
                            userProfile.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: cs.onSurface.withValues(alpha: 0.54),
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
                      accentColor: accentColor,
                      icon: Icons.queue_music,
                      title: l10n.drawerMyPlaylists,
                      onTap: () =>
                          _onNavigationItemTapped(context, '/all-playlists'),
                    ),

                    _settingsTile(
                      context,
                      accentColor: accentColor,
                      icon: Icons.translate_rounded,
                      title: l10n.drawerLanguage,
                      trailingText: locale.languageCode == 'ar'
                          ? l10n.drawerArabic
                          : l10n.drawerEnglish,
                      onTap: () {
                        final newLocale = locale.languageCode == 'ar'
                            ? 'en'
                            : 'ar';
                        ref
                            .read(localeProvider.notifier)
                            .changeLocale(newLocale);
                      },
                    ),

                    _settingsTile(
                      context,
                      accentColor: accentColor,
                      icon: Icons.nights_stay_rounded,
                      title: l10n.drawerDarkMode,
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) =>
                            ref.read(themeProvider.notifier).toggleTheme(),
                        activeColor: accentColor,
                      ),
                      onTap: () =>
                          ref.read(themeProvider.notifier).toggleTheme(),
                    ),

                    // Theme section - Colors below title
                    _themeSection(
                      context,
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
                      accentColor: accentColor,
                      icon: Icons.favorite_border_rounded,
                      title: l10n.drawerFavorites,
                      onTap: () =>
                          _onNavigationItemTapped(context, '/favorites'),
                    ),

                    _settingsTile(
                      context,
                      accentColor: accentColor,
                      icon: Icons.download_rounded,
                      title: l10n.drawerDownloads,
                      onTap: () =>
                          _onNavigationItemTapped(context, '/downloads'),
                    ),

                    _settingsTile(
                      context,
                      accentColor: accentColor,
                      icon: Icons.notifications_none_rounded,
                      title: l10n.drawerNotifications,
                      onTap: () =>
                          _onNavigationItemTapped(context, '/notifications'),
                    ),

                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 22.w,
                      ),
                      child: Container(height: 1, color: divider),
                    ),

                    _settingsTile(
                      context,
                      accentColor: Colors.red,
                      icon: Icons.delete_forever_rounded,
                      title: l10n.drawerDeleteAccount,
                      titleColor: Colors.red,
                      onTap: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          title: l10n.dialogDeleteTitle,
                          content: l10n.dialogDeleteContent,
                          cancelText: l10n.dialogCancel,
                          confirmText: l10n.dialogConfirm,
                          accentColor: accentColor,
                          confirmColor: Colors.red,
                        );
                        if (confirm == true && context.mounted) {
                          // Implement delete account logic
                          _closeDrawer(context);
                          context.go('/login');
                        }
                      },
                    ),

                    _settingsTile(
                      context,
                      accentColor: accentColor,
                      icon: Icons.info_outline_rounded,
                      title: l10n.aboutDeveloper,
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
                  onPressed: () async {
                    final confirm = await showConfirmDialog(
                      context,
                      title: l10n.dialogLogoutTitle,
                      content: l10n.dialogLogoutContent,
                      cancelText: l10n.dialogCancel,
                      confirmText: l10n.dialogConfirm,
                      accentColor: accentColor,
                      confirmColor: accentColor,
                    );
                    if (confirm == true && context.mounted) {
                      _closeDrawer(context);
                      context.go('/login');
                    }
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
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
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
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28.r),
                  ),
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
                      child: Icon(
                        Icons.headphones_rounded,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      l10n.appTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        l10n.aboutTeam,
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
                      l10n.close,
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.54),
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
    required Color accentColor,
    required IconData icon,
    required String title,
    String? trailingText,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final defaultTitleColor = cs.onSurface;
    final subColor = cs.onSurface.withValues(alpha: 0.54);

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsetsDirectional.symmetric(
        horizontal: 14.w,
        vertical: 2.h,
      ),

      leading: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: accentColor, size: 18.r),
      ),

      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: titleColor ?? defaultTitleColor,
        ),
      ),

      trailing:
          trailing ??
          (trailingText != null
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
                            fontSize: 11.sp,
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
              : Icon(Icons.chevron_right_rounded, color: subColor, size: 22.r)),
    );
  }

  // ================= Theme Section (Colors below title) =================
  Widget _themeSection(
    BuildContext context, {
    required Color accentColor,
    required WidgetRef ref,
    required String label,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(14.w, 4.h, 14.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: accentColor,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // Dots — no indent, full width
          _buildColorDots(ref),
        ],
      ),
    );
  }

  // ================= Dots =================
  Widget _buildColorDots(WidgetRef ref) {
    // Use the SAME color values as AppTheme.accentColors so comparison works
    final colors = AppTheme.accentColors.entries.toList();
    final currentAccent = ref.watch(accentColorProvider);

    return Wrap(
      spacing: 7.w,
      runSpacing: 6.h,
      children: colors.map((entry) {
        final color = entry.value;
        final name = entry.key;
        final isSelected = currentAccent == color;

        return GestureDetector(
          onTap: () =>
              ref.read(accentColorProvider.notifier).changeAccentColor(name),
          child: Container(
            width: 22.r,
            height: 22.r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2.0)
                  : null,
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: isSelected
                ? Icon(Icons.check_rounded, color: Colors.white, size: 13.r)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
