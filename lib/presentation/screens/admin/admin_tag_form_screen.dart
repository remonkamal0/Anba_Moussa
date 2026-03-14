import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/tag.dart';
import '../../../../l10n/app_localizations.dart';
import 'admin_tags_screen.dart';

class AdminTagFormScreen extends ConsumerStatefulWidget {
  final Tag? tag;

  const AdminTagFormScreen({super.key, this.tag});

  @override
  ConsumerState<AdminTagFormScreen> createState() => _AdminTagFormScreenState();
}

class _AdminTagFormScreenState extends ConsumerState<AdminTagFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _slugCtrl;
  late TextEditingController _titleArCtrl;
  late TextEditingController _titleEnCtrl;

  @override
  void initState() {
    super.initState();
    final t = widget.tag;
    _slugCtrl = TextEditingController(text: t?.slug ?? '');
    _titleArCtrl = TextEditingController(text: t?.titleAr ?? '');
    _titleEnCtrl = TextEditingController(text: t?.titleEn ?? '');

    _titleEnCtrl.addListener(() {
      if (widget.tag == null && _slugCtrl.text.isEmpty) {
        _slugCtrl.text = _titleEnCtrl.text.toLowerCase().replaceAll(' ', '-');
      }
    });
  }

  @override
  void dispose() {
    _slugCtrl.dispose();
    _titleArCtrl.dispose();
    _titleEnCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = ref.read(adminTagProvider);
    final now = DateTime.now();

    final newTag = Tag(
      id: widget.tag?.id ?? '',
      slug: _slugCtrl.text,
      titleAr: _titleArCtrl.text,
      titleEn: _titleEnCtrl.text,
    );

    bool success;
    if (widget.tag == null) {
      success = await provider.createTag(newTag);
    } else {
      success = await provider.updateTag(newTag);
    }

    if (success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.tag == null
                ? l10n.adminCreated(l10n.adminTag.toLowerCase())
                : l10n.adminUpdated(l10n.adminTag.toLowerCase()),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(adminTagProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tag == null
              ? l10n.adminNew(l10n.adminTag)
              : l10n.adminEdit(l10n.adminTag),
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
                      controller: _slugCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminSlug,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? l10n.required : null,
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
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _submit,
                      child: Text(
                        widget.tag == null
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
