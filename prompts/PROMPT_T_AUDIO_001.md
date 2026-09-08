# Execution Prompt: Audio Asset Generation Pipeline (`T_AUDIO_001` & `T_AUDIO_002`)

## 1. Context & Task Identity
* **Target Nodes:** `T_AUDIO_001_BOOTSTRAP_AUDIO` and `T_AUDIO_002_AUDIO_MANIFEST` from `dev_graph.json`
* **Assigned Role:** `audio_engineer`
* **Track:** `TRACK_CREATIVE_AUDIO`
* **Mission:** Pre-generate clean, offline, tone-accurate native Mandarin audio assets (MP3 format) for all 45 target bootstrap vocabulary items and story sentences, and generate the corresponding audio manifest (`assets/audio/manifests/bootstrap_audio.json`).

---

## 2. Applicable Non-Negotiable Invariants
1. **Offline-First ($E\text{-}01, E\text{-}12$):** Audio is **pre-rendered and bundled locally**. The core loop never calls a live cloud TTS API at runtime.
2. **Standard Audio Quality:** Mono MP3, 128 kbps, 44.1 kHz or 24 kHz, with exact trimmed leading/trailing silence (< 50ms) to ensure instant, crisp playback.
3. **Monolingual Mandarin:** Standard Putonghua pronunciation with accurate tone contours (e.g. using natural neural voices like `zh-CN-XiaoxiaoNeural` or `zh-CN-YunxiNeural`).

---

## 3. Input & Output File Contracts
* **Inputs:**
  * `assets/content/curriculum/bootstrap_target_lexicon.json` (45 bootstrap words with id, surface, pinyin)
  * `assets/content/stories/story_001_source.txt` (Story 1 sentence texts)
  * `assets/content/stories/story_002_source.txt` (Story 2 sentence texts)
  * `assets/content/stories/story_003_source.txt` (Story 3 sentence texts)
* **Outputs:**
  * `assets/audio/words/*.mp3` (45 audio files named `<vocabId>.mp3`, e.g. `水.mp3`, `茶.mp3`, `米饭.mp3`)
  * `assets/audio/sentences/*.mp3` (Sentence narration audio files)
  * `assets/audio/manifests/bootstrap_audio.json` (Manifest mapping every VocabId and SentenceId to its relative asset path, duration in ms, and voice metadata)
  * `pubspec.yaml` (Ensure `assets/audio/` is registered under `flutter.assets`)

---

## 4. Concrete Implementation Steps
1. **Set Up Pre-generation Tooling:**
   Use Python `edge-tts` (or local Piper/Kokoro TTS) or a CLI script to synthesize speech offline:
   ```bash
   pip install --user edge-tts
   ```
2. **Execute Audio Batch Synthesis Script:**
   Generate clean MP3s for every word in `bootstrap_target_lexicon.json`:
   ```python
   # Example generation command:
   edge-tts --voice "zh-CN-XiaoxiaoNeural" --text "水" --write-media "assets/audio/words/水.mp3"
   ```
3. **Trim Silence & Normalize Volume:**
   Ensure zero latency start for each audio file using `ffmpeg` (e.g. `ffmpeg -i input.mp3 -af silenceremove=start_periods=1:start_duration=0.01:start_threshold=-50dB output.mp3`).
4. **Generate `assets/audio/manifests/bootstrap_audio.json`:**
   Structure:
   ```json
   {
     "version": "1.0.0",
     "voice": "zh-CN-XiaoxiaoNeural",
     "words": {
       "水": "assets/audio/words/水.mp3",
       "茶": "assets/audio/words/茶.mp3"
     },
     "sentences": {
       "s1-1": "assets/audio/sentences/s1-1.mp3"
     }
   }
   ```
5. **Register Assets in `pubspec.yaml`:**
   Ensure `assets/audio/` and subdirectories are listed.

---

## 5. Automated Verification & Acceptance Criteria
* Run validation to verify 100% of vocabulary items have a valid, non-empty MP3 file:
  ```bash
  fvm flutter test test/content_test.dart
  ```
* Ensure `fvm flutter test` passes without missing asset errors.
