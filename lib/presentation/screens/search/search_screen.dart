import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  final List<SearchResult> _recentSearches = [
    SearchResult(
      id: '1',
      type: SearchResultType.song,
      title: 'Midnight Dreams',
      subtitle: 'Luna Rose',
      imageUrl: 'https://picsum.photos/seed/midnight-dreams/60/60',
    ),
    SearchResult(
      id: '2',
      type: SearchResultType.artist,
      title: 'The Weeknd',
      subtitle: 'Artist',
      imageUrl: 'https://picsum.photos/seed/the-weeknd/60/60',
    ),
    SearchResult(
      id: '3',
      type: SearchResultType.album,
      title: 'After Hours',
      subtitle: 'Album • The Weeknd',
      imageUrl: 'https://picsum.photos/seed/after-hours/60/60',
    ),
    SearchResult(
      id: '4',
      type: SearchResultType.playlist,
      title: 'Summer Vibes',
      subtitle: 'Playlist • 24 songs',
      imageUrl: 'https://picsum.photos/seed/summer-vibes/60/60',
    ),
  ];

  final List<SearchResult> _allResults = [
    SearchResult(
      id: '5',
      type: SearchResultType.song,
      title: 'Ocean Waves',
      subtitle: 'Blue Horizon',
      imageUrl: 'https://picsum.photos/seed/ocean-waves/60/60',
    ),
    SearchResult(
      id: '6',
      type: SearchResultType.song,
      title: 'Golden Hour',
      subtitle: 'Sunset Boulevard',
      imageUrl: 'https://picsum.photos/seed/golden-hour/60/60',
    ),
    SearchResult(
      id: '7',
      type: SearchResultType.artist,
      title: 'Arctic Monkeys',
      subtitle: 'Artist',
      imageUrl: 'https://picsum.photos/seed/arctic-monkeys/60/60',
    ),
    SearchResult(
      id: '8',
      type: SearchResultType.album,
      title: 'Celestial',
      subtitle: 'Album • Luna Rose',
      imageUrl: 'https://picsum.photos/seed/celestial/60/60',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
  }

  void _onResultTapped(SearchResult result) {
    // TODO: Navigate to appropriate screen based on result type
    print('Tapped: ${result.title} (${result.type})');
    
    switch (result.type) {
      case SearchResultType.song:
        // Navigate to player
        break;
      case SearchResultType.artist:
        // Navigate to artist page
        break;
      case SearchResultType.album:
        context.go('/album/${result.id}');
        break;
      case SearchResultType.playlist:
        // Navigate to playlist
        break;
    }
  }

  List<SearchResult> get _filteredResults {
    if (_searchQuery.isEmpty) return [];
    
    return _allResults.where((result) {
      return result.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             result.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search songs, artists, albums...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
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
            if (!_isSearching) ...[
              // Recent searches
              _buildSectionHeader('Recent Searches'),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                  itemCount: _recentSearches.length,
                  itemBuilder: (context, index) {
                    final result = _recentSearches[index];
                    return SearchResultTile(
                      result: result,
                      onTap: () => _onResultTapped(result),
                    ).animate().slideX(
                      duration: AppConstants.defaultAnimationDuration,
                      delay: Duration(milliseconds: index * 100),
                      begin: -0.2,
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
            ] else ...[
              // Search results
              if (_filteredResults.isEmpty) ...[
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64.w,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: AppConstants.mediumSpacing.h),
                      Text(
                        'No results found for "$_searchQuery"',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _buildSectionHeader('Search Results'),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                    itemCount: _filteredResults.length,
                    itemBuilder: (context, index) {
                      final result = _filteredResults[index];
                      return SearchResultTile(
                        result: result,
                        onTap: () => _onResultTapped(result),
                      ).animate().slideX(
                        duration: AppConstants.defaultAnimationDuration,
                        delay: Duration(milliseconds: index * 100),
                        begin: -0.2,
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
                  color: const Color(0xFFFF6B35),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(AppConstants.mediumSpacing.r),
      leading: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius.r),
          color: _getResultTypeColor(result.type),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius.r),
          child: result.imageUrl != null
              ? Image.network(
                  result.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    _getResultTypeIcon(result.type),
                    color: Colors.white,
                    size: 24.w,
                  ),
                )
              : Icon(
                  _getResultTypeIcon(result.type),
                  color: Colors.white,
                  size: 24.w,
                ),
        ),
      ),
      title: Text(
        result.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        result.subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.play_arrow,
        color: Colors.black,
        size: 24.w,
      ),
      onTap: onTap,
    );
  }

  Color _getResultTypeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.song:
        return const Color(0xFFFF6B35);
      case SearchResultType.artist:
        return Colors.purple;
      case SearchResultType.album:
        return Colors.blue;
      case SearchResultType.playlist:
        return Colors.green;
    }
  }

  IconData _getResultTypeIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.song:
        return Icons.music_note;
      case SearchResultType.artist:
        return Icons.person;
      case SearchResultType.album:
        return Icons.album;
      case SearchResultType.playlist:
        return Icons.playlist_play;
    }
  }
}

class SearchResult {
  final String id;
  final SearchResultType type;
  final String title;
  final String subtitle;
  final String? imageUrl;

  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });
}

enum SearchResultType {
  song,
  artist,
  album,
  playlist,
}
