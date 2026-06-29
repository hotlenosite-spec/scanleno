import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../export/application/document_export_service.dart';
import '../../files/application/local_file_repository.dart';
import '../../scanner/application/document_draft_controller.dart';
import '../domain/watermark_options.dart';

class WatermarkService {
  WatermarkService({LocalFileRepository? repository})
    : _repository = repository ?? LocalFileRepository();

  final LocalFileRepository _repository;

  Future<List<File>> saveWatermarkedDraft({
    required List<DraftPage> pages,
    required DocumentExportOptions exportOptions,
    required WatermarkOptions watermark,
  }) async {
    if (pages.isEmpty) return const [];
    final directory = await _outputDirectory();
    final safeName = _safeFileName('${exportOptions.fileName}_watermarked');
    final files = switch (exportOptions.format) {
      ExportFormat.pdf => [
        await _saveWatermarkedPdf(pages, exportOptions, watermark, directory, safeName),
      ],
      ExportFormat.jpg => await _saveWatermarkedImages(
        pages,
        exportOptions.quality,
        watermark,
        directory,
        safeName,
      ),
    };
    await _repository.registerFiles(
      files: files,
      type: exportOptions.format == ExportFormat.pdf
          ? StoredDocumentType.pdf
          : StoredDocumentType.image,
      pageCount: pages.length,
      thumbnailPath: pages.first.path,
      hasWatermark: true,
      watermarkType: watermark.kind.name,
    );
    return files;
  }

  Future<File> saveWatermarkedImageDocument({
    required StoredDocument document,
    required WatermarkOptions watermark,
  }) async {
    final source = File(document.path);
    final bytes = await source.readAsBytes();
    final outputBytes = await applyWatermarkToImageBytes(bytes, watermark);
    final directory = await _outputDirectory();
    final output = File('${directory.path}/${_safeFileName('${document.name}_watermarked')}.jpg');
    await output.writeAsBytes(outputBytes);
    await _repository.registerFiles(
      files: [output],
      type: StoredDocumentType.image,
      pageCount: 1,
      thumbnailPath: output.path,
      hasWatermark: true,
      watermarkType: watermark.kind.name,
    );
    return output;
  }

  Future<Uint8List> applyWatermarkToImageBytes(
    Uint8List bytes,
    WatermarkOptions options,
  ) async {
    final source = img.decodeImage(bytes);
    if (source == null) return bytes;
    final output = img.Image.from(source);
    if (options.kind == WatermarkKind.image && options.imageFile != null) {
      final logo = img.decodeImage(await options.imageFile!.readAsBytes());
      if (logo != null) {
        _drawImageWatermark(output, logo, options);
      }
    } else {
      _drawTextWatermark(output, options);
    }
    return Uint8List.fromList(img.encodeJpg(output, quality: 92));
  }

  Future<Uint8List> applyWatermarkToPdfImageBytes(
    Uint8List bytes,
    WatermarkOptions options,
  ) {
    return applyWatermarkToImageBytes(bytes, options);
  }

  Future<File> _saveWatermarkedPdf(
    List<DraftPage> pages,
    DocumentExportOptions exportOptions,
    WatermarkOptions watermark,
    Directory directory,
    String safeName,
  ) async {
    final document = pw.Document();
    final exporter = DocumentExportService();
    for (var i = 0; i < pages.length; i++) {
      final imageBytes = await exporter.processedJpgBytesForWatermark(
        pages[i],
        exportOptions.quality,
      );
      final pageWatermark = _appliesToPage(watermark, i)
          ? await applyWatermarkToPdfImageBytes(imageBytes, watermark)
          : imageBytes;
      document.addPage(
        pw.Page(
          pageFormat: exporter.pdfPageFormatForWatermark(exportOptions.pageSize),
          build: (_) => pw.Center(
            child: pw.Image(pw.MemoryImage(pageWatermark), fit: pw.BoxFit.contain),
          ),
        ),
      );
    }
    final output = File('${directory.path}/$safeName.pdf');
    await output.writeAsBytes(await document.save());
    return output;
  }

  Future<List<File>> _saveWatermarkedImages(
    List<DraftPage> pages,
    ExportQuality quality,
    WatermarkOptions watermark,
    Directory directory,
    String safeName,
  ) async {
    final exporter = DocumentExportService();
    final files = <File>[];
    for (var i = 0; i < pages.length; i++) {
      final suffix = pages.length == 1 ? '' : '-${i + 1}';
      final output = File('${directory.path}/$safeName$suffix.jpg');
      final imageBytes = await exporter.processedJpgBytesForWatermark(pages[i], quality);
      final watermarked = _appliesToPage(watermark, i)
          ? await applyWatermarkToImageBytes(imageBytes, watermark)
          : imageBytes;
      await output.writeAsBytes(watermarked);
      files.add(output);
    }
    return files;
  }

