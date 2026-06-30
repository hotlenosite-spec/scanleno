import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/feature_flags.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../../ads/application/ad_service.dart';
import '../../files/application/local_file_repository.dart';
import '../../premium/application/premium_access_service.dart';
import '../../premium/presentation/premium_gate_dialog.dart';
import '../application/translate_service.dart';
import '../domain/translate_models.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  final repository = LocalFileRepository();
  final service = TranslateService();

  late Future<List<TranslateLanguage>> languagesFuture = service.languages();
  List<StoredDocument> ocrDocuments = const [];
  StoredDocument? selectedDocument;
  String fromLanguage = 'auto';
  String toLanguage = 'en';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadOcrDocuments();
  }

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    super.dispose();
  }

  Future<void> _loadOcrDocuments() async {
    final documents = await repository.documentsWithOcrText();
    if (!mounted) return;
    setState(() => ocrDocuments = documents);
  }

  Future<void> _translate() async {
    final text = inputController.text.trim();
    if (text.isEmpty || loading) return;
    final access = await premiumAccessService.canAccessPremiumFeature(
      PremiumFeature.translate,
    );
    if (!mounted) return;
    if (!access.allowed) {
      await showPremiumGateDialog(
        context,
        feature: PremiumFeature.translate,
        result: access,
        onEarnScanCredit: _earnCredit,
      );
      return;
    }
    setState(() => loading = true);
    try {
      final result = await service.translateText(
        text: text,
        fromLanguage: fromLanguage == 'auto' ? null : fromLanguage,
        toLanguage: toLanguage,
        documentId: selectedDocument?.id,
      );
      outputController.text = result.translatedText;
      if (selectedDocument != null) {
        await repository.saveTranslation(
          documentId: selectedDocument!.id,
          pageIndex: 0,
          sourceLanguage: result.sourceLanguage,
          targetLanguage: result.targetLanguage,
          sourceText: text,
          translatedText: result.translatedText,
          provider: result.provider,
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
      }
      if (mounted) _snack(context.l10n.translateComplete);
    } on TranslateBackendException catch (error) {
      if (!mounted) return;
      await _handleBackendError(error.code);
    } catch (_) {
      if (mounted) _snack(context.l10n.translateFailed);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _handleBackendError(String code) async {
    if (code == 'PREMIUM_REQUIRED' || code == 'TRANSLATE_CREDIT_REQUIRED') {
      final access = await premiumAccessService.canAccessPremiumFeature(
        PremiumFeature.translate,
      );
      if (!mounted) return;
      await showPremiumGateDialog(
        context,
        feature: PremiumFeature.translate,
        result: access.copyWith(
          allowed: false,
          requiresPremium: code == 'PREMIUM_REQUIRED',
          canUseScanCredit: code == 'TRANSLATE_CREDIT_REQUIRED',
          messageKey: 'premiumRequiredForTranslate',
        ),
        onEarnScanCredit: _earnCredit,
      );
      return;
    }
    final l = context.l10n;
    final message = switch (code) {
      'AI_TRANSLATE_DISABLED' || 'TRANSLATE_DISABLED' => l.translateDisabled,
      'INVALID_TEXT' || 'EMPTY_TEXT' => l.emptyTranslateText,
      'TEXT_TOO_LONG' => l.translateTextTooLong,
      'INVALID_LANGUAGE' || 'UNSUPPORTED_LANGUAGE' => l.unsupportedLanguage,
      'RATE_LIMITED' => l.translateRateLimited,
      'AUTH_REQUIRED' => l.signIn,
      _ => l.translateFailed,
    };
    _snack(message);
  }

  Future<void> _earnCredit() async {
    _snack(context.l10n.rewardEarnedWaitingForVerification);
    final result = await adService.showRewardedForScanCredit();
    if (!mounted) return;
    _snack(result.status == RewardedCreditStatus.granted
        ? context.l10n.rewardedCreditGranted
        : context.l10n.rewardEarnedWaitingForVerification);
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: outputController.text));
    if (mounted) _snack(context.l10n.copied);
  }

  Future<void> _share() {
    return SharePlus.instance.share(ShareParams(text: outputController.text));
  }

  Future<void> _exportTxt() async {
    final directory = await getApplicationDocumentsDirectory();
    final folder = Directory('${directory.path}/ScanLeno');
    if (!folder.existsSync()) await folder.create(recursive: true);
    final file = File(
      '${folder.path}/translation-${DateTime.now().microsecondsSinceEpoch}.txt',
    );
    await file.writeAsString(outputController.text);
    await repository.registerFiles(
      files: [file],
      type: StoredDocumentType.text,
      pageCount: 1,
    );
    if (mounted) _snack(context.l10n.textSaved);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (!FeatureFlags.translateEnabled) {
      return AppScreen(
        title: l.aiTranslate,
        showBack: true,
        child: Center(child: SoftCard(child: Text(l.translateDisabled))),
      );
    }
    return AppScreen(
      title: l.aiTranslate,
      showBack: true,
      bottomAction: outputController.text.trim().isEmpty
          ? null
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(l.share),
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
      child: FutureBuilder<List<TranslateLanguage>>(
        future: languagesFuture,
        builder: (context, snapshot) {
          final languages = snapshot.data ?? const <TranslateLanguage>[];
          return ListView(
            children: [
              Text(l.translateSource, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              if (ocrDocuments.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: selectedDocument?.id,
                  decoration: InputDecoration(labelText: l.ocrSavedText),
                  items: [
                    DropdownMenuItem(value: '', child: Text(l.manualText)),
                    for (final document in ocrDocuments)
                      DropdownMenuItem(
                        value: document.id,
                        child: Text(document.name, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (id) {
                    final document = id == null || id.isEmpty
                        ? null
                        : ocrDocuments.firstWhere((item) => item.id == id);
                    setState(() {
                      selectedDocument = document;
                      inputController.text = document?.ocrText ?? '';
                    });
                  },
                ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: inputController,
                minLines: 5,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: l.manualText,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _LanguageDropdown(
                      label: l.sourceLanguage,
                      value: fromLanguage,
                      languages: languages,
                      includeAuto: true,
                      onChanged: (value) => setState(() => fromLanguage = value),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _LanguageDropdown(
                      label: l.targetLanguage,
                      value: toLanguage,
                      languages: languages,
                      onChanged: (value) => setState(() => toLanguage = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: loading ? null : _translate,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.translate_rounded),
                label: Text(l.translate),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l.translatedText, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: outputController,
                minLines: 5,
                maxLines: 12,
                readOnly: false,
                decoration: InputDecoration(
                  labelText: l.translatedText,
                  alignLabelWithHint: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: outputController.text.trim().isEmpty ? null : _copy,
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(l.copyText),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: outputController.text.trim().isEmpty ? null : _share,
                      icon: const Icon(Icons.ios_share_rounded),
                      label: Text(l.share),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({
    required this.label,
    required this.value,
    required this.languages,
    required this.onChanged,
    this.includeAuto = false,
  });

  final String label;
  final String value;
  final List<TranslateLanguage> languages;
  final ValueChanged<String> onChanged;
  final bool includeAuto;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final values = [
      if (includeAuto) const TranslateLanguage(code: 'auto', name: 'Auto Detect'),
      ...languages,
    ];
    final safeValue = values.any((item) => item.code == value)
        ? value
        : (includeAuto ? 'auto' : values.isEmpty ? 'en' : values.first.code);
    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final language in values)
          DropdownMenuItem(
            value: language.code,
            child: Text(language.code == 'auto' ? l.autoDetect : language.name),
          ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
