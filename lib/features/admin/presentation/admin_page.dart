import 'package:flutter/material.dart';

import '../../../core/config/scanleno_app_config.dart';
import '../../../core/constants/feature_flags.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../../ads/application/admob_config.dart';
import '../../account/application/firebase_auth_service.dart';
import '../application/admin_api_service.dart';

enum _AdminSection {
  dashboard,
  users,
  featureFlags,
  ads,
  subscriptions,
  support,
  messages,
  privacy,
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final api = AdminApiService();
  final messageController = TextEditingController();
  final maintenanceController = TextEditingController();
  final offerController = TextEditingController();
  late Future<AdminOverview> future = api.loadOverview();
  _AdminSection section = _AdminSection.dashboard;
  bool saving = false;
  Map<String, Object?> editedFlags = {};

  @override
  void dispose() {
    messageController.dispose();
    maintenanceController.dispose();
    offerController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => future = api.loadOverview());

  Future<void> _saveFlags(AdminOverview overview) async {
    await _runSave(() async {
      final updated = await api.saveFeatureFlags({
        ...overview.featureFlags,
        ...editedFlags,
      });
      await FeatureFlags.applyAndCache(updated, loadedFromBackend: true);
      editedFlags.clear();
    });
  }

  Future<void> _saveMessages(AdminOverview overview) async {
    await _runSave(() {
      return api.saveSettings({
        ...overview.settings,
        'appMessage': messageController.text,
        'maintenanceAlert': maintenanceController.text,
        'specialOffer': offerController.text,
      });
    });
  }

  Future<void> _createSupportTicket() async {
    await _runSave(
      () => api.createSupportTicket(context.l10n.localTestTicketMessage),
    );
  }

  Future<void> _updateTicket(String id, String status) async {
    await _runSave(() => api.updateSupportTicket(id, status));
  }

  Future<void> _verifySubscription() async {
    await _runSave(api.verifySubscription);
  }

  Future<void> _updateUser(String uid, Map<String, Object?> changes) async {
    await _runSave(() => api.updateUser(uid, changes));
  }

  Future<void> _runSave(Future<void> Function() action) async {
    setState(() => saving = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.changesSaved)));
      }
      _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saveFailed)));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (!firebaseAuthService.isAdmin) {
      return AppScreen(
        title: l.adminDashboard,
        showBack: true,
        child: _StateCard(
          icon: Icons.admin_panel_settings_outlined,
          title: l.adminAccessDenied,
          description: l.adminAccessDeniedDescription,
          actionLabel: l.signIn,
          onAction: () async {
            await Navigator.of(context).pushNamed(AppRoutes.auth);
            setState(() {});
          },
        ),
      );
    }
    return AppScreen(
      title: l.adminDashboard,
      showBack: true,
      trailing: IconButton(
        tooltip: l.retry,
        onPressed: _refresh,
        icon: const Icon(Icons.refresh_rounded),
      ),
      child: FutureBuilder<AdminOverview>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _StateCard(
              icon: Icons.cloud_off_outlined,
              title: l.serverConnectionFailed,
              description: l.adminBackendHint,
              actionLabel: l.retry,
              onAction: _refresh,
            );
          }
          final overview = snapshot.data!;
          _syncMessageControllers(overview);
          return ListView(
            children: [
              SoftCard(
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.softBlue,
                      child: Icon(Icons.admin_panel_settings_outlined),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.adminDashboard,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            l.filesStayOnDevice,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SectionPicker(
                selected: section,
                onSelected: (value) => setState(() => section = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(overview),
            ],
          );
        },
      ),
    );
  }

  void _syncMessageControllers(AdminOverview overview) {
    if (messageController.text.isEmpty) {
      messageController.text = _text(overview.settings['appMessage']);
    }
    if (maintenanceController.text.isEmpty) {
      maintenanceController.text = _text(overview.settings['maintenanceAlert']);
    }
    if (offerController.text.isEmpty) {
      offerController.text = _text(overview.settings['specialOffer']);
    }
  }

  Widget _buildSection(AdminOverview overview) {
    return switch (section) {
      _AdminSection.dashboard => _DashboardSection(overview: overview),
      _AdminSection.users => _UsersSection(
        users: overview.users,
        saving: saving,
        onUpdate: _updateUser,
      ),
      _AdminSection.featureFlags => _FeatureFlagsSection(
        flags: {...overview.featureFlags, ...editedFlags},
        saving: saving,
        onChanged: (key, value) => setState(() => editedFlags[key] = value),
        onSave: () => _saveFlags(overview),
      ),
      _AdminSection.ads => _AdsSection(
        flags: {...overview.featureFlags, ...editedFlags},
        saving: saving,
        onChanged: (key, value) => setState(() => editedFlags[key] = value),
        onSave: () => _saveFlags(overview),
      ),
      _AdminSection.subscriptions => _SubscriptionsSection(
        overview: overview,
        saving: saving,
        onVerify: _verifySubscription,
      ),
      _AdminSection.support => _SupportSection(
        tickets: overview.supportTickets,
        saving: saving,
        onCreate: _createSupportTicket,
        onUpdate: _updateTicket,
      ),
      _AdminSection.messages => _MessagesSection(
        messageController: messageController,
        maintenanceController: maintenanceController,
        offerController: offerController,
        saving: saving,
        onSave: () => _saveMessages(overview),
      ),
      _AdminSection.privacy => _PrivacySection(overview: overview),
    };
  }
}

