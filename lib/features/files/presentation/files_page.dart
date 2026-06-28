import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/app_shell.dart';
import '../../../core/constants/feature_flags.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../../ads/application/ad_service.dart';
import '../../ads/presentation/ad_banner_slot.dart';
import '../../premium/application/premium_access_service.dart';
import '../../premium/application/subscription_service.dart';
import '../../premium/presentation/premium_gate_dialog.dart';
import '../application/local_file_repository.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  final repository = LocalFileRepository();
  final searchController = TextEditingController();
  FileFilterMode filter = FileFilterMode.all;
  FileSortMode sort = FileSortMode.newest;
  late Future<LocalFileState> future = repository.load();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => future = repository.load());

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppShell(
      currentIndex: 1,
      child: AppScreen(
        title: l.myFiles,
        trailing: IconButton(
          onPressed: () => _createFolder(context),
          icon: const Icon(Icons.create_new_folder_outlined),
        ),
        child: FutureBuilder<LocalFileState>(
          future: future,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final documents = _filteredDocuments(state.documents);
            return ListView(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: l.searchFiles,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const AdBannerSlot(placement: AdPlacement.files),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(child: _FilterChips(filter: filter, onChanged: (value) => setState(() => filter = value))),
                    PopupMenuButton<FileSortMode>(
                      initialValue: sort,
                      onSelected: (value) => setState(() => sort = value),
                      icon: const Icon(Icons.tune_rounded),
                      itemBuilder: (context) => [
                        PopupMenuItem(value: FileSortMode.newest, child: Text(l.recent)),
                        PopupMenuItem(value: FileSortMode.oldest, child: Text(l.oldest)),
                        PopupMenuItem(value: FileSortMode.name, child: Text(l.sortByName)),
                        PopupMenuItem(value: FileSortMode.size, child: Text(l.sortBySize)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(title: l.folders),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 138,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.folders.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      if (index == state.folders.length) {
                        return _FolderTile(
                          title: l.newFolder,
                          count: 0,
                          dashed: true,
                          onTap: () => _createFolder(context),
                        );
                      }
                      final folder = state.folders[index];
                      final count = state.documents.where((document) => document.folderId == folder.id && !document.isDeleted).length;
                      return _FolderTile(
                        title: _folderTitle(context, folder),
                        count: count,
                        onTap: () {},
                        onLongPress: folder.isSystem ? null : () => _folderActions(context, folder),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(title: filter == FileFilterMode.trash ? l.trash : l.files),
                const SizedBox(height: AppSpacing.sm),
                if (documents.isEmpty)
                  _EmptyState(
                    title: filter == FileFilterMode.trash ? l.noTrashItems : l.noDocumentsYet,
                    subtitle: l.noDocumentsDescription,
                  )
                else
                  for (final document in documents)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _DocumentCard(
                        document: document,
                        typeLabel: _typeLabel(context, document),
                        dateLabel: MaterialLocalizations.of(context).formatShortDate(document.updatedAt),
                        sizeLabel: _formatSize(document.sizeBytes),
                        onTap: () => _openDocument(document),
                        onMore: () => _documentActions(context, document, state.folders),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<StoredDocument> _filteredDocuments(List<StoredDocument> documents) {
    final query = searchController.text.trim().toLowerCase();
    final visible = documents.where((document) {
      if (filter == FileFilterMode.trash) {
        if (!document.isDeleted) return false;
      } else if (document.isDeleted) {
        return false;
      }
      if (query.isNotEmpty && !document.name.toLowerCase().contains(query)) {
        return false;
      }
      return switch (filter) {
        FileFilterMode.all || FileFilterMode.trash => true,
        FileFilterMode.pdf => document.type == StoredDocumentType.pdf,
        FileFilterMode.images => document.type == StoredDocumentType.image,
        FileFilterMode.favorites => document.isFavorite,
      };
    }).toList();
    visible.sort((a, b) {
      return switch (sort) {
        FileSortMode.newest => b.updatedAt.compareTo(a.updatedAt),
        FileSortMode.oldest => a.updatedAt.compareTo(b.updatedAt),
        FileSortMode.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        FileSortMode.size => b.sizeBytes.compareTo(a.sizeBytes),
      };
    });
    return visible;
  }

  Future<void> _createFolder(BuildContext context) async {
    await subscriptionService.initialize();
    final currentState = await repository.load();
    final customFolderCount = currentState.folders
        .where((folder) => !folder.isSystem)
        .length;
    if (!context.mounted) return;
    if (!subscriptionService.isPremium &&
        customFolderCount >= FeatureFlags.freeFolderLimit) {
      final access = await premiumAccessService.canAccessPremiumFeature(
        PremiumFeature.unlimitedFolders,
      );
      if (!context.mounted) return;
      await showPremiumGateDialog(
        context,
        feature: PremiumFeature.unlimitedFolders,
        result: access,
      );
      return;
    }
    final name = await _textDialog(context, title: context.l10n.newFolder, label: context.l10n.folderName);
    if (name == null || name.trim().isEmpty) return;
    await repository.createFolder(name.trim());
    _refresh();
  }

  Future<void> _folderActions(BuildContext context, LocalFolder folder) async {
    final l = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: Text(l.renameFolder),
              onTap: () async {
                Navigator.pop(context);
                final name = await _textDialog(context, title: l.renameFolder, label: l.folderName, initialValue: _folderTitle(context, folder));
                if (name == null || name.trim().isEmpty) return;
                await repository.renameFolder(folder.id, name.trim());
                _refresh();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(l.deleteFolder),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _confirm(context, l.deleteFolder, l.deleteFolderWarning);
                if (!confirmed) return;
                await repository.deleteFolder(folder.id);
                _refresh();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _documentActions(
    BuildContext context,
    StoredDocument document,
    List<LocalFolder> folders,
  ) async {
    final l = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.open_in_new_rounded), title: Text(l.open), onTap: () { Navigator.pop(context); _openDocument(document); }),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: Text(l.rename),
              onTap: () async {
                Navigator.pop(context);
                final name = await _textDialog(context, title: l.rename, label: l.fileName, initialValue: document.name);
                if (name == null || name.trim().isEmpty) return;
                await repository.renameDocument(document.id, name.trim());
                _refresh();
              },
            ),
            ListTile(leading: const Icon(Icons.ios_share_rounded), title: Text(l.share), onTap: () { Navigator.pop(context); repository.shareDocument(document); }),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(l.moveToFolder),
              onTap: () {
                Navigator.pop(context);
                _moveToFolder(context, document, folders);
              },
            ),
            ListTile(
              leading: Icon(document.isFavorite ? Icons.star_rounded : Icons.star_border_rounded),
              title: Text(document.isFavorite ? l.removeFromFavorites : l.addToFavorites),
              onTap: () async {
                Navigator.pop(context);
                await repository.toggleFavorite(document.id);
                _refresh();
              },
            ),
            if (document.isDeleted)
              ListTile(
                leading: const Icon(Icons.restore_rounded),
                title: Text(l.restore),
                onTap: () async {
                  Navigator.pop(context);
                  await repository.restoreFromTrash(document.id);
                  _refresh();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(document.isDeleted ? l.deleteForever : l.delete),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _confirm(context, document.isDeleted ? l.deleteForever : l.delete, document.isDeleted ? l.deleteForeverWarning : l.deleteFileWarning);
                if (!confirmed) return;
                if (document.isDeleted) {
                  await repository.permanentlyDelete(document.id);
                } else {
                  await repository.moveToTrash(document.id);
                }
                _refresh();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _moveToFolder(
    BuildContext context,
    StoredDocument document,
    List<LocalFolder> folders,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final folder in folders)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(_folderTitle(context, folder)),
                onTap: () async {
                  Navigator.pop(context);
                  await repository.moveDocument(document.id, folder.id);
                  _refresh();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _openDocument(StoredDocument document) {
    if (document.type == StoredDocumentType.image) {
      Navigator.of(context).pushNamed(AppRoutes.signature);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.toolUnavailable)),
    );
  }

  String _folderTitle(BuildContext context, LocalFolder folder) {
    final l = context.l10n;
    return switch (folder.nameKey) {
      'folderContracts' => l.folderContracts,
      'folderInvoices' => l.folderInvoices,
      'folderIdentity' => l.folderIdentity,
      _ => folder.nameKey,
    };
  }

  String _typeLabel(BuildContext context, StoredDocument document) {
    final l = context.l10n;
    return switch (document.type) {
      StoredDocumentType.pdf => l.pdfDocument,
      StoredDocumentType.image => l.imageFormat,
      StoredDocumentType.text => l.exportText,
    };
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<String?> _textDialog(
    BuildContext context, {
    required String title,
    required String label,
    String? initialValue,
  }) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: label), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: Text(context.l10n.confirm)),
        ],
      ),
    );
  }

  Future<bool> _confirm(BuildContext context, String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.confirm)),
        ],
      ),
    ) ?? false;
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filter, required this.onChanged});

  final FileFilterMode filter;
  final ValueChanged<FileFilterMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final values = {
      FileFilterMode.all: l.allFiles,
      FileFilterMode.pdf: l.pdfFiles,
      FileFilterMode.images: l.imageFiles,
      FileFilterMode.favorites: l.favorites,
      FileFilterMode.trash: l.trash,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final entry in values.entries)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: filter == entry.key,
                onSelected: (_) => onChanged(entry.key),
              ),
            ),
        ],
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.title,
    required this.count,
    required this.onTap,
    this.onLongPress,
    this.dashed = false,
  });

  final String title;
  final int count;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: AppRadii.medium,
      child: Container(
        width: 122,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.medium,
          border: Border.all(color: dashed ? AppColors.outline : Colors.transparent),
          boxShadow: dashed ? null : AppShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(dashed ? Icons.add_rounded : Icons.folder_rounded, color: AppColors.interactive, size: 42),
            const SizedBox(height: AppSpacing.sm),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            if (!dashed) Text('$count', style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.document,
    required this.typeLabel,
    required this.dateLabel,
    required this.sizeLabel,
    required this.onTap,
    required this.onMore,
  });

  final StoredDocument document;
  final String typeLabel;
  final String dateLabel;
  final String sizeLabel;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: _Thumbnail(document: document),
        title: Text(document.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('$dateLabel • $typeLabel • ${document.pageCount} ${context.l10n.pagesUnit} • $sizeLabel'),
        trailing: IconButton(onPressed: onMore, icon: const Icon(Icons.more_vert_rounded)),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.document});

  final StoredDocument document;

  @override
  Widget build(BuildContext context) {
    final thumbnail = document.thumbnailPath == null ? null : File(document.thumbnailPath!);
    if (thumbnail != null && thumbnail.existsSync()) {
      return ClipRRect(
        borderRadius: AppRadii.small,
        child: Image.file(thumbnail, width: 54, height: 54, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(color: AppColors.softBlue, borderRadius: AppRadii.small),
      child: Icon(
        document.type == StoredDocumentType.pdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
        color: AppColors.interactive,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          const Icon(Icons.folder_open_outlined, color: AppColors.muted, size: 56),
          const SizedBox(height: AppSpacing.sm),
          Text(title),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}
