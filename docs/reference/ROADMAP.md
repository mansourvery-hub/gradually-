# Roadmap

Read when deciding scope. Requirements unless marked [PROPOSED].

## MVP success criterion

> A learner can open the app and be continuously guided through progressively
> more appropriate Chinese without managing the curriculum themselves.

## MVP contains

1. Flutter shell (iOS, Android, Web)
2. Local persistence
3. Beginner first-vocabulary experience (visual + native audio + Hanzi + tone)
4. Basic tone / recognition testing (beginner review)
5. Small curated story corpus with metadata
6. Chinese tokenization (single service)
7. Learner model V1 (known Hanzi, known vocabulary, exposure)
8. Acquisition pipeline (candidates + promotion)
9. Basic sentence-based SRS after the beginner phase
10. Content selector V1 → one next experience
11. Re-reading of completed content; resume position
12. Minimal reader with playback controls; contextual lookup where curated
    local data exists (depth is later work)

## MVP does not require

Leveled/adaptive dictionary · EPUB import · podcasts · grammar modeling ·
analytics · accounts/sync/server · settings UI · social features · any
behavioral inference.

## Build order

1. **Core learning state** — shared types: Hanzi, vocabulary item, token,
   known-ness, exposure, SRS state, completion.
2. **Content representation** — schema spanning beginner units → stories →
   long text without shared media requirements; first curated data.
3. **Content selection** — simple, replaceable V1 + golden fixtures.
4. **Reading / beginner experience** — smallest UI that consumes selection.
5. **Acquisition + SRS** — candidates, promotion, scheduler adapter, cards.
6. **Refinement** — only after the loop works: selector quality, learner
   model evidence, dictionary depth, story progression.

Deviate only for a strong technical reason, stated in the PR/commit.

## Later (in rough order)

- Contextual grammar / lexical notes attached to content
- Idiom / proper-noun handling
- Leveled Chinese-only dictionary definitions
- EPUB / TXT import (same tokenizer pipeline)
- Podcast / native MP3 listening modality
- Optional opt-in sync of explicit learner data for progress portability
  across devices / reinstalls (E-14; local stays primary)
- Additional learner-model evidence (rereading, long-term exposure, grammar)

## Current focus

_Update this line as work progresses._ Currently: Build order steps 1–5
complete (core learning state, content schema, content selector V1,
beginner reader experience, and acquisition pipeline + FSRS review);
step 6 (refinement & audio/interaction polish) next.
