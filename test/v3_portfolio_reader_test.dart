import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/pipeline/generation/generated_passage.dart';
import 'package:jianru/pipeline/ladder/ladder_model.dart';
import 'package:jianru/pipeline/portfolio/portfolio_manager.dart';
import 'package:jianru/reader/v3_portfolio_reader.dart';

void main() {
  group('Contract 12: Runtime Application (V3PortfolioReader)', () {
    const p1 = GeneratedPassage(
      passageId: 'pass_1',
      targetEventId: 'ev_ch1_1',
      chapterIndex: 1,
      generatedText: '这是甄士隐的故事。',
      sourceRefs: [],
      newWords: ['甄士隐'],
      newCharacters: ['甄', '士', '隐'],
      difficultyEstimate: 1.0,
      generationMetadata: {},
    );

    const p2 = GeneratedPassage(
      passageId: 'pass_2',
      targetEventId: 'ev_ch1_2',
      chapterIndex: 1,
      generatedText: '贾雨村在风尘之中。',
      sourceRefs: [],
      newWords: ['贾雨村', '风尘'],
      newCharacters: ['贾', '村', '尘'],
      difficultyEstimate: 1.5,
      generationMetadata: {},
    );

    const sampleLadder = ProgressiveLadder(
      sourceId: '红楼梦',
      sourceHash: 'sample_hash',
      levels: [
        LadderLevel(
          levelNumber: 0,
          title: 'Level 0',
          difficultyFloor: 1.0,
          difficultyCeiling: 1.5,
          passages: [p1],
          cumulativeKnownWords: {'甄士隐'},
          cumulativeKnownCharacters: {'甄', '士', '隐'},
          introducedEvents: ['ev_ch1_1'],
        ),
        LadderLevel(
          levelNumber: 1,
          title: 'Level 1',
          difficultyFloor: 1.5,
          difficultyCeiling: 2.0,
          passages: [p2],
          cumulativeKnownWords: {'甄士隐', '贾雨村', '风尘'},
          cumulativeKnownCharacters: {'甄', '士', '隐', '贾', '村', '尘'},
          introducedEvents: ['ev_ch1_2'],
        ),
      ],
    );

    final portfolio = StoryPortfolio(
      portfolioId: 'portfolio_test',
      sourceId: '红楼梦',
      sourceContentHash: 'sample_hash',
      pipelineVersion: '3.0.0',
      createdAt: DateTime.now().toIso8601String(),
      ladder: sampleLadder,
    );

    testWidgets(
      'renders first passage without buttons, advances on tap, and updates learner state',
      (tester) async {
        V3ReaderSessionState? latestSession;

        await tester.pumpWidget(
          MaterialApp(
            home: V3PortfolioReader(
              portfolio: portfolio,
              onProgress: (session) {
                latestSession = session;
              },
            ),
          ),
        );

        // Verify Level 0, Passage 1 is displayed
        expect(find.text('这是甄士隐的故事。'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNothing);
        expect(find.byType(IconButton), findsNothing);

        // Tap screen to advance
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Verify Level 1, Passage 2 is now displayed
        expect(find.text('贾雨村在风尘之中。'), findsOneWidget);
        expect(latestSession, isNotNull);
        expect(
          latestSession!.learnerState.linguistic.knownWords,
          contains('甄士隐'),
        );
        expect(
          latestSession!.learnerState.narrative.encounteredEvents,
          contains('ev_ch1_1'),
        );

        // Tap screen again to reach completion
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Verify serene completion mark '完'
        expect(find.text('完'), findsOneWidget);
        expect(latestSession!.completed, isTrue);
        expect(
          latestSession!.learnerState.linguistic.knownWords,
          contains('贾雨村'),
        );
        expect(
          latestSession!.learnerState.narrative.encounteredEvents,
          contains('ev_ch1_2'),
        );

        // Test swipe back / previous navigation
        await tester.fling(
          find.byType(GestureDetector).first,
          const Offset(300, 0),
          1000,
        );
        await tester.pumpAndSettle();

        // Should return to Level 1 Passage 2
        expect(find.text('贾雨村在风尘之中。'), findsOneWidget);

        // Swipe back again to Level 0 Passage 1
        await tester.fling(
          find.byType(GestureDetector).first,
          const Offset(300, 0),
          1000,
        );
        await tester.pumpAndSettle();

        expect(find.text('这是甄士隐的故事。'), findsOneWidget);
      },
    );
  });
}
