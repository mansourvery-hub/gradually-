# Design & Editorial Choices (`CHOICES.md`)

This document records the exact numerical, algorithmic, editorial, and asset pipeline choices for **渐入**.

---

## 1. Pedagogical & Numerical Parameters

| Parameter | Value | Rationale | Status |
|---|---|---|---|
| **Bootstrap Target Lexicon Size** | **100 – 150 Hanzi / Words** | Determined backwards from the first 5–10 short stories. Enough to achieve high reading flow on initial stories. | `[CONFIRMED]` |
| **Pure Exposure Target Multiplier** | **4 – 6× encounters per word** | ~600 total exposures before any recall testing or SRS begins. | `[CONFIRMED]` |
| **Pure Exposure Phase Threshold** | **Total exposures $\ge 500$** | Pure exposure mode remains active until total accumulated exposures pass this threshold. | `[CONFIRMED]` |
| **Data-Driven Dynamic Generation** | **100% data-driven** | Exposure sequence is generated dynamically from `bootstrap_target_lexicon.json` without hardcoded code changes. | `[CONFIRMED]` |
| **Beginner Card Repetitions** | **Distributed across contexts** | Words are shown in isolation, in pairs, and in short micro-contexts across multiple rounds. | `[CONFIRMED]` |
| **SRS Gate** | **Deferred post-exposure** | No SRS review occurs during the pure exposure phase ($0 \rightarrow 100$ words). Cards emerge only from stories read after exposure. | `[CONFIRMED]` |

---

## 2. Editorial & Story Choices (Target-Led Design)

> **Core Rule:** Beginner vocabulary is **not** chosen from arbitrary frequency lists (like HSK 1). It is derived by **backward design** from the target short stories.

### A. Approved Target Stories (Stories 1–3)
1. **Story 1: 《喝茶与米饭》 (Drinking Tea & Eating Rice)**
   - *Source File:* `assets/content/stories/story_001_source.txt`
   - *Pre-tokenized File:* `assets/content/story_001_drink_tea.json`
   - *Target Lexicon:* `我, 想, 喝, 水, 也, 茶, 我们, 一起, 吃, 米饭, 很, 好喝, 好吃`
2. **Story 2: 《大猫与小猫》 (Big Cat & Little Cat)**
   - *Source File:* `assets/content/stories/story_002_source.txt`
   - *Pre-tokenized File:* `assets/content/story_002_cats.json`
   - *Target Lexicon:* `这里, 有, 一, 只, 大, 猫, 和, 小, 看, 要, 鱼, 它们, 是, 朋友, 天天, 在, 跑`
3. **Story 3: 《今天下雨》 (It's Raining Today)**
   - *Source File:* `assets/content/stories/story_003_source.txt`
   - *Pre-tokenized File:* `assets/content/story_003_rainy_day.json`
   - *Target Lexicon:* `今天, 天气, 不, 好, 下雨, 了, 家, 里, 书, 热, 爸爸, 妈妈, 回来, 雨伞, 冷, 快, 来`

---

## 3. Asset Sourcing & Production Pipelines

### A. Audio Pipeline (`T05_AUDIO_ASSET_PIPELINE`)
- **Format:** Clean mono MP3/OGG (128 kbps), normalized volume, exact trimmed silence.
- **Evaluation of Audio Generation / Recording Options:**
  1. *Offline Neural TTS (Edge-TTS / Piper / Kokoro):* Pre-rendered at build time with natural neural Mandarin voice (`zh-CN-XiaoxiaoNeural` / `zh-CN-YunxiNeural`). Highly consistent, reproducible, zero license cost.
  2. *Native Voice Actor Recordings:* Human-recorded tone accuracy and emotional nuance for story scenes.
  3. *Hybrid Strategy:* Use neural pre-rendered offline audio for rapid iteration of the ~100 bootstrap words, with option to swap in native studio recordings by replacing files in `assets/audio/words/` without code changes.

### B. Visual & Animation Pipeline (`T06_VISUAL_ASSET_PIPELINE`)
- **Aesthetic:** Minimalist, warm paper tone, ink/woodblock inspired or clean vector SVG.
- **Palette:** Warm white/cream canvas (`#FBF9F5`, `#F0EBE0`), charcoal ink (`#1E1E1E`, `#3A3A3A`), subtle accent hues.
- **Placeholder vs Final Assets:** Clean geometric icons during bootstrap build, transitioning to curated line-art SVGs and lightweight vector animations (e.g. Rive / Lottie / CSS frame sequences).

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
