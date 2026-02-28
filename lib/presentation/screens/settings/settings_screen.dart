import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../playlist/create_playlist_screen.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int selectedThemeIndex = 0;

  final List<_PlaylistItem> playlists = const [
    _PlaylistItem(
      title: "Vibe Check",
      subtitle: "24 songs",
      imageUrl:
          "https://images.unsplash.com/photo-1526481280695-3c687fd5432c?w=800&q=80",
    ),
    _PlaylistItem(
      title: "Sunset Beats",
      subtitle: "18 songs",
      imageUrl:
          "https://images.unsplash.com/photo-1520975958225-84ea3e1aa7a5?w=800&q=80",
    ),
    _PlaylistItem(
      title: "Deep Focus",
      subtitle: "42 songs",
      imageUrl:
          "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80",
    ),
  ];

  final List<Color> themeColors = const [
    Color(0xFFFF6B35), // orange
    Color(0xFF2F80ED), // blue
    Color(0xFF27AE60), // green
    Color(0xFF9B51E0), // purple
    Color(0xFFEB5757), // red
  ];

  Color get accent => Theme.of(context).colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    final darkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Stack(
        children: [
          // soft gradient header background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260.h,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark ? cs.surfaceContainerHigh : const Color(0xFFFFF4EE),
                    cs.surface,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header row: drawer toggle + title (auto RTL-aware)
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => ZoomDrawer.of(context)?.toggle(),
                        child: Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: cs.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .05),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.menu_rounded,
                            size: 22.w,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Settings",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      // Spacer to balance the menu button and keep title centered
                      SizedBox(width: 42.w),
                    ],
                  ),

                  SizedBox(height: 18.h),

                  // Avatar + edit icon
                  _AvatarWithEdit(
                    accent: accent,
                    imageUrl:
                        "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&q=80",
                    onEdit: () {
                      // TODO: change avatar
                    },
                  ),

                  SizedBox(height: 14.h),

                  Text(
                    "Alex Rivera",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "alex.rivera@example.com",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: cs.onSurface.withValues(alpha: .6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Edit Profile button
                  _PrimarySoftButton(
                    text: "Edit Profile",
                    onTap: () {
                      context.push('/profile/edit');
                    },
                  ),

                  SizedBox(height: 22.h),

                  // MY PLAYLISTS header row
                  _SectionHeaderRow(
                    leftText: "MY PLAYLISTS",
                    rightText: "See All",
                    accent: accent,
                    onAdd: () async {
                      final newPlaylist = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreatePlaylistScreen(),
                        ),
                      );
                      
                      if (newPlaylist != null) {
                        // TODO: Implement actual playlist creation logic
                      }
                    },
                    onSeeAll: () {
                      context.push('/all-playlists');
                    },
                  ),

                  SizedBox(height: 10.h),

                  SizedBox(
                    height: 145.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: playlists.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemBuilder: (context, index) {
                        final p = playlists[index];
                        return _PlaylistCard(item: p);
                      },
                    ),
                  ),

                  SizedBox(height: 18.h),

                  _SectionTitle("PREFERENCES"),
                  SizedBox(height: 10.h),

                  _CardContainer(
                    child: Column(
                      children: [
                        _RowTile(
                          icon: Icons.translate,
                          iconBg: accent.withValues(alpha: .12),
                          iconColor: accent,
                          title: AppLocalizations.of(context)?.drawerLanguage ?? "Language",
                          trailingText: ref.watch(localeProvider).languageCode == 'ar' 
                              ? AppLocalizations.of(context)?.drawerArabic 
                              : AppLocalizations.of(context)?.drawerEnglish,
                          onTap: () {
                            final currentCode = ref.read(localeProvider).languageCode;
                            final newLocale = currentCode == 'ar' ? 'en' : 'ar';
                            ref.read(localeProvider.notifier).changeLocale(newLocale);
                          },
                        ),
                        _DividerIndent(),
                        _RowTile(
                          icon: Icons.dark_mode_outlined,
                          iconBg: accent.withValues(alpha: .12),
                          iconColor: accent,
                          title: "Dark Mode",
                          trailing: Switch(
                            value: darkMode,
                            onChanged: (v) => ref.read(themeProvider.notifier).toggleTheme(),
                            activeColor: accent,
                          ),
                          onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
                        ),
                        _DividerIndent(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          child: Row(
                            children: [
                              _IconBadge(
                                icon: Icons.palette_outlined,
                                bg: accent.withOpacity(.12),
                                color: accent,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  "Theme Customization",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                _themeName(selectedThemeIndex),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 14.w,
                            right: 14.w,
                            bottom: 14.h,
                          ),
                          child: Row(
                            children: List.generate(themeColors.length, (i) {
                              final c = themeColors[i];
                              final selected = i == selectedThemeIndex;
                              return GestureDetector(
                                onTap: () => setState(() => selectedThemeIndex = i),
                                child: Container(
                                  margin: EdgeInsets.only(right: 10.w),
                                  width: 26.w,
                                  height: 26.w,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected ? cs.onSurface : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  _SectionTitle("MY LIBRARY"),
                  SizedBox(height: 10.h),

                  _CardContainer(
                    child: Column(
                      children: [
                        _RowTile(
                          icon: Icons.favorite_border,
                          iconBg: accent.withOpacity(.12),
                          iconColor: accent,
                          title: "Favorites",
                          onTap: () {
                            context.push('/favorites');
                          },
                        ),
                        _DividerIndent(),
                        _RowTile(
                          icon: Icons.download_outlined,
                          iconBg: accent.withOpacity(.12),
                          iconColor: accent,
                          title: "Downloads",
                          onTap: () {
                            context.push('/downloads');
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  _SectionTitle("SECURITY & ALERTS"),
                  SizedBox(height: 10.h),

                  _CardContainer(
                    child: Column(
                      children: [
                        _RowTile(
                          icon: Icons.notifications_none,
                          iconBg: accent.withValues(alpha: .12),
                          iconColor: accent,
                          title: AppLocalizations.of(context)?.drawerNotifications ?? "Notifications",
                          onTap: () {
                            context.push('/notifications');
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // About Developer button
                  _CardContainer(
                    child: _RowTile(
                      icon: Icons.info_outline_rounded,
                      iconBg: accent.withOpacity(.12),
                      iconColor: accent,
                      title: "About Developer",
                      onTap: () => _showAboutDeveloper(context, accent),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // Log out
                  TextButton.icon(
                    onPressed: () async {
                      final l10n = AppLocalizations.of(context)!;
                      final confirm = await showConfirmDialog(
                        context,
                        title: l10n.dialogLogoutTitle,
                        content: l10n.dialogLogoutContent,
                        cancelText: l10n.dialogCancel,
                        confirmText: l10n.dialogConfirm,
                        accentColor: accent,
                        confirmColor: accent,
                      );
                      if (confirm == true && context.mounted) {
                        ZoomDrawer.of(context)?.close();
                        context.go('/login');
                      }
                    },
                    icon: Icon(Icons.logout, color: accent),
                    label: Text(
                      AppLocalizations.of(context)?.drawerLogOut ?? "Log Out",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Delete account button
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final l10n = AppLocalizations.of(context)!;
                        final confirm = await showConfirmDialog(
                          context,
                          title: l10n.dialogDeleteTitle,
                          content: l10n.dialogDeleteContent,
                          cancelText: l10n.dialogCancel,
                          confirmText: l10n.dialogConfirm,
                          accentColor: accent,
                          confirmColor: const Color(0xFFEB5757),
                        );
                        if (confirm == true && context.mounted) {
                          // Implement delete account logic here
                          ZoomDrawer.of(context)?.close();
                          context.go('/login');
                        }
                      },
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEB5757)),
                      label: Text(
                        AppLocalizations.of(context)?.drawerDeleteAccount ?? "Delete Account",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFEB5757),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFFEB5757).withValues(alpha: .25),
                          width: 1.2,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        backgroundColor: const Color(0xFFEB5757).withValues(alpha: 0.1),
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showAboutDeveloper(BuildContext context, Color accent) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 28.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.75)],
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
                      style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'About the Team',
                        style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600, letterSpacing: 0.8),
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
                    _teamCard(
                      accent: accent,
                      role: 'UI/UX Designer',
                      name: 'Louis Samir',
                      icon: Icons.design_services_rounded,
                      roleColor: const Color(0xFF7C3AED),
                      roleBg: const Color(0xFFF3EEFF),
                    ),
                    SizedBox(height: 12.h),
                    _teamCard(
                      accent: accent,
                      role: 'Mobile Developer',
                      name: 'Remon Kamal',
                      icon: Icons.phone_android_rounded,
                      roleColor: accent,
                      roleBg: accent.withOpacity(0.10),
                    ),
                  ],
                ),
              ),

              // ── Close ─────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14.sp, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamCard({
    required Color accent,
    required String role,
    required String name,
    required IconData icon,
    required Color roleColor,
    required Color roleBg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: roleBg,
              shape: BoxShape.circle,
            ),
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
                  child: Text(role, style: TextStyle(color: roleColor, fontSize: 10.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
                SizedBox(height: 5.h),
                Text(name, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeName(int i) {
    switch (i) {
      case 0:
        return "Orange";
      case 1:
        return "Blue";
      case 2:
        return "Green";
      case 3:
        return "Purple";
      case 4:
        return "Red";
      default:
        return "Custom";
    }
  }

}


class _AvatarWithEdit extends StatelessWidget {
  final Color accent;
  final String imageUrl;
  final VoidCallback onEdit;

  const _AvatarWithEdit({
    required this.accent,
    required this.imageUrl,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 108.w,
          height: 108.w,
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.black12),
              errorWidget: (_, __, ___) => Container(
                color: Colors.black12,
                child: Icon(Icons.person, size: 40.w, color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          right: 2.w,
          bottom: 2.w,
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.surface, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.edit, color: Colors.white, size: 16.w),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimarySoftButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _PrimarySoftButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170.w,
      height: 42.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _SectionHeaderRow extends StatelessWidget {
  final String leftText;
  final String rightText;
  final Color accent;
  final VoidCallback onAdd;
  final VoidCallback onSeeAll;

  const _SectionHeaderRow({
    required this.leftText,
    required this.rightText,
    required this.accent,
    required this.onAdd,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          leftText,
          style: TextStyle(
            letterSpacing: 1.2,
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        SizedBox(width: 10.w),
        InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.10),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.add, color: Colors.white, size: 16.w),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onSeeAll,
          child: Text(
            rightText,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          letterSpacing: 1.2,
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RowTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback onTap;

  const _RowTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.trailingText,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            _IconBadge(icon: icon, bg: iconBg, color: iconColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            if (trailing != null) trailing!,
            if (trailing == null)
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 22.w),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;

  const _IconBadge({
    required this.icon,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: color, size: 20.w),
    );
  }
}

class _DividerIndent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
      indent: 66.w,
      endIndent: 0,
    );
  }
}

class _PlaylistItem {
  final String title;
  final String subtitle;
  final String imageUrl;

  const _PlaylistItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

class _PlaylistCard extends StatelessWidget {
  final _PlaylistItem item;
  const _PlaylistCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/playlist/1'); // Using dummy ID 1 for now
      },
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.black12),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.black12,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            item.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    ));
  }
}