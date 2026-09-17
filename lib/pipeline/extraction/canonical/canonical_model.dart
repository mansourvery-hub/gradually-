/// Kind of fact in the Mother Story / Canonical representation.
enum FactKind {
  /// Directly quoted or unambiguously stated in the source text.
  sourceFact,

  /// Inferred from context with cited source passages and confidence rating.
  derivedFact,

  /// High-level narrative or thematic interpretation.
  interpretation,
}

/// Type of entity extracted from the novel.
enum EntityType { character, location, clan, artifact }

/// Concrete evidence supporting an extracted fact or entity.
class SourceEvidence {
  const SourceEvidence({
    required this.segmentId,
    required this.chapterIndex,
    required this.rawStartOffset,
    required this.rawEndOffset,
    required this.snippet,
    this.isDirectQuote = false,
  });

  final String segmentId;
  final int chapterIndex;
  final int rawStartOffset;
  final int rawEndOffset;
  final String snippet;
  final bool isDirectQuote;

  Map<String, dynamic> toJson() => {
    'segmentId': segmentId,
    'chapterIndex': chapterIndex,
    'rawStartOffset': rawStartOffset,
    'rawEndOffset': rawEndOffset,
    'snippet': snippet,
    'isDirectQuote': isDirectQuote,
  };

  factory SourceEvidence.fromJson(Map<String, dynamic> json) => SourceEvidence(
    segmentId: json['segmentId'] as String,
    chapterIndex: json['chapterIndex'] as int,
    rawStartOffset: json['rawStartOffset'] as int,
    rawEndOffset: json['rawEndOffset'] as int,
    snippet: json['snippet'] as String,
    isDirectQuote: json['isDirectQuote'] as bool? ?? false,
  );
}

/// A canonical entity (character, location, clan, artifact) grounded in source text.
class CanonicalEntity {
  const CanonicalEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.kind,
    required this.evidence,
    required this.confidence,
    required this.firstChapter,
    this.aliases = const [],
    this.attributes = const {},
  });

  final String id;
  final String name;
  final EntityType type;
  final FactKind kind;
  final List<SourceEvidence> evidence;
  final double confidence;
  final int firstChapter;
  final List<String> aliases;
  final Map<String, dynamic> attributes;

  bool get hasValidProvenance => evidence.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'kind': kind.name,
    'evidence': evidence.map((e) => e.toJson()).toList(),
    'confidence': confidence,
    'firstChapter': firstChapter,
    'aliases': aliases,
    'attributes': attributes,
  };

  factory CanonicalEntity.fromJson(Map<String, dynamic> json) =>
      CanonicalEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        type: EntityType.values.byName(json['type'] as String),
        kind: FactKind.values.byName(json['kind'] as String),
        evidence: (json['evidence'] as List<dynamic>)
            .map((e) => SourceEvidence.fromJson(e as Map<String, dynamic>))
            .toList(),
        confidence: (json['confidence'] as num).toDouble(),
        firstChapter: json['firstChapter'] as int,
        aliases:
            (json['aliases'] as List<dynamic>?)?.cast<String>() ?? const [],
        attributes: (json['attributes'] as Map<String, dynamic>?) ?? const {},
      );
}

/// A relationship between two entities grounded in source evidence.
class CanonicalRelationship {
  const CanonicalRelationship({
    required this.id,
    required this.fromEntityId,
    required this.toEntityId,
    required this.relationType,
    required this.kind,
    required this.evidence,
    required this.confidence,
  });

  final String id;
  final String fromEntityId;
  final String toEntityId;
  final String relationType;
  final FactKind kind;
  final List<SourceEvidence> evidence;
  final double confidence;

  bool get hasValidProvenance => evidence.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromEntityId': fromEntityId,
    'toEntityId': toEntityId,
    'relationType': relationType,
    'kind': kind.name,
    'evidence': evidence.map((e) => e.toJson()).toList(),
    'confidence': confidence,
  };

  factory CanonicalRelationship.fromJson(Map<String, dynamic> json) =>
      CanonicalRelationship(
        id: json['id'] as String,
        fromEntityId: json['fromEntityId'] as String,
        toEntityId: json['toEntityId'] as String,
        relationType: json['relationType'] as String,
        kind: FactKind.values.byName(json['kind'] as String),
        evidence: (json['evidence'] as List<dynamic>)
            .map((e) => SourceEvidence.fromJson(e as Map<String, dynamic>))
            .toList(),
        confidence: (json['confidence'] as num).toDouble(),
      );
}

