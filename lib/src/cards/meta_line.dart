import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The two sizes a [DabblerMetaLine] is set at.
enum DabblerMetaLineSize {
  /// A listing card's place row — 13/18, the first item at weight 500
  /// (`Listings.dc.html:231-240`).
  card,

  /// The upcoming card's place row — 12/16 (`Listings.dc.html:156-163`).
  compact,
}

/// MetaLine — a glyph followed by short facts separated by small dots: where
/// a game is, how far, how long.
///
/// From `Listings.dc.html:231-240` (game and meetup cards) and `:440-447`
/// (upcoming card): a `location` glyph in the subtle ink, then the first fact
/// in `--ink-soft` at weight 500, then each further fact after a 3px round
/// dot, in the muted ink. Every child sits `gap: 5px` from the next.
///
/// ```dart
/// DabblerMetaLine(items: <String>['Dubai Sports City', '2.1 km', '90 min'])
/// ```
///
/// **Ink.** The frame sets the later facts in `--muted`; this system's
/// `textSecondary` is `--ink-soft` and `textTertiary` is `--muted`, demoted
/// from body text by `DECISIONS.md` D-003(a) (3.36:1 on a card). The facts are
/// therefore drawn in `textSecondary`, and the glyph and dots — non-text — in
/// `textTertiary`.
///
/// ## RTL
///
/// A [Row] under the ambient direction: under Arabic the glyph sits at the
/// right and the facts run leftwards.
///
/// ## Accessibility
///
/// One semantics node reading the facts joined by commas; the glyph and dots
/// are decorative.
class DabblerMetaLine extends StatelessWidget {
  /// A meta line of [items].
  const DabblerMetaLine({
    super.key,
    required this.items,
    this.icon = 'location',
    this.size = DabblerMetaLineSize.card,
    this.emphasizeFirst = true,
  });

  /// The facts, already formatted and localised. Empty strings are skipped.
  final List<String> items;

  /// The leading glyph; null draws none.
  final String? icon;

  /// The type size.
  final DabblerMetaLineSize size;

  /// Whether the first fact takes the stronger ink and weight 500.
  final bool emphasizeFirst;

  /// Every child's spacing — `gap: 5px` (`Listings.dc.html:231`).
  static const double gap = 5;

  /// The upcoming card's spacing — `gap: 4px` (`Listings.dc.html:440`).
  static const double compactGap = 4;

  /// The glyph — `size="14"`.
  static const double iconSize = 14;

  /// The separator dot — `width: 3px; height: 3px; border-radius: 9999px`.
  static const double dotSize = DabblerSpacing.space1;

  @override
  Widget build(BuildContext context) {
    final List<String> facts = <String>[
      for (final String i in items)
        if (i.trim().isNotEmpty) i,
    ];
    if (facts.isEmpty) return const SizedBox.shrink();
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool compact = size == DabblerMetaLineSize.compact;
    final TextStyle base =
        (compact ? DabblerType.caption1 : DabblerType.footnote)
            .resolveForDirection(direction)
            .copyWith(color: colors.textSecondary);
    final List<Widget> children = <Widget>[
      if (icon != null)
        DabblerIcon(icon!, size: iconSize, color: colors.textTertiary),
    ];
    for (int i = 0; i < facts.length; i++) {
      if (i > 0) {
        children.add(
          SizedBox.square(
            dimension: dotSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.textTertiary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }
      final bool strong = i == 0 && emphasizeFirst && !compact;
      final Widget text = Text(
        facts[i],
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: strong ? base.copyWith(fontWeight: DabblerType.medium) : base,
      );
      // Every fact may give way (the place name first, being widest) so a
      // large text scale ellipsises instead of overflowing; at 1x they all
      // keep their natural width, as `white-space: nowrap` does.
      children.add(_Fact(child: text));
    }
    return Semantics(
      container: true,
      label: facts.join(', '),
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) => Row(
            mainAxisSize: c.hasBoundedWidth
                ? MainAxisSize.max
                : MainAxisSize.min,
            spacing: compact ? compactGap : gap,
            children: <Widget>[
              for (final Widget w in children)
                // Under an unbounded width (a rail card hugging its content)
                // nothing can flex; the facts lay out at their natural width.
                if (w is _Fact)
                  c.hasBoundedWidth ? Flexible(child: w.child) : w.child
                else
                  w,
            ],
          ),
        ),
      ),
    );
  }
}

/// Marks a fact so the row can decide whether it may flex.
class _Fact extends StatelessWidget {
  const _Fact({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
