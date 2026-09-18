/// The pedagogical classification of a content item (CONTENT.md §2).
///
/// A shared abstraction across content types: one schema, one repository,
/// one selector. New formats join the enum; they never grow parallel
/// hardcoded systems (CONTENT IS DATA).
library;

/// Classification of content items in the corpus.
enum ContentType {
  /// Atomic beginner unit (concept/visual + native sound + Hanzi + tone).
  beginnerUnit,

  /// Single standalone sentence (minimal exposure building block).
  sentence,

  /// Visual-heavy narrated micro-story.
  microStory,

  /// Graded children's or cultural story.
  story,

  /// Dialogue / conversational exchange.
  dialogue,

  /// Plain native text / article.
  article;

  /// Parses from the JSON schema name; unknown values degrade to
  /// [article] rather than throwing (content is data — new data must not
  /// crash an older reader).
  static ContentType fromName(String name) {
    for (final t in values) {
      if (t.name == name) return t;
    }
    return article;
  }
}

/// Availability of a content item in the running corpus.
///
/// Lets an editor park half-finished or retired items in the dataset
/// without the application ever needing to know (schema, not code).
enum ContentStatus {
  /// Selectable and readable.
  available,

  /// Loaded but excluded from selection (work in progress).
  draft,

  /// Kept for stable-id history but no longer offered.
  retired;

  static ContentStatus fromName(String name) {
    for (final s in values) {
      if (s.name == name) return s;
    }
    return available;
  }
}
