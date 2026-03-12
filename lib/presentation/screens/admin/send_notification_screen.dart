import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/network/supabase_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/playlists_provider.dart';

// ──────────────────────────────────────────
// Simple data holder for a picked entity
// ──────────────────────────────────────────

class _PickedEntity {
  final String id;
  final String titleAr;
  final String titleEn;
  final String? imageUrl;
  _PickedEntity({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    this.imageUrl,
  });
}

// ──────────────────────────────────────────
// Route & action option models
// ──────────────────────────────────────────

class _ActionOption {
  final String value;
  final String Function(AppLocalizations) label;
  final IconData icon;
  const _ActionOption(this.value, this.label, this.icon);
}

class _RouteOption {
  final String value;
  final String Function(AppLocalizations) label;
  // 'none' | 'track' | 'album' | 'playlist'
  final String entityKind;
  const _RouteOption(this.value, this.label, {this.entityKind = 'none'});
}

// ──────────────────────────────────────────
// Constants
// ──────────────────────────────────────────

final _actionOptions = [
  _ActionOption('none', (l) => l.adminNoAction, Icons.block_rounded),
  _ActionOption(
    'internal',
    (l) => l.adminInternalScreen,
    Icons.phone_android_rounded,
  ),
  _ActionOption(
    'external',
    (l) => l.adminExternalLink,
    Icons.open_in_new_rounded,
  ),
];

final _routeOptions = [
  _RouteOption('/home', (l) => l.adminRouteHome),
  _RouteOption('/library', (l) => l.adminRouteLibrary),
  _RouteOption('/search', (l) => l.adminRouteSearch),
  _RouteOption('/favorites', (l) => l.adminRouteFavorites),
  _RouteOption('/downloads', (l) => l.adminRouteDownloads),
  _RouteOption('/photo-gallery', (l) => l.adminRoutePhotoGallery),
  _RouteOption('/video-gallery', (l) => l.adminRouteVideoGallery),
  _RouteOption(
    '/album/:id',
    (l) => l.adminRouteAudioAlbum,
    entityKind: 'album',
  ),
  _RouteOption(
    '/playlist/:id',
    (l) => l.adminRoutePlaylist,
    entityKind: 'playlist',
  ),
  _RouteOption('/player', (l) => l.adminRouteTrack, entityKind: 'track'),
  _RouteOption('/video/:id', (l) => l.adminRouteVideo, entityKind: 'video'),
  _RouteOption(
    '/photo-album/:id',
    (l) => l.adminRoutePhotoAlbum,
    entityKind: 'photo_album',
  ),
  _RouteOption(
    '/video-album/:id',
    (l) => l.adminRouteVideoAlbum,
    entityKind: 'video_album',
  ),
];

final List<Map<String, dynamic>> _audienceOptions = [
  {'value': 'all', 'label': (AppLocalizations l) => l.adminAudienceAll},
  {
    'value': 'specific',
    'label': (AppLocalizations l) => l.adminAudienceSpecific,
  },
];

final List<Map<String, dynamic>> _kindOptions = [
  {
    'value': 'general',
    'label': (AppLocalizations l) => l.adminNotificationKindGeneral,
  },
  {
    'value': 'new_track',
    'label': (AppLocalizations l) => l.adminNotificationKindNewTrack,
  },
  {
    'value': 'new_category',
    'label': (AppLocalizations l) => l.adminNotificationKindNewCategory,
  },
  {
    'value': 'system',
    'label': (AppLocalizations l) => l.adminNotificationKindSystem,
  },
  {
    'value': 'offer',
    'label': (AppLocalizations l) => l.adminNotificationKindOffer,
  },
];

