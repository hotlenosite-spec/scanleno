import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/scanleno_app_config.dart';
import '../../../core/constants/feature_flags.dart';
import '../../account/application/firebase_auth_service.dart';
import '../../files/application/local_file_repository.dart';
import '../../premium/application/subscription_service.dart';
import 'admob_config.dart';

enum AdPlacement { home, files, tools, afterExport }

enum RewardedCreditStatus {
  granted,
  pending,
  rejected,
  expired,
  notReady,
  verificationFailed,
  limitReached,
}

class RewardedCreditResult {
  const RewardedCreditResult({
    required this.status,
    this.scanCredit,
    this.rewardSessionId,
  });

  final RewardedCreditStatus status;
  final int? scanCredit;
  final String? rewardSessionId;
}

class _RewardSession {
  const _RewardSession({
    required this.rewardSessionId,
    required this.customData,
    required this.expiresAt,
  });

  final String rewardSessionId;
  final String customData;
  final DateTime expiresAt;
}

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

  Future<RewardedCreditResult> showRewardedForScanCredit() async {
    if (!canOfferRewardedUnlock()) {
      return const RewardedCreditResult(status: RewardedCreditStatus.notReady);
    }
    if (!firebaseAuthService.isSignedIn) {
      return const RewardedCreditResult(
        status: RewardedCreditStatus.verificationFailed,
      );
    }
    final adUnitId = AdMobConfig.adUnitId(AdMobAdType.rewarded);
    if (adUnitId == null) {
      return const RewardedCreditResult(status: RewardedCreditStatus.notReady);
    }
    final session = await _startRewardedCreditSession(adUnitId);
    if (session == null) {
      return const RewardedCreditResult(
        status: RewardedCreditStatus.verificationFailed,
      );
    }
    final completer = Completer<RewardedCreditResult>();
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.setServerSideOptions(
            ServerSideVerificationOptions(
              customData: session.customData,
              userId: session.rewardSessionId,
            ),
          );
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(
                  RewardedCreditResult(
                    status: RewardedCreditStatus.rejected,
                    rewardSessionId: session.rewardSessionId,
                  ),
                );
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(
                  RewardedCreditResult(
                    status: RewardedCreditStatus.notReady,
                    rewardSessionId: session.rewardSessionId,
                  ),
                );
              }
            },
          );
          ad.show(
            onUserEarnedReward: (_, reward) async {
              final result = await _pollRewardedCreditStatus(
                session.rewardSessionId,
                markEarned: true,
              );
              if (result.status == RewardedCreditStatus.granted &&
                  result.scanCredit != null) {
                await LocalFileRepository().saveSetting(
                  'scan_credit',
                  result.scanCredit.toString(),
                );
              }
              if (!completer.isCompleted) completer.complete(result);
            },
          );
        },
        onAdFailedToLoad: (_) {
          if (!completer.isCompleted) {
            completer.complete(
              RewardedCreditResult(
                status: RewardedCreditStatus.notReady,
                rewardSessionId: session.rewardSessionId,
              ),
            );
          }
        },
      ),
    );
    return completer.future.timeout(
      const Duration(seconds: 45),
      onTimeout: () => RewardedCreditResult(
        status: RewardedCreditStatus.pending,
        rewardSessionId: session.rewardSessionId,
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

  Future<_RewardSession?> _startRewardedCreditSession(String adUnitId) async {
    final token = await firebaseAuthService.idToken(forceRefresh: true);
    if (token == null) return null;
    try {
      final response = await http
          .post(
            _backendUri('/api/credits/rewarded/start'),
            headers: {
              'content-type': 'application/json; charset=utf-8',
              'authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'platform': defaultTargetPlatform.name,
              'adUnitId': adUnitId,
              'rewardItem': AdMobConfig.rewardItem,
              'rewardAmount': AdMobConfig.rewardAmount,
            }),
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final rewardSessionId = decoded['rewardSessionId'] as String?;
      final customData = decoded['customData'] as String?;
      if (rewardSessionId == null || customData == null) return null;
      return _RewardSession(
        rewardSessionId: rewardSessionId,
        customData: customData,
        expiresAt:
            DateTime.tryParse(decoded['expiresAt'] as String? ?? '') ??
                DateTime.now().add(const Duration(minutes: 15)),
      );
    } catch (_) {
      return null;
    }
  }

  Future<RewardedCreditResult> _pollRewardedCreditStatus(
    String rewardSessionId, {
    required bool markEarned,
  }) async {
    for (var attempt = 0; attempt < 6; attempt += 1) {
      final result = await _rewardedCreditStatus(
        rewardSessionId,
        markEarned: markEarned && attempt == 0,
      );
      if (result.status != RewardedCreditStatus.pending) return result;
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    return RewardedCreditResult(
      status: RewardedCreditStatus.pending,
      rewardSessionId: rewardSessionId,
    );
  }

  Future<RewardedCreditResult> _rewardedCreditStatus(
    String rewardSessionId, {
    required bool markEarned,
  }) async {
    final token = await firebaseAuthService.idToken(forceRefresh: true);
    if (token == null) {
      return RewardedCreditResult(
        status: RewardedCreditStatus.verificationFailed,
        rewardSessionId: rewardSessionId,
      );
    }
    try {
      final uri = _backendUri('/api/credits/rewarded/status').replace(
        queryParameters: {
          'rewardSessionId': rewardSessionId,
          if (markEarned) 'markEarned': 'true',
        },
      );
      final response = await http
          .get(uri, headers: {'authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 429) {
        return RewardedCreditResult(
          status: RewardedCreditStatus.limitReached,
          rewardSessionId: rewardSessionId,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return RewardedCreditResult(
          status: RewardedCreditStatus.verificationFailed,
          rewardSessionId: rewardSessionId,
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return RewardedCreditResult(
          status: RewardedCreditStatus.verificationFailed,
          rewardSessionId: rewardSessionId,
        );
      }
      return RewardedCreditResult(
        status: _statusFromServer(decoded['status'] as String?),
        scanCredit: (decoded['scanCredit'] as num?)?.toInt(),
        rewardSessionId: rewardSessionId,
      );
    } catch (_) {
      return RewardedCreditResult(
        status: RewardedCreditStatus.verificationFailed,
        rewardSessionId: rewardSessionId,
      );
    }
  }

  RewardedCreditStatus _statusFromServer(String? status) {
    return switch (status) {
      'granted' => RewardedCreditStatus.granted,
      'expired' => RewardedCreditStatus.expired,
      'rejected' => RewardedCreditStatus.rejected,
      _ => RewardedCreditStatus.pending,
    };
  }

  Uri _backendUri(String path) {
    return scanLenoConfig.backendUri(path);
  }
}

final adService = AdService();
