import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/scanleno_database.dart';

class SavedSignature {
  const SavedSignature({
    required this.id,
    required this.createdAt,
    required this.colorValue,
    required this.strokes,
  });

  final String id;
  final DateTime createdAt;
  final int colorValue;
  final List<List<Offset>> strokes;

  Map<String, Object?> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'colorValue': colorValue,
    'strokes': _strokesToJson(strokes),
  };

  factory SavedSignature.fromRecord(SignatureRecord record) => SavedSignature(
    id: record.id,
    createdAt: record.createdAt,
    colorValue: record.colorValue,
    strokes: _strokesFromJson(jsonDecode(record.strokesJson) as List<dynamic>),
  );

  factory SavedSignature.fromJson(Map<String, Object?> json) => SavedSignature(
    id: json['id'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    colorValue: json['colorValue'] as int,
    strokes: _strokesFromJson(json['strokes'] as List<dynamic>),
  );

  static List<List<Map<String, double>>> _strokesToJson(
    List<List<Offset>> strokes,
  ) {
    return [
      for (final stroke in strokes)
        [
          for (final point in stroke) {'x': point.dx, 'y': point.dy},
        ],
    ];
  }

  static List<List<Offset>> _strokesFromJson(List<dynamic> json) {
    return [
      for (final stroke in json)
        [
          for (final point in stroke as List<dynamic>)
            Offset(
              (point as Map<String, Object?>)['x'] as double,
              point['y'] as double,
            ),
        ],
    ];
  }
}

class SignatureRepository {
  SignatureRepository({ScanLenoDatabase? database})
    : database = database ?? scanLenoDatabase;

  final ScanLenoDatabase database;

  Future<List<SavedSignature>> load() async {
    await _migrateLegacyJsonIfNeeded();
    final rows = await (database.select(database.savedSignatures)
          ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
        .get();
    return rows.map(SavedSignature.fromRecord).toList();
  }

  Future<void> save(List<List<Offset>> strokes, int colorValue) async {
    final now = DateTime.now();
    await database.into(database.savedSignatures).insert(
      SavedSignaturesCompanion.insert(
        id: now.microsecondsSinceEpoch.toString(),
        createdAt: now,
        colorValue: colorValue,
        strokesJson: jsonEncode(SavedSignature._strokesToJson(strokes)),
      ),
    );
  }

  Future<void> delete(String id) async {
    await (database.delete(database.savedSignatures)
          ..where((signature) => signature.id.equals(id)))
        .go();
  }

  Future<void> _migrateLegacyJsonIfNeeded() async {
    final setting = await (database.select(database.userSettings)
          ..where((row) => row.key.equals('legacy_json_signatures_migrated')))
        .getSingleOrNull();
    if (setting?.value == 'true') return;

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/scanleno-signatures.json');
    if (file.existsSync()) {
      try {
        final json = jsonDecode(await file.readAsString()) as List<dynamic>;
        for (final item in json.cast<Map<String, Object?>>()) {
          final signature = SavedSignature.fromJson(item);
          await database.into(database.savedSignatures).insertOnConflictUpdate(
            SavedSignaturesCompanion.insert(
              id: signature.id,
              createdAt: signature.createdAt,
              colorValue: signature.colorValue,
              strokesJson: jsonEncode(
                SavedSignature._strokesToJson(signature.strokes),
              ),
            ),
          );
        }
      } catch (_) {
        // Ignore malformed legacy files. The app will continue with SQLite.
      }
    }

    await database.into(database.userSettings).insertOnConflictUpdate(
      UserSettingsCompanion.insert(
        key: 'legacy_json_signatures_migrated',
        value: 'true',
        updatedAt: DateTime.now(),
      ),
    );
  }
}
