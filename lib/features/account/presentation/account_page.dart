import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/app_shell.dart';
import '../../../core/constants/feature_flags.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../application/firebase_auth_service.dart';
import '../../files/application/local_file_repository.dart';
import '../../premium/application/subscription_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final repository = LocalFileRepository();
  late Future<_AccountOverview> future = _load();

  Future<_AccountOverview> _load() async {
    String? warning;
    int documents = 0;
    int folders = 0;
    int storageBytes = 0;
    var scanQuality = 'high';
    var saveFormat = 'pdf';
    var appLock = false;
    var scanCredits = 0;
    var isPremium = false;

    try {
      await subscriptionService.initialize();
      isPremium = subscriptionService.isPremium;
    } catch (_) {
      warning = 'subscription_unavailable';
    }

    try {
      final state = await repository.load();
      final visibleDocuments = state.documents
          .where((document) => !document.isDeleted)
          .toList(growable: false);
      documents = visibleDocuments.length;
      folders = state.folders.length;
      storageBytes = visibleDocuments.fold<int>(
        0,
        (total, document) => total + document.sizeBytes,
      );
    } catch (_) {
      warning = 'local_storage_unavailable';
    }

    try {
      scanQuality =
          await repository.getSetting('default_scan_quality') ?? scanQuality;
      saveFormat = await repository.getSetting('default_save_format') ?? saveFormat;
      appLock = await repository.getSetting('app_lock_enabled') == 'true';
      scanCredits = await repository.getScanCredits();
    } catch (_) {
      warning = 'local_settings_unavailable';
    }

    try {
      await firebaseAuthService.refreshMetadata();
    } catch (_) {
      warning = 'firebase_metadata_unavailable';
    }

    return _AccountOverview(
      documents: documents,
      folders: folders,
      storageBytes: storageBytes,
      scanQuality: scanQuality,
      saveFormat: saveFormat,
      appLockEnabled: appLock,
      isPremium: firebaseAuthService.metadata?.premiumActive ?? isPremium,
      scanCredits: scanCredits,
      authUser: firebaseAuthService.user,
      authMetadata: firebaseAuthService.metadata,
      connectionWarning: firebaseAuthService.connectionWarning ?? warning,
    );
  }

  void _refresh() {
    final nextFuture = _load();
    if (!mounted) return;
    setState(() {
      future = nextFuture;
    });
  }

  Future<void> _saveSetting(String key, String value) async {
    await repository.saveSetting(key, value);
    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.changesSaved)));
    }
  }

  Future<void> _restorePurchases() async {
    await subscriptionService.restorePurchases();
    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.restoreRequested)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppShell(
      currentIndex: 3,
      child: AppScreen(
        title: l.account,
        child: FutureBuilder<_AccountOverview>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  _LocalWarning(message: l.localDataFallback),
                  const SizedBox(height: AppSpacing.md),
                  _ProfileCard(overview: _AccountOverview.fallback()),
                  const SizedBox(height: AppSpacing.lg),
                  _StatCard(
                    icon: Icons.folder_copy_outlined,
                    label: l.documents,
                    value: '0',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l.retry),
                  ),
                ],
              );
            }
            final overview = snapshot.data!;
            return ListView(
              children: [
                if (overview.connectionWarning != null) ...[
                  _LocalWarning(message: l.localDataFallback),
                  const SizedBox(height: AppSpacing.md),
                ],
                _ProfileCard(overview: overview),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.folder_copy_outlined,
                        label: l.documents,
                        value: overview.documents.toString(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.folder_outlined,
                        label: l.folders,
                        value: overview.folders.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _StatCard(
                  icon: Icons.cloud_queue_rounded,
                  label: l.usedStorage,
                  value: _formatBytes(overview.storageBytes),
                ),
                const SizedBox(height: AppSpacing.sm),
                _StatCard(
                  icon: Icons.stars_outlined,
                  label: l.scanCredits,
                  value: overview.scanCredits.toString(),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(l.accountSubscription),
                SoftCard(
                  child: Column(
                    children: [
                      _ActionRow(
                        icon: overview.authUser == null
                            ? Icons.login_rounded
                            : Icons.verified_user_outlined,
                        title: overview.authUser == null
                            ? l.signIn
                            : l.accountStatus,
                        subtitle: overview.authUser == null
                            ? l.accountOptionalDescription
                            : (overview.authUser!.isAnonymous
                                  ? l.guestMode
                                  : (overview.authUser!.email ?? l.registeredUser)),
                        onTap: () async {
                          await Navigator.of(context).pushNamed(AppRoutes.auth);
                          _refresh();
                        },
                      ),
                      if (overview.authUser != null) ...[
                        const Divider(),
                        _ActionRow(
                          icon: Icons.logout_rounded,
                          title: l.signOut,
                          subtitle: l.signOutDescription,
                          onTap: () async {
                            await firebaseAuthService.signOut();
                            _refresh();
                          },
                        ),
                      ],
                      const Divider(),
                      _ActionRow(
                        icon: Icons.workspace_premium_outlined,
                        title: l.manageSubscription,
                        subtitle: l.subscriptionCached,
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.premium),
                      ),
                      if (!overview.isPremium) ...[
                        const Divider(),
                        _ActionRow(
                          icon: Icons.upgrade_rounded,
                          title: l.upgradeToPremium,
                          subtitle: l.premiumDescription,
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.premium),
                        ),
                      ],
                      const Divider(),
                      _ActionRow(
                        icon: Icons.restore_rounded,
                        title: l.restorePurchases,
                        subtitle: l.restorePurchasesDescription,
                        onTap: _restorePurchases,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(l.accountPreferences),
                SoftCard(
                  child: Column(
                    children: [
                      _ActionRow(
                        icon: Icons.language_rounded,
                        title: l.language,
                        subtitle: Localizations.localeOf(context).languageCode,
                        onTap: () => _showInfo(l.languageManagedBySystem),
                      ),
                      const Divider(),
                      _ChoiceRow(
                        icon: Icons.document_scanner_outlined,
                        title: l.defaultScanQuality,
                        value: overview.scanQuality,
                        labels: {
                          'low': l.low,
                          'medium': l.medium,
                          'high': l.high,
                        },
                        onChanged: (value) =>
                            _saveSetting('default_scan_quality', value),
                      ),
                      const Divider(),
                      _ChoiceRow(
                        icon: Icons.save_outlined,
                        title: l.defaultSaveFormat,
                        value: overview.saveFormat,
                        labels: {'pdf': l.pdfDocument, 'jpg': l.jpg},
                        onChanged: (value) =>
                            _saveSetting('default_save_format', value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(l.securitySettings),
                SoftCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.lock_outline),
                        title: Text(l.appLock),
                        subtitle: Text(l.appLockDescription),
                        value: overview.appLockEnabled,
                        onChanged: (value) =>
                            _saveSetting('app_lock_enabled', value.toString()),
                      ),
                      const Divider(),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.fingerprint_rounded),
                        title: Text(l.biometrics),
                        subtitle: Text(
                          FeatureFlags.protectPdfEnabled
                              ? l.biometricsDescription
                              : l.featureDisabled,
                        ),
                        value: false,
                        onChanged: FeatureFlags.protectPdfEnabled ? (_) {} : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(l.helpAndLegal),
                SoftCard(
                  child: Column(
                    children: [
                      _ActionRow(
                        icon: Icons.support_agent_outlined,
                        title: l.contactSupport,
                        subtitle: l.supportLocalOnly,
                        onTap: () => _showInfo(l.supportLocalOnly),
                      ),
                      const Divider(),
                      _ActionRow(
                        icon: Icons.privacy_tip_outlined,
                        title: l.privacyPolicy,
                        subtitle: l.filesStayOnDevice,
                        onTap: () => _showInfo(l.filesStayOnDevice),
                      ),
                      const Divider(),
                      _ActionRow(
                        icon: Icons.description_outlined,
                        title: l.termsOfUse,
                        subtitle: l.termsSummary,
                        onTap: () => _showInfo(l.termsSummary),
                      ),
                      const Divider(),
                      _ActionRow(
                        icon: Icons.info_outline,
                        title: l.aboutApp,
                        subtitle: '${l.appName} ${l.appVersionNumber}',
                        onTap: () => showAboutDialog(
                          context: context,
                          applicationName: l.appName,
                          applicationVersion: l.appVersionNumber,
                          applicationLegalese: l.filesStayOnDevice,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    return '${(mb / 1024).toStringAsFixed(1)} GB';
  }
}

class _AccountOverview {
  const _AccountOverview({
    required this.documents,
    required this.folders,
    required this.storageBytes,
    required this.scanQuality,
    required this.saveFormat,
    required this.appLockEnabled,
    required this.isPremium,
    required this.scanCredits,
    required this.authUser,
    required this.authMetadata,
    required this.connectionWarning,
  });

  factory _AccountOverview.fallback() => const _AccountOverview(
    documents: 0,
    folders: 0,
    storageBytes: 0,
    scanQuality: 'high',
    saveFormat: 'pdf',
    appLockEnabled: false,
    isPremium: false,
    scanCredits: 0,
    authUser: null,
    authMetadata: null,
    connectionWarning: 'fallback',
  );

  final int documents;
  final int folders;
  final int storageBytes;
  final String scanQuality;
  final String saveFormat;
  final bool appLockEnabled;
  final bool isPremium;
  final int scanCredits;
  final User? authUser;
  final ScanLenoUserMetadata? authMetadata;
  final String? connectionWarning;
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.overview});

  final _AccountOverview overview;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final displayName =
        overview.authMetadata?.displayName ??
        overview.authUser?.displayName ??
        l.localUser;
    final subtitle = overview.authUser == null
        ? l.localUser
        : overview.authUser!.isAnonymous
            ? l.guestMode
            : (overview.authMetadata?.email ?? overview.authUser!.email ?? l.registeredUser);
    return SoftCard(
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.softBlue,
            child: Icon(Icons.person_rounded, color: AppColors.interactive),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.xs),
                Chip(
                  label: Text(overview.isPremium ? l.premium : l.freePlan),
                  avatar: Icon(
                    overview.isPremium
                        ? Icons.workspace_premium_outlined
                        : Icons.person_outline_rounded,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}

class _LocalWarning extends StatelessWidget {
  const _LocalWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.softBlue,
      borderRadius: AppRadii.medium,
      border: Border.all(color: AppColors.interactive.withValues(alpha: 0.18)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: AppColors.interactive),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Row(
      children: [
        Icon(icon, color: AppColors.interactive),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(label)),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: AppColors.interactive),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String value;
  final Map<String, String> labels;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.interactive),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: Text(title)),
      DropdownButton<String>(
        value: labels.containsKey(value) ? value : labels.keys.first,
        underline: const SizedBox.shrink(),
        items: [
          for (final entry in labels.entries)
            DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    ],
  );
}
