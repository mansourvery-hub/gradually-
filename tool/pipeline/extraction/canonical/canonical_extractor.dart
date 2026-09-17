import '../../ingestion/source_ingester.dart';
import 'canonical_model.dart';

/// Single-pass, linear-time extractor for Canonical Story Model.
class CanonicalStoryExtractor {
  const CanonicalStoryExtractor();

  static final Map<String, String> _kinshipPatterns = {
    '外孙女': 'maternal_granddaughter',
    '孙儿': 'grandson',
    '祖母': 'grandmother',
    '外祖母': 'maternal_grandmother',
    '母亲': 'mother',
    '娘': 'mother',
    '父亲': 'father',
    '爹': 'father',
    '姑母': 'paternal_aunt',
    '舅兄': 'brother_in_law',
    '表兄': 'cousin_elder_brother',
    '表妹': 'cousin_younger_sister',
    '丫鬟': 'maidservant',
    '丫头': 'maidservant',
    '夫人': 'wife',
  };

  static final RegExp _locationSuffixes = RegExp(
    r'([一-龥]{1,3}(?:府|院|馆|园|庵|寺|阁|楼|亭|境|村))',
  );

  static final RegExp _namePatterns = RegExp(
    r'(?:贾|林|薛|王|甄|史|尤|秦|李|邢)[一-龥]{1,2}|(?:黛玉|宝玉|宝钗|熙凤|袭人|晴雯|紫鹃|平儿|元春|迎春|探春|惜春|湘云|妙玉)',
  );

