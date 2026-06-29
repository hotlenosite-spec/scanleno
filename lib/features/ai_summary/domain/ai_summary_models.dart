enum AiSummaryLength {
  short,
  medium,
  detailed;

  String get apiValue => name;
}

enum AiSummaryLanguage {
  same,
  arabic,
  english;

  String get apiValue => switch (this) {
        AiSummaryLanguage.same => 'same',
        AiSummaryLanguage.arabic => 'ar',
        AiSummaryLanguage.english => 'en',
      };
}

class AiSummaryResult {
  const AiSummaryResult({
    required this.documentId,
    required this.pageIndex,
    required this.sourceLanguage,
    required this.summaryLanguage,
    required this.originalTextLength,
    required this.summary,
    required this.summaryLength,
    required this.provider,
    required this.model,
    required this.deployment,
    required this.createdAt,
    required this.creditConsumed,
    this.remainingScanCredit,
  });

  final String? documentId;
  final int pageIndex;
  final String? sourceLanguage;
  final String summaryLanguage;
  final int originalTextLength;
  final String summary;
  final String summaryLength;
  final String provider;
  final String model;
  final String deployment;
  final DateTime createdAt;
  final bool creditConsumed;
  final int? remainingScanCredit;

  factory AiSummaryResult.fromJson(Map<String, Object?> json) {
    return AiSummaryResult(
      documentId: json['documentId'] as String?,
      pageIndex: json['pageIndex'] as int? ?? 0,
      sourceLanguage: json['sourceLanguage'] as String?,
      summaryLanguage: json['summaryLanguage'] as String? ?? 'same',
      originalTextLength: json['originalTextLength'] as int? ?? 0,
      summary: json['summary'] as String? ?? '',
      summaryLength: json['summaryLength'] as String? ?? 'medium',
      provider: json['provider'] as String? ?? 'azure_openai',
      model: json['model'] as String? ?? 'gpt-4o-mini',
      deployment: json['deployment'] as String? ?? 'scanleno-gpt-4o-mini',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      creditConsumed: json['creditConsumed'] == true,
      remainingScanCredit: json['remainingScanCredit'] as int?,
    );
  }
}
