import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/playlists_provider.dart';
import '../playlist/create_playlist_screen.dart';
import '../playlist/playlist_details_screen.dart';

class AllPlaylistsScreen extends ConsumerStatefulWidget {
  const AllPlaylistsScreen({super.key});

  @override
  ConsumerState<AllPlaylistsScreen> createState() => _AllPlaylistsScreenState();
}

class _AllPlaylistsScreenState extends ConsumerState<AllPlaylistsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreate() async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const CreatePlaylistScreen()),
    );
    // Provider already updated by CreatePlaylistScreen
  }

  void _openEdit(PlaylistModel playlist) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => CreatePlaylistScreen(existingPlaylist: playlist),
      ),
    );
  }

  void _openDetails(PlaylistModel playlist) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaylistDetailsScreen(playlistId: playlist.id),
      ),
    );
  }

  void _deletePlaylist(PlaylistModel playlist) async {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(28.w, 32.h, 28.w, 28.h),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                locale == 'ar' ? 'حذف قائمة التشغيل' : 'Delete Playlist',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                locale == 'ar' 
                  ? 'هل أنت متأكد من حذف "${playlist.titleAr}"؟'
                  : 'Are you sure you want to delete "${playlist.titleEn}"?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: cs.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.onSurface.withValues(alpha: 0.05),
                        foregroundColor: cs.onSurface,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: Text(locale == 'ar' ? 'إلغاء' : 'Cancel', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: Text(locale == 'ar' ? 'تأكيد' : 'Confirm', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true) {
      ref.read(playlistsProvider.notifier).deletePlaylist(playlist.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final playlistState = ref.watch(playlistsProvider);

    final filtered = _query.isEmpty
        ? playlistState.playlists
        : playlistState.playlists
            .where((p) =>
                p.titleAr.toLowerCase().contains(_query.toLowerCase()) ||
                p.titleEn.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Playlists',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search playlists…',
                    hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontSize: 14.sp),
                    prefixIcon: Icon(Icons.search, color: cs.onSurface.withValues(alpha: 0.4), size: 20.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
            ),

            // Body
            Expanded(
              child: playlistState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : playlistState.error != null
                      ? _ErrorView(error: playlistState.error!, onRetry: () => ref.read(playlistsProvider.notifier).fetch())
                      : filtered.isEmpty
                          ? _EmptyView(onAdd: _openCreate)
                          : ListView.separated(
                              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => SizedBox(height: 16.h),
                              itemBuilder: (context, index) {
                                final playlist = filtered[index];
                                return PlaylistCard(
                                  playlist: playlist,
                                  onTap: () => _openDetails(playlist),
                                  onEdit: () => _openEdit(playlist),
                                  onDelete: () => _deletePlaylist(playlist),
                                ).animate().fadeIn(
                                      duration: 400.ms,
                                      delay: Duration(milliseconds: index * 50),
                                    ).slideY(begin: 0.1, end: 0);
                              },
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        backgroundColor: cs.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ─── Empty ─────────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.queue_music_rounded, size: 72.sp, color: cs.onSurface.withValues(alpha: 0.2)),
          SizedBox(height: 16.h),
          Text('No playlists yet', style: TextStyle(fontSize: 16.sp, color: cs.onSurface.withValues(alpha: 0.5))),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: onAdd,
            child: Text('Create your first playlist', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Error ─────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 56.sp, color: cs.onSurface.withValues(alpha: 0.3)),
          SizedBox(height: 12.h),
          Text('Failed to load playlists', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
          SizedBox(height: 8.h),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ─── Card ──────────────────────────────────────────────────────────────────────
class PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final icon = playlistIcon(playlist.iconName);

    return InkWell(
      onTap: onTap,
      onLongPress: () => _showOptions(context),
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon portion
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withValues(alpha: 0.9),
                    cs.primary.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24.sp),
            ),
            
            SizedBox(width: 16.w),
            
            // Text portion
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.getLocalizedTitle(locale),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (playlist.isPublic) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'Public',
                            style: TextStyle(color: cs.primary, fontSize: 9.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        '${playlist.trackCount} Tracks',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Trailing Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: cs.primary.withValues(alpha: 0.7), size: 20.sp),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.red.withValues(alpha: 0.6), size: 20.sp),
                    onPressed: onDelete,
                  ),
              ],
            ),
            SizedBox(width: 4.w),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4.r))),
            SizedBox(height: 12.h),
            if (onEdit != null)
              ListTile(
                leading: Icon(Icons.edit_rounded, color: cs.primary),
                title: const Text('Edit Playlist'),
                onTap: () { Navigator.pop(ctx); onEdit!(); },
              ),
            if (onDelete != null)
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                title: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
                onTap: () { Navigator.pop(ctx); onDelete!(); },
              ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
