# ADR-005: Content serialization and authoring format

**Status:** Accepted (2026-09-05) · **Supersedes:** D-05 open question

## Chosen

Versioned JSON schema (metadata → sections → sentences → pre-tokenized
tokens with exact offsets), plus a Dart-compiled corpus mirror
(`bootstrap_corpus.dart`) used at runtime. Optional media fields; simplified
Chinese.

## Why

Data-driven curriculum (E-13): validator + golden tests treat content as
code. The Dart mirror gives instant startup with zero asset-load latency;
JSON stays the authoring/verification source of truth.

## Invariants checked

D-05, D-06, D-07, E-08 (optional media), C-01/C-02 budgets. Asset names
ASCII-safe after the web percent-encoding incident (R-05).
