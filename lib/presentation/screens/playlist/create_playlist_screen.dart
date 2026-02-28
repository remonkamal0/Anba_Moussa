import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import '../favorites/all_playlists_screen.dart'; // To get the Playlist model
import 'package:cached_network_image/cached_network_image.dart';

class MockTrack {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;

  MockTrack({required this.id, required this.title, required this.artist, required this.coverUrl});
}

class CreatePlaylistScreen extends StatefulWidget {
  final Playlist? existingPlaylist;

  const CreatePlaylistScreen({super.key, this.existingPlaylist});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  String? _selectedCoverUrl;
  final Set<String> _selectedTrackIds = {};
  
  // 10 mock images for cover
  final List<String> _coverImages = List.generate(
    10, 
    (index) => 'https://picsum.photos/seed/cover${index + 1}/300/300'
  );

  // Mock suggested tracks
  final List<MockTrack> _suggestedTracks = [
    MockTrack(id: '1', title: 'Midnight City', artist: 'M83', coverUrl: 'https://picsum.photos/seed/t1/100/100'),
    MockTrack(id: '2', title: 'Starboy', artist: 'The Weeknd', coverUrl: 'https://picsum.photos/seed/t2/100/100'),
    MockTrack(id: '3', title: 'Blinding Lights', artist: 'The Weeknd', coverUrl: 'https://picsum.photos/seed/t3/100/100'),
    MockTrack(id: '4', title: 'Heat Waves', artist: 'Glass Animals', coverUrl: 'https://picsum.photos/seed/t4/100/100'),
    MockTrack(id: '5', title: 'Levitating', artist: 'Dua Lipa', coverUrl: 'https://picsum.photos/seed/t5/100/100'),
    MockTrack(id: '6', title: 'Save Your Tears', artist: 'The Weeknd', coverUrl: 'https://picsum.photos/seed/t6/100/100'),
    MockTrack(id: '7', title: 'As It Was', artist: 'Harry Styles', coverUrl: 'https://picsum.photos/seed/t7/100/100'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingPlaylist != null) {
      _nameController.text = widget.existingPlaylist!.title;
      _selectedCoverUrl = widget.existingPlaylist!.coverImage;
      // Note: we'd also populate tracks here if they were part of the Playlist model
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showCoverSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          height: 400.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Cover Image',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                  ),
                  itemCount: _coverImages.length,
                  itemBuilder: (context, index) {
                    final imageUrl = _coverImages[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() { _selectedCoverUrl = imageUrl; });
                        Navigator.pop(context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[300]),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _createPlaylist() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a playlist name')),
      );
      return;
    }
    
    final playlistId = widget.existingPlaylist?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final newPlaylist = Playlist(
      id: playlistId,
      title: _nameController.text.trim(),
      songCount: widget.existingPlaylist?.songCount ?? _selectedTrackIds.length,
      coverImage: _selectedCoverUrl ?? widget.existingPlaylist?.coverImage ?? 'https://picsum.photos/seed/default/200/200',
      isPublic: widget.existingPlaylist?.isPublic ?? false,
      date: widget.existingPlaylist != null ? 'Updated just now' : 'Just now',
    );
    
    Navigator.of(context).pop(newPlaylist);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: cs.onSurface, size: 20),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          widget.existingPlaylist != null ? 'Edit Playlist' : l10n.playlistCreateTitle,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cover Selection
              Center(
                child: GestureDetector(
                  onTap: _showCoverSelectionSheet,
                  child: Container(
                    width: 160.w,
                    height: 160.w,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: cs.onSurface.withValues(alpha: 0.1), // Mocking the dashed appearance using a light border
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                      image: _selectedCoverUrl != null 
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(_selectedCoverUrl!),
                            fit: BoxFit.cover,
                          ) 
                        : null,
                    ),
                    child: _selectedCoverUrl == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: cs.onSurface.withValues(alpha: 0.5), size: 32.sp),
                              SizedBox(height: 8.h),
                              Text(
                                l10n.playlistAddCover,
                                style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              
              SizedBox(height: 32.h),

              // 2. Playlist Name Input
              Text(
                l10n.playlistNameLabel,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _nameController,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: l10n.playlistNameHint,
                  hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.3), fontSize: 14.sp),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                ),
              ),
              
              SizedBox(height: 24.h),

              // 3. Search Tracks Input
              TextField(
                controller: _searchController,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: l10n.playlistSearchTracksHint,
                  hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.3), fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search, color: cs.onSurface.withValues(alpha: 0.3), size: 20.sp),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.r), // More rounded search field
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                ),
              ),

              SizedBox(height: 32.h),

              // 4. Suggested Tracks List
              Text(
                l10n.playlistSuggestedTracks,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 16.h),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _suggestedTracks.length,
                itemBuilder: (context, index) {
                  final track = _suggestedTracks[index];
                  final isSelected = _selectedTrackIds.contains(track.id);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CachedNetworkImage(
                            imageUrl: track.coverUrl,
                            width: 50.w,
                            height: 50.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                track.artist,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedTrackIds.remove(track.id);
                              } else {
                                _selectedTrackIds.add(track.id);
                              }
                            });
                          },
                          child: Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.transparent : cs.onSurface.withValues(alpha: 0.1),
                                width: 2,
                              ),
                              color: isSelected ? cs.primary : Colors.transparent, // Dynamic accent color
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              SizedBox(height: 80.h), // Space for bottom button
            ],
          ),
        ),
      ),
      
      // Fixed Create Playlist Button at the bottom
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: _createPlaylist,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary, // Dynamic accent color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r),
              ),
              elevation: 0,
            ),
            child: Text(
              widget.existingPlaylist != null ? 'Save Changes' : l10n.playlistCreateButton,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
