import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedIndex = 1; // Library is selected

  final List<LibraryItem> _items = [
    LibraryItem(
      id: '1',
      title: 'Joy',
      year: '2023',
      imageUrl: 'https://picsum.photos/seed/joy/200/200',
      type: LibraryItemType.album,
    ),
    LibraryItem(
      id: '2',
      title: 'Chu',
      year: '2023',
      imageUrl: 'https://picsum.photos/seed/chu/200/200',
      type: LibraryItemType.album,
    ),
    LibraryItem(
      id: '3',
      title: 'To Y',
      year: '2023',
      imageUrl: 'https://picsum.photos/seed/toy/200/200',
      type: LibraryItemType.album,
    ),
    LibraryItem(
      id: '4',
      title: 'Salv',
      year: '2023',
      imageUrl: 'https://picsum.photos/seed/salv/200/200',
      type: LibraryItemType.album,
    ),
    LibraryItem(
      id: '5',
      title: 'New',
      year: '2024',
      imageUrl: 'https://picsum.photos/seed/new/200/200',
      type: LibraryItemType.album,
    ),
    LibraryItem(
      id: '6',
      title: 'Light',
      year: '2024',
      imageUrl: 'https://picsum.photos/seed/light/200/200',
      type: LibraryItemType.album,
    ),
  ];

  void _onItemTapped(LibraryItem item) {
    // TODO: Navigate to album details or player
    print('Tapped on: ${item.title}');
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Navigate to different screens
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // TODO: Open drawer
          },
        ),
        title: Text(
          'LIBRARY',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.mediumSpacing.w,
            mainAxisSpacing: AppConstants.mediumSpacing.h,
            childAspectRatio: 0.75,
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return LibraryCard(
              item: item,
              onTap: () => _onItemTapped(item),
            ).animate().scale(
              duration: AppConstants.defaultAnimationDuration,
              delay: Duration(milliseconds: index * 100),
              curve: Curves.easeOut,
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF6B35),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_outlined),
            activeIcon: Icon(Icons.library_music),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            activeIcon: Icon(Icons.video_library),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class LibraryCard extends StatelessWidget {
  final LibraryItem item;
  final VoidCallback onTap;

  const LibraryCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
          color: Colors.grey[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppConstants.mediumBorderRadius.r),
                      ),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(item.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Play button overlay
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Title and year
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(AppConstants.smallSpacing.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.year,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryItem {
  final String id;
  final String title;
  final String year;
  final String imageUrl;
  final LibraryItemType type;

  LibraryItem({
    required this.id,
    required this.title,
    required this.year,
    required this.imageUrl,
    required this.type,
  });
}

enum LibraryItemType {
  album,
  playlist,
  artist,
}
