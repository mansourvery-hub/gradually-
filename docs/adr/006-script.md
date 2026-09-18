# ADR-006: Script

**Status:** Accepted (2026-09-05) · **Supersedes:** D-06 open question

## Chosen

Simplified Chinese only (MVP and foreseeable lifetime).

## Why

One script keeps tokenizer, dictionary, vocabulary keys, and content
pipeline coherent; traditional support was judged not worth the ubiquitous
double-keying.

## Invariants checked

C-01, C-04. Revisit only as an explicit product decision.
