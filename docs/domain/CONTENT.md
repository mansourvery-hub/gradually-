# Content

Content representation, curriculum metadata, progression, media, rereading,
and later import. Read with `AGENTS.md`. Requirements unless marked
[PROPOSED] / [OPEN].

## 1. Content is part of the algorithm

> **Poor content cannot be fully repaired by a smarter selection algorithm.**

Incorrect tokenization, bad vocabulary metadata, weak recycling, unnatural
Chinese, excessive irrelevant words, or wrong difficulty labeling damage the
curriculum directly. Content data is versioned and regression-tested like
code (`ARCHITECTURE.md` §7). Curriculum lives in data, never in widget
conditionals.

## 2. Progression

```text
absolute beginner (first ~100 words: visual + native audio + Hanzi + tone)
→ visual-heavy, narrated micro-stories
→ children's stories / culturally important tales
→ increasingly text-centered, longer native stories
→ adult native content · books · literature · magazines · philosophy
→ imported EPUBs and arbitrary native text
```

Not a rigid level taxonomy. Learner state + content metadata decide
appropriateness. The beginner phase is a general absolute-beginner phase, not
a course for speakers of any particular language.

## 3. Content model

```text
Content
 ├── metadata: id, title, type, ordering, prerequisites, difficulty,
 │             editorial constraints, vocabulary references
 ├── sections / scenes
 │    ├── text (unspaced Chinese)
 │    ├── visual assets   (optional)
 │    └── audio           (optional)
 └── sentences
      ├── tokens (shared token type)
      └── learning metadata (e.g. curriculum-critical vocabulary)
```

Must support: unspaced text · shared tokenization · section boundaries ·
optional visuals/audio/animation · ordering and prerequisites · difficulty
metadata · vocabulary reuse · completion history · saved reading position.

Do not force fields that only apply to beginner stories onto every item.
Content types range from beginner atomic units to long plain text without
identical media requirements. Serialization / authoring format: **[OPEN]**
`DECISIONS.md` D-05.

## 4. Media are optional capabilities

```text
beginner units    strong visuals + native word audio
early stories     illustrations, animation where useful, native narration
later stories     fewer visuals, narration optional
native reading    text is primary
```

No universal sentence-audio synchronization. Audio-bearing content declares
it; the reader plays what exists. Podcasts / native MP3 listening is a later,
separate modality.

## 5. Editorial requirements (early content)

- Strong vocabulary budgets per item.
- Deliberate recycling of important vocabulary across adjacent stories.
- Natural, genuinely enjoyable Chinese — not sentences wrapped in pictures.
- Long enough for repeated contextual exposure.
- Culturally meaningful material: children's stories, classic tales.
- Beginner sequence connects concept/visual → native sound → Hanzi → tone.

Content metadata may mark vocabulary as curriculum-critical so the acquisition
pipeline and selector can weight it. It is never shown to the learner.

Selecting which specific stories, books, or reading materials to include in the
curriculum is a critical task requiring human judgment. Agents facing choices
about which texts to include are free and expected to ask the user, who will
respond.

## 6. Scaffold decay

Scaffolds (visuals, narration, pinyin, sentence-mode reading, lookup depth)
are stage-driven capabilities, not permanent user preferences. The system
reduces them as learner state advances; there is no "beginner mode" toggle.
Pinyin exists internally on vocabulary items; whether it is displayed for a
given item at a given stage is driven by content/learner data.

## 7. Rereading

Completed content stays accessible ("previously finished reading"). Rereading
uses the current learner state — it is not a fresh lesson. Very high
repetition of early stories is expected and may be surfaced by the selector.
Reading position is always preserved and resumed.

## 8. Reader presentation

Minimal. Legitimate controls: play/pause/replay, continue, back, tap-to-look-up
where the content supports it. Lookup stays inside the reader, is local, and
is monolingual; the depth of what it shows is content/stage-driven (see
`ROADMAP.md` for dictionary phasing). No word-status colors, percentages, or
difficulty indicators.

## 9. Later content capabilities (not MVP)

- Grammar / lexical notes attached to the exact sentence or pattern
  (contextual help, never a grammar course).
- Idiom and proper-noun treatment distinct from core vocabulary.
- EPUB / TXT import → same tokenizer → vocabulary mapping → learner-state
  comparison. Offered only when learner state supports native reading. Not a
  document manager.
- Simplified/traditional handling if both are ever supported
  (`DECISIONS.md` D-06).
- Leveled Chinese-only definitions (simple → standard → nuanced).
