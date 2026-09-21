import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'bottom_bar.dart' show DabblerNavigationItem;

/// The four-tab bar — `NavigationTabBar` in
/// `components/navigation/NavigationTabBar.jsx`, drawn by
/// `navigation.card.html:24` between the top bar and the split bottom bar.
///
/// **This component had no Flutter port before KAN-292.** The specimen names
/// three navigation components and the package carried two; the tab bar is the
/// one that was missing, so the fidelity comparison the ticket asks for had
/// nothing to compare against. It is transcribed here from the export.
///
/// It is the plain, flat alternative to [DabblerNavigationBottomBar]: a bordered
/// card-cornered strip of equal-width, **icon-only** destinations, with no pill,
/// no label and no detached action. The active destination is the brand colour
/// in [DabblerIconWeight.bold]; the rest are [DabblerColors.textTertiary] in
/// [DabblerIconWeight.linear] — the system-wide active/inactive rule.
///
/// ## Anatomy, against the export
///
/// | Part | Source | Here |
/// |---|---|---|
/// | bar width | `width: 384`, `maxWidth: 384` (`:8,10`) | [barWidth], as a **max** |
/// | bar height | `height: 47` (`:9`) | [barHeight], fixed |
/// | bar corner | `borderRadius: 16` (`:13`) | [DabblerRadius.card] |
/// | bar outline | `1px solid var(--neutral-400)` ×4 (`:14-17`) | [DabblerColors.borderDefault] |
/// | clipping | `overflow: "hidden"` (`:12`) | [ClipRRect] — see [barHeight] |
/// | row fill | `var(--neutral-white)` (`:27`) | [DabblerColors.surfaceCard] |
/// | row outline | a **second** `1px solid var(--neutral-400)` ×4 (`:28-31`) | [DabblerColors.borderDefault] |
/// | one tab | `flexGrow: 1` (`:47`) | [Expanded], so the four share the width |
/// | tab padding | `padding: "12px 0px"` (`:43`) | [DabblerSpacing.space4], block only |
/// | glyph | `size={24}` (`:67,98,129,160`) | [DabblerSizing.iconMd] |
/// | line box | `lineHeight: "20px"` (`:64`) | [glyphLineHeight] |
/// | active tint | `var(--purple-600)` (`:65`) | [DabblerColors.brandPrimary] |
/// | inactive tint | `var(--neutral-600)` (`:96,127,158`) | [DabblerColors.textTertiary] |
///
/// **Deviation — the inactive tint.** The export writes `--neutral-600`, which
/// is `--subtle`. `DECISIONS.md` D-003(a) retired `--subtle` as a text or icon
/// tint at 2.15:1, and `test/tokens/no_subtle_as_text_test.dart` enforces that,
/// so the inactive glyph takes `--muted` ([DabblerColors.textTertiary]) — the
/// same substitution every other ported component makes for this token. It is a
/// recorded contrast deviation, not a transcription error.
///
/// **Deviation — the doubled outline.** The export draws the 1px neutral-400
/// border twice, once on the clipped rounded shell and again on the row inside
/// it. Under `overflow: hidden` the inner rule is hidden along the two rounded
/// ends and doubles the line elsewhere. Both are transcribed: the shell's, and
/// the row's, which is what paints the hairline under the glyphs when the strip
/// is placed against a page of the same fill.
class DabblerNavigationTabBar extends StatelessWidget {
  /// Creates a four-tab bar.
  const DabblerNavigationTabBar({
    super.key,
    this.items = defaultItems,
    this.active,
    this.onSelect,
  });

  /// The export's own four glyphs, in order — `home-2`, `search-normal`,
  /// `add-circle`, `sms` (`NavigationTabBar.jsx:67,98,129,160`).
  ///
  /// The export is a static drawing with no labels and no ids, so the labels
  /// here are this port's: a glyph-only target still needs an accessible name,
  /// and these are the names the same glyphs carry in
  /// [DabblerNavigationBottomBar.defaultItems] where they overlap.
  static const List<DabblerNavigationItem> defaultItems =
      <DabblerNavigationItem>[
    DabblerNavigationItem(id: 'home', icon: 'home-2', label: 'Home'),
    DabblerNavigationItem(
        id: 'explore', icon: 'search-normal', label: 'Explore'),
    DabblerNavigationItem(id: 'create', icon: 'add-circle', label: 'Create'),
    DabblerNavigationItem(id: 'messages', icon: 'sms', label: 'Messages'),
  ];

  /// `width: 384` / `maxWidth: 384` (`NavigationTabBar.jsx:8,10`).
  ///
  /// Applied as a **maximum**, not a fixed width: the specimen exports the bar
  /// in a 384 column (`navigation.card.html:24`) because that is phone width,
  /// and the four tabs are `flexGrow: 1`, so the strip is happy narrower. It is
  /// capped so it does not stretch across a tablet and leave the glyphs
  /// marooned.
  static const double barWidth = 384;

