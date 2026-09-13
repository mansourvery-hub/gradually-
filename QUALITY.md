# Quality

**Answers:** what properties must remain true? Each rule is mechanically
enforced (see `TEST_STRATEGY.md` for the how). Violations block a task from
being declared complete.

## Product invariants (P-xx)

| # | Invariant |
|---|---|
| P-01 | Monolingual: no English translations, explanations, or bilingual UI in the learner experience — including selection chrome and dictionary data. |
| P-02 | The system chooses ONE next experience; no course/level/deck selection, ranked lists, or rationale. |
| P-03 | Zero unnecessary decisions: no config screens, dashboards, statistics. Legitimate controls: play/pause/replay/continue/back/contextual lookup. |
| P-04 | Immersion primary; SRS subordinate. Review never preempts reading flow by design. |
| P-05 | Scaffolding decays automatically; stage-driven, never a user setting. |
| P-06 | Completed content stays accessible; rereading uses current learner state; reading position resumes exactly. |
| P-07 | Internals stay internal: i+1 scores, difficulty, intervals, ease, word-status colors never surface. |
| P-08 | Media are optional per item; absence is valid and never strands the learner. |

## Architecture invariants (A-xx)

| # | Invariant |
|---|---|
| A-01 | Domain packages (`core`, `learner`, `content`, `tokenizer`, `acquisition`, `selector`, `review`, `dictionary`) never import Flutter widgets or Riverpod — pure Dart, testable without DB/UI. |
| A-02 | `app/` contains provider composition only — no learning logic. |
| A-03 | `reader/` widgets contain no curriculum conditionals, scores, or scheduling logic — and no content ids, story lists, or corpus imports. |
| A-04 | Selector and Review are separate subsystems sharing learner state only (E-02). |
| A-05 | SRS state ≠ learner state (E-03): no intervals/ease in the learner model. |
| A-06 | Repository interfaces live in the owning domain; `data/` implements them (swappable persistence). |
| A-07 | One tokenizer, one shared Token representation for all consumers (E-07). |
| A-08 | Learner state derives only from explicit learning events (E-09) — never behavior. |
| A-09 | CONTENT IS DATA: the corpus lives in data files (lexicon + manifest); adding/removing content never requires reader, navigation, or selector code changes. |
| A-10 | SEQUENCING IS LOGIC: the next experience is computed by the `ContentSelector` alone; selection is independent of candidate input order and of any UI state. |

## Data invariants (D-xx)

| # | Invariant |
|---|---|
| D-01 | Learner persistence is bounded aggregates (upsert-in-place); no append-only event log. |
| D-02 | Exposure/progress updates derive from explicit events only (encounter, completion, review outcome, reread). |
| D-03 | Schema columns must never contain behavioral fields (hesitation, speed, cursor, scroll, dwell, engagement, telemetry, analytics, profiling, session…). |
| D-04 | Migrations preserve learner data; no destructive shortcut. |
| D-05 | Content tokens: exact offsets, non-overlapping, surface == text slice (validator-enforced). |
| D-06 | Story vocabulary recycles the bootstrap lexicon (children-story test enforces purity). |
| D-07 | Declared media references must resolve to bundled files (validator-enforced). |

## Reliability requirements (R-xx)

| # | Requirement |
|---|---|
| R-01 | Missing optional media degrades silently to a serene fallback — never an error, never a stranded learner. |
| R-02 | Dictionary lookup for unknown words returns absent — never throws. |
| R-03 | Malformed/unloadable visual assets never crash the reader (flutter_svg render smoke covers all declared files). |
| R-04 | Database errors during completion never freeze the loop; providers invalidate and the selector advances. |
| R-05 | Asset names are ASCII-safe (web percent-encoding breaks non-ASCII filenames). |

## Content contracts (C-xx)

| # | Contract |
|---|---|
| C-01 | Target-led backward lexicon: beginner vocabulary derives from stories, never frequency lists; 45-word bootstrap set. |
| C-02 | ~4–6 encounters per word, ~500–600 total exposures before any recall. |
| C-03 | Exposure gate: total ≥500 AND ≥10 ready words; first session cohort capped at 5; no behavioral signal can unlock. |
| C-04 | Monolingual dictionary: no translation fields (structurally absent), no Latin text in definitions/examples. |
| C-05 | Concept art swap contract: `bootstrap_visuals.json` manifest is the stable interface; concept asset references live in the lexicon data. |
| C-06 | Stable content ids: beginner units use `unit-NNN-词`; ids never change when the corpus grows (learner progress keys on them). |
| C-07 | Story corpus files must be listed in `assets/content/manifest.json` (disk ↔ manifest parity, validator-enforced); story `curriculumOrder` > lexicon size. |
| C-08 | Declared story vocabulary ⊆ target lexicon (D-06); authored tokens are lexicon-constrained by the authoring tool. |
| C-09 | Draft/retired content stays in the dataset but is filtered from selection (availability is data, not deletion). |
