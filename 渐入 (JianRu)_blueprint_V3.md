# 渐入 (JianRu) — Knowledgeable Story Blueprint V3

> **Status:** Conceptual blueprint / human-facing product vision  
> **Purpose:** Define JianRu's updated "living story" content architecture: a learner-adaptive path from near-zero Chinese toward a canonical Chinese literary work.

---

# 1. The Core Product Idea

JianRu should not primarily be a collection of graded stories.

Its distinctive content unit is a **living story**.

A learner starts with almost nothing:

> 人

Then:

> 人向山去。

Then:

> 一个人向山里走。  
> 他没有回头。  
> 山很高。  
> 天快黑了。

Later, the same work can become:

- linguistically richer
- narratively wider
- more detailed
- more culturally grounded
- more emotionally and philosophically complex
- told from another meaningful perspective
- expanded backward or forward in time
- expanded sideways into an already-important subplot
- increasingly literary

The learner does not leave the story behind.

**The story grows with the learner.**

The long-term destination is ideally a **real, culturally significant work of Chinese literature**, or a bounded narrative arc from such a work.

That canonical work is the **Mother Story**.

JianRu provides the path into it.

---

# 2. The Mother Story

A Mother Story is the underlying literary work whose world, characters, events, relationships, themes, and meaning anchor the entire JianRu progression.

Examples could eventually come from major Chinese literary traditions and works such as:

- classical novels
- major literary narratives
- famous historical anecdotes
- important traditional tales
- culturally significant literary works

The exact source is an editorial choice.

The important property is:

> **The destination already has genuine literary and cultural substance.**

JianRu therefore does not have to invent a fake "Chinese-feeling" masterpiece merely to give learners something meaningful to read.

The Mother Story provides the deep destination.

JianRu provides the path into it.

---

# 3. The Central Learning Loop

The most important product mechanism is:

> **Given the learner's current Chinese ability, measured primarily through SRS-derived evidence, and the portfolio of stories and narrative material the learner has already encountered, generate the next meaningful slice/version of the Mother Story.**

Conceptually:

```text
                 MOTHER STORY
          canonical world + meaning
                      │
                      ▼
             available story space
                      │
                      ×
                      │
          ┌───────────┴───────────┐
          │                       │
   learner SRS state       narrative portfolio
   -----------------       -------------------
   known Hanzi             stories already read
   known words             events already seen
   mastery/familiarity     characters introduced
   recent exposure         relationships understood
   known constructions     perspectives encountered
   etc.                    narrative context
          │                       │
          └───────────┬───────────┘
                      ▼
              NEXT STORY REALIZATION
                      │
                      ▼
             learner reads it
                      │
                      ▼
             SRS / story state updates
                      │
                      └──────→ next iteration
```

This is the heart of JianRu.

The system is not simply asking:

> "What harder story should I show next?"

It is asking:

> **"What is the next part of this particular great story that this particular learner is ready to enter?"**

---

# 4. Two Kinds of Learner State

The generation process needs two distinct views of the learner.

## 4.1 Linguistic State

This comes from SRS-related evidence.

Examples:

- Hanzi mastery
- word mastery
- frequency of recent exposure
- retention / familiarity
- known constructions
- approximate vocabulary breadth
- tolerated amount of novelty

This answers:

> **What Chinese can this learner probably process comfortably?**

It does not need to reduce the learner to a single crude "level number."

A richer learner profile is preferable.

---

## 4.2 Narrative State

The learner also has a growing **narrative portfolio**.

This records what the learner has already encountered through JianRu stories.

Examples:

- characters already known
- relationships already established
- locations already familiar
- events already encountered
- historical periods already introduced
- narrative threads already opened
- prior perspectives
- information the learner has already been shown
- interpretations the learner has already been exposed to

This answers:

> **What does the learner already understand about this story-world?**

A learner may be linguistically capable of reading something but narratively unprepared for it.

Conversely, a learner may know the relevant Chinese but benefit more from continuing a familiar narrative thread than from beginning a completely new one.

The two states therefore interact.

---

# 5. The Next Iteration Is Not an "Easy Version of the Next Chapter"

The generated material can advance toward the Mother Story in several ways.

The LLM may choose one or several dimensions simultaneously.

## Linguistic expansion

Use richer Chinese while preserving naturalness:

- better vocabulary
- more precise vocabulary
- richer grammar
- idioms
- discourse structures
- more natural collocations
- figurative or literary language

## Same event, deeper rendering

The same underlying event can be described with more detail.

Early:

> 他回家了。

Later:

> 为什么回家、他一路看见什么、家里谁在等他、他记起了什么、回家后发生什么。

## New meaningful thread

The learner may move temporarily away from the protagonist to an existing thread that is genuinely relevant to the Mother Story:

