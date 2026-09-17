import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'surface.dart';

/// The tint a [DabblerIconTile] paints.
///
/// [brand] is the source's own default and its only documented tint:
/// `IconTile.jsx` fills with the brand at a low mix and strokes it with the
/// card hairline — which is exactly [DabblerSurfaceVariant.brandTint], the fill
/// step DS-500 already ported from `--glass-icon-tile-fill` /
/// `--glass-icon-tile-stroke`. The tile therefore states no tint of its own.
///
/// The other three are the **decorative tile roles** of `tokens/colors.css:89-91`
/// — `--tile-amber-*`, `--tile-info-*`, `--tile-accent-*` — ported by DS-102 as
/// [DabblerColors.tileAmber], [DabblerColors.tileInfo] and
/// [DabblerColors.tileAccent]. That block is the complete tile list in the
/// source: three roles, no more, and the token layer carries all three. Each is
/// a [DabblerToneColor], i.e. a surface **and** the ink that sits on it, so the
/// glyph colour is read from the same token as the fill rather than derived.
///
/// ## Why the source's free-form `color` prop is not ported
///
/// `IconTile.jsx` takes any CSS colour and mixes the fill at 10% and the stroke
/// at 28% of it. Porting that would put a second tint formula in this file,
/// next to the one [DabblerSurface.brandTintFill] already owns, and would let a
/// caller paint a tile in a colour the token layer never declared. The
/// specimen's one non-default use — `color="var(--color-accent)"` on
/// `components/surfaces/surfaces.card.html:28` — is [accent] here. If a tone
/// the source paints turns out to be missing from the token layer, that is a
/// DS-102 gap to report, not a colour to invent.
enum DabblerIconTileTone {
  /// The brand tint — [DabblerSurfaceVariant.brandTint], with the card
  /// hairline. The default, and the source's default.
  brand,

  /// `--tile-amber-surface` / `--tile-amber-ink`.
  amber,

  /// `--tile-info-surface` / `--tile-info-ink`.
  info,

  /// `--tile-accent-surface` / `--tile-accent-ink`.
  accent,
}

