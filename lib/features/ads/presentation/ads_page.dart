import 'package:flutter/material.dart';

import '../../../core/config/scanleno_app_config.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../application/ad_service.dart';
import 'ad_banner_slot.dart';

class AdsPage extends StatelessWidget {
  const AdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppScreen(
      title: l.ads,
      showBack: true,
      child: ListView(
        children: [
          SoftCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.ads_click_outlined,
                color: AppColors.interactive,
              ),
              title: Text(l.adminAds),
              subtitle: Text(l.subscriptionCached),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const AdBannerSlot(placement: AdPlacement.home),
          const SizedBox(height: AppSpacing.md),
          SoftCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.card_giftcard_rounded,
                color: AppColors.accent,
              ),
              title: Text(l.earnScanCredit),
              subtitle: Text(l.scanCreditReward),
              trailing: FilledButton(
                onPressed: adService.canOfferRewardedUnlock()
                    ? adService.showRewardedForScanCredit
                    : null,
                child: Text(l.tryNow),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ConfigRow(label: l.adPlacement, value: scanLenoConfig.environmentName),
          _ConfigRow(label: l.filesStayOnDevice, value: l.gotIt),
        ],
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}
