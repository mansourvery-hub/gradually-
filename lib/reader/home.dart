/// Zero-friction, monolingual reader and beginner experience (AGENTS.md §3, CONTENT.md §8).
///
/// Widgets only: consumes Riverpod providers, contains no learning logic.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../content/content.dart';
import '../core/progress.dart';
import '../learner/known.dart';

/// The primary screen of 渐入.
///
/// Immediately presents the system-selected piece of Chinese with zero
/// decision screens, dashboards, or course catalogs (AGENTS.md §3).
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
    final nextExperienceAsync = ref.watch(nextExperienceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5), // Calm paper tone
      body: SafeArea(
        child: nextExperienceAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '渐入',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 6,
                    color: Color(0xFF3A3A3A),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ],
            ),
          ),
          error: (err, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '渐入',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4,
                    color: Color(0xFF3A3A3A),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.invalidate(nextExperienceProvider),
                  child: const Text(
                    '重试',
                    style: TextStyle(color: Color(0xFF5A5A5A)),
                  ),
                ),
              ],
            ),
          ),
          data: (contentItem) {
            if (contentItem == null) {
              return const Center(
                child: Text(
                  '渐入',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 6,
                    color: Color(0xFF3A3A3A),
                  ),
                ),
              );
            }

            if (contentItem.type == ContentType.beginnerUnit) {
              return _BeginnerUnitView(
                item: contentItem,
                isAdvancing: _isAdvancing,
                onComplete: () => _handleItemCompletion(contentItem),
              );
            }

            return _StoryReaderView(
              item: contentItem,
              sectionIndex: _currentSectionIndex,
              isAdvancing: _isAdvancing,
              onNextSection: () {
                if (_currentSectionIndex < contentItem.sections.length - 1) {
                  setState(() => _currentSectionIndex++);
                } else {
                  _handleItemCompletion(contentItem);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleItemCompletion(ContentItem item) async {
    if (_isAdvancing) return;
    setState(() => _isAdvancing = true);

    try {
      final now = DateTime.now();
      final learnerRepo = ref.read(learnerRepositoryProvider);
      final contentRepo = ref.read(contentRepositoryProvider);

      // 1. Record vocabulary exposure for all words in the content
      final vocabIds = item.metadata.vocabulary.toList();
      await learnerRepo.recordBatchExposure(vocabIds, item.id, at: now);

      // 2. Record explicit mastery evidence for critical vocabulary
      for (final vocabId in item.metadata.curriculumCriticalVocabulary) {
        await learnerRepo.recordMasteryEvidence(
          MasteryEvidence(
            vocabId: vocabId,
            kind: MasteryEvidenceKind.meaning,
            grade: RecallGrade.remembered,
            at: now,
          ),
        );
      }

      // 3. Update reading completion progress in SQLite
      final existingProgress = await contentRepo.getProgress(item.id);
      final updatedProgress =
          (existingProgress ??
                  ContentProgress.initial(contentId: item.id, now: now))
              .recordCompletion(now);

      await contentRepo.saveProgress(updatedProgress);
      await learnerRepo.updateContentProgress(updatedProgress);

      if (mounted) {
        setState(() {
          _currentSectionIndex = 0;
          _isAdvancing = false;
        });
      }

      ref.invalidate(nextExperienceProvider);
    } catch (_) {
      if (mounted) {
        setState(() => _isAdvancing = false);
      }
    }
  }
}

/// Immersive single-word / atomic concept view for absolute beginners.
class _BeginnerUnitView extends StatelessWidget {
  const _BeginnerUnitView({
    required this.item,
    required this.isAdvancing,
    required this.onComplete,
  });

  final ContentItem item;
  final bool isAdvancing;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final mainWord = item.metadata.title;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Subtle top app title
              const Text(
                '渐入',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                  color: Color(0xFF9E9E9E),
                ),
              ),

              const Spacer(),

              // Visual Illustration Card
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBE0),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(child: _buildVisualPlaceholder(mainWord)),
              ),

              const SizedBox(height: 40),

              // Large Prominent Hanzi
              Text(
                mainWord,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 84,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E1E1E),
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 16),

              // Native pronunciation audio prompt button
              IconButton.filledTonal(
                onPressed: () {
                  // Audio playback placeholder (E-08)
                },
                icon: const Icon(Icons.volume_up_rounded, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFECE6D8),
                  foregroundColor: const Color(0xFF4A4A4A),
                  padding: const EdgeInsets.all(16),
                ),
              ),

              const Spacer(),

              // Primary "继续" progression button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  onPressed: isAdvancing ? null : onComplete,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2B2B2B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: isAdvancing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '继续',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 4,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 36),
            ],
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
        iconData = Icons.emoji_food_beverage_rounded;
      case '喝':
        iconData = Icons.local_cafe_rounded;
      case '吃':
      case '米饭':
        iconData = Icons.rice_bowl_rounded;
      default:
        iconData = Icons.auto_stories_rounded;
    }

    return Icon(iconData, size: 72, color: const Color(0xFF525252));
  }
}

/// Graded reader scene view for micro-stories and longer texts.
class _StoryReaderView extends StatelessWidget {
  const _StoryReaderView({
    required this.item,
    required this.sectionIndex,
    required this.isAdvancing,
    required this.onNextSection,
  });

  final ContentItem item;
  final int sectionIndex;
  final bool isAdvancing;
  final VoidCallback onNextSection;

  @override
  Widget build(BuildContext context) {
    final section = sectionIndex < item.sections.length
        ? item.sections[sectionIndex]
        : item.sections.first;

    final isLastSection = sectionIndex >= item.sections.length - 1;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Story Title
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1E1E),
                ),
              ),

              const SizedBox(height: 28),

              // Scene visual illustration container
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBE0),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_stories_rounded,
                    size: 64,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Unspaced Chinese sentence rendering with clean typography
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    section.text,
                    style: const TextStyle(
                      fontSize: 30,
                      height: 1.8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF242424),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton(
                    onPressed: isAdvancing ? null : onNextSection,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2B2B2B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: isAdvancing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isLastSection ? '完成' : '继续',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 4,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
