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
        defaultValue: 'scanleno_premium_annual',
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
}

final scanLenoConfig = ScanLenoAppConfig.fromEnvironment();