// ──────────────────────────────────────────
// Main Screen
// ──────────────────────────────────────────

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleArCtrl = TextEditingController();
  final _titleEnCtrl = TextEditingController();
  final _bodyArCtrl = TextEditingController();
  final _bodyEnCtrl = TextEditingController();
  final _extUrlCtrl = TextEditingController();
  final _recipientCtrl = TextEditingController();

  String _selectedKind = 'general';
  String _selectedAudience = 'all';
  String _selectedAction = 'none';
  _RouteOption? _selectedRoute;

  // The entity picked via the smart picker (track / album / playlist)
  _PickedEntity? _pickedEntity;

  bool _isSending = false;

  @override
  void dispose() {
    _titleArCtrl.dispose();
    _titleEnCtrl.dispose();
    _bodyArCtrl.dispose();
    _bodyEnCtrl.dispose();
    _extUrlCtrl.dispose();
    _recipientCtrl.dispose();
    super.dispose();
  }

  // ── Send ────────────────────────────────
  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    if (_selectedAction == 'internal' && _selectedRoute == null) {
      _showWarning(l10n.adminSelectScreenWarning);
      return;
    }
    if (_selectedAction == 'internal' &&
        _selectedRoute?.entityKind != 'none' &&
        _pickedEntity == null) {
      _showWarning(
        l10n.adminSelectEntityWarning(
          _entityLabel(_selectedRoute?.entityKind, l10n),
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final recipients = _selectedAudience == 'specific'
          ? _recipientCtrl.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : <String>[];

      await SupabaseService.instance.sendNotification(
        titleAr: _titleArCtrl.text.trim(),
        titleEn: _titleEnCtrl.text.trim(),
        bodyAr: _bodyArCtrl.text.trim().isEmpty
            ? null
            : _bodyArCtrl.text.trim(),
        bodyEn: _bodyEnCtrl.text.trim().isEmpty
            ? null
            : _bodyEnCtrl.text.trim(),
        kind: _selectedKind,
        audience: _selectedAudience,
        actionType: _selectedAction,
        internalRoute: _selectedAction == 'internal'
            ? _selectedRoute?.value
            : null,
        internalId:
            (_selectedAction == 'internal' &&
                _selectedRoute?.entityKind != 'none')
            ? _pickedEntity?.id
            : null,
        entityType:
            (_selectedAction == 'internal' &&
                _selectedRoute?.entityKind != 'none')
            ? _selectedRoute?.entityKind
            : null,
        entityId:
            (_selectedAction == 'internal' &&
                _selectedRoute?.entityKind != 'none')
            ? _pickedEntity?.id
            : null,
        externalUrl: _selectedAction == 'external'
            ? _extUrlCtrl.text.trim()
            : null,
        imageUrl: _pickedEntity?.imageUrl,
        recipientUserIds: recipients,
      );

      if (mounted) {
        _showSuccess(l10n.adminSendNotificationSuccess);
        _resetForm();
      }
    } catch (e) {
      if (mounted) _showError('${l10n.errorOccurred}: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleArCtrl.clear();
    _titleEnCtrl.clear();
    _bodyArCtrl.clear();
    _bodyEnCtrl.clear();
    _extUrlCtrl.clear();
    _recipientCtrl.clear();
    setState(() {
      _selectedKind = 'general';
      _selectedAudience = 'all';
      _selectedAction = 'none';
      _selectedRoute = null;
      _pickedEntity = null;
    });
  }

  // ── Entity picker bottom sheet ───────────
  Future<void> _openEntityPicker(String kind) async {
    final picked = await showModalBottomSheet<_PickedEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EntityPickerSheet(kind: kind),
    );
    if (picked != null) setState(() => _pickedEntity = picked);
  }

  String _entityLabel(String? kind, AppLocalizations l10n) {
    switch (kind) {
      case 'track':
        return l10n.adminTrack;
      case 'album':
        return l10n
            .adminPhotoAlbum; // This is used for audio albums too in some contexts, but let's be consistent
      case 'playlist':
        return l10n.navigationLibrary;
      case 'video':
        return l10n.adminVideo;
      case 'photo_album':
        return l10n.adminPhotoAlbum;
      case 'video_album':
        return l10n.adminVideoAlbum;
      default:
        return '';
    }
  }

  // ── Snackbars ────────────────────────────
  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8.w),
            Text(msg),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ $msg'),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0E0E1A)
          : const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.adminSendNewNotification,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            _buildBanner(cs, l10n),
            SizedBox(height: 24.h),

            // ── Content ──
            _buildSectionTitle('📝 ${l10n.adminNotificationContent}', cs),
            SizedBox(height: 12.h),
            _buildTextField(
              controller: _titleArCtrl,
              label: l10n.adminTitleAr,
              hint: l10n.adminTitleHintAr,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.required : null,
            ),
            SizedBox(height: 12.h),
            _buildTextField(
              controller: _titleEnCtrl,
              label: l10n.adminTitleEn,
              hint: l10n.adminTitleHintEn,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.required : null,
            ),
            SizedBox(height: 12.h),
            _buildTextField(
              controller: _bodyArCtrl,
              label: l10n.adminBodyAr,
              hint: l10n.adminBodyHintAr,
              maxLines: 3,
            ),
            SizedBox(height: 12.h),
            _buildTextField(
              controller: _bodyEnCtrl,
              label: l10n.adminBodyEn,
              hint: l10n.adminBodyHintEn,
              maxLines: 3,
            ),

            SizedBox(height: 24.h),

            // ── Settings ──
            _buildSectionTitle('⚙️ ${l10n.adminSettings}', cs),
            SizedBox(height: 12.h),
            _buildDropdownCard(
              label: l10n.adminNotificationKind,
              icon: Icons.label_rounded,
              value: _selectedKind,
              items: _kindOptions
                  .map(
                    (k) => DropdownMenuItem<String>(
                      value: k['value'] as String,
                      child: Text(k['label'](l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedKind = v!),
            ),
            SizedBox(height: 12.h),
            _buildDropdownCard(
              label: l10n.adminTargetAudience,
              icon: Icons.people_rounded,
              value: _selectedAudience,
              items: _audienceOptions
                  .map(
                    (a) => DropdownMenuItem<String>(
                      value: a['value'] as String,
                      child: Text(a['label'](l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedAudience = v!),
            ),
            if (_selectedAudience == 'specific') ...[
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _recipientCtrl,
                label: l10n.adminUserUuids,
                hint: l10n.adminUserUuidsHint,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.adminUserUuidsHint
                    : null,
              ),
              _buildHintText(l10n.adminUserUuidsHelper),
            ],

            SizedBox(height: 24.h),

            // ── Action ──
            _buildSectionTitle('👆 ${l10n.adminOnTapAction}', cs),
            SizedBox(height: 12.h),
            _buildActionTypePicker(cs, l10n),

            if (_selectedAction == 'internal') ...[
              SizedBox(height: 16.h),
              _buildRoutePicker(cs, l10n),

              // Smart entity picker — shown instead of raw UUID field
              if (_selectedRoute?.entityKind != null &&
                  _selectedRoute?.entityKind != 'none') ...[
                SizedBox(height: 14.h),
                _buildEntityPickerButton(cs, l10n),
              ],
            ],

            if (_selectedAction == 'external') ...[
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _extUrlCtrl,
                label: l10n.adminExternalUrl,
                hint: l10n.adminExternalUrlHint,
                keyboardType: TextInputType.url,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.required;
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasScheme)
                    return l10n.adminInvalidUrl;
                  return null;
                },
              ),
            ],

            SizedBox(height: 36.h),
            _buildSendButton(cs, l10n),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ── Widgets ─────────────────────────────

  Widget _buildBanner(ColorScheme cs, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(0.15),
            cs.primaryContainer.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: cs.primary,
              size: 24.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.adminNotificationBannerTitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.adminNotificationBannerSubtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme cs) => Text(
    title,
    style: TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: cs.onSurface.withOpacity(0.8),
      letterSpacing: 0.3,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 13.sp, color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 12.sp,
          color: cs.onSurface.withOpacity(0.35),
        ),
        labelStyle: TextStyle(fontSize: 12.sp, color: cs.primary),
        filled: true,
        fillColor: isDark ? const Color(0xFF1C1C2E) : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildDropdownCard({
    required String label,
    required IconData icon,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C2E) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  fontSize: 11.sp,
                  color: cs.onSurface.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 13.sp, color: cs.onSurface),
              dropdownColor: isDark ? const Color(0xFF1C1C2E) : Colors.white,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTypePicker(ColorScheme cs, AppLocalizations l10n) {
    return Row(
      children: _actionOptions.map((opt) {
        final isSelected = _selectedAction == opt.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedAction = opt.value;
              _selectedRoute = null;
              _pickedEntity = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primary.withOpacity(0.15)
                    : (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1C1C2E)
                          : Colors.white),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected ? cs.primary : cs.outline.withOpacity(0.2),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    opt.icon,
                    color: isSelected
                        ? cs.primary
                        : cs.onSurface.withOpacity(0.4),
                    size: 22.w,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    opt.label(l10n),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? cs.primary
                          : cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoutePicker(ColorScheme cs, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.adminSelectScreen,
          style: TextStyle(
            fontSize: 12.sp,
            color: cs.onSurface.withOpacity(0.6),
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _routeOptions.map((route) {
            final isSelected = _selectedRoute?.value == route.value;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedRoute = route;
                _pickedEntity = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primary.withOpacity(0.15)
                      : (isDark ? const Color(0xFF1C1C2E) : Colors.white),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected
                        ? cs.primary
                        : cs.outline.withOpacity(0.2),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (route.entityKind != 'none')
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Icon(
                          Icons.touch_app_rounded,
                          size: 13.w,
                          color: isSelected
                              ? cs.primary
                              : cs.onSurface.withOpacity(0.4),
                        ),
                      ),
                    Text(
                      route.label(l10n),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? cs.primary
                            : cs.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedRoute == null)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              '⚠️ ${l10n.adminSelectScreenWarning}',
              style: TextStyle(fontSize: 10.sp, color: Colors.orange.shade400),
            ),
          ),
      ],
    );
  }

  /// Smart entity picker button — shows picked entity or "اختر X" prompt
  Widget _buildEntityPickerButton(ColorScheme cs, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kind = _selectedRoute?.entityKind ?? 'none';
    final label = _entityLabel(kind, l10n);
    final hasPicked = _pickedEntity != null;

    return GestureDetector(
      onTap: () => _openEntityPicker(kind),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: hasPicked
              ? cs.primary.withOpacity(0.08)
              : (isDark ? const Color(0xFF1C1C2E) : Colors.white),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasPicked ? cs.primary : cs.outline.withOpacity(0.3),
            width: hasPicked ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: hasPicked
                    ? cs.primary.withOpacity(0.12)
                    : cs.onSurface.withOpacity(0.06),
                image: (hasPicked && _pickedEntity?.imageUrl != null)
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(
                          _pickedEntity!.imageUrl!,
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (!hasPicked || _pickedEntity?.imageUrl == null)
                  ? Icon(
                      _iconForKind(kind),
                      color: hasPicked
                          ? cs.primary
                          : cs.onSurface.withOpacity(0.3),
                      size: 22.w,
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasPicked
                        ? _pickedEntity!.titleAr
                        : l10n.adminChooseEntity(label),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: hasPicked
                          ? cs.onSurface
                          : cs.onSurface.withOpacity(0.5),
                    ),
                  ),
                  if (hasPicked) ...[
                    SizedBox(height: 2.h),
                    Text(
                      _pickedEntity!.titleEn,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              hasPicked
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              color: hasPicked ? cs.primary : cs.onSurface.withOpacity(0.3),
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintText(String text) => Padding(
    padding: EdgeInsets.only(top: 4.h, right: 4.w),
    child: Text(
      '💡 $text',
      style: TextStyle(
        fontSize: 10.sp,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
      ),
    ),
  );

  Widget _buildSendButton(ColorScheme cs, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: _isSending ? null : _send,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: _isSending
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 18.w),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.adminSendNotification,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Entity Picker Bottom Sheet
// ──────────────────────────────────────────

class _EntityPickerSheet extends StatefulWidget {
  final String
  kind; // 'track' | 'album' | 'playlist' | 'video' | 'photo_album' | 'video_album'
  const _EntityPickerSheet({required this.kind});

  @override
  State<_EntityPickerSheet> createState() => _EntityPickerSheetState();
}

class _EntityPickerSheetState extends State<_EntityPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<_PickedEntity> _all = [];
  List<_PickedEntity> _filtered = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final client = SupabaseService.instance.client;
      List<_PickedEntity> results = [];

      if (widget.kind == 'track') {
        final data = await client
            .from('tracks')
            .select(
              'id, title_ar, title_en, cover_image_url, speaker_ar, speaker_en',
            )
            .eq('is_active', true)
            .order('created_at', ascending: false)
            .limit(500);
        results = (data as List)
            .map(
              (r) => _PickedEntity(
                id: r['id'],
                titleAr: '${r['title_ar'] ?? ''} - ${r['speaker_ar'] ?? ''}',
                titleEn: '${r['title_en'] ?? ''} - ${r['speaker_en'] ?? ''}',
                imageUrl: r['cover_image_url'],
              ),
            )
            .toList();
      } else if (widget.kind == 'album') {
        // Audio albums (categories used as albums)
        final data = await client
            .from('categories')
            .select(
              'id, title_ar, title_en, image_url, subtitle_ar, subtitle_en',
            )
            .eq('is_active', true)
            .order('sort_order', ascending: true)
            .limit(500);
        results = (data as List)
            .map(
              (r) => _PickedEntity(
                id: r['id'],
                titleAr: '${r['title_ar'] ?? ''} (${r['subtitle_ar'] ?? ''})',
                titleEn: '${r['title_en'] ?? ''} (${r['subtitle_en'] ?? ''})',
                imageUrl: r['image_url'],
              ),
            )
            .toList();
      } else if (widget.kind == 'playlist') {
        final data = await client
            .from('playlists')
            .select('id, title_ar, title_en, image_url')
            .order('created_at', ascending: false)
            .limit(500);
        results = (data as List)
            .map(
              (r) => _PickedEntity(
                id: r['id'],
                titleAr: r['title_ar'] ?? '',
                titleEn: r['title_en'] ?? '',
                imageUrl: r['image_url'],
              ),
            )
            .toList();
      } else if (widget.kind == 'video') {
        final data = await client
            .from('videos')
            .select(
              'id, title_ar, title_en, thumbnail_url, subtitle_ar, subtitle_en',
            )
            .eq('is_active', true)
            .order('sort_order', ascending: true)
            .limit(500);
        results = (data as List)
            .map(
              (r) => _PickedEntity(
                id: r['id'],
                titleAr: '${r['title_ar'] ?? ''} (${r['subtitle_ar'] ?? ''})',
                titleEn: '${r['title_en'] ?? ''} (${r['subtitle_en'] ?? ''})',
                imageUrl: r['thumbnail_url'],
              ),
            )
            .toList();
      } else if (widget.kind == 'photo_album') {
        final data = await client
            .from('photo_albums')
            .select('id, title_ar, title_en, cover_image_url')
            .eq('is_active', true)
            .order('sort_order', ascending: true)
            .limit(500);
        results = (data as List)
            .map(
              (r) => _PickedEntity(
                id: r['id'],
                titleAr: r['title_ar'] ?? '',
                titleEn: r['title_en'] ?? '',
                imageUrl: r['cover_image_url'],
              ),
            )
            .toList();
      } else if (widget.kind == 'video_album') {
        final data = await client
            .from('video_albums')
            .select('id, title_ar, title_en, cover_image_url')
            .eq('is_active', true)
            .order('sort_order', ascending: true)
            .limit(500);
        results = (data as List)
            .map(
              (r) => _PickedEntity(
                id: r['id'],
                titleAr: r['title_ar'] ?? '',
                titleEn: r['title_en'] ?? '',
                imageUrl: r['cover_image_url'],
              ),
            )
            .toList();
      }

      if (mounted)
        setState(() {
          _all = results;
          _filtered = results;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
    }
  }

  void _filter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all
                .where(
                  (e) =>
                      e.titleAr.toLowerCase().contains(q) ||
                      e.titleEn.toLowerCase().contains(q),
                )
                .toList();
    });
  }

  String _sheetTitle(AppLocalizations l10n) {
    switch (widget.kind) {
      case 'track':
        return l10n.adminRouteTrack;
      case 'album':
        return l10n.adminRouteAudioAlbum;
      case 'video':
        return l10n.adminRouteVideo;
      case 'playlist':
        return l10n.adminRoutePlaylist;
      case 'photo_album':
        return l10n.adminRoutePhotoAlbum;
      case 'video_album':
        return l10n.adminRouteVideoAlbum;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E0E1A) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: cs.onSurface.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              _sheetTitle(l10n),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(fontSize: 13.sp, color: cs.onSurface),
              decoration: InputDecoration(
                hintText: l10n.adminSearchByName,
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: cs.onSurface.withOpacity(0.4),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: cs.primary,
                  size: 20.w,
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF1C1C2E)
                    : const Color(0xFFF4F4F8),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: cs.outlineVariant.withOpacity(0.3)),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Text(
                      'Error: $_error',
                      style: TextStyle(color: cs.error, fontSize: 12.sp),
                    ),
                  )
                : _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No results',
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.4),
                        fontSize: 13.sp,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 16.w,
                    ),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: cs.outlineVariant.withOpacity(0.2),
                    ),
                    itemBuilder: (context, index) {
                      final entity = _filtered[index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 4.h,
                        ),
                        leading: Container(
                          width: 46.w,
                          height: 46.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            color: cs.primary.withOpacity(0.08),
                            image: entity.imageUrl != null
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      entity.imageUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: entity.imageUrl == null
                              ? Icon(
                                  _iconForKind(widget.kind),
                                  color: cs.primary.withOpacity(0.5),
                                  size: 22.w,
                                )
                              : (widget.kind == 'playlist')
                              ? Icon(
                                  playlistIcon(entity.imageUrl),
                                  color: cs.primary,
                                  size: 22.w,
                                )
                              : null,
                        ),
                        title: Text(
                          entity.titleAr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: entity.titleEn != entity.titleAr
                            ? Text(
                                entity.titleEn,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: cs.onSurface.withOpacity(0.5),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14.w,
                          color: cs.onSurface.withOpacity(0.3),
                        ),
                        onTap: () => Navigator.of(context).pop(entity),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────

IconData _iconForKind(String kind) {
  switch (kind) {
    case 'track':
      return Icons.headphones_rounded;
    case 'album':
      return Icons.album_rounded;
    case 'playlist':
      return Icons.queue_music_rounded;
    case 'video':
      return Icons.play_circle_fill_rounded;
    case 'photo_album':
      return Icons.photo_library_rounded;
    case 'video_album':
      return Icons.video_library_rounded;
    default:
      return Icons.link_rounded;
  }
}
