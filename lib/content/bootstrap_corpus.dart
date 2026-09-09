/// Pre-compiled bootstrap curriculum items (CONTENT.md §2, §5, CHOICES.md §2).
///
/// Guaranteed available instantly on frame 1 across all platforms without
/// runtime asset-bundle network or filesystem delays.
library;

import '../core/token.dart';
import 'content.dart';

/// The target bootstrap lexicon items (45 words/Hanzi backward-derived from Stories 1–3).
const List<({String id, String surface, String concept})> kBootstrapLexicon = [
  (id: '水', surface: '水', concept: 'water'),
  (id: '茶', surface: '茶', concept: 'tea'),
  (id: '喝', surface: '喝', concept: 'drink'),
  (id: '吃', surface: '吃', concept: 'eat'),
  (id: '米饭', surface: '米饭', concept: 'rice'),
  (id: '我', surface: '我', concept: 'I / me'),
  (id: '想', surface: '想', concept: 'want / think'),
  (id: '也', surface: '也', concept: 'also / too'),
  (id: '我们', surface: '我们', concept: 'we / us'),
  (id: '一起', surface: '一起', concept: 'together'),
  (id: '很', surface: '很', concept: 'very'),
  (id: '好喝', surface: '好喝', concept: 'delicious to drink'),
  (id: '好吃', surface: '好吃', concept: 'delicious to eat'),
  (id: '好', surface: '好', concept: 'good'),
  (id: '猫', surface: '猫', concept: 'cat'),
  (id: '大', surface: '大', concept: 'big'),
  (id: '小', surface: '小', concept: 'small'),
  (id: '看', surface: '看', concept: 'look / see'),
  (id: '要', surface: '要', concept: 'want / need'),
  (id: '鱼', surface: '鱼', concept: 'fish'),
  (id: '这里', surface: '这里', concept: 'here'),
  (id: '有', surface: '有', concept: 'have / there is'),
  (id: '一', surface: '一', concept: 'one'),
  (id: '只', surface: '只', concept: 'measure word for animals'),
  (id: '和', surface: '和', concept: 'and'),
  (id: '它们', surface: '它们', concept: 'they (animals)'),
  (id: '是', surface: '是', concept: 'is / are'),
  (id: '朋友', surface: '朋友', concept: 'friend'),
  (id: '天天', surface: '天天', concept: 'every day'),
  (id: '在', surface: '在', concept: 'at / in'),
  (id: '跑', surface: '跑', concept: 'run'),
  (id: '今天', surface: '今天', concept: 'today'),
  (id: '天气', surface: '天气', concept: 'weather'),
  (id: '不', surface: '不', concept: 'not'),
  (id: '下雨', surface: '下雨', concept: 'rain'),
  (id: '了', surface: '了', concept: 'aspect particle'),
  (id: '家', surface: '家', concept: 'home'),
  (id: '里', surface: '里', concept: 'inside'),
  (id: '书', surface: '书', concept: 'book'),
  (id: '热', surface: '热', concept: 'hot / warm'),
  (id: '爸爸', surface: '爸爸', concept: 'father'),
  (id: '妈妈', surface: '妈妈', concept: 'mother'),
  (id: '回来', surface: '回来', concept: 'come back'),
  (id: '雨伞', surface: '雨伞', concept: 'umbrella'),
  (id: '冷', surface: '冷', concept: 'cold'),
];

/// Builds the complete list of 45 beginner units sequenced in target order.
List<ContentItem> _buildBootstrapUnits() {
  final units = <ContentItem>[];

  for (int i = 0; i < kBootstrapLexicon.length; i++) {
    final item = kBootstrapLexicon[i];
    final order = i + 1;
    final id = 'unit-${(i + 1).toString().padLeft(3, '0')}-${item.id}';
    final prevId = i > 0
        ? 'unit-${i.toString().padLeft(3, '0')}-${kBootstrapLexicon[i - 1].id}'
        : null;

    units.add(
      ContentItem(
        metadata: ContentMetadata(
          id: id,
          title: item.surface,
          type: ContentType.beginnerUnit,
          curriculumOrder: order,
          prerequisiteIds: prevId != null ? {prevId} : const {},
          difficultyEstimate: 1,
          vocabulary: {item.id},
          curriculumCriticalVocabulary: {item.id},
        ),
        sections: [
          ContentSection(
            id: 'sec-1',
            text: item.surface,
            visualAsset: 'assets/images/concepts/${item.id}.svg',
            audioAsset: 'assets/audio/words/${item.id}.mp3',
            sentences: [
              ContentSentence(
                id: 's-$id',
                text: item.surface,
                tokens: [
                  Token(
                    vocabId: item.id,
                    surface: item.surface,
                    start: 0,
                    end: item.surface.length,
                  ),
                ],
                criticalVocabIds: {item.id},
              ),
            ],
          ),
        ],
      ),
    );
  }

  return units;
}

