import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../common/app_drawer.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppConstants.homeRoute)) return 0;
    if (location.startsWith('/library')) return 1;
    if (location.startsWith('/photo-gallery')) return 2;
    if (location.startsWith('/video-gallery')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppConstants.homeRoute);
        break;
      case 1:
        context.go('/library');
        break;
      case 2:
        context.go('/photo-gallery');
        break;
      case 3:
        context.go('/video-gallery');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = _calculateSelectedIndex(context);
    final locale = ref.watch(localeProvider);
    final isRtl = locale.languageCode == 'ar';

    final navItems = [
      _NavItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l10n.navigationHome,
      ),
      _NavItemData(
        icon: Icons.library_music_outlined,
        activeIcon: Icons.library_music_rounded,
        label: l10n.navigationLibrary,
      ),
      _NavItemData(
        icon: Icons.photo_library_outlined,
        activeIcon: Icons.photo_library_rounded,
        label: l10n.navigationGallery,
      ),
      _NavItemData(
        icon: Icons.play_circle_outline,
        activeIcon: Icons.play_circle_rounded,
        label: l10n.navigationVideos,
      ),
      _NavItemData(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: l10n.navigationSettings,
      ),
    ];

    return ZoomDrawer(
      controller: _drawerController,
      style: DrawerStyle.defaultStyle,
      menuScreen: const AppDrawer(),
      isRtl: isRtl,
      mainScreen: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: widget.child,
        bottomNavigationBar: _CustomBottomNav(
          items: navItems,
          currentIndex: currentIndex,
          onTap: (i) => _onItemTapped(i, context),
        ),
      ),
      borderRadius: 24.0,
      showShadow: true,
      angle: isRtl ? 12.0 : -12.0,
      drawerShadowsBackgroundColor: Colors.grey[300]!,
      slideWidth: MediaQuery.of(context).size.width * 0.75,
      menuBackgroundColor: Colors.white,
    );
  }
}

// ─── Custom Bottom Navigation ──────────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData({required this.icon, required this.activeIcon, required this.label});
}

class _CustomBottomNav extends StatelessWidget {
  final List<_NavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CustomBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: Container(
          height: 64.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: _NavTile(
                  item: item,
                  isActive: isActive,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItemData item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFF05A28);
    const grey = Color(0xFF9AA3B2);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isActive ? item.activeIcon : item.icon,
              key: ValueKey(isActive),
              color: isActive ? orange : grey,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? orange : grey,
            ),
          ),
        ],
      ),
    );
  }
}
