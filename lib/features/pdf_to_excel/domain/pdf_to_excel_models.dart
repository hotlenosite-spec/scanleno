class PdfToExcelOptions {
  const PdfToExcelOptions({
    this.includeAllTables = true,
    this.includeTextSheet = true,
    this.oneTablePerSheet = true,
    this.preserveCellText = true,
  });

  final bool includeAllTables;
  final bool includeTextSheet;
  final bool oneTablePerSheet;
  final bool preserveCellText;

  Map<String, Object?> toJson() => {
        'includeAllTables': includeAllTables,
        'includeTextSheet': includeTextSheet,
        'oneTablePerSheet': oneTablePerSheet,
        'preserveCellText': preserveCellText,
      };
}

class PdfToExcelResult {
  const PdfToExcelResult({
    required this.fileName,
    required this.mimeType,
    required this.excelBase64,
    required this.tablesCount,
    required this.pagesProcessed,
    required this.provider,
    required this.model,
    required this.createdAt,
    required this.creditConsumed,
    this.remainingScanCredit,
  });

  final String fileName;
  final String mimeType;
  final String excelBase64;
  final int tablesCount;
  final int pagesProcessed;
  final String provider;
  final String model;
  final DateTime createdAt;
  final bool creditConsumed;
  final int? remainingScanCredit;

  factory PdfToExcelResult.fromJson(Map<String, Object?> json) {
    return PdfToExcelResult(
      fileName: json['fileName'] as String? ?? 'document.xlsx',
      mimeType: json['mimeType'] as String? ??
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      excelBase64: json['excelBase64'] as String? ?? '',
      tablesCount: (json['tablesCount'] as num?)?.toInt() ?? 0,
      pagesProcessed: (json['pagesProcessed'] as num?)?.toInt() ?? 0,
      provider: json['provider'] as String? ?? 'azure_document_intelligence',
      model: json['model'] as String? ?? 'prebuilt-layout',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      creditConsumed: json['creditConsumed'] == true,
      remainingScanCredit: (json['remainingScanCredit'] as num?)?.toInt(),
    );
  }
}
