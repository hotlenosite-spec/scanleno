import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/scanleno_app_config.dart';
import '../../account/application/firebase_auth_service.dart';
import '../domain/translate_models.dart';

class TranslateBackendException implements Exception {
  const TranslateBackendException(this.code);

  final String code;
}

class TranslateService {
  TranslateService({
    http.Client? client,
    FirebaseAuthService? auth,
  })  : _client = client ?? http.Client(),
        _auth = auth ?? firebaseAuthService;

  final http.Client _client;
  final FirebaseAuthService _auth;

  Future<List<TranslateLanguage>> languages() async {
    try {
      final response = await _client
          .get(scanLenoConfig.backendUri('/api/translate/languages'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _fallbackLanguages;
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final list = decoded['languages'] as List<dynamic>? ?? const [];
      return list
          .map((item) => TranslateLanguage.fromJson((item as Map).cast<String, Object?>()))
          .where((item) => item.code.isNotEmpty)
          .toList();
    } catch (_) {
      return _fallbackLanguages;
    }
  }

  Future<TranslateResult> translateText({
    required String text,
    required String? fromLanguage,
    required String toLanguage,
    String? documentId,
    int pageIndex = 0,
  }) async {
    final token = await _auth.idToken(forceRefresh: true);
    if (token == null) throw const TranslateBackendException('AUTH_REQUIRED');
    final response = await _client
        .post(
          scanLenoConfig.backendUri('/api/translate/text'),
          headers: {
            'content-type': 'application/json; charset=utf-8',
            'authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'text': text,
            'fromLanguage': fromLanguage ?? 'auto',
            'toLanguage': toLanguage,
            'documentId': documentId,
            'pageIndex': pageIndex,
          }),
        )
        .timeout(const Duration(seconds: 35));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TranslateBackendException(decoded['error'] as String? ?? 'TRANSLATE_FAILED');
    }
    return TranslateResult.fromJson(decoded.cast<String, Object?>());
  }

  static const _fallbackLanguages = [
    TranslateLanguage(code: 'ar', name: 'Arabic'),
    TranslateLanguage(code: 'en', name: 'English'),
    TranslateLanguage(code: 'tr', name: 'Turkish'),
    TranslateLanguage(code: 'fr', name: 'French'),
    TranslateLanguage(code: 'es', name: 'Spanish'),
    TranslateLanguage(code: 'de', name: 'German'),
    TranslateLanguage(code: 'zh-Hans', name: 'Chinese Simplified'),
    TranslateLanguage(code: 'ja', name: 'Japanese'),
    TranslateLanguage(code: 'ko', name: 'Korean'),
    TranslateLanguage(code: 'hi', name: 'Hindi'),
    TranslateLanguage(code: 'id', name: 'Indonesian'),
    TranslateLanguage(code: 'ur', name: 'Urdu'),
  ];
}
