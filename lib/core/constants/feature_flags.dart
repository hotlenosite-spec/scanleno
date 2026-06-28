import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/scanleno_app_config.dart';
import '../database/scanleno_database.dart';

class FeatureFlagState {
  const FeatureFlagState({
    required this.values,
    required this.loadedFromBackend,
    required this.loadedAt,
  });

  factory FeatureFlagState.defaults() => FeatureFlagState(
    values: const {
      'adsEnabled': true,
      'bannerEnabled': true,
      'bannerAdsEnabled': true,
      'interstitialAfterExportEnabled': true,
      'interstitialAdsEnabled': true,
      'rewardedAdsEnabled': true,
      'homeBannerAdsEnabled': true,
      'filesBannerAdsEnabled': true,
      'toolsBannerAdsEnabled': true,
      'freeDailyScanLimit': 10,
      'freeImageImportLimit': 12,
      'freeImageToPdfLimit': 12,
      'freeFolderLimit': 3,
      'watermarkEnabled': false,
      'exportWatermarkEnabled': false,
      'ocrEnabled': true,
      'ocrPremiumOnly': true,
      'ocrAsPremium': true,
      'ocrWithScanCreditEnabled': true,
      'ocrScanCreditEnabled': true,
      'freeDailyOcrLimit': 3,
      'premiumMonthlyOcrLimit': 500,
      'premiumYearlyOcrLimit': 6000,
      'advancedPdfToolsEnabled': false,
      'mergePdfEnabled': false,
      'splitPdfEnabled': false,
      'compressPdfEnabled': false,
      'protectPdfEnabled': false,
      'editPdfPagesEnabled': false,
      'pdfToImagesEnabled': false,
      'pdfTextEditingEnabled': false,
      'freeTrialEnabled': false,
      'annualOffersEnabled': true,
    },
    loadedFromBackend: false,
    loadedAt: null,
  );

  final Map<String, Object?> values;
  final bool loadedFromBackend;
  final DateTime? loadedAt;

  FeatureFlagState copyWith({
    Map<String, Object?>? values,
    bool? loadedFromBackend,
    DateTime? loadedAt,
  }) {
    return FeatureFlagState(
      values: values ?? this.values,
      loadedFromBackend: loadedFromBackend ?? this.loadedFromBackend,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }
}

abstract final class FeatureFlags {
  static const _cacheKey = 'feature_flags_cache_v1';
  static FeatureFlagState _state = FeatureFlagState.defaults();

  static FeatureFlagState get state => _state;

  static Future<void> initialize() async {
    await _loadCached();
    await refreshFromBackend();
  }

