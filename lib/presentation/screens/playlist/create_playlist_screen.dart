import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/playlists_provider.dart';
import '../../../core/network/supabase_service.dart';
import '../../../domain/entities/track.dart';
import '../../../l10n/app_localizations.dart';

class CreatePlaylistScreen extends ConsumerStatefulWidget {
  final PlaylistModel? existingPlaylist;

  const CreatePlaylistScreen({super.key, this.existingPlaylist});

  @override
  ConsumerState<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends ConsumerState<CreatePlaylistScreen> {
  // ── Step control ─────────────────────────────────────────────────────────────
  int _step = 0; // 0 = details, 1 = track picker

  // ── Step 0 fields ─────────────────────────────────────────────────────────────
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  String _selectedIconName = 'music_note';
  bool _isPublic = false;

  // ── Step 1 fields ─────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _allTrackData = [];
  List<Map<String, dynamic>> _filteredTrackData = [];
  final Set<String> _selectedTrackIds = {};
  final TextEditingController _searchController = TextEditingController();
  bool _loadingTracks = false;

  // ── Saving ────────────────────────────────────────────────────────────────────
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingPlaylist != null) {
      final p = widget.existingPlaylist!;
      _nameArController.text = p.titleAr;
      _nameEnController.text = p.titleEn;
      _selectedIconName = p.iconName ?? 'music_note';
      _isPublic = p.isPublic;
      _loadExistingTracks();
    }
  }

  Future<void> _loadExistingTracks() async {
    if (widget.existingPlaylist == null) return;
    try {
      final rows = await SupabaseService.instance.client
          .from('playlist_tracks')
          .select('track_id')
          .eq('playlist_id', widget.existingPlaylist!.id);
      
      final ids = (rows as List).map((r) => r['track_id'] as String).toSet();
      setState(() => _selectedTrackIds.addAll(ids));
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Load tracks for step 1 ───────────────────────────────────────────────────
  Future<void> _loadTracks() async {
    if (_allTrackData.isNotEmpty) return; // Don't reload if already have them
    setState(() => _loadingTracks = true);
    try {
      final rows = await SupabaseService.instance.client
          .from('tracks')
          .select('*, categories(title_ar, title_en)')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final trackData = (rows as List).map((r) => r as Map<String, dynamic>).toList();

      setState(() {
        _allTrackData = trackData;
        _filteredTrackData = trackData;
        _loadingTracks = false;
      });
    } catch (e) {
      setState(() => _loadingTracks = false);
    }
  }

  void _filterTracks(String q) {
    setState(() {
      _filteredTrackData = _allTrackData
          .where((t) =>
              (t['title_ar'] as String? ?? '').toLowerCase().contains(q.toLowerCase()) ||
              (t['title_en'] as String? ?? '').toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  // ── Navigate between steps ──────────────────────────────────────────────────
  void _goToStep1() {
    final titleEn = _nameEnController.text.trim();
    final titleAr = _nameArController.text.trim();
    if (titleEn.isEmpty && titleAr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.playlistEnterNameError)),
      );
      return;
    }
    _loadTracks();
    setState(() => _step = 1);
  }

  // ── Icon picker ──────────────────────────────────────────────────────────────
  void _showIconPicker() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w, height: 4.h,
              decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4.r)),
            ),
            SizedBox(height: 16.h),
            Text(AppLocalizations.of(context)!.playlistChooseIcon, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 20.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, mainAxisSpacing: 16.h, crossAxisSpacing: 16.w,
              ),
              itemCount: playlistIconMap.length,
              itemBuilder: (_, i) {
                final entry = playlistIconMap.entries.elementAt(i);
                final isSelected = _selectedIconName == entry.key;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedIconName = entry.key);
                    Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? cs.primary : cs.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: isSelected
                          ? [BoxShadow(color: cs.primary.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))]
                          : null,
                    ),
                    child: Icon(entry.value, color: isSelected ? Colors.white : cs.primary, size: 28.sp),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    final titleEn = _nameEnController.text.trim();
    final titleAr = _nameArController.text.trim().isEmpty ? titleEn : _nameArController.text.trim();

    setState(() => _isSaving = true);

    final notifier = ref.read(playlistsProvider.notifier);
    String? pid;

    if (widget.existingPlaylist != null) {
      pid = widget.existingPlaylist!.id;
      await notifier.updatePlaylist(
        id: pid,
        titleAr: titleAr,
        titleEn: titleEn,
        iconName: _selectedIconName,
        isPublic: _isPublic,
      );
    } else {
      final created = await notifier.createPlaylist(
        titleAr: titleAr,
        titleEn: titleEn,
        iconName: _selectedIconName,
        isPublic: _isPublic,
      );
      pid = created?.id;
    }

    // Sync selected tracks
    if (pid != null) {
      // Simplest way to "edit" tracks is to delete all and re-insert
      // or we can be smarter, but for now this is reliable
      await SupabaseService.instance.client
          .from('playlist_tracks')
          .delete()
          .eq('playlist_id', pid);

      if (_selectedTrackIds.isNotEmpty) {
        // We need to maintain some order, let's use the order from _allTrackData 
        // if available, or just as they come.
        List<Map<String, dynamic>> toInsert = [];
        int pos = 0;
        for (var tid in _selectedTrackIds) {
          toInsert.add({
            'playlist_id': pid,
            'track_id': tid,
            'position': pos++,
          });
        }
        await SupabaseService.instance.client
            .from('playlist_tracks')
            .insert(toInsert);
        
        // Refresh the count locally
        ref.read(playlistsProvider.notifier).fetch();
        // Invalidate tracks provider so details screen reloads
        ref.invalidate(playlistTracksProvider(pid));
      }
    }

    setState(() => _isSaving = false);
    if (mounted) Navigator.of(context).pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return _step == 0 ? _buildStep0() : _buildStep1();
  }

  // ── Step 0: Details ──────────────────────────────────────────────────────────
  Widget _buildStep0() {
    final cs = Theme.of(context).colorScheme;
    final isEditing = widget.existingPlaylist != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(Icons.close, color: cs.onSurface, size: 18),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(isEditing ? AppLocalizations.of(context)!.playlistEdit : AppLocalizations.of(context)!.playlistCreateTitle,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              if (!isEditing) _stepIndicator(0),
              SizedBox(height: 24.h),

              // Icon picker
              Center(
                child: GestureDetector(
                  onTap: _showIconPicker,
                  child: Container(
                    width: 130.w, height: 130.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [cs.primary.withValues(alpha: 0.9), cs.primary.withValues(alpha: 0.6)],
                      ),
                      boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.30), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(playlistIcon(_selectedIconName), color: Colors.white, size: 52.sp),
                        Positioned(
                          bottom: 10.h, right: 10.w,
                          child: Container(
                            padding: EdgeInsets.all(5.r),
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6)]),
                            child: Icon(Icons.edit_rounded, size: 13.sp, color: cs.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Center(child: Text(AppLocalizations.of(context)!.playlistTapToChangeIcon, style: TextStyle(fontSize: 11.sp, color: cs.onSurface.withValues(alpha: 0.4)))),
              SizedBox(height: 28.h),

              // Name EN
              _label(AppLocalizations.of(context)!.playlistNameEnLabel, cs),
              SizedBox(height: 8.h),
              _textField(controller: _nameEnController, hint: AppLocalizations.of(context)!.playlistNameEnHint, cs: cs),
              SizedBox(height: 16.h),

              // Name AR
              _label(AppLocalizations.of(context)!.playlistNameArLabel, cs),
              SizedBox(height: 8.h),
              _textField(controller: _nameArController, hint: AppLocalizations.of(context)!.playlistNameArHint, cs: cs, textDirection: TextDirection.rtl),
              SizedBox(height: 20.h),

              // Public toggle
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16.r)),
                child: Row(
                  children: [
                    Icon(Icons.public_rounded, color: cs.primary, size: 22.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.playlistPublicLabel, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                          Text(AppLocalizations.of(context)!.playlistPublicSubtitle, style: TextStyle(fontSize: 11.sp, color: cs.onSurface.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                    Switch(value: _isPublic, onChanged: (v) => setState(() => _isPublic = v), activeThumbColor: cs.primary),
                  ],
                ),
              ),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SizedBox(
          width: double.infinity, height: 54.h,
          child: ElevatedButton(
            onPressed: _goToStep1,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.playlistNextTracksSave,
                    style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                SizedBox(width: 8.w), Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 1: Track Picker ─────────────────────────────────────────────────────
  Widget _buildStep1() {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => setState(() => _step = 0),
        ),
        title: Text(AppLocalizations.of(context)!.playlistAddTracks, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (_selectedTrackIds.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20.r)),
                  child: Text(AppLocalizations.of(context)!.playlistSelectedCount(_selectedTrackIds.length), style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 12.sp)),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator
            Padding(padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h), child: _stepIndicator(1)),

            // Search
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: TextField(
                controller: _searchController,
                onChanged: _filterTracks,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.playlistSearchTracksHint,
                  hintStyle: TextStyle(fontSize: 13.sp, color: cs.onSurface.withValues(alpha: 0.4)),
                  prefixIcon: Icon(Icons.search, size: 20.sp, color: cs.onSurface.withValues(alpha: 0.4)),
                  filled: true,
                  fillColor: cs.onSurface.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(28.r), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),

            // Track list
            Expanded(
                      child: _loadingTracks
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredTrackData.isEmpty
                              ? Center(child: Text(AppLocalizations.of(context)!.playlistNoTracksFound, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4))))
                              : ListView.builder(
                                  itemCount: _filteredTrackData.length,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  itemBuilder: (_, i) {
                                    final track = _filteredTrackData[i];
                                    final locale = Localizations.localeOf(context).languageCode;
                                    final tid = track['id'] as String;
                                    final isSelected = _selectedTrackIds.contains(tid);

                                    final title = locale == 'ar' ? (track['title_ar'] as String? ?? '') : (track['title_en'] as String? ?? '');
                                    final categories = track['categories'] as Map<String, dynamic>?;
                                    final albumTitle = categories != null 
                                      ? (locale == 'ar' ? (categories['title_ar'] as String? ?? '') : (categories['title_en'] as String? ?? ''))
                                      : AppLocalizations.of(context)!.playlistNoAlbum;
                                    
                                    final imageUrl = track['cover_image_url'] as String?;

                                    return ListTile(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(10.r),
                                        child: imageUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                width: 48.w, height: 48.w, fit: BoxFit.cover,
                                                placeholder: (_, __) => Container(color: cs.primary.withValues(alpha: 0.1),
                                                    child: Icon(Icons.music_note_rounded, color: cs.primary, size: 22.sp)),
                                                errorWidget: (_, __, ___) => Container(color: cs.primary.withValues(alpha: 0.1),
                                                    child: Icon(Icons.music_note_rounded, color: cs.primary, size: 22.sp)),
                                              )
                                            : Container(width: 48.w, height: 48.w,
                                                color: cs.primary.withValues(alpha: 0.1),
                                                child: Icon(Icons.music_note_rounded, color: cs.primary, size: 22.sp)),
                                      ),
                                      title: Text(
                                        title,
                                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        albumTitle,
                                        style: TextStyle(fontSize: 11.sp, color: cs.onSurface.withValues(alpha: 0.5)),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: GestureDetector(
                                        onTap: () => setState(() {
                                          if (isSelected) _selectedTrackIds.remove(tid);
                                          else _selectedTrackIds.add(tid);
                                        }),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 26.r, height: 26.r,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected ? cs.primary : Colors.transparent,
                                            border: Border.all(color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.25), width: 2),
                                          ),
                                          child: isSelected ? Icon(Icons.check_rounded, color: Colors.white, size: 14.sp) : null,
                                        ),
                                      ),
                                      onTap: () => setState(() {
                                        if (isSelected) _selectedTrackIds.remove(tid);
                                        else _selectedTrackIds.add(tid);
                                      }),
                                    );
                                  },
                                ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: SizedBox(
          width: double.infinity, height: 54.h,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              disabledBackgroundColor: cs.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
              elevation: 0,
            ),
            child: _isSaving
                ? SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(
                    _selectedTrackIds.isEmpty 
                        ? AppLocalizations.of(context)!.playlistCreateEmpty 
                        : AppLocalizations.of(context)!.playlistCreateWithCount(_selectedTrackIds.length),
                    style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator(int active) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [0, 1].map((i) {
        final done = i < active;
        final current = i == active;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: current ? 28.w : 22.w, height: 4.h,
                decoration: BoxDecoration(
                  color: done || current ? cs.primary : cs.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              if (i == 0) SizedBox(width: 6.w),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _label(String text, ColorScheme cs) => Text(text,
      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.1));

  Widget _textField({required TextEditingController controller, required String hint, required ColorScheme cs, TextDirection textDirection = TextDirection.ltr}) =>
      TextField(
        controller: controller, textDirection: textDirection,
        style: TextStyle(color: cs.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.3), fontSize: 14.sp),
          filled: true, fillColor: cs.onSurface.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        ),
      );
}
