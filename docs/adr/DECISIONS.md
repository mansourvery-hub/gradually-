# Decision Records

Established decisions (E-xx) are product/architecture invariants — their
enforcement lives in `QUALITY.md`. Resolved implementation decisions
(D-xx) have ADRs in this directory. Only decisions with multiple plausible
alternatives + meaningful consequences get an ADR.

## Established invariants (index)

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
| E-14 | Optional opt-in sync of explicit learner data is post-MVP; local stays primary; the §6 privacy boundary travels to synced data. Progress must be portable. |

## ADR index

| ADR | Decision | Status |
|---|---|---|
| [001-persistence](adr/001-persistence.md) | Drift/SQLite behind repository interfaces | Accepted |
| [002-tokenizer](adr/002-tokenizer.md) | dart_jieba as the single tokenizer | Accepted |
| [003-state-management](adr/003-state-management.md) | Riverpod providers in `app/` only | Accepted |
| [004-scheduler](adr/004-scheduler.md) | FSRS behind a replaceable adapter | Accepted |
| [005-content-serialization](adr/005-content-serialization.md) | Pre-tokenized JSON + Dart corpus mirror | Accepted |
| [006-script](adr/006-script.md) | Simplified Chinese only | Accepted |

## Market-informed decisions (compact)

| Source → mechanism | Status |
|---|---|
| LingQ → persistent vocabulary state across all reading | ADOPT |
| Migaku → difficulty analysis; sentence mining | ADAPT: internal only |
| Du Chinese → one-tap lookup; pinyin scaffolding; partial-recall grades | ADAPT: monolingual lookup; stage-driven pinyin; 3-grade recall |
| Mandarin Companion → vocabulary budgets, recycling, story quality | ADOPT as editorial requirement |
| HelloChinese / SuperChinese → polished beginner phonology/tone | ADOPT for bootstrap only |
| Anki / FSRS → mature scheduler behind simple UI | ADOPT; internals invisible |
| Chairman's Bao → sentence-attached grammar/lexical notes | LATER |
| Readibu → EPUB/native-text import, resume, offline library | LATER (resume + offline are MVP) |
| Comprehension %, status colors, catalogs, translation-first lookup, gamification, behavioral inference | REJECT |
