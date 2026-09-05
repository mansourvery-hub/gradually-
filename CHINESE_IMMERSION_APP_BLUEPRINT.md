> **Status:** Foundational blueprint (master product specification).
> Agents: do not read this file by default. Start with `AGENTS.md` and the
> relevant subsystem document; consult this file only when they do not answer.

# Chinese Immersion App — Product & Engineering Blueprint

# 渐入

**App name:** 渐入

A zero-friction, inherently monolingual Chinese immersion application...
---

## 1. Product in One Sentence

A **zero-friction, inherently monolingual Chinese immersion app** that takes a learner from absolute beginner to independent native-content reading by continuously answering one question:

> **Given everything the learner knows, which piece of Chinese should come next?**

The application should gradually remove its own scaffolding as the learner becomes capable of consuming Chinese directly.

---

## 2. Core Product Philosophy

These principles are not suggestions. They are **product invariants**. New features, refactors, UI changes, and agent decisions must be evaluated against them.

### 2.1 Dogmatically monolingual

After launch, the learner should not see English translations, English explanations, translation popups, or bilingual teaching UI.

Meaning should be acquired from:

- visuals
- animation
- context
- repeated encounters
- simple Chinese definitions when appropriate later
- native Chinese content

The product should not quietly become bilingual because that is easier to implement.

### 2.2 Zero choice / zero friction

The learner should not have to manage a curriculum.

The system should decide what comes next based on the learner's current state and the content progression model.

Avoid unnecessary:

- course selection
- level selection
- deck selection
- lesson selection
- configuration screens
- statistics dashboards
- streaks
- points
- badges
- gamification
- decision-heavy home screens

The product should feel like a **continuous path**, not a content marketplace.

### 2.3 The learner chooses almost nothing

The core interaction is:

```text
Open app
  ↓
Receive the next appropriate experience
  ↓
Learn / read / listen
  ↓
Continue
```

At the beginning there may effectively be no navigation UI at all.

As the learner becomes more advanced, only genuinely useful destinations should appear, such as:

- Review
- Read / previously finished content
- EPUB / content import

The interface should remain extremely minimal.

### 2.4 Quality content over feature volume

The product is fundamentally a **content progression system**, not a feature collection.

The early curriculum should emphasize culturally meaningful, high-quality native material, especially:

- children's stories
- classic tales
- culturally important stories
- eventually longer native literature
- eventually philosophical texts, magazines, and other premium/native material
- eventually arbitrary learner-imported text such as EPUBs

Do not add generic language-app features merely because competitors have them.

### 2.5 Immersion is the primary activity

The goal is not to maximize quiz time.

The main loop is:

```text
CONTENT
  ↓
ENCOUNTER
  ↓
VOCABULARY ACQUISITION
  ↓
AUTOMATIC CARD CREATION / REVIEW SUPPORT
  ↓
BETTER COMPREHENSION
  ↓
MORE APPROPRIATE CONTENT
```

SRS exists to support immersion, not replace it.

### 2.6 Scaffolding should decay automatically

The learner should not have to manually choose "beginner mode", "intermediate mode", etc.

As the learner becomes capable of consuming Chinese with less assistance, the app should naturally reduce assistance.

Conceptually:

```text
Highly visual beginner experience
        ↓
Visual + native narration stories
        ↓
Increasingly text-centered stories
        ↓
Longer native reading
        ↓
Native books / literature
        ↓
Arbitrary native content
```

> **The application should gradually get out of the learner's way.**

### 2.7 The ultimate goal is to make the app less necessary

The app is successful when the learner can increasingly consume Chinese without it.

This is a deliberate product philosophy, not a retention failure.

```text
APP
 ↓
guided immersion
 ↓
independent reading
 ↓
native Chinese media
 ↓
native books / podcasts / literature
 ↓
less dependence on the app
```

---

## 3. Market-Informed Features: What to Borrow, What to Adapt, What to Reject

This section is intentionally concrete. The goal is not to copy competitors, but to identify **specific features that have already proven useful in immersion/Chinese-learning products** and decide exactly how they fit this product.

The reference products include **LingQ, Migaku, Du Chinese, The Chairman's Bao, Mandarin Companion, Readibu, HelloChinese, SuperChinese, and Anki/FSRS**.

### 3.1 Borrow from LingQ: a persistent vocabulary/known-word layer

LingQ's reader distinguishes unfamiliar, learning/saved, known, and ignored vocabulary and uses that vocabulary state across reading. It also supports sentence mode and repeated reading of mini-stories. [LingQ Reader](https://forum.lingq.com/t/new-learner-guide/8719), [LingQ Mini Stories](https://www.lingq.com/en/learn-chinese-online/courses/289023/)

**Incorporate:**

- one persistent vocabulary state shared by reader, acquisition, SRS, and content selection
- vocabulary state must survive across stories
- rereading old content must use the same learner state rather than treating every reading as a fresh lesson
- sentence-focused reading is useful as a **reader interaction mode**, especially for beginners

