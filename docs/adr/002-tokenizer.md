# ADR-002: Tokenizer

**Status:** Accepted (2026-09-05) · **Supersedes:** D-02 open question

## Chosen

`dart_jieba` behind one `Tokenizer` interface; curated content is
pre-tokenized at authoring time, runtime tokenization is for free text
only.

## Why

Single pure-Dart embedded service; deterministic; no FFI/portability tax
across iOS/Android/Web. Pre-tokenization freezes boundaries for goldens
(E-07, E-13).

## Invariants checked

A-07 (one tokenizer), D-05 (exact offsets enforced by the curriculum
validator). Replaceable via the `Tokenizer` interface.
