/// Radical zero-friction, button-free monolingual reader (AGENTS.md §3, CHOICES.md §1).
///
/// Widgets only: consumes Riverpod providers, contains no learning logic.
/// All progression is driven by natural tap/gesture interactions.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../content/bootstrap_corpus.dart';
import '../content/content.dart';
import '../core/progress.dart';
import '../core/simulated_level.dart';
import '../learner/known.dart';
import '../review/review.dart';

/// The primary screen of 渐入.
///
/// Completely button-free: tap anywhere to progress, natural audio, serene canvas.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentSectionIndex = 0;
  bool _isAdvancing = false;

  @override
  Widget build(BuildContext context) {
    final dueCardsAsync = ref.watch(dueReviewCardsProvider);
    final nextExperienceAsync = ref.watch(nextExperienceProvider);

    // 1. Post-exposure phase: If an SRS card is due, present review card
    final dueCards = dueCardsAsync.value ?? const [];
    if (dueCards.isNotEmpty) {
      final activeCard = dueCards.first;
      return Scaffold(
        backgroundColor: const Color(0xFFFBF9F5),
        body: SafeArea(
          child: _ButtonlessReviewView(
            key: ValueKey(activeCard.card.id),
            record: activeCard,
            onRecallCompleted: (grade) => _handleReviewGrade(activeCard, grade),
          ),
        ),
      );
    }

    // 2. Immersion flow: render active content with zero-delay fallback
    final contentItem =
        nextExperienceAsync.value ?? bootstrapCurriculum.firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5), // Calm paper tone
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: contentItem != null
              ? (contentItem.type == ContentType.beginnerUnit
                    ? _ButtonlessBeginnerUnitView(
                        key: ValueKey(contentItem.id),
                        item: contentItem,
                        onAdvance: () => _handleItemCompletion(contentItem),
                      )
                    : _ButtonlessStoryReaderView(
                        key: ValueKey(
                          '${contentItem.id}-$_currentSectionIndex',
                        ),
                        item: contentItem,
                        sectionIndex: _currentSectionIndex,
                        onAdvance: () {
                          if (_currentSectionIndex <
                              contentItem.sections.length - 1) {
                            setState(() => _currentSectionIndex++);
                          } else {
                            _handleItemCompletion(contentItem);
                          }
                        },
                      ))
              : const Center(
                  key: ValueKey('empty-splash'),
                  child: Text(
                    '渐入',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 8,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _handleReviewGrade(
    ReviewCardRecord cardRecord,
    RecallGrade grade,
  ) async {
    final reviewSystem = ref.read(reviewSystemProvider);
    await reviewSystem.processOutcome(
      cardRecord: cardRecord,
      grade: grade,
      now: DateTime.now(),
    );

    ref.invalidate(dueReviewCardsProvider);
    ref.invalidate(learnerStateStreamProvider);
  }

  Future<void> _handleItemCompletion(ContentItem item) async {
    if (_isAdvancing) return;
    setState(() => _isAdvancing = true);

    try {
      final now = DateTime.now();
      final learnerState = ref.read(activeLearnerStateProvider);

      // Simulated level: advance the in-memory state; skip real DB writes.
      if (kSimulatedLevel > 0) {
        ref.read(activeLearnerStateProvider.notifier).completeItem(item);
      } else {
        final learnerRepo = ref.read(learnerRepositoryProvider);
        final contentRepo = ref.read(contentRepositoryProvider);
        final acquisition = ref.read(acquisitionPipelineProvider);

        // 1. Record vocabulary exposure for all words in the content
        final vocabIds = item.metadata.vocabulary.toList();
        await learnerRepo.recordBatchExposure(vocabIds, item.id, at: now);

        // 2. Evaluate words for acquisition (candidate registration)
        for (final section in item.sections) {
          for (final sentence in section.sentences) {
            for (final token in sentence.tokens) {
              final isCritical = item.metadata.curriculumCriticalVocabulary
                  .contains(token.vocabId);
              await acquisition.evaluateAndPromote(
                learner: learnerState,
                vocabId: token.vocabId,
                contentId: item.id,
                sourceSentenceText: sentence.text,
                token: token,
                isCurriculumCritical: isCritical,
                visualAsset: section.visualAsset,
                audioAsset: section.audioAsset,
                now: now,
              );
            }
          }
        }

        // 3. Update reading completion progress in SQLite
        final existingProgress = await contentRepo.getProgress(item.id);
        final updatedProgress =
            (existingProgress ??
                    ContentProgress.initial(contentId: item.id, now: now))
                .recordCompletion(now);

        await contentRepo.saveProgress(updatedProgress);
        await learnerRepo.updateContentProgress(updatedProgress);
      }

      if (mounted) {
        setState(() {
          _currentSectionIndex = 0;
          _isAdvancing = false;
        });
      }

      ref.invalidate(nextExperienceProvider);
      ref.invalidate(dueReviewCardsProvider);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('_handleItemCompletion error: $e\n$stack');
      }
      if (mounted) {
        setState(() => _isAdvancing = false);
      }
      // Always invalidate so the selector can pick the next item
      ref.invalidate(nextExperienceProvider);
      ref.invalidate(dueReviewCardsProvider);
    }
  }
}

