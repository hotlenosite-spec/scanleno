import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/config/scanleno_app_config.dart';
import '../../account/application/firebase_auth_service.dart';
import '../domain/pdf_to_excel_models.dart';

class PdfToExcelBackendException implements Exception {
  const PdfToExcelBackendException(this.code);

  final String code;
}

class PdfToExcelService {
  PdfToExcelService({
    http.Client? client,
    FirebaseAuthService? auth,
  })  : _client = client ?? http.Client(),
        _auth = auth ?? firebaseAuthService;

  final http.Client _client;
  final FirebaseAuthService _auth;

  Future<PdfToExcelResult> convert({
    required File pdfFile,
    required String documentId,
    required String fileName,
    required PdfToExcelOptions options,
  }) async {
    final token = await _auth.idToken(forceRefresh: true);
    if (token == null) {
      throw const PdfToExcelBackendException('AUTH_REQUIRED');
    }
    final bytes = await pdfFile.readAsBytes();
    final response = await _client
        .post(
          scanLenoConfig.backendUri('/api/pdf/to-excel'),
          headers: {
            'content-type': 'application/json; charset=utf-8',
            'authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'documentId': documentId,
            'fileName': fileName,
            'pdfBase64': base64Encode(bytes),
            'options': options.toJson(),
          }),
        )
        .timeout(const Duration(seconds: 120));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PdfToExcelBackendException(
        decoded['error'] as String? ?? 'PDF_TO_EXCEL_FAILED',
      );
    }
    return PdfToExcelResult.fromJson(decoded.cast<String, Object?>());
  }
}
