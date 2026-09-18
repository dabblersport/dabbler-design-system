/// The authored heading vocabulary for the documentation corpus — `D-042`.
///
/// **This is the one list.** `T-085`'s acceptance criterion 4 requires the
/// splitter and the `flutter test` gate (`KAN-324`) to recognise the same
/// vocabulary from the same place: two independent lists drift, and a gate that
/// accepts what the splitter rejects is worse than no gate. Anything needing to
/// know what a legal `##` is reads [DabblerDocVocabulary], never a literal.
///
/// The list is **authored, not derived** (`D-042` preamble): the 59 pages on
/// disk are evidence of intent and not authority — `content-manager`'s sweeps
/// found three with sections out of order and four with a section dropped. It is
/// transcribed from `D-042`(b)–(e), not read off the pages.
library;

/// What kind of page a documentation file is, which decides its vocabulary.
enum DabblerDocPageKind {
  /// `assets/documentation/components/*.md` — `D-042`(b), seven headings.
  component,

  /// `assets/documentation/foundations/*.md` — `D-042`(c), six headings.
  ///
  /// `Tokens used` is **not** in this vocabulary at all (`D-034`(a)); its
  /// presence on a Foundations page is the error, not merely unrecognised.
  foundations,

  /// `assets/documentation/patterns/*.md` — `D-042`(d), four headings.
  ///
  /// A pattern page is not a component page and must not be dressed as one: no
  /// `Using it`, no `Tokens used`, no `Direction`, no `Source`.
  patterns,

  /// `start-here.md` — `D-042`(e), exempt from the vocabulary and from nothing
  /// else. It is still bound by the lead-prose rule and by `@specimen`
  /// resolution.
  exempt,

  /// `_order.md` — not a page at all (`D-042`(e)). Exempt entirely, including
  /// the lead-prose rule.
  notAPage,
}

/// One `##` heading in a page kind's vocabulary, in its ruled position.
class DabblerDocHeading {
  /// Creates a heading entry.
  const DabblerDocHeading(this.text, {required this.required});

  /// The exact string, sentence case, no trailing punctuation, no variants —
  /// `## Using it`, never `## Usage` or `## Using It` (`D-042`(f)).
  final String text;

  /// Whether every page of this kind must carry it.
  ///
  /// Optional means **omitted, never emptied** (`D-042`(f)): a present heading
  /// with no body under it fails the gate.
  final bool required;

  @override
  String toString() => text;
}

/// The heading vocabulary, and the mapping from an asset path to a page kind.
abstract final class DabblerDocVocabulary {
  /// `D-042`(b) — component page, seven headings in this order.
  static const List<DabblerDocHeading> component = <DabblerDocHeading>[
    DabblerDocHeading('Specimen', required: true),
    DabblerDocHeading('Using it', required: true),
    DabblerDocHeading('Axes', required: false),
    DabblerDocHeading('Direction', required: false),
    DabblerDocHeading('Tokens used', required: true),
    DabblerDocHeading('Change log', required: false),
    DabblerDocHeading('Source', required: true),
  ];

  /// `D-042`(c) — foundations page, six headings in this order.
  static const List<DabblerDocHeading> foundations = <DabblerDocHeading>[
    DabblerDocHeading('Specimen', required: true),
    DabblerDocHeading('Using it', required: true),
    DabblerDocHeading('Axes', required: false),
    DabblerDocHeading('Direction', required: false),
    DabblerDocHeading('Change log', required: false),
    DabblerDocHeading('Source', required: true),
  ];

  /// `D-042`(d) — patterns page, four headings in this order.
  static const List<DabblerDocHeading> patterns = <DabblerDocHeading>[
    DabblerDocHeading('Choosing', required: true),
    DabblerDocHeading('Specimen', required: false),
    DabblerDocHeading('Related', required: true),
    DabblerDocHeading('Change log', required: false),
  ];

  /// The vocabulary for [kind], in the ruled order.
  ///
  /// Empty for [DabblerDocPageKind.exempt] and [DabblerDocPageKind.notAPage] —
  /// "a vocabulary for a single page is a list with one member" (`D-042`(e)).
  /// An empty vocabulary means *unconstrained*, not *no headings allowed*; a
  /// consumer that treats empty as "reject everything" has misread the ruling.
  static List<DabblerDocHeading> forKind(DabblerDocPageKind kind) {
    switch (kind) {
      case DabblerDocPageKind.component:
        return component;
      case DabblerDocPageKind.foundations:
        return foundations;
      case DabblerDocPageKind.patterns:
        return patterns;
      case DabblerDocPageKind.exempt:
      case DabblerDocPageKind.notAPage:
        return const <DabblerDocHeading>[];
    }
  }

  /// Whether [kind] is bound by the vocabulary at all.
  static bool isGoverned(DabblerDocPageKind kind) =>
      forKind(kind).isNotEmpty;

  /// The root every documentation asset path sits under.
  static const String assetRoot = 'assets/documentation';

  /// The page kind implied by an asset path, by the directory it sits in.
  ///
  /// Accepts a full asset path (`assets/documentation/components/button.md`) or
  /// one relative to [assetRoot] (`components/button.md`). An unrecognised
  /// directory is [DabblerDocPageKind.exempt] rather than a throw — this is a
  /// classifier, not a gate, and the gate (`KAN-324`) reports the unknown path
  /// as its own finding.
  static DabblerDocPageKind kindForAssetPath(String path) {
    final String normalised = path.startsWith('$assetRoot/')
        ? path.substring(assetRoot.length + 1)
        : path;
    final int slash = normalised.indexOf('/');
    if (slash < 0) {
      return normalised == '_order.md'
          ? DabblerDocPageKind.notAPage
          : DabblerDocPageKind.exempt;
    }
    switch (normalised.substring(0, slash)) {
      case 'components':
        return DabblerDocPageKind.component;
      case 'foundations':
        return DabblerDocPageKind.foundations;
      case 'patterns':
        return DabblerDocPageKind.patterns;
      default:
        return DabblerDocPageKind.exempt;
    }
  }
}