- a family member
- an antagonist
- a servant
- a friend
- another participant in the central conflict
- a simultaneous event elsewhere

The side thread must matter.

## Different perspective

A later iteration may show the same world through another legitimate viewpoint.

Examples:

- protagonist
- daughter
- father
- antagonist
- witness
- historical observer
- later descendant

The purpose is not to generate novelty for its own sake.

The purpose is to reveal another dimension of the work.

## Different time scale

The story can expand:

- later that day
- earlier that day
- years earlier
- twenty years earlier
- another generation
- years later

The new period should illuminate the Mother Story.

## New information that was previously outside the narrative window

Something can be revealed simply because the learner is now capable of understanding it.

For example:

> the earlier narrative never explained what happened to the butler

A later iteration can tell the butler's story.

That is not a retcon if the event was always compatible with the Mother Story.

## Cultural or literary depth

As the learner advances, the story can naturally introduce:

- idioms
- allusions
- social conventions
- historically situated assumptions
- indirect ways of communicating
- culturally meaningful symbolism
- literary motifs
- deeper moral ambiguity

These should emerge through the story itself rather than being explained as lessons.

---

# 6. The Invariant: The Mother Story's Meaning

The exact wording does not need to remain constant.

The exact sequence of scenes does not always need to remain constant.

A particular iteration does not even need to show the same semantic slice as the previous one.

What must remain stable is the **identity and integrity of the work**.

The learner should be able to move from:

> 人向山去。

to a much later, much richer narrative and feel:

> **"This is the same work I began reading."**

The early version may have shown only one small aspect of the whole.

The later version may change how the learner understands it.

That is desirable.

But it should not casually make the earlier material false.

---

# 7. Progressive Understanding, Not Mystery-Box Storytelling

JianRu should not depend on:

> "You thought X happened. Surprise! X was false."

The learner is not being asked to race toward a twist.

The intended experience is:

> **partial understanding → contextual understanding → richer interpretation**

A later iteration may reveal something that changes the *meaning* of an earlier event.

It should normally do so by adding context, perspective, history, or consequences.

The learner should think:

> "Now I see what that meant."

rather than:

> "The author tricked me."

Advanced unreliable narration can eventually exist inside genuinely appropriate literary works, but it should be treated as a property of the source work, not as JianRu's default progression mechanism.

---

# 8. The Iterations Are Not Rewrites

A crucial product property is that the story grows primarily through **new material**.

It is not an autocomplete system.

It is not:

> same sentence → harder synonym → another harder sentence

And it is not:

> rewrite yesterday's four sentences using five more advanced words.

Instead:

```text
L0
  人

L1
  人向山去。

L2
  tiny complete narrative

L3
  + meaningful detail

L4
  + another connected event

L5
  + relevant side thread

L6
  + different perspective

L7
  + earlier/later context

L8
  + richer language

...
```

The old material remains part of the learner's accessible story history.

The new version adds another meaningful window onto the same work.

The learner can therefore watch the story **grow**, rather than repeatedly watching it get paraphrased.

---

# 9. "One Story" Does Not Mean "One Continuous Camera"

The underlying Mother Story may contain:

- many characters
- many places
- several timelines
- multiple simultaneous events
- competing viewpoints
- historical background
- side plots

Therefore a story iteration can legitimately leave the current protagonist.

For example:

```text
Iteration 1:
  protagonist walks toward mountain

Iteration 2:
  same journey, more detail

Iteration 3:
  what the protagonist's mother was doing that morning

Iteration 4:
  twenty years earlier, when the father first visited the mountain

Iteration 5:
  the antagonist's actions during the same afternoon

Iteration 6:
  return to the protagonist

Iteration 7:
  the consequence of that afternoon years later
```

These are not unrelated stories.

They are different narrative views of the same Mother Story.

---

# 10. The Story Manifold

"Story manifold" is useful as a mental model, not necessarily as a literal software object.

Imagine the Mother Story as a large space of:

- events
- people
- places
- time
- relationships
- causes
- consequences
- perspectives
- meanings

A narrative iteration is a path through that space.

```text
                         MOTHER STORY
                  ┌─────────────────────┐
                  │   ●────●────●       │
                  │  /      │     \\      │
                  │ ●       ●      ●     │
                  │ │      / \\     │     │
                  │ ●─────●───●────●     │
                  │       │              │
                  │   ●───●───●          │
                  └─────────────────────┘
                         ▲
                         │
                    current view
```

A later learner state permits a broader, deeper, or different traversal.

The important constraint is:

> **The traversal must remain anchored to the Mother Story.**

An interesting tangent is not automatically a useful JianRu story.

---

# 11. The World / Event Graph

The world graph remains useful, but it exists to support the narrative system rather than replace it.

It should capture the story-bearing reality of the Mother Story:

