import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/pipeline/failure/pipeline_failure.dart';

void main() {
  group('Contract 13: Failure Handling & Fail-Closed Policies', () {
    test('PipelineErrorCode maps unique integer codes and descriptions', () {
      final codes = PipelineErrorCode.values.map((e) => e.code).toSet();
      expect(
        codes.length,
        PipelineErrorCode.values.length,
        reason: 'All codes must be unique',
      );

      const err = PipelineErrorCode.validationGroundingFailed;
      expect(err.code, 6003);
      expect(err.message, contains('source grounding'));
    });

    test('PipelineFailureException serializes machine-readable JSON', () {
      final ex = PipelineFailureException(
        code: PipelineErrorCode.validationDeterministicFailed,
        details: 'English word found in generated sentence',
        stage: 'validation_layer_a',
        sourceEvidenceSnippet: '甄士隐梦幻识通灵',
        retryable: true,
      );

      final json = ex.toJson();
      expect(json['code'], 6001);
      expect(json['codeName'], 'validationDeterministicFailed');
      expect(json['details'], contains('English word'));
      expect(json['stage'], 'validation_layer_a');
      expect(json['retryable'], isTrue);
      expect(ex.toString(), contains('6001'));
    });

    test('FailClosedRetryPolicy succeeds on early attempt', () {
      const policy = FailClosedRetryPolicy(maxRetries: 3);
      int attempts = 0;

      final result = policy.run<String>(
        actionName: 'test_action',
        action: (att) {
          attempts++;
          return 'success_on_$att';
        },
        isValid: (res) => attempts >= 2,
        failureCodeOnExhaustion: PipelineErrorCode.generationQuotaExceeded,
      );

      expect(result, 'success_on_2');
      expect(attempts, 2);
    });

    test(
      'FailClosedRetryPolicy enforces fail-closed boundary and throws on exhaustion',
      () {
        const policy = FailClosedRetryPolicy(maxRetries: 3);
        int attempts = 0;

        expect(
          () => policy.run<String>(
            actionName: 'stubborn_failure',
            action: (att) {
              attempts++;
              return 'invalid_output';
            },
            isValid: (_) => false, // Never valid
            failureCodeOnExhaustion: PipelineErrorCode.generationQuotaExceeded,
          ),
          throwsA(
            isA<PipelineFailureException>()
                .having(
                  (e) => e.code,
                  'code',
                  PipelineErrorCode.generationQuotaExceeded,
                )
                .having((e) => e.retryable, 'retryable', isFalse)
                .having(
                  (e) => e.details,
                  'details',
                  contains('after 3 attempts'),
                ),
          ),
        );

        expect(attempts, 3);
      },
    );
  });
}
