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

/// Splits [markup] into the plain, bold and code runs the design draws.
List<InlineSpan> _spans(String markup, TextStyle base, DabblerColors colors) {
  final RegExp pattern = RegExp(r'\*\*(.+?)\*\*|`([^`]+)`');
  final List<InlineSpan> spans = <InlineSpan>[];
  int cursor = 0;

  for (final RegExpMatch match in pattern.allMatches(markup)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: markup.substring(cursor, match.start)));
    }
    final String? bold = match.group(1);
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
    } else {
      spans.add(_codeChip(match.group(2)!, base, colors));
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
