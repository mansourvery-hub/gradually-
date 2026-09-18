import '../../ingestion/source_ingester.dart';
import 'canonical_model.dart';

/// Independent validator verifying source-grounding and provenance of a [CanonicalStoryModel].
class CanonicalGroundingValidator {
  const CanonicalGroundingValidator();

  ValidationResult validate({
    required CanonicalStoryModel model,
    required SourceArtifact artifact,
  }) {
    final List<String> failures = [];
    final List<String> warnings = [];

    // Check 1: Source hash alignment
    if (model.sourceHash != artifact.contentHash) {
      failures.add(
        'Source hash mismatch: model(${model.sourceHash}) vs artifact(${artifact.contentHash})',
      );
    }

    final rawText = artifact.rawText;

    // Check 2: Verify Entities Provenance & Evidence Offsets
    for (final entity in model.entities) {
      if (!entity.hasValidProvenance) {
        failures.add(
          'Entity ${entity.id} (${entity.name}) has no provenance evidence',
        );
        continue;
      }

      for (final ev in entity.evidence) {
        if (ev.rawStartOffset < 0 ||
            ev.rawEndOffset > rawText.length ||
            ev.rawStartOffset >= ev.rawEndOffset) {
          failures.add(
            'Entity ${entity.id} has invalid offset range: [${ev.rawStartOffset}, ${ev.rawEndOffset}]',
          );
        } else {
          final snippetInSource = rawText.substring(
            ev.rawStartOffset,
            ev.rawEndOffset,
          );
          if (ev.snippet.isNotEmpty && !snippetInSource.contains(ev.snippet)) {
            failures.add(
              'Entity ${entity.id} (${entity.name}) evidence snippet "${ev.snippet}" does not match snippet in source: "$snippetInSource"',
            );
          } else if (ev.isDirectQuote &&
              !snippetInSource.contains(entity.name)) {
            failures.add(
              'Direct quote evidence for ${entity.name} does not match text at offset: "$snippetInSource"',
            );
          }
        }
      }
    }

    // Check 3: Verify Events Provenance
    for (final event in model.events) {
      if (!event.hasValidProvenance) {
        failures.add('Event ${event.id} has no provenance evidence');
        continue;
      }

      for (final ev in event.evidence) {
        if (ev.rawStartOffset < 0 ||
            ev.rawEndOffset > rawText.length ||
            ev.rawStartOffset >= ev.rawEndOffset) {
          failures.add(
            'Event ${event.id} has invalid offset range: [${ev.rawStartOffset}, ${ev.rawEndOffset}]',
          );
        } else {
          final snippetInSource = rawText.substring(
            ev.rawStartOffset,
            ev.rawEndOffset,
          );
          if (ev.snippet.isNotEmpty && !snippetInSource.contains(ev.snippet)) {
            failures.add(
              'Event ${event.id} evidence snippet "${ev.snippet}" is not found in source snippet: "$snippetInSource"',
            );
          }
        }
      }
    }

    // Check 4: Verify Relationships Reference Existing Entities
    final entityIds = model.entities.map((e) => e.id).toSet();
    for (final rel in model.relationships) {
      if (!entityIds.contains(rel.fromEntityId)) {
        failures.add(
          'Relationship ${rel.id} references missing fromEntityId: ${rel.fromEntityId}',
        );
      }
      if (!entityIds.contains(rel.toEntityId)) {
        failures.add(
          'Relationship ${rel.id} references missing toEntityId: ${rel.toEntityId}',
        );
      }
      if (!rel.hasValidProvenance) {
        failures.add('Relationship ${rel.id} has no provenance evidence');
      }
    }

    return ValidationResult(
      passed: failures.isEmpty,
      failures: failures,
      warnings: warnings,
    );
  }
}

class ValidationResult {
  const ValidationResult({
    required this.passed,
    required this.failures,
    required this.warnings,
  });

  final bool passed;
  final List<String> failures;
  final List<String> warnings;

  Map<String, dynamic> toJson() => {
    'passed': passed,
    'failures': failures,
    'warnings': warnings,
  };
}
