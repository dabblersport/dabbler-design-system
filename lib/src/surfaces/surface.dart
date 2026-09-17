import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

/// The fill steps a [DabblerSurface] can take.
///
/// Transcribed from the design source `guidelines/surface-separation.html`,
/// whose subtitle states the law this whole file implements: *"Flat system: no
/// shadows. Depth comes from fill steps + a 1px hairline."* That specimen
/// renders exactly four steps, in this order: `sunken`, `surface + hairline`,
/// `brand tint`, `selected`.
///
/// [grey] is the fifth step and is **not** in that specimen: it is the
/// `--color-surface-grey` entry of `guidelines/colors-surfaces.html` (*"page bg
/// … card … sunken … grey … faint"*), described in `tokens/colors.css` as the
/// neutral inset panel. It is included because the epic's panel-shaped
/// components need a neutral inset that is not the page background, and it is
/// documented here rather than left for each of them to re-derive.
enum DabblerSurfaceVariant {
  /// `--surface-flat` + `--surface-hairline` — the opaque card surface with its
  /// 1px hairline. The default, and the step every card, tile, panel, sheet and
  /// dialog in the system is built on.
  card,

  /// `--surface-flat-sunken`, i.e. `--color-bg-primary`. A fill step **with no
  /// hairline**: separation comes from the step itself, which is why the
  /// specimen draws it borderless.
  sunken,

  /// `--color-surface-grey` — the neutral inset panel. Like [sunken], a fill
  /// step with no hairline.
  grey,

  /// `--glass-icon-tile-fill` / `--glass-icon-tile-stroke` under their post-FLAT
  /// values: an **opaque** brand tint with the card hairline. The source names
  /// are a deprecated compatibility layer and are deliberately not ported — see
  /// the class doc.
  brandTint,

  /// `--glass-selected-fill` under its post-FLAT value: solid
  /// `--color-brand-primary`, no sheen, no white lip. The overlay and stroke
  /// that the selected state used to carry are both `transparent` in the
  /// source, so this step is a bare brand fill with no border.
  selected,
}

/// Surface — the shared **flat** container primitive that every other component
/// in the system composes.
///
/// Transcribed from `components/foundations/Surface.jsx`, its `Surface.d.ts`
/// and `Surface.prompt.md`: *"an opaque fill plus a 1px hairline; every other
/// component composes it."*
///
/// ```dart
/// DabblerSurface(
///   padding: const EdgeInsets.all(DabblerSpacing.cardPadding),
///   child: const Text('Content'),
/// )
/// ```
///
/// ## Flat, and what that rules out
///
/// `tokens/glass.css` carries the ruling this component exists to enforce:
/// surfaces are *"FLAT: opaque fills, 1px hairline borders, no backdrop blur,
/// no sheen gradients, no coloured shadow casts."* A [DabblerSurface]
/// accordingly paints **one** [BoxDecoration] — a solid fill, a hairline and a
/// radius — and has no API through which a blur, a gradient or a shadow could
/// be introduced. There is no `shadow` parameter: the source's `shadow` prop
/// defaults to `'none'` and its implementation already collapses anything else
/// to `'none'`, so porting it would port a parameter that cannot do anything.
/// The one legal shadow in the system is [DabblerElevation.dialogFor], reserved
/// for Dialog (DS-702).
///
/// ## The retired layer is not ported
///
/// The source's own `Surface` was renamed from a surface primitive whose name
/// described the retired Liquid Glass layer, and it keeps that old name as a
/// deprecated alias. **Neither the alias nor any `--glass-*` token is ported.**
/// The alias exists in the source only so existing web imports keep resolving;
/// this package has no such consumers, and a Dart alias would put the retired
/// vocabulary into a brand-new public API. `test/tokens/dabbler_palette_test.dart`
/// asserts that no such symbol exists anywhere in `lib/`, and
/// `test/surfaces/surface_test.dart` asserts it again for this file.
///
/// The three post-FLAT `--glass-*` values that are still *live* — the icon-tile
/// fill, its stroke and the selected fill — are ported by **value**, as
/// [DabblerSurfaceVariant.brandTint] and [DabblerSurfaceVariant.selected],
/// under names that describe what they are.
///
/// ## Overriding
///
/// [fill], [borderColor] and [borderWidth] override the variant, which is how
/// the source's `fill` / `borderColor` props are used: a focus ring or an error
/// stroke is a [borderColor] override, not a new variant. Passing
/// `borderColor: null` keeps the variant's own hairline; to remove a hairline,
/// pass [borderWidth] `0`.
class DabblerSurface extends StatelessWidget {
  /// A surface on the [variant] fill step. Defaults to
  /// [DabblerSurfaceVariant.card].
  const DabblerSurface({
    super.key,
    this.child,
    this.variant = DabblerSurfaceVariant.card,
    this.radius,
    this.fill,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.width,
    this.height,
    this.center = false,
    this.clipBehavior = Clip.antiAlias,
  }) : assert(borderWidth == null || borderWidth >= 0,
            'a border cannot be narrower than zero');

