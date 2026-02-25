import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController(viewportFraction: 0.90);
  int _sliderIndex = 0;
  int _selectedIndex = 0;
  Timer? _autoPlayTimer;

  // Colors like screenshot
  final Color _orange = const Color(0xFFFF6B35);
  final Color _navy = const Color(0xFF0B1320);
  final Color _muted = const Color(0xFF7E8798);

  // Mock UI data
  final String userName = "Alex Johnson";

  final List<_SliderItem> sliders = const [
    _SliderItem(
      title: "New Album:\nR&B Soul Hits",
      subtitle: "Listen to the latest tracks from top artists",
      imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=1200&q=80",
    ),
    _SliderItem(
      title: "Top Praise:\nKoinonia",
      subtitle: "Fellowship songs for your day",
      imageUrl: "https://images.unsplash.com/photo-1522780209446-3f30c0a4c69d?w=1200&q=80",
    ),
    _SliderItem(
      title: "New Release:\nSpiritual Vibes",
      subtitle: "Fresh tracks every week",
      imageUrl: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=1200&q=80",
    ),
  ];

  final List<_CategoryItem> categories = const [
    _CategoryItem(title: "Jazz", imageUrl: "https://picsum.photos/seed/jazz/300/400"),
    _CategoryItem(title: "Rock", imageUrl: "https://picsum.photos/seed/rock/300/400"),
    _CategoryItem(title: "Pop", imageUrl: "https://picsum.photos/seed/pop/300/400"),
    _CategoryItem(title: "Classic", imageUrl: "https://picsum.photos/seed/classic/300/400"),
  ];

  final List<_SongItem> topSongs = const [
    _SongItem(rank: 1, title: "Amelia ...", artist: "Starry Skies", duration: "3:45", coverUrl: "https://picsum.photos/seed/a1/200/200", liked: true, downloaded: true),
    _SongItem(rank: 2, title: "Olivia Lyric", artist: "Sunset Serenity", duration: "4:02", coverUrl: "https://picsum.photos/seed/a2/200/200", liked: false, downloaded: false),
    _SongItem(rank: 3, title: "Mason Chorus", artist: "Eternal Sunset", duration: "3:28", coverUrl: "https://picsum.photos/seed/a3/200/200", liked: false, downloaded: true),
    _SongItem(rank: 4, title: "Midnight Dreams", artist: "Luna Rose", duration: "3:11", coverUrl: "https://picsum.photos/seed/a4/200/200", liked: true, downloaded: false),
  ];

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
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && sliders.isNotEmpty) {
        final nextPage = (_sliderIndex + 1) % sliders.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        setState(() {
          _sliderIndex = nextPage;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              name: userName,
              onMenu: () {},
              onSearch: () {},
              onNotifications: () {},
              orange: _orange,
              navy: _navy,
            ).animate().fadeIn(duration: 250.ms),

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
                        sliderIndex: _sliderIndex,
                        onChanged: (i) {
                          setState(() => _sliderIndex = i);
                          _startAutoPlay(); // Restart timer when user manually changes page
                        },
                        orange: _orange,
                      ).animate().slideY(begin: 0.05, duration: 300.ms),

                      SizedBox(height: 16.h),

                      _SectionHeader(
                        title: "Categories",
                        actionText: "VIEW ALL",
                        onAction: () {},
                        trailingIcon: null,
                        onTrailing: null,
                        orange: _orange,
                        navy: _navy,
                      ).animate().fadeIn(delay: 120.ms, duration: 250.ms),

                      SizedBox(height: 8.h),

                      _CategoriesRow(
                        categories: categories,
                        orange: _orange,
                      ).animate().slideX(begin: -0.04, duration: 300.ms),

                      SizedBox(height: 16.h),

                      _SectionHeader(
                        title: "Top 10 Songs",
                        actionText: "",
                        onAction: null,
                        trailingIcon: Icons.tune,
                        onTrailing: () {},
                        orange: _orange,
                        navy: _navy,
                      ).animate().fadeIn(delay: 180.ms, duration: 250.ms),

                      SizedBox(height: 8.h),

                      _TopSongsList(
                        songs: topSongs,
                        orange: _orange,
                        navy: _navy,
                        muted: _muted,
                      ),

                      SizedBox(height: 18.h),
                    ],
                  ),
                ),
              ),
            ),

            _BottomNav(
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              orange: _orange,
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- Widgets -------------------- */

class _TopBar extends StatelessWidget {
  final String name;
  final VoidCallback onMenu;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final Color orange;
  final Color navy;

  const _TopBar({
    required this.name,
    required this.onMenu,
    required this.onSearch,
    required this.onNotifications,
    required this.orange,
    required this.navy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenu,
            icon: const Icon(Icons.menu, color: Colors.black),
          ),
          SizedBox(width: 6.w),

          // avatar
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFE0D6),
              border: Border.all(color: const Color(0xFFFFC7B3), width: 2),
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
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8A93A3),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                    color: navy,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search, color: Colors.black),
          ),

          Stack(
            children: [
              IconButton(
                onPressed: onNotifications,
                icon: const Icon(Icons.notifications_none, color: Colors.black),
              ),
              Positioned(
                right: 12,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: orange,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderSection extends StatelessWidget {
  final PageController pageController;
  final List<_SliderItem> sliders;
  final int sliderIndex;
  final ValueChanged<int> onChanged;
  final Color orange;

  const _SliderSection({
    required this.pageController,
    required this.sliders,
    required this.sliderIndex,
    required this.onChanged,
    required this.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180.h,
          child: PageView.builder(
            controller: pageController,
            itemCount: sliders.length,
            onPageChanged: (index) => onChanged(index),
            itemBuilder: (_, i) => _SliderCard(item: sliders[i], orange: orange),
          ),
        ),
        SizedBox(height: 10.h),
        SmoothPageIndicator(
          controller: pageController,
          count: sliders.length,
          effect: ExpandingDotsEffect(
            dotHeight: 6.h,
            dotWidth: 6.w,
            expansionFactor: 2,
            spacing: 8.w,
            dotColor: const Color(0xFFE6E9EF),
            activeDotColor: orange,
          ),
        ),
      ],
    );
  }
}

class _SliderCard extends StatelessWidget {
  final _SliderItem item;
  final Color orange;

  const _SliderCard({required this.item, required this.orange});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(item.imageUrl, fit: BoxFit.cover),

          // orange overlay like screenshot
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
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'FEATURED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
  final Color orange;
  final Color navy;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
    required this.trailingIcon,
    required this.onTrailing,
    required this.orange,
    required this.navy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            color: navy,
          ),
        ),
        const Spacer(),
        if (trailingIcon != null)
          IconButton(
            onPressed: onTrailing,
            icon: Icon(trailingIcon, color: const Color(0xFF9AA3B2)),
          )
        else if (actionText.isNotEmpty)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText,
              style: TextStyle(
                color: orange,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  final List<_CategoryItem> categories;
  final Color orange;

  const _CategoriesRow({
    required this.categories,
    required this.orange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, i) {
          final c = categories[i];
          return InkWell(
            onTap: () {},
            child: Container(
              width: 120.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: i == 1 ? orange : const Color(0xFFF0F2F6),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(c.imageUrl, fit: BoxFit.cover),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Text(
                          c.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.45),
                                blurRadius: 10,
                              )
                            ],
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
  }
}

class _TopSongsList extends StatelessWidget {
  final List<_SongItem> songs;
  final Color orange;
  final Color navy;
  final Color muted;

  const _TopSongsList({
    required this.songs,
    required this.orange,
    required this.navy,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(songs.length, (i) {
        final s = songs[i];
        final bool first = i == 0;

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Row(
              children: [
                Text(
                  s.rank.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: const Color(0xFFC7CEDA),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 12.w),

                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    color: const Color(0xFFF3F5F7),
                    image: DecorationImage(
                      image: NetworkImage(s.coverUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: navy,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        s.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: muted,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        s.duration,
                        style: TextStyle(
                          color: orange,
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  s.liked ? Icons.favorite : Icons.favorite_border,
                  color: s.liked ? orange : const Color(0xFFB8C0CF),
                ),

                SizedBox(width: 8.w),

                Icon(
                  s.downloaded ? Icons.download_done : Icons.download_outlined,
                  color: const Color(0xFFB8C0CF),
                ),

                SizedBox(width: 10.w),

                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: first ? orange : const Color(0xFFF0F2F6),
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      if (first)
                        BoxShadow(
                          color: orange.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        )
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: first ? Colors.white : const Color(0xFF97A0B0),
                    size: 30.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color orange;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, -8),
          )
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: orange,
        unselectedItemColor: const Color(0xFFB0B7C4),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music_outlined), activeIcon: Icon(Icons.library_music), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library_outlined), activeIcon: Icon(Icons.photo_library), label: 'Gallery'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library_outlined), activeIcon: Icon(Icons.video_library), label: 'Videos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/* -------------------- Models (UI only) -------------------- */

class _SliderItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  const _SliderItem({required this.title, required this.subtitle, required this.imageUrl});
}

class _CategoryItem {
  final String title;
  final String imageUrl;
  const _CategoryItem({required this.title, required this.imageUrl});
}

class _SongItem {
  final int rank;
  final String title;
  final String artist;
  final String duration;
  final String coverUrl;
  final bool liked;
  final bool downloaded;

  const _SongItem({
    required this.rank,
    required this.title,
    required this.artist,
    required this.duration,
    required this.coverUrl,
    required this.liked,
    required this.downloaded,
  });
}