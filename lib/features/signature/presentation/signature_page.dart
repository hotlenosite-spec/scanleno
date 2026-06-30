import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/feature_flags.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_screen.dart';
import '../../files/application/local_file_repository.dart';
import '../../premium/application/premium_access_service.dart';
import '../../premium/presentation/premium_gate_dialog.dart';
import '../../scanner/application/document_draft_controller.dart';
import '../application/signature_repository.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final repository = SignatureRepository();
  final previewKey = GlobalKey();
  final strokes = <List<Offset>>[];
  final placed = <_PlacedSignature>[];
  List<SavedSignature> saved = [];
  Color selectedColor = AppColors.interactive;
  double selectedScale = 1;
  int? selectedPlacedIndex;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    saved = await repository.load();
    if (mounted) setState(() {});
  }

  Future<void> _saveSignature() async {
    if (strokes.isEmpty) return;
    if (!await _ensurePremiumAccess()) return;
    await repository.save(strokes, selectedColor.toARGB32());
    strokes.clear();
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.signatureSaved)),
      );
    }
  }

  Future<void> _saveSignedDocument() async {
    if (!documentDraft.hasPages) return;
    if (!await _ensurePremiumAccess()) return;
    final boundary = previewKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/ScanLeno/signed-${DateTime.now().microsecondsSinceEpoch}.png',
    );
    if (!file.parent.existsSync()) await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes.buffer.asUint8List());
    await LocalFileRepository().registerFiles(
      files: [file],
      type: StoredDocumentType.image,
      pageCount: 1,
      thumbnailPath: file.path,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.signedDocumentSaved)),
      );
    }
  }

  Future<bool> _ensurePremiumAccess() async {
    final access = await premiumAccessService.canAccessPremiumFeature(
      PremiumFeature.signature,
    );
    if (!mounted) return false;
    if (access.allowed) return true;
    await showPremiumGateDialog(
      context,
      feature: PremiumFeature.signature,
      result: access,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (!FeatureFlags.signatureEnabled) {
      return AppScreen(
        title: l.signDocument,
        showBack: true,
        child: Center(child: SoftCard(child: Text(l.toolUnavailable))),
      );
    }
    if (!documentDraft.hasPages) {
      return AppScreen(
        title: l.signDocument,
        showBack: true,
        child: Center(
          child: FilledButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.scanner),
            child: Text(l.openScanner),
          ),
        ),
      );
    }

    return AppScreen(
      title: l.signDocument,
      showBack: true,
      bottomAction: FilledButton(
        onPressed: _saveSignedDocument,
        child: Text(l.saveSignedDocument),
      ),
      child: ListView(
        children: [
          AspectRatio(
            aspectRatio: .78,
            child: RepaintBoundary(
              key: previewKey,
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(
                        File(documentDraft.currentPage.path),
                        fit: BoxFit.contain,
                      ),
                    ),
                    for (var i = 0; i < placed.length; i++)
                      _PlacedSignatureWidget(
                        signature: placed[i],
                        selected: selectedPlacedIndex == i,
                        onTap: () => setState(() => selectedPlacedIndex = i),
                        onMove: (position) => setState(
                          () => placed[i] = placed[i].copyWith(position: position),
                        ),
                        onScale: (scale) => setState(
                          () => placed[i] = placed[i].copyWith(scale: scale),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _ColorDots(selected: selectedColor, onChanged: (color) => setState(() => selectedColor = color))),
              IconButton(
                tooltip: l.deleteSignature,
                onPressed: selectedPlacedIndex == null
                    ? null
                    : () => setState(() => placed.removeAt(selectedPlacedIndex!)),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l.addSignature, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.medium,
              border: Border.all(color: AppColors.outline),
            ),
            child: _SignaturePad(
              strokes: strokes,
              color: selectedColor,
              onChanged: () => setState(() {}),
            ),
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(strokes.clear),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l.clear),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _saveSignature,
                icon: const Icon(Icons.save_outlined),
                label: Text(l.saveSignature),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l.savedSignatures, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.sm),
          if (saved.isEmpty)
            SoftCard(child: Text(l.noSavedSignatures, style: const TextStyle(color: AppColors.muted)))
          else
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: saved.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final signature = saved[index];
                  return _SavedSignatureTile(
                    signature: signature,
                    onTap: () => setState(
                      () => placed.add(
                        _PlacedSignature(
                          saved: signature,
                          position: const Offset(.5, .72),
                          scale: selectedScale,
                        ),
                      ),
                    ),
                    onDelete: () async {
                      await repository.delete(signature.id);
                      await _load();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SignaturePad extends StatelessWidget {
  const _SignaturePad({
    required this.strokes,
    required this.color,
    required this.onChanged,
  });

  final List<List<Offset>> strokes;
  final Color color;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onPanStart: (details) {
          strokes.add([_normalized(details.localPosition, constraints.biggest)]);
          onChanged();
        },
        onPanUpdate: (details) {
          if (strokes.isEmpty) return;
          strokes.last.add(_normalized(details.localPosition, constraints.biggest));
          onChanged();
        },
        child: CustomPaint(
          painter: _SignaturePainter(strokes: strokes, color: color),
          child: Center(
            child: strokes.isEmpty
                ? Text(context.l10n.signatureHint, style: const TextStyle(color: AppColors.muted))
                : null,
          ),
        ),
      ),
    );
  }

  Offset _normalized(Offset point, Size size) {
    return Offset(
      (point.dx / size.width).clamp(0, 1),
      (point.dy / size.height).clamp(0, 1),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter({required this.strokes, required this.color});

  final List<List<Offset>> strokes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx * size.width, stroke.first.dy * size.height);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}

class _SavedSignatureTile extends StatelessWidget {
  const _SavedSignatureTile({
    required this.signature,
    required this.onTap,
    required this.onDelete,
  });

  final SavedSignature signature;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.medium,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.medium,
          border: Border.all(color: AppColors.outline),
          boxShadow: AppShadows.card,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SignaturePainter(
                  strokes: signature.strokes,
                  color: Color(signature.colorValue),
                ),
              ),
            ),
            PositionedDirectional(
              top: 0,
              end: 0,
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlacedSignatureWidget extends StatelessWidget {
  const _PlacedSignatureWidget({
    required this.signature,
    required this.selected,
    required this.onTap,
    required this.onMove,
    required this.onScale,
  });

  final _PlacedSignature signature;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<Offset> onMove;
  final ValueChanged<double> onScale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = 180 * signature.scale;
        final height = 76 * signature.scale;
        return Positioned(
          left: signature.position.dx * constraints.maxWidth - width / 2,
          top: signature.position.dy * constraints.maxHeight - height / 2,
          width: width,
          height: height,
          child: GestureDetector(
            onTap: onTap,
            onPanUpdate: (details) {
              onMove(
                Offset(
                  signature.position.dx + details.delta.dx / constraints.maxWidth,
                  signature.position.dy + details.delta.dy / constraints.maxHeight,
                ),
              );
            },
            onScaleUpdate: (details) => onScale((signature.scale * details.scale).clamp(.55, 2.4)),
            child: Container(
              decoration: BoxDecoration(
                border: selected ? Border.all(color: AppColors.interactive, width: 1.6) : null,
              ),
              child: CustomPaint(
                painter: _SignaturePainter(
                  strokes: signature.saved.strokes,
                  color: Color(signature.saved.colorValue),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ColorDots extends StatelessWidget {
  const _ColorDots({required this.selected, required this.onChanged});

  final Color selected;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.interactive,
      Colors.black,
      Colors.red,
      Colors.green,
      Colors.purple,
    ];
    return Row(
      children: [
        for (final color in colors)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
            child: InkWell(
              onTap: () => onChanged(color),
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                backgroundColor: color,
                child: selected == color
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _PlacedSignature {
  const _PlacedSignature({
    required this.saved,
    required this.position,
    required this.scale,
  });

  final SavedSignature saved;
  final Offset position;
  final double scale;

  _PlacedSignature copyWith({Offset? position, double? scale}) =>
      _PlacedSignature(
        saved: saved,
        position: position ?? this.position,
        scale: scale ?? this.scale,
      );
}
