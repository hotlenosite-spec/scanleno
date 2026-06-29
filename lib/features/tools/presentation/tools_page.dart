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
import '../../premium/presentation/premium_gate_dialog.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final showPasswordProtection = FeatureFlags.protectPdfEnabled;
    final tools = [
      _Tool(Icons.merge_type_rounded, l.mergePdf, AppRoutes.export, PremiumFeature.mergePdf),
      _Tool(Icons.call_split_rounded, l.splitPdf, null, PremiumFeature.splitPdf),
      _Tool(Icons.compress_rounded, l.compressPdf, null, PremiumFeature.compressPdf),
      _Tool.free(Icons.draw_outlined, l.signPdf, AppRoutes.signature),
      _Tool.free(Icons.image_outlined, l.imagesToPdf, AppRoutes.scanner),
      if (showPasswordProtection)
        _Tool(Icons.lock_outline, l.protectPdf, null, PremiumFeature.protectPdf),
      _Tool(Icons.delete_outline, l.removePages, null, PremiumFeature.editPdfPages),
      _Tool.free(Icons.reorder_rounded, l.reorderPages, AppRoutes.export),
      _Tool(Icons.rotate_90_degrees_cw_rounded, l.rotatePdfPages, null, PremiumFeature.editPdfPages),
      _Tool(Icons.collections_outlined, l.pdfToImages, null, PremiumFeature.pdfToImages),
      _Tool(Icons.table_chart_outlined, l.pdfToExcel, AppRoutes.pdfToExcel, PremiumFeature.pdfToExcel),
      _Tool(Icons.description_outlined, l.pdfToWord, AppRoutes.pdfToWord, PremiumFeature.pdfToWord),
      _Tool.free(Icons.photo_library_outlined, l.multipleImagesToPdf, AppRoutes.scanner),
      _Tool(Icons.text_fields_rounded, l.addTextToPdf, null, PremiumFeature.pdfTextEditing),
      _Tool.free(Icons.opacity_rounded, l.addWatermark, AppRoutes.watermark),
      _Tool(Icons.translate_rounded, l.aiTranslate, AppRoutes.translate, PremiumFeature.translate),
      _Tool(Icons.auto_awesome_rounded, l.aiSummary, AppRoutes.aiSummary, PremiumFeature.aiSummary),
      _Tool.unavailable(Icons.print_outlined, l.printDocument),
      _Tool(Icons.text_snippet_outlined, l.extractText, AppRoutes.ocr, PremiumFeature.ocr),
      _Tool.free(Icons.search_rounded, l.searchDocuments, AppRoutes.files),
      if (showPasswordProtection)
        _Tool(Icons.enhanced_encryption_outlined, l.lockDocument, null, PremiumFeature.protectPdf),
      _Tool.free(Icons.copy_rounded, l.duplicateDocument, AppRoutes.files),
      _Tool.free(Icons.create_new_folder_outlined, l.newFolder, AppRoutes.files),
      _Tool.free(Icons.folder_outlined, l.manageFiles, AppRoutes.files),
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
                return _ToolCard(
                  icon: tool.icon,
                  label: tool.label,
                  premium: tool.feature != null,
                  unavailable: tool.unavailable,
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

  Future<void> _openTool(BuildContext context, _Tool tool) async {
    if (tool.unavailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.toolUnavailable)));
      return;
    }
    if (tool.route == AppRoutes.watermark && !FeatureFlags.watermarkEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.watermarkDisabled)));
      return;
    }
    if (tool.route == AppRoutes.translate && !FeatureFlags.translateEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.translateDisabled)));
      return;
    }
    if (tool.route == AppRoutes.aiSummary && !FeatureFlags.aiSummaryEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.aiSummaryDisabled)));
      return;
    }
    if (tool.route == AppRoutes.pdfToExcel && !FeatureFlags.pdfToExcelEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.pdfToExcelDisabled)));
      return;
    }
    if (tool.route == AppRoutes.pdfToWord && !FeatureFlags.pdfToWordEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.pdfToWordDisabled)));
      return;
    }
    final feature = tool.feature;
    if (feature != null) {
      final access = await premiumAccessService.canAccessPremiumFeature(feature);
      if (!context.mounted) return;
      if (!access.allowed) {
        await showPremiumGateDialog(
          context,
          feature: feature,
          result: access,
        );
        return;
      }
    }
    if (tool.route == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.toolUnavailable)));
      return;
    }
    Navigator.of(context).pushNamed(tool.route!);
  }
}

class _Tool {
  const _Tool(this.icon, this.label, this.route, this.feature)
    : enabled = true,
      unavailable = false;

  const _Tool.free(this.icon, this.label, this.route)
    : feature = null,
      enabled = true,
      unavailable = false;

  const _Tool.unavailable(this.icon, this.label)
    : route = null,
      feature = null,
      enabled = false,
      unavailable = true;

  final IconData icon;
  final String label;
  final String? route;
  final PremiumFeature? feature;
  final bool enabled;
  final bool unavailable;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accent,
    required this.premium,
    required this.unavailable,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accent;
  final bool premium;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.medium,
      child: SoftCard(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(color: accent, borderRadius: AppRadii.small),
                  child: Icon(
                    unavailable ? Icons.lock_clock_outlined : icon,
                    color: unavailable ? AppColors.muted : AppColors.interactive,
                  ),
                ),
                const Spacer(),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: unavailable ? AppColors.muted : null,
                  ),
                ),
              ],
            ),
            if (premium)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadii.pill,
                  ),
                  child: Text(
                    l.premium,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
