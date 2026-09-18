import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../learner/v3_learner_state.dart';
import '../pipeline/generation/generated_passage.dart';
import '../pipeline/ladder/ladder_model.dart';
import '../pipeline/portfolio/portfolio_manager.dart';

/// State of the V3 Portfolio Reader session.
class V3ReaderSessionState {
  const V3ReaderSessionState({
    required this.portfolio,
    required this.currentLevelIndex,
    required this.currentPassageIndex,
    required this.learnerState,
    this.completed = false,
  });

  final StoryPortfolio portfolio;
  final int currentLevelIndex;
  final int currentPassageIndex;
  final V3LearnerState learnerState;
  final bool completed;

  LadderLevel? get currentLevel {
    if (currentLevelIndex < portfolio.ladder.levels.length) {
      return portfolio.ladder.levels[currentLevelIndex];
    }
    return null;
  }

  GeneratedPassage? get currentPassage {
    final level = currentLevel;
    if (level != null && currentPassageIndex < level.passages.length) {
      return level.passages[currentPassageIndex];
    }
    return null;
  }

  V3ReaderSessionState advance() {
    final level = currentLevel;
    if (level == null) {
      return copyWith(completed: true);
    }

    final passage = currentPassage;
    V3LearnerState updatedLearner = learnerState;

    if (passage != null) {
      final updatedLinguistic = learnerState.linguistic.recordLearnedWords(
        passage.newWords.toSet(),
        newDifficulty: passage.difficultyEstimate,
      );
      final updatedNarrative = learnerState.narrative.recordEventExposed(
        eventId: passage.targetEventId,
        chapterIndex: passage.chapterIndex,
      );
      updatedLearner = learnerState.copyWith(
        linguistic: updatedLinguistic,
        narrative: updatedNarrative,
      );
    }

    if (currentPassageIndex + 1 < level.passages.length) {
      return V3ReaderSessionState(
        portfolio: portfolio,
        currentLevelIndex: currentLevelIndex,
        currentPassageIndex: currentPassageIndex + 1,
        learnerState: updatedLearner,
        completed: false,
      );
    } else if (currentLevelIndex + 1 < portfolio.ladder.levels.length) {
      return V3ReaderSessionState(
        portfolio: portfolio,
        currentLevelIndex: currentLevelIndex + 1,
        currentPassageIndex: 0,
        learnerState: updatedLearner,
        completed: false,
      );
    } else {
      return V3ReaderSessionState(
        portfolio: portfolio,
        currentLevelIndex: currentLevelIndex,
        currentPassageIndex: currentPassageIndex,
        learnerState: updatedLearner,
        completed: true,
      );
    }
  }

  /// Navigates to the previous passage or un-completes to review prior material.
  V3ReaderSessionState previous() {
    if (completed) {
      final lastLevelIdx = portfolio.ladder.levels.length - 1;
      final lastPassageIdx =
          portfolio.ladder.levels[lastLevelIdx].passages.length - 1;
      return copyWith(
        currentLevelIndex: lastLevelIdx,
        currentPassageIndex: lastPassageIdx,
        completed: false,
      );
    }
    if (currentPassageIndex > 0) {
      return copyWith(currentPassageIndex: currentPassageIndex - 1);
    } else if (currentLevelIndex > 0) {
      final prevLevelIdx = currentLevelIndex - 1;
      final prevLevel = portfolio.ladder.levels[prevLevelIdx];
      return copyWith(
        currentLevelIndex: prevLevelIdx,
        currentPassageIndex: prevLevel.passages.length - 1,
      );
    }
    return this;
  }

  V3ReaderSessionState copyWith({
    StoryPortfolio? portfolio,
    int? currentLevelIndex,
    int? currentPassageIndex,
    V3LearnerState? learnerState,
    bool? completed,
  }) => V3ReaderSessionState(
    portfolio: portfolio ?? this.portfolio,
    currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
    currentPassageIndex: currentPassageIndex ?? this.currentPassageIndex,
    learnerState: learnerState ?? this.learnerState,
    completed: completed ?? this.completed,
  );
}

/// A serene, button-free Flutter reading widget rendering verified V3 story portfolios.
class V3PortfolioReader extends StatefulWidget {
  const V3PortfolioReader({
    super.key,
    required this.portfolio,
    this.initialLearnerState,
    this.onProgress,
  });

  final StoryPortfolio portfolio;
  final V3LearnerState? initialLearnerState;
  final ValueChanged<V3ReaderSessionState>? onProgress;

  @override
  State<V3PortfolioReader> createState() => _V3PortfolioReaderState();
}

class _V3PortfolioReaderState extends State<V3PortfolioReader> {
  late V3ReaderSessionState _session;

  @override
  void initState() {
    super.initState();
    _session = V3ReaderSessionState(
      portfolio: widget.portfolio,
      currentLevelIndex: 0,
      currentPassageIndex: 0,
      learnerState:
          widget.initialLearnerState ??
          const V3LearnerState(
            learnerId: 'v3_reader_learner',
            linguistic: LinguisticLearnerState(
              knownCharacters: {},
              knownWords: {},
              estimatedDifficulty: 1.0,
            ),
            narrative: NarrativeLearnerState(),
          ),
    );
  }

  void _handleTap() {
    if (_session.completed) return;
    setState(() {
      _session = _session.advance();
      widget.onProgress?.call(_session);
    });
  }

  void _handleSwipeRight() {
    setState(() {
      _session = _session.previous();
      widget.onProgress?.call(_session);
    });
  }

  @override
  Widget build(BuildContext context) {
    final passage = _session.currentPassage;

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _handleTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 200) {
              _handleSwipeRight();
            } else if (details.primaryVelocity != null &&
                details.primaryVelocity! < -200) {
              _handleTap();
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFFBF9F5), // Serene parchment
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 24.0,
                  ),
                  child: _session.completed
                      ? const Text(
                          '完',
                          style: TextStyle(
                            fontSize: 48,
                            fontFamily: 'NotoSerifSC',
                            fontFamilyFallback: [
                              'PingFang SC',
                              'Hiragino Sans GB',
                              'Microsoft YaHei',
                              'WenQuanYi Micro Hei',
                              'Noto Sans CJK SC',
                              'NotoSansSC',
                              'serif',
                            ],
                            color: Color(0xFF2C2C2C),
                          ),
                        )
                      : passage == null
                      ? const SizedBox.shrink()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              passage.generatedText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                height: 1.8,
                                letterSpacing: 2.0,
                                fontFamily: 'NotoSerifSC',
                                fontFamilyFallback: [
                                  'PingFang SC',
                                  'Hiragino Sans GB',
                                  'Microsoft YaHei',
                                  'WenQuanYi Micro Hei',
                                  'Noto Sans CJK SC',
                                  'NotoSansSC',
                                  'serif',
                                ],
                                color: Color(0xFF1F1F1F),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
