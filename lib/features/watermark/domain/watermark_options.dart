import 'dart:io';
import 'dart:ui';

enum WatermarkKind { text, image }

enum WatermarkPosition { center, top, bottom, right, left }

enum WatermarkScope { allPages, currentPage }

class WatermarkOptions {
  const WatermarkOptions({
    required this.kind,
    required this.text,
    required this.fontSize,
    required this.color,
    required this.opacity,
    required this.rotationDegrees,
    required this.position,
    required this.repeated,
    required this.scope,
    this.imageFile,
    this.imageScale = 0.24,
    this.pageIndex = 0,
  });

  factory WatermarkOptions.scanLenoDefault() => const WatermarkOptions(
    kind: WatermarkKind.text,
    text: 'ScanLeno',
    fontSize: 34,
    color: Color(0xFF0A2A66),
    opacity: 0.14,
    rotationDegrees: -28,
    position: WatermarkPosition.center,
    repeated: true,
    scope: WatermarkScope.allPages,
  );

  final WatermarkKind kind;
  final String text;
  final double fontSize;
  final Color color;
  final double opacity;
  final double rotationDegrees;
  final WatermarkPosition position;
  final bool repeated;
  final WatermarkScope scope;
  final File? imageFile;
  final double imageScale;
  final int pageIndex;

  WatermarkOptions copyWith({
    WatermarkKind? kind,
    String? text,
    double? fontSize,
    Color? color,
    double? opacity,
    double? rotationDegrees,
    WatermarkPosition? position,
    bool? repeated,
    WatermarkScope? scope,
    File? imageFile,
    double? imageScale,
    int? pageIndex,
  }) {
    return WatermarkOptions(
      kind: kind ?? this.kind,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      position: position ?? this.position,
      repeated: repeated ?? this.repeated,
      scope: scope ?? this.scope,
      imageFile: imageFile ?? this.imageFile,
      imageScale: imageScale ?? this.imageScale,
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }
}
