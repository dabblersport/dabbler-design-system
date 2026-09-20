/// The design's two inline text treatments, and the monospace stack they and
/// [GalleryMono] share — `.usage b` and `.usage code`.
///
/// A `part` of `gallery_page.dart` rather than a library, for two reasons:
/// these are that file's own private helpers and must not become API, and
/// `gallery_page.dart` had reached 499 lines against the 500-line rule
/// (`013`), where one more line would have broken it. Moving the helpers out
/// gives it headroom without exporting anything.
part of 'gallery_page.dart';

/// The monospace stack the design's `code` and `.mono` rules ask for
/// (`ui-monospace,monospace`), spelled as a Flutter fallback chain.
const List<String> _monoFallback = <String>[
  'ui-monospace',
  'SFMono-Regular',
  'SF Mono',
  'Menlo',
  'Consolas',
  'monospace',
];

/// The inline vocabulary: `**bold**`, `` `code` `` and `[text](target)`.
///
/// **`dotAll: true` is the KAN-330/D-051(a) fix.** Without it `.` does not
/// cross a newline, so a `**…**` span whose asterisks sit on different
/// physical lines of the same paragraph could not match and both pairs
/// rendered literally — 66 spans across 43 of 58 pages, `colour.md:74-75`
/// among them. The corpus soft-wraps its prose; the renderer completes to the
/// corpus, never the other way round (D-051(b)).
final RegExp _inlineMarkup = RegExp(
  r'\*\*(.+?)\*\*|`([^`]+)`|\[([^\]]+)\]\(([^)]*)\)',
  dotAll: true,
);

/// Splits [markup] into the plain, bold, code and link runs the design draws.
List<InlineSpan> _spans(String markup, TextStyle base, DabblerColors colors) {
  final List<InlineSpan> spans = <InlineSpan>[];
  int cursor = 0;

  for (final RegExpMatch match in _inlineMarkup.allMatches(markup)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: markup.substring(cursor, match.start)));
    }
    final String? bold = match.group(1);
    final String? code = match.group(2);
    final String? linkText = match.group(3);
    if (bold != null) {
      spans.add(
        TextSpan(
          text: bold,
          style: base.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (code != null) {
      spans.add(_codeChip(code, base, colors));
    } else {
      // D-051(d)/D-052(f): the TEXT only — the target never appears on screen.
      // textPrimary AND underlined, both channels, because tone alone does not
      // carry at 12px. No new colour role (D-037(b) stands).
      //
      // **Deliberately not tappable, and no navigation is wired.** D-052(f): a
      // link that is tappable before its target resolves is confidently
      // broken, which is worse than inert text. Resolving the nine by page id
      // through the loader is a joint cto/cxo call, not this ticket's.
      spans.add(
        TextSpan(
          text: linkText,
          style: base.copyWith(
            color: colors.textPrimary,
            decoration: TextDecoration.underline,
            decorationColor: colors.textPrimary,
          ),
        ),
      );
    }
    cursor = match.end;
  }
  if (cursor < markup.length) {
    spans.add(TextSpan(text: markup.substring(cursor)));
  }
  return spans;
}

/// `.usage code` — a sunken chip, radius 4, 1px/4px padding, 12px mono.
InlineSpan _codeChip(String code, TextStyle base, DabblerColors colors) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Text(
        code,
        style: base.copyWith(
          fontFamily: _monoFallback.first,
          fontFamilyFallback: _monoFallback.sublist(1),
          height: 1.2,
        ),
      ),
    ),
  );
}

/// A `- ` or `1. ` line, once its marker is off.
class _ListItem {
  const _ListItem(this.marker, this.text);

  /// What the author wrote in the gutter: `•` for a bullet, `1.` for ordered.
  final String marker;

  /// The item's markup, marker stripped. Still carries inline treatments.
  final String text;
}

/// A run of consecutive list lines, or null when [block] is not a list.
///
/// KAN-330/D-051(d). `- ` and `1. ` were not in the inline vocabulary at all,
/// so the marker rendered as a literal dash or digit — 78 items across 32 of
/// 58 pages. A list is not an inline treatment: a hanging indent, where a
/// wrapped line aligns to the text and not under the bullet, is a layout the
/// span list cannot express. So it is parsed here and laid out as rows.
List<_ListItem>? _listItems(String block) {
  final List<String> lines = block.split('\n');
  final List<_ListItem> items = <_ListItem>[];
  for (final String line in lines) {
    final RegExpMatch? bullet = _bulletMarker.firstMatch(line);
    if (bullet != null) {
      items.add(_ListItem('•', bullet.group(1)!));
      continue;
    }
    final RegExpMatch? ordered = _orderedMarker.firstMatch(line);
    if (ordered != null) {
      items.add(_ListItem('${ordered.group(1)}.', ordered.group(2)!));
      continue;
    }
    // A wrapped continuation of the item above — the corpus soft-wraps, and a
    // continuation belongs to its item, not to a new one.
    if (items.isNotEmpty && line.trim().isNotEmpty) {
      final _ListItem last = items.removeLast();
      items.add(_ListItem(last.marker, '${last.text}\n${line.trim()}'));
      continue;
    }
    // Any non-list, non-continuation line means this block is prose that
    // merely contains a dash — not a list. Render it the ordinary way.
    if (line.trim().isNotEmpty) return null;
  }
  return items.isEmpty ? null : items;
}

final RegExp _bulletMarker = RegExp(r'^\s*[-*]\s+(.*)$');
final RegExp _orderedMarker = RegExp(r'^\s*(\d+)\.\s+(.*)$');

/// The ruled list layout — D-051(d).
///
/// Bullet glyph [DabblerColors.textTertiary], item text
/// [DabblerColors.textSecondary] so it matches the prose around it, hanging
/// indent of [DabblerSpacing.space4] (12) and [DabblerSpacing.space2] (6)
/// between items — the same tight-binding step D-050(c) gives a sub-heading
/// and its own prose.
Widget _listBody(
  List<_ListItem> items,
  TextStyle base,
  DabblerColors colors,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      for (int i = 0; i < items.length; i++) ...<Widget>[
        if (i > 0) const SizedBox(height: DabblerSpacing.space2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // A fixed gutter is what makes the indent hang: the text column
            // starts here, so a wrapped line lands under the text rather than
            // under the marker.
            SizedBox(
              width: DabblerSpacing.space4,
              child: Text(
                items[i].marker,
                style: base.copyWith(color: colors.textTertiary),
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(children: _spans(items[i].text, base, colors)),
                style: base,
              ),
            ),
          ],
        ),
      ],
    ],
  );
}
