# Product — JianRu V3

**One sentence:** 渐入 (JianRu) is an automated system that takes a single Chinese literary TXT file (such as 《红楼梦》) and autonomously produces a progressive, level-appropriate, verified Chinese reading portfolio with zero manual Chinese authoring or QA.

**Authoritative for:** what the product is and must do. System architecture lives in `docs/v3-architecture.md` and `ARCHITECTURE.md`.

## V3 Core Mission

The system constructs a progressively accessible path into original Chinese literature. It does not simply summarize or simplify; it preserves underlying narrative identity while controlling:
- linguistic difficulty
- lexical introduction
- character/entity exposure
- narrative complexity
- contextual complexity

The system strictly decouples:
1. **What meaningful piece of the source should become visible next?** (Narrative Planner)
2. **How to express that piece at the learner's current linguistic level?** (Controlled Generator)

## Core Invariants

1. **TXT-Only Source:** The literary source TXT is the only required input. No hand-authored metadata, summaries, or entity graphs.
2. **Zero Manual Chinese Audit:** Operators have zero Chinese knowledge. All quality, linguistic correctness, grounding, and narrative progression are mechanically validated.
3. **End-to-End Provenance:** Every derived entity, event, and generated passage links back to source offsets and segment IDs.
4. **Independent Validation Stack:** Fail-closed, multi-layered verification (deterministic, linguistic, source grounding, narrative coherence, independent judge).
5. **Decoupled Learner State:** Separate Linguistic Learner State from Narrative Learner State.

## Core user journeys

```text
Open app
  → see exactly one piece of Chinese (no menus, no choice)
  → absorb it (visual + native audio + Hanzi; meaning from context)
  → tap anywhere
  → next piece, chosen by the system
  → …repeat until reading native Chinese independently…
  → app becomes unnecessary (success, not churn)
```

Review emerges from content encountered; it never preempts immersion.

## Functional requirements

1. The system selects the single next experience; the learner never sees a
   course catalog, ranked list, or rationale.
2. Beginner exposure units ground meaning monolingually (visual, audio,
   context) — no English anywhere in the learner experience.
3. Curated beginner stories recycle vocabulary with tight budgets; content
   is data-driven and regression-tested like code.
4. Completed content stays accessible; rereading is progression.
5. Recognition and SRS review unlock only after a pure-exposure phase;
   review is subordinate to reading.
6. Scaffolding (pinyin, narration, visuals) decays automatically as the
   learner grows; it is never a user setting.
7. Contextual monolingual lookup works where curated data exists.
8. The core loop (open, read, lookup, known-ness, review, selection) works
   fully offline and locally.

## UX requirements

- Zero decision points: no configuration screens, dashboards, statistics,
  settings for ordinary use, or lesson menus. Controls are limited to play,
  pause, replay, continue, back, and contextual lookup.
- Zen minimalism: calm paper-tone canvas, full-screen visuals, tap-anywhere
  cadence; space/enter activation for accessibility and hardware keyboards.
- Internals stay internal: i+1 scores, difficulty, intervals, ease,
  word-status colors, and algorithm decisions are never surfaced.
- All UI chrome (including the selection/copy toolbar) is Chinese.

## Constraints

- Platforms: Flutter — iOS, Android, Web.
- Offline-first core: no live backend, no runtime AI/LLM, no network
  dependency for the core loop. Optional opt-in sync of explicit learner
  data may exist post-MVP; local storage remains the source of truth.
- Media (audio, illustrations, animation) are optional per content item —
  absence is valid and must never strand the learner.

## Non-goals (permanent)

- English translations, bilingual explanations, translation popups.
- Behavioral inference of any kind: no hesitation timing, reading-speed,
  cursor/scroll, eye-movement, engagement, or psychological profiling.
  Learner state derives only from explicit learning events.
- Gamification: XP, streaks, badges, leaderboards, daily goals.
- Social features, accounts, LLM chat, engagement loops.

## Important assumptions

- Meaning can be grounded monolingually from visuals + audio + context for
  the bootstrap vocabulary (~45–150 words backward-derived from stories).
- A first-order learner model (known Hanzi + known vocabulary + bounded
  exposure) suffices for V1; the architecture must permit later
  sophistication without requiring it now.

## Open questions

- Chinese art style direction for AI-generated concept art and story
  illustrations (human editorial gate; candidates in mind).
- Audio sourcing: pre-rendered neural TTS vs native recordings (CHOICES §3).
