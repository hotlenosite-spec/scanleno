import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'document_edge_service.dart';

enum DocumentFilter { original, enhanced, monochrome, grayscale, color }

class DraftPage {
  DraftPage({
    required this.path,
    this.filter = DocumentFilter.original,
    this.brightness = 0,
    this.contrast = 0,
    this.cropQuad = const CropQuad.defaultDocument(),
    this.edgesDetected = false,
  });
  String path;
  DocumentFilter filter;
  double brightness;
  double contrast;
  CropQuad cropQuad;
  bool edgesDetected;
}

class DocumentDraftController extends ChangeNotifier {
  final List<DraftPage> pages = [];
  int currentIndex = 0;

  DraftPage get currentPage => pages[currentIndex];
  bool get hasPages => pages.isNotEmpty;

  void replaceWith(List<String> paths) { pages..clear()..addAll(paths.map((path) => DraftPage(path: path))); currentIndex = 0; notifyListeners(); }
  void addPages(List<String> paths) { pages.addAll(paths.map((path) => DraftPage(path: path))); notifyListeners(); }
  void removePage(int index) { pages.removeAt(index); currentIndex = currentIndex.clamp(0, pages.length - 1); notifyListeners(); }
  void reorder(int oldIndex, int newIndex) { if (newIndex > oldIndex) newIndex--; final page = pages.removeAt(oldIndex); pages.insert(newIndex, page); currentIndex = newIndex; notifyListeners(); }
  void rotateCurrent() { _transformCurrent((image) => img.copyRotate(image, angle: 90)); }
  void updateCurrent({DocumentFilter? filter, double? brightness, double? contrast}) { final page = currentPage; page.filter = filter ?? page.filter; page.brightness = brightness ?? page.brightness; page.contrast = contrast ?? page.contrast; notifyListeners(); }
  void updateCurrentCrop(CropQuad quad) { currentPage.cropQuad = quad; notifyListeners(); }
  void updateCurrentDetection(CropQuad quad) { final page = currentPage; page.cropQuad = quad; page.edgesDetected = true; notifyListeners(); }
  Future<void> applyCurrentCrop() async { final croppedPath = await DocumentEdgeService().crop(currentPage.path, currentPage.cropQuad); if (croppedPath == null) return; currentPage.path = croppedPath; currentPage.cropQuad = const CropQuad.defaultDocument(); currentPage.edgesDetected = false; notifyListeners(); }
  void resetCurrent() { final page = currentPage; page..filter = DocumentFilter.original..brightness = 0..contrast = 0; notifyListeners(); }
  Future<void> _transformCurrent(img.Image Function(img.Image) transform) async { final page = currentPage; final image = img.decodeImage(await File(page.path).readAsBytes()); if (image == null) return; final directory = await getApplicationDocumentsDirectory(); final output = File('${directory.path}/scanleno-${DateTime.now().microsecondsSinceEpoch}.jpg'); await output.writeAsBytes(img.encodeJpg(transform(image), quality: 95)); page.path = output.path; page.cropQuad = const CropQuad.defaultDocument(); page.edgesDetected = false; notifyListeners(); }
  Future<Uint8List> pageBytes(DraftPage page) => File(page.path).readAsBytes();
}

final documentDraft = DocumentDraftController();
