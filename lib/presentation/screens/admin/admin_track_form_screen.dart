import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/entities/category.dart';
import '../../../../l10n/app_localizations.dart';
import 'admin_tracks_screen.dart';
import 'admin_categories_screen.dart'; // To load categories for dropdown

class AdminTrackFormScreen extends ConsumerStatefulWidget {
  final Track? track;

  const AdminTrackFormScreen({super.key, this.track});

  @override
  ConsumerState<AdminTrackFormScreen> createState() =>
      _AdminTrackFormScreenState();
}

class _AdminTrackFormScreenState extends ConsumerState<AdminTrackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _categoryId;
  late TextEditingController _titleArCtrl;
  late TextEditingController _titleEnCtrl;
  late TextEditingController _subtitleArCtrl;
  late TextEditingController _subtitleEnCtrl;
  late TextEditingController _descriptionArCtrl;
  late TextEditingController _descriptionEnCtrl;
  late TextEditingController _speakerArCtrl;
  late TextEditingController _speakerEnCtrl;
  late TextEditingController _imageUrlCtrl;
  late TextEditingController _audioUrlCtrl;
  late TextEditingController _durationSecondsCtrl;
  bool _isActive = true;
  DateTime? _publishedAt;

  @override
  void initState() {
    super.initState();
    final t = widget.track;
    _categoryId = t?.categoryId;
    _titleArCtrl = TextEditingController(text: t?.titleAr ?? '');
    _titleEnCtrl = TextEditingController(text: t?.titleEn ?? '');
    _subtitleArCtrl = TextEditingController(text: t?.subtitleAr ?? '');
    _subtitleEnCtrl = TextEditingController(text: t?.subtitleEn ?? '');
    _descriptionArCtrl = TextEditingController(text: t?.descriptionAr ?? '');
    _descriptionEnCtrl = TextEditingController(text: t?.descriptionEn ?? '');
    _speakerArCtrl = TextEditingController(text: t?.speakerAr ?? '');
    _speakerEnCtrl = TextEditingController(text: t?.speakerEn ?? '');
    _imageUrlCtrl = TextEditingController(text: t?.imageUrl ?? '');
    _audioUrlCtrl = TextEditingController(text: t?.audioUrl ?? '');
    _durationSecondsCtrl = TextEditingController(
      text: t?.durationSeconds?.toString() ?? '',
    );
    _isActive = t?.isActive ?? true;
    _publishedAt = t?.publishedAt;

    // Trigger categories load if not loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminCategoryProvider);
    });
  }

  @override
  void dispose() {
    _titleArCtrl.dispose();
    _titleEnCtrl.dispose();
    _subtitleArCtrl.dispose();
    _subtitleEnCtrl.dispose();
    _descriptionArCtrl.dispose();
    _descriptionEnCtrl.dispose();
    _speakerArCtrl.dispose();
    _speakerEnCtrl.dispose();
    _imageUrlCtrl.dispose();
    _audioUrlCtrl.dispose();
    _durationSecondsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    if (_categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.adminSelectCategory)));
      return;
    }

    final provider = ref.read(adminTrackProvider);
    final now = DateTime.now();

    final newTrack = Track(
      id: widget.track?.id ?? '',
      categoryId: _categoryId!,
      titleAr: _titleArCtrl.text,
      titleEn: _titleEnCtrl.text,
      subtitleAr: _subtitleArCtrl.text.isEmpty ? null : _subtitleArCtrl.text,
      subtitleEn: _subtitleEnCtrl.text.isEmpty ? null : _subtitleEnCtrl.text,
      descriptionAr: _descriptionArCtrl.text.isEmpty
          ? null
          : _descriptionArCtrl.text,
      descriptionEn: _descriptionEnCtrl.text.isEmpty
          ? null
          : _descriptionEnCtrl.text,
      speakerAr: _speakerArCtrl.text.isEmpty ? null : _speakerArCtrl.text,
      speakerEn: _speakerEnCtrl.text.isEmpty ? null : _speakerEnCtrl.text,
      imageUrl: _imageUrlCtrl.text.isEmpty ? null : _imageUrlCtrl.text,
      audioUrl: _audioUrlCtrl.text,
      durationSeconds: int.tryParse(_durationSecondsCtrl.text),
      publishedAt: _publishedAt ?? now,
      isActive: _isActive,
      createdAt: widget.track?.createdAt ?? now,
      updatedAt: now,
      tags: widget.track?.tags ?? [], // Keep existing tags
    );

    bool success;
    if (widget.track == null) {
      success = await provider.createTrack(newTrack);
    } else {
      success = await provider.updateTrack(newTrack);
    }

    if (success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.track == null
                ? l10n.adminCreated(l10n.adminTrack.toLowerCase())
                : l10n.adminUpdated(l10n.adminTrack.toLowerCase()),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(adminTrackProvider).isLoading;
    final catProvider = ref.watch(adminCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.track == null
              ? l10n.adminNew(l10n.adminTrack)
              : l10n.adminEdit(l10n.adminTrack),
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
                    DropdownButtonFormField<String>(
                      value:
                          catProvider.categories.any((c) => c.id == _categoryId)
                          ? _categoryId
                          : null,
                      decoration: InputDecoration(
                        labelText: l10n.adminCategory,
                        border: const OutlineInputBorder(),
                      ),
                      items: catProvider.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.titleAr),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _categoryId = v),
                      validator: (v) => v == null ? l10n.required : null,
                    ),
                    const SizedBox(height: 16),
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
                      controller: _speakerArCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminSpeakerAr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _speakerEnCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminSpeakerEn,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionArCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminDescriptionAr,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionEnCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminDescriptionEn,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminCoverImageUrl,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _audioUrlCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminAudioUrl,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? l10n.required : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _durationSecondsCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminDuration,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(l10n.adminIsActive),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _submit,
                      child: Text(
                        widget.track == null
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
