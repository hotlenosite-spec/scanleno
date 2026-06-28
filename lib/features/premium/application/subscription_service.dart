import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/config/scanleno_app_config.dart';
import '../../account/application/firebase_auth_service.dart';
import '../../files/application/local_file_repository.dart';

enum SubscriptionPlan { free, monthly, annual }

enum SubscriptionStatus {
  free,
  premiumMonthly,
  premiumYearly,
  pendingVerification,
  expired,
  unavailable,
  error,
}

class SubscriptionState {
  const SubscriptionState({
    required this.isPremium,
    required this.plan,
    required this.productId,
    required this.platform,
    required this.expiresAt,
    required this.verified,
    required this.source,
    required this.status,
    required this.reason,
    required this.lastVerifiedAt,
  });

  const SubscriptionState.free()
      : isPremium = false,
        plan = SubscriptionPlan.free,
        productId = null,
        platform = null,
        expiresAt = null,
        verified = false,
        source = 'local_cache',
        status = SubscriptionStatus.free,
        reason = null,
        lastVerifiedAt = null;

  final bool isPremium;
  final SubscriptionPlan plan;
  final String? productId;
  final String? platform;
  final DateTime? expiresAt;
  final bool verified;
  final String source;
  final SubscriptionStatus status;
  final String? reason;
  final DateTime? lastVerifiedAt;

  Map<String, Object?> toJson() => {
        'isPremium': isPremium,
        'plan': plan.name,
        'productId': productId,
        'platform': platform,
        'expiresAt': expiresAt?.toIso8601String(),
        'verified': verified,
        'source': source,
        'status': status.name,
        'reason': reason,
        'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
      };

  factory SubscriptionState.fromJson(Map<String, Object?> json) {
    return SubscriptionState(
      isPremium: json['isPremium'] as bool? ?? false,
      plan: _planFromName(json['plan'] as String?),
      productId: json['productId'] as String?,
      platform: json['platform'] as String?,
      expiresAt: _date(json['expiresAt']),
      verified: json['verified'] as bool? ?? false,
      source: json['source'] as String? ?? 'local_cache',
      status: _statusFromName(json['status'] as String?),
      reason: json['reason'] as String?,
      lastVerifiedAt: _date(json['lastVerifiedAt']),
    );
  }

  static DateTime? _date(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static SubscriptionPlan _planFromName(String? value) {
    return SubscriptionPlan.values.firstWhere(
      (item) => item.name == value,
      orElse: () => SubscriptionPlan.free,
    );
  }

  static SubscriptionStatus _statusFromName(String? value) {
    return SubscriptionStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => SubscriptionStatus.free,
    );
  }
}

class SubscriptionService extends ChangeNotifier {
  SubscriptionService({
    InAppPurchase? inAppPurchase,
    http.Client? client,
    LocalFileRepository? repository,
    FirebaseAuthService? auth,
  })  : _iap = inAppPurchase ?? InAppPurchase.instance,
        _client = client ?? http.Client(),
        _repository = repository ?? LocalFileRepository(),
        _auth = auth ?? firebaseAuthService;

  static const monthlyProductId = 'scanleno_premium_monthly';
  static const yearlyProductId = 'scanleno_premium_yearly';
  static const productIds = {monthlyProductId, yearlyProductId};

  final InAppPurchase _iap;
  final http.Client _client;
  final LocalFileRepository _repository;
  final FirebaseAuthService _auth;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  final Map<String, ProductDetails> _products = {};
  SubscriptionState _state = const SubscriptionState.free();
  bool _initialized = false;

  SubscriptionState get state => _state;
  bool get isPremium => _state.isPremium && _state.verified;
  bool get storeAvailable => _storeAvailable;
  bool get productsLoaded => _products.isNotEmpty;
  bool get isLoadingProducts => _loadingProducts;

  bool _storeAvailable = false;
  bool _loadingProducts = false;

  ProductDetails? productForPlan(SubscriptionPlan plan) {
    return _products[_productIdForPlan(plan)];
  }

  String? priceForPlan(SubscriptionPlan plan) => productForPlan(plan)?.price;

