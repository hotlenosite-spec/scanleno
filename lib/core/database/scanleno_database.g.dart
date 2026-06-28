// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanleno_database.dart';

// ignore_for_file: type=lint
class $AppFoldersTable extends AppFolders
    with TableInfo<$AppFoldersTable, AppFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nameKey, createdAt, isSystem];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppFolder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
    );
  }

  @override
  $AppFoldersTable createAlias(String alias) {
    return $AppFoldersTable(attachedDatabase, alias);
  }
}

class AppFolder extends DataClass implements Insertable<AppFolder> {
  final String id;
  final String nameKey;
  final DateTime createdAt;
  final bool isSystem;
  const AppFolder({
    required this.id,
    required this.nameKey,
    required this.createdAt,
    required this.isSystem,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name_key'] = Variable<String>(nameKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_system'] = Variable<bool>(isSystem);
    return map;
  }

  AppFoldersCompanion toCompanion(bool nullToAbsent) {
    return AppFoldersCompanion(
      id: Value(id),
      nameKey: Value(nameKey),
      createdAt: Value(createdAt),
      isSystem: Value(isSystem),
    );
  }

  factory AppFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppFolder(
      id: serializer.fromJson<String>(json['id']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nameKey': serializer.toJson<String>(nameKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSystem': serializer.toJson<bool>(isSystem),
    };
  }