/// A discrete canonical event/scene in the novel with temporal sequence and provenance.
class CanonicalEvent {
  const CanonicalEvent({
    required this.id,
    required this.chapterIndex,
    required this.temporalOrder,
    required this.title,
    required this.summary,
    required this.participants,
    required this.locations,
    required this.kind,
    required this.evidence,
    required this.confidence,
    this.causalPredecessors = const [],
    this.narrativeThread = 'main',
  });

  final String id;
  final int chapterIndex;
  final int temporalOrder;
  final String title;
  final String summary;
  final List<String> participants;
  final List<String> locations;
  final FactKind kind;
  final List<SourceEvidence> evidence;
  final double confidence;
  final List<String> causalPredecessors;
  final String narrativeThread;

  bool get hasValidProvenance => evidence.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'chapterIndex': chapterIndex,
    'temporalOrder': temporalOrder,
    'title': title,
    'summary': summary,
    'participants': participants,
    'locations': locations,
    'kind': kind.name,
    'evidence': evidence.map((e) => e.toJson()).toList(),
    'confidence': confidence,
    'causalPredecessors': causalPredecessors,
    'narrativeThread': narrativeThread,
  };

  factory CanonicalEvent.fromJson(Map<String, dynamic> json) => CanonicalEvent(
    id: json['id'] as String,
    chapterIndex: json['chapterIndex'] as int,
    temporalOrder: json['temporalOrder'] as int,
    title: json['title'] as String,
    summary: json['summary'] as String,
    participants: (json['participants'] as List<dynamic>).cast<String>(),
    locations: (json['locations'] as List<dynamic>).cast<String>(),
    kind: FactKind.values.byName(json['kind'] as String),
    evidence: (json['evidence'] as List<dynamic>)
        .map((e) => SourceEvidence.fromJson(e as Map<String, dynamic>))
        .toList(),
    confidence: (json['confidence'] as num).toDouble(),
    causalPredecessors:
        (json['causalPredecessors'] as List<dynamic>?)?.cast<String>() ??
        const [],
    narrativeThread: json['narrativeThread'] as String? ?? 'main',
  );
}

/// The complete Canonical Story Model extracted from the source novel.
class CanonicalStoryModel {
  const CanonicalStoryModel({
    required this.sourceId,
    required this.sourceHash,
    required this.entities,
    required this.relationships,
    required this.events,
  });

  final String sourceId;
  final String sourceHash;
  final List<CanonicalEntity> entities;
  final List<CanonicalRelationship> relationships;
  final List<CanonicalEvent> events;

  List<CanonicalEntity> get characters =>
      entities.where((e) => e.type == EntityType.character).toList();

  List<CanonicalEntity> get locations =>
      entities.where((e) => e.type == EntityType.location).toList();

  Map<String, dynamic> toJson() => {
    'sourceId': sourceId,
    'sourceHash': sourceHash,
    'entities': entities.map((e) => e.toJson()).toList(),
    'relationships': relationships.map((r) => r.toJson()).toList(),
    'events': events.map((e) => e.toJson()).toList(),
  };

  factory CanonicalStoryModel.fromJson(Map<String, dynamic> json) =>
      CanonicalStoryModel(
        sourceId: json['sourceId'] as String,
        sourceHash: json['sourceHash'] as String,
        entities: (json['entities'] as List<dynamic>)
            .map((e) => CanonicalEntity.fromJson(e as Map<String, dynamic>))
            .toList(),
        relationships: (json['relationships'] as List<dynamic>)
            .map(
              (r) => CanonicalRelationship.fromJson(r as Map<String, dynamic>),
            )
            .toList(),
        events: (json['events'] as List<dynamic>)
            .map((e) => CanonicalEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toReport() {
    final totalObjects = entities.length + relationships.length + events.length;
    final objectsWithProvenance =
        entities.where((e) => e.hasValidProvenance).length +
        relationships.where((r) => r.hasValidProvenance).length +
        events.where((e) => e.hasValidProvenance).length;

    final coverage = totalObjects == 0
        ? 1.0
        : objectsWithProvenance / totalObjects;

    return {
      'source_id': sourceId,
      'source_hash': sourceHash,
      'characters_count': characters.length,
      'locations_count': locations.length,
      'relationships_count': relationships.length,
      'events_count': events.length,
      'total_objects': totalObjects,
      'provenance_coverage': coverage,
      'unsupported_objects': totalObjects - objectsWithProvenance,
    };
  }
}
