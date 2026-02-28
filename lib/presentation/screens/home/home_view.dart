import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../domain/entities/track.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/slider.dart' as entity_slider;
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/app_drawer.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/home_provider.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl.homeProvider..initialize(),
      child: const _HomeViewContent(),
    );
  }
}

class _HomeViewContent extends StatefulWidget {
  const _HomeViewContent();

  @override
  State<_HomeViewContent> createState() => _HomeViewContentState();
}

class _HomeViewContentState extends State<_HomeViewContent> {
  final _pageController = PageController(viewportFraction: 0.90);
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    // Left empty since CarouselSlider manages its own auto-play
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
          return provider.state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => _ErrorView(message: message),
            loaded: (tracks, categories, sliders, favoriteIds, currentIndex) {
              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                drawer: AppDrawer(),
                body: SafeArea(
                  child: Column(
                    children: [
                      _TopBar(
                        userName: 'Guest',
                        onSearch: () {},
                        onNotifications: () {},
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SliderSection(
                                  pageController: _pageController,
                                  sliders: sliders,
                                  currentIndex: currentIndex,
                                  onChanged: (index) {
                                    provider.onSliderChanged(index);
                                    _startAutoPlay();
                                  },
                                ).animate().slideY(begin: 0.05, duration: 300.ms),
                                SizedBox(height: 16.h),
                                _SectionHeader(
                                  title: "Categories",
                                  actionText: "VIEW ALL",
                                  onAction: () {},
                                ).animate().fadeIn(delay: 120.ms, duration: 250.ms),
                                SizedBox(height: 8.h),
                                _CategoriesRow(
                                  categories: categories,
                                ).animate().slideX(begin: -0.04, duration: 300.ms),
                                SizedBox(height: 16.h),
                                _SectionHeader(
                                  title: "Top 10 Songs",
                                  actionText: "",
                                  trailingIcon: Icons.tune,
                                  onTrailing: () {},
                                ).animate().fadeIn(delay: 180.ms, duration: 250.ms),
                                SizedBox(height: 8.h),
                                _TopTracksList(
                                  tracks: tracks,
                                  favoriteIds: favoriteIds,
                                  onToggleFavorite: provider.toggleFavorite,
                                  onPlay: provider.playTrack,
                                ),
                                SizedBox(height: 16.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
  }
}

class _TopBar extends StatelessWidget {
  final String userName;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;

  const _TopBar({
    required this.userName,
    required this.onSearch,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final orange = cs.primary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (ZoomDrawer.of(context) != null) {
                ZoomDrawer.of(context)!.toggle();
              }
            },
            icon: Icon(Icons.menu, color: cs.onSurface),
          ),
          SizedBox(width: 6.w),
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              border: Border.all(color: cs.primary.withValues(alpha: 0.3), width: 2),
              borderRadius: BorderRadius.circular(21.r),
            ),
            child: Icon(Icons.person, color: orange),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME BACK,',
                  style: AppTextStyles.getBodySmall(context).copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.getDisplayMedium(context).copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSearch,
            icon: Icon(Icons.search, color: cs.onSurface),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: onNotifications,
                icon: Icon(Icons.notifications_outlined, color: cs.onSurface),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderSection extends StatelessWidget {
  final PageController pageController; // Kept for compatibility but unused
  final List<entity_slider.Slider> sliders;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _SliderSection({
    required this.pageController,
    required this.sliders,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final orange = cs.primary;

    if (sliders.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final sliderH = isTablet ? 220.h : 180.h;
        return Column(
          children: [
            CarouselSlider.builder(
              itemCount: sliders.length,
              itemBuilder: (context, index, realIndex) {
                return _SliderCard(slider: sliders[index], orange: orange);
              },
              options: CarouselOptions(
                height: sliderH,
                viewportFraction: 0.85,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                enlargeFactor: 0.22,
                onPageChanged: (index, reason) {
                  onChanged(index);
                },
                scrollDirection: Axis.horizontal,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(sliders.length, (i) => Container(
                width: i == currentIndex ? 16.w : 6.w,
                height: 6.w,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: i == currentIndex ? orange : cs.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              )),
            ),
          ],
        );
      },
    );
  }
}

class _SliderCard extends StatelessWidget {
  final entity_slider.Slider slider;
  final Color orange;

  const _SliderCard({
    required this.slider,
    required this.orange,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (slider.imageUrl != null)
              Image.network(
                slider.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: orange.withOpacity(0.12),
                  child: Icon(Icons.image, color: orange),
                ),
              )
            else
              Container(color: orange.withOpacity(0.12)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    orange.withOpacity(0.70),
                    orange.withOpacity(0.88),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'FEATURED',
                      style: AppTextStyles.getLabelSmall(context).copyWith(
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    slider.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.getDisplayMedium(context).copyWith(
                      color: Colors.white,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  if (slider.subtitle != null)
                    Text(
                      slider.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.getBodySmall(context).copyWith(
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onAction;
  final IconData? trailingIcon;
  final VoidCallback? onTrailing;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    this.onAction,
    this.trailingIcon,
    this.onTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final orange = cs.primary;

    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.getHeadlineLarge(context).copyWith(
            color: cs.onSurface,
          ),
        ),
        const Spacer(),
        if (trailingIcon != null)
          IconButton(
            onPressed: onTrailing,
            icon: Icon(trailingIcon, color: cs.onSurface.withValues(alpha: 0.4)),
          )
        else if (actionText.isNotEmpty)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText,
              style: AppTextStyles.getLabelLarge(context).copyWith(
                color: orange,
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  final List<Category> categories;

  const _CategoriesRow({required this.categories});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final cardW = isTablet ? 140.w : 110.w;
        final cardH = isTablet ? 170.h : 140.h;
        return SizedBox(
          height: cardH,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 14.w),
            itemBuilder: (_, i) {
              final category = categories[i];
              final isSecond = i == 1;
              return InkWell(
                onTap: () {},
                child: Container(
                  width: cardW,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: cs.onSurface.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isSecond ? cs.primary : cs.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (category.imageUrl != null)
                          Image.network(
                            category.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: cs.surfaceVariant,
                              child: Icon(Icons.category, color: cs.onSurface.withValues(alpha: 0.3)),
                            ),
                          )
                        else
                          Container(color: const Color(0xFFE8ECEF)),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                cs.onSurface.withValues(alpha: 0.7),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Text(
                              "${category.title}${isSecond ? " •" : ""}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.getLabelLarge(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TopTracksList extends StatelessWidget {
  final List<Track> tracks;
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;
  final Function(String) onPlay;

  const _TopTracksList({
    required this.tracks,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final orange = cs.primary;

    return Column(
      children: List.generate(tracks.length, (i) {
        final track = tracks[i];
        final isFavorite = favoriteIds.contains(track.id);
        final isFirst = i == 0;

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: isFirst ? [
                BoxShadow(
                  color: cs.onSurface.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 30.w,
                  child: Text(
                    (i + 1).toString().padLeft(2, '0'),
                    style: AppTextStyles.getHeadlineSmall(context).copyWith(
                    color: isFirst ? orange : cs.onSurface.withValues(alpha: 0.2),
                    fontWeight: FontWeight.w600,
                  ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: cs.surfaceVariant,
                    image: track.coverImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(track.coverImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.getTitleMedium(context).copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        track.speaker ?? 'Unknown Speaker',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.getBodyMedium(context).copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (track.duration != null)
                        Text(
                          _formatDuration(track.duration!),
                          style: AppTextStyles.getLabelMedium(context).copyWith(
                            color: orange,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? orange : cs.onSurface.withValues(alpha: 0.3),
                        size: 20.w,
                      ),
                      onPressed: () => onToggleFavorite(track.id),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.download_outlined, color: cs.onSurface.withValues(alpha: 0.3), size: 20.w),
                      onPressed: () {},
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: () => onPlay(track.id),
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: isFirst ? orange : cs.surfaceVariant,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: isFirst ? [
                            BoxShadow(
                              color: orange.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ] : null,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: isFirst ? Colors.white : cs.onSurface.withValues(alpha: 0.4),
                          size: 24.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: AppTextStyles.getHeadlineMedium(context).copyWith(color: cs.onSurface),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTextStyles.getBodyMedium(context).copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {},
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
