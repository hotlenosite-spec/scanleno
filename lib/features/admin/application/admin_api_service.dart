import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/scanleno_app_config.dart';
import '../../account/application/firebase_auth_service.dart';

class AdminApiException implements Exception {
  const AdminApiException(this.message);

  final String message;
}

class AdminOverview {
  const AdminOverview({
    required this.settings,
    required this.featureFlags,
    required this.stats,
    required this.users,
    required this.supportTickets,
    required this.appErrors,
    required this.subscriptions,
  });

  final Map<String, Object?> settings;
  final Map<String, Object?> featureFlags;
  final Map<String, Object?> stats;
  final List<Map<String, Object?>> users;
  final List<Map<String, Object?>> supportTickets;
  final List<Map<String, Object?>> appErrors;
  final Map<String, Object?> subscriptions;
}

class AdminApiService {
  AdminApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) {
    final base = scanLenoConfig.backendBaseUrl.trim().isEmpty
        ? 'http://localhost:8787'
        : scanLenoConfig.backendBaseUrl.trim();
    return Uri.parse(base).resolve(path);
  }

  Future<AdminOverview> loadOverview() async {
    try {
      final responses = await Future.wait([
        _getMap('/api/settings'),
        _getMap('/api/feature-flags'),
        _getMap('/api/stats'),
        _getList('/api/users'),
        _getList('/api/support-tickets'),
        _getList('/api/app-errors'),
        _getMap('/api/subscriptions'),
      ]);
      return AdminOverview(
        settings: responses[0] as Map<String, Object?>,
        featureFlags: responses[1] as Map<String, Object?>,
        stats: responses[2] as Map<String, Object?>,
        users: responses[3] as List<Map<String, Object?>>,
        supportTickets: responses[4] as List<Map<String, Object?>>,
        appErrors: responses[5] as List<Map<String, Object?>>,
        subscriptions: responses[6] as Map<String, Object?>,
      );
    } catch (_) {
      throw const AdminApiException('server_unreachable');
    }
  }

  Future<Map<String, Object?>> saveFeatureFlags(
    Map<String, Object?> flags,
  ) async {
    return _putMap('/api/feature-flags', flags);
  }

  Future<Map<String, Object?>> saveSettings(Map<String, Object?> settings) {
    return _putMap('/api/settings', settings);
  }

  Future<Map<String, Object?>> createSupportTicket(String message) {
    return _postMap('/api/support-tickets', {'message': message});
  }

  Future<Map<String, Object?>> updateSupportTicket(
    String id,
    String status,
  ) {
    return _putMap('/api/support-tickets/$id', {'status': status});
  }

  Future<Map<String, Object?>> updateUser(
    String uid,
    Map<String, Object?> changes,
  ) {
    return _putMap('/api/users/$uid', changes);
  }

  Future<Map<String, Object?>> verifySubscription() {
    return _postMap('/api/subscription/verify', const {});
  }

  Future<Map<String, Object?>> _getMap(String path) async {
    final response = await _client.get(_uri(path), headers: await _headers());
    return _decodeMap(response);
  }

  Future<List<Map<String, Object?>>> _getList(String path) async {
    final response = await _client.get(_uri(path), headers: await _headers());
    final decoded = _decode(response);
    return (decoded as List<dynamic>)
        .cast<Map<String, Object?>>()
        .toList(growable: false);
  }

  Future<Map<String, Object?>> _postMap(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _client.post(
      _uri(path),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decodeMap(response);
  }

  Future<Map<String, Object?>> _putMap(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _client.put(
      _uri(path),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decodeMap(response);
  }

  Map<String, Object?> _decodeMap(http.Response response) {
    return (_decode(response) as Map<String, dynamic>).cast<String, Object?>();
  }

  Object? _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AdminApiException('http_${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  Future<Map<String, String>> _headers() async {
    final headers = {'content-type': 'application/json; charset=utf-8'};
    final token = await firebaseAuthService.idToken(forceRefresh: true);
    if (token != null) headers['authorization'] = 'Bearer $token';
    return headers;
  }
}
