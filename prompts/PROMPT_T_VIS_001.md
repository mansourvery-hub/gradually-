# Execution Prompt: Visual Concept & Scene Illustration Pipeline (`T_VIS_001` & `T_VIS_002`)

## 1. Context & Task Identity
* **Target Nodes:** `T_VIS_001_CONCEPTS` and `T_VIS_002_VISUAL_MANIFEST` from `dev_graph.json`
* **Assigned Role:** `visual_engineer`
* **Track:** `TRACK_CREATIVE_VISUAL`
* **Mission:** Author clean, minimalist vector SVGs / PNG visual assets for all 45 target bootstrap concepts and story scene illustrations, and generate the visual asset manifest (`assets/images/manifests/bootstrap_visuals.json`).

---

## 2. Applicable Non-Negotiable Invariants & Aesthetic Rules
1. **Monolingual Immersion ($E\text{-}01, E\text{-}08$):** Visuals provide direct concept grounding **without English labels, translation text, or bilingual subtitles**.
2. **Minimalist Zen Aesthetic ($CHOICES §3$):**
   * *Canvas palette:* Warm paper tones (`#FBF9F5`, `#F0EBE0`, `#ECE6D8`).
   * *Ink strokes:* Charcoal / dark graphite (`#1E1E1E`, `#3A3A3A`, `#4A4A4A`).
   * *Accents:* Subtle earthen hues (clay red, sage green, tea amber).
   * Clean, uncrowded line art, vector silhouettes, or ink-wash inspired illustrations.
3. **Responsive Scaling:** Assets must scale cleanly on mobile, tablet, desktop, and web viewports without raster degradation.

---

## 3. Input & Output File Contracts
* **Inputs:**
  * `assets/content/curriculum/bootstrap_target_lexicon.json` (45 target words with concept hints, e.g. `水: water`, `猫: cat`, `雨伞: umbrella`, `米饭: rice`)
  * `assets/content/stories/story_001_source.txt` (Scene descriptions for Story 1)
  * `assets/content/stories/story_002_source.txt` (Scene descriptions for Story 2)
  * `assets/content/stories/story_003_source.txt` (Scene descriptions for Story 3)
* **Outputs:**
  * `assets/images/concepts/*.svg` or `*.png` (45 concept visual files, e.g. `水.svg`, `猫.svg`, `雨伞.svg`, `热.svg`)
  * `assets/images/stories/story_001_sec*.svg` (Scene illustrations for Story 1)
  * `assets/images/stories/story_002_sec*.svg` (Scene illustrations for Story 2)
  * `assets/images/stories/story_003_sec*.svg` (Scene illustrations for Story 3)
  * `assets/images/manifests/bootstrap_visuals.json` (Manifest mapping every VocabId and Story Section ID to its asset path and semantic description)
  * `pubspec.yaml` (Ensure `assets/images/` is registered under `flutter.assets`)

---

## 4. Concrete Implementation Steps
1. **Curate/Generate Vector Asset Set:**
   Create or generate clean vector SVGs / styled PNGs matching the 45 target vocabulary concepts (e.g. water droplet, tea cup, rice bowl, cat silhouette, raining clouds, open book, umbrella, cozy home).
2. **Author Story Scene Illustrations:**
   * *Story 1:* Scene 1 (Teacup and water cup on table), Scene 2 (Table with tea and steaming rice bowl), Scene 3 (Serene tea setting).
   * *Story 2:* Scene 1 (Big cat and small kitten side-by-side), Scene 2 (Cats looking at each other), Scene 3 (Kitten drinking water, big cat eating fish), Scene 4 (Two cats playing/running together).
   * *Story 3:* Scene 1 (Rain falling outside window), Scene 2 (Cozy reading with steaming hot tea), Scene 3 (Parents arriving with wet umbrella), Scene 4 (Warm family tea gathering).
3. **Generate `assets/images/manifests/bootstrap_visuals.json`:**
   Structure:
   ```json
   {
     "version": "1.0.0",
     "concepts": {
       "水": "assets/images/concepts/水.svg",
       "茶": "assets/images/concepts/茶.svg",
       "猫": "assets/images/concepts/猫.svg"
     },
     "scenes": {
       "story_001_sec1": "assets/images/stories/story_001_sec1.svg"
     }
   }
   ```
4. **Register in `pubspec.yaml`:**
   Ensure assets directory declarations include `assets/images/`.

---

## 5. Automated Verification & Acceptance Criteria
* Validate that 100% of concept IDs and story scene IDs resolve to an existing, valid image file.
* `fvm flutter test` passes with zero missing asset warnings.
