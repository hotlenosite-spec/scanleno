import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/feature_flags.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../../ads/application/ad_service.dart';
import '../../files/application/local_file_repository.dart';
import '../../premium/application/premium_access_service.dart';
import '../../premium/presentation/premium_gate_dialog.dart';
import '../../scanner/application/document_draft_controller.dart';
import '../application/ocr_backend_service.dart';

class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  final textController = TextEditingController();
  final searchController = TextEditingController();
  final repository = LocalFileRepository();
  final ocrService = OcrBackendService();
  bool loading = false;
  bool loadedAccess = false;
  int scanCredits = 0;
  PremiumAccessResult? accessResult;
  bool gateShown = false;
  String? provider;
  String? model;
  String? language;
  String? detectedLanguage;
  double? confidence;
  String selectedLanguage = 'auto';

  @override
  void initState() {
    super.initState();
    _loadAccess();
    _loadLanguagePreference();
  }

  @override
  void dispose() {
    textController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAccess() async {
    final credits = await repository.getScanCredits();
    final access = await premiumAccessService.canAccessPremiumFeature(
      PremiumFeature.ocr,
    );
    if (!mounted) return;
    setState(() {
      scanCredits = credits;
      accessResult = access;
      loadedAccess = true;
    });
    if (!access.allowed && !gateShown) {
      gateShown = true;
      await showPremiumGateDialog(
        context,
        feature: PremiumFeature.ocr,
        result: access,
        onEarnScanCredit: _earnCredit,
      );
    }
  }

  Future<void> _loadLanguagePreference() async {
    final saved = await repository.getSetting('ocr_language_hint');
    final fallback = FeatureFlags.defaultOcrLanguage;
    final value = _ocrLanguages.any((item) => item.code == saved)
        ? saved
        : (_ocrLanguages.any((item) => item.code == fallback) ? fallback : 'auto');
    if (!mounted) return;
    setState(() => selectedLanguage = value ?? 'auto');
  }

  Future<void> _analyze() async {
    if (!documentDraft.hasPages || loading) return;
    final access = await premiumAccessService.canAccessPremiumFeature(
      PremiumFeature.ocr,
    );
    if (!mounted) return;
    setState(() {
      accessResult = access;
    });
    if (!access.allowed) {
      await showPremiumGateDialog(
        context,
        feature: PremiumFeature.ocr,
        result: access,
        onEarnScanCredit: _earnCredit,
      );
      return;
    }
    final needsAdvancedLanguage =
        selectedLanguage != 'auto' && selectedLanguage != 'en';
    if (needsAdvancedLanguage) {
      final languageAccess = await premiumAccessService.canAccessPremiumFeature(
        PremiumFeature.advancedOcrLanguages,
      );
      if (!mounted) return;
      if (!languageAccess.allowed) {
        await showPremiumGateDialog(
          context,
          feature: PremiumFeature.advancedOcrLanguages,
          result: languageAccess,
        );
        return;
      }
    }

    setState(() => loading = true);
    try {
      final page = documentDraft.currentPage;
      final pageFile = File(page.path);
      var document = await repository.findDocumentByPath(page.path);
      if (document == null) {
        await repository.registerFiles(
          files: [pageFile],
          type: StoredDocumentType.image,
          pageCount: 1,
          thumbnailPath: page.path,
        );
        document = await repository.findDocumentByPath(page.path);
      }
      final documentId = document?.id ?? page.path.hashCode.toString();
      final languageForRequest =
          !FeatureFlags.allowAutoLanguageDetection && selectedLanguage == 'auto'
              ? 'en'
              : selectedLanguage;
      final result = await ocrService.analyzePage(
        documentId: documentId,
        pageIndex: documentDraft.currentIndex,
        imageFile: pageFile,
        isPremium: access.isPremiumUser,
        scanCreditAvailable: access.canUseScanCredit,
        languageHint: languageForRequest,
        model: 'read',
        detectLanguage: languageForRequest == 'auto',
      );
      textController.text = result.text;
      provider = result.provider;
      model = result.model;
      language = result.language;
      detectedLanguage = result.detectedLanguage;
      confidence = result.confidence;
      await repository.saveSetting('ocr_language_hint', languageForRequest);
      if (document != null) {
        await repository.saveOcrResult(
          documentId: document.id,
          text: result.text,
          provider: result.provider,
          model: result.model,
          createdAt: result.createdAt,
          pageIndex: result.pageIndex,
          language: result.languageHint ?? languageForRequest,
          detectedLanguage: result.detectedLanguage ?? result.language,
          confidence: result.confidence,
        );
      }
      if (result.creditConsumed) {
        if (result.remainingScanCredit != null) {
          await repository.saveSetting(
            'scan_credit',
            result.remainingScanCredit.toString(),
          );
        } else {
          await repository.consumeScanCredit();
        }
        scanCredits = await repository.getScanCredits();
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.recognitionComplete)));
      }
    } on OcrBackendException catch (error) {
      if (mounted) await _handleBackendError(error.code);
    } catch (_) {
      if (mounted) _showError(context.l10n.ocrFailed);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: textController.text));
  }

  Future<void> _share() {
    return SharePlus.instance.share(ShareParams(text: textController.text));
  }

  Future<void> _exportTxt() async {
    final directory = await getApplicationDocumentsDirectory();
    final folder = Directory('${directory.path}/ScanLeno');
    if (!folder.existsSync()) await folder.create(recursive: true);
    final file = File(
      '${folder.path}/ocr-${DateTime.now().microsecondsSinceEpoch}.txt',
    );
    await file.writeAsString(textController.text);
    await repository.registerFiles(
      files: [file],
      type: StoredDocumentType.text,
      pageCount: 1,
    );
    if (documentDraft.hasPages) {
      await repository.saveOcrTextForPath(
        documentDraft.currentPage.path,
        textController.text,
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.textSaved)));
    }
  }

  Future<void> _earnCredit() async {
    _showError(context.l10n.rewardEarnedWaitingForVerification);
    final result = await adService.showRewardedForScanCredit();
    if (!mounted) return;
    _showError(_rewardMessage(result.status));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _loadAccess();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final access = accessResult;
    final canAnalyze = FeatureFlags.ocrEnabled &&
        loadedAccess &&
        documentDraft.hasPages &&
        (access?.allowed ?? false);
    final languagePool = FeatureFlags.advancedOcrLanguagesEnabled
        ? _ocrLanguages
        : _basicOcrLanguages;
    final availableOcrLanguages = FeatureFlags.allowAutoLanguageDetection
        ? languagePool
        : languagePool.where((item) => item.code != 'auto').toList();
    final safeSelectedLanguage = availableOcrLanguages.any(
      (item) => item.code == selectedLanguage,
    )
        ? selectedLanguage
        : 'en';
    return AppScreen(
      title: l.ocrResult,
      showBack: true,
      bottomAction: textController.text.trim().isEmpty
          ? null
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(l.shareText),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _exportTxt,
                    icon: const Icon(Icons.text_snippet_outlined),
                    label: Text(l.exportText),
                  ),
                ),
              ],
            ),
      child: ListView(
        children: [
          if (!documentDraft.hasPages)
            _InfoCard(
              icon: Icons.document_scanner_outlined,
              title: l.noDocumentPages,
              actionLabel: l.openScanner,
              onAction: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.scanner),
            )
          else ...[
            AspectRatio(
              aspectRatio: 1.45,
              child: SoftCard(
                child: Image.file(
                  File(documentDraft.currentPage.path),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (!loadedAccess)
              const Center(child: CircularProgressIndicator())
            else if (!FeatureFlags.ocrEnabled)
              _InfoCard(
                icon: Icons.lock_clock_outlined,
                title: l.featureDisabled,
              )
            else if (!(access?.allowed ?? false))
              _AccessCard(onEarnCredit: _earnCredit)
            else ...[
              DropdownButtonFormField<String>(
                initialValue: safeSelectedLanguage,
                decoration: InputDecoration(labelText: l.ocrLanguage),
                items: [
                  for (final language in availableOcrLanguages)
                    DropdownMenuItem(
                      value: language.code,
                      child: Text(language.label(context)),
                    ),
                ],
                onChanged: loading
                    ? null
                    : (value) async {
                        if (value == null) return;
                        setState(() => selectedLanguage = value);
                        await repository.saveSetting('ocr_language_hint', value);
                      },
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: canAnalyze && !loading ? _analyze : null,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.document_scanner_outlined),
                label: Text(loading ? l.loading : l.extractTextNow),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (textController.text.trim().isNotEmpty) ...[
              SoftCard(
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.softTurquoise,
                      child: Icon(Icons.check_rounded, color: AppColors.accent),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l.textReady,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _OcrMeta(provider: provider, model: model, language: language, detectedLanguage: detectedLanguage, confidence: confidence),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l.searchText,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SoftCard(
                child: TextField(
                  controller: textController,
                  maxLines: 13,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: _copy,
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(l.copyText),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleBackendError(String code) async {
    if (code == 'premium_required' ||
        code == 'ocr_credit_required' ||
        code == 'auth_required') {
      final access = await premiumAccessService.canAccessPremiumFeature(
        PremiumFeature.ocr,
      );
      if (!mounted) return;
      await showPremiumGateDialog(
        context,
        feature: PremiumFeature.ocr,
        result: access,
        onEarnScanCredit: _earnCredit,
      );
      return;
    }
    final message = switch (code) {
      'ocr_disabled' => context.l10n.featureDisabled,
      'ocr_rate_limited' => context.l10n.ocrRateLimited,
      'ocr_language_not_supported' => context.l10n.unsupportedLanguage,
      'ocr_unavailable' => context.l10n.ocrFailed,
      'azure_ocr_failed' => context.l10n.ocrFailed,
      _ => context.l10n.ocrFailed,
    };
    _showError(message);
  }

  String _rewardMessage(RewardedCreditStatus status) {
    return switch (status) {
      RewardedCreditStatus.granted => context.l10n.ocrCreditAdded,
      RewardedCreditStatus.pending => context.l10n.rewardedCreditPending,
      RewardedCreditStatus.rejected => context.l10n.rewardedCreditRejected,
      RewardedCreditStatus.expired => context.l10n.rewardedCreditExpired,
      RewardedCreditStatus.notReady => context.l10n.rewardedAdNotReady,
      RewardedCreditStatus.verificationFailed =>
        context.l10n.rewardedVerificationFailed,
      RewardedCreditStatus.limitReached => context.l10n.rewardedLimitReached,
    };
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({required this.onEarnCredit});

  final VoidCallback onEarnCredit;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_outlined, color: AppColors.interactive),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l.scanCreditRequired,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l.ocrPremiumOrCredit, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEarnCredit,
                  child: Text(l.watchAdForOneOcrCredit),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.premium),
                  child: Text(l.upgradeToPremium),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OcrMeta extends StatelessWidget {
  const _OcrMeta({
    required this.provider,
    required this.model,
    required this.language,
    required this.detectedLanguage,
    required this.confidence,
  });

  final String? provider;
  final String? model;
  final String? language;
  final String? detectedLanguage;
  final double? confidence;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SoftCard(
      child: Column(
        children: [
          _MetaRow(label: l.provider, value: provider ?? 'azure_document_intelligence'),
          const Divider(),
          _MetaRow(label: l.model, value: model ?? 'prebuilt-layout'),
          if (language != null) ...[
            const Divider(),
            _MetaRow(label: l.language, value: language!),
          ],
          if (detectedLanguage != null) ...[
            const Divider(),
            _MetaRow(label: l.ocrDetectedLanguage, value: detectedLanguage!),
          ],
          if (confidence != null) ...[
            const Divider(),
            _MetaRow(
              label: l.confidence,
              value: '${(confidence! * 100).toStringAsFixed(1)}%',
            ),
          ],
        ],
      ),
    );
  }
}

class _OcrLanguageOption {
  const _OcrLanguageOption(this.code, this.labelKey);

  final String code;
  final String labelKey;

  String label(BuildContext context) {
    final l = context.l10n;
    return switch (labelKey) {
      'autoDetect' => l.autoDetect,
      'arabic' => l.arabic,
      'english' => l.english,
      'turkish' => l.turkish,
      'french' => l.french,
      'spanish' => l.spanish,
      'german' => l.german,
      'italian' => l.italian,
      'portuguese' => l.portuguese,
      'chineseSimplified' => l.chineseSimplified,
      'chineseTraditional' => l.chineseTraditional,
      'japanese' => l.japanese,
      'korean' => l.korean,
      'hindi' => l.hindi,
      'urdu' => l.urdu,
      'indonesian' => l.indonesian,
      'malay' => l.malay,
      'russian' => l.russian,
      _ => code,
    };
  }
}

const _ocrLanguages = [
  _OcrLanguageOption('auto', 'autoDetect'),
  _OcrLanguageOption('en', 'english'),
  _OcrLanguageOption('ar', 'arabic'),
  _OcrLanguageOption('fr', 'french'),
  _OcrLanguageOption('es', 'spanish'),
  _OcrLanguageOption('de', 'german'),
  _OcrLanguageOption('tr', 'turkish'),
  _OcrLanguageOption('zh-Hans', 'chineseSimplified'),
  _OcrLanguageOption('ja', 'japanese'),
  _OcrLanguageOption('ko', 'korean'),
];

const _basicOcrLanguages = [
  _OcrLanguageOption('auto', 'autoDetect'),
  _OcrLanguageOption('en', 'english'),
];

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label)),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(color: AppColors.muted),
        ),
      ),
    ],
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, this.actionLabel, this.onAction});

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.interactive, size: 56),
        const SizedBox(height: AppSpacing.md),
        Text(title, textAlign: TextAlign.center),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    ),
  );
}
