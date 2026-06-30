import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/config/scanleno_app_config.dart';
import '../../account/application/firebase_auth_service.dart';

class OcrBackendException implements Exception {
  const OcrBackendException(this.code);

  final String code;
}

class OcrResult {
  const OcrResult({
    required this.documentId,
    required this.pageIndex,
    required this.text,
    required this.lines,
    required this.words,
    required this.provider,
    required this.model,
    required this.createdAt,
    this.language,
    this.detectedLanguage,
    this.languageHint,
    this.confidence,
    this.creditConsumed = false,
    this.remainingScanCredit,
  });

  final String documentId;
  final int pageIndex;
  final String text;
  final List<String> lines;
  final List<String> words;
  final String provider;
  final String model;
  final DateTime createdAt;
  final String? language;
  final String? detectedLanguage;
  final String? languageHint;
  final double? confidence;
  final bool creditConsumed;
  final int? remainingScanCredit;

  factory OcrResult.fromJson(Map<String, Object?> json) => OcrResult(
    documentId: json['documentId'] as String? ?? '',
    pageIndex: json['pageIndex'] as int? ?? 0,
    text: json['text'] as String? ?? '',
    lines: (json['lines'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList(growable: false),
    words: (json['words'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList(growable: false),
    provider: json['provider'] as String? ?? 'azure_document_intelligence',
    model: json['model'] as String? ?? 'prebuilt-layout',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.now(),
    language: json['language'] as String?,
    detectedLanguage: json['detectedLanguage'] as String?,
    languageHint: json['languageHint'] as String?,
    confidence: (json['confidence'] as num?)?.toDouble(),
    creditConsumed: json['creditConsumed'] as bool? ?? false,
    remainingScanCredit: (json['remainingScanCredit'] as num?)?.toInt(),
  );
}

class OcrBackendService {
  OcrBackendService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<OcrResult> analyzePage({
    required String documentId,
    required int pageIndex,
    required File imageFile,
    required bool isPremium,
    required bool scanCreditAvailable,
    String languageHint = 'auto',
    String model = 'read',
    bool detectLanguage = true,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final headers = {'content-type': 'application/json; charset=utf-8'};
    final token = await firebaseAuthService.idToken(forceRefresh: true);
    if (token != null) headers['authorization'] = 'Bearer $token';
    final response = await _client
        .post(
          _uri('/api/ocr/analyze'),
          headers: headers,
          body: jsonEncode({
            'documentId': documentId,
            'pageIndex': pageIndex,
            'imageBase64': base64Encode(bytes),
            'mimeType': _mimeType(imageFile.path),
            'languageHint': languageHint,
            'model': model,
            'detectLanguage': detectLanguage,
            // Kept only for backward compatibility with older local backends.
            // Current production backend verifies entitlement from Firebase token
            // and backend user metadata, not from these client-provided values.
            'userPlan': isPremium ? 'premium' : 'free',
            'scanCreditAvailable': scanCreditAvailable,
          }),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OcrBackendException(_errorCode(response));
    }
    return OcrResult.fromJson(
      (jsonDecode(response.body) as Map<String, dynamic>).cast<String, Object?>(),
    );
  }

  Uri _uri(String path) {
    return scanLenoConfig.backendUri(path);
  }

  String _mimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  String _errorCode(http.Response response) {
    String? backendCode;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        backendCode = decoded['error']?.toString();
      }
    } catch (_) {
      backendCode = null;
    }
    return switch (backendCode) {
      'AUTH_REQUIRED' => 'auth_required',
      'PREMIUM_REQUIRED' => 'premium_required',
      'OCR_CREDIT_REQUIRED' => 'ocr_credit_required',
      'OCR_DISABLED' => 'ocr_disabled',
      'AZURE_OCR_FAILED' => 'azure_ocr_failed',
      'OCR_LANGUAGE_NOT_SUPPORTED' => 'ocr_language_not_supported',
      'UNSUPPORTED_LANGUAGE' => 'ocr_language_not_supported',
      'INVALID_OCR_MODEL' => 'invalid_ocr_model',
      'RATE_LIMITED' => 'ocr_rate_limited',
      'AZURE_KEY_MISSING' || 'AZURE_ENDPOINT_MISSING' => 'ocr_unavailable',
      _ when response.statusCode == 401 => 'auth_required',
      _ when response.statusCode == 403 => 'premium_required',
      _ when response.statusCode == 429 => 'ocr_rate_limited',
      _ => 'ocr_failed',
    };
  }
}
