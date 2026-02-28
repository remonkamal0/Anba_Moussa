import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/mini_player_provider.dart';
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
        body: Stack(
          children: [
            widget.child,
            // Mini Player: only shown when a track is active
            Consumer(
              builder: (context, ref, _) {
                final miniState = ref.watch(miniPlayerProvider);
                if (!miniState.isVisible || miniState.track == null) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 84.h,
                  child: _MiniPlayer(state: miniState),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: _CustomBottomNav(
          items: navItems,
          currentIndex: currentIndex,
          onTap: (i) => _onItemTapped(i, context),
        ),
      ),
      borderRadius: 24.0,
      showShadow: true,
      angle: isRtl ? 12.0 : -12.0,
      drawerShadowsBackgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.black26 
          : Colors.grey[300]!,
      slideWidth: MediaQuery.of(context).size.width * 0.75,
      menuBackgroundColor: Theme.of(context).colorScheme.surface,
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(32.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.10),
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
    final cs = Theme.of(context).colorScheme;
    final orange = cs.primary;
    final grey = cs.onSurface.withValues(alpha: 0.4);

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

// ─── Mini Player ───────────────────────────────────────────────────────────────

class _MiniPlayer extends ConsumerWidget {
  final MiniPlayerState state;
  const _MiniPlayer({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(miniPlayerProvider);
    final track = state.track;
    final locale = Localizations.localeOf(context).languageCode;

    if (!state.isVisible || track == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: GestureDetector(
        onTap: () => context.push(AppConstants.playerRoute),
        child: Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? cs.surfaceVariant.withValues(alpha: 0.95)
                : const Color(0xFF1B2340),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Album thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: track.coverImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: track.coverImageUrl,
                        width: 40.w,
                        height: 40.w,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => _placeholder(),
                      )
                    : _placeholder(),
              ),

              SizedBox(width: 12.w),

              // Title & artist
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.getLocalizedTitle(locale),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      track.getLocalizedSpeaker(locale) ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Previous
              _ControlBtn(icon: Icons.skip_previous_rounded, onTap: () {}),

              // Play / Pause — wired to provider
              GestureDetector(
                onTap: () =>
                    ref.read(miniPlayerProvider.notifier).togglePlayPause(),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    state.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20.w,
                  ),
                ),
              ),

              // Next
              _ControlBtn(icon: Icons.skip_next_rounded, onTap: () {}),

              SizedBox(width: 6.w),

              // ✕ Dismiss button
              GestureDetector(
                onTap: () =>
                    ref.read(miniPlayerProvider.notifier).dismiss(),
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 16.w,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 40.w,
        height: 40.w,
        color: Colors.white12,
        child: const Icon(Icons.music_note, color: Colors.white54),
      );
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ControlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Icon(icon, color: Colors.white70, size: 22.w),
      ),
    );
  }
}
