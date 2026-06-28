import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../application/ad_service.dart';
import '../application/admob_config.dart';

class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({super.key, required this.placement});

  final AdPlacement placement;

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  BannerAd? ad;
  bool loaded = false;
  bool failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  @override
  void dispose() {
    ad?.dispose();
    super.dispose();
  }

  void _load() {
    if (ad != null || failed || !adService.canShowBanner(widget.placement)) {
      return;
    }
    final adUnitId = AdMobConfig.adUnitId(AdMobAdType.banner);
    if (adUnitId == null) return;
    ad = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => failed = true);
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (!adService.canShowBanner(widget.placement) || failed) {
      return const SizedBox.shrink();
    }
    if (!loaded || ad == null) {
      return SizedBox(
        height: 64,
        child: Center(
          child: Text(
            context.l10n.adPlacement,
            style: const TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }
    return Container(
      height: ad!.size.height.toDouble(),
      width: ad!.size.width.toDouble(),
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: AdWidget(ad: ad!),
    );
  }
}
