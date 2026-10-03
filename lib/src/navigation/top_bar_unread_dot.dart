part of 'top_bar.dart';

/// The unread dot on a [DabblerNavigationAction] (KAN-409 item 2).
///
/// Transcribed from the Home Feed design's notification action:
/// `position:absolute; top:9px; right:9px; width:9px; height:9px;
/// border-radius:9999px; background:var(--color-brand-primary);
/// border:2px solid var(--surface-page); box-sizing:content-box`, inside a
/// 45px box around a 24px glyph. **No count** — the design draws a bare dot.
///
/// The design measures from the 45px box; this bar's glyph is 22 in a
/// narrower box, so the offsets are re-expressed against the glyph: the 24px
/// glyph sits 10.5 in from the box edge, so `top: 9 / right: 9` puts the dot's
/// outer edge 1.5 beyond the glyph's top-end corner. Anchored with
/// [PositionedDirectional], so it sits top-right in English and top-left in
/// Arabic.
abstract final class DabblerNavigationUnreadDot {
  /// `width: 9px; height: 9px` — the fill.
  static const double diameter = 9;

  /// `border: 2px solid var(--surface-page)`, outside the fill.
  static const double borderWidth = 2;

  /// The outer box: fill plus border on both sides (CSS `content-box`).
  static const double outerSide = diameter + 2 * borderWidth;

  /// How far the dot's outer edge overhangs the glyph, on both axes.
  static const double overhang = -1.5;

  /// Finds the dot in a test.
  static const Key dotKey = ValueKey<String>('dabbler-navigation-unread-dot');

  /// [child] with the dot on its top-end corner when [visible].
  static Widget wrap({required bool visible, required Widget child}) {
    if (!visible) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        const PositionedDirectional(
          top: overhang,
          end: overhang,
          child: _UnreadDot(),
        ),
      ],
    );
  }

  /// The action's accessible name: its label, plus its `unreadLabel` while
  /// unread.
  static String semanticLabel(DabblerNavigationAction action) {
    final String? extra = action.unreadLabel;
    if (!action.unread || extra == null || extra.isEmpty) return action.label;
    return '${action.label}, $extra';
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Container(
      key: DabblerNavigationUnreadDot.dotKey,
      width: DabblerNavigationUnreadDot.outerSide,
      height: DabblerNavigationUnreadDot.outerSide,
      decoration: BoxDecoration(
        // `background: var(--color-brand-primary)`.
        color: colors.brandPrimary,
        shape: BoxShape.circle,
        // `border: 2px solid var(--surface-page)` — bgPrimary.
        border: Border.all(
          color: colors.bgPrimary,
          width: DabblerNavigationUnreadDot.borderWidth,
        ),
      ),
    );
  }
}
