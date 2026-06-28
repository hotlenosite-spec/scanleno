import 'package:drift/drift.dart';

import 'scanleno_database_connection.dart';

part 'scanleno_database.g.dart';

class AppFolders extends Table {
  TextColumn get id => text()();
  TextColumn get nameKey => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DocumentRecord')
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get fileType => text()();
  TextColumn get localPath => text().unique()();
  IntColumn get sizeBytes => integer()();
  IntColumn get pageCount => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get folderId => text().nullable().references(AppFolders, #id)();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get ocrText => text().nullable()();
  TextColumn get ocrProvider => text().nullable()();
  TextColumn get ocrModel => text().nullable()();
  DateTimeColumn get ocrCreatedAt => dateTime().nullable()();
  TextColumn get ocrLanguage => text().nullable()();
  RealColumn get ocrConfidence => real().nullable()();
  IntColumn get ocrPageIndex => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SignatureRecord')
class SavedSignatures extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get colorValue => integer()();
  TextColumn get strokesJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('UserSettingRecord')
class UserSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('DailyUsageRecord')
class DailyUsage extends Table {
  TextColumn get day => text()();
  IntColumn get scanCount => integer().withDefault(const Constant(0))();
  IntColumn get imageImportCount => integer().withDefault(const Constant(0))();
  IntColumn get imageToPdfCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {day};
}

@DriftDatabase(
  tables: [AppFolders, Documents, SavedSignatures, UserSettings, DailyUsage],
)
class ScanLenoDatabase extends _$ScanLenoDatabase {
  ScanLenoDatabase() : super(openScanLenoConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(documents, documents.ocrProvider);
        await migrator.addColumn(documents, documents.ocrModel);
        await migrator.addColumn(documents, documents.ocrCreatedAt);
        await migrator.addColumn(documents, documents.ocrLanguage);
        await migrator.addColumn(documents, documents.ocrConfidence);
        await migrator.addColumn(documents, documents.ocrPageIndex);
      }
    },
  );

  Future<void> ensureDefaultFolders() async {
    final existingCount = await (select(appFolders)..limit(1)).get();
    if (existingCount.isNotEmpty) return;
    final now = DateTime.now();
    await batch((batch) {
      batch.insertAll(appFolders, [
        AppFoldersCompanion.insert(
          id: 'contracts',
          nameKey: 'folderContracts',
          createdAt: now,
          isSystem: const Value(true),
        ),
        AppFoldersCompanion.insert(
          id: 'invoices',
          nameKey: 'folderInvoices',
          createdAt: now,
          isSystem: const Value(true),
        ),
        AppFoldersCompanion.insert(
          id: 'identity',
          nameKey: 'folderIdentity',
          createdAt: now,
          isSystem: const Value(true),
        ),
      ]);
    });
  }
}

final scanLenoDatabase = ScanLenoDatabase();
