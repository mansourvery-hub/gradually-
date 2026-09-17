# Implementation Plan — JianRu V3

This plan tracks the 16 contracts of the V3 Automated Mother-Story Pipeline.
A contract is **READY** when all its dependencies are complete. Work sequentially.
**Never proceed to the next contract until the current contract's verification gate passes.**

## V3 Pipeline Contracts Status

```text
[COMPLETE] Contract 1: Repository + Architecture Reset
[COMPLETE] Contract 2: Source Ingestion
[COMPLETE] Contract 3: Canonical Story Extraction
[COMPLETE] Contract 4: Linguistic Knowledge Extraction
[COMPLETE] Contract 5: Learner State + Narrative State
[READY]    Contract 6: Narrative Planner
[BLOCKED]  Contract 7: Controlled Generation
[BLOCKED]  Contract 7: Controlled Generation
[BLOCKED]  Contract 8: Independent Validation Stack
[BLOCKED]  Contract 9: End-to-End Red Chamber Fixture
[BLOCKED]  Contract 10: Progressive Ladder Generation
[BLOCKED]  Contract 11: Portfolio / Caching Model
[BLOCKED]  Contract 12: Runtime Application
[BLOCKED]  Contract 13: Failure Handling
[BLOCKED]  Contract 14: Automated Quality Dashboard / Report
[BLOCKED]  Contract 15: Full Pipeline Regression Suite
[BLOCKED]  Contract 16: Final Product Gate
```

## Contract Dependency Flow

```text
Contract 1 (Reset)
    │
    ▼
Contract 2 (Source Ingestion)
    │
    ├─────────────────────────────┐
    ▼                             ▼
Contract 3 (Canonical Extraction) Contract 4 (Linguistic Extraction)
    │                             │
    └──────────────┬──────────────┘
                   ▼
Contract 5 (Learner State + Narrative State)
                   │
                   ▼
Contract 6 (Narrative Planner)
                   │
                   ▼
Contract 7 (Controlled Generation) ◄───┐
                   │                   │ (Fail-closed retry)
                   ▼                   │
Contract 8 (Validation Stack) ─────────┘
                   │
                   ▼
Contract 9 (End-to-End Fixture: 红楼梦.txt)
                   │
                   ▼
Contract 10 (Progressive Ladder Generation)
                   │
                   ▼
Contract 11 (Portfolio / Caching Model)
                   │
                   ▼
Contract 12 (Runtime Application)
                   │
                   ▼
Contract 13 (Failure Handling)
                   │
                   ▼
Contract 14 (Automated Quality Dashboard)
                   │
                   ▼
Contract 15 (Full Pipeline Regression Suite)
                   │
                   ▼
Contract 16 (Final Product Gate)
```

## Completed milestone: content architecture (2026-09-13)

```text
[COMPLETE] T-ARCH-1 repository/content audit (findings in ADR-007 context)
[COMPLETE] T-ARCH-2 canonical content model
           ContentType {beginnerUnit, sentence, microStory, story, dialogue,
           article}; ContentStatus {available, draft, retired}; tags;
           difficulty; optional visual/audio/animation per section
[COMPLETE] T-ARCH-3 content repository as data
           units generated from lexicon JSON (45 words, asset refs in
           data); stories via assets/content/manifest.json; by-ID lookup;
           availability filtering; firstItemId fallback
[COMPLETE] T-ARCH-4 hardcoded sequencing removed
           bootstrap_corpus.dart + exposure_generator.dart deleted;
           UI/simulated-level no longer reference a compiled corpus;
           reader/ carries no content ids (architecture test enforced)
[COMPLETE] T-ARCH-5 sequencing interface preserved + V2 engine
           ContentSelector.select(); deterministic; exposure-based i+1
           readiness (≤6 unseen AND ≥60% seen); forward preparation;
           reread rotation; input-order independent
[COMPLETE] T-ARCH-6 dynamic first curriculum
           45 units + 24 stories (14 micro, 3 legacy, 1 children, 6
           dialogues) — all data; walk starts unit-001-水, first story at
           ~step 7 (exposure-driven, not hardcoded)
[COMPLETE] T-ARCH-7 target-content-driven vocabulary metadata
           story vocabulary declared in data; forward preparation reads
           it; authoring tool enforces lexicon closure at authoring time
[COMPLETE] T-ARCH-8 tests (156 total: +38 architecture/selector/e2e)
           add-stories-without-code-changes; input-order determinism;
           learner-state changes selection; stable ids; draft/retired
           filtered; media-optional rendering; full-corpus end-to-end walk
[COMPLETE] T-ARCH-9 documentation (MVP, ROADMAP, ARCHITECTURE, QUALITY,
           TEST_STRATEGY, ADR-007)
```

