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
| E-14 | Optional opt-in sync of explicit learner data is a post-MVP capability for progress portability (reinstall, device change, phone→desktop). Local remains primary; the core loop never depends on sync; synced data is explicit learning data only (§6 privacy boundary travels to the server). Progress must be portable. |

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

## Resolved

All six open decisions resolved 2026-09-05, before implementation began.

D-01 — Chosen: **drift (SQLite)** · Why: type-safe compile-checked queries; explicit
versioned migrations that preserve learner data (DEVELOPMENT.md §10); reactive streams;
SQLite is the battle-tested embedded engine; web support via sqlite3 WASM keeps the
required Web platform (E-01) viable. Isar rejected (unmaintained since 2023, unstable v3,
weak web). Raw sqlite3 rejected (runtime-only SQL errors, no migration story). The
learner-data schema uses bounded per-word aggregate rows (see LEARNING_ENGINE.md §2),
not append-only event logs, so the database stays small and sync-portable (E-14). ·
Invariants checked: §3.6 offline-first; E-01; E-09 (only explicit learning events);
DEVELOPMENT.md §10 migrations. · Replaceable via: all access sits behind repository
interfaces in `data/`; drift is one implementation of them. · Date: 2026-09-05.

D-02 — Chosen: **dart_jieba** (pure-Dart jieba port) · Why: the original "C tokenizer
via Dart FFI" direction cannot run on Web (FFI unsupported in browsers), violating
E-01; dart_jieba is pure Dart, runs on all six platforms, is verified byte-identical
to Python jieba (24 golden tests), loads its compressed dictionary in ~19 ms, MIT
licensed. · Invariants checked: E-07 (one tokenizer service — single deterministic
implementation behind one interface); §3.6 offline (embedded dictionary asset). ·
Replaceable via: `Tokenizer` interface in `tokenizer/`; any implementation
(FFI jieba on native, another segmenter) can be swapped without touching consumers;
golden tokenization tests pin behavior. Risk noted: young package — mitigated by the
interface boundary. · Date: 2026-09-05.

D-03 — Chosen: **Riverpod (flutter_riverpod)** · Why: compile-safe provider wiring
that keeps learning logic in domain services and out of widgets (AGENTS.md §5);
doubles as the DI container (no extra package); first-class test overrides; no
BuildContext lookups or global singletons; most actively maintained of the options.
Bloc rejected (event-stream boilerplate exceeds V1 needs). Provider rejected (legacy,
no compile safety). Hand-rolled DI rejected (invites widget-embedded logic — the
anti-pattern blueprint §25.1 forbids). · Invariants checked: §5 learning logic in
domain services; §7 simplicity (one package, no framework sprawl). · Replaceable
via: providers are thin composition over domain services; services never import
Riverpod, so the wiring layer alone changes if the approach ever does. ·
Date: 2026-09-05.

D-04 — Chosen: **FSRS via the `fsrs` Dart package** · Why: LEARNING_ENGINE.md §4
demands a mature scheduler, not an invention; FSRS is the modern open standard
(Anki's default since 2023, open-spaced-repetition project). The package separates
card data (JSON-serializable) from scheduler logic — exactly the E-03 boundary —
and emits review outcomes the learner model consumes as mastery evidence. Beginner
3-grade outcomes (remembered/partial/forgotten) map to FSRS ratings at the adapter.
· Invariants checked: E-03 (SRS state ≠ learner state); §3.11 internals never shown
(intervals/ease stay in the review subsystem). · Replaceable via: scheduler adapter
in `review/`; card schema is scheduler-agnostic so the algorithm can change without
touching cards (D-04 constraint). Risk noted: unverified publisher — accepted because
the dependency is tiny (only `meta`), MIT, and isolated behind the adapter. ·
Date: 2026-09-05.

D-05 — Chosen: **JSON data files, versioned in-repo, pre-tokenized at authoring time**
· Why: content is code-equivalent (E-13) — JSON diffs cleanly in review, validates
trivially in CI, and needs no extra dependency; pre-tokenization at authoring (or in
a build step using the same shared tokenizer) keeps runtime deterministic and
guarantees consistent tokens across all consumers (E-07) without re-tokenizing on
open. Schema itself is designed at build-order step 2; this decision fixes only
format + pre-tokenization policy. YAML rejected (extra parser dependency). Dart
constants rejected (curriculum mixed into code; content edits force app rebuilds). ·
Invariants checked: E-08 (optional media — schema does not force media fields);
E-13 (regression tests over data files); §7 curriculum lives in data. · Replaceable
via: format conversion is a one-way script; content ids are format-independent. ·
Date: 2026-09-05.

D-06 — Chosen: **Simplified Chinese only** (traditional not supported; revisit only
as a new decision) · Why: simplified covers the target content corpus and ~97% of
Chinese-language media; dual-script support would double tokenizer, dictionary,
content, and vocabulary-key surface forever (D-06 constraint list). CONTENT.md §9
already treats traditional as conditional. Deciding now keeps build-step-1 Hanzi/
vocabulary types script-free. · Invariants checked: §7 smallest option that
violates no invariant; future addition is additive (a conversion layer + script tag
on content ids) rather than a rewrite. · Replaceable via: adding traditional later
is a new decision + additive conversion layer, not schema surgery. · Date: 2026-09-05.
