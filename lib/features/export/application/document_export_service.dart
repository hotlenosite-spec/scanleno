import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../files/application/local_file_repository.dart';
import '../../scanner/application/document_draft_controller.dart';

enum ExportFormat { pdf, jpg }

enum ExportPageSize { a4, letter, legal, original }

enum ExportQuality { low, medium, high }

class DocumentExportOptions {
  const DocumentExportOptions({
    required this.fileName,
    required this.format,
    required this.pageSize,
    required this.quality,
  });

  final String fileName;
  final ExportFormat format;
  final ExportPageSize pageSize;
  final ExportQuality quality;
}

class DocumentExportService {
  Future<List<File>> save({
    required List<DraftPage> pages,
    required DocumentExportOptions options,
  }) async {
    if (pages.isEmpty) return const [];
    final directory = await getApplicationDocumentsDirectory();
    final outputDirectory = Directory('${directory.path}/ScanLeno');
    if (!outputDirectory.existsSync()) {
      await outputDirectory.create(recursive: true);
    }

    final safeName = _safeFileName(options.fileName);
    return switch (options.format) {
      ExportFormat.pdf => [
        await _savePdf(pages, options, outputDirectory, safeName),
      ],
      ExportFormat.jpg => _saveJpgPages(
        pages,
        options,
        outputDirectory,
        safeName,
      ),
    };
  }

  Future<void> registerExportedFiles({
    required List<File> files,
    required ExportFormat format,
    required int pageCount,
    String? thumbnailPath,
  }) {
    return LocalFileRepository().registerFiles(
      files: files,
      type: format == ExportFormat.pdf
          ? StoredDocumentType.pdf
          : StoredDocumentType.image,
      pageCount: pageCount,
      thumbnailPath: thumbnailPath,
    );
  }

  Future<void> share(List<File> files) {
    return SharePlus.instance.share(
      ShareParams(files: files.map((file) => XFile(file.path)).toList()),
    );
  }

  Future<File> _savePdf(
    List<DraftPage> pages,
    DocumentExportOptions options,
    Directory outputDirectory,
    String safeName,
  ) async {
    final document = pw.Document();
    for (final page in pages) {
      final imageBytes = await _processedJpgBytes(page, options.quality);
      final memoryImage = pw.MemoryImage(imageBytes);
      document.addPage(
        pw.Page(
          pageFormat: _pdfPageFormat(options.pageSize),
          build: (_) => pw.Center(
            child: pw.Image(memoryImage, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

    final output = File('${outputDirectory.path}/$safeName.pdf');
    await output.writeAsBytes(await document.save());
    return output;
  }

  Future<List<File>> _saveJpgPages(
    List<DraftPage> pages,
    DocumentExportOptions options,
    Directory outputDirectory,
    String safeName,
  ) async {
    final files = <File>[];
    for (var i = 0; i < pages.length; i++) {
      final suffix = pages.length == 1 ? '' : '-${i + 1}';
      final output = File('${outputDirectory.path}/$safeName$suffix.jpg');
      await output.writeAsBytes(
        await _processedJpgBytes(pages[i], options.quality),
      );
      files.add(output);
    }
    return files;
  }

  Future<Uint8List> _processedJpgBytes(
    DraftPage page,
    ExportQuality quality,
  ) async {
    final source = img.decodeImage(await File(page.path).readAsBytes());
    if (source == null) {
      return File(page.path).readAsBytes();
    }

    var output = img.Image.from(source);
    output = switch (page.filter) {
      DocumentFilter.original => output,
      DocumentFilter.enhanced => img.adjustColor(
        output,
        brightness: 1.04,
        contrast: 1.16,
        saturation: 1.03,
      ),
      DocumentFilter.monochrome => img.luminanceThreshold(
        img.grayscale(output),
        threshold: 0.58,
      ),
      DocumentFilter.grayscale => img.grayscale(output),
      DocumentFilter.color => img.adjustColor(output, saturation: 1.16),
    };

    if (page.brightness != 0 || page.contrast != 0) {
      output = img.adjustColor(
        output,
        brightness: (1 + page.brightness).clamp(0.25, 1.75),
        contrast: (1 + page.contrast).clamp(0.2, 2.0),
      );
    }

    return Uint8List.fromList(img.encodeJpg(output, quality: _jpgQuality(quality)));
  }

  PdfPageFormat _pdfPageFormat(ExportPageSize size) {
    return switch (size) {
      ExportPageSize.a4 => PdfPageFormat.a4,
      ExportPageSize.letter => PdfPageFormat.letter,
      ExportPageSize.legal => PdfPageFormat.legal,
      ExportPageSize.original => PdfPageFormat.a4,
    };
  }

  int _jpgQuality(ExportQuality quality) {
    return switch (quality) {
      ExportQuality.low => 62,
      ExportQuality.medium => 80,
      ExportQuality.high => 94,
    };
  }

  String _safeFileName(String value) {
    final trimmed = value.trim().isEmpty ? 'scanleno-document' : value.trim();
    return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]+'), '-');
  }
}