  void _drawTextWatermark(img.Image output, WatermarkOptions options) {
    final text = options.text.trim().isEmpty ? 'ScanLeno' : options.text.trim();
    final color = _imageColor(options.color, options.opacity);
    final font = options.fontSize >= 38 ? img.arial48 : img.arial24;
    if (options.repeated) {
      final stepX = math.max(180, text.length * options.fontSize * 2.0).round();
      final stepY = math.max(120, options.fontSize * 4.0).round();
      for (var y = -stepY; y < output.height + stepY; y += stepY) {
        for (var x = -stepX; x < output.width + stepX; x += stepX) {
          _drawRotatedText(output, text, x, y, font, color, options.rotationDegrees);
        }
      }
      return;
    }
    final point = _position(output.width, output.height, options);
    _drawRotatedText(output, text, point.x, point.y, font, color, options.rotationDegrees);
  }

  void _drawImageWatermark(
    img.Image output,
    img.Image logo,
    WatermarkOptions options,
  ) {
    final width = math.max(24, (output.width * options.imageScale).round());
    final resized = _withImageOpacity(
      img.copyResize(logo, width: width),
      options.opacity,
    );
    if (options.repeated) {
      final stepX = math.max(width + 60, width * 2);
      final stepY = math.max(resized.height + 60, resized.height * 2);
      for (var y = 0; y < output.height; y += stepY) {
        for (var x = 0; x < output.width; x += stepX) {
          img.compositeImage(output, resized, dstX: x, dstY: y);
        }
      }
      return;
    }
    final point = _position(output.width, output.height, options);
    img.compositeImage(
      output,
      resized,
      dstX: (point.x - resized.width / 2).round(),
      dstY: (point.y - resized.height / 2).round(),
    );
  }

  void _drawRotatedText(
    img.Image output,
    String text,
    int x,
    int y,
    img.BitmapFont font,
    img.Color color,
    double rotation,
  ) {
    final layerWidth = math.max(320, text.length * font.lineHeight * 2);
    final layerHeight = math.max(120, font.lineHeight * 4);
    final layer = img.Image(width: layerWidth, height: layerHeight, numChannels: 4);
    img.fill(layer, color: img.ColorRgba8(0, 0, 0, 0));
    img.drawString(
      layer,
      text,
      font: font,
      x: layerWidth ~/ 4,
      y: layerHeight ~/ 2,
      color: color,
    );
    final rotated = img.copyRotate(layer, angle: rotation);
    img.compositeImage(
      output,
      rotated,
      dstX: (x - rotated.width / 2).round(),
      dstY: (y - rotated.height / 2).round(),
    );
  }

  _Point _position(int width, int height, WatermarkOptions options) {
    return switch (options.position) {
      WatermarkPosition.center => _Point(width ~/ 2, height ~/ 2),
      WatermarkPosition.top => _Point(width ~/ 2, (height * 0.18).round()),
      WatermarkPosition.bottom => _Point(width ~/ 2, (height * 0.82).round()),
      WatermarkPosition.right => _Point((width * 0.78).round(), height ~/ 2),
      WatermarkPosition.left => _Point((width * 0.22).round(), height ~/ 2),
    };
  }

  bool _appliesToPage(WatermarkOptions options, int index) {
    return options.scope == WatermarkScope.allPages || options.pageIndex == index;
  }

  img.Color _imageColor(Color color, double opacity) {
    return img.ColorRgba8(
      (color.r * 255).round().clamp(0, 255),
      (color.g * 255).round().clamp(0, 255),
      (color.b * 255).round().clamp(0, 255),
      (opacity.clamp(0.05, 1.0) * 255).round(),
    );
  }

  img.Image _withImageOpacity(img.Image image, double opacity) {
    final alphaFactor = opacity.clamp(0.05, 1.0);
    final working = image.hasAlpha ? image : image.convert(numChannels: 4);
    for (final pixel in working) {
      working.setPixelRgba(
        pixel.x,
        pixel.y,
        pixel.r,
        pixel.g,
        pixel.b,
        pixel.a * alphaFactor,
      );
    }
    return working;
  }

  Future<Directory> _outputDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final outputDirectory = Directory('${directory.path}/ScanLeno');
    if (!outputDirectory.existsSync()) {
      await outputDirectory.create(recursive: true);
    }
    return outputDirectory;
  }

  String _safeFileName(String value) {
    final trimmed = value.trim().isEmpty ? 'scanleno-document' : value.trim();
    return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]+'), '-');
  }
}

class _Point {
  const _Point(this.x, this.y);

  final int x;
  final int y;
}
