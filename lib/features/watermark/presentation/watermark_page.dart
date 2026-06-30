import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/feature_flags.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../../files/application/local_file_repository.dart';
import '../../premium/application/premium_access_service.dart';
import '../../premium/presentation/premium_gate_dialog.dart';
import '../application/watermark_service.dart';
import '../domain/watermark_options.dart';

class WatermarkPage extends StatefulWidget {
  const WatermarkPage({super.key});

  @override
  State<WatermarkPage> createState() => _WatermarkPageState();
}

class _WatermarkPageState extends State<WatermarkPage> {
  final repository = LocalFileRepository();
  final service = WatermarkService();
  final textController = TextEditingController(text: 'ScanLeno');
  final picker = ImagePicker();

  late Future<LocalFileState> future = repository.load();
  StoredDocument? selected;
  WatermarkKind kind = WatermarkKind.text;
  WatermarkPosition position = WatermarkPosition.center;
  WatermarkScope scope = WatermarkScope.allPages;
  File? logoFile;
  double fontSize = 34;
  double opacity = 0.18;
  double rotation = -28;
  bool repeated = false;
  bool saving = false;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 95);
    if (file == null) return;
    setState(() {
      logoFile = File(file.path);
      kind = WatermarkKind.image;
    });
  }

  WatermarkOptions _options() => WatermarkOptions(
    kind: kind,
    text: textController.text,
    fontSize: fontSize,
    color: const Color(0xFF0A2A66),
    opacity: opacity,
    rotationDegrees: rotation,
    position: position,
    repeated: repeated,
    scope: scope,
    imageFile: logoFile,
  );

  Future<void> _save() async {
    final document = selected;
    if (document == null) return;
    final l = context.l10n;
    if (!await _ensurePremiumAccess()) return;
    if (document.type == StoredDocumentType.pdf) {
      _snack(l.watermarkUnsupportedPdf);
      return;
    }
    setState(() => saving = true);
    try {
      await service.saveWatermarkedImageDocument(
        document: document,
        watermark: _options(),
      );
      if (!mounted) return;
      _snack(l.watermarkAddedSuccess);
      setState(() {
        future = repository.load();
      });
    } catch (_) {
      if (mounted) _snack(l.watermarkAddFailed);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _ensurePremiumAccess() async {
    final access = await premiumAccessService.canAccessPremiumFeature(
      PremiumFeature.watermark,
    );
    if (!mounted) return false;
    if (access.allowed) return true;
    await showPremiumGateDialog(
      context,
      feature: PremiumFeature.watermark,
      result: access,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (!FeatureFlags.watermarkEnabled) {
      return AppScreen(
        title: l.watermark,
        showBack: true,
        child: Center(
          child: SoftCard(
            child: Text(
              l.watermarkDisabled,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
        ),
      );
    }
    return AppScreen(
      title: l.watermark,
      showBack: true,
      bottomAction: FilledButton.icon(
        onPressed: saving || selected == null ? null : _save,
        icon: saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(l.saveCopy),
      ),
      child: FutureBuilder<LocalFileState>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final documents = (snapshot.data?.documents ?? const <StoredDocument>[])
              .where((item) =>
                  !item.isDeleted &&
                  (item.type == StoredDocumentType.image ||
                      item.type == StoredDocumentType.pdf))
              .toList();
          if (selected == null) {
            for (final item in documents) {
              if (item.type == StoredDocumentType.image) {
                selected = item;
                break;
              }
            }
          }
          return ListView(
            children: [
              _SectionTitle(l.selectFile),
              const SizedBox(height: AppSpacing.sm),
              if (documents.isEmpty)
                SoftCard(child: Text(l.noFilesYet))
              else
                DropdownButtonFormField<String>(
                  initialValue: selected?.id,
                  items: [
                    for (final document in documents)
                      DropdownMenuItem(
                        value: document.id,
                        child: Text(
                          '${document.name} • ${document.type.name.toUpperCase()}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (id) => setState(
                    () => selected = documents.firstWhere((item) => item.id == id),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              _PreviewCard(
                document: selected,
                options: _options(),
                service: service,
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(l.watermarkType),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<WatermarkKind>(
                segments: [
                  ButtonSegment(value: WatermarkKind.text, label: Text(l.text)),
                  ButtonSegment(value: WatermarkKind.image, label: Text(l.logoImage)),
                ],
                selected: {kind},
                onSelectionChanged: (value) => setState(() => kind = value.first),
              ),
              const SizedBox(height: AppSpacing.md),
              if (kind == WatermarkKind.text)
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: l.watermarkText,
                    prefixIcon: const Icon(Icons.text_fields_rounded),
                  ),
                  onChanged: (_) => setState(() {}),
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickLogo,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(logoFile == null ? l.chooseLogo : l.logoSelected),
                ),
              const SizedBox(height: AppSpacing.md),
              _SliderTile(
                label: l.opacity,
                value: opacity,
                min: 0.05,
                max: 0.7,
                onChanged: (value) => setState(() => opacity = value),
              ),
              _SliderTile(
                label: l.rotation,
                value: rotation,
                min: -60,
                max: 60,
                onChanged: (value) => setState(() => rotation = value),
              ),
              if (kind == WatermarkKind.text)
                _SliderTile(
                  label: l.fontSize,
                  value: fontSize,
                  min: 20,
                  max: 54,
                  onChanged: (value) => setState(() => fontSize = value),
                ),
              const SizedBox(height: AppSpacing.md),
              _SectionTitle(l.position),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final item in WatermarkPosition.values)
                    ChoiceChip(
                      label: Text(_positionLabel(l, item)),
                      selected: position == item,
                      onSelected: (_) => setState(() => position = item),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                value: repeated,
                onChanged: (value) => setState(() => repeated = value),
                title: Text(l.repeatOnPage),
              ),
              SwitchListTile(
                value: scope == WatermarkScope.allPages,
                onChanged: (value) => setState(
                  () => scope = value ? WatermarkScope.allPages : WatermarkScope.currentPage,
                ),
                title: Text(l.applyToAllPages),
              ),
            ],
          );
        },
      ),
    );
  }

  String _positionLabel(ScanLenoLocalizations l, WatermarkPosition value) {
    return switch (value) {
      WatermarkPosition.center => l.center,
      WatermarkPosition.top => l.top,
      WatermarkPosition.bottom => l.bottom,
      WatermarkPosition.right => l.right,
      WatermarkPosition.left => l.left,
    };
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.document,
    required this.options,
    required this.service,
  });

  final StoredDocument? document;
  final WatermarkOptions options;
  final WatermarkService service;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final item = document;
    if (item == null) {
      return SoftCard(child: Text(l.selectFile));
    }
    if (item.type == StoredDocumentType.pdf) {
      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.preview),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.watermarkUnsupportedPdf,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      );
    }
    return FutureBuilder<Uint8List>(
      future: service.applyWatermarkToImageBytes(File(item.path).readAsBytesSync(), options),
      builder: (context, snapshot) {
        return SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.preview),
              const SizedBox(height: AppSpacing.sm),
              AspectRatio(
                aspectRatio: 0.72,
                child: ClipRRect(
                  borderRadius: AppRadii.medium,
                  child: snapshot.hasData
                      ? Image.memory(snapshot.data!, fit: BoxFit.contain)
                      : Image.file(File(item.path), fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          SizedBox(width: 96, child: Text(label)),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}
