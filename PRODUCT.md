# Product

**One sentence:** 渐入 (JianRu) is a zero-friction, inherently monolingual
Chinese immersion app that guides a learner from absolute beginner to
independent native reading and gradually removes its own scaffolding.

**Authoritative for:** what the product is and must do. Scope of *right now*
lives in `MVP.md`; structure lives in `ARCHITECTURE.md`.

## Problem

Learning to read Chinese requires massive comprehensible input, but existing
apps interrupt the reading loop with decisions, translations, gamification,
and menus. The learner manages the curriculum instead of absorbing the
language. No app answers the core question continuously and autonomously:

> *Given everything the learner knows, which piece of Chinese should come
> next?*

## Target users

- Absolute beginners who want to learn to *read* Chinese.
- False beginners restarting with a clean, guided path.
- Learners fatigued by translation-first tools and seeking direct immersion.
- Eventually: intermediate readers importing native text (post-MVP).

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
