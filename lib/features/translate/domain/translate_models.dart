class TranslateLanguage {
  const TranslateLanguage({required this.code, required this.name});

  final String code;
  final String name;

  factory TranslateLanguage.fromJson(Map<String, Object?> json) {
    return TranslateLanguage(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class TranslateResult {
  const TranslateResult({
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.translatedText,
    required this.provider,
    required this.createdAt,
    required this.creditConsumed,
    this.remainingScanCredit,
  });

  final String? sourceLanguage;
  final String targetLanguage;
  final String translatedText;
  final String provider;
  final DateTime createdAt;
  final bool creditConsumed;
  final int? remainingScanCredit;

  factory TranslateResult.fromJson(Map<String, Object?> json) {
    return TranslateResult(
      sourceLanguage: json['sourceLanguage'] as String?,
      targetLanguage: json['targetLanguage'] as String? ?? '',
      translatedText: json['translatedText'] as String? ?? '',
      provider: json['provider'] as String? ?? 'azure_translator',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      creditConsumed: json['creditConsumed'] == true,
      remainingScanCredit: json['remainingScanCredit'] as int?,
    );
  }
}
