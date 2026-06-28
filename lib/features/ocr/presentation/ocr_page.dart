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
import '../../premium/application/subscription_service.dart';
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
  bool isPremium = false;
  int scanCredits = 0;
  String? provider;
  String? model;
  String? language;
  double? confidence;

  @override
  void initState() {
    super.initState();
    _loadAccess();
  }

  @override
  void dispose() {
    textController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAccess() async {
    await subscriptionService.initialize();
    final credits = await repository.getScanCredits();
    if (!mounted) return;
    setState(() {
      isPremium = subscriptionService.isPremium;
      scanCredits = credits;
      loadedAccess = true;
    });
  }

  Future<void> _analyze() async {
    if (!documentDraft.hasPages || loading) return;
    final freeAllowed = !FeatureFlags.ocrPremiumOnly;
    final hasCredit =
        FeatureFlags.ocrWithScanCreditEnabled && scanCredits > 0 && !isPremium;
    if (!isPremium && !freeAllowed && !hasCredit) return;

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
      final result = await ocrService.analyzePage(
        documentId: documentId,
        pageIndex: documentDraft.currentIndex,
        imageFile: pageFile,
        isPremium: isPremium,
        scanCreditAvailable: hasCredit,
      );
      textController.text = result.text;
      provider = result.provider;
      model = result.model;
      language = result.language;
      confidence = result.confidence;
      if (document != null) {
        await repository.saveOcrResult(
          documentId: document.id,
          text: result.text,
          provider: result.provider,
          model: result.model,
          createdAt: result.createdAt,
          pageIndex: result.pageIndex,
          language: result.language,
          confidence: result.confidence,
        );
      }
      if (result.creditConsumed) {
        await repository.consumeScanCredit();
        scanCredits = await repository.getScanCredits();
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.recognitionComplete)));
      }
    } on OcrBackendException catch (error) {
      if (mounted) _showError(_messageForError(error.code));
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
    await adService.showRewardedForScanCredit();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _loadAccess();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final freeAllowed = !FeatureFlags.ocrPremiumOnly;
    final canAnalyze = FeatureFlags.ocrEnabled &&
        loadedAccess &&
        documentDraft.hasPages &&
        (isPremium || freeAllowed || scanCredits > 0);
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
            else if (!isPremium && !freeAllowed && scanCredits <= 0)
              _AccessCard(onEarnCredit: _earnCredit)
            else
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
              _OcrMeta(provider: provider, model: model, language: language, confidence: confidence),
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

  String _messageForError(String code) {
    return switch (code) {
      'ocr_forbidden' => context.l10n.scanCreditRequired,
      'ocr_rate_limited' => context.l10n.ocrRateLimited,
      _ => context.l10n.ocrFailed,
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
                  child: Text(l.earnScanCredit),
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
    required this.confidence,
  });

  final String? provider;
  final String? model;
  final String? language;
  final double? confidence;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SoftCard(
      child: Column(
        children: [
          _MetaRow(label: l.provider, value: provider ?? 'azure_document_intelligence'),
          const Divider(),
          _MetaRow(label: l.model, value: model ?? 'prebuilt-read'),
          if (language != null) ...[
            const Divider(),
            _MetaRow(label: l.language, value: language!),
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
