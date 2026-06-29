class PdfToWordOptions {
  const PdfToWordOptions({
    this.preserveParagraphs = true,
    this.includeTables = true,
    this.includePageBreaks = true,
    this.includeHeadings = true,
    this.outputLanguageDirection = 'auto',
  });

  final bool preserveParagraphs;
  final bool includeTables;
  final bool includePageBreaks;
  final bool includeHeadings;
  final String outputLanguageDirection;

  Map<String, Object?> toJson() => {
        'preserveParagraphs': preserveParagraphs,
        'includeTables': includeTables,
        'includePageBreaks': includePageBreaks,
        'includeHeadings': includeHeadings,
        'outputLanguageDirection': outputLanguageDirection,
      };
}

class PdfToWordResult {
  const PdfToWordResult({
    required this.fileName,
    required this.mimeType,
    required this.docxBase64,
    required this.pagesProcessed,
    required this.paragraphsCount,
    required this.tablesCount,
    required this.provider,
    required this.model,
    required this.createdAt,
    required this.creditConsumed,
    this.remainingScanCredit,
  });

  final String fileName;
  final String mimeType;
  final String docxBase64;
  final int pagesProcessed;
  final int paragraphsCount;
  final int tablesCount;
  final String provider;
  final String model;
  final DateTime createdAt;
  final bool creditConsumed;
  final int? remainingScanCredit;

  factory PdfToWordResult.fromJson(Map<String, Object?> json) {
    return PdfToWordResult(
      fileName: json['fileName'] as String? ?? 'document.docx',
      mimeType: json['mimeType'] as String? ??
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      docxBase64: json['docxBase64'] as String? ?? '',
      pagesProcessed: (json['pagesProcessed'] as num?)?.toInt() ?? 0,
      paragraphsCount: (json['paragraphsCount'] as num?)?.toInt() ?? 0,
      tablesCount: (json['tablesCount'] as num?)?.toInt() ?? 0,
      provider: json['provider'] as String? ?? 'azure_document_intelligence',
      model: json['model'] as String? ?? 'prebuilt-layout',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      creditConsumed: json['creditConsumed'] == true,
      remainingScanCredit: (json['remainingScanCredit'] as num?)?.toInt(),
    );
  }
}
