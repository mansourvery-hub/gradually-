/// Pre-compiled bootstrap curriculum items (CONTENT.md §2, §5).
///
/// Guaranteed available instantly on frame 1 across all platforms without
/// runtime asset-bundle network or filesystem delays.
library;

import '../core/token.dart';
import 'content.dart';

/// The default bootstrap curriculum for absolute beginners.
final List<ContentItem> bootstrapCurriculum = [
  // Unit 1: 水 (Water)
  const ContentItem(
    metadata: ContentMetadata(
      id: 'unit-001-water',
      title: '水',
      type: ContentType.beginnerUnit,
      curriculumOrder: 1,
      prerequisiteIds: {},
      difficultyEstimate: 1,
      vocabulary: {'水'},
      curriculumCriticalVocabulary: {'水'},
    ),
    sections: [
      ContentSection(
        id: 'sec-1',
        text: '水',
        visualAsset: 'assets/images/water.png',
        audioAsset: 'assets/audio/shui.mp3',
        sentences: [
          ContentSentence(
            id: 'unit-001-s1',
            text: '水',
            tokens: [Token(vocabId: '水', surface: '水', start: 0, end: 1)],
            criticalVocabIds: {'水'},
          ),
        ],
      ),
    ],
  ),

  // Unit 2: 茶 (Tea)
  const ContentItem(
    metadata: ContentMetadata(
      id: 'unit-002-tea',
      title: '茶',
      type: ContentType.beginnerUnit,
      curriculumOrder: 2,
      prerequisiteIds: {'unit-001-water'},
      difficultyEstimate: 1,
      vocabulary: {'茶'},
      curriculumCriticalVocabulary: {'茶'},
    ),
    sections: [
      ContentSection(
        id: 'sec-1',
        text: '茶',
        visualAsset: 'assets/images/tea.png',
        audioAsset: 'assets/audio/cha.mp3',
        sentences: [
          ContentSentence(
            id: 'unit-002-s1',
            text: '茶',
            tokens: [Token(vocabId: '茶', surface: '茶', start: 0, end: 1)],
            criticalVocabIds: {'茶'},
          ),
        ],
      ),
    ],
  ),

  // Unit 3: 喝 (Drink)
  const ContentItem(
    metadata: ContentMetadata(
      id: 'unit-003-drink',
      title: '喝',
      type: ContentType.beginnerUnit,
      curriculumOrder: 3,
      prerequisiteIds: {'unit-002-tea'},
      difficultyEstimate: 2,
      vocabulary: {'喝', '水', '茶'},
      curriculumCriticalVocabulary: {'喝'},
    ),
    sections: [
      ContentSection(
        id: 'sec-1',
        text: '喝水。喝茶。',
        visualAsset: 'assets/images/drink.png',
        sentences: [
          ContentSentence(
            id: 'unit-003-s1',
            text: '喝水。',
            tokens: [
              Token(vocabId: '喝', surface: '喝', start: 0, end: 1),
              Token(vocabId: '水', surface: '水', start: 1, end: 2),
            ],
            criticalVocabIds: {'喝'},
          ),
          ContentSentence(
            id: 'unit-003-s2',
            text: '喝茶。',
            tokens: [
              Token(vocabId: '喝', surface: '喝', start: 0, end: 1),
              Token(vocabId: '茶', surface: '茶', start: 1, end: 2),
            ],
            criticalVocabIds: {'喝'},
          ),
        ],
      ),
    ],
  ),

  // Unit 4: 吃 (Eat)
  const ContentItem(
    metadata: ContentMetadata(
      id: 'unit-004-eat',
      title: '吃',
      type: ContentType.beginnerUnit,
      curriculumOrder: 4,
      prerequisiteIds: {'unit-003-drink'},
      difficultyEstimate: 2,
      vocabulary: {'吃', '米饭'},
      curriculumCriticalVocabulary: {'吃', '米饭'},
    ),
    sections: [
      ContentSection(
        id: 'sec-1',
        text: '吃米饭。',
        visualAsset: 'assets/images/rice.png',
        sentences: [
          ContentSentence(
            id: 'unit-004-s1',
            text: '吃米饭。',
            tokens: [
              Token(vocabId: '吃', surface: '吃', start: 0, end: 1),
              Token(vocabId: '米饭', surface: '米饭', start: 1, end: 3),
            ],
            criticalVocabIds: {'吃', '米饭'},
          ),
        ],
      ),
    ],
  ),

  // Micro-story 1: 我想喝茶
  const ContentItem(
    metadata: ContentMetadata(
      id: 'story-001-drink-tea',
      title: '我想喝茶',
      type: ContentType.microStory,
      curriculumOrder: 5,
      prerequisiteIds: {'unit-004-eat'},
      difficultyEstimate: 3,
      vocabulary: {'我', '想', '喝', '茶', '水', '吃', '米饭', '也'},
      curriculumCriticalVocabulary: {'我', '想', '也'},
    ),
    sections: [
      ContentSection(
        id: 'sec-1',
        text: '我想喝水。',
        visualAsset: 'assets/images/story_water.png',
        sentences: [
          ContentSentence(
            id: 'story-001-s1',
            text: '我想喝水。',
            tokens: [
              Token(vocabId: '我', surface: '我', start: 0, end: 1),
              Token(vocabId: '想', surface: '想', start: 1, end: 2),
              Token(vocabId: '喝', surface: '喝', start: 2, end: 3),
              Token(vocabId: '水', surface: '水', start: 3, end: 4),
            ],
            criticalVocabIds: {'我', '想'},
          ),
        ],
      ),
      ContentSection(
        id: 'sec-2',
        text: '我也想喝茶，吃米饭。',
        visualAsset: 'assets/images/story_tea_rice.png',
        sentences: [
          ContentSentence(
            id: 'story-001-s2',
            text: '我也想喝茶，吃米饭。',
            tokens: [
              Token(vocabId: '我', surface: '我', start: 0, end: 1),
              Token(vocabId: '也', surface: '也', start: 1, end: 2),
              Token(vocabId: '想', surface: '想', start: 2, end: 3),
              Token(vocabId: '喝', surface: '喝', start: 3, end: 4),
              Token(vocabId: '茶', surface: '茶', start: 4, end: 5),
              Token(vocabId: '吃', surface: '吃', start: 6, end: 7),
              Token(vocabId: '米饭', surface: '米饭', start: 7, end: 9),
            ],
            criticalVocabIds: {'也'},
          ),
        ],
      ),
    ],
  ),
];
