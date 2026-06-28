import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../application/subscription_service.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AnimatedBuilder(
      animation: subscriptionService,
      builder: (context, _) => AppScreen(
        title: l.premium,
        showBack: true,
        bottomAction: OutlinedButton(
          onPressed: subscriptionService.restorePurchases,
          child: Text(l.restorePurchases),
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
            const SizedBox(height: AppSpacing.lg),
            _PlanCard(
              title: l.freePlan,
              features: [
                l.premiumFreeFeature1,
                l.premiumFreeFeature2,
                l.premiumFreeFeature3,
              ],
              selected: !subscriptionService.isPremium,
              onPressed: null,
            ),
            const SizedBox(height: AppSpacing.md),
            _PlanCard(
              title: l.premiumMonthly,
              features: [
                l.premiumFeature1,
                l.premiumFeature2,
                l.premiumFeature3,
              ],
              selected:
                  subscriptionService.state.plan == SubscriptionPlan.monthly,
              onPressed: () =>
                  subscriptionService.startPurchase(SubscriptionPlan.monthly),
            ),
            const SizedBox(height: AppSpacing.md),
            _PlanCard(
              title: l.premiumAnnual,
              features: [
                l.premiumFeature1,
                l.premiumFeature2,
                l.premiumFeature3,
                l.premiumFeature4,
              ],
              selected: subscriptionService.state.plan == SubscriptionPlan.annual,
              onPressed: () =>
                  subscriptionService.startPurchase(SubscriptionPlan.annual),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l.subscriptionCached,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.features,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final List<String> features;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
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
              if (selected)
                const Icon(Icons.check_circle, color: AppColors.accent),
            ],
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
          if (onPressed != null) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPressed,
                child: Text(context.l10n.upgradeNow),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
