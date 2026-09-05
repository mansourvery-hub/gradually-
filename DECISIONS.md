# Decisions

Only decisions that affect multiple subsystems. Established decisions are not
reopened. Open items are resolved here before code depends on them. Keep this
file short.

## Established

| # | Decision |
|---|---|
| E-01 | Platform: Flutter on iOS, Android, Web. Offline-first core; no server in MVP. |
| E-02 | Content Selector and Review System are separate subsystems sharing learner state only. |
| E-03 | SRS state ≠ learner state. Review owns cards/scheduling; learner model owns knowledge and consumes mastery evidence. |
| E-04 | Learner model V1 = known Hanzi + known vocabulary + pedagogical exposure. No rigid level as core representation. |
| E-05 | Acquisition states are distinct: unknown → candidate → promoted → established. Never `unknown == card`. |
| E-06 | Selector outputs ONE experience; no ranked list, score, or rationale is ever shown. |
| E-07 | One tokenizer service and one shared vocabulary/token representation for all consumers. |
| E-08 | Media (audio, visuals, animation) are optional per content item; no universal audio-sync layer. |
| E-09 | Learner data derives only from explicit learning events. No behavioral signals, ever. |
| E-10 | Completed content remains accessible; rereading uses current learner state. |
| E-11 | Scaffolds (pinyin, narration, visuals) are stage-driven, not user settings. |
| E-12 | Dictionary is local, monolingual, curated; no runtime LLM; depth is later work. |
| E-13 | Content data is regression-tested like code (golden progression fixtures). |

## Market-informed decisions (compact)

| Source → mechanism | Status |
|---|---|
| LingQ → persistent vocabulary state across all reading | ADOPT |
| Migaku → content difficulty analysis; contextual sentence mining | ADAPT: internal only; system chooses content, learner does not |
| Du Chinese → one-tap contextual lookup; pinyin scaffolding; partial-recall grades | ADAPT: monolingual lookup; stage-driven pinyin; 3-grade recall in beginner phase |
| Mandarin Companion → vocabulary budgets, recycling, story quality | ADOPT as editorial requirement |
| HelloChinese / SuperChinese → polished beginner phonology/tone recognition | ADOPT for bootstrap only; no gamified course model |
| Anki / FSRS → mature scheduler behind a simple review UI | ADOPT; internals invisible |
| Chairman's Bao → sentence-attached grammar/lexical notes | LATER |
| Readibu → EPUB/native-text import, resume, offline library | LATER (resume + offline are MVP) |
| Comprehension %, word-status colors, catalogs, translation-first lookup, gamification, behavioral inference | REJECT |

## Open — resolve here before implementing

| # | Decision | Constraints |
|---|---|---|
| D-01 | Local persistence (SQLite vs Isar vs other) | Offline; behind repository interfaces; swappable. |
| D-02 | Tokenizer implementation (e.g. C tokenizer via Dart FFI) | Embedded, offline, single service, deterministic. |
| D-03 | State management / DI approach | Learning logic stays out of widgets. |
| D-04 | SRS scheduling algorithm | Mature; separated from card data; replaceable; internals hidden. |
| D-05 | Content serialization / authoring format and pre-tokenization policy | Data-driven; optional media; consistent tokens across consumers. |
| D-06 | Script for curated content (simplified/traditional; whether both are ever supported) | Affects tokenizer, dictionary, content, vocabulary keys. |

Resolution format:

```text
D-XX — Chosen: … · Why: … · Invariants checked: … · Replaceable via: … · Date: …
```
