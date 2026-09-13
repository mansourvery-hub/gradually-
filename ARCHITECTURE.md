# Architecture

Subsystem boundaries, code layout, persistence, tokenizer, and tests. Read
with `AGENTS.md`. Requirements unless marked [PROPOSED].

## 1. Component map

```text
                 Learner State (learner/)
                    /      \
                   ↓        ↓
       Content Selector    Review System
         (selector/)        (review/)
         "What's next?"    "What's due?"
                   ↓        ↓
                Content    Cards
              (content/)  (review/)
```

Shared infrastructure: `tokenizer/` (one service, E-07) · `acquisition/`
(candidate → promotion) · `dictionary/` (later) · `data/` (drift
implementations behind repository interfaces) · `app/` (Riverpod wiring —
the only layer widgets touch).

## 2. Package layout

```text
lib/
├── main.dart                 app entry
├── core/                     shared value objects & types
│   ├── vocab.dart            VocabularyItem (stable id · surface · pinyin+tone)
│   ├── hanzi.dart            Hanzi representation
│   ├── token.dart            shared token type (E-07)
│   ├── content_type.dart     ContentType + ContentStatus (content as data)
│   ├── simulated_level.dart  LEVEL=0..100 dev hook (corpus-independent)
│   └── ids.dart              typed ids (VocabId, ContentId, SentenceId…)
├── learner/                  Learner Model (E-04)
│   ├── learner_state.dart    known Hanzi + known vocabulary + aggregates
│   ├── known.dart            the one "known" rule (LEARNING_ENGINE §2)
│   └── exposure_gate.dart    bounded per-word aggregates + SRS unlock gate
├── content/                  content schema + corpus DATA loading (D-05, ADR-007)
│   ├── content.dart         ContentItem/Metadata/Section/Sentence schema
│   ├── corpus.dart          lexicon → generated beginner units; ids
│   ├── content_repository.dart  repository interface (by-ID lookup)
│   └── media_capabilities.dart  optional-media capability builder
├── tokenizer/               Tokenizer interface + dart_jieba impl (D-02)
├── acquisition/              encounter → candidate → promotion (E-05)
├── selector/                 ContentSelector V1/V2 → ONE experience (E-06)
├── review/                   cards + fsrs adapter (D-04); ≠ learner state (E-03)
├── reader/                   reader & beginner-experience UI (widgets only)
├── data/                     drift DB + repository implementations (D-01)
│   └── repositories/         interfaces live in domain packages; impls here
└── app/                      Riverpod providers (D-03): composition only

assets/content/               THE CORPUS (data, not code)
├── curriculum/bootstrap_target_lexicon.json   45-word lexicon (+ asset refs)
├── manifest.json              story/dialogue item list (loaded at runtime)
├── micro-*.json               micro-stories (pre-tokenized)
├── story-*.json               longer stories (pre-tokenized)
└── dialogue-*.json            dialogues (pre-tokenized)
```

Rules:

- **CONTENT IS DATA. SEQUENCING IS LOGIC. PRESENTATION IS UI.** The corpus
  lives in `assets/content/` and is loaded by the repository; the sequence
  is computed by `selector/`; the reader renders whatever it is given.
  The reader and app layers contain no content ids, story lists, or order
  assumptions (mechanically enforced by
  `test/content_architecture_test.dart`).
- Domain packages (`core`, `learner`, `content`, `tokenizer`, `acquisition`,
  `selector`, `review`) **never import Flutter widgets or Riverpod**. They are
  pure Dart and runnable/testable without a database or UI.
- `app/` contains provider wiring only — no learning logic.
- `reader/` widgets consume providers; they contain no curriculum
  conditionals, scores, or scheduling logic.
- Repository interfaces are declared in the domain package that owns the
  data; `data/` implements them. Domain code depends on the interface only,
  so the persistence technology is swappable (D-01 constraint).
