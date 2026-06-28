import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/constants/feature_flags.dart';
import '../../files/application/local_file_repository.dart';
import '../../premium/application/subscription_service.dart';
import 'admob_config.dart';

enum AdPlacement { home, files, tools, afterExport }

class AdService extends ChangeNotifier {
  int shownToday = 0;
  DateTime lastReset = DateTime.now();

  Future<void> initialize() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
  }

  bool canShowBanner(AdPlacement placement) {
    if (subscriptionService.isPremium) return false;
    if (!FeatureFlags.adsEnabled || !FeatureFlags.bannerEnabled) return false;
    if (AdMobConfig.adUnitId(AdMobAdType.banner) == null) return false;
    return switch (placement) {
      AdPlacement.home => FeatureFlags.homeBannerAdsEnabled,
      AdPlacement.files => FeatureFlags.filesBannerAdsEnabled,
      AdPlacement.tools => FeatureFlags.toolsBannerAdsEnabled,
      AdPlacement.afterExport => false,
    };
  }

  bool canShowInterstitial() {
    if (subscriptionService.isPremium) return false;
    if (!FeatureFlags.adsEnabled ||
        !FeatureFlags.interstitialAfterExportEnabled) {
      return false;
    }
    if (AdMobConfig.adUnitId(AdMobAdType.interstitial) == null) return false;
    _resetIfNeeded();
    return shownToday < 6;
  }

  void markInterstitialShown() {
    _resetIfNeeded();
    shownToday += 1;
    notifyListeners();
  }

  bool canOfferRewardedUnlock() {
    return !subscriptionService.isPremium &&
        FeatureFlags.adsEnabled &&
        FeatureFlags.rewardedAdsEnabled &&
        AdMobConfig.adUnitId(AdMobAdType.rewarded) != null;
  }

  Future<void> showInterstitialAfterExport() async {
    if (!canShowInterstitial()) return;
    final adUnitId = AdMobConfig.adUnitId(AdMobAdType.interstitial);
    if (adUnitId == null) return;
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
          );
          markInterstitialShown();
          ad.show();
        },
        onAdFailedToLoad: (_) {},
      ),
    );
  }

  Future<void> showRewardedForScanCredit() async {
    if (!canOfferRewardedUnlock()) return;
    final adUnitId = AdMobConfig.adUnitId(AdMobAdType.rewarded);
    if (adUnitId == null) return;
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
          );
          ad.show(
            onUserEarnedReward: (_, reward) async {
              await LocalFileRepository().addScanCredits(AdMobConfig.rewardAmount);
            },
          );
        },
        onAdFailedToLoad: (_) {},
      ),
    );
  }

  void _resetIfNeeded() {
    final now = DateTime.now();
    if (now.year != lastReset.year ||
        now.month != lastReset.month ||
        now.day != lastReset.day) {
      shownToday = 0;
      lastReset = now;
    }
  }
}

final adService = AdService();
