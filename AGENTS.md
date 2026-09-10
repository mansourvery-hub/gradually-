# AGENTS.md — entry point for coding agents

Read this first, then only what the current task needs. This file explains
how to navigate the repository — it deliberately does not contain the
methodology or the requirements themselves.

## 1. Authority hierarchy

```text
PRODUCT.md        → what the product is and must do
MVP.md            → current scope (what "right now" means)
ARCHITECTURE.md   → technical structure and boundaries
QUALITY.md        → invariants that must remain true (P/A/D/R/C codes)
TEST_STRATEGY.md  → how each invariant is mechanically verified
IMPLEMENTATION_PLAN.md → current tasks, dependencies, status
AGENTS.md         → how to operate (this file)
```

Specialized documents (read on demand):

```text
docs/domain/LEARNING_ENGINE.md   acquisition/review/selector semantics
docs/domain/CONTENT.md           content schema, media, editorial rules
docs/domain/CHOICES.md           numerical/editorial parameters, pipelines
docs/adr/                        decision records (established + ADRs)
docs/reference/                  blueprint, original roadmap, machine graph
```

**CODE ≠ specification.** Code implements specs; tests enforce them. When
behavior and a document disagree, the document wins — fix the code, or fix
the document deliberately (never silently).

## 2. Operating loop

You receive: **"Work on the next ready task."** Then:

```text
1. read IMPLEMENTATION_PLAN.md → select a READY task
2. read the specs that task touches (hierarchy above)
3. inspect existing code + tests
4. split the task into the smallest meaningful contracts
5. write/extend the test for one brick first
6. implement just enough to pass it
7. run targeted tests while iterating
8. run ./verify before declaring done
9. fix failures; add a regression test for every bug found
10. update IMPLEMENTATION_PLAN.md status; update a spec only if
    something actually changed
11. commit on the task branch; never push or merge without instruction
12. select the next READY task
```

## 3. Hard rules

- **Product:** preserve every invariant in `QUALITY.md`. Monolingual means
  *everything* the learner sees — including copy toolbars and mock data.
  When a spec is silent on a product detail: choose the smallest option
  that violates no invariant, mark it `[PROPOSED]`, keep it isolated.
- **Editorial:** story/curriculum selection and art/audio direction are
  human gates. Ask; do not decide alone.
- **Privacy:** learner state derives from explicit learning events only.
  Never add a behavioral signal, field, or telemetry path (D-03 scan will
  fail you anyway).
- **Content is code:** a content-data change is an algorithm change — the
  validator and goldens must stay green.
- **Dependencies:** don't add a package without a real requirement that
  survives the checklist in `docs/reference/DEVELOPMENT.md` §13.

## 4. Failure and escalation

```text
attempt 1–2      investigate and fix normally
attempt 3        stop retrying; diagnose the root cause
root cause found → missing spec? update the spec
                  missing invariant? add a QUALITY rule
                  missing protection? add a test/linter
                  architecture problem? update ARCHITECTURE.md + plan
still unclear    → escalate to the human with a precise description
```

## 5. Git conduct (summary — full workflow in `docs/reference/DEVELOPMENT.md`)

- Never work on `main`; one task branch per coherent task; worktrees for
  parallel agents.
- Inspect `git status`/`branch` before touching anything; never discard
  unrelated work; no destructive commands without explicit instruction.
- Coherent commits only; review the diff before committing; never commit
  secrets, build output, or local learner databases.
- Agents may branch and commit; never push or merge without instruction.

## 6. Repository tooling

```bash
fvm dart analyze                # static analysis
fvm flutter test                # full suite
fvm dart run tool/validate_curriculum.dart   # content/asset contracts
./verify                        # the complete local quality gate — run
                                # before declaring any task complete
```

CI (`.github/workflows/ci.yaml`) re-runs format/analyze/test on every push.
