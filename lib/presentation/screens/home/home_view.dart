import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/track.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/slider.dart' as entity_slider;
import '../../widgets/common/app_drawer.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/home_provider.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import '../../providers/favorites_provider.dart';
import '../../providers/downloads_provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/common/error_handle_widget.dart';

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

class _HomeViewContent extends riverpod.ConsumerStatefulWidget {
  const _HomeViewContent();

  @override
  riverpod.ConsumerState<_HomeViewContent> createState() => _HomeViewContentState();
}

class _HomeViewContentState extends riverpod.ConsumerState<_HomeViewContent> {
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

  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
          return provider.state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err) => ErrorHandleWidget(
              error: err,
              onRetry: () => provider.refresh(),
            ),
            loaded: (tracks, categories, sliders, favoriteIds, currentIndex) {
              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                drawer: AppDrawer(),
                body: SafeArea(
                  child: Column(
                    children: [
                      _TopBar(
                        userName: userProfile.fullName,
                        onSearch: () => context.push('/search'),
                        onNotifications: () => context.push('/notifications'),
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
                                  onAction: () => context.push('/library'),
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
                                  onPlay: (t) {
                                    final index = tracks.indexOf(t);
                                    if (index != -1) {
                                      ref.read(audioProvider.notifier).loadPlaylist(tracks, index);
                                    }
                                  },
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
    return InkWell(
      onTap: () async {
        final link = slider.linkUrl;
        if (link != null && link.isNotEmpty) {
          debugPrint('Attempting to open slider link: $link');
          final uri = Uri.tryParse(link);
          if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
            try {
              final launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              if (!launched) {
                debugPrint('Could not launch URL: $link');
              }
            } catch (e) {
              debugPrint('Error launching URL: $e');
            }
          } else if (link.startsWith('/')) {
            context.push(link);
          } else {
            debugPrint('Invalid or unsupported link format: $link');
          }
        }
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
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
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(12.w),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slider.getLocalizedTitle(Localizations.localeOf(context).languageCode),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.getDisplayMedium(context).copyWith(
                          color: orange,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      if (slider.getLocalizedSubtitle(Localizations.localeOf(context).languageCode) != null) ...[
                        SizedBox(height: 6.h),
                        Text(
                          slider.getLocalizedSubtitle(Localizations.localeOf(context).languageCode)!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.getBodySmall(context).copyWith(
                            color: orange.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
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
              return InkWell(
                onTap: () => context.push(
                  Uri(
                    path: '/album/${category.id}',
                    queryParameters: {
                      'title': category.getLocalizedTitle(Localizations.localeOf(context).languageCode),
                      'imageUrl': category.imageUrl ?? '',
                    },
                  ).toString(),
                ),
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
                      color: cs.outlineVariant,
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
                              category.getLocalizedTitle(Localizations.localeOf(context).languageCode),
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

class _TopTracksList extends riverpod.ConsumerWidget {
  final List<Track> tracks;
  final Function(Track) onPlay;

  const _TopTracksList({
    required this.tracks,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final orange = cs.primary;

    return Column(
      children: List.generate(tracks.length, (i) {
        final track = tracks[i];
        final audioState = ref.watch(audioProvider);
        final isCurrentTrack = audioState.currentTrack?.id == track.id;
        final isPlaying = audioState.isPlaying && isCurrentTrack;

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            decoration: BoxDecoration(
              color: isCurrentTrack ? orange.withValues(alpha: 0.08) : cs.surface,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: isCurrentTrack ? [
                BoxShadow(
                  color: orange.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ] : null,
              border: isCurrentTrack 
                ? Border.all(color: orange.withValues(alpha: 0.15), width: 1.5)
                : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(24.r),
                onTap: () {
                  if (isCurrentTrack) {
                    ref.read(audioProvider.notifier).togglePlayPause();
                  } else {
                    onPlay(track);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  child: Row(
                    children: [
                      // Index number
                      SizedBox(
                        width: 30.w,
                        child: Text(
                          (i + 1).toString().padLeft(2, '0'),
                          style: AppTextStyles.getHeadlineSmall(context).copyWith(
                            color: isCurrentTrack ? orange : cs.onSurface.withValues(alpha: 0.2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Thumbnail with Visualizer
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 52.w,
                            height: 52.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              color: cs.surfaceVariant,
                              image: track.imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(track.imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: track.imageUrl == null
                                ? Icon(Icons.music_note, color: orange, size: 22.w)
                                : null,
                          ),
                          if (isPlaying)
                            Container(
                              width: 52.w,
                              height: 52.w,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.bar_chart_rounded,
                                  color: Colors.white,
                                  size: 26.w,
                                ).animate(onPlay: (controller) => controller.repeat())
                                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 600.ms, curve: Curves.easeInOut)
                                  .then()
                                  .scale(begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.easeInOut),
                              ),
                            ),
                        ],
                      ),
                      
                      SizedBox(width: 14.w),

                      // Title & Artist
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.getLocalizedTitle(Localizations.localeOf(context).languageCode),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.getTitleMedium(context).copyWith(
                                color: isCurrentTrack ? orange : cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "${track.getLocalizedSpeaker(Localizations.localeOf(context).languageCode) ?? 'Unknown Speaker'} • ${_formatDuration(track.duration ?? Duration.zero)}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.getBodyMedium(context).copyWith(
                                color: isCurrentTrack ? orange.withValues(alpha: 0.7) : cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Actions
                      riverpod.Consumer(
                        builder: (context, ref, child) {
                          final isFavorite = ref.watch(favoritesProvider).tracks.any((t) => t.id == track.id);
                          final downloads = ref.watch(downloadsProvider);
                          final isDownloaded = downloads.downloadedTracks.any((t) => t.id == track.id);
                          final progress = downloads.downloadProgress[track.id];

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? orange : cs.onSurface.withValues(alpha: 0.3),
                                  size: 20.w,
                                ),
                                onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(track),
                              ),
                              SizedBox(width: 8.w),
                              progress != null
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 2,
                                        color: orange,
                                      ),
                                    )
                                  : IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        isDownloaded ? Icons.download_done_rounded : Icons.download_outlined,
                                        color: isDownloaded ? orange : cs.onSurface.withValues(alpha: 0.3),
                                        size: 20.w,
                                      ),
                                      onPressed: () {
                                        if (isDownloaded) {
                                          ref.read(downloadsProvider.notifier).removeDownload(track.id);
                                        } else {
                                          ref.read(downloadsProvider.notifier).downloadTrack(track);
                                        }
                                      },
                                    ),
                              SizedBox(width: 12.w),
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: isCurrentTrack ? orange : cs.surfaceVariant,
                                  borderRadius: BorderRadius.circular(14.r),
                                  boxShadow: isCurrentTrack
                                      ? [
                                          BoxShadow(
                                            color: orange.withOpacity(0.35),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: isCurrentTrack ? Colors.white : cs.onSurface.withValues(alpha: 0.4),
                                  size: 24.w,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
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
