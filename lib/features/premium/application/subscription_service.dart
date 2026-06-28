import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/config/scanleno_app_config.dart';

enum SubscriptionPlan { free, monthly, annual }

class SubscriptionState {
  const SubscriptionState({
    required this.plan,
    required this.isPremium,
    required this.lastVerifiedAt,
    this.productId,
  });

  const SubscriptionState.free()
    : plan = SubscriptionPlan.free,
      isPremium = false,
      productId = null,
      lastVerifiedAt = null;

  final SubscriptionPlan plan;
  final bool isPremium;
  final String? productId;
  final DateTime? lastVerifiedAt;

  Map<String, Object?> toJson() => {
    'plan': plan.name,
    'isPremium': isPremium,
    'productId': productId,
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
  };

  factory SubscriptionState.fromJson(Map<String, Object?> json) {
    return SubscriptionState(
      plan: SubscriptionPlan.values.byName(json['plan'] as String),
      isPremium: json['isPremium'] as bool? ?? false,
      productId: json['productId'] as String?,
      lastVerifiedAt: json['lastVerifiedAt'] == null
          ? null
          : DateTime.parse(json['lastVerifiedAt'] as String),
    );
  }
}

class SubscriptionService extends ChangeNotifier {
  SubscriptionState _state = const SubscriptionState.free();

  SubscriptionState get state => _state;
  bool get isPremium => _state.isPremium;

  Future<void> initialize() async {
    _state = await _loadLocalState();
    notifyListeners();
    await verifySubscription();
  }

  Future<void> startPurchase(SubscriptionPlan plan) async {
    final productId = switch (plan) {
      SubscriptionPlan.monthly => scanLenoConfig.monthlyProductId,
      SubscriptionPlan.annual => scanLenoConfig.annualProductId,
      SubscriptionPlan.free => null,
    };
    if (productId == null) return;

    // Store pending intent only. Official store purchase integration belongs
    // behind this service and must not hard-code secrets or product metadata.
    _state = SubscriptionState(
      plan: plan,
      isPremium: false,
      productId: productId,
      lastVerifiedAt: DateTime.now(),
    );
    await _saveLocalState(_state);
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    await verifySubscription();
  }

  Future<void> verifySubscription() async {
    // Local state is a cache only. A later backend/store verifier can replace
    // this method without changing UI code.
    _state = SubscriptionState(
      plan: _state.plan,
      isPremium: false,
      productId: _state.productId,
      lastVerifiedAt: DateTime.now(),
    );
    await _saveLocalState(_state);
    notifyListeners();
  }

  Future<SubscriptionState> _loadLocalState() async {
    if (kIsWeb) return const SubscriptionState.free();
    final file = await _file();
    if (!file.existsSync()) return const SubscriptionState.free();
    return SubscriptionState.fromJson(
      jsonDecode(await file.readAsString()) as Map<String, Object?>,
    );
  }

  Future<void> _saveLocalState(SubscriptionState state) async {
    if (kIsWeb) return;
    final file = await _file();
    await file.writeAsString(jsonEncode(state.toJson()));
  }

  Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/scanleno-subscription.json');
  }
}

final subscriptionService = SubscriptionService();
