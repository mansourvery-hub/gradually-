# ADR-001: Local persistence

**Status:** Accepted (2026-09-05) · **Supersedes:** D-01 open question

## Chosen

Drift (SQLite) via `drift_flutter`, bounded aggregate tables only.

## Why

Mature, migration-capable, WASM backend for web (offline-first E-01),
testable with `NativeDatabase.memory()`. Strongest fit for the bounded
upsert model the learner state requires (no append-only event log).

## Alternatives considered

- Isar — good DX but weaker web story at decision time.
- Plain JSON file — no reactive watch streams, no migrations.

## Invariants checked

D-01 (data), D-03 (schema privacy), R-04 (loop resilience). Replaceable via
repository interfaces owned by domain packages (A-06): only `data/` knows
Drift exists.
