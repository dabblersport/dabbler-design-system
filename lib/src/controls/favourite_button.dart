import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

/// FavouriteButton — the square, bordered well with a heart that saves a venue
/// (or any listing) to favourites.
///
/// Drawn from the venue card of `Listings.dc.html:774-776`: a 12-radius
/// well on the card fill with the 1px card outline, `padding: 6` around an
/// 18px heart, the glyph `linear` in `--ink-soft` when off and `bold` in
/// `--color-status-error` when on (`:2035-2036`). The same heart, borderless
/// and round, is the "remove" control of `Favourites.dc.html:60-62` (a bold
/// error heart, 36px); that is the [selected] state of this button on the page
/// surface, so the Favourites list reuses it rather than a second control.
///
/// ```dart
/// DabblerFavouriteButton(
///   selected: venue.isFavourite,
///   semanticLabel: 'Save Padel Yard',
///   onPressed: () => toggle(venue),
/// )
/// ```
///
/// It is a toggle: [selected] is exposed as `Semantics(toggled:)`, so the
/// state is never carried by colour or weight alone. The caller owns the
/// state; the button only reports a tap, Enter or Space.
///
/// **Deviation (target).** The painted well is [wellSide] (32) as designed,
/// which is under the 45 floor; it is laid out inside a [DabblerSizing.touchTargetMin]
/// square so the hit area clears it, exactly as `DabblerChip` does. In a card
/// header this makes the row 45 tall where the design's well is 32.
///
/// ## RTL
///
/// Placed by its parent row at the inline end of the venue name; the heart is
/// not directional, so nothing mirrors.
class DabblerFavouriteButton extends StatelessWidget {
  /// A favourite well; [selected] says whether the item is saved.
  const DabblerFavouriteButton({
    super.key,
    required this.selected,
    required this.semanticLabel,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
    this.plain = false,
  });

  /// Whether the item is a favourite — a bold, error-coloured heart.
  final bool selected;

  /// The accessible name. Required: the button has no visible text. Pass the
  /// localised action, `Add to favourites` / `Remove from favourites`.
  final String semanticLabel;

  /// Fired on tap, Enter or Space. Null disables the button.
  final VoidCallback? onPressed;

  /// Draws the borderless round form of `Favourites.dc.html:60-62` — a
  /// [plainSide] (36) circle with no fill or hairline around the same heart —
  /// instead of the bordered well. For a row on the page surface, where a
  /// card-coloured well would add a second surface. Default false.
  final bool plain;

  /// An external focus node.
  final FocusNode? focusNode;

  /// Focuses the button on mount.
  final bool autofocus;

  /// The well's corner — [DabblerRadius.lg] (12), `Listings.dc.html:774`.
  static const double radius = DabblerRadius.lg;

  /// The padding between the well edge and the glyph — [DabblerSpacing.space2]
  /// (6), `padding: 6px`.
  static const double padding = DabblerSpacing.space2;

  /// The heart's size — [DabblerSizing.iconSm] (18).
  static const double glyphSize = DabblerSizing.iconSm;

  /// The painted well's side: glyph + 2 × [padding] + 2 × the 1px border (32).
  static const double wellSide =
      glyphSize + padding * 2 + DabblerSizing.borderDefault * 2;

  /// The [plain] form's side — `36` (`Favourites.dc.html:60`).
  static const double plainSide = DabblerSpacing.space10;

  /// The disabled opacity, shared with `DabblerOnColorIconButton`.
  static const double disabledOpacity = 0.45;

  /// The heart's colour: `--color-status-error` when [selected], `--ink-soft`
  /// (the secondary ink) otherwise.
  static Color glyphColorFor(DabblerColors colors, {required bool selected}) =>
      selected ? colors.error.base : colors.textSecondary;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool enabled = onPressed != null;

    final Widget heart = DabblerIcon(
      'heart',
      weight: selected ? DabblerIconWeight.bold : DabblerIconWeight.linear,
      size: glyphSize,
      color: glyphColorFor(colors, selected: selected),
    );
    Widget well = plain
        ? SizedBox.square(
            dimension: plainSide,
            child: Center(child: heart),
          )
        : DabblerSurface(
            radius: radius,
            // The hairline is drawn inside the surface's box, while the
            // design's `padding: 6px` sits outside its border, so the border
            // width is added.
            padding: const EdgeInsets.all(
              padding + DabblerSizing.borderDefault,
            ),
            child: heart,
          );
    if (!enabled) {
      well = Opacity(opacity: disabledOpacity, child: well);
    }

    return Semantics(
      button: true,
      enabled: enabled,
      toggled: selected,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onPressed,
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent _) {
              onPressed?.call();
              return null;
            },
          ),
        },
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: DabblerSizing.touchTargetMin,
                minHeight: DabblerSizing.touchTargetMin,
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: DabblerFocusRing(
                  borderRadius: plain
                      ? DabblerRadius.pillAll
                      : BorderRadius.circular(radius),
                  enabled: enabled,
                  canRequestFocus: enabled,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  child: well,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
