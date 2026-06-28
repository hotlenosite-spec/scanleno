import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../../scanner/application/document_draft_controller.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AnimatedBuilder(
      animation: documentDraft,
      builder: (context, _) {
        if (!documentDraft.hasPages) {
          return AppScreen(
            title: l.enhanceDocument,
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

        final page = documentDraft.currentPage;
        final filters = <(DocumentFilter, String)>[
          (DocumentFilter.original, l.original),
          (DocumentFilter.enhanced, l.enhancedFilter),
          (DocumentFilter.monochrome, l.blackAndWhite),
          (DocumentFilter.grayscale, l.gray),
          (DocumentFilter.color, l.colored),
        ];

        return AppScreen(
          title: l.enhanceDocument,
          showBack: true,
          bottomAction: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: documentDraft.resetCurrent,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l.reset),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.export,
                  ),
                  child: Text(l.saveChanges),
                ),
              ),
            ],
          ),
          child: ListView(
            children: [
              AspectRatio(
                aspectRatio: .78,
                child: SoftCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ClipRRect(
                    borderRadius: AppRadii.medium,
                    child: _FilteredPreview(page: page),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 114,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final filter = filters[index];
                    final selected = page.filter == filter.$1;
                    return _FilterTile(
                      label: filter.$2,
                      selected: selected,
                      imagePath: page.path,
                      onTap: () => documentDraft.updateCurrent(
                        filter: filter.$1,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SliderCard(
                label: l.brightness,
                value: page.brightness,
                icon: Icons.wb_sunny_outlined,
                onChanged: (value) =>
                    documentDraft.updateCurrent(brightness: value),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SliderCard(
                label: l.contrast,
                value: page.contrast,
                icon: Icons.contrast_rounded,
                onChanged: (value) =>
                    documentDraft.updateCurrent(contrast: value),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilteredPreview extends StatelessWidget {
  const _FilteredPreview({required this.page});

  final DraftPage page;

  @override
  Widget build(BuildContext context) {
    final image = Image.file(File(page.path), fit: BoxFit.contain);
    return ColorFiltered(
      colorFilter: switch (page.filter) {
        DocumentFilter.original => const ColorFilter.mode(
          Colors.transparent,
          BlendMode.dst,
        ),
        DocumentFilter.enhanced => const ColorFilter.matrix([
          1.14,
          0,
          0,
          0,
          4,
          0,
          1.14,
          0,
          0,
          4,
          0,
          0,
          1.14,
          0,
          4,
          0,
          0,
          0,
          1,
          0,
        ]),
        DocumentFilter.monochrome || DocumentFilter.grayscale =>
          const ColorFilter.matrix([
            .2126,
            .7152,
            .0722,
            0,
            0,
            .2126,
            .7152,
            .0722,
            0,
            0,
            .2126,
            .7152,
            .0722,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
        DocumentFilter.color => const ColorFilter.matrix([
          1.12,
          0,
          0,
          0,
          0,
          0,
          1.08,
          0,
          0,
          0,
          0,
          0,
          1.08,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
      },
      child: image,
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.label,
    required this.selected,
    required this.imagePath,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.medium,
      child: Container(
        width: 96,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.medium,
          border: Border.all(
            color: selected ? AppColors.interactive : AppColors.outline,
            width: selected ? 2 : 1,
          ),
          boxShadow: AppShadows.card,
        ),
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
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final double value;
  final IconData icon;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          SizedBox(width: 82, child: Text(label)),
          Expanded(
            child: Slider(
              value: value,
              min: -.45,
              max: .45,
              onChanged: onChanged,
            ),
          ),
          Icon(icon, color: AppColors.primary),
        ],
      ),
    );
  }
}