class _SectionPicker extends StatelessWidget {
  const _SectionPicker({required this.selected, required this.onSelected});

  final _AdminSection selected;
  final ValueChanged<_AdminSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final labels = {
      _AdminSection.dashboard: l.adminStats,
      _AdminSection.users: l.adminUsers,
      _AdminSection.featureFlags: l.adminFlags,
      _AdminSection.ads: l.adminAds,
      _AdminSection.subscriptions: l.adminSubscriptions,
      _AdminSection.support: l.adminSupport,
      _AdminSection.messages: l.adminMessages,
      _AdminSection.privacy: l.adminPrivacy,
    };
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final item in _AdminSection.values)
          ChoiceChip(
            label: Text(labels[item]!),
            selected: selected == item,
            onSelected: (_) => onSelected(item),
          ),
      ],
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.overview});

  final AdminOverview overview;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final stats = overview.stats;
    final topTools = stats['topTools'] is List
        ? (stats['topTools'] as List).join(', ')
        : l.noDataYet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l.adminStats),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _Metric(title: l.adminUsers, value: _value(stats['users'])),
            _Metric(title: l.documents, value: _value(stats['documents'])),
            _Metric(title: l.scanCount, value: _value(stats['scans'])),
            _Metric(title: l.freeUsers, value: _value(stats['freeUsers'])),
            _Metric(title: l.premiumUsers, value: _value(stats['premiumUsers'])),
            _Metric(title: l.createdPdfCount, value: _value(stats['createdPdfs'])),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SoftCard(
          child: Column(
            children: [
              _InfoRow(label: l.mostUsedTools, value: topTools),
              const Divider(),
              _InfoRow(
                label: l.adminAds,
                value: _boolLabel(context, overview.featureFlags['adsEnabled']),
              ),
              const Divider(),
              _InfoRow(
                label: l.ocrExtraction,
                value: _boolLabel(context, overview.featureFlags['ocrEnabled']),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UsersSection extends StatelessWidget {
  const _UsersSection({
    required this.users,
    required this.saving,
    required this.onUpdate,
  });

  final List<Map<String, Object?>> users;
  final bool saving;
  final void Function(String uid, Map<String, Object?> changes) onUpdate;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l.adminUsers),
        if (users.isEmpty)
          _EmptyCard(message: l.noDataYet)
        else
          for (final user in users)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _UserCard(
                user: user,
                saving: saving,
                onUpdate: onUpdate,
              ),
            ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.saving,
    required this.onUpdate,
  });

  final Map<String, Object?> user;
  final bool saving;
  final void Function(String uid, Map<String, Object?> changes) onUpdate;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final uid = _text(user['uid']);
    final disabled = user['disabled'] == true;
    final plan = _text(user['plan']).isEmpty ? 'free' : _text(user['plan']);
    final monthlyLimit = _safeInt(user['monthlyOcrLimit'], 100);
    final scanCredit = _safeInt(user['scanCredit'], 0);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: disabled ? AppColors.outline : AppColors.softBlue,
                child: Icon(
                  disabled ? Icons.block_outlined : Icons.person_outline,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _text(user['displayName']).isEmpty
                          ? _text(user['email']).isEmpty
                                ? uid
                                : _text(user['email'])
                          : _text(user['displayName']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      uid,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(label: l.email, value: _text(user['email'])),
          const Divider(),
          _InfoRow(label: l.plan, value: _localizedPlan(context, plan)),
          const Divider(),
          _InfoRow(label: l.status, value: disabled ? l.disabled : l.enabled),
          const Divider(),
          _InfoRow(label: l.monthlyOcrUsed, value: _value(user['monthlyOcrUsed'])),
          const Divider(),
          _InfoRow(label: l.monthlyOcrLimit, value: monthlyLimit.toString()),
          const Divider(),
          _InfoRow(label: l.scanCredits, value: scanCredit.toString()),
          const Divider(),
          _InfoRow(label: l.role, value: _text(user['role'])),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownButton<String>(
                value: plan,
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(value: 'free', child: Text(l.freePlan)),
                  DropdownMenuItem(value: 'premium', child: Text(l.premium)),
                ],
                onChanged: saving || uid.isEmpty
                    ? null
                    : (value) {
                        if (value != null) {
                          onUpdate(uid, {
                            'plan': value,
                            'premiumActive': value == 'premium',
                          });
                        }
                      },
              ),
              DropdownButton<int>(
                value: monthlyLimit,
                underline: const SizedBox.shrink(),
                items: const [100, 250, 500, 1000]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: saving || uid.isEmpty
                    ? null
                    : (value) {
                        if (value != null) {
                          onUpdate(uid, {'monthlyOcrLimit': value});
                        }
                      },
              ),
              OutlinedButton.icon(
                onPressed: saving || uid.isEmpty
                    ? null
                    : () => onUpdate(uid, {'scanCredit': scanCredit + 1}),
                icon: const Icon(Icons.add_rounded),
                label: Text(l.addScanCredit),
              ),
              OutlinedButton.icon(
                onPressed: saving || uid.isEmpty
                    ? null
                    : () => onUpdate(uid, {'disabled': !disabled}),
                icon: Icon(disabled ? Icons.lock_open_outlined : Icons.block_outlined),
                label: Text(disabled ? l.enableUser : l.disableUser),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureFlagsSection extends StatelessWidget {
  const _FeatureFlagsSection({
    required this.flags,
    required this.saving,
    required this.onChanged,
    required this.onSave,
  });

  final Map<String, Object?> flags;
  final bool saving;
  final void Function(String key, Object? value) onChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l.adminFlags),
        _SwitchCard(l.adminAds, _flag('adsEnabled'), (value) => onChanged('adsEnabled', value)),
        _SwitchCard(l.ocrExtraction, _flag('ocrEnabled'), (value) => onChanged('ocrEnabled', value)),
        _SwitchCard(l.ocrPremiumMode, _flag('ocrPremiumOnly'), (value) => onChanged('ocrPremiumOnly', value)),
        _SwitchCard(l.ocrScanCreditAccess, _flag('ocrWithScanCreditEnabled'), (value) => onChanged('ocrWithScanCreditEnabled', value)),
        _SwitchCard(l.allowAutoLanguageDetection, _flag('allowAutoLanguageDetection'), (value) => onChanged('allowAutoLanguageDetection', value)),
        _SwitchCard(l.aiTranslate, _flag('translateEnabled'), (value) => onChanged('translateEnabled', value)),
        _SwitchCard(l.translatePremiumOnly, _flag('translatePremiumOnly'), (value) => onChanged('translatePremiumOnly', value)),
        _SwitchCard(l.translateWithScanCredit, _flag('translateWithScanCreditEnabled'), (value) => onChanged('translateWithScanCreditEnabled', value)),
        _SwitchCard(l.aiSummary, _flag('aiSummaryEnabled'), (value) => onChanged('aiSummaryEnabled', value)),
        _SwitchCard(l.aiSummaryPremiumOnly, _flag('aiSummaryPremiumOnly'), (value) => onChanged('aiSummaryPremiumOnly', value)),
        _SwitchCard(l.aiSummaryWithScanCredit, _flag('aiSummaryWithScanCreditEnabled'), (value) => onChanged('aiSummaryWithScanCreditEnabled', value)),
        _SwitchCard(l.pdfToExcel, _flag('pdfToExcelEnabled'), (value) => onChanged('pdfToExcelEnabled', value)),
        _SwitchCard(l.pdfToExcelPremiumOnly, _flag('pdfToExcelPremiumOnly'), (value) => onChanged('pdfToExcelPremiumOnly', value)),
        _SwitchCard(l.pdfToExcelWithScanCredit, _flag('pdfToExcelWithScanCreditEnabled'), (value) => onChanged('pdfToExcelWithScanCreditEnabled', value)),
        _SwitchCard(l.pdfToWord, _flag('pdfToWordEnabled'), (value) => onChanged('pdfToWordEnabled', value)),
        _SwitchCard(l.pdfToWordPremiumOnly, _flag('pdfToWordPremiumOnly'), (value) => onChanged('pdfToWordPremiumOnly', value)),
        _SwitchCard(l.pdfToWordWithScanCredit, _flag('pdfToWordWithScanCreditEnabled'), (value) => onChanged('pdfToWordWithScanCreditEnabled', value)),
        _SwitchCard(l.advancedPdfTools, _flag('advancedPdfToolsEnabled'), (value) => onChanged('advancedPdfToolsEnabled', value)),
        _SwitchCard(l.watermark, _flag('watermarkEnabled'), (value) => onChanged('watermarkEnabled', value)),
        _SwitchCard(l.freeVersionWatermark, _flag('freeExportWatermarkRequired'), (value) => onChanged('freeExportWatermarkRequired', value)),
        _SwitchCard(l.noWatermarkForPremium, _flag('premiumCustomWatermarkEnabled'), (value) => onChanged('premiumCustomWatermarkEnabled', value)),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: TextFormField(
            initialValue: _text(flags['defaultWatermarkText']).isEmpty
                ? 'ScanLeno'
                : _text(flags['defaultWatermarkText']),
            decoration: InputDecoration(labelText: l.watermarkText),
            onChanged: (value) => onChanged('defaultWatermarkText', value),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.opacity)),
              DropdownButton<double>(
                value: _opacityFlag(),
                underline: const SizedBox.shrink(),
                items: const [0.10, 0.14, 0.20, 0.30, 0.40]
                    .map((value) => DropdownMenuItem(value: value, child: Text('${(value * 100).round()}%')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('defaultWatermarkOpacity', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.position)),
              DropdownButton<String>(
                value: _positionFlag(),
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(value: 'center', child: Text(l.center)),
                  DropdownMenuItem(value: 'top', child: Text(l.top)),
                  DropdownMenuItem(value: 'bottom', child: Text(l.bottom)),
                  DropdownMenuItem(value: 'right', child: Text(l.right)),
                  DropdownMenuItem(value: 'left', child: Text(l.left)),
                ],
                onChanged: (value) {
                  if (value != null) onChanged('defaultWatermarkPosition', value);
                },
              ),
            ],
          ),
        ),
        SoftCard(
          child: Column(
            children: [
              _InfoRow(label: l.provider, value: _text(flags['azureOcrProvider'])),
              const Divider(),
              _InfoRow(label: l.model, value: _text(flags['azureOcrModel'])),
              const Divider(),
              _InfoRow(label: l.ocrReadModel, value: _text(flags['azureOcrReadModel'])),
              const Divider(),
              _InfoRow(label: l.ocrLayoutModel, value: _text(flags['azureOcrLayoutModel'])),
              const Divider(),
              _InfoRow(label: l.azureOcrStatus, value: _boolLabel(context, flags['azureOcrEnabled'])),
              const Divider(),
              _InfoRow(label: l.translatorProvider, value: _text(flags['translatorProvider'])),
              const Divider(),
              _InfoRow(label: l.translatorRegion, value: _text(flags['translatorRegion'])),
              const Divider(),
              _InfoRow(label: l.aiSummaryProvider, value: _text(flags['aiSummaryProvider'])),
              const Divider(),
              _InfoRow(label: l.aiSummaryModel, value: _text(flags['aiSummaryModel'])),
              const Divider(),
              _InfoRow(label: l.aiSummaryDeployment, value: _text(flags['aiSummaryDeployment'])),
              const Divider(),
              _InfoRow(label: l.pdfToExcelProvider, value: _text(flags['pdfToExcelProvider'])),
              const Divider(),
              _InfoRow(label: l.pdfToExcelModel, value: _text(flags['pdfToExcelModel'])),
              const Divider(),
              _InfoRow(label: l.pdfToWordProvider, value: _text(flags['pdfToWordProvider'])),
              const Divider(),
              _InfoRow(label: l.pdfToWordModel, value: _text(flags['pdfToWordModel'])),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.defaultOcrLanguage)),
              DropdownButton<String>(
                value: _ocrLanguageFlag(),
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(value: 'auto', child: Text(l.autoDetect)),
                  DropdownMenuItem(value: 'ar', child: Text(l.arabic)),
                  DropdownMenuItem(value: 'en', child: Text(l.english)),
                  DropdownMenuItem(value: 'tr', child: Text(l.turkish)),
                  DropdownMenuItem(value: 'fr', child: Text(l.french)),
                  DropdownMenuItem(value: 'es', child: Text(l.spanish)),
                  DropdownMenuItem(value: 'de', child: Text(l.german)),
                  DropdownMenuItem(value: 'it', child: Text(l.italian)),
                  DropdownMenuItem(value: 'pt', child: Text(l.portuguese)),
                  DropdownMenuItem(value: 'zh-Hans', child: Text(l.chineseSimplified)),
                  DropdownMenuItem(value: 'zh-Hant', child: Text(l.chineseTraditional)),
                  DropdownMenuItem(value: 'ja', child: Text(l.japanese)),
                  DropdownMenuItem(value: 'ko', child: Text(l.korean)),
                  DropdownMenuItem(value: 'hi', child: Text(l.hindi)),
                  DropdownMenuItem(value: 'ur', child: Text(l.urdu)),
                  DropdownMenuItem(value: 'id', child: Text(l.indonesian)),
                  DropdownMenuItem(value: 'ms', child: Text(l.malay)),
                  DropdownMenuItem(value: 'ru', child: Text(l.russian)),
                ],
                onChanged: (value) {
                  if (value != null) onChanged('defaultOcrLanguage', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.freeDailyLimit)),
              DropdownButton<int>(
                value: _intFlag('freeDailyScanLimit', FeatureFlags.freeDailyScanLimit),
                underline: const SizedBox.shrink(),
                items: const [5, 10, 15, 20, 30]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('freeDailyScanLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.freeImageToPdfLimit)),
              DropdownButton<int>(
                value: _intFlag('freeImageToPdfLimit', FeatureFlags.freeImageToPdfLimit),
                underline: const SizedBox.shrink(),
                items: const [5, 10, 12, 20, 30]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('freeImageToPdfLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.freeFolderLimit)),
              DropdownButton<int>(
                value: _intFlag('freeFolderLimit', FeatureFlags.freeFolderLimit),
                underline: const SizedBox.shrink(),
                items: const [1, 3, 5, 10]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('freeFolderLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.freeDailyOcrLimit)),
              DropdownButton<int>(
                value: _intFlag('freeDailyOcrLimit', FeatureFlags.freeDailyOcrLimit),
                underline: const SizedBox.shrink(),
                items: const [1, 3, 5, 10]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('freeDailyOcrLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.freeDailyTranslateLimit)),
              DropdownButton<int>(
                value: _intFlag('freeDailyTranslateLimit', FeatureFlags.freeDailyTranslateLimit),
                underline: const SizedBox.shrink(),
                items: const [1, 3, 5, 10]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('freeDailyTranslateLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.freeDailySummaryLimit)),
              DropdownButton<int>(
                value: _intFlag('freeDailySummaryLimit', FeatureFlags.freeDailySummaryLimit),
                underline: const SizedBox.shrink(),
                items: const [1, 3, 5, 10]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('freeDailySummaryLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.freeDailyPdfToExcelLimit)),
              DropdownButton<int>(
                value: _intFlag('freeDailyPdfToExcelLimit', FeatureFlags.freeDailyPdfToExcelLimit),
                underline: const SizedBox.shrink(),
                items: const [1, 3, 5, 10]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('freeDailyPdfToExcelLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.freeDailyPdfToWordLimit)),
              DropdownButton<int>(
                value: _intFlag('freeDailyPdfToWordLimit', FeatureFlags.freeDailyPdfToWordLimit),
                underline: const SizedBox.shrink(),
                items: const [1, 3, 5, 10]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('freeDailyPdfToWordLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.premiumMonthlyOcrLimit)),
              DropdownButton<int>(
                value: _intFlag('premiumMonthlyOcrLimit', FeatureFlags.premiumMonthlyOcrLimit),
                underline: const SizedBox.shrink(),
                items: const [100, 250, 500, 1000]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('premiumMonthlyOcrLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.premiumMonthlyTranslateLimit)),
              DropdownButton<int>(
                value: _intFlag('premiumMonthlyTranslateLimit', FeatureFlags.premiumMonthlyTranslateLimit),
                underline: const SizedBox.shrink(),
                items: const [100, 250, 500, 1000]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('premiumMonthlyTranslateLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.premiumMonthlySummaryLimit)),
              DropdownButton<int>(
                value: _intFlag('premiumMonthlySummaryLimit', FeatureFlags.premiumMonthlySummaryLimit),
                underline: const SizedBox.shrink(),
                items: const [100, 250, 500, 1000]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('premiumMonthlySummaryLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.premiumMonthlyPdfToExcelLimit)),
              DropdownButton<int>(
                value: _intFlag('premiumMonthlyPdfToExcelLimit', FeatureFlags.premiumMonthlyPdfToExcelLimit),
                underline: const SizedBox.shrink(),
                items: const [50, 100, 200, 500]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('premiumMonthlyPdfToExcelLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.premiumMonthlyPdfToWordLimit)),
              DropdownButton<int>(
                value: _intFlag('premiumMonthlyPdfToWordLimit', FeatureFlags.premiumMonthlyPdfToWordLimit),
                underline: const SizedBox.shrink(),
                items: const [50, 100, 200, 500]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('premiumMonthlyPdfToWordLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SoftCard(
          child: Row(
            children: [
              Expanded(child: Text(l.premiumYearlyOcrLimit)),
              DropdownButton<int>(
                value: _intFlag('premiumYearlyOcrLimit', FeatureFlags.premiumYearlyOcrLimit),
                underline: const SizedBox.shrink(),
                items: const [1000, 3000, 6000, 12000]
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChanged('premiumYearlyOcrLimit', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: saving ? null : onSave,
          icon: const Icon(Icons.save_outlined),
          label: Text(l.saveChanges),
        ),
      ],
    );
  }

  bool _flag(String key) => flags[key] as bool? ?? false;
  int _intFlag(String key, int fallback) => flags[key] as int? ?? fallback;
  double _doubleFlag(String key, double fallback) {
    final value = flags[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  double _opacityFlag() {
    const allowed = [0.10, 0.14, 0.20, 0.30, 0.40];
    final value = _doubleFlag(
      'defaultWatermarkOpacity',
      FeatureFlags.defaultWatermarkOpacity,
    );
    return allowed.contains(value) ? value : 0.14;
  }

  String _positionFlag() {
    const allowed = ['center', 'top', 'bottom', 'right', 'left'];
    final value = _text(flags['defaultWatermarkPosition']);
    return allowed.contains(value) ? value : 'center';
  }

  String _ocrLanguageFlag() {
    const allowed = [
      'auto',
      'ar',
      'en',
      'tr',
      'fr',
      'es',
      'de',
      'it',
      'pt',
      'zh-Hans',
      'zh-Hant',
      'ja',
      'ko',
      'hi',
      'ur',
      'id',
      'ms',
      'ru',
    ];
    final value = _text(flags['defaultOcrLanguage']);
    return allowed.contains(value) ? value : 'auto';
  }
}

class _AdsSection extends StatelessWidget {
  const _AdsSection({
    required this.flags,
    required this.saving,
    required this.onChanged,
    required this.onSave,
  });

  final Map<String, Object?> flags;
  final bool saving;
  final void Function(String key, Object? value) onChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l.adminAds),
        SoftCard(
          child: Column(
            children: [
              _InfoRow(label: l.androidAppId, value: AdMobConfig.androidAppId),
              const Divider(),
              _InfoRow(label: l.iosAppId, value: AdMobConfig.iosAppId),
              const Divider(),
              _InfoRow(
                label: l.rewardItem,
                value: '${AdMobConfig.rewardAmount} ${AdMobConfig.rewardItem}',
              ),
              const Divider(),
              _InfoRow(label: l.premiumNoAds, value: l.enabled),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SwitchCard(l.adminAds, _flag('adsEnabled'), (value) => onChanged('adsEnabled', value)),
        _SwitchCard(l.bannerAds, _flag('bannerEnabled'), (value) => onChanged('bannerEnabled', value)),
        _SwitchCard(l.interstitialAds, _flag('interstitialAfterExportEnabled'), (value) => onChanged('interstitialAfterExportEnabled', value)),
        _SwitchCard(l.rewardedAds, _flag('rewardedAdsEnabled'), (value) => onChanged('rewardedAdsEnabled', value)),
        _SwitchCard(l.home, _flag('homeBannerAdsEnabled'), (value) => onChanged('homeBannerAdsEnabled', value)),
        _SwitchCard(l.myFiles, _flag('filesBannerAdsEnabled'), (value) => onChanged('filesBannerAdsEnabled', value)),
        _SwitchCard(l.tools, _flag('toolsBannerAdsEnabled'), (value) => onChanged('toolsBannerAdsEnabled', value)),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: saving ? null : onSave,
          icon: const Icon(Icons.save_outlined),
          label: Text(l.saveChanges),
        ),
      ],
    );
  }

  bool _flag(String key) => flags[key] as bool? ?? false;
}

class _SubscriptionsSection extends StatelessWidget {
  const _SubscriptionsSection({
    required this.overview,
    required this.saving,
    required this.onVerify,
  });

  final AdminOverview overview;
  final bool saving;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final plans = overview.subscriptions['plans'] as List<dynamic>? ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l.adminSubscriptions),
        if (plans.isEmpty)
          _EmptyCard(message: l.noDataYet)
        else
          for (final item in plans)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SoftCard(
                child: Column(
                  children: [
                    _InfoRow(label: l.plan, value: _text((item as Map)['id'])),
                    const Divider(),
                    _InfoRow(label: l.status, value: _boolLabel(context, item['active'])),
                    const Divider(),
                    _InfoRow(label: l.productId, value: _text(item['productId'])),
                  ],
                ),
              ),
            ),
        SoftCard(
          child: _InfoRow(
            label: l.freeTrial,
            value: _boolLabel(context, overview.subscriptions['freeTrialEnabled']),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: saving ? null : onVerify,
          icon: const Icon(Icons.verified_outlined),
          label: Text(l.verifySubscription),
        ),
      ],
    );
  }
}

class _SupportSection extends StatelessWidget {
  const _SupportSection({
    required this.tickets,
    required this.saving,
    required this.onCreate,
    required this.onUpdate,
  });

  final List<Map<String, Object?>> tickets;
  final bool saving;
  final VoidCallback onCreate;
  final void Function(String id, String status) onUpdate;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l.adminSupport),
        if (tickets.isEmpty) _EmptyCard(message: l.noSupportTickets),
        for (final ticket in tickets)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_text(ticket['message'])),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _text(ticket['createdAt']),
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Chip(label: Text(_text(ticket['status']))),
                      const Spacer(),
                      TextButton(
                        onPressed: saving
                            ? null
                            : () => onUpdate(_text(ticket['id']), 'closed'),
                        child: Text(l.closeTicket),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        FilledButton.icon(
          onPressed: saving ? null : onCreate,
          icon: const Icon(Icons.add_rounded),
          label: Text(l.createLocalTicket),
        ),
      ],
    );
  }
}

class _MessagesSection extends StatelessWidget {
  const _MessagesSection({
    required this.messageController,
    required this.maintenanceController,
    required this.offerController,
    required this.saving,
    required this.onSave,
  });

  final TextEditingController messageController;
  final TextEditingController maintenanceController;
  final TextEditingController offerController;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l.adminMessages),
        _TextFieldCard(label: l.generalMessage, controller: messageController),
        _TextFieldCard(label: l.maintenanceAlert, controller: maintenanceController),
        _TextFieldCard(label: l.specialOffer, controller: offerController),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: saving ? null : onSave,
          icon: const Icon(Icons.save_outlined),
          label: Text(l.saveChanges),
        ),
      ],
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({required this.overview});

  final AdminOverview overview;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l.adminPrivacy),
        SoftCard(
          child: Column(
            children: [
              _InfoRow(label: l.privacyNotes, value: _text(overview.settings['privacy'])),
              const Divider(),
              _InfoRow(label: l.userFilesUploadPolicy, value: l.filesStayOnDevice),
              const Divider(),
              _InfoRow(label: l.backendBaseUrl, value: scanLenoConfig.effectiveBackendBaseUrl),
            ],
          ),
        ),
      ],
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

class _Metric extends StatelessWidget {
  const _Metric({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _SwitchCard extends StatelessWidget {
  const _SwitchCard(this.title, this.value, this.onChanged);

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: SoftCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        title: Text(title),
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: Text(label)),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Text(
          value.isEmpty ? context.l10n.noDataYet : value,
          textAlign: TextAlign.end,
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _TextFieldCard extends StatelessWidget {
  const _TextFieldCard({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: SoftCard(
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 3,
        decoration: InputDecoration(labelText: label),
      ),
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Row(
      children: [
        const Icon(Icons.inbox_outlined, color: AppColors.muted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: SoftCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: AppColors.muted),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    ),
  );
}

String _value(Object? value) => value?.toString() ?? '0';
String _text(Object? value) => value?.toString() ?? '';

int _safeInt(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(_text(value)) ?? fallback;
}

String _localizedPlan(BuildContext context, String plan) {
  return plan == 'premium' ? context.l10n.premium : context.l10n.freePlan;
}

String _boolLabel(BuildContext context, Object? value) {
  return value == true ? context.l10n.enabled : context.l10n.disabled;
}
