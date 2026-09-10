# MVP

**Answers:** what are we building *right now*? Scope only — product intent
lives in `PRODUCT.md`; structure in `ARCHITECTURE.md`.

## MVP goal

> A learner can open the app and be continuously guided through progressively
> more appropriate Chinese without managing the curriculum themselves.

## Core user journey

```text
Open → one selected experience → absorb → tap → next …
→ stories unlock → pure-exposure phase completes
→ recognition/SRS review begins (subordinate to reading)
```

## Included capabilities

1. Flutter shell (iOS, Android, Web) with instant startup
2. Local persistence (drift/SQLite; bounded aggregates, no event log)
3. Target-led beginner exposure units (45-word bootstrap lexicon:
   visual + audio path + Hanzi; no pinyin display)
4. Curated corpus: 3 micro stories + 1 children story mock (recycled
   lexicon only), pre-tokenized with exact offsets
5. Pure-exposure gate with per-word pacing and unlock ramp (≥500 total
   exposures, ≥4 per word, ≥10-word cohort, first session capped)
6. Acquisition pipeline: encounter → candidate → promotion (never
   unknown == card)
7. FSRS review behind a 3-grade adapter (remembered / partial / forgotten)
8. Content selector V1 → exactly ONE next experience; rereading rotation;
   prerequisite-aware
9. Reading-position persistence: resume exactly; reread counts as
   progression
10. Minimal reader: full-screen visuals, tap-anywhere advance, space/enter
    semantic activation, text selection with Chinese copy toolbar
11. Contextual monolingual lookup (mock dictionary, full lexicon coverage,
    absent-tap fail-safe)
12. Simulated level hook `--dart-define=LEVEL=0..100` (dev/testing only)
13. Curriculum validator + content/selector/tokenizer golden regression

## Excluded capabilities (deferred — see product tree)

```text
PRODUCT                          MVP
├── beginner→native progression  ├─ beginner→micro/children stories
├── leveled dictionary           ├─ mock dictionary (full lexicon)
├── EPUB/TXT import              ✗
├── podcast/listening modality   ✗
├── grammar/lexical notes        ✗
├── opt-in sync                  ✗ (E-14, post-MVP)
├── accounts                     ✗
└── settings UI                  ✗ (no user-facing settings)
```

## Acceptance criteria

- Fresh learner enters pure exposure; below the gate no recall exists;
  taps can't bypass exposure presentations.
- The selector always outputs one item; near-zero learner gets unit 1.
- Every target word receives 4–6 encounters; ~500–600 total before review.
- A story read halfway resumes at the same section after restart.
- Rereading increments completion in place; learner state never resets.
- All 110 tests pass; `dart analyze` clean; validator exits 0.
- No English/translation string reachable in the learner experience
  (enforced by tests, including material chrome).

## Known limitations

- Beginner audio assets not yet generated (controller no-ops per E-08).
- Concept art is programmatic placeholder SVGs; AI-generated art deferred.
- Dictionary definitions are mock-scale (simple, recycled vocabulary).
- Children-story corpus is a single mock entity.

## Deferred features (rough order)

Contextual grammar notes · idiom/proper-noun handling · leveled monolingual
dictionary · EPUB/TXT import · podcast listening · opt-in explicit-data sync
(E-14) · additional learner-model evidence (rereading counts, long-term
exposure).
