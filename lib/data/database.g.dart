// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ExposuresTable extends Exposures
    with TableInfo<$ExposuresTable, ExposureRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExposuresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _vocabIdMeta = const VerificationMeta(
    'vocabId',
  );
  @override
  late final GeneratedColumn<String> vocabId = GeneratedColumn<String>(
    'vocab_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encounterCountMeta = const VerificationMeta(
    'encounterCount',
  );
  @override
  late final GeneratedColumn<int> encounterCount = GeneratedColumn<int>(
    'encounter_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _contentItemIdsJsonMeta =
      const VerificationMeta('contentItemIdsJson');
  @override
  late final GeneratedColumn<String> contentItemIdsJson =
      GeneratedColumn<String>(
        'content_item_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _firstSeenMeta = const VerificationMeta(
    'firstSeen',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeen = GeneratedColumn<DateTime>(
    'first_seen',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
    'last_seen',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    vocabId,
    encounterCount,
    contentItemIdsJson,
    firstSeen,
    lastSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exposures';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExposureRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vocab_id')) {
      context.handle(
        _vocabIdMeta,
        vocabId.isAcceptableOrUnknown(data['vocab_id']!, _vocabIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vocabIdMeta);
    }
    if (data.containsKey('encounter_count')) {
      context.handle(
        _encounterCountMeta,
        encounterCount.isAcceptableOrUnknown(
          data['encounter_count']!,
          _encounterCountMeta,
        ),
      );
    }
    if (data.containsKey('content_item_ids_json')) {
      context.handle(
        _contentItemIdsJsonMeta,
        contentItemIdsJson.isAcceptableOrUnknown(
          data['content_item_ids_json']!,
          _contentItemIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentItemIdsJsonMeta);
    }
    if (data.containsKey('first_seen')) {
      context.handle(
        _firstSeenMeta,
        firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_firstSeenMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {vocabId};
  @override
  ExposureRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExposureRow(
      vocabId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocab_id'],
      )!,
      encounterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}encounter_count'],
      )!,
      contentItemIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_item_ids_json'],
      )!,
      firstSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen'],
      )!,
    );
  }

  @override
  $ExposuresTable createAlias(String alias) {
    return $ExposuresTable(attachedDatabase, alias);
  }
}

class ExposureRow extends DataClass implements Insertable<ExposureRow> {
  final String vocabId;
  final int encounterCount;

