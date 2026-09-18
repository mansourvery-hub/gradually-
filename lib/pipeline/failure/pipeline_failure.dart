/// Standard machine-readable failure error codes across the V3 pipeline (Contract 13).
enum PipelineErrorCode {
  // Ingestion (1000s)
  sourceFileNotFound(1001, 'Source novel TXT file not found'),
  sourceEncodingInvalid(1002, 'Source file encoding could not be resolved'),
  sourceEmpty(1003, 'Source novel content is empty'),
  sourceStructureInvalid(
    1004,
    'Failed to identify chapter structure or headers',
  ),

  // Canonical Extraction (2000s)
  canonicalExtractionFailed(2001, 'Failed to extract canonical story model'),
  canonicalProvenanceMissing(
    2002,
    'Extracted entity or event missing source provenance',
  ),
  canonicalOffsetMismatch(
    2003,
    'Raw character offset does not match source text snippet',
  ),

  // Linguistic Profiling (3000s)
  linguisticSegmentationFailed(3001, 'Tokenizer failed to segment text'),
  linguisticProfileCorrupt(
    3002,
    'Linguistic frequency profile is empty or corrupted',
  ),

  // Narrative Planning (4000s)
  narrativeTargetUnreachable(
    4001,
    'All unexposed narrative targets have unresolvable prerequisites',
  ),
  narrativeGraphCyclic(
    4002,
    'Detected cyclical dependencies in narrative graph',
  ),

  // Controlled Generation (5000s)
  generationFailed(5001, 'Controlled generator failed to produce output'),
  generationQuotaExceeded(5002, 'Exceeded maximum regeneration retries'),

  // Validation Stack (6000s)
  validationDeterministicFailed(
    6001,
    'Failed Layer A deterministic check (empty, english, leak, etc.)',
  ),
  validationLinguisticFailed(
    6002,
    'Failed Layer B linguistic check (non-Chinese, punctuation, budget)',
  ),
  validationGroundingFailed(
    6003,
    'Failed Layer C source grounding check (hallucination)',
  ),
  validationNarrativeFailed(
    6004,
    'Failed Layer D narrative coherence check (event mismatch, duplicate)',
  ),
  validationJudgeFailed(6005, 'Failed Layer E independent judge check'),

  // Portfolio & Persistence (7000s)
  portfolioCorrupted(7001, 'Stored portfolio file is corrupted or unreadable'),
  portfolioHashMismatch(
    7002,
    'Portfolio source hash does not match current source artifact',
  ),
  portfolioVersionOutdated(7003, 'Portfolio pipeline version is incompatible');

  const PipelineErrorCode(this.code, this.message);

  final int code;
  final String message;
}

/// Structured, machine-readable pipeline exception enforcing fail-closed boundaries.
class PipelineFailureException implements Exception {
  PipelineFailureException({
    required this.code,
    required this.details,
    this.stage = 'pipeline',
    this.sourceEvidenceSnippet,
    this.retryable = false,
  });

  final PipelineErrorCode code;
  final String details;
  final String stage;
  final String? sourceEvidenceSnippet;
  final bool retryable;

  Map<String, dynamic> toJson() => {
    'code': code.code,
    'codeName': code.name,
    'message': code.message,
    'details': details,
    'stage': stage,
    'sourceEvidenceSnippet': sourceEvidenceSnippet,
    'retryable': retryable,
  };

  @override
  String toString() =>
      'PipelineFailureException [${code.code} ${code.name}]: $details (stage: $stage, retryable: $retryable)';
}

/// A fail-closed retry wrapper with deterministic backoff and limit.
class FailClosedRetryPolicy {
  const FailClosedRetryPolicy({this.maxRetries = 3});

  final int maxRetries;

  /// Executes [action], automatically retrying on retryable failures up to [maxRetries].
  /// Fail-closed: rethrows structured [PipelineFailureException] if limit exceeded.
  T run<T>({
    required String actionName,
    required T Function(int attempt) action,
    required bool Function(T result) isValid,
    required PipelineErrorCode failureCodeOnExhaustion,
  }) {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final result = action(attempt);
        if (isValid(result)) {
          return result;
        }
      } catch (e) {
        if (attempt == maxRetries) {
          throw PipelineFailureException(
            code: failureCodeOnExhaustion,
            details:
                'Action "$actionName" failed after $maxRetries attempts. Last error: $e',
            stage: actionName,
            retryable: false,
          );
        }
      }
    }

    throw PipelineFailureException(
      code: failureCodeOnExhaustion,
      details:
          'Action "$actionName" failed to produce a valid result after $maxRetries attempts.',
      stage: actionName,
      retryable: false,
    );
  }
}
