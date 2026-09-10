# Implementation Plan

Task definitions, dependency graph, and execution status for the current
scope (`MVP.md`). A task is **READY** when all its dependencies are
complete. Work top-to-bottom by readiness; never start a task whose
dependencies are incomplete.

Historical note: the detailed 280-node machine graph lives in
`docs/reference/dev_graph.json` (generated during initial decomposition).
This file is the human/agent-readable plan of record.

## Status legend

```text
[COMPLETE]  shipped + guarded by tests
[READY]     dependencies complete; may be selected next
[BLOCKED]   waiting on dependencies or a decision
[DEFERRED]  out of current MVP scope (see MVP.md)
[DECISION]  requires human input (art direction, audio sourcing)
```

## Dependency graph (remaining work)

```text
[DECISION] audio sourcing (neural TTS vs native recordings)
      │
      ↓
T1 AUDIO_ASSETS ──→ T2 PLAYBACK_CADENCE ──→ [COMPLETE] (UI wiring done)
      │
      ↓
[DECISION] Chinese art style (concept art + story illustrations)
      │
      ↓
T3 ART_SWAP (replace placeholder SVGs at manifest paths)

T4 REREAD_EVIDENCE ──→ T5 LONG_TERM_EXPOSURE        (post-MVP evidence)
T6 DICTIONARY_SCHEMA ──→ T7 LEVELED_LOOKUP_DEPTH    (post-MVP dictionary)
T8 IMPORT_PIPELINE ──→ T9 IMPORT_SELECTION          (post-MVP importing)

T10 RELEASE_AUDIT ──→ T11 PLATFORM_VALIDATION ──→ MVP VALIDATION
```

## Task definitions

### T1 — Bootstrap word audio assets `[BLOCKED: DECISION]`

- Generate/approve native audio for all 45 bootstrap words + story
  narration; compress to OGG/MP3; publish `assets/audio/audio_manifest.json`
  (schema already fixed: `assets/audio/words/{id}.mp3` referenced by units).
- Depends on: **audio sourcing decision** (see `docs/domain/CONTENT.md` §audio
  pipeline; CHOICES §3A). Controller/wiring already complete and no-ops
  safely (E-08), so this task changes data only.
- Verification: audio manifest test (files decode, refs resolve), manual
  playback check.

### T2 — Audio playback cadence `[BLOCKED: T1]`

- Content-scoped autoplay/replay metadata at experience boundaries
  (`assets/content/audio_playback.json`). Reader wiring already consumes
  capabilities gracefully; this adds the data + cadence contract test.

### T3 — AI-generated art swap `[BLOCKED: DECISION]`

- Replace placeholder SVGs with AI-generated Chinese-style concept art and
  story illustrations at the manifest paths (`CHOICES §3B swap contract`,
  C-05). Zero code changes by design.

### T4 — Reread evidence in learner model `[READY]`

- Rereads already record exposure/completion; fold rereading into
  learner-model evidence explicitly (post-MVP per E-14 ordering, but small
  and well-defined now).
- Files: `lib/learner/` aggregate extension + `test/` regression.
- Guard: D-02 (explicit events only).

### T5 — Long-term exposure evidence `[BLOCKED: T4]`

- Aggregate-derived familiarity signal feeding selector scoring V2.

### T6 — Curated dictionary schema (real data) `[READY]`

- Replace mock dictionary entries with curated monolingual definitions at
  the same path/schema (mock proves the pipeline; real data is editorial
  work). Schema is stable — data swap only.
- Guard: C-04 (structurally monolingual).

### T7 — Leveled lookup depth `[BLOCKED: T6]`

- Learner-aware definition depth (simpler Chinese for earlier stages).

### T8 — Import pipeline (EPUB/TXT) `[DEFERRED]`

- Per MVP exclusion; interface sketches in `docs/domain/CONTENT.md`.

### T9 — Imported-content selection gating `[DEFERRED: T8]`

### T10 — Release audit `[READY]`

- Automated anti-feature scan (no XP/streak/dashboard/catalog strings, no
  translation-first UI, no behavioral tracking) over `lib/`.
- Verification: `test/release/product_invariants_test.dart`.

### T11 — Platform validation `[READY after T10]`

- `flutter analyze` + full tests + representative iOS/Android/Web builds
  with offline asset/persistence checks. CI (`.github/workflows/ci.yaml`)
  runs analyze+test on every push already.

## Completed foundation (for orientation)

```text
core types → tokenizer → learner model → exposure gate
→ acquisition → promotion → FSRS review → selector V1 (+goldens)
→ drift schema/repositories (bounded aggregates, privacy-scanned)
→ web WASM persistence → reader (tap/activation/full-screen/select)
→ 45 units + 3 micro stories + children story mock (validator-enforced)
→ placeholder visuals (45 concepts + 17 scenes, flutter_svg smoke)
→ exposure gate pacing + first-session ramp
→ reading-position persistence + rereading rotation
→ contextual monolingual lookup + full-coverage mock dictionary
→ simulated LEVEL hook (0..100 deterministic)
→ CI (analyze + test) on all pushes
```

## MVP validation checklist (gate to release)

```text
[ ] Fresh learner walks exposure → stories → gate unlock (manual, LEVEL=0)
[ ] Resume: kill app mid-story → reopen → same section
[ ] Lookup: tap curated + absent words in stories → definitions / serene fallback
[ ] Selection: long-press text → 复制 toolbar → copy works
[ ] No English reachable anywhere in the learner UI
[ ] T10 + T11 pass; all tests green; ./verify green
```