/// Pure button-free beginner unit: tap anywhere to absorb and advance.
class _ButtonlessBeginnerUnitView extends ConsumerWidget {
  const _ButtonlessBeginnerUnitView({
    super.key,
    required this.item,
    required this.onAdvance,
  });

  final ContentItem item;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainWord = item.metadata.title;
    final audioCtrl = ref.watch(audioPlaybackControllerProvider);
    final hasAudio = audioCtrl.hasAudio(item.id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onAdvance,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Visual concept illustration card
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBE0),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(child: _buildVisualPlaceholder(mainWord)),
                ),

                const SizedBox(height: 52),

                // Prominent Large Hanzi (Pure Monolingual — NO PINYIN)
                Text(
                  mainWord,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1E1E1E),
                    height: 1.05,
                  ),
                ),

                const SizedBox(height: 48),

                // Audio playback trigger (graceful no-op when absent per E-08)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => audioCtrl.play(item.id),
                  child: Icon(
                    hasAudio ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    size: 26,
                    color: hasAudio
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualPlaceholder(String word) {
    IconData iconData;
    switch (word) {
      case '水':
        iconData = Icons.water_drop_rounded;
      case '茶':
      case '好喝':
        iconData = Icons.emoji_food_beverage_rounded;
      case '喝':
        iconData = Icons.local_cafe_rounded;
      case '吃':
      case '好吃':
      case '米饭':
        iconData = Icons.rice_bowl_rounded;
      case '猫':
        iconData = Icons.pets_rounded;
      case '鱼':
        iconData = Icons.set_meal_rounded;
      case '跑':
        iconData = Icons.directions_run_rounded;
      case '下雨':
      case '雨伞':
      case '天气':
        iconData = Icons.umbrella_rounded;
      case '家':
        iconData = Icons.home_rounded;
      case '书':
        iconData = Icons.menu_book_rounded;
      case '热':
        iconData = Icons.whatshot_rounded;
      case '冷':
        iconData = Icons.ac_unit_rounded;
      default:
        iconData = Icons.auto_stories_rounded;
    }

    return Icon(iconData, size: 76, color: const Color(0xFF4E4E4E));
  }
}

/// Pure button-free story reader: tap anywhere to read the next sentence/scene.
class _ButtonlessStoryReaderView extends StatelessWidget {
  const _ButtonlessStoryReaderView({
    super.key,
    required this.item,
    required this.sectionIndex,
    required this.onAdvance,
  });

  final ContentItem item;
  final int sectionIndex;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final section = sectionIndex < item.sections.length
        ? item.sections[sectionIndex]
        : item.sections.first;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onAdvance,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Story Scene Illustration Container
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBE0),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 64,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Unspaced Chinese Narrative Text
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      section.text,
                      style: const TextStyle(
                        fontSize: 34,
                        height: 1.8,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF222222),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gesture-driven, buttonless review card (post-exposure phase).
class _ButtonlessReviewView extends StatefulWidget {
  const _ButtonlessReviewView({
    super.key,
    required this.record,
    required this.onRecallCompleted,
  });

  final ReviewCardRecord record;
  final ValueChanged<RecallGrade> onRecallCompleted;

  @override
  State<_ButtonlessReviewView> createState() => _ButtonlessReviewViewState();
}

class _ButtonlessReviewViewState extends State<_ButtonlessReviewView> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final card = widget.record.card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!_revealed) {
          setState(() => _revealed = true);
        } else {
          // Tap to confirm recall (remembered)
          widget.onRecallCompleted(RecallGrade.remembered);
        }
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Target word
                Text(
                  card.vocabId,
                  style: const TextStyle(
                    fontSize: 84,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1E1E1E),
                  ),
                ),

                const SizedBox(height: 32),

                // Context sentence (revealed on tap)
                AnimatedOpacity(
                  opacity: _revealed ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    card.sourceSentence,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.6,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
