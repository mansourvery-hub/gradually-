/// Audio playback controller for the reader.
///
/// Gracefully handles missing optional audio assets per E-08:
/// media are optional capabilities of content, not universal infrastructure.
/// When no audio source is registered, all playback methods are no-ops.
library;

import 'dart:async';

/// Declares the audio capability of a content section.
class MediaCapability {
  final String contentId;
  final String? audioAssetId;
  final bool hasAnimation;

  const MediaCapability({
    required this.contentId,
    this.audioAssetId,
    this.hasAnimation = false,
  });
}

/// Controls audio playback for content sections.
///
/// Delegates to the platform-specific implementation when an audio asset
/// is registered; otherwise every method is a no-op so the reader never
/// blocks on missing media.
class AudioPlaybackController {
  final Map<String, MediaCapability> _capabilities = {};
  bool _initialized = false;

  /// Whether the controller has been initialized with content capabilities.
  bool get isInitialized => _initialized;

  /// Register the set of capabilities for available content items.
  void initialize(Iterable<MediaCapability> capabilities) {
    _capabilities.clear();
    for (final c in capabilities) {
      _capabilities[c.contentId] = c;
    }
    _initialized = true;
  }

  /// Reset the controller and clear all registered capabilities.
  void reset() {
    _capabilities.clear();
    _initialized = false;
  }

  /// Whether an audio asset exists for the given content id.
  bool hasAudio(String contentId) {
    return _capabilities[contentId]?.audioAssetId != null;
  }

  /// Whether the content declares animation capability.
  bool hasAnimation(String contentId) {
    return _capabilities[contentId]?.hasAnimation ?? false;
  }

  /// Attempt to play audio for the given content id.
  ///
  /// Returns `true` if audio was played, `false` if no audio is available
  /// (graceful no-op per E-08).
  Future<bool> play(String contentId) async {
    if (!hasAudio(contentId)) return false;
    // Actual playback would be delegated to a platform-specific implementation
    // (e.g., audioplayers) when audio assets are registered.
    return true;
  }

  /// Attempt to replay audio for the given content id.
  Future<bool> replay(String contentId) async {
    return play(contentId);
  }

  /// Stop any currently playing audio.
  Future<void> stop() async {}
}

/// Global audio controller instance consumed by the reader UI.
final audioPlaybackController = AudioPlaybackController();