  /// The opaque card surface with its hairline —
  /// [DabblerSurfaceVariant.card].
  const DabblerSurface.card({
    Key? key,
    Widget? child,
    double? radius,
    Color? fill,
    Color? borderColor,
    double? borderWidth,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool center = false,
    Clip clipBehavior = Clip.antiAlias,
  }) : this(
          key: key,
          child: child,
          variant: DabblerSurfaceVariant.card,
          radius: radius,
          fill: fill,
          borderColor: borderColor,
          borderWidth: borderWidth,
          padding: padding,
          width: width,
          height: height,
          center: center,
          clipBehavior: clipBehavior,
        );

  /// The sunken fill step — [DabblerSurfaceVariant.sunken].
  const DabblerSurface.sunken({
    Key? key,
    Widget? child,
    double? radius,
    Color? fill,
    Color? borderColor,
    double? borderWidth,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool center = false,
    Clip clipBehavior = Clip.antiAlias,
  }) : this(
          key: key,
          child: child,
          variant: DabblerSurfaceVariant.sunken,
          radius: radius,
          fill: fill,
          borderColor: borderColor,
          borderWidth: borderWidth,
          padding: padding,
          width: width,
          height: height,
          center: center,
          clipBehavior: clipBehavior,
        );

  /// The neutral inset panel — [DabblerSurfaceVariant.grey].
  const DabblerSurface.grey({
    Key? key,
    Widget? child,
    double? radius,
    Color? fill,
    Color? borderColor,
    double? borderWidth,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool center = false,
    Clip clipBehavior = Clip.antiAlias,
  }) : this(
          key: key,
          child: child,
          variant: DabblerSurfaceVariant.grey,
          radius: radius,
          fill: fill,
          borderColor: borderColor,
          borderWidth: borderWidth,
          padding: padding,
          width: width,
          height: height,
          center: center,
          clipBehavior: clipBehavior,
        );

  /// The opaque brand tint with the card hairline —
  /// [DabblerSurfaceVariant.brandTint].
  const DabblerSurface.brandTint({
    Key? key,
    Widget? child,
    double? radius,
    Color? fill,
    Color? borderColor,
    double? borderWidth,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool center = false,
    Clip clipBehavior = Clip.antiAlias,
  }) : this(
          key: key,
          child: child,
          variant: DabblerSurfaceVariant.brandTint,
          radius: radius,
          fill: fill,
          borderColor: borderColor,
          borderWidth: borderWidth,
          padding: padding,
          width: width,
          height: height,
          center: center,
          clipBehavior: clipBehavior,
        );

  /// The solid brand fill of a selected control —
  /// [DabblerSurfaceVariant.selected].
  const DabblerSurface.selected({
    Key? key,
    Widget? child,
    double? radius,
    Color? fill,
    Color? borderColor,
    double? borderWidth,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool center = false,
    Clip clipBehavior = Clip.antiAlias,
  }) : this(
          key: key,
          child: child,
          variant: DabblerSurfaceVariant.selected,
          radius: radius,
          fill: fill,
          borderColor: borderColor,
          borderWidth: borderWidth,
          padding: padding,
          width: width,
          height: height,
          center: center,
          clipBehavior: clipBehavior,
        );

  /// The content of the surface. May be null — an empty surface is a legitimate
  /// spacer or media well.
  final Widget? child;

  /// Which fill step this surface paints.
  final DabblerSurfaceVariant variant;

  /// Corner radius. Defaults to [defaultRadius] (`--radius-xl`, 18), the
  /// source's own `radius = 'var(--radius-xl)'`.
  ///
  /// Pass a step of [DabblerRadius]; a raw number is a hardcoded geometry value
  /// and the package forbids those.
  final double? radius;

  /// Fill override. Null resolves [variant] through [fillOf].
  final Color? fill;

  /// Hairline colour override. Null resolves [variant] through [borderOf],
  /// which yields null for the borderless fill steps.
  final Color? borderColor;

  /// Hairline width. Defaults to [DabblerSizing.borderDefault] (1) when the
  /// variant has a hairline, and is ignored when it does not. Pass `0` to drop
  /// the hairline from a variant that has one.
  final double? borderWidth;