  /// `height: 47` (`NavigationTabBar.jsx:9`), fixed.
  ///
  /// The row inside is 46 at its natural size — 1 border + 12 padding + the 20
  /// line box + 12 padding + 1 border — inside a 45 content box, so the export
  /// overflows it by 1 and `overflow: hidden` (`:12`) takes that pixel off the
  /// block end. That is reproduced rather than tidied away: growing the shell to
  /// 48 to "fit" would make the strip a pixel taller than every drawing of it.
  static const double barHeight = 47;

  /// `lineHeight: "20px"` on the span that holds each glyph
  /// (`NavigationTabBar.jsx:64,95,126,157`).
  ///
  /// The 24px glyph is larger than its own 20px line box and overhangs it by 2
  /// each way, exactly as an inline replaced element does on the web. The box
  /// is what the 12px padding is measured from, so it is the number that sets
  /// the row's height — not the glyph.
  static const double glyphLineHeight = 20;

  /// `padding: "12px 0px 12px 0px"` on each tab (`NavigationTabBar.jsx:43`) —
  /// `--space-4`, block axis only. There is no inline padding: the tabs divide
  /// the width between them and the glyph centres in whatever it gets.
  static const double tabPaddingBlock = DabblerSpacing.space4;

  /// The destinations, in visual order. Icon-only — [DabblerNavigationItem.label]
  /// is the accessible name rather than drawn text, which is the one way this
  /// differs from the same type's use in [DabblerNavigationBottomBar].
  final List<DabblerNavigationItem> items;

  /// The active destination's id. Null selects the first, which is what the
  /// export draws (`home-2` in `--purple-600` bold, the rest neutral linear).
  final String? active;

  /// Called with the tapped destination's id. Null leaves every tab inert,
  /// which is the export's own state — it is a drawing, not a control.
  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final String? activeId =
        active ?? (items.isEmpty ? null : items.first.id);

    final Widget row = Container(
      decoration: BoxDecoration(
        // `backgroundColor: 'var(--neutral-white)'` — `--surface-card`.
        color: colors.surfaceCard,
        // The export's second, inner `1px solid var(--neutral-400)` (`:28-31`).
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          for (final DabblerNavigationItem item in items)
            // `flexGrow: 1` — the four tabs split the width evenly.
            Expanded(child: _tab(colors, item, item.id == activeId)),
        ],
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: barWidth),
      child: SizedBox(
        height: barHeight,
        child: ClipRRect(
          // `overflow: "hidden"` against `borderRadius: 16` — this is what
          // takes the row's overflowing pixel off the block end.
          borderRadius: DabblerRadius.cardAll,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: DabblerRadius.cardAll,
              // The shell's own `1px solid var(--neutral-400)` (`:14-17`).
              border: Border.all(
                color: colors.borderDefault,
                width: DabblerSizing.borderDefault,
              ),
            ),
            // `flexDirection: "column", alignItems: "flex-start"` (`:19-20`)
            // with a `flexShrink: 0` row — so the row keeps its natural height
            // and is clipped from the block end, not squeezed.
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: OverflowBox(
                alignment: AlignmentDirectional.topStart,
                minHeight: 0,
                maxHeight: double.infinity,
                child: row,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// One tab: the glyph in its 20px line box, with 12 of block padding either
  /// side and nothing on the inline axis.
  Widget _tab(
    DabblerColors colors,
    DabblerNavigationItem item,
    bool isActive,
  ) {
    final Widget body = Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: tabPaddingBlock,
      ),
      child: SizedBox(
        height: glyphLineHeight,
        // The 24 glyph overhangs its 20 line box by 2 each way, as the inline
        // element does on the web. [OverflowBox] lets it, so the row measures
        // 20 here and the drawn mark is still 24.
        child: OverflowBox(
          maxHeight: DabblerSizing.iconMd,
          child: DabblerIcon(
            item.icon,
            size: DabblerSizing.iconMd,
            weight:
                isActive ? DabblerIconWeight.bold : DabblerIconWeight.linear,
            color: isActive ? colors.brandPrimary : colors.textTertiary,
          ),
        ),
      ),
    );

    final ValueChanged<String>? onSelect = this.onSelect;

    return Semantics(
      container: true,
      button: true,
      selected: isActive,
      enabled: onSelect != null,
      label: item.label,
      onTap: onSelect == null ? null : () => onSelect(item.id),
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSelect == null ? null : () => onSelect(item.id),
          child: DabblerFocusRing(
            borderRadius: DabblerRadius.cardAll,
            child: DabblerPressScale.gesture(
              enabled: onSelect != null,
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}
