/// The reading order — `assets/documentation/_order.md` parsed into the
/// navigation tree, `KAN-328`.
///
/// ## Why this is a `part`, and why every type in it is private
///
/// `D-046`: the navigation is gallery chrome, not a component, and nothing new
/// reaches the barrel. A library of its own would either have to be exported
/// or carry an exemption per public name; as a `part` of `gallery_index.dart`
/// with private types it is neither — a part is not a library and is never
/// exported.
///
/// ## The file is the spine; this is not a taxonomy
///
/// `_order.md` is authored, not generated: D-033(a)'s four sections, D-033(b)'s
/// nine groups in the order building a screen actually goes, an editorial
/// one-liner per entry, and the Shells / Composed cards split inside group 2.
/// None of it is derivable from filenames and none is invented here — the
/// navigation is parsed from that file and from nothing else, because a
/// hand-written list in Dart would be a second spine and the two would drift.
///
/// ## Two views of ONE taxonomy, deliberately not merged (`cxo`, 2026-09-18)
///
/// [GalleryIndex._bands] groups **specimens** by `GalleryPurpose` and reaches
/// 45 distinct pages; this order carries **documentation pages** and reaches
/// 58. Strict containment, not a conflict: the nav navigates documentation so
/// it must reach a patterns page that has no specimen, and the index promises
/// specimens so it must not offer a tile for a page that has none. `cxo`
/// withdrew its earlier instruction to derive the nav from `_bands()`.
/// `D-044` is untouched — the nav does not band on `group` at all.
///
/// ## Never throws
///
/// A file that cannot be read or parsed comes back as [_DocOrder.unavailable],
/// which the rail renders as a visible reason. A broken spine is a visible
/// defect, not a crash.
part of 'gallery_index.dart';

/// One link in the reading order: a page, its title, and its one-line
/// editorial description.
class _DocOrderEntry {
  /// Creates an entry.
  const _DocOrderEntry({
    required this.title,
    required this.page,
    required this.description,
  });

  /// The link text — the component or foundation's name (`TopBar`, `Colour`).
  final String title;

  /// The corpus-relative page path, exactly as written
  /// (`components/top-bar.md`, `start-here.md`).
  final String page;

  /// The authored one-liner after the em dash, or `null` where the link
  /// carries none. Whitespace-joined across wrapped source lines.
  final String? description;
}

/// A named run of entries inside a group — `_order.md`'s `**Shells**` /
/// `**Composed cards**` split.
///
/// A group with no such split carries exactly one band whose [label] is `null`,
/// so a renderer never special-cases the common shape.
class _DocOrderBand {
  /// Creates a band.
  const _DocOrderBand({required this.label, required this.entries});

  /// The band's name, or `null` for a group that is not sub-split.
  final String? label;

  /// The entries, in authored order.
  final List<_DocOrderEntry> entries;
}

/// One `### ` group — the nine numbered purpose groups.
///
/// Sections that carry their bullets directly (`Foundations`, `Patterns`) are
/// given one implicit group named after the section, so every entry in the
/// model is reachable by the same section → group → band → entry walk.
class _DocOrderGroup {
  /// Creates a group.
  const _DocOrderGroup({
    required this.number,
    required this.name,
    required this.tagline,
    required this.intro,
    required this.bands,
  });

  /// The authored ordinal (`1` for Navigation), or `null` for an implicit
  /// group. **Not** the index: the number is written in the file.
  final int? number;

  /// The group's name, with the `N · ` prefix and the tagline removed.
  final String name;

  /// The clause after the heading's em dash — *orienting the user: where they
  /// are, and how they move* — or `null` where there is none.
  final String? tagline;

  /// The prose paragraphs between the heading and the first bullet.
  final List<String> intro;

  /// The entries, in one or more bands.
  final List<_DocOrderBand> bands;

  /// Every entry in this group, bands flattened, in authored order.
  List<_DocOrderEntry> get entries => <_DocOrderEntry>[
        for (final _DocOrderBand band in bands) ...band.entries,
      ];
}

/// One `## ` section — `Foundations`, `Components`, `Patterns`, and the
/// `How this is ordered` note, which has prose and no entries.
class _DocOrderSection {
  /// Creates a section.
  const _DocOrderSection({
    required this.title,
    required this.intro,
    required this.groups,
  });

  /// The heading text.
  final String title;

  /// The prose between the heading and the first group or bullet.
  final List<String> intro;

  /// The groups, in authored order. Empty for a prose-only section.
  final List<_DocOrderGroup> groups;

  /// Every entry under this section, in authored order.
  List<_DocOrderEntry> get entries => <_DocOrderEntry>[
        for (final _DocOrderGroup group in groups) ...group.entries,
      ];
}

/// The parsed reading order.
class _DocOrder {
  /// Creates a parsed order.
  const _DocOrder({
    required this.title,
    required this.lead,
    required this.sections,
    this.startHere,
    this.unavailableReason,
  });

