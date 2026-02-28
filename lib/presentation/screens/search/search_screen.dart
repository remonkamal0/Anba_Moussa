import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

import '../../../domain/entities/track.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_text_styles.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<Track> _searchResults = [];

  // Recents could be stored in local storage later
  final List<Track> _recentTracks = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await sl.trackRepository.searchTracks(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Handle error toast or message
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    // Debounce search if needed, but for simplicity:
    _performSearch(query);
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
    });
  }

  void _onTrackTapped(Track track) {
    context.push('/player?trackId=${track.id}');
  }

  List<Track> get _filteredResults => _searchResults;
  bool get _isSearching => _searchQuery.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: cs.onSurface),
            onChanged: _onSearchChanged,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search songs, artists, albums...',
              hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
              prefixIcon: Icon(Icons.search, color: cs.onSurface.withValues(alpha: 0.4)),
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: Icon(Icons.clear, color: cs.onSurface.withValues(alpha: 0.4)),
                      onPressed: _onClearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppConstants.mediumSpacing.r),
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_searchQuery.isEmpty && _recentTracks.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64.w, color: cs.onSurface.withValues(alpha: 0.1)),
                      SizedBox(height: 16.h),
                      Text('Search for your favorite songs', 
                        style: AppTextStyles.getBodyLarge(context).copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
              )
            else if (_searchQuery.isNotEmpty && _searchResults.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64.w, color: cs.onSurface.withValues(alpha: 0.1)),
                      SizedBox(height: 16.h),
                      Text('No results found for "$_searchQuery"',
                        style: AppTextStyles.getBodyLarge(context).copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _searchQuery.isEmpty ? _recentTracks.length : _searchResults.length,
                  itemBuilder: (context, index) {
                    final track = _searchQuery.isEmpty ? _recentTracks[index] : _searchResults[index];
                    return SearchResultTile(
                      track: track,
                      onTap: () => _onTrackTapped(track),
                    ).animate().fadeIn(delay: Duration(milliseconds: index * 50)).slideX(begin: -0.05);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (!_isSearching)
            TextButton(
              onPressed: () {
                // TODO: Clear recent searches
                print('Clear recent searches');
              },
              child: Text(
                'Clear all',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SearchResultTile extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.track,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
      leading: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: cs.primary.withValues(alpha: 0.1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: track.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: track.imageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(
                    Icons.music_note,
                    color: cs.primary,
                    size: 24.w,
                  ),
                )
              : Icon(
                  Icons.music_note,
                  color: cs.primary,
                  size: 24.w,
                ),
        ),
      ),
      title: Text(
        track.getLocalizedTitle(locale),
        style: AppTextStyles.getBodyLarge(context).copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.getLocalizedSpeaker(locale) ?? 'Unknown Speaker',
        style: AppTextStyles.getBodySmall(context).copyWith(
          color: cs.onSurface.withValues(alpha: 0.5),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: cs.primary,
          size: 20.w,
        ),
      ),
      onTap: onTap,
    );
  }
}