  /// JSON-encoded array of distinct content item IDs (e.g. `["story-1"]`).
  final String contentItemIdsJson;
  final DateTime firstSeen;
  final DateTime lastSeen;
  const ExposureRow({
    required this.vocabId,
    required this.encounterCount,
    required this.contentItemIdsJson,
    required this.firstSeen,
    required this.lastSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['vocab_id'] = Variable<String>(vocabId);
    map['encounter_count'] = Variable<int>(encounterCount);
    map['content_item_ids_json'] = Variable<String>(contentItemIdsJson);
    map['first_seen'] = Variable<DateTime>(firstSeen);
    map['last_seen'] = Variable<DateTime>(lastSeen);
    return map;
  }

  ExposuresCompanion toCompanion(bool nullToAbsent) {
    return ExposuresCompanion(
      vocabId: Value(vocabId),
      encounterCount: Value(encounterCount),
      contentItemIdsJson: Value(contentItemIdsJson),
      firstSeen: Value(firstSeen),
      lastSeen: Value(lastSeen),
    );
  }

  factory ExposureRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExposureRow(
      vocabId: serializer.fromJson<String>(json['vocabId']),
      encounterCount: serializer.fromJson<int>(json['encounterCount']),
      contentItemIdsJson: serializer.fromJson<String>(
        json['contentItemIdsJson'],
      ),
      firstSeen: serializer.fromJson<DateTime>(json['firstSeen']),
      lastSeen: serializer.fromJson<DateTime>(json['lastSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vocabId': serializer.toJson<String>(vocabId),
      'encounterCount': serializer.toJson<int>(encounterCount),
      'contentItemIdsJson': serializer.toJson<String>(contentItemIdsJson),
      'firstSeen': serializer.toJson<DateTime>(firstSeen),
      'lastSeen': serializer.toJson<DateTime>(lastSeen),
    };
  }

  ExposureRow copyWith({
    String? vocabId,
    int? encounterCount,
    String? contentItemIdsJson,
    DateTime? firstSeen,
    DateTime? lastSeen,
  }) => ExposureRow(
    vocabId: vocabId ?? this.vocabId,
    encounterCount: encounterCount ?? this.encounterCount,
    contentItemIdsJson: contentItemIdsJson ?? this.contentItemIdsJson,
    firstSeen: firstSeen ?? this.firstSeen,
    lastSeen: lastSeen ?? this.lastSeen,
  );
  ExposureRow copyWithCompanion(ExposuresCompanion data) {
    return ExposureRow(
      vocabId: data.vocabId.present ? data.vocabId.value : this.vocabId,
      encounterCount: data.encounterCount.present
          ? data.encounterCount.value
          : this.encounterCount,
      contentItemIdsJson: data.contentItemIdsJson.present
          ? data.contentItemIdsJson.value
          : this.contentItemIdsJson,
      firstSeen: data.firstSeen.present ? data.firstSeen.value : this.firstSeen,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExposureRow(')
          ..write('vocabId: $vocabId, ')
          ..write('encounterCount: $encounterCount, ')
          ..write('contentItemIdsJson: $contentItemIdsJson, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    vocabId,
    encounterCount,
    contentItemIdsJson,
    firstSeen,
    lastSeen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExposureRow &&
          other.vocabId == this.vocabId &&
          other.encounterCount == this.encounterCount &&
          other.contentItemIdsJson == this.contentItemIdsJson &&
          other.firstSeen == this.firstSeen &&
          other.lastSeen == this.lastSeen);
}

class ExposuresCompanion extends UpdateCompanion<ExposureRow> {
  final Value<String> vocabId;
  final Value<int> encounterCount;
  final Value<String> contentItemIdsJson;
  final Value<DateTime> firstSeen;
  final Value<DateTime> lastSeen;
  final Value<int> rowid;
  const ExposuresCompanion({
    this.vocabId = const Value.absent(),
    this.encounterCount = const Value.absent(),
    this.contentItemIdsJson = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExposuresCompanion.insert({
    required String vocabId,
    this.encounterCount = const Value.absent(),
    required String contentItemIdsJson,
    required DateTime firstSeen,
    required DateTime lastSeen,
    this.rowid = const Value.absent(),
  }) : vocabId = Value(vocabId),
       contentItemIdsJson = Value(contentItemIdsJson),
       firstSeen = Value(firstSeen),
       lastSeen = Value(lastSeen);
  static Insertable<ExposureRow> custom({
    Expression<String>? vocabId,
    Expression<int>? encounterCount,
    Expression<String>? contentItemIdsJson,
    Expression<DateTime>? firstSeen,
    Expression<DateTime>? lastSeen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (vocabId != null) 'vocab_id': vocabId,
      if (encounterCount != null) 'encounter_count': encounterCount,
      if (contentItemIdsJson != null)
        'content_item_ids_json': contentItemIdsJson,
      if (firstSeen != null) 'first_seen': firstSeen,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExposuresCompanion copyWith({
    Value<String>? vocabId,
    Value<int>? encounterCount,
    Value<String>? contentItemIdsJson,
    Value<DateTime>? firstSeen,
    Value<DateTime>? lastSeen,
    Value<int>? rowid,
  }) {
    return ExposuresCompanion(
      vocabId: vocabId ?? this.vocabId,
      encounterCount: encounterCount ?? this.encounterCount,
      contentItemIdsJson: contentItemIdsJson ?? this.contentItemIdsJson,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (vocabId.present) {
      map['vocab_id'] = Variable<String>(vocabId.value);
    }
    if (encounterCount.present) {
      map['encounter_count'] = Variable<int>(encounterCount.value);
    }
    if (contentItemIdsJson.present) {
      map['content_item_ids_json'] = Variable<String>(contentItemIdsJson.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<DateTime>(firstSeen.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExposuresCompanion(')
          ..write('vocabId: $vocabId, ')
          ..write('encounterCount: $encounterCount, ')
          ..write('contentItemIdsJson: $contentItemIdsJson, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentProgressesTable extends ContentProgresses
    with TableInfo<$ContentProgressesTable, ContentProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentProgressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
    'content_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPositionMeta = const VerificationMeta(
    'lastPosition',
  );
  @override
  late final GeneratedColumn<int> lastPosition = GeneratedColumn<int>(
    'last_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completionCountMeta = const VerificationMeta(
    'completionCount',
  );
  @override
  late final GeneratedColumn<int> completionCount = GeneratedColumn<int>(
    'completion_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rereadCountMeta = const VerificationMeta(
    'rereadCount',
  );
  @override
  late final GeneratedColumn<int> rereadCount = GeneratedColumn<int>(
    'reread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _firstReadMeta = const VerificationMeta(
    'firstRead',
  );
  @override
  late final GeneratedColumn<DateTime> firstRead = GeneratedColumn<DateTime>(
    'first_read',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReadMeta = const VerificationMeta(
    'lastRead',
  );
  @override
  late final GeneratedColumn<DateTime> lastRead = GeneratedColumn<DateTime>(
    'last_read',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    contentId,
    lastPosition,
    completionCount,
    rereadCount,
    firstRead,
    lastRead,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_progresses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contentIdMeta);
    }
    if (data.containsKey('last_position')) {
      context.handle(
        _lastPositionMeta,
        lastPosition.isAcceptableOrUnknown(
          data['last_position']!,
          _lastPositionMeta,
        ),
      );
    }
    if (data.containsKey('completion_count')) {
      context.handle(
        _completionCountMeta,
        completionCount.isAcceptableOrUnknown(
          data['completion_count']!,
          _completionCountMeta,
        ),
      );
    }
    if (data.containsKey('reread_count')) {
      context.handle(
        _rereadCountMeta,
        rereadCount.isAcceptableOrUnknown(
          data['reread_count']!,
          _rereadCountMeta,
        ),
      );
    }
    if (data.containsKey('first_read')) {
      context.handle(
        _firstReadMeta,
        firstRead.isAcceptableOrUnknown(data['first_read']!, _firstReadMeta),
      );
    } else if (isInserting) {
      context.missing(_firstReadMeta);
    }
    if (data.containsKey('last_read')) {
      context.handle(
        _lastReadMeta,
        lastRead.isAcceptableOrUnknown(data['last_read']!, _lastReadMeta),
      );
    } else if (isInserting) {
      context.missing(_lastReadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {contentId};
  @override
  ContentProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentProgressRow(
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_id'],
      )!,
      lastPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_position'],
      )!,
      completionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completion_count'],
      )!,
      rereadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reread_count'],
      )!,
      firstRead: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_read'],
      )!,
      lastRead: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read'],
      )!,
    );
  }

  @override
  $ContentProgressesTable createAlias(String alias) {
    return $ContentProgressesTable(attachedDatabase, alias);
  }
}

class ContentProgressRow extends DataClass
    implements Insertable<ContentProgressRow> {
  final String contentId;
  final int lastPosition;
  final int completionCount;
  final int rereadCount;
  final DateTime firstRead;
  final DateTime lastRead;
  const ContentProgressRow({
    required this.contentId,
    required this.lastPosition,
    required this.completionCount,
    required this.rereadCount,
    required this.firstRead,
    required this.lastRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['content_id'] = Variable<String>(contentId);
    map['last_position'] = Variable<int>(lastPosition);
    map['completion_count'] = Variable<int>(completionCount);
    map['reread_count'] = Variable<int>(rereadCount);
    map['first_read'] = Variable<DateTime>(firstRead);
    map['last_read'] = Variable<DateTime>(lastRead);
    return map;
  }

  ContentProgressesCompanion toCompanion(bool nullToAbsent) {
    return ContentProgressesCompanion(
      contentId: Value(contentId),
      lastPosition: Value(lastPosition),
      completionCount: Value(completionCount),
      rereadCount: Value(rereadCount),
      firstRead: Value(firstRead),
      lastRead: Value(lastRead),
    );
  }

  factory ContentProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentProgressRow(
      contentId: serializer.fromJson<String>(json['contentId']),
      lastPosition: serializer.fromJson<int>(json['lastPosition']),
      completionCount: serializer.fromJson<int>(json['completionCount']),
      rereadCount: serializer.fromJson<int>(json['rereadCount']),
      firstRead: serializer.fromJson<DateTime>(json['firstRead']),
      lastRead: serializer.fromJson<DateTime>(json['lastRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'contentId': serializer.toJson<String>(contentId),
      'lastPosition': serializer.toJson<int>(lastPosition),
      'completionCount': serializer.toJson<int>(completionCount),
      'rereadCount': serializer.toJson<int>(rereadCount),
      'firstRead': serializer.toJson<DateTime>(firstRead),
      'lastRead': serializer.toJson<DateTime>(lastRead),
    };
  }

  ContentProgressRow copyWith({
    String? contentId,
    int? lastPosition,
    int? completionCount,
    int? rereadCount,
    DateTime? firstRead,
    DateTime? lastRead,
  }) => ContentProgressRow(
    contentId: contentId ?? this.contentId,
    lastPosition: lastPosition ?? this.lastPosition,
    completionCount: completionCount ?? this.completionCount,
    rereadCount: rereadCount ?? this.rereadCount,
    firstRead: firstRead ?? this.firstRead,
    lastRead: lastRead ?? this.lastRead,
  );
  ContentProgressRow copyWithCompanion(ContentProgressesCompanion data) {
    return ContentProgressRow(
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      lastPosition: data.lastPosition.present
          ? data.lastPosition.value
          : this.lastPosition,
      completionCount: data.completionCount.present
          ? data.completionCount.value
          : this.completionCount,
      rereadCount: data.rereadCount.present
          ? data.rereadCount.value
          : this.rereadCount,
      firstRead: data.firstRead.present ? data.firstRead.value : this.firstRead,
      lastRead: data.lastRead.present ? data.lastRead.value : this.lastRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentProgressRow(')
          ..write('contentId: $contentId, ')
          ..write('lastPosition: $lastPosition, ')
          ..write('completionCount: $completionCount, ')
          ..write('rereadCount: $rereadCount, ')
          ..write('firstRead: $firstRead, ')
          ..write('lastRead: $lastRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    contentId,
    lastPosition,
    completionCount,
    rereadCount,
    firstRead,
    lastRead,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentProgressRow &&
          other.contentId == this.contentId &&
          other.lastPosition == this.lastPosition &&
          other.completionCount == this.completionCount &&
          other.rereadCount == this.rereadCount &&
          other.firstRead == this.firstRead &&
          other.lastRead == this.lastRead);
}

class ContentProgressesCompanion extends UpdateCompanion<ContentProgressRow> {
  final Value<String> contentId;
  final Value<int> lastPosition;
  final Value<int> completionCount;
  final Value<int> rereadCount;
  final Value<DateTime> firstRead;
  final Value<DateTime> lastRead;
  final Value<int> rowid;
  const ContentProgressesCompanion({
    this.contentId = const Value.absent(),
    this.lastPosition = const Value.absent(),
    this.completionCount = const Value.absent(),
    this.rereadCount = const Value.absent(),
    this.firstRead = const Value.absent(),
    this.lastRead = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentProgressesCompanion.insert({
    required String contentId,
    this.lastPosition = const Value.absent(),
    this.completionCount = const Value.absent(),
    this.rereadCount = const Value.absent(),
    required DateTime firstRead,
    required DateTime lastRead,
    this.rowid = const Value.absent(),
  }) : contentId = Value(contentId),
       firstRead = Value(firstRead),
       lastRead = Value(lastRead);
  static Insertable<ContentProgressRow> custom({
    Expression<String>? contentId,
    Expression<int>? lastPosition,
    Expression<int>? completionCount,
    Expression<int>? rereadCount,
    Expression<DateTime>? firstRead,
    Expression<DateTime>? lastRead,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (contentId != null) 'content_id': contentId,
      if (lastPosition != null) 'last_position': lastPosition,
      if (completionCount != null) 'completion_count': completionCount,
      if (rereadCount != null) 'reread_count': rereadCount,
      if (firstRead != null) 'first_read': firstRead,
      if (lastRead != null) 'last_read': lastRead,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentProgressesCompanion copyWith({
    Value<String>? contentId,
    Value<int>? lastPosition,
    Value<int>? completionCount,
    Value<int>? rereadCount,
    Value<DateTime>? firstRead,
    Value<DateTime>? lastRead,
    Value<int>? rowid,
  }) {
    return ContentProgressesCompanion(
      contentId: contentId ?? this.contentId,
      lastPosition: lastPosition ?? this.lastPosition,
      completionCount: completionCount ?? this.completionCount,
      rereadCount: rereadCount ?? this.rereadCount,
      firstRead: firstRead ?? this.firstRead,
      lastRead: lastRead ?? this.lastRead,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (lastPosition.present) {
      map['last_position'] = Variable<int>(lastPosition.value);
    }
    if (completionCount.present) {
      map['completion_count'] = Variable<int>(completionCount.value);
    }
    if (rereadCount.present) {
      map['reread_count'] = Variable<int>(rereadCount.value);
    }
    if (firstRead.present) {
      map['first_read'] = Variable<DateTime>(firstRead.value);
    }
    if (lastRead.present) {
      map['last_read'] = Variable<DateTime>(lastRead.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentProgressesCompanion(')
          ..write('contentId: $contentId, ')
          ..write('lastPosition: $lastPosition, ')
          ..write('completionCount: $completionCount, ')
          ..write('rereadCount: $rereadCount, ')
          ..write('firstRead: $firstRead, ')
          ..write('lastRead: $lastRead, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MasteryEvidencesTable extends MasteryEvidences
    with TableInfo<$MasteryEvidencesTable, MasteryEvidenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MasteryEvidencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vocabIdMeta = const VerificationMeta(
    'vocabId',
  );
  @override
  late final GeneratedColumn<String> vocabId = GeneratedColumn<String>(
    'vocab_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, vocabId, kind, grade, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mastery_evidences';
  @override
  VerificationContext validateIntegrity(
    Insertable<MasteryEvidenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vocab_id')) {
      context.handle(
        _vocabIdMeta,
        vocabId.isAcceptableOrUnknown(data['vocab_id']!, _vocabIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vocabIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MasteryEvidenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MasteryEvidenceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vocabId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocab_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $MasteryEvidencesTable createAlias(String alias) {
    return $MasteryEvidencesTable(attachedDatabase, alias);
  }
}

class MasteryEvidenceRow extends DataClass
    implements Insertable<MasteryEvidenceRow> {
  final int id;
  final String vocabId;

  /// Enum string value of `MasteryEvidenceKind`.
  final String kind;

  /// Enum string value of `RecallGrade`.
  final String grade;
  final DateTime at;
  const MasteryEvidenceRow({
    required this.id,
    required this.vocabId,
    required this.kind,
    required this.grade,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vocab_id'] = Variable<String>(vocabId);
    map['kind'] = Variable<String>(kind);
    map['grade'] = Variable<String>(grade);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  MasteryEvidencesCompanion toCompanion(bool nullToAbsent) {
    return MasteryEvidencesCompanion(
      id: Value(id),
      vocabId: Value(vocabId),
      kind: Value(kind),
      grade: Value(grade),
      at: Value(at),
    );
  }

  factory MasteryEvidenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MasteryEvidenceRow(
      id: serializer.fromJson<int>(json['id']),
      vocabId: serializer.fromJson<String>(json['vocabId']),
      kind: serializer.fromJson<String>(json['kind']),
      grade: serializer.fromJson<String>(json['grade']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vocabId': serializer.toJson<String>(vocabId),
      'kind': serializer.toJson<String>(kind),
      'grade': serializer.toJson<String>(grade),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  MasteryEvidenceRow copyWith({
    int? id,
    String? vocabId,
    String? kind,
    String? grade,
    DateTime? at,
  }) => MasteryEvidenceRow(
    id: id ?? this.id,
    vocabId: vocabId ?? this.vocabId,
    kind: kind ?? this.kind,
    grade: grade ?? this.grade,
    at: at ?? this.at,
  );
  MasteryEvidenceRow copyWithCompanion(MasteryEvidencesCompanion data) {
    return MasteryEvidenceRow(
      id: data.id.present ? data.id.value : this.id,
      vocabId: data.vocabId.present ? data.vocabId.value : this.vocabId,
      kind: data.kind.present ? data.kind.value : this.kind,
      grade: data.grade.present ? data.grade.value : this.grade,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MasteryEvidenceRow(')
          ..write('id: $id, ')
          ..write('vocabId: $vocabId, ')
          ..write('kind: $kind, ')
          ..write('grade: $grade, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vocabId, kind, grade, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MasteryEvidenceRow &&
          other.id == this.id &&
          other.vocabId == this.vocabId &&
          other.kind == this.kind &&
          other.grade == this.grade &&
          other.at == this.at);
}

class MasteryEvidencesCompanion extends UpdateCompanion<MasteryEvidenceRow> {
  final Value<int> id;
  final Value<String> vocabId;
  final Value<String> kind;
  final Value<String> grade;
  final Value<DateTime> at;
  const MasteryEvidencesCompanion({
    this.id = const Value.absent(),
    this.vocabId = const Value.absent(),
    this.kind = const Value.absent(),
    this.grade = const Value.absent(),
    this.at = const Value.absent(),
  });
  MasteryEvidencesCompanion.insert({
    this.id = const Value.absent(),
    required String vocabId,
    required String kind,
    required String grade,
    required DateTime at,
  }) : vocabId = Value(vocabId),
       kind = Value(kind),
       grade = Value(grade),
       at = Value(at);
  static Insertable<MasteryEvidenceRow> custom({
    Expression<int>? id,
    Expression<String>? vocabId,
    Expression<String>? kind,
    Expression<String>? grade,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vocabId != null) 'vocab_id': vocabId,
      if (kind != null) 'kind': kind,
      if (grade != null) 'grade': grade,
      if (at != null) 'at': at,
    });
  }

  MasteryEvidencesCompanion copyWith({
    Value<int>? id,
    Value<String>? vocabId,
    Value<String>? kind,
    Value<String>? grade,
    Value<DateTime>? at,
  }) {
    return MasteryEvidencesCompanion(
      id: id ?? this.id,
      vocabId: vocabId ?? this.vocabId,
      kind: kind ?? this.kind,
      grade: grade ?? this.grade,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vocabId.present) {
      map['vocab_id'] = Variable<String>(vocabId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MasteryEvidencesCompanion(')
          ..write('id: $id, ')
          ..write('vocabId: $vocabId, ')
          ..write('kind: $kind, ')
          ..write('grade: $grade, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $ReviewCardsTable extends ReviewCards
    with TableInfo<$ReviewCardsTable, ReviewCardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vocabIdMeta = const VerificationMeta(
    'vocabId',
  );
  @override
  late final GeneratedColumn<String> vocabId = GeneratedColumn<String>(
    'vocab_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceSentenceMeta = const VerificationMeta(
    'sourceSentence',
  );
  @override
  late final GeneratedColumn<String> sourceSentence = GeneratedColumn<String>(
    'source_sentence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetStartMeta = const VerificationMeta(
    'targetStart',
  );
  @override
  late final GeneratedColumn<int> targetStart = GeneratedColumn<int>(
    'target_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetEndMeta = const VerificationMeta(
    'targetEnd',
  );
  @override
  late final GeneratedColumn<int> targetEnd = GeneratedColumn<int>(
    'target_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visualAssetMeta = const VerificationMeta(
    'visualAsset',
  );
  @override
  late final GeneratedColumn<String> visualAsset = GeneratedColumn<String>(
    'visual_asset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordAudioMeta = const VerificationMeta(
    'wordAudio',
  );
  @override
  late final GeneratedColumn<String> wordAudio = GeneratedColumn<String>(
    'word_audio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fsrsCardStateJsonMeta = const VerificationMeta(
    'fsrsCardStateJson',
  );
  @override
  late final GeneratedColumn<String> fsrsCardStateJson =
      GeneratedColumn<String>(
        'fsrs_card_state_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<DateTime> due = GeneratedColumn<DateTime>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    cardId,
    vocabId,
    sourceSentence,
    targetStart,
    targetEnd,
    visualAsset,
    wordAudio,
    fsrsCardStateJson,
    due,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewCardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('vocab_id')) {
      context.handle(
        _vocabIdMeta,
        vocabId.isAcceptableOrUnknown(data['vocab_id']!, _vocabIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vocabIdMeta);
    }
    if (data.containsKey('source_sentence')) {
      context.handle(
        _sourceSentenceMeta,
        sourceSentence.isAcceptableOrUnknown(
          data['source_sentence']!,
          _sourceSentenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceSentenceMeta);
    }
    if (data.containsKey('target_start')) {
      context.handle(
        _targetStartMeta,
        targetStart.isAcceptableOrUnknown(
          data['target_start']!,
          _targetStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetStartMeta);
    }
    if (data.containsKey('target_end')) {
      context.handle(
        _targetEndMeta,
        targetEnd.isAcceptableOrUnknown(data['target_end']!, _targetEndMeta),
      );
    } else if (isInserting) {
      context.missing(_targetEndMeta);
    }
    if (data.containsKey('visual_asset')) {
      context.handle(
        _visualAssetMeta,
        visualAsset.isAcceptableOrUnknown(
          data['visual_asset']!,
          _visualAssetMeta,
        ),
      );
    }
    if (data.containsKey('word_audio')) {
      context.handle(
        _wordAudioMeta,
        wordAudio.isAcceptableOrUnknown(data['word_audio']!, _wordAudioMeta),
      );
    }
    if (data.containsKey('fsrs_card_state_json')) {
      context.handle(
        _fsrsCardStateJsonMeta,
        fsrsCardStateJson.isAcceptableOrUnknown(
          data['fsrs_card_state_json']!,
          _fsrsCardStateJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fsrsCardStateJsonMeta);
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    } else if (isInserting) {
      context.missing(_dueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  ReviewCardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewCardRow(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      vocabId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocab_id'],
      )!,
      sourceSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_sentence'],
      )!,
      targetStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_start'],
      )!,
      targetEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_end'],
      )!,
      visualAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visual_asset'],
      ),
      wordAudio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_audio'],
      ),
      fsrsCardStateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fsrs_card_state_json'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due'],
      )!,
    );
  }

  @override
  $ReviewCardsTable createAlias(String alias) {
    return $ReviewCardsTable(attachedDatabase, alias);
  }
}

class ReviewCardRow extends DataClass implements Insertable<ReviewCardRow> {
  final String cardId;
  final String vocabId;
  final String sourceSentence;
  final int targetStart;
  final int targetEnd;
  final String? visualAsset;
  final String? wordAudio;

  /// Serialized FSRS scheduler card state (JSON string).
  final String fsrsCardStateJson;
  final DateTime due;
  const ReviewCardRow({
    required this.cardId,
    required this.vocabId,
    required this.sourceSentence,
    required this.targetStart,
    required this.targetEnd,
    this.visualAsset,
    this.wordAudio,
    required this.fsrsCardStateJson,
    required this.due,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['vocab_id'] = Variable<String>(vocabId);
    map['source_sentence'] = Variable<String>(sourceSentence);
    map['target_start'] = Variable<int>(targetStart);
    map['target_end'] = Variable<int>(targetEnd);
    if (!nullToAbsent || visualAsset != null) {
      map['visual_asset'] = Variable<String>(visualAsset);
    }
    if (!nullToAbsent || wordAudio != null) {
      map['word_audio'] = Variable<String>(wordAudio);
    }
    map['fsrs_card_state_json'] = Variable<String>(fsrsCardStateJson);
    map['due'] = Variable<DateTime>(due);
    return map;
  }

  ReviewCardsCompanion toCompanion(bool nullToAbsent) {
    return ReviewCardsCompanion(
      cardId: Value(cardId),
      vocabId: Value(vocabId),
      sourceSentence: Value(sourceSentence),
      targetStart: Value(targetStart),
      targetEnd: Value(targetEnd),
      visualAsset: visualAsset == null && nullToAbsent
          ? const Value.absent()
          : Value(visualAsset),
      wordAudio: wordAudio == null && nullToAbsent
          ? const Value.absent()
          : Value(wordAudio),
      fsrsCardStateJson: Value(fsrsCardStateJson),
      due: Value(due),
    );
  }

  factory ReviewCardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewCardRow(
      cardId: serializer.fromJson<String>(json['cardId']),
      vocabId: serializer.fromJson<String>(json['vocabId']),
      sourceSentence: serializer.fromJson<String>(json['sourceSentence']),
      targetStart: serializer.fromJson<int>(json['targetStart']),
      targetEnd: serializer.fromJson<int>(json['targetEnd']),
      visualAsset: serializer.fromJson<String?>(json['visualAsset']),
      wordAudio: serializer.fromJson<String?>(json['wordAudio']),
      fsrsCardStateJson: serializer.fromJson<String>(json['fsrsCardStateJson']),
      due: serializer.fromJson<DateTime>(json['due']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'vocabId': serializer.toJson<String>(vocabId),
      'sourceSentence': serializer.toJson<String>(sourceSentence),
      'targetStart': serializer.toJson<int>(targetStart),
      'targetEnd': serializer.toJson<int>(targetEnd),
      'visualAsset': serializer.toJson<String?>(visualAsset),
      'wordAudio': serializer.toJson<String?>(wordAudio),
      'fsrsCardStateJson': serializer.toJson<String>(fsrsCardStateJson),
      'due': serializer.toJson<DateTime>(due),
    };
  }

  ReviewCardRow copyWith({
    String? cardId,
    String? vocabId,
    String? sourceSentence,
    int? targetStart,
    int? targetEnd,
    Value<String?> visualAsset = const Value.absent(),
    Value<String?> wordAudio = const Value.absent(),
    String? fsrsCardStateJson,
    DateTime? due,
  }) => ReviewCardRow(
    cardId: cardId ?? this.cardId,
    vocabId: vocabId ?? this.vocabId,
    sourceSentence: sourceSentence ?? this.sourceSentence,
    targetStart: targetStart ?? this.targetStart,
    targetEnd: targetEnd ?? this.targetEnd,
    visualAsset: visualAsset.present ? visualAsset.value : this.visualAsset,
    wordAudio: wordAudio.present ? wordAudio.value : this.wordAudio,
    fsrsCardStateJson: fsrsCardStateJson ?? this.fsrsCardStateJson,
    due: due ?? this.due,
  );
  ReviewCardRow copyWithCompanion(ReviewCardsCompanion data) {
    return ReviewCardRow(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      vocabId: data.vocabId.present ? data.vocabId.value : this.vocabId,
      sourceSentence: data.sourceSentence.present
          ? data.sourceSentence.value
          : this.sourceSentence,
      targetStart: data.targetStart.present
          ? data.targetStart.value
          : this.targetStart,
      targetEnd: data.targetEnd.present ? data.targetEnd.value : this.targetEnd,
      visualAsset: data.visualAsset.present
          ? data.visualAsset.value
          : this.visualAsset,
      wordAudio: data.wordAudio.present ? data.wordAudio.value : this.wordAudio,
      fsrsCardStateJson: data.fsrsCardStateJson.present
          ? data.fsrsCardStateJson.value
          : this.fsrsCardStateJson,
      due: data.due.present ? data.due.value : this.due,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewCardRow(')
          ..write('cardId: $cardId, ')
          ..write('vocabId: $vocabId, ')
          ..write('sourceSentence: $sourceSentence, ')
          ..write('targetStart: $targetStart, ')
          ..write('targetEnd: $targetEnd, ')
          ..write('visualAsset: $visualAsset, ')
          ..write('wordAudio: $wordAudio, ')
          ..write('fsrsCardStateJson: $fsrsCardStateJson, ')
          ..write('due: $due')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cardId,
    vocabId,
    sourceSentence,
    targetStart,
    targetEnd,
    visualAsset,
    wordAudio,
    fsrsCardStateJson,
    due,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewCardRow &&
          other.cardId == this.cardId &&
          other.vocabId == this.vocabId &&
          other.sourceSentence == this.sourceSentence &&
          other.targetStart == this.targetStart &&
          other.targetEnd == this.targetEnd &&
          other.visualAsset == this.visualAsset &&
          other.wordAudio == this.wordAudio &&
          other.fsrsCardStateJson == this.fsrsCardStateJson &&
          other.due == this.due);
}

class ReviewCardsCompanion extends UpdateCompanion<ReviewCardRow> {
  final Value<String> cardId;
  final Value<String> vocabId;
  final Value<String> sourceSentence;
  final Value<int> targetStart;
  final Value<int> targetEnd;
  final Value<String?> visualAsset;
  final Value<String?> wordAudio;
  final Value<String> fsrsCardStateJson;
  final Value<DateTime> due;
  final Value<int> rowid;
  const ReviewCardsCompanion({
    this.cardId = const Value.absent(),
    this.vocabId = const Value.absent(),
    this.sourceSentence = const Value.absent(),
    this.targetStart = const Value.absent(),
    this.targetEnd = const Value.absent(),
    this.visualAsset = const Value.absent(),
    this.wordAudio = const Value.absent(),
    this.fsrsCardStateJson = const Value.absent(),
    this.due = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewCardsCompanion.insert({
    required String cardId,
    required String vocabId,
    required String sourceSentence,
    required int targetStart,
    required int targetEnd,
    this.visualAsset = const Value.absent(),
    this.wordAudio = const Value.absent(),
    required String fsrsCardStateJson,
    required DateTime due,
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       vocabId = Value(vocabId),
       sourceSentence = Value(sourceSentence),
       targetStart = Value(targetStart),
       targetEnd = Value(targetEnd),
       fsrsCardStateJson = Value(fsrsCardStateJson),
       due = Value(due);
  static Insertable<ReviewCardRow> custom({
    Expression<String>? cardId,
    Expression<String>? vocabId,
    Expression<String>? sourceSentence,
    Expression<int>? targetStart,
    Expression<int>? targetEnd,
    Expression<String>? visualAsset,
    Expression<String>? wordAudio,
    Expression<String>? fsrsCardStateJson,
    Expression<DateTime>? due,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (vocabId != null) 'vocab_id': vocabId,
      if (sourceSentence != null) 'source_sentence': sourceSentence,
      if (targetStart != null) 'target_start': targetStart,
      if (targetEnd != null) 'target_end': targetEnd,
      if (visualAsset != null) 'visual_asset': visualAsset,
      if (wordAudio != null) 'word_audio': wordAudio,
      if (fsrsCardStateJson != null) 'fsrs_card_state_json': fsrsCardStateJson,
      if (due != null) 'due': due,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewCardsCompanion copyWith({
    Value<String>? cardId,
    Value<String>? vocabId,
    Value<String>? sourceSentence,
    Value<int>? targetStart,
    Value<int>? targetEnd,
    Value<String?>? visualAsset,
    Value<String?>? wordAudio,
    Value<String>? fsrsCardStateJson,
    Value<DateTime>? due,
    Value<int>? rowid,
  }) {
    return ReviewCardsCompanion(
      cardId: cardId ?? this.cardId,
      vocabId: vocabId ?? this.vocabId,
      sourceSentence: sourceSentence ?? this.sourceSentence,
      targetStart: targetStart ?? this.targetStart,
      targetEnd: targetEnd ?? this.targetEnd,
      visualAsset: visualAsset ?? this.visualAsset,
      wordAudio: wordAudio ?? this.wordAudio,
      fsrsCardStateJson: fsrsCardStateJson ?? this.fsrsCardStateJson,
      due: due ?? this.due,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (vocabId.present) {
      map['vocab_id'] = Variable<String>(vocabId.value);
    }
    if (sourceSentence.present) {
      map['source_sentence'] = Variable<String>(sourceSentence.value);
    }
    if (targetStart.present) {
      map['target_start'] = Variable<int>(targetStart.value);
    }
    if (targetEnd.present) {
      map['target_end'] = Variable<int>(targetEnd.value);
    }
    if (visualAsset.present) {
      map['visual_asset'] = Variable<String>(visualAsset.value);
    }
    if (wordAudio.present) {
      map['word_audio'] = Variable<String>(wordAudio.value);
    }
    if (fsrsCardStateJson.present) {
      map['fsrs_card_state_json'] = Variable<String>(fsrsCardStateJson.value);
    }
    if (due.present) {
      map['due'] = Variable<DateTime>(due.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewCardsCompanion(')
          ..write('cardId: $cardId, ')
          ..write('vocabId: $vocabId, ')
          ..write('sourceSentence: $sourceSentence, ')
          ..write('targetStart: $targetStart, ')
          ..write('targetEnd: $targetEnd, ')
          ..write('visualAsset: $visualAsset, ')
          ..write('wordAudio: $wordAudio, ')
          ..write('fsrsCardStateJson: $fsrsCardStateJson, ')
          ..write('due: $due, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExposuresTable exposures = $ExposuresTable(this);
  late final $ContentProgressesTable contentProgresses =
      $ContentProgressesTable(this);
  late final $MasteryEvidencesTable masteryEvidences = $MasteryEvidencesTable(
    this,
  );
  late final $ReviewCardsTable reviewCards = $ReviewCardsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exposures,
    contentProgresses,
    masteryEvidences,
    reviewCards,
  ];
}

typedef $$ExposuresTableCreateCompanionBuilder =
    ExposuresCompanion Function({
      required String vocabId,
      Value<int> encounterCount,
      required String contentItemIdsJson,
      required DateTime firstSeen,
      required DateTime lastSeen,
      Value<int> rowid,
    });
typedef $$ExposuresTableUpdateCompanionBuilder =
    ExposuresCompanion Function({
      Value<String> vocabId,
      Value<int> encounterCount,
      Value<String> contentItemIdsJson,
      Value<DateTime> firstSeen,
      Value<DateTime> lastSeen,
      Value<int> rowid,
    });

class $$ExposuresTableFilterComposer
    extends Composer<_$AppDatabase, $ExposuresTable> {
  $$ExposuresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get vocabId => $composableBuilder(
    column: $table.vocabId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get encounterCount => $composableBuilder(
    column: $table.encounterCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentItemIdsJson => $composableBuilder(
    column: $table.contentItemIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExposuresTableOrderingComposer
    extends Composer<_$AppDatabase, $ExposuresTable> {
  $$ExposuresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get vocabId => $composableBuilder(
    column: $table.vocabId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get encounterCount => $composableBuilder(
    column: $table.encounterCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentItemIdsJson => $composableBuilder(
    column: $table.contentItemIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExposuresTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExposuresTable> {
  $$ExposuresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get vocabId =>
      $composableBuilder(column: $table.vocabId, builder: (column) => column);

  GeneratedColumn<int> get encounterCount => $composableBuilder(
    column: $table.encounterCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentItemIdsJson => $composableBuilder(
    column: $table.contentItemIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstSeen =>
      $composableBuilder(column: $table.firstSeen, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);
}

class $$ExposuresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExposuresTable,
          ExposureRow,
          $$ExposuresTableFilterComposer,
          $$ExposuresTableOrderingComposer,
          $$ExposuresTableAnnotationComposer,
          $$ExposuresTableCreateCompanionBuilder,
          $$ExposuresTableUpdateCompanionBuilder,
          (
            ExposureRow,
            BaseReferences<_$AppDatabase, $ExposuresTable, ExposureRow>,
          ),
          ExposureRow,
          PrefetchHooks Function()
        > {
  $$ExposuresTableTableManager(_$AppDatabase db, $ExposuresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExposuresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExposuresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExposuresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> vocabId = const Value.absent(),
                Value<int> encounterCount = const Value.absent(),
                Value<String> contentItemIdsJson = const Value.absent(),
                Value<DateTime> firstSeen = const Value.absent(),
                Value<DateTime> lastSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExposuresCompanion(
                vocabId: vocabId,
                encounterCount: encounterCount,
                contentItemIdsJson: contentItemIdsJson,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String vocabId,
                Value<int> encounterCount = const Value.absent(),
                required String contentItemIdsJson,
                required DateTime firstSeen,
                required DateTime lastSeen,
                Value<int> rowid = const Value.absent(),
              }) => ExposuresCompanion.insert(
                vocabId: vocabId,
                encounterCount: encounterCount,
                contentItemIdsJson: contentItemIdsJson,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExposuresTable, ExposureRow>(table),
                  BaseReferences<_$AppDatabase, $ExposuresTable, ExposureRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExposuresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExposuresTable,
      ExposureRow,
      $$ExposuresTableFilterComposer,
      $$ExposuresTableOrderingComposer,
      $$ExposuresTableAnnotationComposer,
      $$ExposuresTableCreateCompanionBuilder,
      $$ExposuresTableUpdateCompanionBuilder,
      (
        ExposureRow,
        BaseReferences<_$AppDatabase, $ExposuresTable, ExposureRow>,
      ),
      ExposureRow,
      PrefetchHooks Function()
    >;
typedef $$ContentProgressesTableCreateCompanionBuilder =
    ContentProgressesCompanion Function({
      required String contentId,
      Value<int> lastPosition,
      Value<int> completionCount,
      Value<int> rereadCount,
      required DateTime firstRead,
      required DateTime lastRead,
      Value<int> rowid,
    });
typedef $$ContentProgressesTableUpdateCompanionBuilder =
    ContentProgressesCompanion Function({
      Value<String> contentId,
      Value<int> lastPosition,
      Value<int> completionCount,
      Value<int> rereadCount,
      Value<DateTime> firstRead,
      Value<DateTime> lastRead,
      Value<int> rowid,
    });

class $$ContentProgressesTableFilterComposer
    extends Composer<_$AppDatabase, $ContentProgressesTable> {
  $$ContentProgressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPosition => $composableBuilder(
    column: $table.lastPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completionCount => $composableBuilder(
    column: $table.completionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rereadCount => $composableBuilder(
    column: $table.rereadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstRead => $composableBuilder(
    column: $table.firstRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRead => $composableBuilder(
    column: $table.lastRead,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentProgressesTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentProgressesTable> {
  $$ContentProgressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPosition => $composableBuilder(
    column: $table.lastPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completionCount => $composableBuilder(
    column: $table.completionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rereadCount => $composableBuilder(
    column: $table.rereadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstRead => $composableBuilder(
    column: $table.firstRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRead => $composableBuilder(
    column: $table.lastRead,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentProgressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentProgressesTable> {
  $$ContentProgressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<int> get lastPosition => $composableBuilder(
    column: $table.lastPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completionCount => $composableBuilder(
    column: $table.completionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rereadCount => $composableBuilder(
    column: $table.rereadCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstRead =>
      $composableBuilder(column: $table.firstRead, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRead =>
      $composableBuilder(column: $table.lastRead, builder: (column) => column);
}

class $$ContentProgressesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentProgressesTable,
          ContentProgressRow,
          $$ContentProgressesTableFilterComposer,
          $$ContentProgressesTableOrderingComposer,
          $$ContentProgressesTableAnnotationComposer,
          $$ContentProgressesTableCreateCompanionBuilder,
          $$ContentProgressesTableUpdateCompanionBuilder,
          (
            ContentProgressRow,
            BaseReferences<
              _$AppDatabase,
              $ContentProgressesTable,
              ContentProgressRow
            >,
          ),
          ContentProgressRow,
          PrefetchHooks Function()
        > {
  $$ContentProgressesTableTableManager(
    _$AppDatabase db,
    $ContentProgressesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentProgressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentProgressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentProgressesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> contentId = const Value.absent(),
                Value<int> lastPosition = const Value.absent(),
                Value<int> completionCount = const Value.absent(),
                Value<int> rereadCount = const Value.absent(),
                Value<DateTime> firstRead = const Value.absent(),
                Value<DateTime> lastRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentProgressesCompanion(
                contentId: contentId,
                lastPosition: lastPosition,
                completionCount: completionCount,
                rereadCount: rereadCount,
                firstRead: firstRead,
                lastRead: lastRead,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String contentId,
                Value<int> lastPosition = const Value.absent(),
                Value<int> completionCount = const Value.absent(),
                Value<int> rereadCount = const Value.absent(),
                required DateTime firstRead,
                required DateTime lastRead,
                Value<int> rowid = const Value.absent(),
              }) => ContentProgressesCompanion.insert(
                contentId: contentId,
                lastPosition: lastPosition,
                completionCount: completionCount,
                rereadCount: rereadCount,
                firstRead: firstRead,
                lastRead: lastRead,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContentProgressesTable, ContentProgressRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ContentProgressesTable,
                    ContentProgressRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentProgressesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentProgressesTable,
      ContentProgressRow,
      $$ContentProgressesTableFilterComposer,
      $$ContentProgressesTableOrderingComposer,
      $$ContentProgressesTableAnnotationComposer,
      $$ContentProgressesTableCreateCompanionBuilder,
      $$ContentProgressesTableUpdateCompanionBuilder,
      (
        ContentProgressRow,
        BaseReferences<
          _$AppDatabase,
          $ContentProgressesTable,
          ContentProgressRow
        >,
      ),
      ContentProgressRow,
      PrefetchHooks Function()
    >;
typedef $$MasteryEvidencesTableCreateCompanionBuilder =
    MasteryEvidencesCompanion Function({
      Value<int> id,
      required String vocabId,
      required String kind,
      required String grade,
      required DateTime at,
    });
typedef $$MasteryEvidencesTableUpdateCompanionBuilder =
    MasteryEvidencesCompanion Function({
      Value<int> id,
      Value<String> vocabId,
      Value<String> kind,
      Value<String> grade,
      Value<DateTime> at,
    });

class $$MasteryEvidencesTableFilterComposer
    extends Composer<_$AppDatabase, $MasteryEvidencesTable> {
  $$MasteryEvidencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vocabId => $composableBuilder(
    column: $table.vocabId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MasteryEvidencesTableOrderingComposer
    extends Composer<_$AppDatabase, $MasteryEvidencesTable> {
  $$MasteryEvidencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vocabId => $composableBuilder(
    column: $table.vocabId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MasteryEvidencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MasteryEvidencesTable> {
  $$MasteryEvidencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vocabId =>
      $composableBuilder(column: $table.vocabId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$MasteryEvidencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MasteryEvidencesTable,
          MasteryEvidenceRow,
          $$MasteryEvidencesTableFilterComposer,
          $$MasteryEvidencesTableOrderingComposer,
          $$MasteryEvidencesTableAnnotationComposer,
          $$MasteryEvidencesTableCreateCompanionBuilder,
          $$MasteryEvidencesTableUpdateCompanionBuilder,
          (
            MasteryEvidenceRow,
            BaseReferences<
              _$AppDatabase,
              $MasteryEvidencesTable,
              MasteryEvidenceRow
            >,
          ),
          MasteryEvidenceRow,
          PrefetchHooks Function()
        > {
  $$MasteryEvidencesTableTableManager(
    _$AppDatabase db,
    $MasteryEvidencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MasteryEvidencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MasteryEvidencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MasteryEvidencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> vocabId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> grade = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => MasteryEvidencesCompanion(
                id: id,
                vocabId: vocabId,
                kind: kind,
                grade: grade,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String vocabId,
                required String kind,
                required String grade,
                required DateTime at,
              }) => MasteryEvidencesCompanion.insert(
                id: id,
                vocabId: vocabId,
                kind: kind,
                grade: grade,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MasteryEvidencesTable, MasteryEvidenceRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $MasteryEvidencesTable,
                    MasteryEvidenceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MasteryEvidencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MasteryEvidencesTable,
      MasteryEvidenceRow,
      $$MasteryEvidencesTableFilterComposer,
      $$MasteryEvidencesTableOrderingComposer,
      $$MasteryEvidencesTableAnnotationComposer,
      $$MasteryEvidencesTableCreateCompanionBuilder,
      $$MasteryEvidencesTableUpdateCompanionBuilder,
      (
        MasteryEvidenceRow,
        BaseReferences<
          _$AppDatabase,
          $MasteryEvidencesTable,
          MasteryEvidenceRow
        >,
      ),
      MasteryEvidenceRow,
      PrefetchHooks Function()
    >;
typedef $$ReviewCardsTableCreateCompanionBuilder =
    ReviewCardsCompanion Function({
      required String cardId,
      required String vocabId,
      required String sourceSentence,
      required int targetStart,
      required int targetEnd,
      Value<String?> visualAsset,
      Value<String?> wordAudio,
      required String fsrsCardStateJson,
      required DateTime due,
      Value<int> rowid,
    });
typedef $$ReviewCardsTableUpdateCompanionBuilder =
    ReviewCardsCompanion Function({
      Value<String> cardId,
      Value<String> vocabId,
      Value<String> sourceSentence,
      Value<int> targetStart,
      Value<int> targetEnd,
      Value<String?> visualAsset,
      Value<String?> wordAudio,
      Value<String> fsrsCardStateJson,
      Value<DateTime> due,
      Value<int> rowid,
    });

class $$ReviewCardsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewCardsTable> {
  $$ReviewCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vocabId => $composableBuilder(
    column: $table.vocabId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceSentence => $composableBuilder(
    column: $table.sourceSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetStart => $composableBuilder(
    column: $table.targetStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetEnd => $composableBuilder(
    column: $table.targetEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visualAsset => $composableBuilder(
    column: $table.visualAsset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wordAudio => $composableBuilder(
    column: $table.wordAudio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fsrsCardStateJson => $composableBuilder(
    column: $table.fsrsCardStateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewCardsTable> {
  $$ReviewCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vocabId => $composableBuilder(
    column: $table.vocabId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceSentence => $composableBuilder(
    column: $table.sourceSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetStart => $composableBuilder(
    column: $table.targetStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetEnd => $composableBuilder(
    column: $table.targetEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visualAsset => $composableBuilder(
    column: $table.visualAsset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wordAudio => $composableBuilder(
    column: $table.wordAudio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fsrsCardStateJson => $composableBuilder(
    column: $table.fsrsCardStateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewCardsTable> {
  $$ReviewCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get vocabId =>
      $composableBuilder(column: $table.vocabId, builder: (column) => column);

  GeneratedColumn<String> get sourceSentence => $composableBuilder(
    column: $table.sourceSentence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetStart => $composableBuilder(
    column: $table.targetStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetEnd =>
      $composableBuilder(column: $table.targetEnd, builder: (column) => column);

  GeneratedColumn<String> get visualAsset => $composableBuilder(
    column: $table.visualAsset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wordAudio =>
      $composableBuilder(column: $table.wordAudio, builder: (column) => column);

  GeneratedColumn<String> get fsrsCardStateJson => $composableBuilder(
    column: $table.fsrsCardStateJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);
}

class $$ReviewCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewCardsTable,
          ReviewCardRow,
          $$ReviewCardsTableFilterComposer,
          $$ReviewCardsTableOrderingComposer,
          $$ReviewCardsTableAnnotationComposer,
          $$ReviewCardsTableCreateCompanionBuilder,
          $$ReviewCardsTableUpdateCompanionBuilder,
          (
            ReviewCardRow,
            BaseReferences<_$AppDatabase, $ReviewCardsTable, ReviewCardRow>,
          ),
          ReviewCardRow,
          PrefetchHooks Function()
        > {
  $$ReviewCardsTableTableManager(_$AppDatabase db, $ReviewCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<String> vocabId = const Value.absent(),
                Value<String> sourceSentence = const Value.absent(),
                Value<int> targetStart = const Value.absent(),
                Value<int> targetEnd = const Value.absent(),
                Value<String?> visualAsset = const Value.absent(),
                Value<String?> wordAudio = const Value.absent(),
                Value<String> fsrsCardStateJson = const Value.absent(),
                Value<DateTime> due = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewCardsCompanion(
                cardId: cardId,
                vocabId: vocabId,
                sourceSentence: sourceSentence,
                targetStart: targetStart,
                targetEnd: targetEnd,
                visualAsset: visualAsset,
                wordAudio: wordAudio,
                fsrsCardStateJson: fsrsCardStateJson,
                due: due,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required String vocabId,
                required String sourceSentence,
                required int targetStart,
                required int targetEnd,
                Value<String?> visualAsset = const Value.absent(),
                Value<String?> wordAudio = const Value.absent(),
                required String fsrsCardStateJson,
                required DateTime due,
                Value<int> rowid = const Value.absent(),
              }) => ReviewCardsCompanion.insert(
                cardId: cardId,
                vocabId: vocabId,
                sourceSentence: sourceSentence,
                targetStart: targetStart,
                targetEnd: targetEnd,
                visualAsset: visualAsset,
                wordAudio: wordAudio,
                fsrsCardStateJson: fsrsCardStateJson,
                due: due,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewCardsTable, ReviewCardRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReviewCardsTable,
                    ReviewCardRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewCardsTable,
      ReviewCardRow,
      $$ReviewCardsTableFilterComposer,
      $$ReviewCardsTableOrderingComposer,
      $$ReviewCardsTableAnnotationComposer,
      $$ReviewCardsTableCreateCompanionBuilder,
      $$ReviewCardsTableUpdateCompanionBuilder,
      (
        ReviewCardRow,
        BaseReferences<_$AppDatabase, $ReviewCardsTable, ReviewCardRow>,
      ),
      ReviewCardRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExposuresTableTableManager get exposures =>
      $$ExposuresTableTableManager(_db, _db.exposures);
  $$ContentProgressesTableTableManager get contentProgresses =>
      $$ContentProgressesTableTableManager(_db, _db.contentProgresses);
  $$MasteryEvidencesTableTableManager get masteryEvidences =>
      $$MasteryEvidencesTableTableManager(_db, _db.masteryEvidences);
  $$ReviewCardsTableTableManager get reviewCards =>
      $$ReviewCardsTableTableManager(_db, _db.reviewCards);
}