  /// An order that could not be read or parsed.
  ///
  /// Renders as a visible reason rather than an empty navigation tree.
  factory _DocOrder.unavailable(String reason) => _DocOrder(
        title: 'Reading order',
        lead: const <String>[],
        sections: const <_DocOrderSection>[],
        unavailableReason: reason,
      );

  /// The `# ` title.
  final String title;

  /// The prose between the title and the first `## `.
  final List<String> lead;

  /// The sections, in authored order.
  final List<_DocOrderSection> sections;

  /// The one entry `_order.md` links from its lead prose rather than from a
  /// bullet — `start-here.md`.
  ///
  /// It is the 58th of the file's 58 links and the only one outside a section,
  /// which is why it is a field of its own rather than a section that does not
  /// exist. `null` when the lead links nothing.
  final _DocOrderEntry? startHere;

  /// Why this order is unavailable, or `null` when it parsed.
  final String? unavailableReason;

  /// Whether the file could not be read or parsed.
  bool get isUnavailable => unavailableReason != null;

  /// Every entry in the whole order, in authored order, [startHere] first.
  List<_DocOrderEntry> get entries => <_DocOrderEntry>[
        ?startHere,
        for (final _DocOrderSection section in sections)
          ...section.entries,
      ];

  /// The section a page belongs to, or `null` where nothing links it.
  _DocOrderSection? sectionOf(String page) {
    for (final _DocOrderSection section in sections) {
      if (section.entries.any((_DocOrderEntry e) => e.page == page)) {
        return section;
      }
    }
    return null;
  }

  /// The corpus-relative path of `_order.md` itself.
  static const String assetName = '_order.md';

  /// Parses the raw markdown of `_order.md`.
  ///
  /// Never throws: an input with no `# ` title or no sections comes back as
  /// [_DocOrder.unavailable].
  static _DocOrder parse(String raw) {
    final List<String> lines =
        DabblerDocSplitter.stripProvenanceComment(raw).split('\n');
    final _OrderBuilder builder = _OrderBuilder();
    for (final String line in lines) {
      builder.add(line);
    }
    return builder.build();
  }
}

/// `- [Title](path.md) — description`, description optional.
final RegExp _link = RegExp(r'^-\s+\[([^\]]+)\]\(([^)]+)\)\s*(?:—\s*(.*))?$');

/// An inline `[Title](path.md)` anywhere in a paragraph — the lead's one link.
final RegExp _inlineLink = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');

/// `**Shells**` on a line of its own.
final RegExp _bandLabel = RegExp(r'^\*\*(.+)\*\*$');

/// `### 1 · Navigation — orienting the user…`, ordinal and tagline optional.
final RegExp _groupHeading =
    RegExp(r'^(?:(\d+)\s*·\s*)?(.*?)(?:\s+—\s+(.*))?$');

/// Accumulates the line-by-line walk. Kept out of [_DocOrder] so the
/// model stays immutable and has no parse state on it.
class _OrderBuilder {
  String? _title;
  final List<String> _lead = <String>[];
  final List<_DocOrderSection> _sections = <_DocOrderSection>[];

  // The section being filled.
  String? _sectionTitle;
  List<String> _sectionIntro = <String>[];
  List<_DocOrderGroup> _groups = <_DocOrderGroup>[];

  // The group being filled. `_groupName == null` means bullets seen so far in
  // this section belong to the section's implicit group.
  int? _groupNumber;
  String? _groupName;
  String? _groupTagline;
  List<String> _groupIntro = <String>[];
  List<_DocOrderBand> _bands = <_DocOrderBand>[];

  // The band being filled.
  String? _bandLabelText;
  List<_DocOrderEntry> _entries = <_DocOrderEntry>[];

  // Prose and wrapped-link accumulation.
  final List<String> _paragraph = <String>[];
  _PendingEntry? _pending;

  void add(String raw) {
    final String line = raw.trimRight();
    final String trimmed = line.trim();

    if (trimmed.isEmpty) {
      _flushPending();
      _flushParagraph();
      return;
    }

    if (trimmed.startsWith('#')) {
      _flushPending();
      _flushParagraph();
      _heading(trimmed);
      return;
    }

    final RegExpMatch? link = _link.firstMatch(trimmed);
    if (link != null) {
      _flushPending();
      _flushParagraph();
      _pending = _PendingEntry(
        title: link.group(1)!.trim(),
        page: link.group(2)!.trim(),
        description: <String>[if (link.group(3)?.isNotEmpty ?? false)
          link.group(3)!.trim()],
      );
      return;
    }

    // A continuation of the bullet above: `_order.md` wraps its one-liners.
    if (_pending != null && raw.startsWith(' ')) {
      _pending!.description.add(trimmed);
      return;
    }
    _flushPending();

    final RegExpMatch? band = _bandLabel.firstMatch(trimmed);
    if (band != null && _paragraph.isEmpty) {
      _flushParagraph();
      _startBand(band.group(1)!.trim());
      return;
    }

    _paragraph.add(trimmed);
  }