**Adapt:**

LingQ requires the learner to decide what to save / create as a LingQ. In this product, curated-content acquisition should be substantially more automatic.

**Do not copy:**

Do not reproduce LingQ's highly user-directed library/lesson-selection model as the main experience. The learner should not browse a giant catalog to decide what to read next.

### 3.2 Borrow from Migaku: content difficulty analysis and frictionless sentence mining

Migaku's strongest relevant features are its per-word learning statuses, content comprehension scoring based on known vocabulary, contextual dictionary, and one-click media-rich sentence mining. It can also identify sentences that are useful to learn based on the learner's current vocabulary. [Migaku Features](https://migaku.com/faq/features), [Migaku learning statuses](https://migaku.com/blog/youtube/supercharge-your-language-learning-tracking-learned-words)

**Incorporate:**

- a persistent known-vocabulary state that the content engine can query
- content analysis that estimates how appropriate a piece of text is for the learner
- automatic identification of promising vocabulary candidates
- automatic sentence-card creation from the exact context in which vocabulary was encountered

**Adapt strongly:**

Migaku uses its comprehension analysis mainly to help the learner choose among media. Our system should use the same *underlying idea* to **choose the media for the learner**.

In other words:

```text
Migaku:
learner -> analyzes content -> learner chooses

This product:
learner state -> analyzes candidate content -> system chooses
```

**Do not copy:**

Do not expose colored word statuses, comprehension percentages, or content difficulty scores to the learner during the normal curriculum.

### 3.3 Borrow from Migaku: rich contextual cards

Migaku's cards can include the target word, the sentence, native/TTS audio, an image or screenshot, and an audio excerpt from the source media. [Migaku Features](https://migaku.com/faq/features)

**Incorporate the principle, not the entire implementation:**

For this product, curated story cards should preserve the strongest contextual information available:

- target word
- full source sentence
- target-word emphasis
- relevant story visual when available
- native word audio when available
- source-story context / provenance

For early stories, this can make cards dramatically more useful than isolated vocabulary cards.

**Do not require screenshots, sentence audio, or other media for every future content type.** Those are optional enrichments that naturally disappear as the product moves toward plain native reading.

### 3.4 Borrow from Du Chinese: context-dependent lookup

Du Chinese provides one-tap dictionary lookup, context-dependent word meanings, sentence translation, pinyin controls, native human recordings, and integrated flashcards. [Du Chinese reader](https://duchinese.net/blog/2016/01/08/12-du-chinese-for-android-released/), [Du Chinese usage guide](https://duchinese.net/blog/2021/04/14/welcome-to-du-chinese/)

**Incorporate:**

- tap a word without leaving the reading flow
- dictionary result should be specific to the current word and context
- word audio should be immediately accessible when available
- a lookup should not require navigating to a separate dictionary application

**Important adaptation for the monolingual philosophy:**

The final product should not expose English translations as its default reading aid. The underlying dictionary infrastructure can contain lexical information, but learner-facing explanations should progressively use simple Chinese/context/visuals instead.

### 3.5 Borrow from Du Chinese: selective scaffolding controls

Du Chinese supports showing/hiding pinyin and a “difficult words only” mode that reveals pinyin selectively for harder vocabulary. It also supports listening through lessons as a continuous audio experience. [Du Chinese feature guide](https://duchinese.net/blog/2022/11/21/10-things-to-do-to-get-better-at-chinese/)

**Incorporate the underlying capability:**

- pinyin can exist as an internal/optional scaffold
- the app should be able to expose less or more phonetic support depending on stage
- beginner content can use much more explicit audio/phonology support

**Adapt:**

The learner should not have to constantly configure these controls. The product's progression should increasingly make scaffolding unnecessary.

A good future implementation may make pinyin availability a **stage-driven behavior** rather than a permanent user preference.

### 3.6 Borrow from Du Chinese: weak/partial recall in SRS

Du Chinese's flashcards explicitly allow a learner to distinguish “Forgot”, “Almost”, and “Got it”, including partial knowledge such as remembering meaning but forgetting pinyin. [Du Chinese flashcards](https://duchinese.net/blog/2024/09/30/the-best-way-to-use-flashcards-to-study-chinese/)

**Incorporate:**

For early Mandarin vocabulary, the SRS should be able to distinguish at least:

- clearly remembered
- partially remembered
- forgotten

This is particularly useful in the beginner stage because **meaning, Hanzi, sound, and tone can become dissociated**.

Later, sentence-based SRS can simplify the interaction and rely on a conventional scheduler underneath.

### 3.7 Borrow from The Chairman's Bao: integrated grammar and lexical notes attached to content

The Chairman's Bao combines graded reading with grammar explanations, keywords/idioms/proper nouns, native recordings, and automated flashcards. [TCB](https://www.thechairmansbao.com/)

**Incorporate later:**

- optional grammar explanations attached to the exact sentence/pattern where they matter
- special handling for idioms, proper nouns, and other lexical units that are not ordinary vocabulary words
- content-linked vocabulary notes

**Do not turn this into a grammar course.**

Grammar support should answer questions created by immersion rather than becoming a separate sequence of grammar lessons.

### 3.8 Borrow from Mandarin Companion: extreme lexical control + story quality

Mandarin Companion deliberately constrains character/vocabulary complexity while building full, enjoyable stories and emphasizes repeated encounters and extensive reading. [Mandarin Companion](https://mandarincompanion.com/why-graded-readers/)

**Incorporate:**

- strong editorial vocabulary budgets for early content
- deliberate recycling of important vocabulary across adjacent stories
- stories that are actually enjoyable, not artificial sentences wrapped in pictures
- long enough material to create repeated contextual exposure

This is a content-production requirement, not merely a front-end feature.

### 3.9 Borrow from Readibu: advanced transition to arbitrary Chinese

Readibu provides a native-content library, arbitrary website reading, EPUB/PDF/TXT import, simplified/traditional conversion, tracked words, bookmarks, resume-from-last-position, offline reading, sentence translation, quiz mode, and vocabulary export. [Readibu](https://www.readibu.com/)

**Incorporate later:**

- EPUB import
- local/offline reading
- resume exactly where the learner left off
- persistent personal library of imported texts
- simplified/traditional handling if the product eventually supports both
- vocabulary extraction from imported reading
- bookmarks / saved reading position

**Adapt:**

Readibu is fundamentally a reader/toolbox. Our product should treat import as the **advanced endpoint of the curriculum**, not as the starting point.

The user should not be dumped into an arbitrary book before the learner model says that native reading is appropriate.

### 3.10 Borrow from HelloChinese / SuperChinese selectively

HelloChinese demonstrates the effectiveness of structured Chinese-specific beginner instruction, native-speaker media, pronunciation work, character work, and tightly packaged micro-lessons. SuperChinese similarly combines structured progression, vocabulary/grammar teaching, and Chinese-specific practice.

**Incorporate only what solves the early bootstrapping problem:**

- polished first-contact experience
- tone discrimination
- audio/character recognition
- tiny atomic learning units before the learner can handle stories
- carefully sequenced beginner vocabulary

**Do not import their broader product model:**

- game-like progression
- broad skill-course dashboards
- speaking drills as a permanent core loop
- writing practice as a permanent core loop
- points/XP/achievement mechanics

This application is fundamentally a **reading-immersion product**, not an all-skills Chinese course.

### 3.11 Borrow from Anki/FSRS: mature scheduling, invisible complexity

Anki demonstrates that sophisticated scheduling can remain behind a simple review interface. Its filtered decks and scheduling are powerful without requiring the learner to understand the underlying machinery. [Anki Manual](https://docs.ankiweb.net/filtered-decks.html)

**Incorporate:**

- a mature spaced-repetition scheduler rather than inventing an unnecessarily exotic one
- due-card selection based on memory state
- strong separation between card data and scheduler implementation
- future ability to replace/improve the scheduling algorithm without changing card content

**Do not copy:**

- deck-management complexity
- manual card configuration as the default experience
- exposing intervals/algorithm settings to ordinary users

### 3.12 Concrete feature decisions from the market research

The following is the implementation decision list. Agents should use it as a sharper guide than “copy what competitors do.”

| Market feature | Decision | How it should appear here |
|---|---|---|
| Persistent known-vocabulary state | **ADOPT** | Shared learner-state service used by SRS + content selector |
| Content difficulty/comprehension analysis | **ADOPT** | Internal only; drives next-content choice |
| Automatic sentence mining | **ADOPT** | Candidate -> useful/recurring -> automatic SRS |
| Contextual word lookup | **ADOPT** | One-tap, local-first, stays inside reader |
| Rich sentence cards | **ADOPT** | Sentence + target + available native/visual context |
| Repetition-friendly mini-stories | **ADOPT** | Explicitly designed and surfaced for rereading |
| Strong early vocabulary constraints | **ADOPT** | Editorial/content metadata, mostly invisible to learner |
| Pinyin controls | **ADOPT, AUTOMATE** | Mostly stage-dependent; avoid settings clutter |
| Native story audio | **ADOPT, EARLY-STAGE** | Strong beginner/early-story support; not universal |
| Partial-recall SRS outcome | **ADOPT** | Especially important for tones/sound/Hanzi in beginner phase |
| Grammar explanations | **ADOPT LATER** | Contextual help, not a separate grammar curriculum |
| Idiom/proper-noun treatment | **ADOPT LATER** | Distinguish special lexical items from core vocab |
| EPUB/TXT/PDF import | **ADOPT LATER** | Advanced reading endpoint |
| Resume reading position | **ADOPT** | Always preserve reading position |
| Offline reading | **ADOPT** | Core architectural property |
| Podcast/native MP3 immersion | **ADOPT LATER** | Separate advanced listening modality |
| Comprehension percentage shown to user | **REJECT** | Internal selection signal only |
| Word-status colors / vocabulary heatmaps | **REJECT** | Violates zero-clutter philosophy |
| Manual lesson/course selection as main flow | **REJECT** | System chooses next content |
| Translation-first lookup | **REJECT** | Violates monolingual philosophy |
| Gamification / streaks / XP | **REJECT** | Not part of the product |
| Behavioral learning inference | **REJECT** | No surveillance or hidden nudging |

### 3.13 The key synthesis

The best ideas to borrow are not isolated UI widgets. They are **proven mechanisms**:

```text
Persistent vocabulary state       <- LingQ / Migaku
Content difficulty analysis       <- Migaku
Frictionless contextual mining    <- Migaku / Du Chinese
Contextual lookup                 <- Du Chinese
Repetition + lexical control      <- Du Chinese / Mandarin Companion
Grammar/lexical annotations       <- The Chairman's Bao
Advanced native-content import    <- Readibu / LingQ
Mature invisible SRS              <- Anki / FSRS
Beginner phonology scaffolding    <- HelloChinese / Chinese-specific apps
```

The product then recombines them around a different control model:

```text
Competitors often:

learner -> choose content -> inspect -> save -> review

This product:

learner state
      ↓
content engine selects next content
      ↓
learner reads
      ↓
automatic acquisition
      ↓
review system supports retention
      ↓
learner state improves
      ↓
content engine selects better next content
```

**The market research should make our implementation more sophisticated, not our UI more complicated.**

---

## 4. Learning Progression

The intended long-term path is approximately:

```text
Absolute beginner
        ↓
First vocabulary / sound mapping
        ↓
Controlled, visual-heavy material
        ↓
Curated micro-stories
        ↓
Children's stories / culturally important tales
        ↓
Longer native stories
        ↓
Adult native content
        ↓
Native books / literature / magazines / philosophy
        ↓
Imported EPUBs and arbitrary native text
```

This is not a rigid level taxonomy. The system should use learner state and content characteristics to decide what is appropriate.

---

## 5. Beginner Phase: First Vocabulary / First ~100 Words

The first phase exists to bootstrap the learner into Chinese.

The experience should be visual and audio-supported, with emphasis on connecting:

- concept / visual
- Hanzi
- native Mandarin sound
- tone

Example interaction concept:

```text
visual / concept
      ↓
native audio
      ↓
Hanzi
```

### Beginner testing

During this earliest stage, testing can be deliberately different from later SRS.

Examples:

- audio-first recognition
- picture → choose Hanzi
- hear a word + see a visual → identify the correct character
- tone discrimination
- basic recognition quizzes

The beginner review experience may therefore resemble the simplicity of recognition-focused language apps.

### Important boundary

This is a **general absolute-beginner phase**, not a special Japanese-to-Mandarin course.

---

## 6. Stories & Immersion Phase

After the initial bootstrap, the learner enters a curated sequence of visual-heavy, animated, native stories.

Early content should provide strong comprehension support through:

- high-quality illustrations
- animation where useful
- native narration
- short, understandable stories
- repeated vocabulary
- cultural relevance

The initial curriculum is intentionally more controlled than arbitrary native content.

### Re-reading is expected and encouraged

Stories are not disposable lessons.

A learner should be able to reread a story repeatedly.

Repeated reading is a feature of the pedagogy, not a failure of progression.

The product can explicitly encourage very high repetition in early stories; a learner may read the same children's story many times.

Previously finished stories should remain accessible.

---

## 7. Audio Philosophy

Audio is most important in the early learning journey and in early story content.

There is **no requirement that the entire application have synchronized sentence-level audio forever**.

The intended progression is:

```text
Beginner:
  strong native audio support

Early stories:
  native narration

More proficient reading:
  progressively less dependence on narration

Advanced native reading:
  text is primary
```

Later, native audio can return as a separate immersion modality, for example through:

- podcasts
- native MP3 content
- other real-world listening material

This does not need to be part of the initial architecture.

### Engineering implication

Treat audio as a capability of certain content types, not as a universal requirement on every text item.

Do not build the whole application around mandatory sentence-level audio synchronization.

---

## 8. Automatic Vocabulary Acquisition / Mining

A major feature is automatic vocabulary acquisition from reading rather than requiring the learner to manually maintain a deck.

When a learner encounters a word that is not known, the system can create a **candidate acquisition record**.

However:

> **Do not equate every unknown encounter with an immediate permanent flashcard.**

A candidate may later become an SRS item based on criteria such as:

- recurrence
- usefulness
- appropriateness for the learner's current stage
- importance to understanding the curriculum
- sufficient exposure

This avoids polluting the learner's review queue with arbitrary names, rare words, and incidental vocabulary.

### Example pipeline

```text
word encountered
      ↓
already known?
   /      \
yes       no
 |          ↓
continue   acquisition candidate
              ↓
      useful / recurring?
          /       \
        no        yes
        |           ↓
     ignore      SRS candidate
```

The exact thresholds can evolve.

The architecture should keep **candidate acquisition** distinct from **scheduled review**.

---

## 9. SRS / Review System

SRS is deliberately subordinate to immersion.

The system should automatically create and schedule review material without forcing the learner to become a deck manager.

### Beginner SRS

Early review can use simple recognition-heavy formats such as:

- picture → select Hanzi
- audio → select Hanzi
- visual → identify word
- tone discrimination

### Later SRS

After the beginner phase, the default should become closer to a normal sentence-based Anki-style card:

**Front:**

- full Chinese sentence
- target word emphasized/bolded
- relevant sentence audio when available

**Back:**

- target word
- Chinese definition when appropriate
- target-word audio / available audio support
- useful contextual information

Exact card design can evolve, but the fundamental principle stays:

> **Cards should emerge from immersion. They should not become the main product.**

### SRS UI

Keep scheduling machinery hidden.

Do not expose ordinary users to:

- intervals
- ease values
- algorithm settings
- deck limits
- card configuration
- complicated statistics

The app should simply know what should be reviewed.

---

## 10. Learner Model

The learner model is intentionally **not** a complete linguistic-state estimator.

It is primarily a **vocabulary / reading model** that helps answer the content-selection question.

### V1 approximation

A practical initial model can be built from:

- known Hanzi
- known vocabulary inferred from SRS state
- relevant exposure information

This is explicitly a **first-order approximation**, not a claim that vocabulary completely describes language ability.

### Future evolution

The model can become more sophisticated without changing the product philosophy.

Potential future evidence sources include:

- finished stories
- repeated story exposure
- repeated vocabulary occurrences in content
- long-term exposure history
- later, possibly grammar knowledge inferred from known/read structures
- other explicit learning records that are pedagogically justified

For example, repeated exposure to a vocabulary item across a story that has been reread many times may eventually contribute to a familiarity estimate.

### Privacy boundary

The learner model must **not** become a surveillance system.

Do not infer learning state from unrelated private behavior such as:

- hesitation time
- eye movement
- reading speed
- cursor behavior
- "engagement" signals
- compulsive usage patterns
- psychological profiling
- behavioral nudging

Only use learning data that is intentionally generated by the learning experience or clearly justified by the pedagogical model.

---

## 11. What "Language Skill" Means in the Initial System

For the first implementation, a useful approximation is:

> **Known vocabulary + Hanzi knowledge ≈ sufficient proxy for selecting the next Chinese text.**

This approximation should be treated as an extensible first version.

The system may later incorporate more information, but do not build a giant learner model before the core content-selection loop has proven itself.

---

## 12. The Central Engine: Content Selection

This is the technical and pedagogical heart of the project.

The system should continuously answer:

> **Given everything the learner knows, which piece of Chinese should come next?**

The learner should not have to answer this question.

### Content-selection inputs

At minimum:

- learner's known vocabulary / Hanzi state
- content lexical information
- content difficulty characteristics
- progression constraints
- curriculum ordering / prerequisites
- previously completed content

### Output

One appropriate next experience.

The selector is not simply a "level filter".

The goal is to find material that gives the learner an appropriate **i+1** experience.

---

## 13. i+1 Content Selection

Do not reduce i+1 to a simplistic:

```text
percentage of unknown words
```

The content-selection engine should be designed to become more intelligent over time.

Potential factors include:

- amount of known vocabulary
- amount of new vocabulary
- recurrence of new vocabulary
- usefulness of new vocabulary
- frequency / importance of unfamiliar words
- content prerequisites
- sentence complexity
- grammatical complexity
- curriculum position
- whether new vocabulary is concentrated or scattered

The system should conceptually optimize for:

> **high learning value at an appropriate comprehension/difficulty cost**

rather than blindly minimizing unknown-word percentage.

The exact scoring formula can evolve.

### Important architectural principle

Keep the content selector modular so the scoring algorithm can be improved independently from the reader UI and SRS implementation.

---

## 14. Content Data Model

Curated content should be represented as structured learning material rather than just a blob of text.

At a conceptual level:

```text
Content
 ├── metadata
 ├── title
 ├── stage / progression metadata
 ├── scenes / sections
 │    ├── text
 │    ├── visual assets
 │    └── optional audio
 ├── sentences
 │    ├── tokenized words
 │    └── learning metadata
 └── vocabulary references
```

The precise schema is an implementation decision, but it should support:

- unspaced Chinese text
- tokenized vocabulary
- story/section boundaries
- optional visuals
- optional audio
- content ordering
- difficulty metadata
- vocabulary reuse
- completion history
- editorial constraints / prerequisites used by the content selector

Content metadata is not secondary bookkeeping. It is part of the learning system: the selector cannot make intelligent decisions from raw text alone.

Do not force every content item to contain fields that only apply to beginner stories.

---

## 15. Tokenization & NLP

Chinese has no spaces, so the application needs reliable segmentation for:

- vocabulary lookup
- unknown/known classification
- content difficulty estimation
- sentence-level mining
- future i+1 selection

A lightweight embedded Chinese tokenizer is preferred for local/offline operation.

A C-based tokenizer such as Jieba exposed through Dart FFI is a valid implementation direction.

### Engineering principle

Tokenization should be treated as an infrastructure service used by multiple systems, not duplicated independently in:

- reader code
- dictionary code
- SRS code
- EPUB import code
- content selector

There should be a single authoritative tokenization pipeline and shared representations.

---

## 16. Local-First Architecture

The app should be designed for offline-first use.

Candidate local persistence technologies include:

- SQLite
- Isar

The specific choice can be made based on implementation constraints, but the architectural goal is:

> The core learning experience should not depend on a live backend or real-time AI API.

Persist locally:

- learner state
- known Hanzi
- vocabulary state
- exposure records needed for learning
- SRS state
- content completion state
- imported content metadata
- other local learning data

Avoid unnecessary server dependence.

### Local-first, not local-only

Local-first means the core loop never *depends* on a server. It does not mean
learner progress may only ever live on one device: browsers may evict local
web storage, and learners change phones or move between phone and desktop.
Progress must be portable. An optional, opt-in sync of explicit learning data
(known vocabulary, SRS state, completion, reading position — never behavioral
data, which is never collected at all) may exist later as a post-MVP
capability. It is a portability layer, not a dependency: the app stays fully
functional offline and local storage remains the source of truth (see
`DECISIONS.md` E-14).

---

## 17. Adaptive Local Dictionary

A local dictionary is useful, but it is **not an early priority**.

Do not prematurely build an elaborate real-time LLM dictionary system.

The eventual direction can include:

- Chinese-only definitions
- multiple definition complexity levels
- learner-aware simplification
- contextual examples
- previously encountered sentences containing the word

For example:

```text
ELI5 / very simple Chinese
        ↓
Standard Chinese definition
        ↓
Advanced / nuanced definition
```

The correct level can eventually be selected based on the learner's known vocabulary.

### Early-stage rule

Prefer a reliable, mostly local, curated solution over an overengineered AI definition pipeline.

Real-time LLM calls should not be required for ordinary reading.

---

## 18. EPUB / Native Content Import

EPUB import is a **later-stage capability**, not an MVP requirement.

The intended progression is:

```text
Curated beginner content
        ↓
Curated native stories
        ↓
Long native reading
        ↓
EPUB / arbitrary native content
```

When the feature exists, imported text should be processed locally through the same core vocabulary infrastructure:

```text
EPUB
 ↓
extract text
 ↓
segment Chinese
 ↓
map vocabulary
 ↓
compare against learner state
 ↓
make content progression / reading assistance possible
```

Do not turn EPUB import into a giant general-purpose document-management application.

Its purpose is to help an advanced learner transition into arbitrary native Chinese reading.

---

## 19. Future Native Audio / Podcast Immersion

Later in the learner journey, audio can become a separate immersion modality.

Potential future support:

- podcast MP3s
- native listening collections
- other long-form native audio

This belongs **after** the reading-centered system is working well.

Do not let future audio features distort the early reading-first architecture.

---

## 20. UI / UX Blueprint

### Beginner

The UI can be almost nonexistent.

The learner opens the app and receives the learning experience immediately.

Avoid a traditional dashboard.

### Developing learner

Small navigation affordances can gradually appear where they become useful.

Potential destinations:

- Review
- Previously finished stories
- Continue reading

### Advanced learner

The interface should increasingly resemble a reading application rather than a language-learning dashboard.

Potentially:

- Read
- Review
- Import

That is enough.

### UI rule

If a piece of UI exists only to expose internal system state, question whether it should exist at all.

The learner should generally not need to know:

- their exact i+1 score
- hidden difficulty values
- SRS intervals
- vocabulary counts
- algorithm decisions
- content-selection calculations

The system should do the work silently.

---

## 21. Explicit Non-Goals

The product is **not** intended to become:

- a gamified language app
- a streak tracker
- a points/XP system
- a social language app
- a flashcard-management tool with reading attached
- a bilingual translation app
- an LLM chatbot for practicing Chinese
- a dashboard-heavy progress tracker
- a behavioral-optimization system
- a surveillance-based adaptive tutor
- a giant multimedia platform from day one

Do not add a conventional feature simply because it is common in Duolingo, Anki, or another language-learning product.

---

## 22. Core System Architecture

The conceptual architecture should remain close to:

```text
                         ┌─────────────────────┐
                         │    Learner Model    │
                         │                     │
                         │ Known Hanzi         │
                         │ Known vocabulary    │
                         │ Exposure / history  │
                         │ SRS state           │
                         │ Overall reading     │
                         │ approximation       │
                         └──────────┬──────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ↓                               ↓
          ┌──────────────────┐            ┌──────────────────┐
          │ Content Selector │            │  Review System   │
          │                  │            │                  │
          │ What comes next? │            │ What to review?  │
          └────────┬─────────┘            └────────┬─────────┘
                   ↓                               ↓
                Content                           Card
                   │                               │
                   └──────────────┬────────────────┘
                                  ↓
                              Learner
```

Supporting infrastructure:

```text
Content Storage
    ↓
Tokenizer / NLP
    ↓
Vocabulary representation
    ↓
Learner state

Reader / Beginner Experience
    ↓
Acquisition candidate creation
    ↓
SRS

EPUB Import (later)
    ↓
Same tokenizer + vocabulary pipeline
```

### Separation of responsibilities

The **Content Selector** and **Review System** are separate subsystems.

Their questions are different:

> Content Selector: **What new material should come next?**

> Review System: **What previously acquired material should be reviewed now?**

They share learner/vocabulary data, but they should not become one tangled subsystem.

---

## 23. Recommended MVP Scope

The first implementation should prove the central loop, not build the entire vision.

### MVP should contain

1. Flutter application shell
2. Local persistence
3. Beginner first-vocabulary experience
4. Native audio + visuals for beginner material
5. Basic tone / recognition testing
6. A small curated story corpus
7. Chinese segmentation/tokenization
8. Known vocabulary state
9. Automatic acquisition candidates
10. Basic sentence-based SRS after the beginner phase
11. Basic content-selection engine
12. Automatic selection of the next appropriate content item
13. Re-reading of completed stories

### MVP should NOT require

- adaptive LLM dictionary
- EPUB importing
- podcast support
- advanced grammar modeling
- sophisticated behavioral inference
- giant analytics system
- complicated account/server architecture
- extensive settings UI
- broad social features

The MVP succeeds if it proves this:

> **A learner can open the app and be continuously guided through progressively more appropriate Chinese without managing the curriculum themselves.**

---

## 24. Development Priorities

Work in this order unless there is a strong technical reason not to:

### Priority 1 — Core learning state

Implement reliable representations for:

- Hanzi
- segmented vocabulary
- known vocabulary
- exposure
- SRS state
- content completion

### Priority 2 — Content representation

Create a clean content model that supports the progression from:

- beginner visual/audio material
- stories
- long text
- eventual EPUB

without forcing every content type to share identical media requirements.

### Priority 3 — Content selection

Build the first useful i+1 selection algorithm.

Start simple, but make it replaceable.

### Priority 4 — Reading / story experience

Build the smallest interface necessary to consume the selected content.

### Priority 5 — Acquisition + SRS

Automatically turn useful unknown encounters into review material.

### Priority 6 — Progressive refinement

Only after the core loop works well, improve:

- selection quality
- learner model quality
- dictionary quality
- story progression
- advanced reading
- import
- additional immersion modalities

---

## 25. Programming & Agent Rules

These are product-specific engineering practices, not generic style rules.

### 25.1 Protect the conceptual boundaries

Keep these components distinct:

- Learner Model
- Content Selector
- Reader
- Acquisition pipeline
- Review/SRS
- Tokenizer
- Dictionary
- Importer

Avoid letting UI widgets contain learner-model logic or content-selection algorithms.

Agents should prefer clear domain services/models over scattering learning logic through screens.

### 25.2 Make the content selector replaceable

The i+1 algorithm will evolve.

Do not hard-code selection formulas throughout the reader or database layer.

Expose a clear boundary such as:

```text
LearnerState + CandidateContent[]
              ↓
        ContentSelector
              ↓
       SelectedContent
```

This allows future selection algorithms to improve without rewriting the app.

### 25.3 Treat vocabulary state as shared infrastructure

There must be one coherent definition of:

- what a vocabulary item is
- how Hanzi is represented
- how segmentation results are represented
- how "known" is represented
- how exposure is represented

Avoid separate incompatible representations in the dictionary, reader, SRS, and EPUB importer.

### 25.4 Do not leak implementation details into pedagogy

The learner should not see internal values simply because they exist in the database.

Examples that should stay internal:

- i+1 scores
- confidence values
- SRS interval values
- candidate rankings
- tokenization diagnostics
- learner-model internals

### 25.5 Prefer deterministic, local behavior for core learning decisions

The basic reading experience should work offline and predictably.

Do not make real-time network calls a hidden dependency for:

- opening a story
- looking up core vocabulary
- determining known words
- normal SRS behavior
- selecting existing curated content

### 25.6 Keep data-driven curriculum separate from UI code

Stories, vocabulary metadata, progression rules, and selection metadata should live in data/content layers, not be encoded as giant conditional statements inside Flutter widgets.

This matters because the curriculum will change much more often than the UI architecture.

### 25.7 Build for content evolution

Do not assume all future content has:

- animation
- audio
- illustrations
- sentence recordings

Media should be optional capabilities of content, not mandatory assumptions.

### 25.8 Do not overengineer future learner intelligence

A simple first-order vocabulary model is acceptable.

Do not block MVP development waiting for:

- perfect grammar inference
- perfect familiarity estimation
- perfect comprehension modeling
- perfect i+1 scoring

The architecture should permit these later without requiring them now.

### 25.9 Avoid hidden "smart" behavior

Do not implement behavioral inference, nudging, or engagement optimization behind the learner's back.

Any adaptation should be explainable as a consequence of explicit learning/content data.

### 25.10 Optimize for the actual loop

When deciding between two engineering approaches, prefer the one that improves:

```text
learner state
    ↓
content selection
    ↓
immersion
    ↓
vocabulary acquisition
    ↓
review
    ↓
better future content
```

A technically impressive feature that does not improve this loop is likely not a priority.

---

## 26. Testing Strategy Tailored to This Product

Agents should test more than isolated UI behavior.

### Learner-state tests

Verify that repeated and different types of exposure update learner state consistently.

### Content-selection tests

Create synthetic learner states and candidate story sets and verify that the selector chooses sensible next content.

Example cases should include:

- beginner with almost no vocabulary
- learner who knows most common beginner words
- learner who has just acquired a specific vocabulary cluster
- learner returning to old content
- candidate content with many rare irrelevant words
- candidate content with fewer but highly recurring new words

### Regression tests for curriculum drift

When improving the selector, preserve known-good progression cases.

A scoring tweak must not silently turn a sensible sequence into a chaotic one.

### Tokenization consistency tests

The same Chinese text must produce consistent vocabulary representations across:

- reader
- SRS mining
- dictionary lookup
- content selection
- EPUB import

### Privacy tests

Make sure no hidden behavioral telemetry or unauthorized learner profiling gets introduced as an "optimization."

### Content-data regression tests

Curated content is effectively part of the product's algorithm. Changes to tokenization, vocabulary metadata, or selection heuristics must not silently make previously appropriate stories inappropriate. Keep representative content sequences as regression fixtures.

---

## 27. Agent Decision Framework

When an agent is uncertain about an implementation, use this order:

1. **Does it preserve the product philosophy?**
2. **Does it improve the core immersion → acquisition → review → next-content loop?**
3. **Can it remain invisible to the learner if it is not necessary?**
4. **Can it remain local/offline?**
5. **Does it keep the content selector and review system cleanly separated?**
6. **Does it avoid premature complexity?**
7. **Can it evolve later without forcing a rewrite?**

If a proposed feature conflicts with the philosophy, the philosophy wins.

---

## 28. What Agents Must Not Do Without a Strong Product Reason

Do not spontaneously add:

- XP systems
- streaks
- achievement systems
- social features
- leaderboards
- daily goals
- excessive onboarding
- lesson menus
- course catalogs
- translation popups
- bilingual explanations
- intrusive notifications
- behavioral engagement loops
- hidden comprehension surveillance
- unnecessary cloud dependencies
- permanent dependence on audio
- complicated settings for ordinary users
- dashboards exposing internal algorithm state

Do not turn the application into a clone of a mainstream language-learning app.

---

## 29. Long-Term Vision

The mature application should feel fundamentally different depending on when the learner encountered it.

### At the beginning

The app does almost everything:

- chooses the material
- provides visual support
- provides native audio
- tests basic recognition
- introduces the first vocabulary
- handles review

### In the middle

The learner mostly reads stories.

The app quietly:

- tracks known vocabulary
- mines useful new words
- schedules review
- chooses what comes next
- gradually removes scaffolding

### At the advanced stage

The learner primarily reads Chinese.

The app becomes a minimal tool around:

- native reading
- occasional review
- discovering the next appropriate material
- importing personal/native content

The application is increasingly **a bridge to Chinese itself**, rather than a destination.

---

## 30. The Core Principles — Keep These Visible to Every Agent

> **Given everything the learner knows, which piece of Chinese should come next?**

> **The learner chooses almost nothing; the system chooses the next appropriate content.**

> **Scaffolding should decay automatically.**

> **Almost everything is acquired through meaningful content.**

> **SRS exists to support immersion, not replace it.**

> **Start with a simple learner model; make it more intelligent over time.**

> **Do not turn the learner model into surveillance.**

> **Keep content selection and review scheduling separate.**

> **The interface should become less important as the learner becomes more capable.**

> **The ultimate goal of the application is to make itself less necessary.**

---

## 31. Final Agent Instruction

Before implementing a feature, ask:

> **Does this help the system get the learner to the right Chinese content at the right time, with the least unnecessary friction?**

If yes, implement it in the simplest architecture that preserves future evolution.

If no, question whether the feature belongs in the product at all.

When in doubt, choose **less UI, less configuration, less friction, more native Chinese, and a cleaner automated progression**.

The product should feel less like a course platform and more like a **guided path into Chinese itself**.