  CanonicalStoryModel extract(SourceArtifact artifact, {int? maxChapters}) {
    final Map<String, CanonicalEntity> entityMap = {};
    final List<CanonicalRelationship> relationships = [];
    final List<CanonicalEvent> events = [];

    final chaptersToProcess = maxChapters != null
        ? artifact.chapters.take(maxChapters).toList()
        : artifact.chapters;

    int temporalCounter = 0;

    for (final chapter in chaptersToProcess) {
      final chIdx = chapter.chapterIndex;

      // 1. Single pass over segments of this chapter to discover entities & local relationships
      final chapterEntities = <String>{};

      for (final seg in chapter.segments) {
        final text = seg.normalizedText;

        // Fast location match
        for (final m in _locationSuffixes.allMatches(text)) {
          final locName = m.group(1)!;
          if (locName.length >= 2 && !_isGeneric(locName)) {
            final locId = 'loc_$locName';
            chapterEntities.add(locId);
            if (!entityMap.containsKey(locId)) {
              final idx = seg.rawText.indexOf(locName);
              final start = idx != -1
                  ? seg.rawStartOffset + idx
                  : seg.rawStartOffset;
              entityMap[locId] = CanonicalEntity(
                id: locId,
                name: locName,
                type: EntityType.location,
                kind: FactKind.sourceFact,
                evidence: [
                  SourceEvidence(
                    segmentId: seg.id,
                    chapterIndex: chIdx,
                    rawStartOffset: start,
                    rawEndOffset: start + locName.length,
                    snippet: locName,
                    isDirectQuote: true,
                  ),
                ],
                confidence: 0.90,
                firstChapter: chIdx,
              );
            }
          }
        }

        // Fast character match
        final segCharacters = <String>[];
        for (final m in _namePatterns.allMatches(text)) {
          final name = m.group(0)!;
          if (!_isGeneric(name)) {
            final charId = 'char_$name';
            chapterEntities.add(charId);
            segCharacters.add(charId);

            if (!entityMap.containsKey(charId)) {
              final idx = seg.rawText.indexOf(name);
              final start = idx != -1
                  ? seg.rawStartOffset + idx
                  : seg.rawStartOffset;
              entityMap[charId] = CanonicalEntity(
                id: charId,
                name: name,
                type: EntityType.character,
                kind: FactKind.sourceFact,
                evidence: [
                  SourceEvidence(
                    segmentId: seg.id,
                    chapterIndex: chIdx,
                    rawStartOffset: start,
                    rawEndOffset: start + name.length,
                    snippet: name,
                    isDirectQuote: true,
                  ),
                ],
                confidence: 0.92,
                firstChapter: chIdx,
              );
            }
          }
        }

        // Fast relationship match: only if segment has 2+ characters and a kinship word
        if (segCharacters.length >= 2) {
          for (final entry in _kinshipPatterns.entries) {
            if (text.contains(entry.key)) {
              final c1 = segCharacters[0];
              final c2 = segCharacters[1];
              if (c1 != c2) {
                final relId = 'rel_${c1}_${c2}_${entry.value}';
                if (!relationships.any((r) => r.id == relId)) {
                  final idx = seg.rawText.indexOf(entry.key);
                  final start = idx != -1
                      ? seg.rawStartOffset + idx
                      : seg.rawStartOffset;
                  relationships.add(
                    CanonicalRelationship(
                      id: relId,
                      fromEntityId: c1,
                      toEntityId: c2,
                      relationType: entry.value,
                      kind: FactKind.derivedFact,
                      evidence: [
                        SourceEvidence(
                          segmentId: seg.id,
                          chapterIndex: chIdx,
                          rawStartOffset: start,
                          rawEndOffset: start + entry.key.length,
                          snippet: entry.key,
                        ),
                      ],
                      confidence: 0.85,
                    ),
                  );
                }
              }
            }
          }
        }
      }

      // 2. Create canonical events for this chapter title (once per chapter)
      final headerSeg = chapter.segments.firstWhere(
        (s) => s.isChapterHeader,
        orElse: () => chapter.segments.first,
      );
      final titleClean = _cleanChapterTitle(chapter.title);
      final subTitles = _splitChapterTitleEvents(titleClean);

      for (final subTitle in subTitles) {
        temporalCounter++;
        final eventId = 'ev_ch${chIdx}_$temporalCounter';

        final participants = <String>[];
        final locations = <String>[];

        for (final entId in chapterEntities) {
          final ent = entityMap[entId]!;
          if (subTitle.contains(ent.name)) {
            if (ent.type == EntityType.character) {
              participants.add(ent.id);
            } else if (ent.type == EntityType.location) {
              locations.add(ent.id);
            }
          }
        }

        events.add(
          CanonicalEvent(
            id: eventId,
            chapterIndex: chIdx,
            temporalOrder: temporalCounter,
            title: subTitle,
            summary: 'Chapter $chIdx: $subTitle',
            participants: participants,
            locations: locations,
            kind: FactKind.sourceFact,
            evidence: [
              SourceEvidence(
                segmentId: headerSeg.id,
                chapterIndex: chIdx,
                rawStartOffset: headerSeg.rawStartOffset,
                rawEndOffset: headerSeg.rawEndOffset,
                snippet: subTitle,
                isDirectQuote: true,
              ),
            ],
            confidence: 0.95,
            causalPredecessors: temporalCounter > 1
                ? ['ev_ch${events.last.chapterIndex}_${temporalCounter - 1}']
                : const [],
          ),
        );
      }
    }

    return CanonicalStoryModel(
      sourceId: artifact.sourceId,
      sourceHash: artifact.contentHash,
      entities: entityMap.values.toList(),
      relationships: relationships,
      events: events,
    );
  }

  bool _isGeneric(String word) {
    const generic = {
      '这个',
      '那个',
      '如此',
      '不过',
      '不知',
      '只见',
      '听见',
      '如何',
      '一面',
      '出来',
      '进去',
      '起来',
      '下去',
      '何事',
      '何人',
      '今日',
      '一日',
      '二人',
      '众人',
      '自己',
      '东西',
      '什么',
      '后来',
      '原来',
      '因此',
      '那里',
      '这里',
      '他们',
      '我们',
      '你们',
      '夫人',
      '姑娘',
    };
    return generic.contains(word);
  }

  String _cleanChapterTitle(String title) {
    return title
        .replaceFirst(
          RegExp(r'^(?:第\s*[0-9零一二三四五六七八九十百千万]+\s*[章回卷节]|Chapter\s*\d+)\s*'),
          '',
        )
        .trim();
  }

  List<String> _splitChapterTitleEvents(String cleanedTitle) {
    final parts = cleanedTitle.split(RegExp(r'\s+'));
    final filtered = parts
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return filtered.isNotEmpty ? filtered : [cleanedTitle];
  }
}
