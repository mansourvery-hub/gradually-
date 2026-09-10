# Test Strategy

**Answers:** how is every rule in `QUALITY.md` mechanically verified?
Hierarchy: `targeted test → full suite → ./verify → CI`.

| Quality rule | Enforcement | Test / command |
|---|---|---|
| A-01 domain purity | architecture test | `test/architecture_and_privacy_test.dart` (import scan over all 8 domain dirs) |
| A-02/A-03 composition & widget purity | convention + review | boundary test covers domain dirs; `app/`+`reader/` reviewed in diff |
| D-03 no behavioral fields | schema test | privacy column-scan over all drift tables |
| D-01/D-02 explicit-event upserts | unit tests | `test/learner_state_test.dart`, `test/progress_test.dart`, `test/reading_position_test.dart` |
| D-04 migration preservation | migration test | `test/drift_repository_test.dart` (schema round-trips) |
| D-05 exact token offsets | validator + tests | `tool/validate_curriculum.dart`, `test/content_test.dart` |
| D-06 story lexicon purity | regression test | `test/reading_position_test.dart` (children story recycles lexicon) |
| D-07 media refs resolve | validator | `tool/validate_curriculum.dart` (visual refs exist on disk) |
| R-01/R-03 renderable assets | render smoke | `test/svg_render_smoke_test.dart` (every manifest SVG through flutter_svg) |
| R-02 absent lookup fail-safe | unit tests | `test/reader/context_lookup_test.dart` |
| R-04 loop never freezes | regression tests | `test/simulated_session_test.dart` (state advances on tap) |
| R-05 ASCII asset names | manifest test | `test/visual_manifest_test.dart` + `kConceptAssetNames` parity |
| P-01 monolingual UI & data | data tests + widget test | lookup tests (no translation fields, no Latin), `test/selection_interaction_test.dart` (复制, never Copy), SVG no-text test |
| P-02 selector outputs ONE | unit tests | `test/selector_golden_test.dart` |
| P-04/P-07 review subordinate, internals hidden | design + gate tests | `test/exposure_gate_test.dart` (lock, pacing, ramp), fsrs smoke (adapter boundary) |
| P-06 resume & reread | regression tests | `test/reading_position_test.dart` (position round-trip, reread upsert, clamping) |
| C-01/C-02 exposure budgets | content tests | `test/dynamic_exposure_test.dart`, gate boundary tests (499/500, per-word floor) |
| C-03 gate pacing | boundary tests | `test/exposure_gate_test.dart` (exact boundaries, anti-cramming, cohort cap) |
| C-04 monolingual dictionary | data tests | full-lexicon coverage test, no-Latin test |
| C-05 asset name contract | manifest + coverage tests | `test/visual_manifest_test.dart` |
| acquisition lifecycle (E-05) | unit tests | `test/acquisition_test.dart`, `test/acquisition_and_review_test.dart` |
| tokenization determinism | golden tests | `test/jieba_smoke_test.dart`, `test/tokenizer_golden_test.dart` |
| reader interaction (tap/advance/lookup/select) | widget tests | `test/reader_widget_test.dart`, `test/activation_input_test.dart`, `test/selection_interaction_test.dart`, `test/widget_smoke_test.dart` |
| level hook determinism | unit tests | `test/exposure_gate_test.dart` (LEVEL mapping), `test/dev_level_injection_test.dart` |

## Verification gates

```text
targeted test      → while iterating a brick
flutter test       → before declaring a task done (110 tests)
./verify           → full local quality gate (format, analyze, test, validator)
CI (ci.yaml)       → clean-environment re-run of analyze + test
```

## Regression rule

Every bug fix adds a permanent regression test at the smallest layer that
would have caught it (bug → diagnose → fix → regression test → verify →
commit). Historical examples baked into the suite: tap-freeze at simulated
levels, web percent-encoded assets, dictionary lexicon coverage, tofu font
flash.
