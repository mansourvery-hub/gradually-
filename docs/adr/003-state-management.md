# ADR-003: State management / DI

**Status:** Accepted (2026-09-05) · **Supersedes:** D-03 open question

## Chosen

Riverpod. Providers live only in `app/`; widgets consume them; domain
packages stay pure Dart.

## Why

Testable provider overrides; stream-friendly for drift watch queries;
keeps learning logic out of widgets by construction (A-02/A-03).

## Invariants checked

A-01..A-03. Replaceable: widgets only touch `app/` providers, so a swap
is a contained refactor.
