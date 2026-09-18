/// The parsed shape of one documentation page, and the splitter that produces
/// it — `T-085` parts 2 and 3.
///
/// Nothing here renders. A [DabblerDocPage] is data: the gallery's rendering
/// layer maps its blocks onto the existing `GalleryUsage` / `GallerySectionLabel`
/// / `GalleryRule` widgets and restyles nothing in `gallery_page.dart`
/// (`D-041`(c)4). Keeping the parse pure is what makes it unit-testable without
/// a widget, which is what `cto` asked for.
///
/// Nothing here throws, either. A page that cannot be read or cannot be parsed
/// comes back as a page carrying [DabblerDocPage.error] and one visible
/// "not available" section — never as an exception crossing the layer boundary.
library;

import 'doc_vocabulary.dart';

/// One piece of a section's body.
///
/// Sealed in practice: a block is either prose ([DabblerDocProse]) or a
/// block-level specimen reference ([DabblerDocSpecimen]).
sealed class DabblerDocBlock {
  const DabblerDocBlock();
}

/// A run of markdown prose, exactly as authored, with the surrounding blank
/// lines trimmed.
///
/// Inline `**bold**` and `` `code` `` are left in place: `GalleryUsage.markup`
/// already owns that two-token contract and this splitter deliberately does not
/// duplicate or extend it (`D-041`(c)4).
class DabblerDocProse extends DabblerDocBlock {
  /// Creates a prose block.
  const DabblerDocProse(this.markup);

  /// The raw markdown of this block.
  final String markup;

  @override
  String toString() => 'DabblerDocProse(${markup.length} chars)';
}

/// A block-level `@specimen <id>` line.
///
/// **Block level only** — its own line inside a section, never inline. That is
/// `D-042`(g) endorsing `T-085`'s design call, and the reason
/// `GalleryUsage.markup`'s regex stays untouched.
///
/// The [id] is a stable slug on `GalleryEntry`, not a title: a title is prose
/// that `cxo` and `content-manager` revise, and a reference keyed on prose
/// breaks precisely when the prose improves.
class DabblerDocSpecimen extends DabblerDocBlock {
  /// Creates a specimen reference.
  const DabblerDocSpecimen(this.id);

  /// The referenced entry's stable id, as written after `@specimen`.
  final String id;

  @override
  String toString() => 'DabblerDocSpecimen($id)';
}

/// One `## ` section of a page.
class DabblerDocSection {
  /// Creates a section.
  const DabblerDocSection({required this.heading, required this.blocks});

  /// The heading text, with the leading `## ` and surrounding space removed.
  final String heading;

  /// The section's body, in document order.
  final List<DabblerDocBlock> blocks;

  /// Whether this heading is in the vocabulary for [kind].
  ///
  /// Always `true` for an ungoverned kind. This answers *recognised*, not
  /// *correctly ordered* — ordering and the required/optional gate are
  /// `KAN-324`'s, reading the same [DabblerDocVocabulary].
  bool isRecognisedFor(DabblerDocPageKind kind) {
    if (!DabblerDocVocabulary.isGoverned(kind)) {
      return true;
    }
    return DabblerDocVocabulary.forKind(kind)
        .any((DabblerDocHeading h) => h.text == heading);
  }

  /// Every specimen id referenced in this section, in document order.
  List<String> get specimenIds => blocks
      .whereType<DabblerDocSpecimen>()
      .map((DabblerDocSpecimen s) => s.id)
      .toList(growable: false);
}

/// A parsed documentation page.
class DabblerDocPage {
  /// Creates a parsed page.
  const DabblerDocPage({
    required this.assetPath,
    required this.kind,
    required this.title,
    required this.lead,
    required this.sections,
    this.error,
  });

  /// A page that could not be read or parsed.
  ///
  /// Carries one visible section so the gallery shows the failure in place
  /// rather than an empty page or a crash (`T-085` part 2).
  factory DabblerDocPage.unavailable(String assetPath, String reason) {
    return DabblerDocPage(
      assetPath: assetPath,
      kind: DabblerDocVocabulary.kindForAssetPath(assetPath),
      title: 'Page not available',
      lead: const <DabblerDocProse>[],
      sections: <DabblerDocSection>[
        DabblerDocSection(
          heading: 'Page not available',
          blocks: <DabblerDocBlock>[
            DabblerDocProse('`$assetPath` could not be loaded — $reason'),
          ],
        ),
      ],
      error: reason,
    );
  }

