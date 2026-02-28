import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/category.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl.libraryProvider..initialize(),
      child: const _LibraryScreenContent(),
    );
  }
}

class _LibraryScreenContent extends StatefulWidget {
  const _LibraryScreenContent();

  @override
  State<_LibraryScreenContent> createState() => _LibraryScreenContentState();
}

class _LibraryScreenContentState extends State<_LibraryScreenContent> {
  void _onCategoryTapped(Category category) {
    final locale = Localizations.localeOf(context).languageCode;
    context.push(
      Uri(
        path: '/album/${category.id}',
        queryParameters: {
          'title': category.getLocalizedTitle(locale),
          'imageUrl': category.imageUrl ?? '',
        },
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gap = 12.w;

    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        final state = provider.state;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {
                final drawer = ZoomDrawer.of(context);
                if (drawer != null) drawer.toggle();
              },
            ),
            title: Text(
              'LIBRARY',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 1.2,
                  ),
            ),
            centerTitle: true,
          ),
          body: _buildBody(state, gap),
        );
      },
    );
  }

  Widget _buildBody(LibraryState state, double gap) {
    switch (state.status) {
      case LibraryStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LibraryStatus.error:
        return Center(child: Text(state.errorMessage ?? 'An error occurred'));
      case LibraryStatus.loaded:
        if (state.categories.isEmpty) {
          return const Center(child: Text('No categories found'));
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: GridView.builder(
            itemCount: state.categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: gap,
              mainAxisSpacing: gap,
              childAspectRatio: 0.85, 
            ),
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return _CategoryCard(
                category: category,
                onTap: () => _onCategoryTapped(category),
              )
                  .animate()
                  .fadeIn(
                    duration: const Duration(milliseconds: 280),
                    delay: Duration(milliseconds: index * 40),
                    curve: Curves.easeOut,
                  )
                  .slideY(
                    begin: 0.1,
                    end: 0,
                    duration: const Duration(milliseconds: 280),
                    delay: Duration(milliseconds: index * 40),
                    curve: Curves.easeOut,
                  );
            },
          ),
        );
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final title = category.getLocalizedTitle(locale);
    final subtitle = category.getLocalizedSubtitle(locale);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: category.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.category_outlined, color: Colors.grey),
                    ),
            ),

            // Bottom capsule overlay
            Positioned(
              left: 10.w,
              right: 10.w,
              bottom: 10.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(40.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20.w,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: 1.h),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
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