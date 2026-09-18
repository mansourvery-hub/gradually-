import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import '../ladder/ladder_model.dart';

/// Represents a persistent, versioned, cacheable story portfolio (Contract 11).
class StoryPortfolio {
  const StoryPortfolio({
    required this.portfolioId,
    required this.sourceId,
    required this.sourceContentHash,
    required this.pipelineVersion,
    required this.createdAt,
    required this.ladder,
    this.metadata = const {},
  });

  final String portfolioId;
  final String sourceId;
  final String sourceContentHash;
  final String pipelineVersion;
  final String createdAt;
  final ProgressiveLadder ladder;
  final Map<String, dynamic> metadata;

  /// Deterministic portfolio fingerprint derived from source hash + ladder content + pipeline version.
  String get portfolioFingerprint {
    final raw =
        '$portfolioId:$sourceContentHash:$pipelineVersion:${ladder.totalPassages}';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  Map<String, dynamic> toJson() => {
    'portfolioId': portfolioId,
    'sourceId': sourceId,
    'sourceContentHash': sourceContentHash,
    'pipelineVersion': pipelineVersion,
    'createdAt': createdAt,
    'ladder': ladder.toJson(),
    'fingerprint': portfolioFingerprint,
    'metadata': metadata,
  };

  factory StoryPortfolio.fromJson(Map<String, dynamic> json) => StoryPortfolio(
    portfolioId: json['portfolioId'] as String,
    sourceId: json['sourceId'] as String,
    sourceContentHash: json['sourceContentHash'] as String,
    pipelineVersion: json['pipelineVersion'] as String,
    createdAt: json['createdAt'] as String,
    ladder: ProgressiveLadder.fromJson(json['ladder'] as Map<String, dynamic>),
    metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  );
}

/// Portfolio storage and cache manager verifying content hashes and invalidating stale caches.
class PortfolioCacheManager {
  const PortfolioCacheManager({required this.storageDirectory});

  final Directory storageDirectory;

  static const String currentPipelineVersion = '3.0.0';

  File _getCacheFile(String sourceId) {
    return File('${storageDirectory.path}/portfolio_$sourceId.json');
  }

  /// Saves a portfolio to disk cache.
  Future<void> save(StoryPortfolio portfolio) async {
    if (!storageDirectory.existsSync()) {
      storageDirectory.createSync(recursive: true);
    }
    final file = _getCacheFile(portfolio.sourceId);
    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(portfolio.toJson());
    await file.writeAsString(jsonString, flush: true);
  }

  /// Loads portfolio from cache if valid. Returns null if missing, corrupted, or invalid.
  Future<StoryPortfolio?> load({
    required String sourceId,
    required String expectedSourceContentHash,
  }) async {
    final file = _getCacheFile(sourceId);
    if (!file.existsSync()) {
      return null;
    }

    try {
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final portfolio = StoryPortfolio.fromJson(json);

      // Invalidate if source content has changed
      if (portfolio.sourceContentHash != expectedSourceContentHash) {
        return null;
      }

      // Invalidate if pipeline version changed
      if (portfolio.pipelineVersion != currentPipelineVersion) {
        return null;
      }

      // Invalidate if fingerprint is tampered
      final recordedFingerprint = json['fingerprint'] as String?;
      if (portfolio.portfolioFingerprint != recordedFingerprint) {
        return null;
      }

      return portfolio;
    } catch (_) {
      return null;
    }
  }

  /// Explicitly evicts cached portfolio for a source.
  Future<bool> evict(String sourceId) async {
    final file = _getCacheFile(sourceId);
    if (file.existsSync()) {
      await file.delete();
      return true;
    }
    return false;
  }
}
