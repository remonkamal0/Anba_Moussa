import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/photo_album.dart';
import '../../../../l10n/app_localizations.dart';
import 'admin_photo_albums_screen.dart';

class AdminPhotoAlbumFormScreen extends ConsumerStatefulWidget {
  final PhotoAlbum? album;

  const AdminPhotoAlbumFormScreen({super.key, this.album});

  @override
  ConsumerState<AdminPhotoAlbumFormScreen> createState() =>
      _AdminPhotoAlbumFormScreenState();
}

class _AdminPhotoAlbumFormScreenState
    extends ConsumerState<AdminPhotoAlbumFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleArCtrl;
  late TextEditingController _titleEnCtrl;
  late TextEditingController _subtitleArCtrl;
  late TextEditingController _subtitleEnCtrl;
  late TextEditingController _coverUrlCtrl;
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    final a = widget.album;
    _titleArCtrl = TextEditingController(text: a?.titleAr ?? '');
    _titleEnCtrl = TextEditingController(text: a?.titleEn ?? '');
    _subtitleArCtrl = TextEditingController(text: a?.subtitleAr ?? '');
    _subtitleEnCtrl = TextEditingController(text: a?.subtitleEn ?? '');
    _coverUrlCtrl = TextEditingController(text: a?.coverImageUrl ?? '');
    _createdAt = a?.createdAt;
  }

  @override
  void dispose() {
    _titleArCtrl.dispose();
    _titleEnCtrl.dispose();
    _subtitleArCtrl.dispose();
    _subtitleEnCtrl.dispose();
    _coverUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = ref.read(adminPhotoAlbumProvider);
    final now = DateTime.now();

    final newAlbum = PhotoAlbum(
      id: widget.album?.id ?? '',
      titleAr: _titleArCtrl.text,
      titleEn: _titleEnCtrl.text,
      subtitleAr: _subtitleArCtrl.text.isEmpty ? null : _subtitleArCtrl.text,
      subtitleEn: _subtitleEnCtrl.text.isEmpty ? null : _subtitleEnCtrl.text,
      coverImageUrl: _coverUrlCtrl.text.isEmpty ? null : _coverUrlCtrl.text,
      sortOrder: widget.album?.sortOrder ?? 0,
      isActive: widget.album?.isActive ?? true,
      createdAt: _createdAt ?? now,
      updatedAt: now,
    );

    bool success;
    if (widget.album == null) {
      success = await provider.createAlbum(newAlbum);
    } else {
      success = await provider.updateAlbum(newAlbum);
    }

    if (success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.album == null
                ? l10n.adminCreated(l10n.adminPhotoAlbum.toLowerCase())
                : l10n.adminUpdated(l10n.adminPhotoAlbum.toLowerCase()),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(adminPhotoAlbumProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.album == null
              ? l10n.adminNew(l10n.adminPhotoAlbum)
              : l10n.adminEdit(l10n.adminPhotoAlbum),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleArCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminTitleAr,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? l10n.required : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleEnCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminTitleEn,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? l10n.required : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subtitleArCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminSubtitleAr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subtitleEnCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminSubtitleEn,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _coverUrlCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminCoverImageUrl,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _submit,
                      child: Text(
                        widget.album == null
                            ? l10n.adminCreate
                            : l10n.adminUpdate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
