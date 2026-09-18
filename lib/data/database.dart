/// Drift SQLite database schema (D-01, ARCHITECTURE.md §4).
///
/// Implements bounded aggregates for word exposure and content progress,
/// storing explicit learning data only (§6 privacy boundary).
library;

import 'package:drift/drift.dart';

part 'database.g.dart';

/// Table storing bounded per-word exposure aggregates (LEARNING_ENGINE.md §2).
///
/// One row per word ever encountered. Upserted in place on every encounter.
@DataClassName('ExposureRow')
class Exposures extends Table {
  TextColumn get vocabId => text()();
  IntColumn get encounterCount => integer().withDefault(const Constant(1))();

  /// JSON-encoded array of distinct content item IDs (e.g. `["story-1"]`).
  TextColumn get contentItemIdsJson => text()();

  DateTimeColumn get firstSeen => dateTime()();
  DateTimeColumn get lastSeen => dateTime()();

  @override
  Set<Column> get primaryKey => {vocabId};
}

/// Table storing reading progress and completion history (CONTENT.md §3, §7).
///
/// One row per content item ever opened.
@DataClassName('ContentProgressRow')
class ContentProgresses extends Table {
  TextColumn get contentId => text()();
  IntColumn get lastPosition => integer().withDefault(const Constant(0))();
  IntColumn get completionCount => integer().withDefault(const Constant(0))();
  IntColumn get rereadCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get firstRead => dateTime()();
  DateTimeColumn get lastRead => dateTime()();

  @override
  Set<Column> get primaryKey => {contentId};
}

/// Table storing explicit mastery evidence (LEARNING_ENGINE.md §2).
///
/// Explicit review/recognition outcomes used to derive known vocabulary/Hanzi.
@DataClassName('MasteryEvidenceRow')
class MasteryEvidences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get vocabId => text()();

  /// Enum string value of `MasteryEvidenceKind`.
  TextColumn get kind => text()();

  /// Enum string value of `RecallGrade`.
  TextColumn get grade => text()();

  DateTimeColumn get at => dateTime()();
}

/// Table storing SRS review cards and FSRS scheduling state (D-04, E-03).
///
/// Separates review cards from learner state.
@DataClassName('ReviewCardRow')
class ReviewCards extends Table {
  TextColumn get cardId => text()();
  TextColumn get vocabId => text()();
  TextColumn get sourceSentence => text()();
  IntColumn get targetStart => integer()();
  IntColumn get targetEnd => integer()();
  TextColumn get visualAsset => text().nullable()();
  TextColumn get wordAudio => text().nullable()();

  /// Serialized FSRS scheduler card state (JSON string).
  TextColumn get fsrsCardStateJson => text()();

  DateTimeColumn get due => dateTime()();

  @override
  Set<Column> get primaryKey => {cardId};
}

@DriftDatabase(
  tables: [Exposures, ContentProgresses, MasteryEvidences, ReviewCards],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
