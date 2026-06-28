import 'package:flutter/material.dart';

import '../../../app/app_shell.dart';
import '../../../core/constants/feature_flags.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../../ads/application/ad_service.dart';
import '../../ads/presentation/ad_banner_slot.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final showPasswordProtection = FeatureFlags.protectPdfEnabled;
    final tools = [
      _Tool(Icons.merge_type_rounded, l.mergePdf, AppRoutes.export, FeatureFlags.mergePdfEnabled),
      _Tool(Icons.call_split_rounded, l.splitPdf, null, FeatureFlags.splitPdfEnabled),
      _Tool(Icons.compress_rounded, l.compressPdf, null, FeatureFlags.compressPdfEnabled),
      _Tool(Icons.draw_outlined, l.signPdf, AppRoutes.signature, true),
      _Tool(Icons.image_outlined, l.imagesToPdf, AppRoutes.scanner, true),
      if (showPasswordProtection)
        _Tool(Icons.lock_outline, l.protectPdf, null, FeatureFlags.protectPdfEnabled),
      _Tool(Icons.delete_outline, l.removePages, null, FeatureFlags.editPdfPagesEnabled),
      _Tool(Icons.reorder_rounded, l.reorderPages, AppRoutes.export, true),
      _Tool(Icons.rotate_90_degrees_cw_rounded, l.rotatePdfPages, null, FeatureFlags.editPdfPagesEnabled),
      _Tool(Icons.collections_outlined, l.pdfToImages, null, FeatureFlags.pdfToImagesEnabled),
      _Tool(Icons.photo_library_outlined, l.multipleImagesToPdf, AppRoutes.scanner, true),
      _Tool(Icons.text_fields_rounded, l.addTextToPdf, null, FeatureFlags.pdfTextEditingEnabled),
      _Tool(Icons.opacity_rounded, l.addWatermark, null, FeatureFlags.pdfTextEditingEnabled),
      _Tool(Icons.print_outlined, l.printDocument, null, false),
      _Tool(Icons.text_snippet_outlined, l.extractText, AppRoutes.ocr, true),
      _Tool(Icons.search_rounded, l.searchDocuments, AppRoutes.files, true),
      if (showPasswordProtection)
        _Tool(Icons.enhanced_encryption_outlined, l.lockDocument, null, FeatureFlags.protectPdfEnabled),
      _Tool(Icons.copy_rounded, l.duplicateDocument, AppRoutes.files, true),
      _Tool(Icons.create_new_folder_outlined, l.newFolder, AppRoutes.files, true),
      _Tool(Icons.folder_outlined, l.manageFiles, AppRoutes.files, true),
    ];

    return AppShell(
      currentIndex: 2,
      child: AppScreen(
        title: l.tools,
        child: ListView(
          children: [
            Text(
              l.smartAssistant,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(l.smartAssistantDescription, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                borderRadius: AppRadii.large,
                gradient: LinearGradient(colors: [Color(0xFF174C93), Color(0xFF061E55)]),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 54),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.smartAssistant, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(l.smartAssistantDescription, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const AdBannerSlot(placement: AdPlacement.tools),
            const SizedBox(height: AppSpacing.lg),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.12,
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return ToolTile(
                  icon: tool.icon,
                  label: tool.label,
                  onTap: () => _openTool(context, tool),
                  accent: tool.enabled
                      ? (index.isEven ? AppColors.softBlue : AppColors.softTurquoise)
                      : AppColors.background,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openTool(BuildContext context, _Tool tool) {
    if (!tool.enabled || tool.route == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.toolUnavailable)));
      return;
    }
    Navigator.of(context).pushNamed(tool.route!);
  }
}

class _Tool {
  const _Tool(this.icon, this.label, this.route, this.enabled);

  final IconData icon;
  final String label;
  final String? route;
  final bool enabled;
}
