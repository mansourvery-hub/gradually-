# MVP

**Answers:** what are we building *right now*? Scope only — product intent
lives in `PRODUCT.md`; structure in `ARCHITECTURE.md`.

## MVP goal

> A learner can open the app and be continuously guided through progressively
> more appropriate Chinese without managing the curriculum themselves.

## Current MVP reality (updated 2026-09-13)

The **content architecture milestone** is complete:

- Beginner exposure units are **generated from lexicon data**
  (`assets/content/curriculum/bootstrap_target_lexicon.json`, 45 words) —
  not compiled into code.
- The story corpus lives in **data files** loaded via
  `assets/content/manifest.json`: **24 story/dialogue items**
  (14 micro-stories + 3 legacy stories + 1 children's story + 6 dialogues).
- Sequencing runs through the **V2ContentSelector** (deterministic,
  exposure-driven, forward-preparing) — the UI never knows the curriculum.
- Media (audio/visuals) remain optional per item; the 16 new stories carry
  no media and work fully (E-08 by construction).

Earlier drafts mentioned "45 units" as hand-authored content — that is no
longer accurate: the 45 *word units* are the generated target-led bootstrap;
story count is 24 (not 4, not a fixed ceiling — the corpus grows via data).

## Core user journey

```text
Open → one selected experience → absorb → tap → next …
→ stories unlock → pure-exposure phase completes
→ recognition/SRS review begins (subordinate to reading)
```

## Included capabilities

1. Flutter shell (iOS, Android, Web) with instant startup
2. Local persistence (drift/SQLite; bounded aggregates, no event log)
3. Target-led beginner exposure units **generated from lexicon data**
   (45-word bootstrap lexicon: visual + audio path + Hanzi; no pinyin
   display)
4. Replaceable story corpus in data files: micro-stories, dialogues,
   children's story — lexicon-closed, pre-tokenized with exact offsets
   (validated like code)
5. Pure-exposure gate with per-word pacing and unlock ramp (≥500 total
   exposures, ≥4 per word, ≥10-word cohort, first session capped)
6. Acquisition pipeline: encounter → candidate → promotion (never
   unknown == card)
7. FSRS review behind a 3-grade adapter (remembered / partial / forgotten)
8. **V2 Content Selector** → exactly ONE next experience; prerequisite-aware;
   exposure-based i+1 readiness; forward preparation toward upcoming
   stories; rereading rotation
9. Reading-position persistence: resume exactly; reread counts as
   progression
10. Minimal reader: full-screen visuals, tap-anywhere advance, space/enter
    semantic activation, text selection with Chinese copy toolbar
11. Contextual monolingual lookup (mock dictionary, full lexicon coverage,
    absent-tap fail-safe)
12. Simulated level hook `--dart-define=LEVEL=0..100` (dev/testing only)
13. Curriculum validator + content/selector/tokenizer golden regression
14. **Content authoring tool** (`tool/author_story.dart`): raw Chinese
    text → lexicon-constrained pre-tokenized corpus JSON

## Excluded capabilities (deferred — see roadmap)

```text
PRODUCT                          CURRENT
├── beginner→native progression  ├─ beginner→micro/dialogue/children stories
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
- A story becomes selectable only when its vocabulary is substantially
  encountered (i+1), and story exposure starts early (step ~7 in the
  current corpus) rather than after all units.
- A story read halfway resumes at the same section after restart.
- Rereading increments completion in place; learner state never resets.
- All tests pass; `dart analyze` clean; validator exits 0; `./verify` green.
- **Adding stories to the corpus requires NO code changes** (data file +
  manifest line only — guarded by tests).
- No English/translation string reachable in the learner experience
  (enforced by tests, including material chrome).

## Known limitations

- Beginner audio assets not yet generated (controller no-ops per E-08).
- Concept art is programmatic placeholder SVGs for the original 45 words
  and 17 scenes; the 16 newer stories have no illustrations yet (valid:
  media are optional data).
- Dictionary definitions are mock-scale (simple, recycled vocabulary).
- Learner-model evidence is first-order (exposure-based); richer
  long-term signals are deferred.

## Deferred features (rough order)

Learner-aware selection refinements (selector V3) · contextual grammar
notes · idiom/proper-noun handling · leveled monolingual dictionary ·
corpus expansion past 24 stories · EPUB/TXT import · podcast listening ·
opt-in explicit-data sync (E-14) · additional learner-model evidence
(rereading counts, long-term exposure).
