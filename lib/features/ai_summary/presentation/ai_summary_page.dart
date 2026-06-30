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
import '../application/ai_summary_service.dart';
import '../domain/ai_summary_models.dart';

class AiSummaryPage extends StatefulWidget {
  const AiSummaryPage({super.key});

  @override
  State<AiSummaryPage> createState() => _AiSummaryPageState();
}

class _AiSummaryPageState extends State<AiSummaryPage> {
  final inputController = TextEditingController();
  final summaryController = TextEditingController();
  final repository = LocalFileRepository();
  final service = AiSummaryService();

  List<StoredDocument> ocrDocuments = const [];
  StoredDocument? selectedDocument;
  AiSummaryLanguage summaryLanguage = AiSummaryLanguage.same;
  AiSummaryLength summaryLength = AiSummaryLength.medium;
  bool loading = false;
  bool originalExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadOcrDocuments();
  }

  @override
  void dispose() {
    inputController.dispose();
    summaryController.dispose();
    super.dispose();
  }

  Future<void> _loadOcrDocuments() async {
    final documents = await repository.documentsWithOcrText();
    if (!mounted) return;
    setState(() => ocrDocuments = documents);
  }

  Future<void> _summarize() async {
    final text = inputController.text.trim();
    if (text.isEmpty || loading) return;
    final access = await premiumAccessService.canAccessPremiumFeature(
      PremiumFeature.aiSummary,
    );
    if (!mounted) return;
    if (!access.allowed) {
      await showPremiumGateDialog(
        context,
        feature: PremiumFeature.aiSummary,
        result: access,
        onEarnScanCredit: _earnCredit,
      );
      return;
    }
    setState(() => loading = true);
    try {
      final result = await service.summarizeText(
        text: text,
        summaryLength: summaryLength,
        language: summaryLanguage,
        documentId: selectedDocument?.id,
        pageIndex: selectedDocument?.ocrPageIndex ?? 0,
        sourceLanguage: selectedDocument?.ocrLanguage,
        fromOcr: selectedDocument != null,
      );
      summaryController.text = result.summary;
      if (selectedDocument != null) {
        await repository.saveSummary(
          documentId: selectedDocument!.id,
          pageIndex: result.pageIndex,
          sourceLanguage: result.sourceLanguage,
          summaryLanguage: result.summaryLanguage,
          sourceTextLength: result.originalTextLength,
          summaryText: result.summary,
          summaryLength: result.summaryLength,
          provider: result.provider,
          model: result.model,
          deployment: result.deployment,
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
      if (mounted) _snack(context.l10n.aiSummaryComplete);
    } on AiSummaryBackendException catch (error) {
      if (!mounted) return;
      await _handleBackendError(error.code);
    } catch (_) {
      if (mounted) _snack(context.l10n.aiSummaryFailed);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _handleBackendError(String code) async {
    if (code == 'PREMIUM_REQUIRED' || code == 'AI_SUMMARY_CREDIT_REQUIRED') {
      final access = await premiumAccessService.canAccessPremiumFeature(
        PremiumFeature.aiSummary,
      );
      if (!mounted) return;
      await showPremiumGateDialog(
        context,
        feature: PremiumFeature.aiSummary,
        result: access.copyWith(
          allowed: false,
          requiresPremium: code == 'PREMIUM_REQUIRED',
          canUseScanCredit: code == 'AI_SUMMARY_CREDIT_REQUIRED',
          messageKey: 'premiumRequiredForAiSummary',
        ),
        onEarnScanCredit: _earnCredit,
      );
      return;
    }
    final l = context.l10n;
    final message = switch (code) {
      'AI_SUMMARY_DISABLED' => l.aiSummaryDisabled,
      'INVALID_TEXT' || 'EMPTY_TEXT' => l.emptySummaryText,
      'TEXT_TOO_LONG' => l.aiSummaryTextTooLong,
      'INVALID_SUMMARY_LENGTH' => l.invalidSummaryLength,
      'UNSUPPORTED_LANGUAGE' => l.unsupportedLanguage,
      'RATE_LIMITED' || 'AI_SUMMARY_LIMIT_REACHED' => l.aiSummaryRateLimited,
      'AUTH_REQUIRED' => l.signIn,
      _ => l.aiSummaryFailed,
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
    await Clipboard.setData(ClipboardData(text: summaryController.text));
    if (mounted) _snack(context.l10n.copied);
  }

  Future<void> _share() {
    return SharePlus.instance.share(ShareParams(text: summaryController.text));
  }

  Future<void> _exportTxt() async {
    final directory = await getApplicationDocumentsDirectory();
    final folder = Directory('${directory.path}/ScanLeno');
    if (!folder.existsSync()) await folder.create(recursive: true);
    final file = File(
      '${folder.path}/summary-${DateTime.now().microsecondsSinceEpoch}.txt',
    );
    await file.writeAsString(summaryController.text);
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
    if (!FeatureFlags.aiSummaryEnabled) {
      return AppScreen(
        title: l.aiSummary,
        showBack: true,
        child: Center(child: SoftCard(child: Text(l.aiSummaryDisabled))),
      );
    }
    return AppScreen(
      title: l.aiSummary,
      showBack: true,
      bottomAction: summaryController.text.trim().isEmpty
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
      child: ListView(
        children: [
          Text(l.summarySource, style: Theme.of(context).textTheme.titleLarge),
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
                child: DropdownButtonFormField<AiSummaryLanguage>(
                  initialValue: summaryLanguage,
                  decoration: InputDecoration(labelText: l.summaryLanguage),
                  items: [
                    DropdownMenuItem(
                      value: AiSummaryLanguage.same,
                      child: Text(l.sameAsDocument),
                    ),
                    DropdownMenuItem(
                      value: AiSummaryLanguage.arabic,
                      child: Text(l.arabic),
                    ),
                    DropdownMenuItem(
                      value: AiSummaryLanguage.english,
                      child: Text(l.english),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => summaryLanguage = value);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: DropdownButtonFormField<AiSummaryLength>(
                  initialValue: summaryLength,
                  decoration: InputDecoration(labelText: l.summaryLength),
                  items: [
                    DropdownMenuItem(
                      value: AiSummaryLength.short,
                      child: Text(l.summaryShort),
                    ),
                    DropdownMenuItem(
                      value: AiSummaryLength.medium,
                      child: Text(l.summaryMedium),
                    ),
                    DropdownMenuItem(
                      value: AiSummaryLength.detailed,
                      child: Text(l.summaryDetailed),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => summaryLength = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: loading ? null : _summarize,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(l.summarize),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (summaryController.text.trim().isNotEmpty) ...[
            ExpansionTile(
              initiallyExpanded: originalExpanded,
              title: Text(l.originalText),
              onExpansionChanged: (value) =>
                  setState(() => originalExpanded = value),
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    inputController.text,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(l.summaryText, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: summaryController,
            minLines: 5,
            maxLines: 12,
            readOnly: false,
            decoration: InputDecoration(
              labelText: l.summaryText,
              alignLabelWithHint: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: summaryController.text.trim().isEmpty ? null : _copy,
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(l.copyText),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: summaryController.text.trim().isEmpty ? null : _share,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(l.share),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
