# Task: Master High-Granularity Development Graph Generation for 渐入 (JianRu)

## Context & Project Identity
You are an expert software architect and pedagogical engineer designing the complete, (near) infinite-granularity execution graph for **渐入 (JianRu)** — a zero-friction, inherently monolingual Chinese reading immersion application.

Before building the graph, you must read and adhere to all repository design documents:
- `AGENTS.md`: Core operating rules, non-negotiable invariants, and privacy boundaries.
- `CHINESE_IMMERSION_APP_BLUEPRINT.md`: Comprehensive product design, pedagogical philosophy, and system architecture.
- `ARCHITECTURE.md`: Subsystem boundaries, drift SQLite persistence, tokenizer single-service rule, and provider wiring.
- `LEARNING_ENGINE.md`: Learner state, bounded aggregate model, acquisition pipeline, FSRS SRS, and content selection.
- `CONTENT.md`: Content schema, pre-tokenized JSON format, scaffold decay, and editorial guidelines.
- `CHOICES.md`: Numerical choices (500–600 exposure threshold, 100–150 target-led bootstrap words, level injection hooks).
- `DECISIONS.md`: Resolved architectural decisions ($D\text{-}01$ through $D\text{-}06$, $E\text{-}01$ through $E\text{-}14$).
- `ROADMAP.md`: Build order and milestones.

---

## Core Non-Negotiable Invariants to Embed in the Graph
1. **Target-Led Backward Lexicon Derivation:** Beginner Hanzi and vocabulary are **never** selected from arbitrary frequency lists (like HSK). They are derived *backwards* from the first short stories (e.g. Stories 1–3 define the exact ~100 bootstrap words needed for 100% $i+1$ comprehension).
2. **Pure Exposure Phase:** At the start, there is **zero recall testing and zero SRS review**. The learner completes $\sim 500\text{--}600$ multi-sensory exposures ($\sim 100\text{--}150$ core words presented $4\text{--}6\times$ with visual + native audio + Hanzi + tone) before any testing or SRS review is unlocked.
3. **Radical Button-Free Zen Minimalism:** No Anki buttons (`忘记/模糊/记得`), no "继续/Continue" button bars, no XP/streaks/dashboards. Interaction is 100% tap-anywhere / natural cadence on a serene paper canvas.
4. **The System Chooses ONE Experience:** Zero course catalogs, level selectors, or decision screens. Internals stay internal.
5. **Offline-First & Strict Privacy:** Pure Dart domain logic, Drift SQLite bounded aggregates (upsert-in-place, no append-only event logs), no behavioral tracking (no dwell/hesitation time).
6. **Simulated Level Testing Hooks:** Support instant developer bootstrapping via `--dart-define=LEVEL=0..100`.

---

## Deliverable Requirements: The High-Granularity Graph

Generate a hierarchical, fully interconnected Directed Acyclic Graph (DAG) in JSON format (`dev_graph.json` or equivalent) that breaks down the entire project implementation into atomic, executable units.

### 1. Hierarchy Levels (Near-Infinite Granularity)
The graph must use a 4-tier hierarchical decomposition:
* **Level 1: Milestone / Track (Epic)** — e.g. `TRACK_EDITORIAL_CONTENT`, `TRACK_CREATIVE_ASSETS`, `TRACK_CORE_ENGINE`, `TRACK_PERSISTENCE`, `TRACK_UI_READER`, `TRACK_TESTING_TOOLING`.
* **Level 2: Feature Subsystem** — e.g. `FEATURE_TARGET_LEXICON_EXTRACTION`, `FEATURE_AUDIO_TTS_PIPELINE`, `FEATURE_FSRS_INTEGRATION`.
* **Level 3: Actionable Task** — e.g. `TASK_TOKENIZE_STORY_001_CORPUS`, `TASK_GENERATE_EDGE_TTS_HANZI_AUDIO`.
* **Level 4: Atomic Execution Step** — Self-contained units with strict inputs, outputs, exact file paths, validation commands, and automated test criteria.

### 2. Node Schema Specification
Each node in the graph must follow this exact structure:

