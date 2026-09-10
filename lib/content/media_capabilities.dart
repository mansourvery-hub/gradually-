library;

import '../reader/audio_controller.dart';
import 'content.dart';

/// Describes the optional media declared by a content section.
class SectionMediaCapability {
  final String contentId;
  final String sectionId;
  final String? audioAssetId;

  const SectionMediaCapability({
    required this.contentId,
    required this.sectionId,
    this.audioAssetId,
  });
}

/// Builds a [MediaCapability] list from content items' optional metadata.
///
/// Returns an empty list when no media capabilities are declared,
/// allowing the reader to function without any media.
List<MediaCapability> buildMediaCapabilities(Iterable<ContentItem> items) {
  final result = <MediaCapability>[];
  for (final item in items) {
    for (final section in item.sections) {
      final audioId = section.audioAsset;
      if (audioId != null) {
        result.add(MediaCapability(contentId: item.id, audioAssetId: audioId));
      }
    }
  }
  return result;
}

/// Returns true if the content item declares any audio capabilities.
bool hasMediaCapabilities(ContentItem item) {
  return item.sections.any((s) => s.audioAsset != null);
}
