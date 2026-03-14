import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/category.dart';
import '../../../../l10n/app_localizations.dart';
import 'admin_categories_screen.dart';

class AdminCategoryFormScreen extends ConsumerStatefulWidget {
  final Category? category; // If null, it's create mode

  const AdminCategoryFormScreen({super.key, this.category});

  @override
  ConsumerState<AdminCategoryFormScreen> createState() =>
      _AdminCategoryFormScreenState();
}

class _AdminCategoryFormScreenState
    extends ConsumerState<AdminCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _slugCtrl;
  late TextEditingController _titleArCtrl;
  late TextEditingController _titleEnCtrl;
  late TextEditingController _subtitleArCtrl;
  late TextEditingController _subtitleEnCtrl;
  late TextEditingController _imageUrlCtrl;
  late TextEditingController _sortOrderCtrl;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _slugCtrl = TextEditingController(text: c?.slug ?? '');
    _titleArCtrl = TextEditingController(text: c?.titleAr ?? '');
    _titleEnCtrl = TextEditingController(text: c?.titleEn ?? '');
    _subtitleArCtrl = TextEditingController(text: c?.subtitleAr ?? '');
    _subtitleEnCtrl = TextEditingController(text: c?.subtitleEn ?? '');
    _imageUrlCtrl = TextEditingController(text: c?.imageUrl ?? '');
    _sortOrderCtrl = TextEditingController(
      text: c?.sortOrder.toString() ?? '0',
    );
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _slugCtrl.dispose();
    _titleArCtrl.dispose();
    _titleEnCtrl.dispose();
    _subtitleArCtrl.dispose();
    _subtitleEnCtrl.dispose();
    _imageUrlCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = ref.read(adminCategoryProvider);
    final now = DateTime.now();

    final newCat = Category(
      id:
          widget.category?.id ??
          '', // handled by DB if empty, but we might need to send a dummy if repo expects String
      slug: _slugCtrl.text,
      titleAr: _titleArCtrl.text,
      titleEn: _titleEnCtrl.text,
      subtitleAr: _subtitleArCtrl.text.isEmpty ? null : _subtitleArCtrl.text,
      subtitleEn: _subtitleEnCtrl.text.isEmpty ? null : _subtitleEnCtrl.text,
      imageUrl: _imageUrlCtrl.text.isEmpty ? null : _imageUrlCtrl.text,
      sortOrder: int.tryParse(_sortOrderCtrl.text) ?? 0,
      isActive: _isActive,
      createdAt: widget.category?.createdAt ?? now,
      updatedAt: now,
    );

    bool success;
    if (widget.category == null) {
      success = await provider.createCategory(newCat);
    } else {
      success = await provider.updateCategory(newCat);
    }

    if (success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.category == null
                ? l10n.adminCreated(l10n.adminCategory.toLowerCase())
                : l10n.adminUpdated(l10n.adminCategory.toLowerCase()),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(adminCategoryProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null
              ? l10n.adminNew(l10n.adminCategory)
              : l10n.adminEdit(l10n.adminCategory),
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
                      controller: _imageUrlCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminImageUrl,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sortOrderCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.adminSortOrder,
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
                        widget.category == null
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