  /// Inner padding. [EdgeInsetsGeometry] rather than [EdgeInsets] so a caller
  /// can pass [EdgeInsetsDirectional] and stay correct under RTL.
  final EdgeInsetsGeometry? padding;

  /// Fixed width. Null lets the surface size to its [child] and its
  /// constraints.
  final double? width;

  /// Fixed height. Null lets the surface size to its [child].
  final double? height;

  /// Centres [child] on both axes — the source's `align: 'center'`.
  ///
  /// Defaults to false, and for the reason the source records: forcing a flex
  /// container on every surface squeezed inline content (*"chips clipped their
  /// labels"*).
  final bool center;

  /// How [child] is clipped to the rounded corners. [Clip.antiAlias] matches
  /// the source's `overflow: hidden`; pass [Clip.none] for a child that must
  /// paint outside the radius.
  final Clip clipBehavior;

  /// The source's default radius: `--radius-xl`, 18.
  static const double defaultRadius = DabblerRadius.xl;

  /// The fill of [variant], resolved against [colors].
  ///
  /// Exposed so a component that cannot use a [DabblerSurface] directly — one
  /// that must paint its own [BoxDecoration], for instance to animate it — can
  /// still take its colour from the one place the steps are defined.
  static Color fillOf(DabblerColors colors, DabblerSurfaceVariant variant) {
    return switch (variant) {
      // `--surface-flat: var(--color-surface-card)`.
      DabblerSurfaceVariant.card => colors.surfaceCard,
      // `--surface-flat-sunken: var(--color-bg-primary)`.
      DabblerSurfaceVariant.sunken => colors.bgPrimary,
      DabblerSurfaceVariant.grey => colors.surfaceGrey,
      DabblerSurfaceVariant.brandTint => brandTintFill(colors),
      // `--glass-selected-fill: var(--color-brand-primary)`.
      DabblerSurfaceVariant.selected => colors.brandPrimary,
    };
  }

  /// The hairline of [variant], or null where the step is borderless.
  ///
  /// `--surface-hairline` is `--outline-card` in light and
  /// `--color-border-default` in dark; [DabblerColors.borderDefault] already
  /// resolves to exactly that pair, so the two names are one value here.
  static Color? borderOf(DabblerColors colors, DabblerSurfaceVariant variant) {
    return switch (variant) {
      DabblerSurfaceVariant.card => colors.borderDefault,
      // `--glass-icon-tile-stroke` — the card outline in both modes.
      DabblerSurfaceVariant.brandTint => colors.borderDefault,
      DabblerSurfaceVariant.sunken ||
      DabblerSurfaceVariant.grey ||
      DabblerSurfaceVariant.selected =>
        null,
    };
  }

  /// The opaque brand tint.
  ///
  /// The source declares it as a `color-mix`:
  /// `color-mix(in srgb, var(--color-brand-primary) 8%, white)` in light and
  /// `… 22%, black)` in dark. [Color.lerp] over sRGB is that same mix, so the
  /// tint is computed from [DabblerColors.brandPrimary] rather than written out
  /// as a hex per theme — there are seven brands, and the source states one
  /// rule for all of them.
  ///
  /// It is opaque by construction: mixing with an opaque white or black, not
  /// lowering alpha. A translucent tint would be the retired layer returning
  /// under another name.
  static Color brandTintFill(DabblerColors colors) {
    final bool dark = colors.brightness == Brightness.dark;
    return Color.lerp(
      dark ? Colors.black : Colors.white,
      colors.brandPrimary,
      dark ? 0.22 : 0.08,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Color resolvedFill = fill ?? fillOf(colors, variant);
    final Color? resolvedBorder = borderColor ?? borderOf(colors, variant);
    final double resolvedWidth = borderWidth ?? DabblerSizing.borderDefault;
    final BorderRadius borderRadius =
        BorderRadius.all(Radius.circular(radius ?? defaultRadius));

    Widget? content = child;
    if (content != null && padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (content != null && center) {
      content = Center(child: content);
    }

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: resolvedFill,
          borderRadius: borderRadius,
          border: resolvedBorder != null && resolvedWidth > 0
              ? Border.all(color: resolvedBorder, width: resolvedWidth)
              : null,
          // The system is flat. No gradient, no shadow, no blur — and no
          // parameter that could add one.
        ),
        child: content == null
            ? null
            : ClipRRect(
                clipBehavior: clipBehavior,
                borderRadius: borderRadius,
                child: content,
              ),
      ),
    );
  }
}
