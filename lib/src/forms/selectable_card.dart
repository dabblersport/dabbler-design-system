import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';

/// The two shapes a [DabblerSelectableCard] takes.
enum DabblerSelectableCardLayout {
  /// The full-width row — leading glyph, caption/title/subtitle, and a
  /// trailing radio-style check. The persona step,
  /// `Auth and Onboarding.dc.html:373-389`.
  row,

  /// The compact grid tile — glyph over a short label, with a small check in
  /// the top inline-end corner while selected. The sport step,
  /// `Auth and Onboarding.dc.html:392-406` (`grid-template-columns:
  /// repeat(4,1fr)`).
  tile,
}

/// SelectableCard — a tappable card that is either chosen or not.
///
/// The onboarding steps ask "which of these are you?" with cards rather than
/// radios: the persona step (`Auth and Onboarding.dc.html:373-389`, one of
/// four, row cards) and the sport step (`:392-406`, many of twelve, a 4-column
/// tile grid). Both draw the same thing — a tinted card whose border thickens
/// to the tint and which grows a `tick-circle` when selected — so one
/// component carries both as [DabblerSelectableCardLayout].
///
/// ```dart
/// DabblerSelectableCard(
///   icon: 'game',
///   caption: 'Player',
///   title: 'I want to find games',
///   subtitle: 'Join pickup games near you.',
///   selected: persona == 'player',
///   onChanged: (_) => setState(() => persona = 'player'),
/// )
/// ```
///
/// ## Selection is the caller's
///
/// The card holds no state. [onChanged] is called with the **toggled** value
/// (`!selected`); single-choice callers ignore it and set their own value,
/// multi-choice callers store it. A null [onChanged] disables the card.
///
/// ## Paint
///
/// | part | value | source |
/// |---|---|---|
/// | fill | [DabblerSurface.tintedFillOf] the [tint] | `color-mix(<ramp>-600 12%, card)` (`:1414`) |
/// | border, idle | [DabblerSurface.tintedBorderOf] the [tint], 1px | `1px solid color-mix(<ramp> 30%, card)` (`:1415`) |
/// | border, selected | the [tint], 2 × [DabblerSizing.borderDefault] | `2px solid <ramp>-700` (`:1415`) |
/// | radius | row [DabblerRadius.lg], tile [DabblerRadius.md] | `:374`, `:395` |
/// | check | `tick-circle` bold (selected) / `record` linear (idle) | `:1421-1422` |
///
/// [tint] defaults to [DabblerColors.brandPrimary]; persona cards pass their
/// own ramp colour.
///
/// **Deviation:** the design mixes the fill at 12% and the idle border at
/// 30%; the package's tint tokens are 10% / 28%
/// ([DabblerSurface.tintFillAlpha]). No 2px border token exists, so the
/// selected border is `2 × borderDefault`. The tile's 26px glyph and 14px
/// check use [DabblerSizing.iconLg] (30) and [DabblerSizing.iconSm] (18), and
/// the row's 14px body uses `footnote` (13) — the nearest steps.
///
/// ## Accessibility
///
/// One semantics node: a button with a selected state, labelled by caption,
/// title and subtitle in reading order. Keyboard focus shows the
/// [DabblerFocusRing]; Enter and Space toggle.
///
/// ## RTL
///
/// The row's glyph sits at the inline start and the check at the inline end;
/// the tile's check sits in the top inline-end corner — top-right in LTR,
/// top-left in RTL.
class DabblerSelectableCard extends StatefulWidget {
  /// Creates a selectable card.
  const DabblerSelectableCard({
    super.key,
    required this.title,
    this.subtitle,
    this.caption,
    this.icon,
    this.leading,
    this.selected = false,
    this.onChanged,
    this.layout = DabblerSelectableCardLayout.row,
    this.tint,
    this.semanticLabel,
  });

  /// The main line — the persona hook, or the sport name on a tile.
  final String title;

  /// Supporting copy under [title]. Row layout only.
  final String? subtitle;

  /// A small uppercase line above [title], in the [tint]. Row layout only.
  final String? caption;

  /// An icon name for the glyph. Bold while selected, linear otherwise.
  final String? icon;

  /// A custom glyph, used instead of [icon].
  final Widget? leading;

  /// Whether the card is chosen.
  final bool selected;

  /// Called with `!selected` on tap. Null disables the card.
  final ValueChanged<bool>? onChanged;

  /// Row or tile.
  final DabblerSelectableCardLayout layout;

  /// The colour the card is tinted with. Defaults to the brand.
  final Color? tint;

  /// Overrides the label read by assistive technology.
  final String? semanticLabel;

  /// The check glyph shown while selected.
  static const String checkIconName = 'tick-circle';