  void _heading(String trimmed) {
    if (trimmed.startsWith('### ')) {
      _closeGroup();
      final RegExpMatch m = _groupHeading.firstMatch(trimmed.substring(4).trim())!;
      _groupNumber = int.tryParse(m.group(1) ?? '');
      _groupName = m.group(2)?.trim();
      _groupTagline = m.group(3)?.trim();
      return;
    }
    if (trimmed.startsWith('## ')) {
      _closeSection();
      _sectionTitle = trimmed.substring(3).trim();
      return;
    }
    if (trimmed.startsWith('# ')) {
      _title = trimmed.substring(2).trim();
    }
  }

  void _startBand(String label) {
    if (_entries.isNotEmpty || _bandLabelText != null) {
      _closeBand();
    }
    _bandLabelText = label;
  }

  void _closeBand() {
    if (_entries.isEmpty && _bandLabelText == null) return;
    _bands.add(
      _DocOrderBand(label: _bandLabelText, entries: _entries),
    );
    _bandLabelText = null;
    _entries = <_DocOrderEntry>[];
  }

  void _closeGroup() {
    _closeBand();
    if (_groupName == null && _bands.isEmpty && _groupIntro.isEmpty) return;
    _groups.add(
      _DocOrderGroup(
        number: _groupNumber,
        // An implicit group is named after its section — `Foundations` and
        // `Patterns` carry their bullets with no `### ` above them.
        name: _groupName ?? _sectionTitle ?? '',
        tagline: _groupTagline,
        intro: _groupIntro,
        bands: _bands,
      ),
    );
    _groupNumber = null;
    _groupName = null;
    _groupTagline = null;
    _groupIntro = <String>[];
    _bands = <_DocOrderBand>[];
  }

  void _closeSection() {
    _closeGroup();
    if (_sectionTitle == null) return;
    _sections.add(
      _DocOrderSection(
        title: _sectionTitle!,
        intro: _sectionIntro,
        groups: _groups,
      ),
    );
    _sectionTitle = null;
    _sectionIntro = <String>[];
    _groups = <_DocOrderGroup>[];
  }

  void _flushPending() {
    final _PendingEntry? pending = _pending;
    if (pending == null) return;
    _pending = null;
    _entries.add(
      _DocOrderEntry(
        title: pending.title,
        page: pending.page,
        description: pending.description.isEmpty
            ? null
            : pending.description.join(' '),
      ),
    );
  }

  /// Prose lands on whichever level is currently open — group, section, or the
  /// page lead — which is exactly where the file puts it.
  ///
  /// Inline links are flattened to their text. `GalleryUsage` renders the
  /// design's two inline treatments (`**bold**` and `` `code` ``) and nothing
  /// else, so a markdown link left intact renders as its own source —
  /// `[Start here](start-here.md)` on screen. The link's *destination* is not
  /// lost: it is read off the raw paragraph first, and becomes [startHere].
  void _flushParagraph() {
    if (_paragraph.isEmpty) return;
    final String raw = _paragraph.join(' ');
    final String text = raw.replaceAllMapped(
      _inlineLink,
      (Match m) => m.group(1)!,
    );
    _paragraph.clear();
    if (_sectionTitle == null && _groupName == null) {
      final RegExpMatch? link = _inlineLink.firstMatch(raw);
      if (link != null && _startHereEntry == null) {
        _startHereEntry = _DocOrderEntry(
          title: link.group(1)!,
          page: link.group(2)!,
          description: null,
        );
      }
    }
    if (_groupName != null) {
      _groupIntro.add(text);
    } else if (_sectionTitle != null) {
      _sectionIntro.add(text);
    } else {
      _lead.add(text);
    }
  }

  _DocOrder build() {
    _flushPending();
    _flushParagraph();
    _closeSection();
    if (_title == null || _sections.isEmpty) {
      return _DocOrder.unavailable(
        'the reading order has no `# ` title or no `## ` sections — is '
        '`${_DocOrder.assetName}` declared under `assets:` in '
        'pubspec.yaml?',
      );
    }
    return _DocOrder(
      title: _title!,
      lead: _lead,
      sections: _sections,
      startHere: _startHereEntry,
    );
  }

  /// The lead's first inline link, captured before the paragraph was
  /// flattened for display.
  _DocOrderEntry? _startHereEntry;
}

/// A bullet being accumulated across wrapped source lines.
class _PendingEntry {
  _PendingEntry({
    required this.title,
    required this.page,
    required this.description,
  });

  final String title;
  final String page;
  final List<String> description;
}
