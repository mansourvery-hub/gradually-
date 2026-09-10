# Learning Engine

Learner model · acquisition · review (SRS) · content selection — and the
boundaries between them. Read with `AGENTS.md`. Requirements unless marked
[PROPOSED] / [OPEN].

## 1. Two questions, one shared state

```text
                 Learner State
                    /      \
                   ↓        ↓
       Content Selector    Review System
         "What's next?"    "What's due?"
                   ↓        ↓
                Content    Cards
```

Separate subsystems. Shared input. Never merged, never importing each other.

## 2. Learner Model

**V1 is a first-order vocabulary/reading approximation**, not a linguistic-
state estimator.

```text
known Hanzi
+ known vocabulary (inferred from explicit learning / review outcomes)
+ pedagogically relevant exposure data
→ approximate reading ability
```

Rules:

- **SRS state ≠ learner state.** Review owns cards and scheduling. The learner
  model receives mastery evidence (e.g. review/recognition outcomes) and
  maintains learner-level knowledge. No intervals, ease, or memory-state
  fields in the learner model.
- **No rigid level as the core representation.** Any coarse stage is derived
  from learner state + content characteristics when needed; it is not the
  model.
- **Allowed inputs:** recognition outcomes, review outcomes, content
  encounters, completion, rereading, other explicit pedagogical records.
- **Forbidden inputs:** hesitation, reading speed, cursor/scroll, eye
  movement, engagement/usage patterns, psychological profiling.
- **Future evidence (permit, do not build now):** repeated reading of finished
  stories, repeated vocabulary exposure, long-term exposure history, grammar
  knowledge from explicitly modeled content.

Definitions (single, shared):

- **Vocabulary item** — stable id · surface form · internal pinyin+tone.
  Optional special-item flag reserved for later idiom/proper-noun handling.
- **Hanzi knowledge** — tracked alongside vocabulary. [PROPOSED] V1 derives
  known Hanzi from known vocabulary plus beginner recognition outcomes.
- **Known** — a learner-model state computed in one place from mastery
  evidence. [PROPOSED] V1: a small function over review/recognition outcomes;
  keep the rule in the learner model only. Never surfaced as colors or counts.
- **Exposure data** — bounded per-word aggregates (encounter count, distinct
  content items, first/last seen), updated **in place**; never an append-only
  event log. Rereading a story increments counters; it does not add rows.
  Sentence context is captured where it is used: on the SRS card at promotion
  time, and derived from content + completion history for future dictionary
  examples. Records *what was encountered*, not behavior.

## 3. Acquisition Pipeline

Distinct states:

```text
unknown encounter
  → acquisition candidate
  → useful / recurring / appropriate?   no → ignore (keep exposure)
  → promoted to SRS
  → established knowledge (learner model)
```

- Never `unknown == flashcard`. A word may be encountered many times and never
  become a card (names, rare words, incidental vocabulary).
- Candidate records are separate from cards and separate from learner state.
- Promotion criteria (thresholds may evolve): recurrence, usefulness,
  appropriateness to current learner state, importance to the curriculum,
  sufficient exposure. Content metadata may mark curriculum-critical
  vocabulary to inform this.
- [PROPOSED] V1 promotion: a single, named, unit-tested rule combining
  recurrence count across content with a curriculum-importance flag. Keep it
  in `acquisition/`, replaceable.

## 4. Review System (SRS)

Subordinate to immersion. The app "simply knows" what is due.

**Beginner phase** — recognition-heavy, deliberately different from later SRS:
picture → choose Hanzi · audio → choose Hanzi · visual recognition · tone
discrimination. Outcomes support at least three grades: **remembered /
partially remembered / forgotten** (meaning, Hanzi, sound, and tone can
dissociate early).

**Later phase** — conventional sentence-based Anki-style cards:

```text
Front: full Chinese sentence · target word emphasized · available context/media
Back:  target word · Chinese definition when appropriate · available audio/context
```

Card data preserves the strongest available context: source sentence, target
emphasis, story visual and native word audio *when available*, provenance.
Media fields are optional.

Scheduler:

- Mature scheduler, not an invention. Algorithm: **[OPEN]** `DECISIONS.md`
  D-04. Card data is separated from scheduler implementation so the algorithm
  can change without touching cards.
- Never expose intervals, ease, deck limits, settings, or statistics.
- Emits mastery evidence to the learner model; does not write learner
  knowledge directly.

## 5. Content Selector

The heart of the product. Answers *"given everything the learner knows, which
piece of Chinese should come next?"*

Boundary:

```text
LearnerState + CandidateContent[] → ContentSelector → ONE selected experience
```

- Replaceable module. No scoring in widgets, repositories, or reader.
- Runnable on synthetic inputs without a database.
- Output is one experience. The learner never sees a ranked list, score, or
  rationale.

Inputs (minimum): learner known vocabulary/Hanzi; content lexical data;
content difficulty metadata; progression constraints / prerequisites;
curriculum ordering; completion history.

**i+1 is not "percent unknown".** The engine is designed to weigh, over time:
known vs new vocabulary amounts · recurrence of new words · usefulness ·
rare/incidental words · curriculum order · prerequisites · sentence and
grammatical complexity · concentration vs scatter of new words. Objective:
*high learning value at an appropriate difficulty cost.* The formula may
evolve; V1 must be simple and replaceable — not a research project.

[PROPOSED] conceptual split (adopt only if it helps in MVP):

```text
LearnerState → Candidate Generation → CandidateContent[] → Ranking → ONE experience
```

[PROPOSED] V1:
1. Filter: prerequisites met, curriculum position reachable, content type
   appropriate to learner state (beginner material before stories).
2. Compute from shared tokens + learner state: known coverage, distinct new
   items, per-item recurrence within the candidate, concentration.
3. Score with one named, unit-tested function favoring a modest number of
   highly recurring new items and honoring curriculum order.
4. Return the top candidate; tie-break by curriculum order.

Required behaviors:
- Near-zero-vocabulary learner receives beginner material, not stories.
- Freshly acquired vocabulary clusters are exploited by subsequent content.
- Few recurring new words beat many rare irrelevant ones.
- Completed content remains eligible (rereading is progression, not failure).
- Imported content (later) is offered only when learner state supports it.

Protect with golden progression fixtures (`ARCHITECTURE.md` §7).