  static Future<void> refreshFromBackend() async {
    try {
      final response = await http
          .get(_uri('/api/feature-flags'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) return;
      await applyAndCache(
        (jsonDecode(response.body) as Map<String, dynamic>)
            .cast<String, Object?>(),
        loadedFromBackend: true,
      );
    } catch (_) {
      // Keep the default or cached state when backend is unavailable.
    }
  }

  static Future<void> applyAndCache(
    Map<String, Object?> values, {
    bool loadedFromBackend = false,
  }) async {
    _state = _state.copyWith(
      values: _normalize({..._state.values, ...values}),
      loadedFromBackend: loadedFromBackend,
      loadedAt: DateTime.now(),
    );
    await _saveCached();
  }

  static Future<void> _loadCached() async {
    try {
      final record = await (scanLenoDatabase.select(scanLenoDatabase.userSettings)
            ..where((row) => row.key.equals(_cacheKey)))
          .getSingleOrNull();
      if (record == null) return;
      final cached = (jsonDecode(record.value) as Map<String, dynamic>)
          .cast<String, Object?>();
      _state = _state.copyWith(values: _normalize({..._state.values, ...cached}));
    } catch (_) {
      _state = FeatureFlagState.defaults();
    }
  }

  static Future<void> _saveCached() async {
    try {
      await scanLenoDatabase.into(scanLenoDatabase.userSettings).insertOnConflictUpdate(
        UserSettingsCompanion.insert(
          key: _cacheKey,
          value: jsonEncode(_state.values),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (error) {
      debugPrint('Feature flag cache was not updated: $error');
    }
  }

  static Uri _uri(String path) {
    return scanLenoConfig.backendUri(path);
  }

  static Map<String, Object?> _normalize(Map<String, Object?> raw) {
    final normalized = Map<String, Object?>.from(raw);
    void alias(String canonical, String legacy) {
      if (normalized[canonical] == null && normalized[legacy] != null) {
        normalized[canonical] = normalized[legacy];
      }
      if (normalized[legacy] == null && normalized[canonical] != null) {
        normalized[legacy] = normalized[canonical];
      }
    }

    alias('bannerEnabled', 'bannerAdsEnabled');
    alias('interstitialAfterExportEnabled', 'interstitialAdsEnabled');
    alias('ocrPremiumOnly', 'ocrAsPremium');
    alias('ocrWithScanCreditEnabled', 'ocrScanCreditEnabled');
    alias('watermarkEnabled', 'exportWatermarkEnabled');
    return normalized;
  }

  static bool _bool(String key, bool fallback) {
    final value = _state.values[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  static int _int(String key, int fallback) {
    final value = _state.values[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static int get freeDailyScanLimit => _int('freeDailyScanLimit', 10);
  static int get freeImageImportLimit => _int('freeImageImportLimit', 12);
  static int get freeImageToPdfLimit => _int('freeImageToPdfLimit', 12);
  static int get freeFolderLimit => _int('freeFolderLimit', 3);
  static bool get adsEnabled => _bool('adsEnabled', true);
  static bool get bannerEnabled => _bool('bannerEnabled', true);
  static bool get bannerAdsEnabled => bannerEnabled;
  static bool get interstitialAfterExportEnabled =>
      _bool('interstitialAfterExportEnabled', true);
  static bool get interstitialAdsEnabled => interstitialAfterExportEnabled;
  static bool get rewardedAdsEnabled => _bool('rewardedAdsEnabled', true);
  static bool get homeBannerAdsEnabled => _bool('homeBannerAdsEnabled', true);
  static bool get filesBannerAdsEnabled => _bool('filesBannerAdsEnabled', true);
  static bool get toolsBannerAdsEnabled => _bool('toolsBannerAdsEnabled', true);
  static bool get watermarkEnabled => _bool('watermarkEnabled', false);
  static bool get exportWatermarkEnabled => watermarkEnabled;
  static bool get freeTrialEnabled => _bool('freeTrialEnabled', false);
  static bool get annualOffersEnabled => _bool('annualOffersEnabled', true);
  static bool get ocrEnabled => _bool('ocrEnabled', true);
  static bool get ocrPremiumOnly => _bool('ocrPremiumOnly', true);
  static bool get ocrAsPremium => ocrPremiumOnly;
  static bool get ocrWithScanCreditEnabled =>
      _bool('ocrWithScanCreditEnabled', true);
  static bool get ocrScanCreditEnabled => ocrWithScanCreditEnabled;
  static int get freeDailyOcrLimit => _int('freeDailyOcrLimit', 3);
  static int get premiumMonthlyOcrLimit => _int('premiumMonthlyOcrLimit', 500);
  static int get premiumYearlyOcrLimit => _int('premiumYearlyOcrLimit', 6000);
  static bool get advancedPdfToolsEnabled =>
      _bool('advancedPdfToolsEnabled', false);
  static bool get mergePdfEnabled =>
      advancedPdfToolsEnabled || _bool('mergePdfEnabled', false);
  static bool get splitPdfEnabled =>
      advancedPdfToolsEnabled || _bool('splitPdfEnabled', false);
  static bool get compressPdfEnabled =>
      advancedPdfToolsEnabled || _bool('compressPdfEnabled', false);
  static bool get protectPdfEnabled => _bool('protectPdfEnabled', false);
  static bool get editPdfPagesEnabled =>
      advancedPdfToolsEnabled || _bool('editPdfPagesEnabled', false);
  static bool get pdfToImagesEnabled =>
      advancedPdfToolsEnabled || _bool('pdfToImagesEnabled', false);
  static bool get pdfTextEditingEnabled =>
      advancedPdfToolsEnabled || _bool('pdfTextEditingEnabled', false);
}
