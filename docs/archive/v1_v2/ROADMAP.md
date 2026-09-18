# Roadmap

Read when deciding scope. Requirements unless marked [PROPOSED].

## Guiding principle

**CONTENT IS DATA. SEQUENCING IS LOGIC. PRESENTATION IS UI.** — never mix
these responsibilities. Phases 1–3 below are complete; the active front is
Phase 4 (corpus growth), with media strictly last.

## MVP success criterion

> A learner can open the app and be continuously guided through progressively
> more appropriate Chinese without managing the curriculum themselves.

## Phase 1 — Content architecture [COMPLETE 2026-09-13]

- ✅ Externalize stories/words/content into data files
  (`assets/content/manifest.json` + per-item JSON; lexicon-driven units)
- ✅ Stable content IDs (unit-NNN-word; story slugs) with permanence tests
- ✅ Metadata: type (beginnerUnit/sentence/microStory/story/dialogue/article),
  status (available/draft/retired), tags, difficulty, prerequisites,
  optional media refs
- ✅ No hardcoded curriculum in UI (architecture test enforces)
- ✅ Content repository/access layer (`ContentRepository` + asset impl;
  `getCandidateContents`, by-ID lookup, availability filtering)

## Phase 2 — Sequencing foundation [COMPLETE 2026-09-13]

- ✅ Sequencing interface (`ContentSelector.select(learner, candidates)`)
- ✅ Deterministic V2 algorithm (prerequisites → exposure-based i+1
  readiness → forward preparation → reread rotation)
- ✅ Learner state integrated (encountered vocabulary drives readiness —
  works before any review/mastery evidence exists)
- ✅ Next exposure selected dynamically; input order never matters

## Phase 3 — Forward preparation [COMPLETE 2026-09-13]

- ✅ Vocabulary of upcoming target content is identified from candidate
  metadata (no NLP pipeline; data-declared vocabulary)
- ✅ Earlier unit exposure deliberately prepares for future stories
  (units pre-teaching story words outrank non-preparing peers)
- ✅ Initial curriculum emerges from learner state × corpus data, not a
  fixed list

## Phase 4 — Corpus expansion [ACTIVE]

- Start: 24 story/dialogue items in data (≥ 20 required for V1) ✅
- Validate architecture under growth (add-20-stories test passes) ✅
- Expand toward 100+ items (editorial work: more stories, richer
  vocabulary — needs a larger target lexicon, backward-derived)
- Authoring workflow: `tool/author_story.dart` (text → lexicon-constrained
  pre-tokenized JSON → manifest → ./verify)

## Phase 5 — Media [DEFERRED until Phases 1–4 are exercised]

- Narration audio (TTS or recordings — decision gate open)
- Illustrations for the newer stories
- Animation
- Richer playback cadence
- The swap is data-only by design (assets attach to content records;
  absence is valid; no learning-logic changes)

## Later (post-MVP)

- Contextual grammar / lexical notes attached to content
- Idiom / proper-noun handling
- Leveled Chinese-only dictionary definitions
- EPUB / TXT import (same tokenizer pipeline)
- Podcast / native MP3 listening modality
- Optional opt-in sync of explicit learner data (E-14)
- Additional learner-model evidence (rereading, long-term exposure,
  grammar)
- Branching paths / alternatives in the content model (metadata can
  already express prerequisite/alternative relations; no UX yet)

## Current focus

Phase 4: grow the corpus through the data pipeline and exercise the
sequencing across more material. Media (Phase 5) stays parked until the
content system is proven on a larger corpus.