- actors
- places
- objects
- relationships
- events
- time
- causes
- consequences
- character knowledge
- character beliefs
- important historical context

Example:

```text
Grandfather leaves village
        ↓
Father forms a belief
        ↓
Daughter grows up under that belief
        ↓
Present protagonist makes a decision
        ↓
Journey to mountain
        ↓
Encounter
        ↓
Later consequence
```

This graph allows JianRu to find legitimate narrative connections across time and perspective.

It does not need to be an exhaustive simulation of every trivial action in the fictional universe.

---

# 12. Build the World from a Canonical Work

The preferred construction direction is now:

```text
Canonical Mother Story
        ↓
rough understanding of its meaning
        ↓
causal world skeleton
        ↓
world / event graph
        ↓
substantial narrative representation
        ↓
refine missing world relationships where needed
        ↓
identify meaningful narrative threads
        ↓
derive JianRu iterations backward from learner accessibility
```

This is preferable to inventing a gigantic world first.

The canonical work already provides the artistic center.

The structured world representation simply makes that center usable for adaptive generation.

---

# 13. The Role of the Long Narrative

The long narrative is useful as a reference representation of the Mother Story.

It helps preserve:

- characters
- relationships
- plot
- chronology
- themes
- recurring motifs
- important details
- cultural context
- literary structure

But JianRu should not simply generate:

> "the full final story"

and then mechanically chop it into levels.

The long version is a **source/reference for generation**.

The actual learner experience is generated from the intersection of:

> Mother Story + story-world + learner linguistic state + learner narrative portfolio.

---

# 14. The i+1 Constraint

The language of each new iteration should remain close to the learner's current ability.

The ideal reading experience is:

> **a sea of known language containing a small amount of useful new language.**

New vocabulary should appear because it is:

- natural in the story
- useful later
- repeated or contextualized
- necessary for a meaningful narrative expansion
- appropriate for the learner's current linguistic state

Avoid:

> "We need ten new words, so let's add ten new words."

Prefer:

> "This part of the Mother Story is now accessible; these few new words are the natural language needed to tell it."

The target is not a mathematically exact i+1 score.

It is a **strong approximation of effortless contextual acquisition**.

---

# 15. The Learner's SRS Drives Language, Not the Story's Meaning

This hierarchy matters.

The Mother Story decides:

> **what is worth saying.**

The learner's SRS state helps decide:

> **how it can be said now.**

The narrative portfolio decides:

> **what the learner is ready to understand next within the story.**

Therefore:

```text
Mother Story
   ↓
what matters
   ↓
Narrative selection
   ↓
what should be shown next
   ↓
Learner linguistic state
   ↓
how it can be expressed now
```

This prevents the content system from corrupting a good story merely to satisfy a vocabulary target.

---

# 16. No Irrelevant Tangents

Every addition should serve the Mother Story.

Suppose the protagonist encounters a fisherman.

If the fisherman:

- causes an important event
- reveals an important relationship
- embodies a relevant theme
- participates in a meaningful cultural or historical context
- becomes important later

then a fisherman thread may be worthwhile.

If the fisherman merely sells fish and disappears forever:

> **Do not build a fisherman subplot just because it is an interesting way to introduce 鱼.**

Likewise, do not add:

- random travel
- decorative scenery
- arbitrary conversations
- unrelated characters
- unnecessary animals
- vocabulary-farming scenes

The story is not a container into which words are poured.

**Language serves narrative; narrative serves the Mother Story.**

---

# 17. Cultural Depth Must Be Emergent

The ultimate ambition is not:

> "Put the learner in China."

Nor:

> "Insert explicit Chinese philosophy lessons."

A successful Mother Story should naturally expose aspects of Chinese literary and cultural traditions through:

- what people value
- what they consider shameful or honorable
- how obligations operate
- how generations relate
- how people speak indirectly
- what remains unsaid
- social hierarchy
- reputation
- ritual
- reciprocity
- attitudes toward nature
- historical memory
- culturally embedded taboos
- idiomatic expression
- literary allusion
- tensions between competing values

The learner should gradually infer these patterns.

The story should not announce:

> "The Chinese lesson is..."

The cultural meaning should live inside the characters, relationships, choices, language, institutions, and consequences.

At the same time, JianRu should not pretend that "Chinese culture" is one indivisible worldview. Chinese literary traditions are internally diverse and can disagree with one another.

---

# 18. The Catalogue of Iterations

Every generated iteration should remain available.

Conceptually:

```text
Mother Story
 ├── L0
 ├── L1
 ├── L2
 ├── L3
 ├── L4
 ├── L5
 └── ...
```

This allows the learner to:

- revisit an earlier version
- compare expressions
- review an easier narrative
- see their own progress
- reconnect with earlier context
- recover a simpler route into a difficult passage