  /// The asset path this page was loaded from.
  final String assetPath;

  /// The page kind, derived from [assetPath].
  final DabblerDocPageKind kind;

  /// The `# ` title, or `null` where the page has none.
  final String? title;

  /// The unheaded lead prose between the title and the first `## `.
  ///
  /// `D-042`(a): exactly two paragraphs, the first a single sentence — the
  /// Definition, then the Intro. Neither gets a heading. This splitter
  /// *preserves* them; it does not enforce the count, which is `KAN-324`'s gate.
  final List<DabblerDocProse> lead;

  /// The `## ` sections, in document order.
  final List<DabblerDocSection> sections;

  /// Why this page is unavailable, or `null` when it parsed.
  final String? error;

  /// Whether this page failed to load or parse.
  bool get isUnavailable => error != null;

  /// Every specimen id on the page, in document order, duplicates kept.
  List<String> get specimenIds => <String>[
        for (final DabblerDocSection section in sections)
          ...section.specimenIds,
      ];
}

/// Turns one page's markdown into its ordered sections.
///
/// Pure and synchronous: no bundle, no widget, no I/O. [DabblerDocLoader] is the
/// only thing that reads an asset, and it hands the body here.
abstract final class DabblerDocSplitter {
  static final RegExp _provenance = RegExp(r'^\s*<!--.*?-->', dotAll: true);
  static final RegExp _specimen = RegExp(r'^@specimen[ \t]+(\S+)[ \t]*$');

  /// Removes the leading HTML provenance comment, which is never rendered.
  ///
  /// Only a comment at the very start of the file is stripped, and only the
  /// first one: a `<!-- -->` further down is body content and stays.
  static String stripProvenanceComment(String raw) {
    final Match? match = _provenance.matchAsPrefix(raw);
    if (match == null) {
      return raw;
    }
    return raw.substring(match.end).replaceFirst(RegExp(r'^\r?\n'), '');
  }

  /// Splits [raw] into a page.
  ///
  /// [assetPath] only supplies [DabblerDocPage.kind] and is not read from disk.
  static DabblerDocPage split(String assetPath, String raw) {
    final String body = stripProvenanceComment(raw);
    final List<String> lines = body.split('\n');

    String? title;
    final List<String> leadLines = <String>[];
    final List<DabblerDocSection> sections = <DabblerDocSection>[];

    String? heading;
    List<String> sectionLines = <String>[];

    void closeSection() {
      if (heading != null) {
        sections.add(
          DabblerDocSection(
            heading: heading,
            blocks: _blocks(sectionLines),
          ),
        );
      }
      sectionLines = <String>[];
    }

    for (final String line in lines) {
      if (heading == null && title == null && line.startsWith('# ')) {
        title = line.substring(2).trim();
        continue;
      }
      if (line.startsWith('## ')) {
        closeSection();
        heading = line.substring(3).trim();
        continue;
      }
      if (heading == null) {
        leadLines.add(line);
      } else {
        sectionLines.add(line);
      }
    }
    closeSection();

    return DabblerDocPage(
      assetPath: assetPath,
      kind: DabblerDocVocabulary.kindForAssetPath(assetPath),
      title: title,
      lead: _blocks(leadLines).whereType<DabblerDocProse>().toList(),
      sections: sections,
    );
  }

  /// Groups [lines] into prose paragraphs and block-level specimen references.
  static List<DabblerDocBlock> _blocks(List<String> lines) {
    final List<DabblerDocBlock> blocks = <DabblerDocBlock>[];
    final List<String> buffer = <String>[];

    void flush() {
      final String text = buffer.join('\n').trim();
      buffer.clear();
      if (text.isNotEmpty) {
        blocks.add(DabblerDocProse(text));
      }
    }

    for (final String line in lines) {
      final Match? specimen = _specimen.firstMatch(line.trimRight());
      if (specimen != null) {
        flush();
        blocks.add(DabblerDocSpecimen(specimen.group(1)!));
        continue;
      }
      if (line.trim().isEmpty) {
        flush();
        continue;
      }
      buffer.add(line);
    }
    flush();
    return blocks;
  }
}
