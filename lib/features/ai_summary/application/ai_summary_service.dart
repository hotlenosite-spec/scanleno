import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/scanleno_app_config.dart';
import '../../account/application/firebase_auth_service.dart';
import '../domain/ai_summary_models.dart';

class AiSummaryBackendException implements Exception {
  const AiSummaryBackendException(this.code);

  final String code;
}

class AiSummaryService {
  AiSummaryService({
    http.Client? client,
    FirebaseAuthService? auth,
  })  : _client = client ?? http.Client(),
        _auth = auth ?? firebaseAuthService;

  final http.Client _client;
  final FirebaseAuthService _auth;

  Future<AiSummaryResult> summarizeText({
    required String text,
    required AiSummaryLength summaryLength,
    required AiSummaryLanguage language,
    String? documentId,
    int pageIndex = 0,
    String? sourceLanguage,
    bool fromOcr = false,
  }) async {
    final token = await _auth.idToken(forceRefresh: true);
    if (token == null) throw const AiSummaryBackendException('AUTH_REQUIRED');
    final response = await _client
        .post(
          scanLenoConfig.backendUri(
            fromOcr ? '/api/ai/summary-from-ocr' : '/api/ai/summary',
          ),
          headers: {
            'content-type': 'application/json; charset=utf-8',
            'authorization': 'Bearer $token',
          },
          body: jsonEncode({
            fromOcr ? 'ocrText' : 'text': text,
            'documentId': documentId,
            'pageIndex': pageIndex,
            'sourceLanguage': sourceLanguage,
            'summaryLength': summaryLength.apiValue,
            'language': language.apiValue,
          }),
        )
        .timeout(const Duration(seconds: 55));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiSummaryBackendException(
        decoded['error'] as String? ?? 'AI_SUMMARY_FAILED',
      );
    }
    return AiSummaryResult.fromJson(decoded.cast<String, Object?>());
  }
}
