# AGENTS.md — operating rules for coding agents

Read this file for every task. Then read only the subsystem document you need
(see §2). Do not load the full blueprint unless these documents fail to answer.

## 1. Product

**One sentence:** a zero-friction, inherently monolingual Chinese immersion
app that guides a learner from absolute beginner to independent native reading
and gradually removes its own scaffolding.

**Core question:** *Given everything the learner knows, which piece of Chinese
should come next?* The system answers it. The learner does not.

**End goal:** the app becomes less necessary as the learner becomes capable of
consuming Chinese directly. This is success, not churn.

## 2. What to read for your task

| Task touches… | Read |
|---|---|
| Learner state, acquisition, SRS/review, next-content selection | `LEARNING_ENGINE.md` |
| Content schema, curriculum data, media, reader presentation | `CONTENT.md` |
| Subsystem boundaries, persistence, tokenizer, tests | `ARCHITECTURE.md` |
| Scope / "should this exist yet?" | `ROADMAP.md` |
| Master execution graph / task decomposition | `dev_graph.json` |
| Numerical parameters, editorial & asset pipelines | `CHOICES.md` |
| Technology choice or anything marked [OPEN] | `DECISIONS.md` |

## 3. Non-negotiable invariants

1. **Monolingual.** No English translations, explanations, translation
   popups, or bilingual teaching UI in the learner experience. Meaning comes
   from visuals, audio, context, repetition, and later simple Chinese.
2. **The system chooses the next content.** No course/level/deck/lesson
   selection. The learner never sees a ranked list of recommendations — the
   selector outputs **one** experience.
3. **Zero unnecessary decision-making.** No configuration screens,
   dashboards, statistics, or decision-heavy home screens. This does *not*
   mean zero controls: play, pause, replay, continue, back, and contextual
   lookup are legitimate. Remove decisions, not buttons.
4. **Immersion is primary; SRS is subordinate.** Cards emerge from content.
   Review supports reading; it is not the product.
5. **Scaffolding decays automatically.** No manual "beginner/advanced mode".
   Visual, audio, and pinyin support diminish as capability grows.
6. **Local/offline-first core.** Opening content, lookup, known-word
   determination, review, and selection never depend on a live backend or a
   real-time AI call. Optional opt-in synchronization of explicit learner
   data may exist later (post-MVP); it never becomes a dependency of the
   core loop, and local storage remains the source of truth (E-14).
7. **No surveillance.** See §6.
8. **Content Selector ≠ Review System.** Two subsystems, two questions
   ("what's next?" / "what's due?"). They share learner state; they are
   never merged.
9. **SRS state ≠ learner state.** The review system owns cards and
   scheduling. The learner model owns learner-level knowledge and consumes
   mastery evidence. Scheduler internals never live in the learner model.
10. **One tokenizer, one vocabulary representation.** Reader, dictionary,
    SRS, selector, and importer all use the same segmentation service and the
    same shared types.
11. **Internals stay internal.** i+1 scores, difficulty values, intervals,
    ease, vocabulary counts, word-status colors, rankings, and algorithm
    decisions are never shown to the learner.
12. **Re-reading is a feature.** Completed content stays accessible and is
    read with the same learner state. Never "completed = gone".
13. **Media are optional capabilities of content, not universal
    infrastructure.** Do not assume audio, animation, or illustrations exist
    for every item. No app-wide sentence-audio-sync requirement.

## 4. Anti-features (do not add without a strong, written product reason)

XP · streaks · badges · achievements · leaderboards · daily goals · social
features · progress dashboards · comprehension percentages or word-status
heatmaps shown to the learner · lesson menus or course catalogs · translation
popups · bilingual explanations · onboarding flows · notifications ·
engagement loops · behavioral inference · cloud dependencies for the core loop
· settings screens for ordinary use · exposed algorithm settings · LLM chat.

"Every language app has it" is not a product reason.

## 5. Core loop and architecture

```text
learner state → content selection → immersion (read/listen)
             → automatic acquisition → review → better learner state → …
```

```text
                 Learner State
                    /      \
                   ↓        ↓
       Content Selector    Review System
         "What's next?"    "What's due?"
                   ↓        ↓
                Content    Cards
```

Distinct components (keep them distinct): Learner Model · Content Selector ·
Reader/Beginner Experience · Acquisition Pipeline · Review/SRS · Tokenizer ·
Dictionary · Importer (later). Learning logic lives in domain services, never
in widgets. Curriculum lives in data, never in widget conditionals.

Acquisition lifecycle — these are **distinct states**:

```text
unknown encounter → acquisition candidate → (useful / recurring / appropriate)
                  → promoted to SRS → established knowledge
```

Never implement `unknown == flashcard`.

## 6. Privacy boundary

Learner state and any stored data may only derive from **explicit learning
events**: recognition/review outcomes, content encounters, completion,
rereading, and other pedagogically justified records.

Never infer from or persist: hesitation time, reading speed, cursor or scroll
behavior, eye movement, session/engagement patterns, usage frequency, or any
psychological profiling. No nudging. Any adaptation must be explainable from
explicit learning/content data.

## 7. Rules of conduct

- **Do not invent product behavior.** If the blueprint and these documents
  are silent on a *product* detail, do not decide it silently. Choose the
  smallest option that violates no invariant, mark it `[PROPOSED]` in code
  comments or docs, and keep it isolated.
- **Do not add complexity because it is conventional or "future-proof".**
  A first-order model is acceptable. The architecture must permit later
  sophistication; it must not require it now.
- **Cross-cutting or technology decisions go in `DECISIONS.md`.** Resolve
  `[OPEN]` items there, then implement.
- **Respect `ROADMAP.md` ordering.** State the reason if you deviate.
- **Content is part of the algorithm.** Poor content cannot be fully repaired
  by a smarter selector. Content data gets regression tests like code.
- **Ask on critical decisions needing human intervention.** If an agent
  encounters a critical task or choice that requires human intervention or
  judgment (for example, selecting which specific stories, books, or texts to
  include in the curriculum), they are free and expected to ask the user, who
  will respond. Do not make high-stakes product or editorial decisions in
  isolation.

## 8. When uncertain, ask in this order

1. Does it preserve the product philosophy?
2. Does it improve the loop: selection → immersion → acquisition → review?
3. Can it stay invisible to the learner?
4. Can it stay local/offline?
5. Does it keep selector and review separate?
6. Is it the simplest thing that still allows evolution?

If a feature conflicts with the philosophy, the philosophy wins.
If an issue requires human judgment (such as content selection or editorial
direction), ask the user directly.

> **Less UI, less configuration, less friction, more native Chinese, cleaner
> automated progression.**

## 9. Git and development

* Never work directly on `main` unless explicitly instructed.
* Prefer one task branch per coherent task.
* For parallel agents, prefer one isolated Git worktree per task.
* Inspect `git status` and the current branch before modifying code.
* Assume existing uncommitted changes may belong to someone else.
* Never discard unrelated work with `git reset --hard`, `git clean`, `git restore`, or similar destructive commands unless explicitly instructed.
* Keep commits coherent; do not mix unrelated refactors into feature work.
* Agents should normally commit completed work on their task branch.
* Do not push to GitHub unless explicitly instructed.
* Run relevant tests and `flutter analyze` when appropriate.
* Review `git diff` before committing.
* Never commit secrets, credentials, or local learner databases.
* Treat curated content and curriculum metadata as code-equivalent because they affect learning progression.
* Never destroy persisted learner data simply to simplify development.
* See `DEVELOPMENT.md` for the complete Git/worktree/CI workflow.

