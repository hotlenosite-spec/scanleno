import '../../../core/constants/feature_flags.dart';
import '../../account/application/firebase_auth_service.dart';
import '../../files/application/local_file_repository.dart';
import 'subscription_service.dart';

enum PremiumFeature {
  ocr,
  mergePdf,
  splitPdf,
  compressPdf,
  protectPdf,
  editPdfPages,
  pdfToImages,
  pdfTextEditing,
  removeAds,
  unlimitedScans,
  unlimitedFolders,
  advancedPdfTools,
  translate,
  aiSummary,
  pdfToExcel,
  pdfToWord,
  signature,
  watermark,
  advancedOcrLanguages,
}

enum PremiumAccessReason {
  allowed,
  premiumRequired,
  scanCreditAllowed,
  featureDisabled,
}

class PremiumAccessResult {
  const PremiumAccessResult({
    required this.allowed,
    required this.reason,
    required this.requiresPremium,
    required this.canUseScanCredit,
    required this.isPremiumUser,
    required this.messageKey,
  });

  final bool allowed;
  final PremiumAccessReason reason;
  final bool requiresPremium;
  final bool canUseScanCredit;
  final bool isPremiumUser;
  final String messageKey;

  PremiumAccessResult copyWith({
    bool? allowed,
    PremiumAccessReason? reason,
    bool? requiresPremium,
    bool? canUseScanCredit,
    bool? isPremiumUser,
    String? messageKey,
  }) {
    return PremiumAccessResult(
      allowed: allowed ?? this.allowed,
      reason: reason ?? this.reason,
      requiresPremium: requiresPremium ?? this.requiresPremium,
      canUseScanCredit: canUseScanCredit ?? this.canUseScanCredit,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      messageKey: messageKey ?? this.messageKey,
    );
  }
}

class PremiumAccessService {
  PremiumAccessService({
    LocalFileRepository? repository,
    SubscriptionService? subscription,
    FirebaseAuthService? auth,
  }) : _repository = repository ?? LocalFileRepository(),
       _subscription = subscription ?? subscriptionService,
       _auth = auth ?? firebaseAuthService;

  final LocalFileRepository _repository;
  final SubscriptionService _subscription;
  final FirebaseAuthService _auth;

  Future<PremiumAccessResult> canAccessPremiumFeature(
    PremiumFeature feature,
  ) async {
    if (!_featureFlagEnabled(feature)) {
      return const PremiumAccessResult(
        allowed: false,
        reason: PremiumAccessReason.featureDisabled,
        requiresPremium: false,
        canUseScanCredit: false,
        isPremiumUser: false,
        messageKey: 'premiumFeatureLocked',
      );
    }

    await _subscription.initialize();
    final isPremium = _isVerifiedPremium();
    if (isPremium) {
      return const PremiumAccessResult(
        allowed: true,
        reason: PremiumAccessReason.allowed,
        requiresPremium: false,
        canUseScanCredit: false,
        isPremiumUser: true,
        messageKey: 'premiumRequiredMessage',
      );
    }

    if (feature == PremiumFeature.ocr) {
      final scanCredits = await _repository.getScanCredits();
      final canUseCredit =
          _auth.isSignedIn &&
          FeatureFlags.ocrWithScanCreditEnabled &&
          scanCredits > 0;
      return PremiumAccessResult(
        allowed: canUseCredit || !FeatureFlags.ocrPremiumOnly,
        reason: canUseCredit
            ? PremiumAccessReason.scanCreditAllowed
            : PremiumAccessReason.premiumRequired,
        requiresPremium: !canUseCredit && FeatureFlags.ocrPremiumOnly,
        canUseScanCredit: canUseCredit,
        isPremiumUser: false,
        messageKey: canUseCredit
            ? 'premiumOcrCreditMessage'
            : 'premiumRequiredForOcr',
      );
    }

    if (feature == PremiumFeature.translate) {
      final scanCredits = await _repository.getScanCredits();
      final canUseCredit =
          _auth.isSignedIn &&
          FeatureFlags.translateWithScanCreditEnabled &&
          scanCredits > 0;
      return PremiumAccessResult(
        allowed: canUseCredit || !FeatureFlags.translatePremiumOnly,
        reason: canUseCredit
            ? PremiumAccessReason.scanCreditAllowed
            : PremiumAccessReason.premiumRequired,
        requiresPremium: !canUseCredit && FeatureFlags.translatePremiumOnly,
        canUseScanCredit: canUseCredit,
        isPremiumUser: false,
        messageKey: canUseCredit
            ? 'translateCreditMessage'
            : 'premiumRequiredForTranslate',
      );
    }

    if (feature == PremiumFeature.aiSummary) {
      final scanCredits = await _repository.getScanCredits();
      final canUseCredit =
          _auth.isSignedIn &&
          FeatureFlags.aiSummaryWithScanCreditEnabled &&
          scanCredits > 0;
      return PremiumAccessResult(
        allowed: canUseCredit || !FeatureFlags.aiSummaryPremiumOnly,
        reason: canUseCredit
            ? PremiumAccessReason.scanCreditAllowed
            : PremiumAccessReason.premiumRequired,
        requiresPremium: !canUseCredit && FeatureFlags.aiSummaryPremiumOnly,
        canUseScanCredit: canUseCredit,
        isPremiumUser: false,
        messageKey: canUseCredit
            ? 'aiSummaryCreditMessage'
            : 'premiumRequiredForAiSummary',
      );
    }

    if (feature == PremiumFeature.pdfToExcel) {
      final scanCredits = await _repository.getScanCredits();
      final canUseCredit =
          _auth.isSignedIn &&
          FeatureFlags.pdfToExcelWithScanCreditEnabled &&
          scanCredits > 0;
      return PremiumAccessResult(
        allowed: canUseCredit || !FeatureFlags.pdfToExcelPremiumOnly,
        reason: canUseCredit
            ? PremiumAccessReason.scanCreditAllowed
            : PremiumAccessReason.premiumRequired,
        requiresPremium: !canUseCredit && FeatureFlags.pdfToExcelPremiumOnly,
        canUseScanCredit: canUseCredit,
        isPremiumUser: false,
        messageKey: canUseCredit
            ? 'pdfToExcelCreditMessage'
            : 'premiumRequiredForPdfToExcel',
      );
    }

    if (feature == PremiumFeature.pdfToWord) {
      final scanCredits = await _repository.getScanCredits();
      final canUseCredit =
          _auth.isSignedIn &&
          FeatureFlags.pdfToWordWithScanCreditEnabled &&
          scanCredits > 0;
      return PremiumAccessResult(
        allowed: canUseCredit || !FeatureFlags.pdfToWordPremiumOnly,
        reason: canUseCredit
            ? PremiumAccessReason.scanCreditAllowed
            : PremiumAccessReason.premiumRequired,
        requiresPremium: !canUseCredit && FeatureFlags.pdfToWordPremiumOnly,
        canUseScanCredit: canUseCredit,
        isPremiumUser: false,
        messageKey: canUseCredit
            ? 'pdfToWordCreditMessage'
            : 'premiumRequiredForPdfToWord',
      );
    }

    return PremiumAccessResult(
      allowed: false,
      reason: PremiumAccessReason.premiumRequired,
      requiresPremium: true,
      canUseScanCredit: false,
      isPremiumUser: false,
      messageKey: _premiumMessageKey(feature),
    );
  }