Earlier versions therefore become part of the learner's long-term relationship with the work.

---

# 19. Generation Should Be Constrained, Not One Giant Prompt

The system should conceptually separate:

### Source truth

What the Mother Story actually establishes.

### World structure

How events, people, relationships, and timelines connect.

### Learner state

What Chinese the learner can likely handle.

### Narrative portfolio

What this learner has already seen.

### Generation

What meaningful material should become visible now, and how should it be expressed?

The LLM's role is therefore not:

> "Write a story."

It is:

> **"Select and realize the next pedagogically valuable narrative window into an existing work."**

This distinction should strongly shape the eventual implementation.

---

# 20. What a Generation Request Means

A future generation call can be thought of as:

```text
INPUT

Mother Story
+ structured world / event knowledge
+ current SRS-derived Chinese profile
+ learner's existing story portfolio
+ current iteration
+ prior narrative context

        ↓

LLM

Choose the next meaningful narrative expansion.

Possible changes:
- richer language
- a few new words
- greater detail
- another existing thread
- another perspective
- another time period
- previously unseen but canon-compatible information
- greater literary/cultural depth

Constraints:
- i+1-like linguistic difficulty
- natural Chinese
- no word-list padding
- no irrelevant tangent
- no contradiction
- no cheap mystery-box reversal
- preserve the identity and meaning of the Mother Story
- build on what the learner already knows narratively

        ↓

OUTPUT

The next JianRu story iteration
+ metadata describing what new narrative/language territory it introduced
```

The metadata is useful for the system, but the learner should experience the result simply as **the story continuing to open**.

---

# 21. The Ultimate Progression

A possible long trajectory:

```text
L0
  one Hanzi / concept

L1
  one simple sentence

L2
  tiny self-contained story

L3
  same event + meaningful detail

L4
  connected event

L5
  additional character

L6
  meaningful side thread

L7
  another perspective

L8
  earlier/later event

L9
  richer relationships

L10
  more natural modern Mandarin

L11
  idioms / culturally meaningful language

L12
  literary texture

...

Advanced
  substantial adaptation of a major narrative

Highest
  close engagement with the canonical work itself,
  where appropriate
```

There is no requirement that every Mother Story use exactly these levels.

The progression should emerge from the work and the learner.

---

# 22. The Deep Product Thesis

The ordinary conception is:

> "Learn Chinese by reading progressively harder stories."

The JianRu conception is:

> **Enter a great Chinese story before you are ready for it, and let your growing Chinese make more and more of that story visible.**

At the beginning, the learner knows almost nothing.

Eventually they can understand:

- the events
- the people
- the relationships
- the history
- the social world
- the different perspectives
- the idioms
- the literary devices
- the cultural assumptions
- the deeper tensions
- the philosophical implications

The learner does not merely finish a graded reader.

They experience:

> **a work of Chinese literature becoming fully legible to them.**

That is the central vision of JianRu's expandable-story system.

---

# 23. Non-Negotiable Editorial Principles

1. **One Mother Story, many learner-accessible realizations.**

2. **The learner's SRS state influences linguistic realization.**

3. **The learner's narrative portfolio influences narrative selection.**

4. **The Mother Story determines what is worth telling.**

5. **The world graph supports narrative continuity but does not replace literary judgment.**

6. **New material must serve the parent work.**

7. **No arbitrary vocabulary-farming scenes.**

8. **No fake mystery-box progression.**

9. **Later material may deepen or reinterpret earlier material without casually making it false.**

10. **The story grows primarily through meaningful new material, not repeated paraphrasing.**

11. **A different perspective is valuable only when the perspective itself enriches the Mother Story.**

12. **Time jumps are valuable when they illuminate the work.**

13. **Cultural meaning should emerge from lived narrative rather than explicit lectures.**

14. **The linguistic target is approximately i+1: mostly known language with a small amount of useful novelty.**

15. **Do not force a fixed number of iterations. Let the richness of the work and the learner determine the progression.**

16. **Earlier iterations remain available for reference.**

17. **The canonical work is the artistic and narrative anchor; AI is the adaptive access mechanism, not the author of the Mother Story.**

---

# 24. Working Definition

> **JianRu's expandable-story system is a learner-adaptive narrative architecture in which a canonical Chinese Mother Story is progressively opened to the learner through a sequence of meaningful narrative realizations. Each new realization is generated from the learner's SRS-derived linguistic state and their existing narrative portfolio, while remaining faithful to the Mother Story and its underlying world. Progression may occur through richer language, limited new vocabulary, additional detail, new information, connected side threads, different perspectives, different time scales, and increasing cultural and literary depth. The learner does not solve a hidden mystery or repeatedly read paraphrases of the same text; instead, the same work becomes progressively more comprehensible, more complete, and more meaningful as the learner's Chinese grows.**
