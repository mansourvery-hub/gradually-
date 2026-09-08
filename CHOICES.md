# Design & Editorial Choices (`CHOICES.md`)

This document records the exact numerical, algorithmic, editorial, and asset pipeline choices for **渐入**.

---

## 1. Pedagogical & Numerical Parameters

| Parameter | Value | Rationale | Status |
|---|---|---|---|
| **Bootstrap Target Lexicon Size** | **100 – 150 Hanzi / Words** | Determined backwards from the first 5–10 short stories. Enough to achieve high reading flow on initial stories. | `[CONFIRMED]` |
| **Pure Exposure Target Multiplier** | **4 – 6× encounters per word** | ~600 total exposures before any recall testing or SRS begins. | `[CONFIRMED]` |
| **Pure Exposure Phase Threshold** | **Total exposures $\ge 500$** | Pure exposure mode remains active until total accumulated exposures pass this threshold. | `[CONFIRMED]` |
| **Beginner Card Repetitions** | **Distributed across contexts** | Words are shown in isolation, in pairs, and in short micro-contexts across multiple rounds. | `[CONFIRMED]` |
| **SRS Gate** | **Deferred post-exposure** | No SRS review occurs during the pure exposure phase ($0 \rightarrow 100$ words). Cards emerge only from stories read after exposure. | `[CONFIRMED]` |

---

## 2. Editorial & Story Choices (Target-Led Design)

> **Core Rule:** Beginner vocabulary is **not** chosen from arbitrary frequency lists (like HSK 1). It is derived by **backward design** from the target short stories.

### A. First Micro-Story Corpus (Stories 1–3)
1. **Story 1: 《喝茶》 (Drinking Tea)**
   - *Target Lexicon:* `我, 想, 喝, 茶, 水, 吃, 饭, 也, 好, 不, 要`
   - *Bootstrap Units Needed:* Introduce each concept with visual + native sound + Hanzi + tone mark.
2. **Story 2: 《大猫和小猫》 (The Big Cat and Little Cat)**
   - *Target Lexicon:* `大, 小, 猫, 看, 见, 跑, 有, 这, 那`
3. **Story 3: 《今天下雨》 (It's Raining Today)**
   - *Target Lexicon:* `天, 雨, 家, 去, 走, 伞, 朋友`

---

## 3. Asset Sourcing & Production Pipelines

### A. Audio Pipeline (`T05_AUDIO_ASSET_PIPELINE`)
- **Format:** Clean mono MP3/OGG (128 kbps), normalized volume.
- **Sources / Tooling:**
  1. *Curated Native Recordings:* Clean short recordings for core Hanzi pronunciations (tone-accurate).
  2. *High-Quality Offline TTS Pre-generation:* Pre-rendered at build time with natural neural Mandarin voice (e.g. edge-tts / Piper / Kokoro) — never generated at runtime ($E\text{-}01, E\text{-}12$).

### B. Visual Illustration Pipeline (`T06_VISUAL_ASSET_PIPELINE`)
- **Aesthetic:** Minimalist, warm paper tone, ink/woodblock inspired or clean vector SVG.
- **Palette:** Warm white/cream canvas (`#FBF9F5`, `#F5EFEB`), charcoal ink (`#242424`, `#3A3A3A`), subtle accent hues.
- **Placeholder Strategy:** Clean, consistent geometric icons while illustration sets are drawn.

---

## 4. Testing & Dev Level Injection (`T10_LEVEL_INJECTION_HOOK`)

To allow instant testing of any point in the learning journey without manual tapping:

```bash
# Level 0: Pure Beginner (0 exposures, 0 known words, pure exposure mode active)
fvm flutter run -d chrome --dart-define=LEVEL=0

# Level 25: Halfway through pure exposure (~300 exposures, 50 words encountered)
fvm flutter run -d chrome --dart-define=LEVEL=25

# Level 50: Exposure phase complete (~600 exposures, ready for Story 1, SRS unlocked)
fvm flutter run -d chrome --dart-define=LEVEL=50

# Level 100: Mastery of entire corpus (all stories read, native reading mode)
fvm flutter run -d chrome --dart-define=LEVEL=100
```
