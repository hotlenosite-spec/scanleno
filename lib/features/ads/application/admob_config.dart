import 'package:flutter/foundation.dart';

enum AdMobAdType { banner, interstitial, rewarded }

abstract final class AdMobConfig {
  static const androidAppId = 'ca-app-pub-5375559288118322~5149137479';
  static const iosAppId = 'ca-app-pub-5375559288118322~8298044990';

  static const _androidProductionBanner =
      'ca-app-pub-5375559288118322/7886981452';
  static const _androidProductionInterstitial =
      'ca-app-pub-5375559288118322/7719460494';
  static const _androidProductionRewarded =
      'ca-app-pub-5375559288118322/3373021373';

  static const _iosProductionBanner =
      'ca-app-pub-5375559288118322/6406378826';
  static const _iosProductionInterstitial =
      'ca-app-pub-5375559288118322/3045718316';
  static const _iosProductionRewarded =
      'ca-app-pub-5375559288118322/7312266382';

  static const _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _androidTestRewarded = 'ca-app-pub-3940256099942544/5224354917';

  static const _iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const _iosTestRewarded = 'ca-app-pub-3940256099942544/1712485313';

  static const rewardAmount = 1;
  static const rewardItem = 'scan_credit';

  static String? adUnitId(AdMobAdType type) {
    if (kIsWeb) return null;
    final useTestAds = !kReleaseMode;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return switch ((type, useTestAds)) {
        (AdMobAdType.banner, true) => _androidTestBanner,
        (AdMobAdType.interstitial, true) => _androidTestInterstitial,
        (AdMobAdType.rewarded, true) => _androidTestRewarded,
        (AdMobAdType.banner, false) => _androidProductionBanner,
        (AdMobAdType.interstitial, false) => _androidProductionInterstitial,
        (AdMobAdType.rewarded, false) => _androidProductionRewarded,
      };
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return switch ((type, useTestAds)) {
        (AdMobAdType.banner, true) => _iosTestBanner,
        (AdMobAdType.interstitial, true) => _iosTestInterstitial,
        (AdMobAdType.rewarded, true) => _iosTestRewarded,
        (AdMobAdType.banner, false) => _iosProductionBanner,
        (AdMobAdType.interstitial, false) => _iosProductionInterstitial,
        (AdMobAdType.rewarded, false) => _iosProductionRewarded,
      };
    }
    return null;
  }
}
