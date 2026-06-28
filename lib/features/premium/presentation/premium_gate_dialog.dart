import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../application/premium_access_service.dart';

Future<void> showPremiumGateDialog(
  BuildContext context, {
  required PremiumFeature feature,
  required PremiumAccessResult result,
  Future<void> Function()? onEarnScanCredit,
}) {
  final l = context.l10n;
  final message = _messageForResult(l, result);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.softBlue,
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.interactive,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    result.reason == PremiumAccessReason.featureDisabled
                        ? l.premiumFeatureLocked
                        : l.unlockPremiumFeatures,
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: AppSpacing.lg),
            if (feature == PremiumFeature.ocr &&
                onEarnScanCredit != null &&
                result.reason == PremiumAccessReason.premiumRequired) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    await onEarnScanCredit();
                  },
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: Text(l.watchAdForOneOcrCredit),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(l.premiumMaybeLater),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: result.reason == PremiumAccessReason.featureDisabled
                        ? null
                        : () {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(context).pushNamed(AppRoutes.premium);
                          },
                    child: Text(l.subscribeToContinue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

String _messageForResult(
  ScanLenoLocalizations l,
  PremiumAccessResult result,
) {
  return switch (result.messageKey) {
    'premiumOcrCreditMessage' => l.premiumOcrCreditMessage,
    'premiumRequiredForOcr' => l.premiumRequiredForOcr,
    'premiumOcrNoCreditMessage' => l.premiumOcrNoCreditMessage,
    'premiumFeatureLocked' => l.premiumFeatureLockedMessage,
    'premiumUnlockAdvancedTools' => l.premiumUnlockAdvancedTools,
    'premiumRequiredForAdvancedPdf' => l.premiumRequiredForAdvancedPdf,
    'premiumRequiredForUnlimitedScans' =>
      l.premiumRequiredForUnlimitedScans,
    'freeDailyScanLimitReached' => l.freeDailyScanLimitReached,
    'freeFolderLimitReached' => l.freeFolderLimitReached,
    _ => l.premiumRequiredMessage,
  };
}