  AppFolder copyWith({
    String? id,
    String? nameKey,
    DateTime? createdAt,
    bool? isSystem,
  }) => AppFolder(
    id: id ?? this.id,
    nameKey: nameKey ?? this.nameKey,
    createdAt: createdAt ?? this.createdAt,
    isSystem: isSystem ?? this.isSystem,
  );
  AppFolder copyWithCompanion(AppFoldersCompanion data) {
    return AppFolder(
      id: data.id.present ? data.id.value : this.id,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppFolder(')
          ..write('id: $id, ')
          ..write('nameKey: $nameKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSystem: $isSystem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nameKey, createdAt, isSystem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppFolder &&
          other.id == this.id &&
          other.nameKey == this.nameKey &&
          other.createdAt == this.createdAt &&
          other.isSystem == this.isSystem);
}

class AppFoldersCompanion extends UpdateCompanion<AppFolder> {
  final Value<String> id;
  final Value<String> nameKey;
  final Value<DateTime> createdAt;
  final Value<bool> isSystem;
  final Value<int> rowid;
  const AppFoldersCompanion({
    this.id = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppFoldersCompanion.insert({
    required String id,
    required String nameKey,
    required DateTime createdAt,
    this.isSystem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nameKey = Value(nameKey),
       createdAt = Value(createdAt);
  static Insertable<AppFolder> custom({
    Expression<String>? id,
    Expression<String>? nameKey,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSystem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameKey != null) 'name_key': nameKey,
      if (createdAt != null) 'created_at': createdAt,
      if (isSystem != null) 'is_system': isSystem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppFoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? nameKey,
    Value<DateTime>? createdAt,
    Value<bool>? isSystem,
    Value<int>? rowid,
  }) {
    return AppFoldersCompanion(
      id: id ?? this.id,
      nameKey: nameKey ?? this.nameKey,
      createdAt: createdAt ?? this.createdAt,
      isSystem: isSystem ?? this.isSystem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppFoldersCompanion(')
          ..write('id: $id, ')
          ..write('nameKey: $nameKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSystem: $isSystem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, DocumentRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileTypeMeta = const VerificationMeta(
    'fileType',
  );
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
    'file_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_folders (id)',
    ),
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrTextMeta = const VerificationMeta(
    'ocrText',
  );
  @override
  late final GeneratedColumn<String> ocrText = GeneratedColumn<String>(
    'ocr_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrProviderMeta = const VerificationMeta(
    'ocrProvider',
  );
  @override
  late final GeneratedColumn<String> ocrProvider = GeneratedColumn<String>(
    'ocr_provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrModelMeta = const VerificationMeta(
    'ocrModel',
  );
  @override
  late final GeneratedColumn<String> ocrModel = GeneratedColumn<String>(
    'ocr_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrCreatedAtMeta = const VerificationMeta(
    'ocrCreatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> ocrCreatedAt = GeneratedColumn<DateTime>(
    'ocr_created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrLanguageMeta = const VerificationMeta(
    'ocrLanguage',
  );
  @override
  late final GeneratedColumn<String> ocrLanguage = GeneratedColumn<String>(
    'ocr_language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrConfidenceMeta = const VerificationMeta(
    'ocrConfidence',
  );
  @override
  late final GeneratedColumn<double> ocrConfidence = GeneratedColumn<double>(
    'ocr_confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrPageIndexMeta = const VerificationMeta(
    'ocrPageIndex',
  );
  @override
  late final GeneratedColumn<int> ocrPageIndex = GeneratedColumn<int>(
    'ocr_page_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    fileType,
    localPath,
    sizeBytes,
    pageCount,
    createdAt,
    updatedAt,
    isFavorite,
    isDeleted,
    deletedAt,
    folderId,
    thumbnailPath,
    ocrText,
    ocrProvider,
    ocrModel,
    ocrCreatedAt,
    ocrLanguage,
    ocrConfidence,
    ocrPageIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(
        _fileTypeMeta,
        fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('ocr_text')) {
      context.handle(
        _ocrTextMeta,
        ocrText.isAcceptableOrUnknown(data['ocr_text']!, _ocrTextMeta),
      );
    }
    if (data.containsKey('ocr_provider')) {
      context.handle(
        _ocrProviderMeta,
        ocrProvider.isAcceptableOrUnknown(
          data['ocr_provider']!,
          _ocrProviderMeta,
        ),
      );
    }
    if (data.containsKey('ocr_model')) {
      context.handle(
        _ocrModelMeta,
        ocrModel.isAcceptableOrUnknown(data['ocr_model']!, _ocrModelMeta),
      );
    }
    if (data.containsKey('ocr_created_at')) {
      context.handle(
        _ocrCreatedAtMeta,
        ocrCreatedAt.isAcceptableOrUnknown(
          data['ocr_created_at']!,
          _ocrCreatedAtMeta,
        ),
      );
    }
    if (data.containsKey('ocr_language')) {
      context.handle(
        _ocrLanguageMeta,
        ocrLanguage.isAcceptableOrUnknown(
          data['ocr_language']!,
          _ocrLanguageMeta,
        ),
      );
    }
    if (data.containsKey('ocr_confidence')) {
      context.handle(
        _ocrConfidenceMeta,
        ocrConfidence.isAcceptableOrUnknown(
          data['ocr_confidence']!,
          _ocrConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('ocr_page_index')) {
      context.handle(
        _ocrPageIndexMeta,
        ocrPageIndex.isAcceptableOrUnknown(
          data['ocr_page_index']!,
          _ocrPageIndexMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_type'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      ocrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_text'],
      ),
      ocrProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_provider'],
      ),
      ocrModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_model'],
      ),
      ocrCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ocr_created_at'],
      ),
      ocrLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_language'],
      ),
      ocrConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ocr_confidence'],
      ),
      ocrPageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ocr_page_index'],
      ),
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class DocumentRecord extends DataClass implements Insertable<DocumentRecord> {
  final String id;
  final String name;
  final String fileType;
  final String localPath;
  final int sizeBytes;
  final int pageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? folderId;
  final String? thumbnailPath;
  final String? ocrText;
  final String? ocrProvider;
  final String? ocrModel;
  final DateTime? ocrCreatedAt;
  final String? ocrLanguage;
  final double? ocrConfidence;
  final int? ocrPageIndex;
  const DocumentRecord({
    required this.id,
    required this.name,
    required this.fileType,
    required this.localPath,
    required this.sizeBytes,
    required this.pageCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavorite,
    required this.isDeleted,
    this.deletedAt,
    this.folderId,
    this.thumbnailPath,
    this.ocrText,
    this.ocrProvider,
    this.ocrModel,
    this.ocrCreatedAt,
    this.ocrLanguage,
    this.ocrConfidence,
    this.ocrPageIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['file_type'] = Variable<String>(fileType);
    map['local_path'] = Variable<String>(localPath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['page_count'] = Variable<int>(pageCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || ocrText != null) {
      map['ocr_text'] = Variable<String>(ocrText);
    }
    if (!nullToAbsent || ocrProvider != null) {
      map['ocr_provider'] = Variable<String>(ocrProvider);
    }
    if (!nullToAbsent || ocrModel != null) {
      map['ocr_model'] = Variable<String>(ocrModel);
    }
    if (!nullToAbsent || ocrCreatedAt != null) {
      map['ocr_created_at'] = Variable<DateTime>(ocrCreatedAt);
    }
    if (!nullToAbsent || ocrLanguage != null) {
      map['ocr_language'] = Variable<String>(ocrLanguage);
    }
    if (!nullToAbsent || ocrConfidence != null) {
      map['ocr_confidence'] = Variable<double>(ocrConfidence);
    }
    if (!nullToAbsent || ocrPageIndex != null) {
      map['ocr_page_index'] = Variable<int>(ocrPageIndex);
    }
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      name: Value(name),
      fileType: Value(fileType),
      localPath: Value(localPath),
      sizeBytes: Value(sizeBytes),
      pageCount: Value(pageCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isFavorite: Value(isFavorite),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      ocrText: ocrText == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrText),
      ocrProvider: ocrProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrProvider),
      ocrModel: ocrModel == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrModel),
      ocrCreatedAt: ocrCreatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrCreatedAt),
      ocrLanguage: ocrLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrLanguage),
      ocrConfidence: ocrConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrConfidence),
      ocrPageIndex: ocrPageIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrPageIndex),
    );
  }

  factory DocumentRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fileType: serializer.fromJson<String>(json['fileType']),
      localPath: serializer.fromJson<String>(json['localPath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      ocrText: serializer.fromJson<String?>(json['ocrText']),
      ocrProvider: serializer.fromJson<String?>(json['ocrProvider']),
      ocrModel: serializer.fromJson<String?>(json['ocrModel']),
      ocrCreatedAt: serializer.fromJson<DateTime?>(json['ocrCreatedAt']),
      ocrLanguage: serializer.fromJson<String?>(json['ocrLanguage']),
      ocrConfidence: serializer.fromJson<double?>(json['ocrConfidence']),
      ocrPageIndex: serializer.fromJson<int?>(json['ocrPageIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'fileType': serializer.toJson<String>(fileType),
      'localPath': serializer.toJson<String>(localPath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'pageCount': serializer.toJson<int>(pageCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'folderId': serializer.toJson<String?>(folderId),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'ocrText': serializer.toJson<String?>(ocrText),
      'ocrProvider': serializer.toJson<String?>(ocrProvider),
      'ocrModel': serializer.toJson<String?>(ocrModel),
      'ocrCreatedAt': serializer.toJson<DateTime?>(ocrCreatedAt),
      'ocrLanguage': serializer.toJson<String?>(ocrLanguage),
      'ocrConfidence': serializer.toJson<double?>(ocrConfidence),
      'ocrPageIndex': serializer.toJson<int?>(ocrPageIndex),
    };
  }

  DocumentRecord copyWith({
    String? id,
    String? name,
    String? fileType,
    String? localPath,
    int? sizeBytes,
    int? pageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isDeleted,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> folderId = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
    Value<String?> ocrText = const Value.absent(),
    Value<String?> ocrProvider = const Value.absent(),
    Value<String?> ocrModel = const Value.absent(),
    Value<DateTime?> ocrCreatedAt = const Value.absent(),
    Value<String?> ocrLanguage = const Value.absent(),
    Value<double?> ocrConfidence = const Value.absent(),
    Value<int?> ocrPageIndex = const Value.absent(),
  }) => DocumentRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    fileType: fileType ?? this.fileType,
    localPath: localPath ?? this.localPath,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    pageCount: pageCount ?? this.pageCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isFavorite: isFavorite ?? this.isFavorite,
    isDeleted: isDeleted ?? this.isDeleted,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    folderId: folderId.present ? folderId.value : this.folderId,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    ocrText: ocrText.present ? ocrText.value : this.ocrText,
    ocrProvider: ocrProvider.present ? ocrProvider.value : this.ocrProvider,
    ocrModel: ocrModel.present ? ocrModel.value : this.ocrModel,
    ocrCreatedAt: ocrCreatedAt.present ? ocrCreatedAt.value : this.ocrCreatedAt,
    ocrLanguage: ocrLanguage.present ? ocrLanguage.value : this.ocrLanguage,
    ocrConfidence: ocrConfidence.present
        ? ocrConfidence.value
        : this.ocrConfidence,
    ocrPageIndex: ocrPageIndex.present ? ocrPageIndex.value : this.ocrPageIndex,
  );
  DocumentRecord copyWithCompanion(DocumentsCompanion data) {
    return DocumentRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      ocrText: data.ocrText.present ? data.ocrText.value : this.ocrText,
      ocrProvider: data.ocrProvider.present
          ? data.ocrProvider.value
          : this.ocrProvider,
      ocrModel: data.ocrModel.present ? data.ocrModel.value : this.ocrModel,
      ocrCreatedAt: data.ocrCreatedAt.present
          ? data.ocrCreatedAt.value
          : this.ocrCreatedAt,
      ocrLanguage: data.ocrLanguage.present
          ? data.ocrLanguage.value
          : this.ocrLanguage,
      ocrConfidence: data.ocrConfidence.present
          ? data.ocrConfidence.value
          : this.ocrConfidence,
      ocrPageIndex: data.ocrPageIndex.present
          ? data.ocrPageIndex.value
          : this.ocrPageIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fileType: $fileType, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('pageCount: $pageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('folderId: $folderId, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('ocrText: $ocrText, ')
          ..write('ocrProvider: $ocrProvider, ')
          ..write('ocrModel: $ocrModel, ')
          ..write('ocrCreatedAt: $ocrCreatedAt, ')
          ..write('ocrLanguage: $ocrLanguage, ')
          ..write('ocrConfidence: $ocrConfidence, ')
          ..write('ocrPageIndex: $ocrPageIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    fileType,
    localPath,
    sizeBytes,
    pageCount,
    createdAt,
    updatedAt,
    isFavorite,
    isDeleted,
    deletedAt,
    folderId,
    thumbnailPath,
    ocrText,
    ocrProvider,
    ocrModel,
    ocrCreatedAt,
    ocrLanguage,
    ocrConfidence,
    ocrPageIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.fileType == this.fileType &&
          other.localPath == this.localPath &&
          other.sizeBytes == this.sizeBytes &&
          other.pageCount == this.pageCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isFavorite == this.isFavorite &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.folderId == this.folderId &&
          other.thumbnailPath == this.thumbnailPath &&
          other.ocrText == this.ocrText &&
          other.ocrProvider == this.ocrProvider &&
          other.ocrModel == this.ocrModel &&
          other.ocrCreatedAt == this.ocrCreatedAt &&
          other.ocrLanguage == this.ocrLanguage &&
          other.ocrConfidence == this.ocrConfidence &&
          other.ocrPageIndex == this.ocrPageIndex);
}

class DocumentsCompanion extends UpdateCompanion<DocumentRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> fileType;
  final Value<String> localPath;
  final Value<int> sizeBytes;
  final Value<int> pageCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isFavorite;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  final Value<String?> folderId;
  final Value<String?> thumbnailPath;
  final Value<String?> ocrText;
  final Value<String?> ocrProvider;
  final Value<String?> ocrModel;
  final Value<DateTime?> ocrCreatedAt;
  final Value<String?> ocrLanguage;
  final Value<double?> ocrConfidence;
  final Value<int?> ocrPageIndex;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fileType = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.folderId = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.ocrProvider = const Value.absent(),
    this.ocrModel = const Value.absent(),
    this.ocrCreatedAt = const Value.absent(),
    this.ocrLanguage = const Value.absent(),
    this.ocrConfidence = const Value.absent(),
    this.ocrPageIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required String name,
    required String fileType,
    required String localPath,
    required int sizeBytes,
    this.pageCount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isFavorite = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.folderId = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.ocrProvider = const Value.absent(),
    this.ocrModel = const Value.absent(),
    this.ocrCreatedAt = const Value.absent(),
    this.ocrLanguage = const Value.absent(),
    this.ocrConfidence = const Value.absent(),
    this.ocrPageIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       fileType = Value(fileType),
       localPath = Value(localPath),
       sizeBytes = Value(sizeBytes),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DocumentRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? fileType,
    Expression<String>? localPath,
    Expression<int>? sizeBytes,
    Expression<int>? pageCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isFavorite,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
    Expression<String>? folderId,
    Expression<String>? thumbnailPath,
    Expression<String>? ocrText,
    Expression<String>? ocrProvider,
    Expression<String>? ocrModel,
    Expression<DateTime>? ocrCreatedAt,
    Expression<String>? ocrLanguage,
    Expression<double>? ocrConfidence,
    Expression<int>? ocrPageIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fileType != null) 'file_type': fileType,
      if (localPath != null) 'local_path': localPath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (pageCount != null) 'page_count': pageCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (folderId != null) 'folder_id': folderId,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (ocrText != null) 'ocr_text': ocrText,
      if (ocrProvider != null) 'ocr_provider': ocrProvider,
      if (ocrModel != null) 'ocr_model': ocrModel,
      if (ocrCreatedAt != null) 'ocr_created_at': ocrCreatedAt,
      if (ocrLanguage != null) 'ocr_language': ocrLanguage,
      if (ocrConfidence != null) 'ocr_confidence': ocrConfidence,
      if (ocrPageIndex != null) 'ocr_page_index': ocrPageIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? fileType,
    Value<String>? localPath,
    Value<int>? sizeBytes,
    Value<int>? pageCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isFavorite,
    Value<bool>? isDeleted,
    Value<DateTime?>? deletedAt,
    Value<String?>? folderId,
    Value<String?>? thumbnailPath,
    Value<String?>? ocrText,
    Value<String?>? ocrProvider,
    Value<String?>? ocrModel,
    Value<DateTime?>? ocrCreatedAt,
    Value<String?>? ocrLanguage,
    Value<double?>? ocrConfidence,
    Value<int?>? ocrPageIndex,
    Value<int>? rowid,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fileType: fileType ?? this.fileType,
      localPath: localPath ?? this.localPath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      pageCount: pageCount ?? this.pageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      folderId: folderId ?? this.folderId,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      ocrText: ocrText ?? this.ocrText,
      ocrProvider: ocrProvider ?? this.ocrProvider,
      ocrModel: ocrModel ?? this.ocrModel,
      ocrCreatedAt: ocrCreatedAt ?? this.ocrCreatedAt,
      ocrLanguage: ocrLanguage ?? this.ocrLanguage,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      ocrPageIndex: ocrPageIndex ?? this.ocrPageIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (ocrText.present) {
      map['ocr_text'] = Variable<String>(ocrText.value);
    }
    if (ocrProvider.present) {
      map['ocr_provider'] = Variable<String>(ocrProvider.value);
    }
    if (ocrModel.present) {
      map['ocr_model'] = Variable<String>(ocrModel.value);
    }
    if (ocrCreatedAt.present) {
      map['ocr_created_at'] = Variable<DateTime>(ocrCreatedAt.value);
    }
    if (ocrLanguage.present) {
      map['ocr_language'] = Variable<String>(ocrLanguage.value);
    }
    if (ocrConfidence.present) {
      map['ocr_confidence'] = Variable<double>(ocrConfidence.value);
    }
    if (ocrPageIndex.present) {
      map['ocr_page_index'] = Variable<int>(ocrPageIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fileType: $fileType, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('pageCount: $pageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('folderId: $folderId, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('ocrText: $ocrText, ')
          ..write('ocrProvider: $ocrProvider, ')
          ..write('ocrModel: $ocrModel, ')
          ..write('ocrCreatedAt: $ocrCreatedAt, ')
          ..write('ocrLanguage: $ocrLanguage, ')
          ..write('ocrConfidence: $ocrConfidence, ')
          ..write('ocrPageIndex: $ocrPageIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedSignaturesTable extends SavedSignatures
    with TableInfo<$SavedSignaturesTable, SignatureRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedSignaturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strokesJsonMeta = const VerificationMeta(
    'strokesJson',
  );
  @override
  late final GeneratedColumn<String> strokesJson = GeneratedColumn<String>(
    'strokes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    colorValue,
    strokesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_signatures';
  @override
  VerificationContext validateIntegrity(
    Insertable<SignatureRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('strokes_json')) {
      context.handle(
        _strokesJsonMeta,
        strokesJson.isAcceptableOrUnknown(
          data['strokes_json']!,
          _strokesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strokesJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SignatureRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignatureRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      strokesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strokes_json'],
      )!,
    );
  }

  @override
  $SavedSignaturesTable createAlias(String alias) {
    return $SavedSignaturesTable(attachedDatabase, alias);
  }
}

class SignatureRecord extends DataClass implements Insertable<SignatureRecord> {
  final String id;
  final DateTime createdAt;
  final int colorValue;
  final String strokesJson;
  const SignatureRecord({
    required this.id,
    required this.createdAt,
    required this.colorValue,
    required this.strokesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['color_value'] = Variable<int>(colorValue);
    map['strokes_json'] = Variable<String>(strokesJson);
    return map;
  }

  SavedSignaturesCompanion toCompanion(bool nullToAbsent) {
    return SavedSignaturesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      colorValue: Value(colorValue),
      strokesJson: Value(strokesJson),
    );
  }

  factory SignatureRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignatureRecord(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      strokesJson: serializer.fromJson<String>(json['strokesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'colorValue': serializer.toJson<int>(colorValue),
      'strokesJson': serializer.toJson<String>(strokesJson),
    };
  }

  SignatureRecord copyWith({
    String? id,
    DateTime? createdAt,
    int? colorValue,
    String? strokesJson,
  }) => SignatureRecord(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    colorValue: colorValue ?? this.colorValue,
    strokesJson: strokesJson ?? this.strokesJson,
  );
  SignatureRecord copyWithCompanion(SavedSignaturesCompanion data) {
    return SignatureRecord(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      strokesJson: data.strokesJson.present
          ? data.strokesJson.value
          : this.strokesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignatureRecord(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('colorValue: $colorValue, ')
          ..write('strokesJson: $strokesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, colorValue, strokesJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignatureRecord &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.colorValue == this.colorValue &&
          other.strokesJson == this.strokesJson);
}

class SavedSignaturesCompanion extends UpdateCompanion<SignatureRecord> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<int> colorValue;
  final Value<String> strokesJson;
  final Value<int> rowid;
  const SavedSignaturesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.strokesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedSignaturesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required int colorValue,
    required String strokesJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       colorValue = Value(colorValue),
       strokesJson = Value(strokesJson);
  static Insertable<SignatureRecord> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<int>? colorValue,
    Expression<String>? strokesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (colorValue != null) 'color_value': colorValue,
      if (strokesJson != null) 'strokes_json': strokesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedSignaturesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<int>? colorValue,
    Value<String>? strokesJson,
    Value<int>? rowid,
  }) {
    return SavedSignaturesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      colorValue: colorValue ?? this.colorValue,
      strokesJson: strokesJson ?? this.strokesJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (strokesJson.present) {
      map['strokes_json'] = Variable<String>(strokesJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedSignaturesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('colorValue: $colorValue, ')
          ..write('strokesJson: $strokesJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSettingRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSettingRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserSettingRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingRecord(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSettingRecord extends DataClass
    implements Insertable<UserSettingRecord> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const UserSettingRecord({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSettingRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingRecord(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSettingRecord copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => UserSettingRecord(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserSettingRecord copyWithCompanion(UserSettingsCompanion data) {
    return UserSettingRecord(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingRecord(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingRecord &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsCompanion extends UpdateCompanion<UserSettingRecord> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<UserSettingRecord> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyUsageTable extends DailyUsage
    with TableInfo<$DailyUsageTable, DailyUsageRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyUsageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scanCountMeta = const VerificationMeta(
    'scanCount',
  );
  @override
  late final GeneratedColumn<int> scanCount = GeneratedColumn<int>(
    'scan_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _imageImportCountMeta = const VerificationMeta(
    'imageImportCount',
  );
  @override
  late final GeneratedColumn<int> imageImportCount = GeneratedColumn<int>(
    'image_import_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _imageToPdfCountMeta = const VerificationMeta(
    'imageToPdfCount',
  );
  @override
  late final GeneratedColumn<int> imageToPdfCount = GeneratedColumn<int>(
    'image_to_pdf_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    day,
    scanCount,
    imageImportCount,
    imageToPdfCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_usage';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyUsageRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('scan_count')) {
      context.handle(
        _scanCountMeta,
        scanCount.isAcceptableOrUnknown(data['scan_count']!, _scanCountMeta),
      );
    }
    if (data.containsKey('image_import_count')) {
      context.handle(
        _imageImportCountMeta,
        imageImportCount.isAcceptableOrUnknown(
          data['image_import_count']!,
          _imageImportCountMeta,
        ),
      );
    }
    if (data.containsKey('image_to_pdf_count')) {
      context.handle(
        _imageToPdfCountMeta,
        imageToPdfCount.isAcceptableOrUnknown(
          data['image_to_pdf_count']!,
          _imageToPdfCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DailyUsageRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyUsageRecord(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      scanCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scan_count'],
      )!,
      imageImportCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}image_import_count'],
      )!,
      imageToPdfCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}image_to_pdf_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyUsageTable createAlias(String alias) {
    return $DailyUsageTable(attachedDatabase, alias);
  }
}

class DailyUsageRecord extends DataClass
    implements Insertable<DailyUsageRecord> {
  final String day;
  final int scanCount;
  final int imageImportCount;
  final int imageToPdfCount;
  final DateTime updatedAt;
  const DailyUsageRecord({
    required this.day,
    required this.scanCount,
    required this.imageImportCount,
    required this.imageToPdfCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['scan_count'] = Variable<int>(scanCount);
    map['image_import_count'] = Variable<int>(imageImportCount);
    map['image_to_pdf_count'] = Variable<int>(imageToPdfCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyUsageCompanion toCompanion(bool nullToAbsent) {
    return DailyUsageCompanion(
      day: Value(day),
      scanCount: Value(scanCount),
      imageImportCount: Value(imageImportCount),
      imageToPdfCount: Value(imageToPdfCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyUsageRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyUsageRecord(
      day: serializer.fromJson<String>(json['day']),
      scanCount: serializer.fromJson<int>(json['scanCount']),
      imageImportCount: serializer.fromJson<int>(json['imageImportCount']),
      imageToPdfCount: serializer.fromJson<int>(json['imageToPdfCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'scanCount': serializer.toJson<int>(scanCount),
      'imageImportCount': serializer.toJson<int>(imageImportCount),
      'imageToPdfCount': serializer.toJson<int>(imageToPdfCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyUsageRecord copyWith({
    String? day,
    int? scanCount,
    int? imageImportCount,
    int? imageToPdfCount,
    DateTime? updatedAt,
  }) => DailyUsageRecord(
    day: day ?? this.day,
    scanCount: scanCount ?? this.scanCount,
    imageImportCount: imageImportCount ?? this.imageImportCount,
    imageToPdfCount: imageToPdfCount ?? this.imageToPdfCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyUsageRecord copyWithCompanion(DailyUsageCompanion data) {
    return DailyUsageRecord(
      day: data.day.present ? data.day.value : this.day,
      scanCount: data.scanCount.present ? data.scanCount.value : this.scanCount,
      imageImportCount: data.imageImportCount.present
          ? data.imageImportCount.value
          : this.imageImportCount,
      imageToPdfCount: data.imageToPdfCount.present
          ? data.imageToPdfCount.value
          : this.imageToPdfCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyUsageRecord(')
          ..write('day: $day, ')
          ..write('scanCount: $scanCount, ')
          ..write('imageImportCount: $imageImportCount, ')
          ..write('imageToPdfCount: $imageToPdfCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(day, scanCount, imageImportCount, imageToPdfCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyUsageRecord &&
          other.day == this.day &&
          other.scanCount == this.scanCount &&
          other.imageImportCount == this.imageImportCount &&
          other.imageToPdfCount == this.imageToPdfCount &&
          other.updatedAt == this.updatedAt);
}

class DailyUsageCompanion extends UpdateCompanion<DailyUsageRecord> {
  final Value<String> day;
  final Value<int> scanCount;
  final Value<int> imageImportCount;
  final Value<int> imageToPdfCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DailyUsageCompanion({
    this.day = const Value.absent(),
    this.scanCount = const Value.absent(),
    this.imageImportCount = const Value.absent(),
    this.imageToPdfCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyUsageCompanion.insert({
    required String day,
    this.scanCount = const Value.absent(),
    this.imageImportCount = const Value.absent(),
    this.imageToPdfCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       updatedAt = Value(updatedAt);
  static Insertable<DailyUsageRecord> custom({
    Expression<String>? day,
    Expression<int>? scanCount,
    Expression<int>? imageImportCount,
    Expression<int>? imageToPdfCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (scanCount != null) 'scan_count': scanCount,
      if (imageImportCount != null) 'image_import_count': imageImportCount,
      if (imageToPdfCount != null) 'image_to_pdf_count': imageToPdfCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyUsageCompanion copyWith({
    Value<String>? day,
    Value<int>? scanCount,
    Value<int>? imageImportCount,
    Value<int>? imageToPdfCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DailyUsageCompanion(
      day: day ?? this.day,
      scanCount: scanCount ?? this.scanCount,
      imageImportCount: imageImportCount ?? this.imageImportCount,
      imageToPdfCount: imageToPdfCount ?? this.imageToPdfCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (scanCount.present) {
      map['scan_count'] = Variable<int>(scanCount.value);
    }
    if (imageImportCount.present) {
      map['image_import_count'] = Variable<int>(imageImportCount.value);
    }
    if (imageToPdfCount.present) {
      map['image_to_pdf_count'] = Variable<int>(imageToPdfCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyUsageCompanion(')
          ..write('day: $day, ')
          ..write('scanCount: $scanCount, ')
          ..write('imageImportCount: $imageImportCount, ')
          ..write('imageToPdfCount: $imageToPdfCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ScanLenoDatabase extends GeneratedDatabase {
  _$ScanLenoDatabase(QueryExecutor e) : super(e);
  $ScanLenoDatabaseManager get managers => $ScanLenoDatabaseManager(this);
  late final $AppFoldersTable appFolders = $AppFoldersTable(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $SavedSignaturesTable savedSignatures = $SavedSignaturesTable(
    this,
  );
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $DailyUsageTable dailyUsage = $DailyUsageTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appFolders,
    documents,
    savedSignatures,
    userSettings,
    dailyUsage,
  ];
}

typedef $$AppFoldersTableCreateCompanionBuilder =
    AppFoldersCompanion Function({
      required String id,
      required String nameKey,
      required DateTime createdAt,
      Value<bool> isSystem,
      Value<int> rowid,
    });
typedef $$AppFoldersTableUpdateCompanionBuilder =
    AppFoldersCompanion Function({
      Value<String> id,
      Value<String> nameKey,
      Value<DateTime> createdAt,
      Value<bool> isSystem,
      Value<int> rowid,
    });

final class $$AppFoldersTableReferences
    extends BaseReferences<_$ScanLenoDatabase, $AppFoldersTable, AppFolder> {
  $$AppFoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DocumentsTable, List<DocumentRecord>>
  _documentsRefsTable(_$ScanLenoDatabase db) => MultiTypedResultKey.fromTable(
    db.documents,
    aliasName: 'app_folders__id__documents__folder_id',
  );

  $$DocumentsTableProcessedTableManager get documentsRefs {
    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AppFoldersTableFilterComposer
    extends Composer<_$ScanLenoDatabase, $AppFoldersTable> {
  $$AppFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> documentsRefs(
    Expression<bool> Function($$DocumentsTableFilterComposer f) f,
  ) {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppFoldersTableOrderingComposer
    extends Composer<_$ScanLenoDatabase, $AppFoldersTable> {
  $$AppFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppFoldersTableAnnotationComposer
    extends Composer<_$ScanLenoDatabase, $AppFoldersTable> {
  $$AppFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  Expression<T> documentsRefs<T extends Object>(
    Expression<T> Function($$DocumentsTableAnnotationComposer a) f,
  ) {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppFoldersTableTableManager
    extends
        RootTableManager<
          _$ScanLenoDatabase,
          $AppFoldersTable,
          AppFolder,
          $$AppFoldersTableFilterComposer,
          $$AppFoldersTableOrderingComposer,
          $$AppFoldersTableAnnotationComposer,
          $$AppFoldersTableCreateCompanionBuilder,
          $$AppFoldersTableUpdateCompanionBuilder,
          (AppFolder, $$AppFoldersTableReferences),
          AppFolder,
          PrefetchHooks Function({bool documentsRefs})
        > {
  $$AppFoldersTableTableManager(_$ScanLenoDatabase db, $AppFoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppFoldersCompanion(
                id: id,
                nameKey: nameKey,
                createdAt: createdAt,
                isSystem: isSystem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nameKey,
                required DateTime createdAt,
                Value<bool> isSystem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppFoldersCompanion.insert(
                id: id,
                nameKey: nameKey,
                createdAt: createdAt,
                isSystem: isSystem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AppFoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (documentsRefs) db.documents],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (documentsRefs)
                    await $_getPrefetchedData<
                      AppFolder,
                      $AppFoldersTable,
                      DocumentRecord
                    >(
                      currentTable: table,
                      referencedTable: $$AppFoldersTableReferences
                          ._documentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AppFoldersTableReferences(
                            db,
                            table,
                            p0,
                          ).documentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AppFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$ScanLenoDatabase,
      $AppFoldersTable,
      AppFolder,
      $$AppFoldersTableFilterComposer,
      $$AppFoldersTableOrderingComposer,
      $$AppFoldersTableAnnotationComposer,
      $$AppFoldersTableCreateCompanionBuilder,
      $$AppFoldersTableUpdateCompanionBuilder,
      (AppFolder, $$AppFoldersTableReferences),
      AppFolder,
      PrefetchHooks Function({bool documentsRefs})
    >;
typedef $$DocumentsTableCreateCompanionBuilder =
    DocumentsCompanion Function({
      required String id,
      required String name,
      required String fileType,
      required String localPath,
      required int sizeBytes,
      Value<int> pageCount,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isFavorite,
      Value<bool> isDeleted,
      Value<DateTime?> deletedAt,
      Value<String?> folderId,
      Value<String?> thumbnailPath,
      Value<String?> ocrText,
      Value<String?> ocrProvider,
      Value<String?> ocrModel,
      Value<DateTime?> ocrCreatedAt,
      Value<String?> ocrLanguage,
      Value<double?> ocrConfidence,
      Value<int?> ocrPageIndex,
      Value<int> rowid,
    });
typedef $$DocumentsTableUpdateCompanionBuilder =
    DocumentsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> fileType,
      Value<String> localPath,
      Value<int> sizeBytes,
      Value<int> pageCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isFavorite,
      Value<bool> isDeleted,
      Value<DateTime?> deletedAt,
      Value<String?> folderId,
      Value<String?> thumbnailPath,
      Value<String?> ocrText,
      Value<String?> ocrProvider,
      Value<String?> ocrModel,
      Value<DateTime?> ocrCreatedAt,
      Value<String?> ocrLanguage,
      Value<double?> ocrConfidence,
      Value<int?> ocrPageIndex,
      Value<int> rowid,
    });

final class $$DocumentsTableReferences
    extends
        BaseReferences<_$ScanLenoDatabase, $DocumentsTable, DocumentRecord> {
  $$DocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppFoldersTable _folderIdTable(_$ScanLenoDatabase db) =>
      db.appFolders.createAlias('documents__folder_id__app_folders__id');

  $$AppFoldersTableProcessedTableManager? get folderId {
    final $_column = $_itemColumn<String>('folder_id');
    if ($_column == null) return null;
    final manager = $$AppFoldersTableTableManager(
      $_db,
      $_db.appFolders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DocumentsTableFilterComposer
    extends Composer<_$ScanLenoDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrProvider => $composableBuilder(
    column: $table.ocrProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrModel => $composableBuilder(
    column: $table.ocrModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ocrCreatedAt => $composableBuilder(
    column: $table.ocrCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrLanguage => $composableBuilder(
    column: $table.ocrLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ocrConfidence => $composableBuilder(
    column: $table.ocrConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ocrPageIndex => $composableBuilder(
    column: $table.ocrPageIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$AppFoldersTableFilterComposer get folderId {
    final $$AppFoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.appFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppFoldersTableFilterComposer(
            $db: $db,
            $table: $db.appFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$ScanLenoDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrProvider => $composableBuilder(
    column: $table.ocrProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrModel => $composableBuilder(
    column: $table.ocrModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ocrCreatedAt => $composableBuilder(
    column: $table.ocrCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrLanguage => $composableBuilder(
    column: $table.ocrLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ocrConfidence => $composableBuilder(
    column: $table.ocrConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ocrPageIndex => $composableBuilder(
    column: $table.ocrPageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppFoldersTableOrderingComposer get folderId {
    final $$AppFoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.appFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppFoldersTableOrderingComposer(
            $db: $db,
            $table: $db.appFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$ScanLenoDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrText =>
      $composableBuilder(column: $table.ocrText, builder: (column) => column);

  GeneratedColumn<String> get ocrProvider => $composableBuilder(
    column: $table.ocrProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrModel =>
      $composableBuilder(column: $table.ocrModel, builder: (column) => column);

  GeneratedColumn<DateTime> get ocrCreatedAt => $composableBuilder(
    column: $table.ocrCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrLanguage => $composableBuilder(
    column: $table.ocrLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ocrConfidence => $composableBuilder(
    column: $table.ocrConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ocrPageIndex => $composableBuilder(
    column: $table.ocrPageIndex,
    builder: (column) => column,
  );

  $$AppFoldersTableAnnotationComposer get folderId {
    final $$AppFoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.appFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppFoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.appFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$ScanLenoDatabase,
          $DocumentsTable,
          DocumentRecord,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (DocumentRecord, $$DocumentsTableReferences),
          DocumentRecord,
          PrefetchHooks Function({bool folderId})
        > {
  $$DocumentsTableTableManager(_$ScanLenoDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fileType = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> pageCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String?> ocrText = const Value.absent(),
                Value<String?> ocrProvider = const Value.absent(),
                Value<String?> ocrModel = const Value.absent(),
                Value<DateTime?> ocrCreatedAt = const Value.absent(),
                Value<String?> ocrLanguage = const Value.absent(),
                Value<double?> ocrConfidence = const Value.absent(),
                Value<int?> ocrPageIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                name: name,
                fileType: fileType,
                localPath: localPath,
                sizeBytes: sizeBytes,
                pageCount: pageCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isFavorite: isFavorite,
                isDeleted: isDeleted,
                deletedAt: deletedAt,
                folderId: folderId,
                thumbnailPath: thumbnailPath,
                ocrText: ocrText,
                ocrProvider: ocrProvider,
                ocrModel: ocrModel,
                ocrCreatedAt: ocrCreatedAt,
                ocrLanguage: ocrLanguage,
                ocrConfidence: ocrConfidence,
                ocrPageIndex: ocrPageIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String fileType,
                required String localPath,
                required int sizeBytes,
                Value<int> pageCount = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String?> ocrText = const Value.absent(),
                Value<String?> ocrProvider = const Value.absent(),
                Value<String?> ocrModel = const Value.absent(),
                Value<DateTime?> ocrCreatedAt = const Value.absent(),
                Value<String?> ocrLanguage = const Value.absent(),
                Value<double?> ocrConfidence = const Value.absent(),
                Value<int?> ocrPageIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                name: name,
                fileType: fileType,
                localPath: localPath,
                sizeBytes: sizeBytes,
                pageCount: pageCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isFavorite: isFavorite,
                isDeleted: isDeleted,
                deletedAt: deletedAt,
                folderId: folderId,
                thumbnailPath: thumbnailPath,
                ocrText: ocrText,
                ocrProvider: ocrProvider,
                ocrModel: ocrModel,
                ocrCreatedAt: ocrCreatedAt,
                ocrLanguage: ocrLanguage,
                ocrConfidence: ocrConfidence,
                ocrPageIndex: ocrPageIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.folderId,
                                referencedTable: $$DocumentsTableReferences
                                    ._folderIdTable(db),
                                referencedColumn: $$DocumentsTableReferences
                                    ._folderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScanLenoDatabase,
      $DocumentsTable,
      DocumentRecord,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (DocumentRecord, $$DocumentsTableReferences),
      DocumentRecord,
      PrefetchHooks Function({bool folderId})
    >;
typedef $$SavedSignaturesTableCreateCompanionBuilder =
    SavedSignaturesCompanion Function({
      required String id,
      required DateTime createdAt,
      required int colorValue,
      required String strokesJson,
      Value<int> rowid,
    });
typedef $$SavedSignaturesTableUpdateCompanionBuilder =
    SavedSignaturesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<int> colorValue,
      Value<String> strokesJson,
      Value<int> rowid,
    });

class $$SavedSignaturesTableFilterComposer
    extends Composer<_$ScanLenoDatabase, $SavedSignaturesTable> {
  $$SavedSignaturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strokesJson => $composableBuilder(
    column: $table.strokesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedSignaturesTableOrderingComposer
    extends Composer<_$ScanLenoDatabase, $SavedSignaturesTable> {
  $$SavedSignaturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strokesJson => $composableBuilder(
    column: $table.strokesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedSignaturesTableAnnotationComposer
    extends Composer<_$ScanLenoDatabase, $SavedSignaturesTable> {
  $$SavedSignaturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get strokesJson => $composableBuilder(
    column: $table.strokesJson,
    builder: (column) => column,
  );
}

class $$SavedSignaturesTableTableManager
    extends
        RootTableManager<
          _$ScanLenoDatabase,
          $SavedSignaturesTable,
          SignatureRecord,
          $$SavedSignaturesTableFilterComposer,
          $$SavedSignaturesTableOrderingComposer,
          $$SavedSignaturesTableAnnotationComposer,
          $$SavedSignaturesTableCreateCompanionBuilder,
          $$SavedSignaturesTableUpdateCompanionBuilder,
          (
            SignatureRecord,
            BaseReferences<
              _$ScanLenoDatabase,
              $SavedSignaturesTable,
              SignatureRecord
            >,
          ),
          SignatureRecord,
          PrefetchHooks Function()
        > {
  $$SavedSignaturesTableTableManager(
    _$ScanLenoDatabase db,
    $SavedSignaturesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedSignaturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedSignaturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedSignaturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<String> strokesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedSignaturesCompanion(
                id: id,
                createdAt: createdAt,
                colorValue: colorValue,
                strokesJson: strokesJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required int colorValue,
                required String strokesJson,
                Value<int> rowid = const Value.absent(),
              }) => SavedSignaturesCompanion.insert(
                id: id,
                createdAt: createdAt,
                colorValue: colorValue,
                strokesJson: strokesJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedSignaturesTableProcessedTableManager =
    ProcessedTableManager<
      _$ScanLenoDatabase,
      $SavedSignaturesTable,
      SignatureRecord,
      $$SavedSignaturesTableFilterComposer,
      $$SavedSignaturesTableOrderingComposer,
      $$SavedSignaturesTableAnnotationComposer,
      $$SavedSignaturesTableCreateCompanionBuilder,
      $$SavedSignaturesTableUpdateCompanionBuilder,
      (
        SignatureRecord,
        BaseReferences<
          _$ScanLenoDatabase,
          $SavedSignaturesTable,
          SignatureRecord
        >,
      ),
      SignatureRecord,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$ScanLenoDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$ScanLenoDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$ScanLenoDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$ScanLenoDatabase,
          $UserSettingsTable,
          UserSettingRecord,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            UserSettingRecord,
            BaseReferences<
              _$ScanLenoDatabase,
              $UserSettingsTable,
              UserSettingRecord
            >,
          ),
          UserSettingRecord,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(
    _$ScanLenoDatabase db,
    $UserSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScanLenoDatabase,
      $UserSettingsTable,
      UserSettingRecord,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        UserSettingRecord,
        BaseReferences<
          _$ScanLenoDatabase,
          $UserSettingsTable,
          UserSettingRecord
        >,
      ),
      UserSettingRecord,
      PrefetchHooks Function()
    >;
typedef $$DailyUsageTableCreateCompanionBuilder =
    DailyUsageCompanion Function({
      required String day,
      Value<int> scanCount,
      Value<int> imageImportCount,
      Value<int> imageToPdfCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DailyUsageTableUpdateCompanionBuilder =
    DailyUsageCompanion Function({
      Value<String> day,
      Value<int> scanCount,
      Value<int> imageImportCount,
      Value<int> imageToPdfCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DailyUsageTableFilterComposer
    extends Composer<_$ScanLenoDatabase, $DailyUsageTable> {
  $$DailyUsageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scanCount => $composableBuilder(
    column: $table.scanCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imageImportCount => $composableBuilder(
    column: $table.imageImportCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imageToPdfCount => $composableBuilder(
    column: $table.imageToPdfCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyUsageTableOrderingComposer
    extends Composer<_$ScanLenoDatabase, $DailyUsageTable> {
  $$DailyUsageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scanCount => $composableBuilder(
    column: $table.scanCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imageImportCount => $composableBuilder(
    column: $table.imageImportCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imageToPdfCount => $composableBuilder(
    column: $table.imageToPdfCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyUsageTableAnnotationComposer
    extends Composer<_$ScanLenoDatabase, $DailyUsageTable> {
  $$DailyUsageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get scanCount =>
      $composableBuilder(column: $table.scanCount, builder: (column) => column);

  GeneratedColumn<int> get imageImportCount => $composableBuilder(
    column: $table.imageImportCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get imageToPdfCount => $composableBuilder(
    column: $table.imageToPdfCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyUsageTableTableManager
    extends
        RootTableManager<
          _$ScanLenoDatabase,
          $DailyUsageTable,
          DailyUsageRecord,
          $$DailyUsageTableFilterComposer,
          $$DailyUsageTableOrderingComposer,
          $$DailyUsageTableAnnotationComposer,
          $$DailyUsageTableCreateCompanionBuilder,
          $$DailyUsageTableUpdateCompanionBuilder,
          (
            DailyUsageRecord,
            BaseReferences<
              _$ScanLenoDatabase,
              $DailyUsageTable,
              DailyUsageRecord
            >,
          ),
          DailyUsageRecord,
          PrefetchHooks Function()
        > {
  $$DailyUsageTableTableManager(_$ScanLenoDatabase db, $DailyUsageTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyUsageTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyUsageTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyUsageTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<int> scanCount = const Value.absent(),
                Value<int> imageImportCount = const Value.absent(),
                Value<int> imageToPdfCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyUsageCompanion(
                day: day,
                scanCount: scanCount,
                imageImportCount: imageImportCount,
                imageToPdfCount: imageToPdfCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                Value<int> scanCount = const Value.absent(),
                Value<int> imageImportCount = const Value.absent(),
                Value<int> imageToPdfCount = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyUsageCompanion.insert(
                day: day,
                scanCount: scanCount,
                imageImportCount: imageImportCount,
                imageToPdfCount: imageToPdfCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyUsageTableProcessedTableManager =
    ProcessedTableManager<
      _$ScanLenoDatabase,
      $DailyUsageTable,
      DailyUsageRecord,
      $$DailyUsageTableFilterComposer,
      $$DailyUsageTableOrderingComposer,
      $$DailyUsageTableAnnotationComposer,
      $$DailyUsageTableCreateCompanionBuilder,
      $$DailyUsageTableUpdateCompanionBuilder,
      (
        DailyUsageRecord,
        BaseReferences<_$ScanLenoDatabase, $DailyUsageTable, DailyUsageRecord>,
      ),
      DailyUsageRecord,
      PrefetchHooks Function()
    >;

class $ScanLenoDatabaseManager {
  final _$ScanLenoDatabase _db;
  $ScanLenoDatabaseManager(this._db);
  $$AppFoldersTableTableManager get appFolders =>
      $$AppFoldersTableTableManager(_db, _db.appFolders);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$SavedSignaturesTableTableManager get savedSignatures =>
      $$SavedSignaturesTableTableManager(_db, _db.savedSignatures);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$DailyUsageTableTableManager get dailyUsage =>
      $$DailyUsageTableTableManager(_db, _db.dailyUsage);
}