/// IconTile — the tinted square that holds one glyph ("Icon Bg").
///
/// Transcribed from `components/surfaces/IconTile.jsx`, `IconTile.d.ts` and
/// `IconTile.prompt.md`: *"the 45×45 tinted icon container … brand @10% fill,
/// brand-light stroke, `--radius-lg`. The icon renders in the tint at 24px."*
///
/// ```dart
/// const DabblerIconTile.named('game');
/// const DabblerIconTile.named('location', tone: DabblerIconTileTone.accent);
/// ```
///
/// ## It is a composition, and restates nothing
///
/// AC1 of KAN-239 is that this component is DS-300's icon inside DS-500's
/// surface. Concretely:
///
/// * the box — fill, hairline, radius clipping, the flat [BoxDecoration] — is
///   [DabblerSurface]. This file contains no `BoxDecoration`, no `Border`, no
///   `Radius`, and no mix of a tint;
/// * the glyph — the Iconsax lookup, the weight fallback, the missing-name
///   placeholder — is [DabblerIcon]. This file names no `IconData` and imports
///   no icon package;
/// * press and focus, when the tile is tappable, are DS-200's
///   [DabblerPressScale] and [DabblerFocusRing]. No scale, duration, curve,
///   ring width or ring offset appears here.
///
/// `test/surfaces/icon_tile_test.dart` proves that by scanning this file's own
/// source for each of those restatements.
///
/// The three numbers the tile *does* state are all tokens, and all three are
/// the source's:
///
/// | value | token | source |
/// |---|---|---|
/// | 45 square | [DabblerSizing.touchTargetMin] | `IconTile.d.ts` *"size. Default: 45"*; `guidelines/measurements.html:113` lists `IconTile (45×45)` among the documented consumers of the 45px floor |
/// | radius 12 | [DabblerRadius.lg] | `IconTile.jsx` `radius="var(--radius-lg)"`, and `guidelines/measurements.html:73` glosses `--radius-lg` as *"cards, icon tiles"*. Gloss and implementation agree here — checked, because they have disagreed elsewhere in this kit |
/// | glyph 24 | [DabblerSizing.iconMd] | `IconTile.jsx` renders the slot at `width: 24, height: 24`; `--icon-md` is *"the native Iconsax grid"* |
///
/// [DabblerSurface]'s own default radius is `--radius-xl` (18), so the tile
/// passes [DabblerRadius.lg] explicitly rather than inheriting it.
///
/// ## Where the port differs from the JSX, and why
///
/// The JSX mixes its fill at **10%** of the tint and its stroke at **28%**.
/// This port takes the brand tone from [DabblerSurfaceVariant.brandTint]
/// instead, which is `--glass-icon-tile-fill` / `--glass-icon-tile-stroke` at
/// their post-FLAT token values (8% in light, 22% in dark, over the card
/// hairline). The token is the later, authoritative statement of the same
/// intent — `tokens/glass.css` re-declared these three values when the retired
/// Liquid Glass layer was flattened, while the component kept its inline
/// `color-mix` from before — and DS-500 already ported it. Re-deriving 10/28
/// here would fork the tint and break the one guarantee AC1 asks for.
///
/// The decorative tones are flat fills with **no** hairline: `--tile-*-surface`
/// is an opaque decorative colour, not a tint over the card, and the source
/// declares no stroke for them.
class DabblerIconTile extends StatefulWidget {
  /// A tile around an arbitrary [icon] widget — the source's `icon` slot, which
  /// its specimen fills with both an `<Icon/>` and a `<SportIcon/>`.
  ///
  /// [icon] is rendered inside an [IconTheme] carrying the tone's ink and
  /// [DabblerSizing.iconMd], so a [DabblerIcon] placed here inherits both
  /// without being told either.
  const DabblerIconTile(
    this.icon, {
    super.key,
    this.tone = DabblerIconTileTone.brand,
    this.size,
    this.onTap,
    this.semanticLabel,
  }) : name = null,
       weight = DabblerIconWeight.linear;

  /// A tile around the Iconsax glyph [name] — the common case, and the one the
  /// specimen shows three times out of four.
  ///
  /// Equivalent to passing `DabblerIcon(name, weight: weight)` to the default
  /// constructor; it exists so the caller does not repeat the glyph size that
  /// the tile would then override anyway.
  const DabblerIconTile.named(
    String this.name, {
    super.key,
    this.weight = DabblerIconWeight.linear,
    this.tone = DabblerIconTileTone.brand,
    this.size,
    this.onTap,
    this.semanticLabel,
  }) : icon = null;

  /// The glyph widget, when built with the default constructor.
  final Widget? icon;

  /// The kebab-case Iconsax name, when built with [DabblerIconTile.named].
  final String? name;

  /// The weight of [name]. Ignored by the default constructor.
  final DabblerIconWeight weight;

  /// Which tint the tile paints. Defaults to [DabblerIconTileTone.brand].
  final DabblerIconTileTone tone;

  /// The square side. Defaults to [DabblerSizing.touchTargetMin] (45), the
  /// source's `size = 45`.
  final double? size;

  /// Makes the tile a button. Null — the default, and the source's only
  /// behaviour — leaves it decorative: no gesture, no focus, no button
  /// semantics.
  final VoidCallback? onTap;

  /// The accessible label. Null leaves the tile decorative to assistive
  /// technology, which is right for a tile whose meaning is carried by the row
  /// it sits in.
  final String? semanticLabel;

