enum ScanLenoEnvironment {
  development,
  staging,
  production;

  static ScanLenoEnvironment fromName(String value) {
    return switch (value.trim().toLowerCase()) {
      'production' || 'prod' => ScanLenoEnvironment.production,
      'staging' || 'stage' => ScanLenoEnvironment.staging,
      _ => ScanLenoEnvironment.development,
    };
  }
}

class ScanLenoConfigException implements Exception {
  const ScanLenoConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ScanLenoAppConfig {
  const ScanLenoAppConfig({
    required this.monthlyProductId,
    required this.annualProductId,
    required this.bannerAdUnitId,
    required this.interstitialAdUnitId,
    required this.rewardedAdUnitId,
    required this.backendBaseUrl,
    required this.environmentName,
  });

  factory ScanLenoAppConfig.fromEnvironment() {
    return const ScanLenoAppConfig(
      monthlyProductId: String.fromEnvironment(
        'SCANLENO_IAP_MONTHLY_ID',
        defaultValue: 'scanleno_premium_monthly',
      ),
      annualProductId: String.fromEnvironment(
        'SCANLENO_IAP_ANNUAL_ID',
        defaultValue: 'scanleno_premium_yearly',
      ),
      bannerAdUnitId: String.fromEnvironment('SCANLENO_AD_BANNER_ID'),
      interstitialAdUnitId: String.fromEnvironment(
        'SCANLENO_AD_INTERSTITIAL_ID',
      ),
      rewardedAdUnitId: String.fromEnvironment('SCANLENO_AD_REWARDED_ID'),
      backendBaseUrl: String.fromEnvironment('SCANLENO_BACKEND_URL'),
      environmentName: String.fromEnvironment(
        'SCANLENO_ENV',
        defaultValue: 'development',
      ),
    );
  }

  final String monthlyProductId;
  final String annualProductId;
  final String bannerAdUnitId;
  final String interstitialAdUnitId;
  final String rewardedAdUnitId;
  final String backendBaseUrl;
  final String environmentName;

  ScanLenoEnvironment get environment =>
      ScanLenoEnvironment.fromName(environmentName);

  bool get isDevelopment => environment == ScanLenoEnvironment.development;
  bool get isStaging => environment == ScanLenoEnvironment.staging;
  bool get isProduction => environment == ScanLenoEnvironment.production;

  String get effectiveBackendBaseUrl {
    final configured = backendBaseUrl.trim();
    if (configured.isNotEmpty) return configured;
    if (isDevelopment) return 'http://localhost:8787';
    throw const ScanLenoConfigException(
      'SCANLENO_BACKEND_URL is required when SCANLENO_ENV is staging or production.',
    );
  }

  Uri backendUri(String path) {
    return Uri.parse(effectiveBackendBaseUrl).resolve(path);
  }

  void validateForStartup() {
    final configured = backendBaseUrl.trim();
    if (!isDevelopment && configured.isEmpty) {
      throw const ScanLenoConfigException(
        'Missing SCANLENO_BACKEND_URL. Localhost fallback is allowed only in development.',
      );
    }
    if (isProduction && configured.contains('localhost')) {
      throw const ScanLenoConfigException(
        'Production builds must not use localhost as SCANLENO_BACKEND_URL.',
      );
    }
    if (isProduction && configured.contains('127.0.0.1')) {
      throw const ScanLenoConfigException(
        'Production builds must not use 127.0.0.1 as SCANLENO_BACKEND_URL.',
      );
    }
  }
}

final scanLenoConfig = ScanLenoAppConfig.fromEnvironment();
