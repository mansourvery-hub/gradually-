# JianRu V3 — Architecture & Pipeline Specification

## 1. System Overview & Invariant

JianRu V3 is an **end-to-end automated system whose only required source input is a Chinese literary TXT file**.
The operator/user has zero Chinese knowledge and cannot manually audit Chinese correctness, literary fidelity, semantic progression, or generated content. Correctness and quality assurance are mechanically built into the software pipeline itself.

```text
ONE INPUT: Chinese literary TXT (e.g. 红楼梦.txt)
      │
      ▼
SOURCE INGESTION (Stable artifact, encoding, normalization, character offsets)
      │
      ▼
STRUCTURAL EXTRACTION (Chapters, scenes, structural segmentation)
      │
      ▼
MOTHER STORY / CANONICAL MODEL (Source facts, derived entities, events, relationships + PROVENANCE)
      │
      ▼
LINGUISTIC + NARRATIVE REPRESENTATION (Lexical profiling, frequency, tokens, narrative dependencies)
      │
      ▼
LEARNER MODEL (Decoupled: Linguistic Learner State + Narrative Learner State)
      │
      ▼
PROGRESSIVE NARRATIVE PLANNER ("What meaningful piece of the Mother Story becomes visible next?")
      │
      ▼
LEVEL-APPROPRIATE CHINESE GENERATION ("How to express that piece at current linguistic level?")
      │
      ▼
INDEPENDENT VALIDATION STACK (Deterministic, linguistic, source grounding, narrative coherence, independent judge)
      │
      ▼
STORY / LEARNING PORTFOLIO (Cacheable, versioned, provenance-preserving progressive ladder L0..Ln)
      │
      ▼
RUNTIME READING EXPERIENCE (Flutter reader consuming verified portfolio, updating learner state)
```

## 2. Explicit Boundaries & Separation of Truth

1. **Source Truth:**
   - The raw Chinese literary TXT file. Immutable. Every piece of derived knowledge or generated story must trace its offsets and segment IDs back to this artifact.
2. **Derived Knowledge (Mother Story / Canonical Model):**
   - Characters, entities, scenes, causal links, relationships, and linguistic frequencies extracted from the source.
   - Strictly segmented into:
     - *Source facts:* Directly quoted or unambiguously mapped to text offsets.
     - *Derived / inferred facts:* Model-assisted extractions with explicit evidence offsets and confidence scores.
     - *Interpretations:* High-level conceptual metadata, never conflated with source facts.
3. **Planning State:**
   - Decisions made by the Progressive Narrative Planner. Resolves *what happens next* based strictly on narrative graph prerequisites, unexposed narrative targets, and learner narrative progress. Completely decoupled from sentence wording or vocabulary simplification.
4. **Generated Content:**
   - Level-appropriate Chinese text produced to communicate the planned narrative target. Contains structured metadata: target IDs, source references, newly introduced vocabulary/Hanzi, and difficulty estimates.
5. **Validation State:**
   - Multi-layer independent evaluation results (pass/fail, layer breakdown, failure reasons). A generator is never its own judge. Fail-closed: invalid generation is discarded and regenerated.
6. **Learner State:**
   - Separated into two decoupled models:
     - *Linguistic State:* Known Hanzi, known words, grammatical complexity budget, exposure counts.
     - *Narrative State:* Discovered characters, understood relationships, experienced events, opened/resolved narrative threads.

## 3. The 16 Pipeline Contracts

1. **Contract 1: Repository + Architecture Reset:** Authoritative documentation and architectural boundaries.
2. **Contract 2: Source Ingestion:** Lossless ingestion, normalization, encoding, offset mapping of raw TXT.
3. **Contract 3: Canonical Story Extraction:** Automated Mother Story extraction with source provenance and confidence.
4. **Contract 4: Linguistic Knowledge Extraction:** Lexical profiling, word segmentation, frequency, and grammatical indexing.
5. **Contract 5: Learner State + Narrative State:** Decoupled linguistic and narrative progress representation.
6. **Contract 6: Narrative Planner:** Graph-based selection of the next narrative target.
7. **Contract 7: Controlled Generation:** Level-appropriate Chinese generation constrained by narrative target and learner state.
8. **Contract 8: Independent Validation Stack:** Multi-layer validation (deterministic, linguistic, grounding, coherence, judge).
9. **Contract 9: End-to-End Red Chamber Fixture:** Complete automated run on `红楼梦.txt`.
10. **Contract 10: Progressive Ladder Generation:** Systematic progressive ladder (L0..Ln) preserving narrative continuity.
11. **Contract 11: Portfolio / Caching Model:** Fingerprinted, versioned persistence and invalidation.
12. **Contract 12: Runtime Application:** Flutter reading client consuming the verified portfolio.
13. **Contract 13: Failure Handling:** Structured, machine-readable error codes and fail-closed transitions.
14. **Contract 14: Automated Quality Dashboard / Report:** Comprehensive inspection report for non-Chinese-speaking operators.
15. **Contract 15: Full Pipeline Regression Suite:** Adversarial fixtures, invalidation tests, and structural validation.
16. **Contract 16: Final Product Gate:** Automated proof of one TXT input to verified runtime learning portfolio.

## 4. Module Inventory & Classification

- **Retain:** `lib/tokenizer/`, `lib/core/`, `lib/data/` (Drift), bounded aggregates in `lib/learner/`, reader UI presentation components, `./verify` test harness.
- **Adapt:** `lib/content/` (provenance schemas), `lib/learner/learner_state.dart` (dual state), `lib/selector/` (portfolio selector), `tool/validate_curriculum.dart` (validation orchestrator).
- **Replace:** Manual authoring tools (`tool/author_story.dart`) and hardcoded bootstrap JSON curricula with automated Mother-Story pipeline (`tool/pipeline/`).
- **Archive:** Legacy V1/V2 design blueprints and hand-authored roadmap graphs moved to `docs/archive/v1_v2/`.
