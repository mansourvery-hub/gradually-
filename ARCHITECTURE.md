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
│   └── ids.dart              typed ids (VocabId, ContentId, SentenceId…)
├── learner/                  Learner Model (E-04)
│   ├── learner_state.dart    known Hanzi + known vocabulary + aggregates
│   ├── known.dart            the one "known" rule (LEARNING_ENGINE §2)
│   └── exposure.dart         bounded per-word aggregates (upsert, not log)
├── content/                  content schema + curated JSON corpus (D-05)
├── tokenizer/               Tokenizer interface + dart_jieba impl (D-02)
├── acquisition/              encounter → candidate → promotion (E-05)
├── selector/                 ContentSelector → ONE experience (E-06)
├── review/                   cards + fsrs adapter (D-04); ≠ learner state (E-03)
├── reader/                   reader & beginner-experience UI (widgets only)
├── data/                     drift DB + repository implementations (D-01)
│   └── repositories/         interfaces live in domain packages; impls here
└── app/                      Riverpod providers (D-03): composition only
```

Rules:

- Domain packages (`core`, `learner`, `content`, `tokenizer`, `acquisition`,
  `selector`, `review`) **never import Flutter widgets or Riverpod**. They are
  pure Dart and runnable/testable without a database or UI.
- `app/` contains provider wiring only — no learning logic.
- `reader/` widgets consume providers; they contain no curriculum
  conditionals, scores, or scheduling logic.
- Repository interfaces are declared in the domain package that owns the
  data; `data/` implements them. Domain code depends on the interface only,
  so the persistence technology is swappable (D-01 constraint).

## 3. Data flow (one direction, no cycles)

```text
widgets → app/ (providers) → domain services → repositories (interfaces)
                                                        ↑
                                                   data/ (drift)
```

Content corpus (JSON, pre-tokenized at authoring time) is loaded read-only
via a `ContentRepository`. The selector consumes corpus + learner state and
returns one experience. The review subsystem owns cards/scheduling and emits
mastery evidence to the learner model. Neither selector nor review writes
into the other (E-02, E-08 of DECISIONS).

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
- Deterministic: content is pre-tokenized at authoring time; runtime
  tokenization is only for free text (lookup, later import).
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
| Selector golden fixtures | known-good progressions; near-zero vocab → beginner material; recurring new words beat rare ones; completed content stays eligible (E-13) |
| Tokenization consistency | same text → same tokens across all consumers (E-07) |
| Content-data regression | curriculum changes can't silently make stories inappropriate; content is code-equivalent |
| Review tests | card lifecycle, promotion boundary, mastery evidence emitted — never writing learner knowledge directly (E-03) |
| Privacy tests | no behavioral fields anywhere in schema or domain types (§6) |

Domain packages are pure Dart → fast `dart test`-style suites without
Flutter bindings. Widget tests only for reader interaction.

## 8. What this architecture explicitly does not have (yet)

No server, no accounts, no importer, no dictionary depth beyond curated
local data, no settings screens. Each is additive later without breaking
boundaries (ROADMAP.md "Later").
