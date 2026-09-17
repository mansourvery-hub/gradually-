# 渐入 (JianRu V3) — Automated Mother-Story Pipeline

An end-to-end automated platform whose only required source input is a Chinese literary TXT file (such as 《红楼梦》).
JianRu constructs a progressively accessible path into the original work by decoupling **what piece of the story should be revealed next** from **how to express that piece at the learner's current linguistic level**.

Zero human Chinese authoring. Zero manual Chinese QA. Full provenance and independent multi-layer validation built in.

## Authoritative Documentation

| File | Purpose |
|---|---|
| `docs/v3-architecture.md` | Authoritative V3 architecture, explicit boundaries, Contracts 1–16 |
| `PRODUCT.md` | V3 Product intent, invariants, core principles |
| `ARCHITECTURE.md` | Technical component map (Pipeline + Flutter Reader) |
| `IMPLEMENTATION_PLAN.md` | Contract status, dependencies, and execution plan |
| `QUALITY.md` | System invariants (provenance, monolingual, validation, privacy) |
| `TEST_STRATEGY.md` | Automated mechanical verification rules |
| `AGENTS.md` | Operating loop and hard rules for development agents |
| `docs/domain/LEARNING_ENGINE.md` | Touching learner model, acquisition, SRS/review, selection. |
| `docs/domain/CONTENT.md` | Touching content schema, curriculum data, media, reader presentation. |
| `docs/domain/CHOICES.md` | Numerical parameters, target-led vocabulary, asset pipelines. |
| `docs/adr/DECISIONS.md` | Before choosing a technology or resolving anything marked `[OPEN]`. |
| `docs/adr/` | Individual ADR files — especially 005 (content serialization) and 007 (content architecture). |
| `docs/reference/dev_graph.json` | Machine-readable execution graph (mirror of the plan). |
| `docs/reference/CHINESE_IMMERSION_APP_BLUEPRINT.md` | Master product spec (consult only when shorter docs don't answer). |
| `docs/reference/DEVELOPMENT.md` | Git, branches, worktrees, commits, CI, repository workflow. |

## Adding content (the architecture contract)

> CONTENT IS DATA. Adding a story never requires code changes.

```bash
# 1. Write the story (one sentence per line, --- between sections)
# 2. Author it (lexicon-constrained pre-tokenization):
fvm dart run tool/author_story.dart my_story.txt --id story-slug --title 标题 \
  --type microStory --order 118
# 3. Add the output file to assets/content/manifest.json
# 4. ./verify
```

## Verification

```bash
./verify        # format + analyze + test + curriculum validator
```

CI runs the same gates (format/analyze/test + validator) on every push.
