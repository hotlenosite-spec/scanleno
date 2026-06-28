import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/scanleno_database.dart';

enum StoredDocumentType { pdf, image, text }

enum FileSortMode { newest, oldest, name, size }

enum FileFilterMode { all, pdf, images, favorites, trash }

class LocalFolder {
  const LocalFolder({
    required this.id,
    required this.nameKey,
    required this.createdAt,
    this.isSystem = false,
  });

  final String id;
  final String nameKey;
  final DateTime createdAt;
  final bool isSystem;

  factory LocalFolder.fromRecord(AppFolder record) => LocalFolder(
    id: record.id,
    nameKey: record.nameKey,
    createdAt: record.createdAt,
    isSystem: record.isSystem,
  );
}

class StoredDocument {
  const StoredDocument({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.sizeBytes,
    required this.pageCount,
    this.thumbnailPath,
    this.folderId,
    this.ocrText,
    this.ocrProvider,
    this.ocrModel,
    this.ocrCreatedAt,
    this.ocrLanguage,
    this.ocrConfidence,
    this.ocrPageIndex,
    this.isFavorite = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String path;
  final StoredDocumentType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sizeBytes;
  final int pageCount;
  final String? thumbnailPath;
  final String? folderId;
  final String? ocrText;
  final String? ocrProvider;
  final String? ocrModel;
  final DateTime? ocrCreatedAt;
  final String? ocrLanguage;
  final double? ocrConfidence;
  final int? ocrPageIndex;
  final bool isFavorite;
  final bool isDeleted;
  final DateTime? deletedAt;

  factory StoredDocument.fromRecord(DocumentRecord record) => StoredDocument(
    id: record.id,
    name: record.name,
    path: record.localPath,
    type: StoredDocumentType.values.byName(record.fileType),
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
    sizeBytes: record.sizeBytes,
    pageCount: record.pageCount,
    thumbnailPath: record.thumbnailPath,
    folderId: record.folderId,
    ocrText: record.ocrText,
    ocrProvider: record.ocrProvider,
    ocrModel: record.ocrModel,
    ocrCreatedAt: record.ocrCreatedAt,
    ocrLanguage: record.ocrLanguage,
    ocrConfidence: record.ocrConfidence,
    ocrPageIndex: record.ocrPageIndex,
    isFavorite: record.isFavorite,
    isDeleted: record.isDeleted,
    deletedAt: record.deletedAt,
  );
}

class LocalFileState {
  const LocalFileState({required this.folders, required this.documents});

  final List<LocalFolder> folders;
  final List<StoredDocument> documents;
}

class LocalFileRepository {
  LocalFileRepository({ScanLenoDatabase? database})
    : database = database ?? scanLenoDatabase;

  final ScanLenoDatabase database;

  Future<LocalFileState> load() async {
    await database.ensureDefaultFolders();
    await _migrateLegacyJsonIfNeeded();
    await _discoverSavedFiles();
    final folders = await database.select(database.appFolders).get();
    final documents = await database.select(database.documents).get();
    return LocalFileState(
      folders: folders.map(LocalFolder.fromRecord).toList(),
      documents: documents
          .where((document) => File(document.localPath).existsSync())
          .map(StoredDocument.fromRecord)
          .toList(),
    );
  }

  Future<void> registerFiles({
    required List<File> files,
    required StoredDocumentType type,
    required int pageCount,
    String? thumbnailPath,
  }) async {
    await database.ensureDefaultFolders();
    final now = DateTime.now();
    for (final file in files) {
      if (!file.existsSync()) continue;
      final existing = await (database.select(database.documents)
            ..where((document) => document.localPath.equals(file.path)))
          .getSingleOrNull();
      if (existing != null) continue;
      await database.into(database.documents).insert(
        DocumentsCompanion.insert(
          id: '${now.microsecondsSinceEpoch}${file.path.hashCode}',
          name: _nameWithoutExtension(file),
          fileType: type.name,
          localPath: file.path,
          sizeBytes: await file.length(),
          pageCount: Value(pageCount),
          createdAt: now,
          updatedAt: now,
          thumbnailPath: Value(thumbnailPath),
        ),
      );
    }
  }

  Future<void> createFolder(String name) async {
    final now = DateTime.now();
    await database.into(database.appFolders).insert(
      AppFoldersCompanion.insert(
        id: now.microsecondsSinceEpoch.toString(),
        nameKey: name,
        createdAt: now,
      ),
    );
  }

  Future<void> renameFolder(String id, String name) async {
    await (database.update(database.appFolders)..where((row) => row.id.equals(id)))
        .write(AppFoldersCompanion(nameKey: Value(name)));
  }

  Future<void> deleteFolder(String id) async {
    await (database.update(database.documents)
          ..where((document) => document.folderId.equals(id)))
        .write(const DocumentsCompanion(folderId: Value(null)));
    await (database.delete(database.appFolders)..where((row) => row.id.equals(id)))
        .go();
  }

  Future<void> renameDocument(String id, String name) async {
    await _updateDocument(id, DocumentsCompanion(name: Value(name)));
  }

  Future<void> moveDocument(String id, String? folderId) async {
    await _updateDocument(id, DocumentsCompanion(folderId: Value(folderId)));
  }

  Future<void> toggleFavorite(String id) async {
    final document = await _documentById(id);
    if (document == null) return;
    await _updateDocument(
      id,
      DocumentsCompanion(isFavorite: Value(!document.isFavorite)),
    );
  }

  Future<void> moveToTrash(String id) async {
    await _updateDocument(
      id,
      DocumentsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreFromTrash(String id) async {
    await _updateDocument(
      id,
      const DocumentsCompanion(isDeleted: Value(false), deletedAt: Value(null)),
    );
  }

  Future<void> saveOcrText(String documentId, String text) async {
    await _updateDocument(documentId, DocumentsCompanion(ocrText: Value(text)));
  }

  Future<void> saveOcrResult({
    required String documentId,
    required String text,
    required String provider,
    required String model,
    required DateTime createdAt,
    required int pageIndex,
    String? language,
    double? confidence,
  }) async {
    await _updateDocument(
      documentId,
      DocumentsCompanion(
        ocrText: Value(text),
        ocrProvider: Value(provider),
        ocrModel: Value(model),
        ocrCreatedAt: Value(createdAt),
        ocrLanguage: Value(language),
        ocrConfidence: Value(confidence),
        ocrPageIndex: Value(pageIndex),
      ),
    );
  }

  Future<void> saveOcrTextForPath(String localPath, String text) async {
    final document = await (database.select(database.documents)
          ..where((row) => row.localPath.equals(localPath)))
        .getSingleOrNull();
    if (document == null) return;
    await saveOcrText(document.id, text);
  }

  Future<StoredDocument?> findDocumentByPath(String localPath) async {
    final document = await (database.select(database.documents)
          ..where((row) => row.localPath.equals(localPath)))
        .getSingleOrNull();
    return document == null ? null : StoredDocument.fromRecord(document);
  }

  Future<void> incrementDailyUsage({
    int scans = 0,
    int imageImports = 0,
    int imageToPdf = 0,
  }) async {
    final now = DateTime.now();
    final day =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final existing = await (database.select(database.dailyUsage)
          ..where((row) => row.day.equals(day)))
        .getSingleOrNull();
    if (existing == null) {
      await database.into(database.dailyUsage).insert(
        DailyUsageCompanion.insert(
          day: day,
          scanCount: Value(scans),
          imageImportCount: Value(imageImports),
          imageToPdfCount: Value(imageToPdf),
          updatedAt: now,
        ),
      );
      return;
    }
    await (database.update(database.dailyUsage)..where((row) => row.day.equals(day)))
        .write(
      DailyUsageCompanion(
        scanCount: Value(existing.scanCount + scans),
        imageImportCount: Value(existing.imageImportCount + imageImports),
        imageToPdfCount: Value(existing.imageToPdfCount + imageToPdf),
        updatedAt: Value(now),
      ),
    );
  }

  Future<DailyUsageRecord?> getTodayUsage() async {
    final now = DateTime.now();
    final day =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return (database.select(database.dailyUsage)
          ..where((row) => row.day.equals(day)))
        .getSingleOrNull();
  }

  Future<void> saveSetting(String key, String value) async {
    await database.into(database.userSettings).insertOnConflictUpdate(
      UserSettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<String?> getSetting(String key) async {
    final record = await (database.select(database.userSettings)
          ..where((row) => row.key.equals(key)))
        .getSingleOrNull();
    return record?.value;
  }

  Future<int> getScanCredits() async {
    return int.tryParse(await getSetting('scan_credit') ?? '') ?? 0;
  }

  Future<void> addScanCredits(int amount) async {
    final current = await getScanCredits();
    await saveSetting('scan_credit', (current + amount).toString());
  }

  Future<bool> consumeScanCredit() async {
    final current = await getScanCredits();
    if (current <= 0) return false;
    await saveSetting('scan_credit', (current - 1).toString());
    return true;
  }

  Future<void> permanentlyDelete(String id) async {
    final document = await _documentById(id);
    if (document != null) {
      final file = File(document.localPath);
      if (file.existsSync()) await file.delete();
    }
    await (database.delete(database.documents)
          ..where((document) => document.id.equals(id)))
        .go();
  }

  Future<void> shareDocument(StoredDocument document) {
    return SharePlus.instance.share(
      ShareParams(files: [XFile(document.path)], title: document.name),
    );
  }

  Future<DocumentRecord?> _documentById(String id) {
    return (database.select(database.documents)
          ..where((document) => document.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> _updateDocument(String id, DocumentsCompanion companion) async {
    await (database.update(database.documents)
          ..where((document) => document.id.equals(id)))
        .write(companion.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> _discoverSavedFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final savedDirectory = Directory('${directory.path}/ScanLeno');
    if (!savedDirectory.existsSync()) return;
    for (final entity in savedDirectory.listSync()) {
      if (entity is! File) continue;
      final existing = await (database.select(database.documents)
            ..where((document) => document.localPath.equals(entity.path)))
          .getSingleOrNull();
      if (existing != null) continue;
      final extension = entity.path.split('.').last.toLowerCase();
      final type = switch (extension) {
        'pdf' => StoredDocumentType.pdf,
        'jpg' || 'jpeg' || 'png' => StoredDocumentType.image,
        'txt' => StoredDocumentType.text,
        _ => null,
      };
      if (type == null) continue;
      final stat = await entity.stat();
      await database.into(database.documents).insert(
        DocumentsCompanion.insert(
          id: '${stat.modified.microsecondsSinceEpoch}${entity.path.hashCode}',
          name: _nameWithoutExtension(entity),
          fileType: type.name,
          localPath: entity.path,
          sizeBytes: stat.size,
          createdAt: stat.modified,
          updatedAt: stat.modified,
        ),
      );
    }
  }

  Future<void> _migrateLegacyJsonIfNeeded() async {
    final migrated = await getSetting('legacy_json_files_migrated');
    if (migrated == 'true') return;
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/scanleno-files.json');
    if (!file.existsSync()) {
      await saveSetting('legacy_json_files_migrated', 'true');
      return;
    }
    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, Object?>;
      for (final folderJson in json['folders'] as List<dynamic>? ?? []) {
        final folder = folderJson as Map<String, Object?>;
        await database.into(database.appFolders).insertOnConflictUpdate(
          AppFoldersCompanion.insert(
            id: folder['id'] as String,
            nameKey: folder['nameKey'] as String,
            createdAt: DateTime.parse(folder['createdAt'] as String),
            isSystem: Value(folder['isSystem'] as bool? ?? false),
          ),
        );
      }
      for (final documentJson in json['documents'] as List<dynamic>? ?? []) {
        final item = documentJson as Map<String, Object?>;
        final path = item['path'] as String;
        final documentFile = File(path);
        if (!documentFile.existsSync()) continue;
        await database.into(database.documents).insertOnConflictUpdate(
          DocumentsCompanion.insert(
            id: item['id'] as String,
            name: item['name'] as String,
            fileType: item['type'] as String,
            localPath: path,
            sizeBytes: item['sizeBytes'] as int,
            pageCount: Value(item['pageCount'] as int? ?? 1),
            createdAt: DateTime.parse(item['createdAt'] as String),
            updatedAt: DateTime.parse(item['updatedAt'] as String),
            isFavorite: Value(item['isFavorite'] as bool? ?? false),
            isDeleted: Value(item['isDeleted'] as bool? ?? false),
            deletedAt: Value(
              item['deletedAt'] == null
                  ? null
                  : DateTime.parse(item['deletedAt'] as String),
            ),
            folderId: Value(item['folderId'] as String?),
            thumbnailPath: Value(item['thumbnailPath'] as String?),
          ),
        );
      }
    } finally {
      await saveSetting('legacy_json_files_migrated', 'true');
    }
  }

  String _nameWithoutExtension(File file) {
    final name = file.uri.pathSegments.last;
    final dot = name.lastIndexOf('.');
    return dot <= 0 ? name : name.substring(0, dot);
  }
}