  String _premiumMessageKey(PremiumFeature feature) {
    return switch (feature) {
      PremiumFeature.unlimitedScans => 'premiumRequiredForUnlimitedScans',
      PremiumFeature.unlimitedFolders => 'freeFolderLimitReached',
      PremiumFeature.mergePdf ||
      PremiumFeature.splitPdf ||
      PremiumFeature.compressPdf ||
      PremiumFeature.protectPdf ||
      PremiumFeature.editPdfPages ||
      PremiumFeature.pdfToImages ||
      PremiumFeature.pdfTextEditing ||
      PremiumFeature.advancedPdfTools => 'premiumRequiredForAdvancedPdf',
      PremiumFeature.ocr => 'premiumRequiredForOcr',
      PremiumFeature.translate => 'premiumRequiredForTranslate',
      PremiumFeature.aiSummary => 'premiumRequiredForAiSummary',
      PremiumFeature.pdfToExcel => 'premiumRequiredForPdfToExcel',
      PremiumFeature.pdfToWord => 'premiumRequiredForPdfToWord',
      PremiumFeature.signature ||
      PremiumFeature.watermark ||
      PremiumFeature.advancedOcrLanguages => 'premiumRequiredForAdvancedPdf',
      PremiumFeature.removeAds => 'premiumRequiredMessage',
    };
  }

  bool _isVerifiedPremium() {
    final metadata = _auth.metadata;
    if (metadata != null) {
      return metadata.premiumActive && !metadata.disabled;
    }
    return _subscription.isPremium;
  }

  bool _featureFlagEnabled(PremiumFeature feature) {
    return switch (feature) {
      PremiumFeature.ocr => FeatureFlags.ocrEnabled,
      PremiumFeature.translate => FeatureFlags.translateEnabled,
      PremiumFeature.aiSummary => FeatureFlags.aiSummaryEnabled,
      PremiumFeature.pdfToExcel => FeatureFlags.pdfToExcelEnabled,
      PremiumFeature.pdfToWord => FeatureFlags.pdfToWordEnabled,
      PremiumFeature.signature => FeatureFlags.signatureEnabled,
      PremiumFeature.watermark => FeatureFlags.watermarkEnabled,
      PremiumFeature.advancedOcrLanguages =>
        FeatureFlags.advancedOcrLanguagesEnabled,
      PremiumFeature.mergePdf => FeatureFlags.mergePdfEnabled,
      PremiumFeature.splitPdf => FeatureFlags.splitPdfEnabled,
      PremiumFeature.compressPdf => FeatureFlags.compressPdfEnabled,
      PremiumFeature.protectPdf => FeatureFlags.protectPdfEnabled,
      PremiumFeature.editPdfPages => FeatureFlags.editPdfPagesEnabled,
      PremiumFeature.pdfToImages => FeatureFlags.pdfToImagesEnabled,
      PremiumFeature.pdfTextEditing => FeatureFlags.pdfTextEditingEnabled,
      PremiumFeature.advancedPdfTools => FeatureFlags.advancedPdfToolsEnabled,
      PremiumFeature.removeAds ||
      PremiumFeature.unlimitedScans ||
      PremiumFeature.unlimitedFolders => true,
    };
  }
}

final premiumAccessService = PremiumAccessService();