  /// The empty radio glyph shown on an idle row.
  static const String idleIconName = 'record';

  @override
  State<DabblerSelectableCard> createState() => _DabblerSelectableCardState();
}

class _DabblerSelectableCardState extends State<DabblerSelectableCard> {
  bool _focused = false;

  bool get _enabled => widget.onChanged != null;

  void _toggle() => widget.onChanged?.call(!widget.selected);

  String get _label =>
      widget.semanticLabel ??
      <String?>[
        widget.caption,
        widget.title,
        widget.subtitle,
      ].whereType<String>().join(', ');

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final Color tint = widget.tint ?? colors.brandPrimary;
    final bool row = widget.layout == DabblerSelectableCardLayout.row;
    final double radius = row ? DabblerRadius.lg : DabblerRadius.md;
    final DabblerIconWeight weight = widget.selected
        ? DabblerIconWeight.bold
        : DabblerIconWeight.linear;

    Widget? glyph = widget.leading;
    if (glyph == null && widget.icon != null) {
      glyph = DabblerIcon(
        widget.icon!,
        weight: weight,
        size: row ? DabblerSizing.iconMd : DabblerSizing.iconLg,
        color: tint,
      );
    }

    final Widget body = row
        ? _row(colors, direction, tint, glyph)
        : _tile(colors, direction, tint, glyph);

    final Widget card = AnimatedOpacity(
      opacity: _enabled ? 1 : 0.6,
      duration: DabblerMotion.reduceMotion(context)
          ? Duration.zero
          : DabblerMotion.base,
      child: DabblerSurface(
        radius: radius,
        fill: DabblerSurface.tintedFillOf(colors, tint),
        borderColor: widget.selected
            ? tint
            : DabblerSurface.tintedBorderOf(colors, tint),
        borderWidth: widget.selected
            ? DabblerSizing.borderDefault * 2
            : DabblerSizing.borderDefault,
        child: body,
      ),
    );

    return Semantics(
      container: true,
      button: true,
      selected: widget.selected,
      enabled: _enabled,
      label: _label,
      onTap: _enabled ? _toggle : null,
      child: ExcludeSemantics(
        child: DabblerFocusRing.visible(
          visible: _focused,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          child: FocusableActionDetector(
            enabled: _enabled,
            mouseCursor: _enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onShowFocusHighlight: (bool v) => setState(() => _focused = v),
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  _toggle();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _enabled ? _toggle : null,
              child: DabblerPressScale.gesture(enabled: _enabled, child: card),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    DabblerColors colors,
    TextDirection direction,
    Color tint,
    Widget? glyph,
  ) {
    return Padding(
      padding: const EdgeInsets.all(DabblerSpacing.space5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (glyph != null) ...<Widget>[
            glyph,
            const SizedBox(width: DabblerSpacing.space4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.caption != null)
                  Text(
                    widget.caption!.toUpperCase(),
                    style: DabblerType.caption1
                        .resolveForDirection(direction)
                        .copyWith(
                          color: tint,
                          fontWeight: DabblerType.semibold,
                        ),
                  ),
                Text(
                  widget.title,
                  style: DabblerType.callout
                      .resolveForDirection(direction)
                      .copyWith(color: colors.textPrimary),
                ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: DabblerType.footnote
                        .resolveForDirection(direction)
                        .copyWith(color: colors.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: DabblerSpacing.space4),
          DabblerIcon(
            widget.selected
                ? DabblerSelectableCard.checkIconName
                : DabblerSelectableCard.idleIconName,
            weight: widget.selected
                ? DabblerIconWeight.bold
                : DabblerIconWeight.linear,
            size: DabblerSizing.iconMd,
            color: widget.selected
                ? tint
                : DabblerSurface.tintedBorderOf(colors, tint),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    DabblerColors colors,
    TextDirection direction,
    Color tint,
    Widget? glyph,
  ) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: DabblerSpacing.space4,
            horizontal: DabblerSpacing.space1,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ?glyph,
                if (glyph != null)
                  const SizedBox(height: DabblerSpacing.space2),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DabblerType.caption2
                      .resolveForDirection(direction)
                      .copyWith(
                        color: colors.textPrimary,
                        fontWeight: DabblerType.medium,
                      ),
                ),
              ],
            ),
          ),
        ),
        if (widget.selected)
          PositionedDirectional(
            top: DabblerSpacing.space1,
            end: DabblerSpacing.space1,
            child: DabblerIcon(
              DabblerSelectableCard.checkIconName,
              weight: DabblerIconWeight.bold,
              size: DabblerSizing.iconSm,
              color: tint,
            ),
          ),
      ],
    );
  }
}
