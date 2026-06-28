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
    this.confidence,
    this.creditConsumed = false,
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
  final double? confidence;
  final bool creditConsumed;

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
    model: json['model'] as String? ?? 'prebuilt-read',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.now(),
    language: json['language'] as String?,
    confidence: (json['confidence'] as num?)?.toDouble(),
    creditConsumed: json['creditConsumed'] as bool? ?? false,
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
  }) async {
    final bytes = await imageFile.readAsBytes();
    final headers = {'content-type': 'application/json; charset=utf-8'};
    final token = await firebaseAuthService.idToken();
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
            'userPlan': isPremium ? 'premium' : 'free',
            'scanCreditAvailable': scanCreditAvailable,
          }),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode == 403) {
      throw const OcrBackendException('ocr_forbidden');
    }
    if (response.statusCode == 429) {
      throw const OcrBackendException('ocr_rate_limited');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const OcrBackendException('ocr_failed');
    }
    return OcrResult.fromJson(
      (jsonDecode(response.body) as Map<String, dynamic>).cast<String, Object?>(),
    );
  }

  Uri _uri(String path) {
    final base = scanLenoConfig.backendBaseUrl.trim().isEmpty
        ? 'http://localhost:8787'
        : scanLenoConfig.backendBaseUrl.trim();
    return Uri.parse(base).resolve(path);
  }

  String _mimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