  /// The fill of [tone], resolved against [colors].
  ///
  /// The brand tone defers to [DabblerSurface.fillOf]; the three decorative
  /// tones are read straight off their DS-102 roles.
  static Color fillFor(DabblerColors colors, DabblerIconTileTone tone) {
    return switch (tone) {
      DabblerIconTileTone.brand => DabblerSurface.fillOf(
        colors,
        DabblerSurfaceVariant.brandTint,
      ),
      DabblerIconTileTone.amber => DabblerColors.tileAmber.surface,
      DabblerIconTileTone.info => DabblerColors.tileInfo.surface,
      DabblerIconTileTone.accent => DabblerColors.tileAccent.surface,
    };
  }

  /// The hairline of [tone], or null where the tone is borderless.
  static Color? borderFor(DabblerColors colors, DabblerIconTileTone tone) {
    return tone == DabblerIconTileTone.brand
        ? DabblerSurface.borderOf(colors, DabblerSurfaceVariant.brandTint)
        : null;
  }

  /// The glyph colour of [tone].
  ///
  /// The source draws the glyph *in the tint* — `color` is the fill, the stroke
  /// and the icon in one prop. The brand tone is therefore
  /// [DabblerColors.brandPrimary], the colour the fill is mixed from, and each
  /// decorative tone is its own `--tile-*-ink`.
  static Color inkFor(DabblerColors colors, DabblerIconTileTone tone) {
    return switch (tone) {
      DabblerIconTileTone.brand => colors.brandPrimary,
      DabblerIconTileTone.amber => DabblerColors.tileAmber.ink,
      DabblerIconTileTone.info => DabblerColors.tileInfo.ink,
      DabblerIconTileTone.accent => DabblerColors.tileAccent.ink,
    };
  }

  @override
  State<DabblerIconTile> createState() => _DabblerIconTileState();
}

class _DabblerIconTileState extends State<DabblerIconTile> {
  bool _pressed = false;
  bool _focused = false;

  bool get _interactive => widget.onTap != null;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  void _setFocused(bool value) {
    if (_focused == value) {
      return;
    }
    setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Color ink = DabblerIconTile.inkFor(colors, widget.tone);
    final double side = widget.size ?? DabblerSizing.touchTargetMin;

    final Widget glyph = widget.name != null
        ? DabblerIcon(widget.name!, weight: widget.weight)
        : widget.icon!;

    final Widget tile = DabblerSurface(
      variant: DabblerSurfaceVariant.brandTint,
      radius: DabblerRadius.lg,
      // Null for the brand tone, which is what leaves DS-500's own step in
      // place; a decorative tone overrides both and drops the hairline.
      fill: widget.tone == DabblerIconTileTone.brand
          ? null
          : DabblerIconTile.fillFor(colors, widget.tone),
      borderWidth: widget.tone == DabblerIconTileTone.brand ? null : 0,
      width: side,
      height: side,
      center: true,
      child: SizedBox(
        width: DabblerSizing.iconMd,
        height: DabblerSizing.iconMd,
        // The glyph reads its colour and its size from here, so neither the
        // caller nor this file has to repeat them on the icon itself.
        child: IconTheme.merge(
          data: IconThemeData(color: ink, size: DabblerSizing.iconMd),
          child: Center(child: glyph),
        ),
      ),
    );

    if (!_interactive) {
      return widget.semanticLabel == null
          ? ExcludeSemantics(child: tile)
          : Semantics(
              container: true,
              label: widget.semanticLabel,
              child: ExcludeSemantics(child: tile),
            );
    }

    // DS-200 supplies press and focus. Nothing about the scale, the duration,
    // the curve, the ring width, the ring offset or the ring colour is stated
    // here.
    final Widget interactive = DabblerFocusRing.visible(
      visible: _focused,
      borderRadius: DabblerRadius.lgAll,
      child: DabblerPressScale(pressed: _pressed, child: tile),
    );

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: _setFocused,
          actions: <Type, Action<Intent>>{
            // Enter and Space, which the source's button role gets from the
            // user agent and Flutter does not.
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                widget.onTap?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onTapDown: (TapDownDetails _) => _setPressed(true),
            onTapUp: (TapUpDetails _) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            child: interactive,
          ),
        ),
      ),
    );
  }
}