/// The default bootstrap curriculum containing 45 progressive exposure units + Stories 1–3.
final List<ContentItem> bootstrapCurriculum = [
  // 1. All 45 target-led beginner exposure units (orders 1..45)
  ..._buildBootstrapUnits(),

  // 2. Story 1: 喝茶与米饭 (Order 46)
  const ContentItem(
    metadata: ContentMetadata(
      id: 'story-001-drink-tea',
      title: '喝茶与米饭',
      type: ContentType.story,
      curriculumOrder: 46,
      prerequisiteIds: {'unit-013-好吃'},
      difficultyEstimate: 2,
      vocabulary: {
        '我',
        '想',
        '喝',
        '水',
        '也',
        '茶',
        '我们',
        '一起',
        '吃',
        '米饭',
        '很',
        '好喝',
        '好吃',
      },
      curriculumCriticalVocabulary: {'我', '想', '也', '我们', '一起', '很'},
    ),
    sections: [
      ContentSection(
        id: 'sec-1',
        text: '我想喝水。我也想喝茶。',
        visualAsset: 'assets/images/story_001_sec1.svg',
        sentences: [
          ContentSentence(
            id: 's1-1',
            text: '我想喝水。',
            tokens: [
              Token(vocabId: '我', surface: '我', start: 0, end: 1),
              Token(vocabId: '想', surface: '想', start: 1, end: 2),
              Token(vocabId: '喝', surface: '喝', start: 2, end: 3),
              Token(vocabId: '水', surface: '水', start: 3, end: 4),
            ],
            criticalVocabIds: {'我', '想', '喝', '水'},
          ),
          ContentSentence(
            id: 's1-2',
            text: '我也想喝茶。',
            tokens: [
              Token(vocabId: '我', surface: '我', start: 0, end: 1),
              Token(vocabId: '也', surface: '也', start: 1, end: 2),
              Token(vocabId: '想', surface: '想', start: 2, end: 3),
              Token(vocabId: '喝', surface: '喝', start: 3, end: 4),
              Token(vocabId: '茶', surface: '茶', start: 4, end: 5),
            ],
            criticalVocabIds: {'也', '茶'},
          ),
        ],
      ),
      ContentSection(
        id: 'sec-2',
        text: '我们一起喝茶，吃米饭。',
        visualAsset: 'assets/images/story_001_sec2.svg',
        sentences: [
          ContentSentence(
            id: 's1-3',
            text: '我们一起喝茶，吃米饭。',
            tokens: [
              Token(vocabId: '我们', surface: '我们', start: 0, end: 2),
              Token(vocabId: '一起', surface: '一起', start: 2, end: 4),
              Token(vocabId: '喝', surface: '喝', start: 4, end: 5),
              Token(vocabId: '茶', surface: '茶', start: 5, end: 6),
              Token(vocabId: '吃', surface: '吃', start: 7, end: 8),
              Token(vocabId: '米饭', surface: '米饭', start: 8, end: 10),
            ],
            criticalVocabIds: {'我们', '一起', '吃', '米饭'},
          ),
        ],
      ),
      ContentSection(
        id: 'sec-3',
        text: '茶很好喝，米饭很好吃。',
        visualAsset: 'assets/images/story_001_sec3.svg',
        sentences: [
          ContentSentence(
            id: 's1-4',
            text: '茶很好喝，米饭很好吃。',
            tokens: [
              Token(vocabId: '茶', surface: '茶', start: 0, end: 1),
              Token(vocabId: '很', surface: '很', start: 1, end: 2),
              Token(vocabId: '好喝', surface: '好喝', start: 2, end: 4),
              Token(vocabId: '米饭', surface: '米饭', start: 5, end: 7),
              Token(vocabId: '很', surface: '很', start: 7, end: 8),
              Token(vocabId: '好吃', surface: '好吃', start: 8, end: 10),
            ],
            criticalVocabIds: {'很', '好喝', '好吃'},
          ),
        ],
      ),
    ],
  ),

  // 3. Story 2: 大猫与小猫 (Order 47)
  const ContentItem(
    metadata: ContentMetadata(
      id: 'story-002-cats',
      title: '大猫与小猫',
      type: ContentType.story,
      curriculumOrder: 47,
      prerequisiteIds: {'story-001-drink-tea'},
      difficultyEstimate: 2,
      vocabulary: {
        '这里',
        '有',
        '一',
        '只',
        '大',
        '猫',
        '和',
        '小',
        '看',
        '要',
        '喝',
        '水',
        '吃',
        '鱼',
        '它们',
        '是',
        '朋友',
        '天天',
        '在',
        '一起',
        '跑',
      },
      curriculumCriticalVocabulary: {'猫', '大', '小', '看', '要', '鱼', '朋友', '跑'},
    ),
    sections: [
      ContentSection(
        id: 'sec-1',
        text: '这里有一只大猫和一只小猫。',
        visualAsset: 'assets/images/story_002_sec1.svg',
        sentences: [
          ContentSentence(
            id: 's2-1',
            text: '这里有一只大猫和一只小猫。',
            tokens: [
              Token(vocabId: '这里', surface: '这里', start: 0, end: 2),
              Token(vocabId: '有', surface: '有', start: 2, end: 3),
              Token(vocabId: '一', surface: '一', start: 3, end: 4),
              Token(vocabId: '只', surface: '只', start: 4, end: 5),
              Token(vocabId: '大', surface: '大', start: 5, end: 6),
              Token(vocabId: '猫', surface: '猫', start: 6, end: 7),
              Token(vocabId: '和', surface: '和', start: 7, end: 8),
              Token(vocabId: '一', surface: '一', start: 8, end: 9),
              Token(vocabId: '只', surface: '只', start: 9, end: 10),
              Token(vocabId: '小', surface: '小', start: 10, end: 11),
              Token(vocabId: '猫', surface: '猫', start: 11, end: 12),
            ],
            criticalVocabIds: {'猫', '大', '小'},
          ),
        ],
      ),
      ContentSection(
        id: 'sec-2',
        text: '大猫看小猫，小猫看大猫。',
        visualAsset: 'assets/images/story_002_sec2.svg',
        sentences: [
          ContentSentence(
            id: 's2-2',
            text: '大猫看小猫，小猫看大猫。',
            tokens: [
              Token(vocabId: '大', surface: '大', start: 0, end: 1),
              Token(vocabId: '猫', surface: '猫', start: 1, end: 2),
              Token(vocabId: '看', surface: '看', start: 2, end: 3),
              Token(vocabId: '小', surface: '小', start: 3, end: 4),
              Token(vocabId: '猫', surface: '猫', start: 4, end: 5),
              Token(vocabId: '小', surface: '小', start: 6, end: 7),
              Token(vocabId: '猫', surface: '猫', start: 7, end: 8),
              Token(vocabId: '看', surface: '看', start: 8, end: 9),
              Token(vocabId: '大', surface: '大', start: 9, end: 10),
              Token(vocabId: '猫', surface: '猫', start: 10, end: 11),
            ],
            criticalVocabIds: {'看'},
          ),
        ],
      ),
      ContentSection(
        id: 'sec-3',
        text: '小猫要喝水，大猫要吃鱼。',
        visualAsset: 'assets/images/story_002_sec3.svg',
        sentences: [
          ContentSentence(
            id: 's2-3',
            text: '小猫要喝水，大猫要吃鱼。',
            tokens: [
              Token(vocabId: '小', surface: '小', start: 0, end: 1),
              Token(vocabId: '猫', surface: '猫', start: 1, end: 2),
              Token(vocabId: '要', surface: '要', start: 2, end: 3),
              Token(vocabId: '喝', surface: '喝', start: 3, end: 4),
              Token(vocabId: '水', surface: '水', start: 4, end: 5),
              Token(vocabId: '大', surface: '大', start: 6, end: 7),
              Token(vocabId: '猫', surface: '猫', start: 7, end: 8),
              Token(vocabId: '要', surface: '要', start: 8, end: 9),
              Token(vocabId: '吃', surface: '吃', start: 9, end: 10),
              Token(vocabId: '鱼', surface: '鱼', start: 10, end: 11),
            ],
            criticalVocabIds: {'要', '鱼'},
          ),
        ],
      ),
      ContentSection(
        id: 'sec-4',
        text: '它们是好朋友，天天在一起跑。',
        visualAsset: 'assets/images/story_002_sec4.svg',
        sentences: [
          ContentSentence(
            id: 's2-4',
            text: '它们是好朋友，天天在一起跑。',
            tokens: [
              Token(vocabId: '它们', surface: '它们', start: 0, end: 2),
              Token(vocabId: '是', surface: '是', start: 2, end: 3),
              Token(vocabId: '好', surface: '好', start: 3, end: 4),
              Token(vocabId: '朋友', surface: '朋友', start: 4, end: 6),
              Token(vocabId: '天天', surface: '天天', start: 7, end: 9),
              Token(vocabId: '在', surface: '在', start: 9, end: 10),
              Token(vocabId: '一起', surface: '一起', start: 10, end: 12),
              Token(vocabId: '跑', surface: '跑', start: 12, end: 13),
            ],
            criticalVocabIds: {'朋友', '跑'},
          ),
        ],
      ),
    ],
  ),

  // 4. Story 3: 今天下雨 (Order 48)
  const ContentItem(
    metadata: ContentMetadata(
      id: 'story-003-rainy-day',
      title: '今天下雨',
      type: ContentType.story,
      curriculumOrder: 48,
      prerequisiteIds: {'story-002-cats'},
      difficultyEstimate: 3,
      vocabulary: {
        '今天',
        '天气',
        '不',
        '好',
        '下雨',
        '了',
        '我',
        '在',
        '家',
        '里',
        '看',
        '书',
        '喝',
        '热',
        '茶',
        '爸爸',
        '妈妈',
        '回来',
        '他们',
        '拿着',
        '雨伞',
        '说',
        '外面',
        '很',
        '冷',
        '快',
        '来',
      },
      curriculumCriticalVocabulary: {
        '今天',
        '天气',
        '下雨',
        '家',
        '书',
        '热',
        '爸爸',
        '妈妈',
        '雨伞',
        '冷',
      },
    ),
    sections: [
      ContentSection(
        id: 'sec-1',
        text: '今天天气不好，天下雨了。',
        visualAsset: 'assets/images/story_003_sec1.svg',
        sentences: [
          ContentSentence(
            id: 's3-1',
            text: '今天天气不好，天下雨了。',
            tokens: [
              Token(vocabId: '今天', surface: '今天', start: 0, end: 2),
              Token(vocabId: '天气', surface: '天气', start: 2, end: 4),
              Token(vocabId: '不', surface: '不', start: 4, end: 5),
              Token(vocabId: '好', surface: '好', start: 5, end: 6),
              Token(vocabId: '下雨', surface: '下雨', start: 8, end: 10),
              Token(vocabId: '了', surface: '了', start: 10, end: 11),
            ],
            criticalVocabIds: {'今天', '天气', '下雨'},
          ),
        ],
      ),
      ContentSection(
        id: 'sec-2',
        text: '我在家里看书，喝热茶。',
        visualAsset: 'assets/images/story_003_sec2.svg',
        sentences: [
          ContentSentence(
            id: 's3-2',
            text: '我在家里看书，喝热茶。',
            tokens: [
              Token(vocabId: '我', surface: '我', start: 0, end: 1),
              Token(vocabId: '在', surface: '在', start: 1, end: 2),
              Token(vocabId: '家', surface: '家', start: 2, end: 3),
              Token(vocabId: '里', surface: '里', start: 3, end: 4),
              Token(vocabId: '看', surface: '看', start: 4, end: 5),
              Token(vocabId: '书', surface: '书', start: 5, end: 6),
              Token(vocabId: '喝', surface: '喝', start: 7, end: 8),
              Token(vocabId: '热', surface: '热', start: 8, end: 9),
              Token(vocabId: '茶', surface: '茶', start: 9, end: 10),
            ],
            criticalVocabIds: {'家', '书', '热'},
          ),
        ],
      ),
      ContentSection(
        id: 'sec-3',
        text: '爸爸妈妈回来了，他们拿着雨伞。',
        visualAsset: 'assets/images/story_003_sec3.svg',
        sentences: [
          ContentSentence(
            id: 's3-3',
            text: '爸爸妈妈回来了，他们拿着雨伞。',
            tokens: [
              Token(vocabId: '爸爸', surface: '爸爸', start: 0, end: 2),
              Token(vocabId: '妈妈', surface: '妈妈', start: 2, end: 4),
              Token(vocabId: '回来', surface: '回来', start: 4, end: 6),
              Token(vocabId: '了', surface: '了', start: 6, end: 7),
              Token(vocabId: '他们', surface: '他们', start: 8, end: 10),
              Token(vocabId: '拿着', surface: '拿着', start: 10, end: 12),
              Token(vocabId: '雨伞', surface: '雨伞', start: 12, end: 14),
            ],
            criticalVocabIds: {'爸爸', '妈妈', '雨伞'},
          ),
        ],
      ),
      ContentSection(
        id: 'sec-4',
        text: '外面很冷，快来喝茶。',
        visualAsset: 'assets/images/story_003_sec4.svg',
        sentences: [
          ContentSentence(
            id: 's3-4',
            text: '外面很冷，快来喝茶。',
            tokens: [
              Token(vocabId: '外面', surface: '外面', start: 0, end: 2),
              Token(vocabId: '很', surface: '很', start: 2, end: 3),
              Token(vocabId: '冷', surface: '冷', start: 3, end: 4),
              Token(vocabId: '快', surface: '快', start: 5, end: 6),
              Token(vocabId: '来', surface: '来', start: 6, end: 7),
              Token(vocabId: '喝', surface: '喝', start: 7, end: 8),
              Token(vocabId: '茶', surface: '茶', start: 8, end: 9),
            ],
            criticalVocabIds: {'冷'},
          ),
        ],
      ),
    ],
  ),
];
