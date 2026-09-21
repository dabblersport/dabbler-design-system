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
/// | bar height | `height: 47` (`:9`), **content-box** | [barContentHeight]; drawn height is [barHeight] |
/// | bar corner | `borderRadius: 16` (`:13`) | [DabblerRadius.card] |
/// | bar outline | `1px solid var(--neutral-400)` ×4 (`:14-17`) | [DabblerColors.borderDefault] |
/// | clipping | `overflow: "hidden"` (`:12`) | [ClipRRect] — corners only; see [barHeight] |
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

  /// `height: 47` (`NavigationTabBar.jsx:9`) — the shell's **content** height,
  /// which is not the height the bar draws at. See [barHeight].
  static const double barContentHeight = 47;

  /// The height the bar actually occupies: **49**.
  ///
  /// **Corrected under KAN-292's visual bar.** The export writes `height: 47`
  /// and this port first read that as the total, making the strip 47 tall. It
  /// is not the total. Neither the shell nor `styles.css` sets
  /// `box-sizing: border-box` — only the tab does (`:45`) — so the browser's
  /// default content-box applies and the shell's four 1px borders (`:14-17`)
  /// sit *outside* the 47. The specimen rendered headless from
  /// `navigation.card.html` measures **49 rows of ink**: border at rows 0-1,
  /// content at 2-46, border at 47-48. So the drawn bar is
  /// [barContentHeight] + 2, and this is that number.
  ///
  /// The row inside still overflows, and is still clipped — but by 3, not by 1.
  /// See [rowHeight].
  static const double barHeight =
      barContentHeight + 2 * DabblerSizing.borderDefault;

  /// The inner row's natural height: **50**, inside a [barContentHeight] of 47.
  ///
  /// 1 border + 12 padding + the 24 glyph + 12 padding + 1 border. The tab is a
  /// flex column with `alignItems: "center"` (`:44`), so its height is its
  /// content's — and its content is the 24px glyph, not the 20px
  /// [glyphLineHeight] of the span around it.
  ///
  /// The row overflows the content box by 3 and `overflow: "hidden"` (`:12`)
  /// takes those 3 off the block end, which is why **the row's bottom border is
  /// never drawn**. The headless specimen shows exactly that asymmetry: two
  /// full-width neutral-400 lines at the top (shell at row 0, row at row 1) and
  /// a single one at the bottom (shell at row 48, the row's clipped away).
  static const double rowHeight = 2 * DabblerSizing.borderDefault +
      2 * tabPaddingBlock +
      DabblerSizing.iconMd;

  /// `lineHeight: "20px"` on the span that holds each glyph
  /// (`NavigationTabBar.jsx:64,95,126,157`).
  ///
  /// **It does not set the row's height** — [rowHeight] does, from the glyph.
  /// The 24px glyph overhangs this 20px line box by 2 each way, and because the
  /// tab centres its content rather than laying it out on a baseline, the box
  /// the 12px padding actually measures from is the glyph's 24. Kept as the
  /// transcribed value of the declaration, not as a layout input.
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: DabblerRadius.cardAll,
            // The shell's own `1px solid var(--neutral-400)` (`:14-17`),
            // drawn inside [barHeight] and outside [barContentHeight] — the
            // content-box the export is written against.
            border: Border.all(
              color: colors.borderDefault,
              width: DabblerSizing.borderDefault,
            ),
          ),
          // `overflow: "hidden"` (`:12`). The clip sits **inside** the border
          // rather than around it, because CSS clips an overflowing child to
          // the padding box — the shell's own outline is never painted over by
          // what it clips. Clipping the whole border box instead would lose the
          // bottom rule, which is the one full-width line the specimen draws
          // down there.
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(
                DabblerRadius.card - DabblerSizing.borderDefault)),
            // `flexDirection: "column"` with a `flexShrink: 0` row (`:19,36`):
            // the row keeps its natural [rowHeight] of 50 in a 47 content box
            // and is clipped from the block end, not squeezed. That clip is
            // what removes the row's own bottom border — see [rowHeight].
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

  /// One tab: the 24px glyph with 12 of block padding either side and nothing
  /// on the inline axis — 48 tall, which is what makes the row [rowHeight].
  Widget _tab(
    DabblerColors colors,
    DabblerNavigationItem item,
    bool isActive,
  ) {
    final Widget body = Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: tabPaddingBlock,
      ),
      // `alignItems: "center"` on a flex column (`:44`) — the tab takes its
      // content's height, and the content is the glyph's own 24. The 20px
      // [glyphLineHeight] the span declares is overhung and does not measure.
      child: SizedBox(
        height: DabblerSizing.iconMd,
        child: Center(
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
