import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/feature_flags.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../files/application/local_file_repository.dart';
import '../../premium/application/premium_access_service.dart';
import '../../premium/application/subscription_service.dart';
import '../../premium/presentation/premium_gate_dialog.dart';
import '../application/document_draft_controller.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  final picker = ImagePicker();
  final repository = LocalFileRepository();
  CameraController? controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _openCamera();
  }

  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        controller = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await controller!.initialize();
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _capture() async {
    if (!await _canUseScan()) return;
    final file = await controller?.takePicture();
    if (file == null) return;
    if (!subscriptionService.isPremium) {
      await repository.incrementDailyUsage(scans: 1);
    }
    documentDraft.replaceWith([file.path]);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.edgeCrop);
    }
  }

  Future<void> _gallery() async {
    final files = await picker.pickMultiImage(imageQuality: 95);
    if (files.isEmpty) return;
    await subscriptionService.initialize();
    if (!subscriptionService.isPremium &&
        files.length > FeatureFlags.freeImageToPdfLimit) {
      if (mounted) await _showScanLimit();
      return;
    }
    if (!subscriptionService.isPremium) {
      await repository.incrementDailyUsage(
        imageImports: files.length,
        imageToPdf: files.length,
      );
    }
    documentDraft.replaceWith(files.map((file) => file.path).toList());
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.edgeCrop);
    }
  }

  Future<bool> _canUseScan() async {
    await subscriptionService.initialize();
    if (subscriptionService.isPremium) return true;
    final usage = await repository.getTodayUsage();
    final scanCount = usage?.scanCount ?? 0;
    if (scanCount < FeatureFlags.freeDailyScanLimit) return true;
    if (mounted) {
      final access = await premiumAccessService.canAccessPremiumFeature(
        PremiumFeature.unlimitedScans,
      );
      if (!mounted) return false;
      await showPremiumGateDialog(
        context,
        feature: PremiumFeature.unlimitedScans,
        result: access.copyWith(messageKey: 'freeDailyScanLimitReached'),
      );
    }
    return false;
  }

  Future<void> _showScanLimit() async {
    final access = await premiumAccessService.canAccessPremiumFeature(
      PremiumFeature.unlimitedScans,
    );
    if (!mounted) return;
    await showPremiumGateDialog(
      context,
      feature: PremiumFeature.unlimitedScans,
      result: access,
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : controller == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          l.cameraPermissionDescription,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : CameraPreview(controller!),
            ),
            PositionedDirectional(
              top: AppSpacing.sm,
              start: AppSpacing.sm,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: l.importFromGallery,
                      onPressed: _gallery,
                      icon: const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    GestureDetector(
                      onTap: _capture,
                      child: const CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 27,
                          backgroundColor: AppColors.interactive,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