## Task definitions (active)

### T12 — Target lexicon growth `[READY]`

- Backward-derive an expanded lexicon (toward 100–150 words) from the next
  batch of target stories (CHOICES §2 method). Data edit +
  `tool/author_story.dart` for stories using the new words; dictionary
  entries must keep full coverage.
- Editorial gate: story selection is a human decision (AGENTS.md §3).
- Verification: validator + dictionary-coverage test + walk smoke.

### T13 — Corpus expansion toward 100+ items `[BLOCKED: T12]`

- Author stories/dialogues through the data pipeline; ~20 per editorial
  batch. No code changes anywhere (that's the architecture contract).
- Verification: add-20-stories test pattern; `./verify`.

### T14 — Sequencing V3 (learner-aware refinements) `[BLOCKED: corpus scale]`

- Enrich scoring with long-term familiarity, reread evidence (needs T4/T5
  evidence), Hanzi-coverage signals. Replaceable engine; golden fixtures
  pin regressions.

### T1 — Bootstrap word audio assets `[BLOCKED: DECISION]`

- Generate/approve native audio for the bootstrap words + story
  narration; publish `assets/audio/audio_manifest.json`. Controller/
  wiring already complete and no-ops safely (E-08) — data-only change.
- Depends on: audio sourcing decision (CHOICES §3A).

### T2 — Audio playback cadence `[BLOCKED: T1]`

- Content-scoped autoplay/replay metadata at experience boundaries;
  reader already consumes capabilities gracefully.

### T3 — AI-generated art swap `[BLOCKED: DECISION]`

- Replace placeholder SVGs at lexicon/manifest-referenced paths. Zero
  code changes by design (swap contract, C-05).

### T4 — Reread evidence in learner model `[DEFERRED]`
### T5 — Long-term exposure evidence `[DEFERRED: T4]`
### T6 — Curated dictionary schema (real data) `[DEFERRED]`
### T7 — Leveled lookup depth `[DEFERRED: T6]`
### T8 — Import pipeline (EPUB/TXT) `[DEFERRED]`
### T9 — Imported-content selection gating `[DEFERRED: T8]`

## Historical: MVP foundation (complete, for orientation)

```text
core types → tokenizer → learner model → exposure gate
→ acquisition → promotion → FSRS review → selector V1 (+goldens)
→ drift schema/repositories (bounded aggregates, privacy-scanned)
→ web WASM persistence → reader (tap/activation/full-screen/select)
→ 45 generated units + 24 story/dialogue items (validator-enforced)
→ placeholder visuals (45 concepts + 17 scenes, flutter_svg smoke)
→ exposure gate pacing + first-session ramp
→ reading-position persistence + rereading rotation
→ contextual monolingual lookup + full-coverage mock dictionary
→ simulated LEVEL hook (0..100 deterministic, corpus-independent)
→ CI (analyze + test) on all pushes
```

## Verification checklist (gate to release)

```text
[COMPLETE] Fresh learner walks exposure → stories → gate unlock (walk test)
[COMPLETE] Selection emerges from data; adding stories needs no code (tested)
[ ] Manual app run: LEVEL=0 tap-through sanity (per release)
[ ] Resume: kill app mid-story → reopen → same section (manual)
[ ] Lookup: tap curated + absent words in stories (manual)
[COMPLETE] T10 release audit + T11 platform validation; ./verify green
```
