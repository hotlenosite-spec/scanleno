import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/feature_flags.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../../ads/application/ad_service.dart';
import '../../files/application/local_file_repository.dart';
import '../../premium/application/premium_access_service.dart';
import '../../premium/presentation/premium_gate_dialog.dart';
import '../application/pdf_to_excel_service.dart';
import '../domain/pdf_to_excel_models.dart';

class PdfToExcelPage extends StatefulWidget {
  const PdfToExcelPage({super.key});

  @override
  State<PdfToExcelPage> createState() => _PdfToExcelPageState();
}

class _PdfToExcelPageState extends State<PdfToExcelPage> {
  final repository = LocalFileRepository();
  final service = PdfToExcelService();

  List<StoredDocument> pdfDocuments = const [];
  StoredDocument? selectedDocument;
  File? outputFile;
  int? tablesCount;
  int? pagesProcessed;
  bool includeAllTables = true;
  bool includeTextSheet = true;
  bool oneTablePerSheet = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadPdfDocuments();
  }

  Future<void> _loadPdfDocuments() async {
    final state = await repository.load();
    if (!mounted) return;
    setState(() {
      pdfDocuments = state.documents
          .where((document) =>
              !document.isDeleted &&
              document.type == StoredDocumentType.pdf &&
              File(document.path).existsSync())
          .toList();
    });
  }

  Future<void> _convert() async {
    final document = selectedDocument;
    if (document == null || loading) return;
    final access = await premiumAccessService.canAccessPremiumFeature(
      PremiumFeature.pdfToExcel,
    );
    if (!mounted) return;
    if (!access.allowed) {
      await showPremiumGateDialog(
        context,
        feature: PremiumFeature.pdfToExcel,
        result: access,
        onEarnScanCredit: _earnCredit,
      );
      return;
    }
    setState(() => loading = true);
    try {
      final result = await service.convert(
        pdfFile: File(document.path),
        documentId: document.id,
        fileName: '${document.name}.pdf',
        options: PdfToExcelOptions(
          includeAllTables: includeAllTables,
          includeTextSheet: includeTextSheet,
          oneTablePerSheet: oneTablePerSheet,
        ),
      );
      final directory = await getApplicationDocumentsDirectory();
      final folder = Directory('${directory.path}/ScanLeno');
      if (!folder.existsSync()) await folder.create(recursive: true);
      final safeName = result.fileName.endsWith('.xlsx')
          ? result.fileName
          : '${result.fileName}.xlsx';
      final file = File('${folder.path}/$safeName');
      await file.writeAsBytes(base64Decode(result.excelBase64));
      await repository.registerFiles(
        files: [file],
        type: StoredDocumentType.xlsx,
        pageCount: result.pagesProcessed == 0 ? 1 : result.pagesProcessed,
        originalDocumentId: document.id,
        outputType: 'xlsx',
        conversionType: 'pdf_to_excel',
        conversionProvider: result.provider,
        conversionModel: result.model,
        tablesCount: result.tablesCount,
        pagesProcessed: result.pagesProcessed,
      );
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
      if (!mounted) return;
      setState(() {
        outputFile = file;
        tablesCount = result.tablesCount;
        pagesProcessed = result.pagesProcessed;
      });
      _snack(context.l10n.pdfToExcelComplete);
    } on PdfToExcelBackendException catch (error) {
      if (!mounted) return;
      await _handleBackendError(error.code);
    } catch (_) {
      if (mounted) _snack(context.l10n.pdfToExcelFailed);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _handleBackendError(String code) async {
    if (code == 'PREMIUM_REQUIRED' || code == 'PDF_TO_EXCEL_CREDIT_REQUIRED') {
      final access = await premiumAccessService.canAccessPremiumFeature(
        PremiumFeature.pdfToExcel,
      );
      if (!mounted) return;
      await showPremiumGateDialog(
        context,
        feature: PremiumFeature.pdfToExcel,
        result: access.copyWith(
          allowed: false,
          requiresPremium: code == 'PREMIUM_REQUIRED',
          canUseScanCredit: code == 'PDF_TO_EXCEL_CREDIT_REQUIRED',
          messageKey: 'premiumRequiredForPdfToExcel',
        ),
        onEarnScanCredit: _earnCredit,
      );
      return;
    }
    final l = context.l10n;
    final message = switch (code) {
      'PDF_TO_EXCEL_DISABLED' => l.pdfToExcelDisabled,
      'INVALID_FILE' || 'FILE_TOO_LARGE' => l.invalidPdfFile,
      'RATE_LIMITED' || 'PDF_TO_EXCEL_LIMIT_REACHED' => l.pdfToExcelRateLimited,
      'AUTH_REQUIRED' => l.signIn,
      _ => l.pdfToExcelFailed,
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

  Future<void> _shareOutput() async {
    final file = outputFile;
    if (file == null) return;
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], title: file.uri.pathSegments.last),
    );
  }

  Future<void> _openOutput() async {
    final file = outputFile;
    if (file == null) return;
    final uri = Uri.file(file.path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      _snack(context.l10n.openFileUnavailable);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (!FeatureFlags.pdfToExcelEnabled) {
      return AppScreen(
        title: l.pdfToExcel,
        showBack: true,
        child: Center(child: SoftCard(child: Text(l.pdfToExcelDisabled))),
      );
    }
    return AppScreen(
      title: l.pdfToExcel,
      showBack: true,
      bottomAction: outputFile == null
          ? null
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openOutput,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(l.open),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _shareOutput,
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(l.share),
                  ),
                ),
              ],
            ),
      child: ListView(
        children: [
          Text(l.selectPdfFile, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          if (pdfDocuments.isEmpty)
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.noPdfFilesYet),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.files),
                    icon: const Icon(Icons.folder_outlined),
                    label: Text(l.myFiles),
                  ),
                ],
              ),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: selectedDocument?.id,
              decoration: InputDecoration(labelText: l.pdfDocument),
              items: [
                for (final document in pdfDocuments)
                  DropdownMenuItem(
                    value: document.id,
                    child: Text(document.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (id) {
                final document = id == null
                    ? null
                    : pdfDocuments.firstWhere((item) => item.id == id);
                setState(() {
                  selectedDocument = document;
                  outputFile = null;
                  tablesCount = null;
                  pagesProcessed = null;
                });
              },
            ),
          if (selectedDocument != null) ...[
            const SizedBox(height: AppSpacing.md),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(selectedDocument!.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${selectedDocument!.pageCount} ${l.pagesUnit}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _OptionSwitch(
            title: l.extractAllTables,
            value: includeAllTables,
            onChanged: (value) => setState(() => includeAllTables = value),
          ),
          _OptionSwitch(
            title: l.oneTablePerSheet,
            value: oneTablePerSheet,
            onChanged: (value) => setState(() => oneTablePerSheet = value),
          ),
          _OptionSwitch(
            title: l.includeTextSheet,
            value: includeTextSheet,
            onChanged: (value) => setState(() => includeTextSheet = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: selectedDocument == null || loading ? null : _convert,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.table_chart_outlined),
            label: Text(loading ? l.loading : l.convertToExcel),
          ),
          if (outputFile != null) ...[
            const SizedBox(height: AppSpacing.lg),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.pdfToExcelComplete,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${l.tablesExtracted}: ${tablesCount ?? 0}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  Text(
                    '${l.pagesProcessed}: ${pagesProcessed ?? 0}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionSwitch extends StatelessWidget {
  const _OptionSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SoftCard(
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
