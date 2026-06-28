import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class CropQuad {
  const CropQuad({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  const CropQuad.defaultDocument()
    : topLeft = const Offset(.08, .08),
      topRight = const Offset(.92, .08),
      bottomRight = const Offset(.92, .92),
      bottomLeft = const Offset(.08, .92);

  final Offset topLeft;
  final Offset topRight;
  final Offset bottomRight;
  final Offset bottomLeft;

  List<Offset> get points => [topLeft, topRight, bottomRight, bottomLeft];

  CropQuad replacePoint(int index, Offset point) {
    final clamped = Offset(
      point.dx.clamp(.01, .99),
      point.dy.clamp(.01, .99),
    );
    return switch (index) {
      0 => CropQuad(
        topLeft: clamped,
        topRight: topRight,
        bottomRight: bottomRight,
        bottomLeft: bottomLeft,
      ),
      1 => CropQuad(
        topLeft: topLeft,
        topRight: clamped,
        bottomRight: bottomRight,
        bottomLeft: bottomLeft,
      ),
      2 => CropQuad(
        topLeft: topLeft,
        topRight: topRight,
        bottomRight: clamped,
        bottomLeft: bottomLeft,
      ),
      _ => CropQuad(
        topLeft: topLeft,
        topRight: topRight,
        bottomRight: bottomRight,
        bottomLeft: clamped,
      ),
    };
  }
}

class DocumentEdgeService {
  Future<CropQuad> detect(String path) async {
    final source = img.decodeImage(await File(path).readAsBytes());
    if (source == null) return const CropQuad.defaultDocument();

    final scale = math.min(420 / source.width, 420 / source.height);
    final work = scale < 1
        ? img.copyResize(
            source,
            width: (source.width * scale).round(),
            height: (source.height * scale).round(),
          )
        : source;
    final gray = img.grayscale(work);
    final points = <PointScore>[];
    final marginX = (gray.width * .04).round();
    final marginY = (gray.height * .04).round();

    for (var y = marginY + 1; y < gray.height - marginY - 1; y += 2) {
      for (var x = marginX + 1; x < gray.width - marginX - 1; x += 2) {
        final gx =
            _luminance(gray, x + 1, y - 1) +
            2 * _luminance(gray, x + 1, y) +
            _luminance(gray, x + 1, y + 1) -
            _luminance(gray, x - 1, y - 1) -
            2 * _luminance(gray, x - 1, y) -
            _luminance(gray, x - 1, y + 1);
        final gy =
            _luminance(gray, x - 1, y + 1) +
            2 * _luminance(gray, x, y + 1) +
            _luminance(gray, x + 1, y + 1) -
            _luminance(gray, x - 1, y - 1) -
            2 * _luminance(gray, x, y - 1) -
            _luminance(gray, x + 1, y - 1);
        final magnitude = gx.abs() + gy.abs();
        if (magnitude > 110) {
          points.add(PointScore(x.toDouble(), y.toDouble(), magnitude));
        }
      }
    }

    if (points.length < 80) return const CropQuad.defaultDocument();

    PointScore bestTopLeft = points.first;
    PointScore bestTopRight = points.first;
    PointScore bestBottomRight = points.first;
    PointScore bestBottomLeft = points.first;

    for (final point in points) {
      final weightedX = point.x / gray.width;
      final weightedY = point.y / gray.height;
      final edgeBoost = point.score / 2550;
      if (weightedX + weightedY - edgeBoost <
          bestTopLeft.x / gray.width + bestTopLeft.y / gray.height) {
        bestTopLeft = point;
      }
      if ((1 - weightedX) + weightedY - edgeBoost <
          (1 - bestTopRight.x / gray.width) + bestTopRight.y / gray.height) {
        bestTopRight = point;
      }
      if ((1 - weightedX) + (1 - weightedY) - edgeBoost <
          (1 - bestBottomRight.x / gray.width) +
              (1 - bestBottomRight.y / gray.height)) {
        bestBottomRight = point;
      }
      if (weightedX + (1 - weightedY) - edgeBoost <
          bestBottomLeft.x / gray.width + (1 - bestBottomLeft.y / gray.height)) {
        bestBottomLeft = point;
      }
    }

    final quad = CropQuad(
      topLeft: Offset(bestTopLeft.x / gray.width, bestTopLeft.y / gray.height),
      topRight: Offset(
        bestTopRight.x / gray.width,
        bestTopRight.y / gray.height,
      ),
      bottomRight: Offset(
        bestBottomRight.x / gray.width,
        bestBottomRight.y / gray.height,
      ),
      bottomLeft: Offset(
        bestBottomLeft.x / gray.width,
        bestBottomLeft.y / gray.height,
      ),
    );

    return _looksUsable(quad) ? quad : const CropQuad.defaultDocument();
  }

  Future<String?> crop(String path, CropQuad quad) async {
    final source = img.decodeImage(await File(path).readAsBytes());
    if (source == null) return null;

    final sourceQuad = quad.points
        .map((point) => Offset(point.dx * source.width, point.dy * source.height))
        .toList();
    final topWidth = (sourceQuad[1] - sourceQuad[0]).distance;
    final bottomWidth = (sourceQuad[2] - sourceQuad[3]).distance;
    final leftHeight = (sourceQuad[3] - sourceQuad[0]).distance;
    final rightHeight = (sourceQuad[2] - sourceQuad[1]).distance;
    final width = math.max(96, ((topWidth + bottomWidth) / 2).round());
    final height = math.max(96, ((leftHeight + rightHeight) / 2).round());
    final output = img.Image(width: width, height: height);

    for (var y = 0; y < height; y++) {
      final v = height == 1 ? 0.0 : y / (height - 1);
      final left = Offset.lerp(sourceQuad[0], sourceQuad[3], v)!;
      final right = Offset.lerp(sourceQuad[1], sourceQuad[2], v)!;
      for (var x = 0; x < width; x++) {
        final u = width == 1 ? 0.0 : x / (width - 1);
        final sourcePoint = Offset.lerp(left, right, u)!;
        final color = source.getPixelInterpolate(
          sourcePoint.dx.clamp(0, source.width - 1),
          sourcePoint.dy.clamp(0, source.height - 1),
        );
        output.setPixel(x, y, color);
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/scanleno-crop-${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(img.encodeJpg(output, quality: 96));
    return file.path;
  }

  int _luminance(img.Image image, int x, int y) {
    return image.getPixelSafe(x, y).luminance.round();
  }

  bool _looksUsable(CropQuad quad) {
    final points = quad.points;
    final minX = points.map((point) => point.dx).reduce(math.min);
    final maxX = points.map((point) => point.dx).reduce(math.max);
    final minY = points.map((point) => point.dy).reduce(math.min);
    final maxY = points.map((point) => point.dy).reduce(math.max);
    return maxX - minX > .35 && maxY - minY > .35;
  }
}

class PointScore {
  const PointScore(this.x, this.y, this.score);

  final double x;
  final double y;
  final int score;
}
