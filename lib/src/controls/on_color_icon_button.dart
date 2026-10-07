import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

/// OnColorIconButton — a round, translucent icon button that sits on a
/// coloured hero (a game's sport-coloured header, a profile's brand band).
///
/// Drawn from `Details.dc.html:50-58`, the game-details hero: three
/// `40×40` circles (`border-radius: 9999px`) — back, favourite, share — each
/// filled `rgba(255,255,255,0.18)` with the glyph in `var(--color-on-brand)`
/// at `size="20"`, on a `--sport-p-600` band. The same fill recurs as the
/// current-row icon chip on a brand fill at `Profiles.dc.html:887`.
///
/// ```dart
/// DabblerOnColorIconButton(
///   icon: 'arrow-circle-left',
///   semanticLabel: 'Back',
///   mirrorInRtl: true,
///   onPressed: () => Navigator.of(context).pop(),
/// )
/// ```
///
/// ## Why not [DabblerButton]
///
/// Every [DabblerButton] tone paints on the page surface. On a solid brand or
/// sport band its fills either vanish (brand on brand) or punch a paper hole
/// in the hero. This button's fill is the band's own on-colour at low alpha,
/// so it reads on any hero the theme can produce.
///
/// ## Colours
///
/// * Fill: [DabblerColors.onBrand] at [fillAlpha] (0.18) — the design's
///   white-at-18% expressed through the on-colour token, so a theme whose
///   on-brand is ink (`bright`) gets an ink wash instead of a white one.
/// * Glyph: [DabblerColors.onBrand], or [color] when the caller needs a
///   state colour (the design's favourite heart turns accent when set).
/// * Disabled ([onPressed] null): the whole button at [disabledOpacity], and
///   `Semantics(enabled: false)` — never colour alone.
///
/// **Deviation (size).** The source circle is 40px, which is under the
/// 45px floor and no geometry token. The circle is drawn at
/// [DabblerSizing.touchTargetMin] (45) so the painted button *is* the target.
///
/// **Deviation (glyph).** The source glyph is 20px; no icon token is 20. It
/// takes [DabblerSizing.iconSm] (18), the nearest step.
///
/// **Deviation (alpha).** 0.18 is the design's literal alpha; the token set
/// has no alpha ramp, so it is a named component constant, like
/// `DabblerButton.disabledOpacity`.
///
/// ## Focus, keyboard and accessibility
///
/// Focusable through [DabblerFocusRing] (keyboard focus only), activated by
/// Enter or Space via [ActivateIntent]. Announced as a button whose name is
/// [semanticLabel] — **required**, because the button has no visible text.
/// [selected] (for a toggle such as favourite) is exposed as
/// `Semantics(toggled:)`.
///
/// ## RTL
///
/// The button is placed by its parent row, so it follows the ambient
/// direction with no positioning of its own. A directional glyph (back,
/// forward) sets [mirrorInRtl] so it points the right way in Arabic.
///
/// ## Reduced motion
///
/// No animation, so nothing to switch off.
class DabblerOnColorIconButton extends StatelessWidget {
  /// Creates a translucent icon button for a coloured hero.
  const DabblerOnColorIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.weight = DabblerIconWeight.linear,
    this.color,
    this.mirrorInRtl = false,
    this.selected,
    this.focusNode,
    this.autofocus = false,
    this.onSurface = false,
    this.onTile = false,
  });

  /// The fill's alpha over [DabblerColors.onBrand] — `rgba(255,255,255,0.18)`
  /// at `Details.dc.html:50`.
  static const double fillAlpha = 0.18;

  /// The ink wash of an [onTile] button — `rgba(20,20,20,0.1)`
  /// (`Details.dc.html:222`).
  static const double tileFillAlpha = 0.1;

  /// The disabled opacity, shared with `DabblerButton.disabledOpacity`.
  static const double disabledOpacity = 0.45;

  /// The circle's side — [DabblerSizing.touchTargetMin]. See the size
  /// deviation in the class doc.
  static const double side = DabblerSizing.touchTargetMin;

  /// The glyph size — [DabblerSizing.iconSm].
  static const double glyphSize = DabblerSizing.iconSm;

  /// The glyph's name in the icon set.
  final String icon;

  /// The accessible name. Required: the button has no visible label.
  final String semanticLabel;

  /// Fired on tap, Enter or Space. Null disables the button.
  final VoidCallback? onPressed;

  /// Glyph weight — `bold` for a set toggle such as a filled heart.
  final DabblerIconWeight weight;

  /// Overrides the glyph colour (defaults to [DabblerColors.onBrand]).
  final Color? color;

  /// Mirror the glyph in right-to-left layouts — for back/forward arrows.
  final bool mirrorInRtl;

  /// For a toggle (favourite): exposed as `Semantics(toggled:)`. Null means
  /// the button is not a toggle.
  final bool? selected;

  /// Draws the circle as the page surface with an ink glyph, for a button that
  /// sits on a photograph rather than on a colour band — the venue gallery's
  /// back and favourite buttons (`Details.dc.html:405-412`, `background:
  /// var(--surface-page)`). Default false: the translucent on-colour wash.
  final bool onSurface;

  /// Draws the button for a decorative-tile band (the meetup details amber
  /// header): the fill is the page ink at [tileFillAlpha] and the glyph is the
  /// page ink. Wins over [onSurface].
  final bool onTile;

  /// An external focus node.
  final FocusNode? focusNode;

  /// Focuses the button on mount.
  final bool autofocus;

  /// The fill for [colors].
  static Color fillOf(DabblerColors colors) =>
      colors.onBrand.withValues(alpha: fillAlpha);

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool enabled = onPressed != null;

    Widget circle = DecoratedBox(
      decoration: BoxDecoration(
        color: onTile
            ? colors.tileAmberTone.ink.withValues(alpha: tileFillAlpha)
            : onSurface
            ? colors.bgPrimary
            : fillOf(colors),
        borderRadius: DabblerRadius.pillAll,
      ),
      child: SizedBox.square(
        dimension: side,
        child: Center(
          child: DabblerIcon(
            icon,
            weight: weight,
            size: glyphSize,
            color:
                color ??
                (onTile
                    ? colors.tileAmberTone.ink
                    : onSurface
                    ? colors.textPrimary
                    : colors.onBrand),
            mirrorInRtl: mirrorInRtl,
          ),
        ),
      ),
    );
    if (!enabled) {
      circle = Opacity(opacity: disabledOpacity, child: circle);
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
        child: DabblerFocusRing(
          borderRadius: DabblerRadius.pillAll,
          enabled: enabled,
          canRequestFocus: enabled,
          focusNode: focusNode,
          autofocus: autofocus,
          child: MouseRegion(
            cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onPressed,
              child: circle,
            ),
          ),
        ),
      ),
    );
  }
}