```json
{
  "id": "T_CONT_004_TOKENIZE_STORIES",
  "name": "Tokenize Target Stories & Extract Lexicon",
  "track": "editorial_content",
  "parent": "FEATURE_TARGET_LEXICON_EXTRACTION",
  "level": 3,
  "status": "pending",
  "isParallelizable": true,
  "assignedAgentRole": "content_engineer",
  "description": "Run the canonical dart_jieba tokenizer across Story 1-3 source texts to produce the exact set of 100-150 required bootstrap tokens and their frequency counts.",
  "inputs": [
    "assets/content/stories/story_001_source.txt",
    "assets/content/stories/story_002_source.txt",
    "assets/content/stories/story_003_source.txt"
  ],
  "outputs": [
    "assets/content/curriculum/bootstrap_target_lexicon.json"
  ],
  "dependsOn": [
    "T_CONT_001_CURATE_TARGET_STORIES_TEXT",
    "T_ENG_002_TOKENIZER_SERVICE"
  ],
  "blocks": [
    "T_ASSET_001_AUDIO_PIPELINE_BOOTSTRAP",
    "T_ASSET_002_VISUAL_PIPELINE_BOOTSTRAP",
    "T_CONT_005_AUTHOR_EXPOSURE_UNITS"
  ],
  "acceptanceCriteria": [
    "Every word in Stories 1-3 exists in bootstrap_target_lexicon.json",
    "Character offsets and token boundaries are validated by automated regression fixtures",
    "fvm flutter test test/content_test.dart passes"
  ],
  "substeps": [
    "Load raw simplified Chinese text for Stories 1-3",
    "Segment text using Tokenizer service",
    "Extract distinct VocabIds and mark curriculum-critical items",
    "Save to target lexicon JSON manifest"
  ]
}
```

### 3. Required Parallel Execution Tracks
The graph must explicitly identify dependencies across these parallel sub-agent tracks:
1. **Editorial & Story Track (`editorial_content`):** Story curation $\rightarrow$ target lexicon extraction $\rightarrow$ pre-tokenized JSON generation $\rightarrow$ regression fixtures.
2. **Audio Creative Track (`creative_audio`):** Lexicon input $\rightarrow$ native audio recording / neural pre-rendered TTS generation $\rightarrow$ asset compression (MP3/OGG) $\rightarrow$ manifest mapping. (Can run 100% in parallel once the lexicon is extracted).
3. **Visual Creative Track (`creative_visual`):** Target concepts $\rightarrow$ minimalist vector SVGs / illustrations $\rightarrow$ asset registration. (Can run 100% in parallel once concepts are chosen).
4. **Learning Engine & Algorithms (`core_engine`):** Bounded exposure accumulator ($\ge 500$ encounters) $\rightarrow$ Content Selector V2 ($i+1$ readiness scoring) $\rightarrow$ Scaffold decay logic $\rightarrow$ Subordinate FSRS review adapter.
5. **Persistence & Data Layer (`data_persistence`):** Drift SQLite migrations $\rightarrow$ repository interfaces $\rightarrow$ web WASM / native asset handling $\rightarrow$ privacy invariant validation.
6. **Reader UI & Canvas (`ui_reader`):** Button-free Zen canvas $\rightarrow$ gesture / tap progression $\rightarrow$ audio autoplay cadence $\rightarrow$ responsive constraints.
7. **Developer Tooling & Testing (`tooling_testing`):** Level injection hooks (`--dart-define=LEVEL=0..100`) $\rightarrow$ Golden progression suites $\rightarrow$ Automated CI verification.

---

## Instructions for the Generating AI
1. **Be Completely Exhaustive:** Do not leave placeholder summaries or "etc." Detail every sub-task down to file names, dependencies, and unit tests.
2. **Strictly Enforce the DAG:** Ensure there are **no circular dependencies** (`A depends on B which depends on A`).
3. **Prioritize Unblocked Parallelism:** Make creative asset tasks (audio generation, illustration rendering) independent of UI rendering tasks once their respective contract interfaces/lexicons are defined.
4. **Output Format:** Provide both the complete machine-readable `dev_graph.json` artifact and a comprehensive markdown summary explaining the critical path and sub-agent allocation.
