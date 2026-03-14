import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/di/service_locator.dart';
import '../../providers/admin/admin_tag_provider.dart';

final adminTagProvider =
    ChangeNotifierProvider<AdminTagProvider>((ref) {
  return sl.adminTagProvider..loadTags();
});

class AdminTagsScreen extends ConsumerWidget {
  const AdminTagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(adminTagProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminManageTags),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/tags/new'),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text('${l10n.errorOccurred}: ${provider.error}'))
          : ListView.builder(
              itemCount: provider.tags.length,
              itemBuilder: (context, index) {
                final tag = provider.tags[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.label)),
                  title: Text(tag.titleAr),
                  subtitle: Text(tag.titleEn),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.link, color: Colors.green),
                        tooltip: l10n.adminLinkTracks,
                        onPressed: () {
                          context.push('/admin/tags/link', extra: tag);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          context.push('/admin/tags/edit', extra: tag);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.adminConfirmDelete),
                              content: Text(
                                l10n.adminDeleteConfirm(
                                  l10n.adminTag.toLowerCase(),
                                  tag.titleAr,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(l10n.dialogCancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    l10n.delete,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref.read(adminTagProvider).deleteTag(tag.id);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
