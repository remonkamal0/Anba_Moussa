import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/photo.dart';
import '../../../../l10n/app_localizations.dart';
import 'admin_photos_screen.dart';

class AdminPhotoFormScreen extends ConsumerStatefulWidget {
  final Photo? photo;
  final String albumId;

  const AdminPhotoFormScreen({super.key, this.photo, required this.albumId});

  @override
  ConsumerState<AdminPhotoFormScreen> createState() =>
      _AdminPhotoFormScreenState();
}

class _AdminPhotoFormScreenState extends ConsumerState<AdminPhotoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleArCtrl;
  late TextEditingController _titleEnCtrl;
  late TextEditingController _captionArCtrl;
  late TextEditingController _captionEnCtrl;
  late TextEditingController _imageUrlCtrl;
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    final p = widget.photo;
    _titleArCtrl = TextEditingController(text: p?.titleAr ?? '');
    _titleEnCtrl = TextEditingController(text: p?.titleEn ?? '');
    _captionArCtrl = TextEditingController(text: p?.captionAr ?? '');
    _captionEnCtrl = TextEditingController(text: p?.captionEn ?? '');
    _imageUrlCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _createdAt = p?.createdAt;
  }

  @override
  void dispose() {
    _titleArCtrl.dispose();
    _titleEnCtrl.dispose();
    _captionArCtrl.dispose();
    _captionEnCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = ref.read(adminPhotoProvider);
    final now = DateTime.now();

    final newPhoto = Photo(
      id: widget.photo?.id ?? '',
      albumId: widget.albumId,
      titleAr: _titleArCtrl.text.isEmpty ? null : _titleArCtrl.text,
      titleEn: _titleEnCtrl.text.isEmpty ? null : _titleEnCtrl.text,
      captionAr: _captionArCtrl.text.isEmpty ? null : _captionArCtrl.text,
      captionEn: _captionEnCtrl.text.isEmpty ? null : _captionEnCtrl.text,
      imageUrl: _imageUrlCtrl.text,
      sortOrder: widget.photo?.sortOrder ?? 0,
      isActive: widget.photo?.isActive ?? true,
      createdAt: _createdAt ?? now,
      updatedAt: now,
    );

    bool success;
    if (widget.photo == null) {
      success = await provider.createPhoto(newPhoto);
    } else {
      success = await provider.updatePhoto(newPhoto);
    }

    if (success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.photo == null
                ? l10n.adminCreated(l10n.adminPhoto.toLowerCase())
                : l10n.adminUpdated(l10n.adminPhoto.toLowerCase()),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(adminPhotoProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.photo == null
              ? l10n.adminNew(l10n.adminPhoto)
              : l10n.adminEdit(l10n.adminPhoto),
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
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleEnCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminTitleEn,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _captionArCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminBodyAr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _captionEnCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminBodyEn,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminImageUrl,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? l10n.required : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _submit,
                      child: Text(
                        widget.photo == null
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
