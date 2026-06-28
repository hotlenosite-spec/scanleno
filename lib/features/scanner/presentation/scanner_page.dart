import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../application/document_draft_controller.dart';
import '../application/document_edge_service.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final edgeService = DocumentEdgeService();
  bool detecting = false;
  bool cropping = false;
  String? detectingPath;

  Future<void> _detectEdges() async {
    if (!documentDraft.hasPages || detecting) return;
    final page = documentDraft.currentPage;
    detectingPath = page.path;
    setState(() => detecting = true);
    try {
      final quad = await edgeService.detect(page.path);
      if (mounted && documentDraft.hasPages && detectingPath == page.path) {
        documentDraft.updateCurrentDetection(quad);
      }
    } finally {
      if (mounted) setState(() => detecting = false);
    }
  }

  Future<void> _continue() async {
    if (cropping) return;
    setState(() => cropping = true);
    try {
      await documentDraft.applyCurrentCrop();
      if (mounted) Navigator.of(context).pushNamed(AppRoutes.editor);
    } finally {
      if (mounted) setState(() => cropping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AnimatedBuilder(
      animation: documentDraft,
      builder: (context, _) {
        if (!documentDraft.hasPages) {
          return AppScreen(
            title: l.cropDocument,
            showBack: true,
            child: Center(
              child: SoftCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.document_scanner_outlined,
                      color: AppColors.interactive,
                      size: 56,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l.noDocumentPages,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.scanner),
                      child: Text(l.openScanner),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final page = documentDraft.currentPage;
        if (!page.edgesDetected && !detecting && detectingPath != page.path) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _detectEdges());
        }

        return AppScreen(
          title: l.cropDocument,
          showBack: true,
          bottomAction: FilledButton(
            onPressed: cropping ? null : _continue,
            child: cropping
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l.continueLabel),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C241E),
                    borderRadius: AppRadii.large,
                    boxShadow: AppShadows.card,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _EdgeCropPreview(
                          imagePath: page.path,
                          quad: page.cropQuad,
                          onChanged: documentDraft.updateCurrentCrop,
                        ),
                      ),
                      if (detecting)
                        const Positioned.fill(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      PositionedDirectional(
                        end: AppSpacing.sm,
                        bottom: AppSpacing.sm,
                        child: _PageBadge(
                          text:
                              '${documentDraft.currentIndex + 1}/${documentDraft.pages.length}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.large,
                  boxShadow: AppShadows.card,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionItem(
                        icon: Icons.camera_alt_outlined,
                        label: l.retake,
                        onTap: () => Navigator.of(
                          context,
                        ).pushReplacementNamed(AppRoutes.scanner),
                      ),
                    ),
                    Expanded(
                      child: _ActionItem(
                        icon: Icons.rotate_90_degrees_cw_rounded,
                        label: l.rotate,
                        onTap: documentDraft.rotateCurrent,
                      ),
                    ),
                    Expanded(
                      child: _ActionItem(
                        icon: Icons.auto_fix_high_rounded,
                        label: l.detectEdges,
                        onTap: _detectEdges,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: cropping ? null : _continue,
                        child: Text(l.continueLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EdgeCropPreview extends StatelessWidget {
  const _EdgeCropPreview({
    required this.imagePath,
    required this.quad,
    required this.onChanged,
  });

  final String imagePath;
  final CropQuad quad;
  final ValueChanged<CropQuad> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder<Size>(
          future: _imageSize(imagePath),
          builder: (context, snapshot) {
            final imageSize = snapshot.data;
            if (imageSize == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final rect = _containedRect(
              Size(constraints.maxWidth, constraints.maxHeight),
              imageSize,
            );
            return Stack(
              children: [
                Positioned.fromRect(
                  rect: rect,
                  child: ClipRRect(
                    borderRadius: AppRadii.small,
                    child: Image.file(File(imagePath), fit: BoxFit.fill),
                  ),
                ),
                Positioned.fromRect(
                  rect: rect,
                  child: CustomPaint(painter: _CropPainter(quad)),
                ),
                for (var index = 0; index < quad.points.length; index++)
                  _Handle(
                    rect: rect,
                    point: quad.points[index],
                    onDrag: (localPoint) {
                      final normalized = Offset(
                        (localPoint.dx - rect.left) / rect.width,
                        (localPoint.dy - rect.top) / rect.height,
                      );
                      onChanged(quad.replacePoint(index, normalized));
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<Size> _imageSize(String path) async {
    final image = await decodeImageFromList(await File(path).readAsBytes());
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  Rect _containedRect(Size outer, Size image) {
    final scale = outer.width / image.width < outer.height / image.height
        ? outer.width / image.width
        : outer.height / image.height;
    final width = image.width * scale;
    final height = image.height * scale;
    return Rect.fromLTWH(
      (outer.width - width) / 2,
      (outer.height - height) / 2,
      width,
      height,
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle({
    required this.rect,
    required this.point,
    required this.onDrag,
  });

  final Rect rect;
  final Offset point;
  final ValueChanged<Offset> onDrag;

  @override
  Widget build(BuildContext context) {
    final center = Offset(
      rect.left + point.dx * rect.width,
      rect.top + point.dy * rect.height,
    );
    return Positioned(
      left: center.dx - 18,
      top: center.dy - 18,
      width: 36,
      height: 36,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => onDrag(
          Offset(center.dx - 18 + details.localPosition.dx,
              center.dy - 18 + details.localPosition.dy),
        ),
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.interactive,
              border: Border.all(color: Colors.white, width: 3),
              shape: BoxShape.circle,
              boxShadow: AppShadows.card,
            ),
          ),
        ),
      ),
    );
  }
}

class _CropPainter extends CustomPainter {
  const _CropPainter(this.quad);

  final CropQuad quad;

  @override
  void paint(Canvas canvas, Size size) {
    final points = quad.points
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList();
    final fill = Paint()
      ..color = AppColors.interactive.withValues(alpha: .08)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppColors.interactive
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..lineTo(points[1].dx, points[1].dy)
      ..lineTo(points[2].dx, points[2].dy)
      ..lineTo(points[3].dx, points[3].dy)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _CropPainter oldDelegate) {
    return oldDelegate.quad != quad;
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.medium,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PageBadge extends StatelessWidget {
  const _PageBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .55),
        borderRadius: AppRadii.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
