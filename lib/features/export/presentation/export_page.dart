import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/feature_flags.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../../ads/application/ad_service.dart';
import '../../premium/application/subscription_service.dart';
import '../../scanner/application/document_draft_controller.dart';
import '../application/document_export_service.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final fileNameController = TextEditingController();
  final picker = ImagePicker();
  final service = DocumentExportService();

  ExportFormat format = ExportFormat.pdf;
  ExportPageSize pageSize = ExportPageSize.a4;
  ExportQuality quality = ExportQuality.high;
  bool passwordEnabled = false;
  bool ocrRequested = false;
  bool saving = false;
  bool initializedName = false;
  List<File> savedFiles = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initializedName) {
      fileNameController.text = context.l10n.appName;
      initializedName = true;
    }
  }

  @override
  void dispose() {
    fileNameController.dispose();
    super.dispose();
  }

  Future<void> _addPages() async {
    final files = await picker.pickMultiImage(imageQuality: 95);
    if (files.isNotEmpty) {
      await subscriptionService.initialize();
      if (!subscriptionService.isPremium &&
          documentDraft.pages.length + files.length >
              FeatureFlags.freeImageToPdfLimit) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.imageToPdfLimitReached)),
          );
        }
        return;
      }
      documentDraft.addPages(files.map((file) => file.path).toList());
    }
  }

  Future<List<File>> _save() async {
    setState(() => saving = true);
    try {
      final files = await service.save(
        pages: documentDraft.pages,
        options: DocumentExportOptions(
          fileName: fileNameController.text,
          format: format,
          pageSize: pageSize,
          quality: quality,
        ),
      );
      await service.registerExportedFiles(
        files: files,
        format: format,
        pageCount: documentDraft.pages.length,
        thumbnailPath: documentDraft.pages.first.path,
      );
      await adService.showInterstitialAfterExport();
      savedFiles = files;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saveSuccess)));
      }
      return files;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saveFailed)));
      }
      return const [];
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _share() async {
    final files = savedFiles.isEmpty ? await _save() : savedFiles;
    if (files.isEmpty) return;
    try {
      await service.share(files);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.shareFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final showPasswordProtection = FeatureFlags.protectPdfEnabled;
    return AnimatedBuilder(
      animation: documentDraft,
      builder: (context, _) {
        if (!documentDraft.hasPages) {
          return AppScreen(
            title: l.saveAndExport,
            showBack: true,
            child: Center(
              child: FilledButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.scanner),
                child: Text(l.openScanner),
              ),
            ),
          );
        }

        return AppScreen(
          title: l.saveAndExport,
          showBack: true,
          bottomAction: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: saving ? null : _share,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(l.share),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: saving ? null : _save,
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(l.saveDocument),
                ),
              ),
            ],
          ),
          child: ListView(
            children: [
              Text(
                l.previewDocument,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PageStrip(onAddPages: _addPages),
              const SizedBox(height: AppSpacing.lg),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.documentName),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: fileNameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.edit_outlined),
                        hintText: l.documentName,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.description_outlined,
                            title: l.pageCount,
                            value:
                                '${documentDraft.pages.length} ${l.pagesUnit}',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.calendar_month_outlined,
                            title: l.createdAt,
                            value: MaterialLocalizations.of(
                              context,
                            ).formatShortDate(DateTime.now()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l.fileFormat,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _FormatCard(
                      selected: format == ExportFormat.pdf,
                      icon: Icons.picture_as_pdf_rounded,
                      title: l.pdfDocument,
                      subtitle: l.saveToFiles,
                      onTap: () => setState(() => format = ExportFormat.pdf),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _FormatCard(
                      selected: format == ExportFormat.jpg,
                      icon: Icons.image_rounded,
                      title: l.jpg,
                      subtitle: l.imageFormat,
                      onTap: () => setState(() => format = ExportFormat.jpg),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SoftCard(
                child: Column(
                  children: [
                    _DropdownRow<ExportPageSize>(
                      label: l.pageSize,
                      icon: Icons.insert_drive_file_outlined,
                      value: pageSize,
                      items: {
                        ExportPageSize.a4: l.a4,
                        ExportPageSize.letter: l.letter,
                        ExportPageSize.legal: l.legal,
                        ExportPageSize.original: l.originalSize,
                      },
                      onChanged: (value) => setState(() => pageSize = value),
                    ),
                    const Divider(),
                    _DropdownRow<ExportQuality>(
                      label: l.quality,
                      icon: Icons.hd_outlined,
                      value: quality,
                      items: {
                        ExportQuality.low: l.low,
                        ExportQuality.medium: l.medium,
                        ExportQuality.high: l.high,
                      },
                      onChanged: (value) => setState(() => quality = value),
                    ),
                    if (showPasswordProtection) ...[
                      const Divider(),
                      _SwitchRow(
                        label: l.passwordProtection,
                        icon: Icons.lock_outline,
                        value: passwordEnabled,
                        enabled: false,
                        subtitle: '',
                        onChanged: (value) =>
                            setState(() => passwordEnabled = value),
                      ),
                    ],
                    const Divider(),
                    _SwitchRow(
                      label: l.ocrExtraction,
                      icon: Icons.document_scanner_outlined,
                      value: FeatureFlags.ocrEnabled && ocrRequested,
                      enabled: FeatureFlags.ocrEnabled,
                      subtitle: FeatureFlags.ocrAsPremium
                          ? l.premiumFeature
                          : l.ocrComingSoon,
                      onChanged: (value) => setState(() => ocrRequested = value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PageStrip extends StatelessWidget {
  const _PageStrip({required this.onAddPages});

  final VoidCallback onAddPages;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SizedBox(
      height: 142,
      child: Row(
        children: [
          _AddPageTile(onTap: onAddPages),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              itemCount: documentDraft.pages.length,
              onReorder: documentDraft.reorder,
              itemBuilder: (context, index) {
                final page = documentDraft.pages[index];
                return Padding(
                  key: ValueKey(page.path),
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                  child: SizedBox(
                    width: 92,
                    child: ReorderableDragStartListener(
                      index: index,
                      child: _PageThumbnail(
                        imagePath: page.path,
                        index: index,
                        deleteLabel: l.deletePage,
                        onDelete: documentDraft.pages.length == 1
                            ? null
                            : () => documentDraft.removePage(index),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPageTile extends StatelessWidget {
  const _AddPageTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.medium,
      child: Container(
        width: 104,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline, style: BorderStyle.solid),
          borderRadius: AppRadii.medium,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: AppColors.interactive),
            const SizedBox(height: AppSpacing.xs),
            Text(context.l10n.addPages, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PageThumbnail extends StatelessWidget {
  const _PageThumbnail({
    required this.imagePath,
    required this.index,
    required this.deleteLabel,
    required this.onDelete,
  });

  final String imagePath;
  final int index;
  final String deleteLabel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: index == 0 ? AppColors.interactive : AppColors.outline,
              width: index == 0 ? 2 : 1,
            ),
            borderRadius: AppRadii.medium,
            boxShadow: AppShadows.card,
          ),
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadii.small,
                  child: Image.file(
                    File(imagePath),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.interactive,
                foregroundColor: Colors.white,
                child: Text('${index + 1}'),
              ),
            ],
          ),
        ),
        PositionedDirectional(
          top: 0,
          end: 0,
          child: IconButton(
            tooltip: deleteLabel,
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ),
      ],
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.medium,
      child: SoftCard(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.interactive : Colors.transparent,
              width: 2,
            ),
            borderRadius: AppRadii.medium,
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.interactive, size: 42),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.muted),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.muted)),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.muted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(label)),
        DropdownButton<T>(
          value: value,
          underline: const SizedBox.shrink(),
          items: [
            for (final entry in items.entries)
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.enabled,
    required this.subtitle,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final bool enabled;
  final String subtitle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.muted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: enabled ? onChanged : null),
      ],
    );
  }
}
