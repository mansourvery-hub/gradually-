# Chinese Immersion App

A zero-friction, inherently monolingual Chinese immersion app. It continuously
answers one question — **given everything the learner knows, which piece of
Chinese should come next?** — and progressively removes its own scaffolding
until the learner no longer needs it.

Platform: Flutter — iOS, Android, Web. Offline-first core.

## Documents

| File | Load when… |
|---|---|
| `AGENTS.md` | **Every task.** Invariants, boundaries, decision rules. Short. |
| `ARCHITECTURE.md` | Touching subsystem boundaries, persistence, tokenizer, tests. |
| `LEARNING_ENGINE.md` | Touching learner model, acquisition, SRS/review, content selection. |
| `CONTENT.md` | Touching content schema, curriculum data, media, reader presentation. |
| `dev_graph.json` | Master execution graph, 4-tier task decomposition (282 nodes), and dependency DAG. |
| `CHOICES.md` | Numerical parameters, target-led vocabulary choices, asset pipelines. |
| `ROADMAP.md` | Deciding what to build now vs later. |
| `DECISIONS.md` | Before choosing a technology or resolving anything marked [OPEN]. |
| `CHINESE_IMMERSION_APP_BLUEPRINT.md` | Master product spec (human reference). Consult only when the shorter docs don't answer. |
| `DEVELOPMENT.md` | Git, branches, worktrees, commits, CI, repository workflow. |

## How to work

1. Read `AGENTS.md`.
2. Read only the subsystem document(s) relevant to the task.
3. Read the code.
4. If a decision affects more than one subsystem, record it in `DECISIONS.md`.

Do not read everything by default.
