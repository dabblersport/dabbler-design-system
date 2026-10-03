import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_type.dart';

/// HighlightedText — a search result's text with the matched part picked out.
///
/// Transcribed from `Search.dc.html:205, 247, 282, 392, 505` (the `{{ pre
/// }}<span …>{{ match }}</span>{{ rest }}` pattern): the matched substring is
/// `--color-brand-primary` text at weight 600 on a 14% brand tint over
/// `--surface-card`; the rest of the string keeps the caller's style.
///
/// ```dart
/// DabblerHighlightedText(
///   text: 'The Dabbler app',
///   query: 'dabbler',
///   style: DabblerType.subheadline,
///   maxLines: 1,
/// )
/// ```
///
/// ## Matching
///
/// Case-insensitive, every non-overlapping occurrence, left to right. An empty
/// query, or one with no occurrence, renders the plain text; a query longer
/// than the text matches nothing. Diacritics are **not** folded (`e` does not
/// match `é`) — the design does not ask for it.
///
/// Where lowercasing preserves the length of both strings (every Latin and
/// Arabic string in practice) the match is a code-unit `indexOf` on the
/// lowercased text, so the ranges index the original text directly. Where it
/// does not (`İ` lowercases to two code units) the match falls back to a
/// case-insensitive, Unicode-mode [RegExp] on the original text. Either way a
/// match is **widened to whole grapheme clusters**: combining marks (Arabic
/// tashkeel, Latin diacritics) that follow or lead a match are taken into it, so
/// a highlight never cuts a letter from its vowel sign. Western digits are
/// matched like any other character and never rewritten.
///
/// ## Direction
///
/// The span structure is logical-order, so the bidi algorithm lays out a
/// highlighted Arabic word, and a Latin match inside an Arabic sentence, as it
/// would the plain string. The style resolves through
/// [DabblerTypeStyle.resolveForDirection], so Arabic takes its own size and
/// leading.
///
/// ## Accessibility
///
/// The rich text is exposed as the plain [text], in one piece: a screen reader
/// does not announce the highlight boundaries.
///
/// ## Deliberate deviation
///
/// The design rounds the highlight by 3px. [TextStyle.background] paints a
/// square rectangle and 3 is not a radius token (`--radius-sm` is 6), so the
/// highlight is square rather than built from a `WidgetSpan`, which would
/// break line wrapping and ellipsis.
class DabblerHighlightedText extends StatelessWidget {
  /// Creates [text] with every occurrence of [query] highlighted.
  const DabblerHighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style = DabblerType.subheadline,
    this.color,
    this.fontWeight,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
  });

  /// `--weight-semibold` — the matched run's weight (`Search.dc.html:505`).
  static const FontWeight matchWeight = DabblerType.semibold;

  /// The tint's share of the brand colour, over `--surface-card` —
  /// `color-mix(in srgb, var(--color-brand-primary) 14%, var(--surface-card))`.
  static const double tintAlpha = 0.14;

  /// The full string shown.
  final String text;

  /// What to highlight. Empty highlights nothing.
  final String query;

  /// The ramp step the text is set in. Defaults to
  /// [DabblerType.subheadline]; the design's 14px result rows have no step of
  /// their own, so a caller picks the nearest.
  final DabblerTypeStyle style;

  /// The unmatched text colour. Defaults to [DabblerColors.textPrimary].
  final Color? color;

  /// Overrides [style]'s weight for the unmatched text (the design sets
  /// titles at 600 and body copy at 400).
  final FontWeight? fontWeight;

  /// Maximum lines. Null is unbounded.
  final int? maxLines;

  /// How overflow is shown. Defaults to ellipsis, as every design row does.
  final TextOverflow overflow;

  /// Alignment inside the available width.
  final TextAlign? textAlign;

  /// The non-overlapping ranges of [text] that match [query], widened to
  /// grapheme boundaries. Public so the matching rule is testable on its own.
  static List<TextRange> matchRanges(String text, String query) {
    if (query.isEmpty || text.isEmpty || query.length > text.length) {
      return const <TextRange>[];
    }
    final String lowText = text.toLowerCase();
    final String lowQuery = query.toLowerCase();
    if (lowText.length == text.length && lowQuery.length == query.length) {
      final List<TextRange> raw = <TextRange>[];
      int from = 0;
      while (true) {
        final int i = lowText.indexOf(lowQuery, from);
        if (i < 0) {
          break;
        }
        raw.add(TextRange(start: i, end: i + lowQuery.length));
        from = i + lowQuery.length;
      }
      return _widen(text, raw);
    }
    return matchRangesByRegExp(text, query);
  }

  /// The fallback for strings whose lowercasing changes their length (it does
  /// on some platforms for `İ`): a case-insensitive, Unicode-mode [RegExp] on
  /// the original text. Public only so the path can be tested on a platform
  /// where lowercasing happens to preserve length.
  @visibleForTesting
  static List<TextRange> matchRangesByRegExp(String text, String query) {
    if (query.isEmpty) {
      return const <TextRange>[];
    }
    final RegExp re = RegExp(
      RegExp.escape(query),
      caseSensitive: false,
      unicode: true,
    );
    final List<TextRange> raw = <TextRange>[
      for (final RegExpMatch m in re.allMatches(text))
        if (m.end > m.start) TextRange(start: m.start, end: m.end),
    ];
    return _widen(text, raw);
  }

  /// Takes the combining marks adjoining each range into it, and merges
  /// ranges that touch or overlap (adjacent matches read as one highlight).
  static List<TextRange> _widen(String text, List<TextRange> ranges) {
    final List<TextRange> out = <TextRange>[];
    for (final TextRange r in ranges) {
      int start = r.start;
      int end = r.end;
      while (start > 0 && _isCombining(text.codeUnitAt(start))) {
        start--;
      }
      while (end < text.length && _isCombining(text.codeUnitAt(end))) {
        end++;
      }
      if (out.isNotEmpty && start <= out.last.end) {
        out[out.length - 1] = TextRange(
          start: out.last.start,
          end: end > out.last.end ? end : out.last.end,
        );
      } else {
        out.add(TextRange(start: start, end: end));
      }
    }
    return out;
  }

  /// Combining diacritics and Arabic marks (tashkeel, superscript alef,
  /// Quranic annotations), plus the zero-width joiners that bind a cluster.
  static bool _isCombining(int u) =>
      (u >= 0x0300 && u <= 0x036F) ||
      (u >= 0x064B && u <= 0x065F) ||
      u == 0x0670 ||
      (u >= 0x06D6 && u <= 0x06DC) ||
      (u >= 0x06DF && u <= 0x06E4) ||
      (u >= 0x06E7 && u <= 0x06E8) ||
      (u >= 0x06EA && u <= 0x06ED) ||
      u == 0x200D ||
      u == 0xFE0F;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextStyle base = style
        .resolveForDirection(Directionality.of(context))
        .copyWith(color: color ?? colors.textPrimary, fontWeight: fontWeight);
    final List<TextRange> ranges = matchRanges(text, query);
    if (ranges.isEmpty) {
      return Text(
        text,
        style: base,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }
    final TextStyle hit = base.copyWith(
      color: colors.brandPrimary,
      fontWeight: matchWeight,
      background: Paint()
        ..color = Color.alphaBlend(
          colors.brandPrimary.withValues(alpha: tintAlpha),
          colors.surfaceCard,
        ),
    );
    final List<InlineSpan> spans = <InlineSpan>[];
    int cursor = 0;
    for (final TextRange r in ranges) {
      if (r.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, r.start)));
      }
      spans.add(TextSpan(text: text.substring(r.start, r.end), style: hit));
      cursor = r.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return Text.rich(
      TextSpan(style: base, children: spans),
      semanticsLabel: text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
