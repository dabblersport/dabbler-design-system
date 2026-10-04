import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_hue_tone.dart';
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

  /// The compact one-line option row — glyph, one label, trailing check —
  /// vertically centred in a [DabblerSizing.touchTargetMin]-and-a-half
  /// minimum height. The primary-sport step,
  /// `Auth and Onboarding.dc.html:418-428`.
  listRow,

  /// The stacked option — glyph over a label with the check inline after it,
  /// centred. The gender step, `Auth and Onboarding.dc.html:359-371`.
  stacked,
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
/// check use [DabblerSizing.iconLg] (30) and [DabblerSizing.iconSm] (18), the
/// nearest steps. Text follows the frames: persona subtitle
/// [DabblerType.small], list-row title [DabblerType.rowTitle], stacked label
/// [DabblerType.copy] and tile label [DabblerType.tagTight].
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
    this.tone,
    this.semanticLabel,
    this.borderOutside = false,
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

  /// A full four-colour tone (surface, edge, solid, glyph, idle radio) for a
  /// card that is tinted by hue or ramp instead of by one [tint] — the sport
  /// tiles and gender cards. When set it overrides [tint]: the fill is the
  /// tone's `surface`, the idle stroke its `edge`, the selected stroke and
  /// check its `solid`, the glyph and caption its `deep`, and the unselected
  /// radio its `idle`.
  final DabblerHueTone? tone;

  /// Overrides the label read by assistive technology.
  final String? semanticLabel;

  /// Whether the border sits **outside** the content box, as the Auth and
  /// Onboarding frame draws every card (`box-sizing: border-box`, no explicit
  /// height): the padded row and the sport tile then grow by twice the border
  /// (1px idle, 2px selected). The two `min-height` layouts
  /// ([DabblerSelectableCardLayout.listRow] and `.stacked`) keep their 64 / 96
  /// *outer* minimum, because `min-height` under `border-box` includes the
  /// border. Default false: the border is painted inside.
  final bool borderOutside;

  /// The check glyph shown while selected.
  static const String checkIconName = 'tick-circle';

  /// The row caption's letter spacing, `0.06em` of the 16px step.
  static const double captionTracking = 0.96;

  /// The [DabblerSelectableCardLayout.listRow] minimum height, `64px`, the nearest step is 63
  /// (`Auth and Onboarding.dc.html:419`).
  static const double listRowMinHeight =
      DabblerSizing.tileLg + DabblerSpacing.space5;

  /// The [DabblerSelectableCardLayout.stacked] minimum height, `96px`
  /// (`:360`).
  static const double stackedMinHeight = DabblerSpacing.space11 * 2;

  /// The persona row hook's Latin line height, `23` (`:383`).
  static const double rowHookLeading = 23;

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
    final DabblerHueTone? tone = widget.tone;
    final Color tint = widget.tint ?? colors.brandPrimary;
    final Color solid = tone?.solid ?? tint;
    final Color glyphColor = tone?.deep ?? tint;
    final Color idleMark =
        tone?.idle ?? DabblerSurface.tintedBorderOf(colors, tint);
    final Color fill =
        tone?.surface ?? DabblerSurface.tintedFillOf(colors, tint);
    final Color edge =
        tone?.edge ?? DabblerSurface.tintedBorderOf(colors, tint);
    final bool row =
        widget.layout != DabblerSelectableCardLayout.tile &&
        widget.layout != DabblerSelectableCardLayout.stacked;
    final double radius = widget.layout == DabblerSelectableCardLayout.tile
        ? DabblerRadius.md
        : DabblerRadius.lg;
    final DabblerIconWeight weight = widget.selected
        ? DabblerIconWeight.bold
        : DabblerIconWeight.linear;

    Widget? glyph = widget.leading;
    if (glyph == null && widget.icon != null) {
      glyph = DabblerIcon(
        widget.icon!,
        weight: weight,
        size: row ? DabblerSizing.iconMd : DabblerSizing.iconLg,
        color: glyphColor,
      );
    }

    final _CardPaint paint = _CardPaint(
      solid: solid,
      glyph: glyphColor,
      idle: idleMark,
    );
    final Widget body = switch (widget.layout) {
      DabblerSelectableCardLayout.row => _row(colors, direction, paint, glyph),
      DabblerSelectableCardLayout.listRow => _listRow(
        colors,
        direction,
        paint,
        glyph,
      ),
      DabblerSelectableCardLayout.tile => _tile(
        colors,
        direction,
        paint,
        glyph,
      ),
      DabblerSelectableCardLayout.stacked => _stacked(
        colors,
        direction,
        paint,
        glyph,
      ),
    };

    final Widget card = AnimatedOpacity(
      opacity: _enabled ? 1 : 0.6,
      duration: DabblerMotion.reduceMotion(context)
          ? Duration.zero
          : DabblerMotion.base,
      child: DabblerSurface(
        borderOutside: widget.borderOutside,
        radius: radius,
        fill: fill,
        borderColor: widget.selected ? solid : edge,
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
    _CardPaint paint,
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
              spacing: DabblerSpacing.space1,
              children: <Widget>[
                if (widget.caption != null)
                  Text(
                    widget.caption!.toUpperCase(),
                    // The caption sets no size and no line-height
                    // (`:379`): it inherits the page's 16px and the
                    // browser's `normal` leading, which is the font's own
                    // metrics, not the body step's 21. Latin draws that;
                    // Arabic keeps the body's 24. Tracking is `0.06em`,
                    // dropped under RTL where it breaks joining.
                    style: _caption(direction, paint.glyph),
                  ),
                Text(
                  widget.title,
                  // The hook sets `line-height: 23px` (`:383`); Arabic keeps
                  // the body's own 24.
                  style: _rowHook(direction).copyWith(
                    color: colors.textPrimary,
                    fontWeight: DabblerType.medium,
                  ),
                ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    // `:384` — 14/20, [DabblerType.small].
                    style: DabblerType.small
                        .resolveForDirection(direction)
                        .copyWith(color: colors.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: DabblerSpacing.space4),
          _radio(paint),
        ],
      ),
    );
  }

  /// A `min-height` that [DabblerSelectableCard.borderOutside] keeps as the
  /// outer size: the border width is taken off the inner constraint.
  double _innerMin(double outer) => widget.borderOutside
      ? outer -
            2 *
                (widget.selected
                    ? DabblerSizing.borderDefault * 2
                    : DabblerSizing.borderDefault)
      : outer;

  TextStyle _caption(TextDirection direction, Color color) {
    final TextStyle s = DabblerType.body.resolveForDirection(direction);
    if (direction == TextDirection.rtl) {
      return s.copyWith(color: color, fontWeight: DabblerType.semibold);
    }
    // `height` left unset is the font's natural line height, CSS `normal`.
    return TextStyle(
      inherit: false,
      color: color,
      fontFamily: s.fontFamily,
      fontFamilyFallback: s.fontFamilyFallback,
      fontSize: s.fontSize,
      fontWeight: DabblerType.semibold,
      letterSpacing: DabblerSelectableCard.captionTracking,
      fontFeatures: s.fontFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  TextStyle _rowHook(TextDirection direction) {
    final TextStyle s = DabblerType.body.resolveForDirection(direction);
    return direction == TextDirection.ltr
        ? s.copyWith(height: DabblerSelectableCard.rowHookLeading / s.fontSize!)
        : s;
  }

  Widget _radio(_CardPaint paint) => DabblerIcon(
    widget.selected
        ? DabblerSelectableCard.checkIconName
        : DabblerSelectableCard.idleIconName,
    weight: widget.selected ? DabblerIconWeight.bold : DabblerIconWeight.linear,
    size: DabblerSizing.iconMd,
    color: widget.selected ? paint.solid : paint.idle,
  );

  Widget _listRow(
    DabblerColors colors,
    TextDirection direction,
    _CardPaint paint,
    Widget? glyph,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: _innerMin(DabblerSelectableCard.listRowMinHeight),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DabblerSpacing.space4,
          horizontal: DabblerSpacing.space5,
        ),
        child: Row(
          children: <Widget>[
            if (glyph != null) ...<Widget>[
              glyph,
              const SizedBox(width: DabblerSpacing.space4),
            ],
            Expanded(
              child: Text(
                widget.title,
                // `:421` — 17/23 weight 500, [DabblerType.rowTitle].
                style: DabblerType.rowTitle
                    .resolveForDirection(direction)
                    .copyWith(
                      color: colors.textPrimary,
                      fontWeight: DabblerType.medium,
                    ),
              ),
            ),
            const SizedBox(width: DabblerSpacing.space4),
            _radio(paint),
          ],
        ),
      ),
    );
  }

  Widget _stacked(
    DabblerColors colors,
    TextDirection direction,
    _CardPaint paint,
    Widget? glyph,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: _innerMin(DabblerSelectableCard.stackedMinHeight),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DabblerSpacing.space5,
          horizontal: DabblerSpacing.space4,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ?glyph,
            if (glyph != null) const SizedBox(height: DabblerSpacing.space3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    widget.title,
                    // `:363` — 15/21 weight 500, [DabblerType.copy].
                    style: DabblerType.copy
                        .resolveForDirection(direction)
                        .copyWith(
                          color: colors.textPrimary,
                          fontWeight: DabblerType.medium,
                        ),
                  ),
                ),
                if (widget.selected) ...<Widget>[
                  const SizedBox(width: DabblerSpacing.space2),
                  DabblerIcon(
                    DabblerSelectableCard.checkIconName,
                    weight: DabblerIconWeight.bold,
                    size: DabblerSizing.iconInline,
                    color: colors.textPrimary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    DabblerColors colors,
    TextDirection direction,
    _CardPaint paint,
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
                  // `:404` — 11/14 weight 500, [DabblerType.tagTight].
                  style: DabblerType.tagTight
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
              color: paint.solid,
            ),
          ),
      ],
    );
  }
}

/// The resolved colours one card paints with.
class _CardPaint {
  const _CardPaint({
    required this.solid,
    required this.glyph,
    required this.idle,
  });

  final Color solid;
  final Color glyph;
  final Color idle;
}