- Beginner units are generated from lexicon data (no prerequisite chains —
  eligibility is selector policy); stories may declare prerequisites as
  content relationships. Adding content = editing data + manifest, never
  code (ADR-007).

## 3. Data flow (one direction, no cycles)

```text
widgets → app/ (providers) → domain services → repositories (interfaces)
                                                        ↑
                                                    data/ (drift)
```

The corpus (lexicon JSON + manifest-listed pre-tokenized story files) is
loaded read-only via `AssetContentRepository.fromData` (ADR-007). The
selector consumes candidates + learner state and returns ONE experience;
readiness is exposure-driven (works during pure exposure, before any
review evidence). The review subsystem owns cards/scheduling and emits
mastery evidence to the learner model. Neither selector nor review writes
into the other (E-02, E-08 of DECISIONS).

```text
CONTENT CORPUS (data) → CONTENT REPOSITORY → SEQUENCING ENGINE →
LEARNER STATE → NEXT EXPOSURE → UI
```

Adding a story: author JSON (`tool/author_story.dart`) → manifest line →
`./verify`. No story-screen, navigation, or sequencing changes.

## 4. Persistence

- Technology: drift (SQLite) — D-01. Single-file database, versioned
  migrations that preserve learner data (DEVELOPMENT.md §10).
- Tables follow the **bounded aggregate model**: one row per word ever
  encountered (counters upserted in place), one row per content item for
  reading position and completion/reread counts. No append-only event logs.
- Web: sqlite3 WASM (drift's supported web backend). Local browser storage
  is best-effort; portability is an explicit non-goal of web storage alone
  (see E-14).
- Opt-in sync (post-MVP, E-14) syncs these bounded tables only. It never
  carries behavioral data (none exists, AGENTS.md §6).

## 5. Tokenizer

- One interface, one implementation today (`dart_jieba`, D-02), one shared
  token type consumed by reader, dictionary, SRS, selector, and the future
  importer (E-07).
- Deterministic: content is pre-tokenized at authoring time; the authoring
  tool applies **lexicon-constrained segmentation** (longest-match against
  the target lexicon + a small incidental whitelist) so authored tokens map
  to lexicon words by construction (D-06 guaranteed at authoring time).
  Runtime tokenization is only for free text (lookup, later import).
- Golden tokenization tests pin segmentation behavior so swapping the
  implementation cannot silently change vocabulary keys.

## 6. Error containment

Persistence failures or a missing asset must never strand the learner in a
broken UI. Reader states cover loading/failure without exposing internal
details (§3.11). No crash screens triggered by algorithm paths.

## 7. Test categories (blueprint §26)

| Category | What it protects |
|---|---|
| Learner-state tests | exposure → aggregate update → known-rule consistency |
| Selector golden fixtures | known-good progressions; near-zero vocab → beginner material; forward preparation beats plain order; input order never matters; completed content stays eligible (E-13); readiness is exposure-driven |
| Tokenization consistency | same text → same tokens across all consumers (E-07) |
| Content-data regression | curriculum changes can't silently make stories inappropriate; manifest parity + schema/offset/D-06 validation (`tool/validate_curriculum.dart`); content is code-equivalent |
| Architecture boundary | reader/ contains no content ids or corpus imports; adding stories via data changes the repository with zero code edits (`test/content_architecture_test.dart`) |
| End-to-end flow | content → selector → learner update → next exposure walks the entire corpus without UI help (`test/end_to_end_flow_test.dart`) |
| Review tests | card lifecycle, promotion boundary, mastery evidence emitted — never writing learner knowledge directly (E-03) |
| Privacy tests | no behavioral fields anywhere in schema or domain types (§6) |

Domain packages are pure Dart → fast `dart test`-style suites without
Flutter bindings. Widget tests only for reader interaction.

## 8. What this architecture explicitly does not have (yet)

No server, no accounts, no importer, no dictionary depth beyond curated
local data, no settings screens. Each is additive later without breaking
boundaries (ROADMAP.md "Later").