  bool productAvailable(SubscriptionPlan plan) => productForPlan(plan) != null;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _state = await _loadLocalState();
    listenToPurchaseUpdates();
    notifyListeners();
    await loadProducts();
    await getCurrentSubscriptionStatus();
  }

  Future<void> loadProducts() async {
    if (!_supportsStorePurchases) {
      _storeAvailable = false;
      _state = _nonPremiumState(
        status: SubscriptionStatus.unavailable,
        reason: 'platform_not_supported',
      );
      await _saveLocalState(_state);
      notifyListeners();
      return;
    }

    _loadingProducts = true;
    notifyListeners();
    try {
      _storeAvailable = await _iap.isAvailable();
      if (!_storeAvailable) {
        _state = _nonPremiumState(
          status: SubscriptionStatus.unavailable,
          reason: 'store_not_ready',
        );
        await _saveLocalState(_state);
        return;
      }
      final response = await _iap.queryProductDetails(productIds);
      _products
        ..clear()
        ..addEntries(
          response.productDetails.map((product) => MapEntry(product.id, product)),
        );
      if (_products.isEmpty) {
        _state = _nonPremiumState(
          status: SubscriptionStatus.unavailable,
          reason: 'products_not_found',
        );
        await _saveLocalState(_state);
      }
    } catch (_) {
      _state = _nonPremiumState(
        status: SubscriptionStatus.error,
        reason: 'product_load_failed',
      );
      await _saveLocalState(_state);
    } finally {
      _loadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> purchaseMonthly() => startPurchase(SubscriptionPlan.monthly);

  Future<void> purchaseYearly() => startPurchase(SubscriptionPlan.annual);

  Future<void> startPurchase(SubscriptionPlan plan) async {
    await initialize();
    final product = productForPlan(plan);
    if (product == null) {
      _state = _nonPremiumState(
        status: SubscriptionStatus.unavailable,
        reason: 'product_not_available',
      );
      await _saveLocalState(_state);
      notifyListeners();
      return;
    }
    final params = PurchaseParam(productDetails: product);
    _state = SubscriptionState(
      isPremium: false,
      plan: plan,
      productId: product.id,
      platform: _platformName,
      expiresAt: null,
      verified: false,
      source: 'store',
      status: SubscriptionStatus.pendingVerification,
      reason: 'purchase_started',
      lastVerifiedAt: DateTime.now(),
    );
    await _saveLocalState(_state);
    notifyListeners();
    await _iap.buyNonConsumable(purchaseParam: params);
  }

  void listenToPurchaseUpdates() {
    _purchaseSubscription ??= _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) => _setError('purchase_stream_failed'),
    );
  }

  Future<void> restorePurchases() async {
    await initialize();
    if (!_supportsStorePurchases || !_storeAvailable) {
      _state = _nonPremiumState(
        status: SubscriptionStatus.unavailable,
        reason: 'store_not_ready',
      );
      await _saveLocalState(_state);
      notifyListeners();
      return;
    }
    _state = _nonPremiumState(
      status: SubscriptionStatus.pendingVerification,
      reason: 'restore_started',
    );
    await _saveLocalState(_state);
    notifyListeners();
    await _iap.restorePurchases();
  }

  Future<SubscriptionState> verifyPurchaseWithBackend(
    PurchaseDetails purchase,
  ) async {
    final token = await _auth.idToken(forceRefresh: true);
    if (token == null) {
      _state = _pendingState(purchase, reason: 'auth_required');
      await _saveLocalState(_state);
      notifyListeners();
      return _state;
    }
    try {
      final response = await _client
          .post(
            _backendUri('/api/subscriptions/verify'),
            headers: {
              'content-type': 'application/json; charset=utf-8',
              'authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'platform': _platformName,
              'productId': purchase.productID,
              'purchaseId': purchase.purchaseID,
              'transactionDate': purchase.transactionDate,
              'verificationData': {
                'source': purchase.verificationData.source,
                'localVerificationData':
                    purchase.verificationData.localVerificationData,
                'serverVerificationData':
                    purchase.verificationData.serverVerificationData,
              },
            }),
          )
          .timeout(const Duration(seconds: 20));
      final decoded = _decodeMap(response.body);
      _state = _stateFromBackend(decoded, purchase.productID);
      await _saveLocalState(_state);
      notifyListeners();
      return _state;
    } catch (_) {
      _state = _pendingState(purchase, reason: 'backend_unavailable');
      await _saveLocalState(_state);
      notifyListeners();
      return _state;
    }
  }

  Future<SubscriptionState> getCurrentSubscriptionStatus() async {
    final token = await _auth.idToken();
    if (token == null) return _state;
    try {
      final response = await _client
          .get(
            _backendUri('/api/subscriptions/status'),
            headers: {'authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _state;
      }
      _state = _stateFromBackend(_decodeMap(response.body), _state.productId);
      await _saveLocalState(_state);
      notifyListeners();
    } catch (_) {
      // Keep the last non-authoritative cache for UI only.
    }
    return _state;
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    var foundKnownPurchase = false;
    for (final purchase in purchases) {
      if (!productIds.contains(purchase.productID)) continue;
      foundKnownPurchase = true;
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _state = _pendingState(purchase, reason: 'purchase_pending');
          await _saveLocalState(_state);
          notifyListeners();
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await verifyPurchaseWithBackend(purchase);
        case PurchaseStatus.error:
          await _setError(purchase.error?.code ?? 'purchase_failed');
        case PurchaseStatus.canceled:
          _state = _nonPremiumState(
            status: SubscriptionStatus.free,
            reason: 'purchase_cancelled',
          );
          await _saveLocalState(_state);
          notifyListeners();
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    if (!foundKnownPurchase &&
        _state.status == SubscriptionStatus.pendingVerification &&
        _state.reason == 'restore_started') {
      _state = _nonPremiumState(
        status: SubscriptionStatus.free,
        reason: 'restore_nothing_found',
      );
      await _saveLocalState(_state);
      notifyListeners();
    }
  }

  Future<void> _setError(String reason) async {
    _state = _nonPremiumState(status: SubscriptionStatus.error, reason: reason);
    await _saveLocalState(_state);
    notifyListeners();
  }

  SubscriptionState _pendingState(PurchaseDetails purchase, {required String reason}) {
    return SubscriptionState(
      isPremium: false,
      plan: _planForProductId(purchase.productID),
      productId: purchase.productID,
      platform: _platformName,
      expiresAt: null,
      verified: false,
      source: 'store',
      status: SubscriptionStatus.pendingVerification,
      reason: reason,
      lastVerifiedAt: DateTime.now(),
    );
  }

  SubscriptionState _nonPremiumState({
    required SubscriptionStatus status,
    required String reason,
  }) {
    return SubscriptionState(
      isPremium: false,
      plan: SubscriptionPlan.free,
      productId: null,
      platform: _platformName,
      expiresAt: null,
      verified: false,
      source: 'store',
      status: status,
      reason: reason,
      lastVerifiedAt: DateTime.now(),
    );
  }

  SubscriptionState _stateFromBackend(
    Map<String, Object?> json,
    String? fallbackProductId,
  ) {
    final verified = json['verified'] == true;
    final active = json['active'] == true || json['isPremium'] == true;
    final productId = json['productId'] as String? ?? fallbackProductId;
    final plan = _planForProductId(productId);
    return SubscriptionState(
      isPremium: verified && active,
      plan: verified && active ? plan : SubscriptionPlan.free,
      productId: productId,
      platform: json['platform'] as String? ?? _platformName,
      expiresAt: SubscriptionState._date(json['expiresAt']),
      verified: verified,
      source: json['source'] as String? ?? 'backend',
      status: _statusFromBackend(json, productId),
      reason: json['reason'] as String? ?? json['error'] as String?,
      lastVerifiedAt: DateTime.now(),
    );
  }

  SubscriptionStatus _statusFromBackend(
    Map<String, Object?> json,
    String? productId,
  ) {
    final status = json['status'] as String?;
    if (json['verified'] == true &&
        (json['active'] == true || json['isPremium'] == true)) {
      return productId == yearlyProductId
          ? SubscriptionStatus.premiumYearly
          : SubscriptionStatus.premiumMonthly;
    }
    return switch (status) {
      'premiumMonthly' => SubscriptionStatus.premiumMonthly,
      'premiumYearly' || 'premiumAnnual' => SubscriptionStatus.premiumYearly,
      'pendingVerification' || 'verificationNotConfigured' =>
        SubscriptionStatus.pendingVerification,
      'expired' => SubscriptionStatus.expired,
      'unavailable' => SubscriptionStatus.unavailable,
      'error' => SubscriptionStatus.error,
      _ => SubscriptionStatus.free,
    };
  }

  Future<SubscriptionState> _loadLocalState() async {
    final raw = await _repository.getSetting('subscription_state');
    if (raw == null || raw.isEmpty) return const SubscriptionState.free();
    try {
      return SubscriptionState.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );
    } catch (_) {
      return const SubscriptionState.free();
    }
  }

  Future<void> _saveLocalState(SubscriptionState state) async {
    await _repository.saveSetting('subscription_state', jsonEncode(state.toJson()));
  }

  Map<String, Object?> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded.cast<String, Object?>();
    return const {};
  }

  String? _productIdForPlan(SubscriptionPlan plan) {
    return switch (plan) {
      SubscriptionPlan.monthly => scanLenoConfig.monthlyProductId,
      SubscriptionPlan.annual => scanLenoConfig.annualProductId,
      SubscriptionPlan.free => null,
    };
  }

  SubscriptionPlan _planForProductId(String? productId) {
    return switch (productId) {
      monthlyProductId => SubscriptionPlan.monthly,
      yearlyProductId => SubscriptionPlan.annual,
      _ => SubscriptionPlan.free,
    };
  }

  bool get _supportsStorePurchases {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => defaultTargetPlatform.name,
    };
  }

  Uri _backendUri(String path) {
    return scanLenoConfig.backendUri(path);
  }
}

final subscriptionService = SubscriptionService();
