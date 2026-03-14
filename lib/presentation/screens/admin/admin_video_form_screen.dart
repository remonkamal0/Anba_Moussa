import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/video.dart';
import '../../../../l10n/app_localizations.dart';
import 'admin_videos_screen.dart';

class AdminVideoFormScreen extends ConsumerStatefulWidget {
  final Video? video;
  final String albumId;

  const AdminVideoFormScreen({super.key, this.video, required this.albumId});

  @override
  ConsumerState<AdminVideoFormScreen> createState() =>
      _AdminVideoFormScreenState();
}

class _AdminVideoFormScreenState extends ConsumerState<AdminVideoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleArCtrl;
  late TextEditingController _titleEnCtrl;
  late TextEditingController _subtitleArCtrl;
  late TextEditingController _subtitleEnCtrl;
  late TextEditingController _descriptionArCtrl;
  late TextEditingController _descriptionEnCtrl;
  late TextEditingController _videoUrlCtrl;
  late TextEditingController _coverUrlCtrl;
  late TextEditingController _durationSecondsCtrl;
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    final v = widget.video;
    _titleArCtrl = TextEditingController(text: v?.titleAr ?? '');
    _titleEnCtrl = TextEditingController(text: v?.titleEn ?? '');
    _subtitleArCtrl = TextEditingController(text: v?.subtitleAr ?? '');
    _subtitleEnCtrl = TextEditingController(text: v?.subtitleEn ?? '');
    _descriptionArCtrl = TextEditingController(text: v?.descriptionAr ?? '');
    _descriptionEnCtrl = TextEditingController(text: v?.descriptionEn ?? '');
    _videoUrlCtrl = TextEditingController(text: v?.videoUrl ?? '');
    _coverUrlCtrl = TextEditingController(text: v?.thumbnailUrl ?? '');
    _durationSecondsCtrl = TextEditingController(
      text: v?.durationSeconds?.toString() ?? '',
    );
    _createdAt = v?.createdAt;
  }

  @override
  void dispose() {
    _titleArCtrl.dispose();
    _titleEnCtrl.dispose();
    _subtitleArCtrl.dispose();
    _subtitleEnCtrl.dispose();
    _descriptionArCtrl.dispose();
    _descriptionEnCtrl.dispose();
    _videoUrlCtrl.dispose();
    _coverUrlCtrl.dispose();
    _durationSecondsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = ref.read(adminVideoProvider);
    final now = DateTime.now();

    final newVideo = Video(
      id: widget.video?.id ?? '',
      albumId: widget.albumId,
      titleAr: _titleArCtrl.text,
      titleEn: _titleEnCtrl.text,
      subtitleAr: _subtitleArCtrl.text.isEmpty ? null : _subtitleArCtrl.text,
      subtitleEn: _subtitleEnCtrl.text.isEmpty ? null : _subtitleEnCtrl.text,
      descriptionAr:
          _descriptionArCtrl.text.isEmpty ? null : _descriptionArCtrl.text,
      descriptionEn:
          _descriptionEnCtrl.text.isEmpty ? null : _descriptionEnCtrl.text,
      videoUrl: _videoUrlCtrl.text,
      thumbnailUrl: _coverUrlCtrl.text.isEmpty ? null : _coverUrlCtrl.text,
      durationSeconds: int.tryParse(_durationSecondsCtrl.text),
      sortOrder: widget.video?.sortOrder ?? 0,
      isActive: widget.video?.isActive ?? true,
      createdAt: _createdAt ?? now,
      updatedAt: now,
    );

    bool success;
    if (widget.video == null) {
      success = await provider.createVideo(newVideo);
    } else {
      success = await provider.updateVideo(newVideo);
    }

    if (success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.video == null
                ? l10n.adminCreated(l10n.adminVideo.toLowerCase())
                : l10n.adminUpdated(l10n.adminVideo.toLowerCase()),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(adminVideoProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.video == null
              ? l10n.adminNew(l10n.adminVideo)
              : l10n.adminEdit(l10n.adminVideo),
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
                      controller: _videoUrlCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminVideoUrl,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? l10n.required : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _coverUrlCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminCoverImageUrl,
                        border: const OutlineInputBorder(),
                      ),
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
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _submit,
                      child: Text(
                        widget.video == null
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
