# ADR-004: SRS scheduling algorithm

**Status:** Accepted (2026-09-05) · **Supersedes:** D-04 open question

## Chosen

FSRS (`fsrs` package) behind a scheduler adapter; beginner 3-grade outcomes
(remembered / partially / forgotten) map to FSRS ratings at the adapter
boundary.

## Why

Mature, maintainable algorithm; card data separated from scheduler so it
can change without touching cards; internals never leave `review/`
(P-04/P-07, A-05).

## Invariants checked

E-03, A-05, P-07. Replaceable via the scheduler interface — only
`fsrs_adapter.dart` imports the package.
