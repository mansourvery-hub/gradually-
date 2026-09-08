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

  @override
  Widget build(BuildContext context) {
    final nextExperienceAsync = ref.watch(nextExperienceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5), // Calm paper tone
      body: SafeArea(
        child: nextExperienceAsync.when(
          loading: () => const Center(
            child: Text(
              '渐入',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
          error: (err, _) => Center(
            child: Text(
              '渐入',
              style: TextStyle(fontSize: 24, color: Colors.grey.shade400),
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
                    letterSpacing: 4,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              );
            }

            if (contentItem.type == ContentType.beginnerUnit) {
              return _BeginnerUnitView(
                item: contentItem,
                onComplete: () => _handleItemCompletion(contentItem),
              );
            }

            return _StoryReaderView(
              item: contentItem,
              sectionIndex: _currentSectionIndex,
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
    final now = DateTime.now();
    final learnerRepo = ref.read(learnerRepositoryProvider);
    final contentRepo = await ref.read(contentRepositoryProvider.future);

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

    // Reset section index for the next content
    if (mounted) {
      setState(() => _currentSectionIndex = 0);
    }

    // Refresh next experience
    ref.invalidate(nextExperienceProvider);
  }
}

/// Immersive single-word / atomic concept view for absolute beginners.
class _BeginnerUnitView extends StatelessWidget {
  const _BeginnerUnitView({required this.item, required this.onComplete});

  final ContentItem item;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final mainWord = item.metadata.title;

    return Column(
      children: [
        // Top subtle branding
        const Padding(
          padding: EdgeInsets.only(top: 24),
          child: Text(
            '渐入',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
              color: Color(0xFF8C8C8C),
            ),
          ),
        ),
        const Spacer(),

        // Visual Placeholder / Illustration Card
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFF0ECE1),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: _buildVisualPlaceholder(mainWord)),
        ),

        const SizedBox(height: 36),

        // Large prominent Hanzi character
        Text(
          mainWord,
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F1F1F),
            height: 1.1,
          ),
        ),

        const SizedBox(height: 12),

        // Native audio pronunciation prompt
        IconButton.filledTonal(
          onPressed: () {
            // Native audio playback placeholder (E-08)
          },
          icon: const Icon(Icons.volume_up_rounded, size: 28),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFEBE5D8),
            foregroundColor: const Color(0xFF4A4A4A),
            padding: const EdgeInsets.all(16),
          ),
        ),

        const Spacer(),

        // Bottom continue action
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: onComplete,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C2C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                '继续',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ],
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

    return Icon(iconData, size: 64, color: const Color(0xFF5A5A5A));
  }
}

/// Graded reader scene view for micro-stories and longer texts.
class _StoryReaderView extends StatelessWidget {
  const _StoryReaderView({
    required this.item,
    required this.sectionIndex,
    required this.onNextSection,
  });

  final ContentItem item;
  final int sectionIndex;
  final VoidCallback onNextSection;

  @override
  Widget build(BuildContext context) {
    final section = sectionIndex < item.sections.length
        ? item.sections[sectionIndex]
        : item.sections.first;

    final isLastSection = sectionIndex >= item.sections.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Story Title
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F1F1F),
            ),
          ),

          const SizedBox(height: 32),

          // Scene visual illustration container
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF0ECE1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_stories_rounded,
                size: 56,
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
                  fontSize: 28,
                  height: 1.8,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF242424),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          // Bottom Action Button
          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: onNextSection,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isLastSection ? '完成' : '继续',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
