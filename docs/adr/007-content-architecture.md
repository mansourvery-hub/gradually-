# ADR-007: Content architecture — corpus as data, sequencing as a replaceable engine

**Status:** Accepted (2026-09-13) · **Supersedes:** the "Dart corpus mirror"
half of ADR-005

## Context

The original implementation compiled the entire curriculum into
`lib/content/bootstrap_corpus.dart` (a 45-word const lexicon, a unit
generator with chained prerequisites, and four inlined stories) while the
JSON corpus in `assets/content/` — nominally the authoring source of truth
— was never loaded at runtime and had drifted from the Dart mirror. Adding
a story meant editing application code. Sequencing was dominated by
`curriculumOrder`, effectively linear, and the UI fell back to
`bootstrapCurriculum.firstOrNull`, coupling reader code to a curriculum.

## Decision

> **CONTENT IS DATA. SEQUENCING IS LOGIC. PRESENTATION IS UI.**

1. **Corpus lives in data files only.**
   - Beginner units are *generated* from the target lexicon
     (`bootstrap_target_lexicon.json`, now carrying the concept-asset
     reference per word). Changing the first ~100 words is a data edit.
   - Stories/dialogues are JSON files listed in `assets/content/manifest.json`.
     Adding one = authoring a file + a manifest line. No code changes.
   - ADR-005's pre-tokenized JSON schema is retained; the Dart mirror is
     deleted. Runtime loads through the asset bundle.

2. **Sequencing is a replaceable pure-Dart engine.**
   - `ContentSelector.select(LearnerState, List<CandidateContent>)` is the
     only door to "what's next". V2 is deterministic: prerequisites →
     exposure-based i+1 readiness (≤ 6 unseen words AND ≥ 60 % seen
     vocabulary) → forward preparation (units pre-teaching upcoming story
     vocabulary win) → reread rotation.
   - Readiness uses *encountered* vocabulary (exposure aggregates), not
     mastery — so selection works during the pure-exposure phase before any
     review evidence exists.
   - Input order of candidates is irrelevant: the corpus may arrive
     unordered.

3. **Beginner units carry no prerequisite chains.** Eligibility is selector
   policy, not dataset structure. (Stories may still declare prerequisites —
   they express *content* relationships, e.g. "read the micro-stories
   first".)

4. **Content metadata gained:** `ContentType` (beginnerUnit, sentence,
   microStory, story, dialogue, article), `ContentStatus` (available,
   draft, retired — repository filters), `tags`, and optional
   `animationAsset` alongside visual/audio. Media stay optional per item.

5. **Authoring is tooling, not hand-tokenization.** `tool/author_story.dart`
   converts raw Chinese text into lexicon-constrained, pre-tokenized JSON
   (longest-match against the target lexicon plus a small incidental-word
   whitelist). This guarantees D-06 (declared vocabulary ⊆ lexicon) by
   construction. The runtime tokenizer (dart_jieba) remains the single
   service for free text (E-07).

## Consequences

- `AssetContentRepository.fromData` builds the running corpus from lexicon
  JSON + manifest payloads; `AssetContentRepository(db, initialItems)` stays
  for tests.
- Learner progress keys on stable content ids: unit ids keep the
  `unit-NNN-词` convention; the original four story ids are unchanged.
- The UI never references content ids; an architecture test enforces this.
- Growth path: 24 stories today → 100+ by editing data only.
- Costs: widget tests must override the repository (no asset bundle in
  test harness); the simulated-level hook needs the loaded corpus
  (empty-then-reseed on arrival).

## Invariants checked

E-06 (one experience), E-08 (optional media), E-10 (rereading), E-13
(content regression-tested as code), D-05/D-06/D-07 (validator), C-01
(target-led lexicon, now enforced at authoring time), A-03 (no curriculum
in reader — mechanically scanned).
