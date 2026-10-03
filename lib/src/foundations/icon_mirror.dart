import 'icon.dart';

/// The directional-mirroring table behind [DabblerIcon.mirrorInRtl].
///
/// ## Why a measured table and not a name swap
///
/// `components/foundations/icons-system.card.html` (*RTL*) says direction is
/// handled by *"selecting the mirrored glyph name (`arrow-circle-right` ↔
/// `-left`), not a CSS transform on the SVG"*. The obvious implementation is to
/// swap `left` for `right` in the name. **In `iconsax_flutter` 1.0.1 that is
/// wrong for most of the plain `arrow-*` family**, measured 2026-10-03 by
/// rendering every `*left*` / `*right*` glyph, flipping it horizontally and
/// finding the glyph it matches pixel for pixel:
///
/// * `arrow-left` is the mirror of `arrow-right-1`, not of `arrow-right`;
/// * at `bold`, `arrow-right` draws a solid circle-arrow whose mirror is
///   `arrow-left-2`; at `linear` it draws a chevron-in-a-square whose mirror is
///   `arrow-square-left`;
/// * `arrow-left-1` pairs with `arrow-right-3` at `bold` but with the
///   bold-only `arrow-right-4` at `linear`.
///
/// The package's labels in that family do not describe what the glyphs draw,
/// and the pairing differs by weight, so this table is **per weight** and every
/// entry is what the pixels say. `test/foundations/icon_mirror_test.dart`
/// re-renders each pair and fails if a flipped glyph stops matching its
/// partner, so the table cannot drift from the font silently.
///
/// ## The pair table
///
/// Both directions are listed implicitly: [pairFor] looks a name up as either
/// side of a pair.
///
/// | weight | name | mirrored name |
/// |---|---|---|
/// | both | `arrow-circle-left` | `arrow-circle-right` |
/// | both | `arrow-left` | `arrow-right-1` |
/// | both | `arrow-left-2` | `arrow-right-3` (linear) / `arrow-right` (bold) |
/// | both | `arrow-left-3` | `arrow-right-2` |
/// | linear | `arrow-square-left` | `arrow-right` |
/// | bold | `arrow-square-left` | `arrow-square-right` |
/// | bold | `arrow-left-1` | `arrow-right-3` |
/// | both | `direct-left` | `direct-right` |
/// | both | `rotate-left` | `rotate-right` |
/// | both | `rotate-left-1` | `rotate-right-1` |
/// | both | `refresh-left-square` | `refresh-right-square` |
/// | both | `textalign-left` | `textalign-right` |
/// | both | `textalign-justifyleft` | `textalign-justifyright` |
/// | linear | `align-left` | `align-right` |
/// | bold | `sidebar-left` | `sidebar-right` |
///
/// Left out on purpose, because the flipped glyph matches nothing in the set:
/// `linear` `arrow-left-1` (its mirror, `arrow-right-4`, ships bold only),
/// `bold` `align-left`/`-right`, `linear` `sidebar-left`/`-right` and
/// `tag-right`. Those, and any name not in the table, are flipped
/// horizontally instead — the documented fallback.
///
/// **Deviation:** the horizontal flip contradicts the card's "not a transform"
/// rule. It is used only where Iconsax ships no mirrored glyph, where the
/// alternative is a glyph pointing the wrong way.
abstract final class DabblerIconMirror {
  const DabblerIconMirror._();

  /// The `linear` pairs, one direction each. See the class table.
  static const Map<String, String> linearPairs = <String, String>{
    'arrow-circle-left': 'arrow-circle-right',
    'arrow-left': 'arrow-right-1',
    'arrow-left-2': 'arrow-right-3',
    'arrow-left-3': 'arrow-right-2',
    'arrow-square-left': 'arrow-right',
    'direct-left': 'direct-right',
    'rotate-left': 'rotate-right',
    'rotate-left-1': 'rotate-right-1',
    'refresh-left-square': 'refresh-right-square',
    'textalign-left': 'textalign-right',
    'textalign-justifyleft': 'textalign-justifyright',
    'align-left': 'align-right',
  };

  /// The `bold` pairs, one direction each. See the class table.
  static const Map<String, String> boldPairs = <String, String>{
    'arrow-circle-left': 'arrow-circle-right',
    'arrow-left': 'arrow-right-1',
    'arrow-left-2': 'arrow-right',
    'arrow-left-3': 'arrow-right-2',
    'arrow-left-1': 'arrow-right-3',
    'arrow-square-left': 'arrow-square-right',
    'direct-left': 'direct-right',
    'rotate-left': 'rotate-right',
    'rotate-left-1': 'rotate-right-1',
    'refresh-left-square': 'refresh-right-square',
    'textalign-left': 'textalign-right',
    'textalign-justifyleft': 'textalign-justifyright',
    'sidebar-left': 'sidebar-right',
  };

  /// The pairs for [weight], one direction each.
  static Map<String, String> pairsFor(DabblerIconWeight weight) =>
      weight == DabblerIconWeight.bold ? boldPairs : linearPairs;

  /// The Iconsax name that draws the horizontal mirror of [name] at [weight],
  /// or null when the set has none and the icon must be flipped instead.
  static String? pairFor(String name, DabblerIconWeight weight) {
    final Map<String, String> pairs = pairsFor(weight);
    final String? forward = pairs[name];
    if (forward != null) return forward;
    for (final MapEntry<String, String> e in pairs.entries) {
      if (e.value == name) return e.key;
    }
    return null;
  }
}
