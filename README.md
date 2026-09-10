# 渐入 — Chinese Immersion App

A zero-friction, inherently monolingual Chinese immersion app. It continuously
answers one question — **given everything the learner knows, which piece of
Chinese should come next?** — and progressively removes its own scaffolding
until the learner no longer needs it.

Platform: Flutter — iOS, Android, Web. Offline-first core.

## Documents (read in order — narrow to the task at hand)

| File | Read when… |
|---|---|
| `AGENTS.md` | **Every task.** Entry point, authority hierarchy, operating loop, hard rules. |
| `PRODUCT.md` | Need the product intent, users, journeys, non-goals, constraints. |
| `MVP.md` | Deciding what is in scope right now vs deferred. |
| `ARCHITECTURE.md` | Touching subsystem boundaries, persistence, tokenizer, tests. |
| `QUALITY.md` | Need to know which invariants must remain true. |
| `TEST_STRATEGY.md` | Need to know how an invariant is mechanically verified. |
| `IMPLEMENTATION_PLAN.md` | Selecting the next ready task. |
| `docs/domain/LEARNING_ENGINE.md` | Touching learner model, acquisition, SRS/review, selection. |
| `docs/domain/CONTENT.md` | Touching content schema, curriculum data, media, reader presentation. |
| `docs/domain/CHOICES.md` | Numerical parameters, target-led vocabulary, asset pipelines. |
| `docs/adr/DECISIONS.md` | Before choosing a technology or resolving anything marked `[OPEN]`. |
| `docs/adr/` | Individual ADR files for established decisions. |
| `docs/reference/dev_graph.json` | Machine-readable execution graph (mirror of the plan). |
| `docs/reference/CHINESE_IMMERSION_APP_BLUEPRINT.md` | Master product spec (consult only when shorter docs don't answer). |
| `docs/reference/DEVELOPMENT.md` | Git, branches, worktrees, commits, CI, repository workflow. |

## Verification

```bash
./verify        # format + analyze + test + curriculum validator
```

CI runs the same gates (format/analyze/test + validator) on every push.
