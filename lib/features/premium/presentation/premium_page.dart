import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../application/subscription_service.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  @override
  void initState() {
    super.initState();
    subscriptionService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AnimatedBuilder(
      animation: subscriptionService,
      builder: (context, _) {
        final statusMessage = _statusMessage(l, subscriptionService.state);
        return AppScreen(
          title: l.premium,
          showBack: true,
          bottomAction: OutlinedButton.icon(
            onPressed: _restorePurchases,
            icon: const Icon(Icons.restore_rounded),
            label: Text(l.subscriptionRestorePurchases),
          ),
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  borderRadius: AppRadii.large,
                  gradient: LinearGradient(
                    colors: [Color(0xFF174C93), Color(0xFF061E55)],
                  ),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.workspace_premium_outlined,
                      color: Color(0xFFFFB52C),
                      size: 52,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l.upgradeToPremium,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l.premiumDescription,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _StatusCard(message: statusMessage),
              const SizedBox(height: AppSpacing.lg),
              _PlanCard(
                title: l.freePlan,
                price: l.premiumPriceUnavailable,
                features: [
                  l.premiumFreeFeature1,
                  l.premiumFreeFeature2,
                  l.premiumFreeFeature3,
                ],
                selected: !subscriptionService.isPremium,
                enabled: false,
                onPressed: null,
              ),
              const SizedBox(height: AppSpacing.md),
              _PlanCard(
                title: l.premiumMonthlyPlan,
                price: subscriptionService.priceForPlan(SubscriptionPlan.monthly) ??
                    l.premiumPriceUnavailable,
                features: [
                  l.premiumFeature1,
                  l.premiumFeature2,
                  l.premiumFeature3,
                ],
                selected: subscriptionService.state.status ==
                    SubscriptionStatus.premiumMonthly,
                enabled: subscriptionService.productAvailable(
                  SubscriptionPlan.monthly,
                ),
                onPressed: () => _purchase(SubscriptionPlan.monthly),
              ),
              const SizedBox(height: AppSpacing.md),
              _PlanCard(
                title: l.premiumYearlyPlan,
                price: subscriptionService.priceForPlan(SubscriptionPlan.annual) ??
                    l.premiumPriceUnavailable,
                badge: l.bestValue,
                features: [
                  l.premiumFeature1,
                  l.premiumFeature2,
                  l.premiumFeature3,
                  l.premiumFeature4,
                ],
                selected: subscriptionService.state.status ==
                    SubscriptionStatus.premiumYearly,
                enabled: subscriptionService.productAvailable(
                  SubscriptionPlan.annual,
                ),
                onPressed: () => _purchase(SubscriptionPlan.annual),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.subscriptionCached,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _purchase(SubscriptionPlan plan) async {
    await subscriptionService.startPurchase(plan);
    if (!mounted) return;
    _showSnack(_statusMessage(context.l10n, subscriptionService.state));
  }

  Future<void> _restorePurchases() async {
    await subscriptionService.restorePurchases();
    if (!mounted) return;
    final l = context.l10n;
    final reason = subscriptionService.state.reason;
    _showSnack(
      reason == 'restore_nothing_found'
          ? l.subscriptionRestoreNothingFound
          : _statusMessage(l, subscriptionService.state),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusMessage(
    ScanLenoLocalizations l,
    SubscriptionState state,
  ) {
    if (state.isPremium && state.verified) return l.subscriptionActive;
    return switch (state.status) {
      SubscriptionStatus.pendingVerification =>
        l.subscriptionVerificationPending,
      SubscriptionStatus.unavailable => switch (state.reason) {
          'products_not_found' => l.subscriptionProductsNotFound,
          'store_not_ready' => l.premiumStoreNotReady,
          'platform_not_supported' => l.subscriptionUnavailable,
          _ => l.subscriptionComingSoon,
        },
      SubscriptionStatus.expired => l.subscriptionExpired,
      SubscriptionStatus.error => l.subscriptionPurchaseFailed,
      _ => l.subscriptionComingSoon,
    };
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.interactive),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.features,
    required this.selected,
    required this.enabled,
    required this.onPressed,
    this.badge,
  });

  final String title;
  final String price;
  final List<String> features;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softTurquoise,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (selected)
                const Padding(
                  padding: EdgeInsetsDirectional.only(start: AppSpacing.sm),
                  child: Icon(Icons.check_circle, color: AppColors.accent),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            price,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: enabled ? AppColors.primary : AppColors.muted,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final feature in features)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: Text(feature)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: enabled ? onPressed : null,
              child: Text(enabled ? l.upgradeNow : l.subscriptionUnavailable),
            ),
          ),
        ],
      ),
    );
  }
}
