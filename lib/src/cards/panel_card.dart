import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../layout/accordion.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_palette.dart';
import '../tokens/dabbler_type.dart';

/// The frame colour of a [DabblerPanelCard] — `PanelCard.jsx` `TONES`.
enum DabblerPanelCardTone {
  /// The active theme's brand fill.
  brand,

  /// `--tile-amber-surface`, ink text.
  amber,

  /// `--color-status-info-solid`, white text.
  info,

  /// `--sport-p-600`.
  sport,

  /// `--active-p-600`.
  active,
}

/// PanelCard — the framed panel: a coloured outer frame with a header row, an
/// inset content panel, and a footer holding a text link and prev/next arrows.
///
/// Ported from the live design project's `components/cards/PanelCard.jsx` and
/// `PanelCard.d.ts` (design system 1.2.0). Frame radius 24, inner panel radius
/// 18, inset 6. The body collapses with [DabblerCollapse], so it animates and
/// reports `expanded` like every other collapsible surface.
///
/// Injected only: [title], [footerLabel] and the [child] are supplied by the
/// caller and the callbacks are theirs.
///
/// ## Where the port states a type override (recorded rulings)
///
/// * Title — `headline` (17/22) at weight 700 (the ramp's headline is 600).
/// * Footer label — the source's 14/19/600 snaps one step to `subheadline`
///   15/20 at weight 600; this is a ruled snap, not rounding.
class DabblerPanelCard extends StatelessWidget {
  /// A panel card.
  const DabblerPanelCard({
    super.key,
    this.title,
    this.child,
    this.tone = DabblerPanelCardTone.brand,
    this.dark = false,
    this.width = defaultWidth,
    this.footerLabel,
    this.onFooter,
    this.onPrev,
    this.onNext,
    this.collapsed = false,
    this.onToggle,
    this.headerInside = true,
  });

  /// Header text inside the panel.
  final String? title;

  /// The body.
  final Widget? child;

  /// Frame colour. Defaults to [DabblerPanelCardTone.brand].
  final DabblerPanelCardTone tone;

  /// An ink panel instead of the card surface.
  final bool dark;

  /// Fixed width. `340` in the source.
  final double width;

  /// The footer link text.
  final String? footerLabel;

  /// Called when the footer label is pressed.
  final VoidCallback? onFooter;

  /// Previous arrow; null draws it dimmed and inert.
  final VoidCallback? onPrev;

  /// Next arrow; null draws it dimmed and inert.
  final VoidCallback? onNext;

  /// Hides the body and flips the header chevron.
  final bool collapsed;

  /// Supplying this renders the collapse chevron.
  final VoidCallback? onToggle;

  /// Set false when the child draws its own header (a date picker does).
  final bool headerInside;

  /// The default [width], `340`.
  static const double defaultWidth = 340;

  /// Frame radius — `borderRadius: 24`.
  static const double frameRadius = DabblerRadius.xxl;

  /// Inner panel radius — `borderRadius: 18`.
  static const double panelRadius = DabblerRadius.xl;

  /// Frame inset and the gap between frame children — `padding: 6`, `gap: 6`.
  static const double inset = DabblerSpacing.space2;

  /// Disabled arrow opacity — `opacity: fn ? 1 : 0.4`.
  static const double dimmedArrowOpacity = 0.4;

  /// The header chevron's size — `size={20}` (off the 18/24/30 icon ramp,
  /// transcribed).
  static const double chevronSize = 20;

  /// The title's weight — `fontWeight: 700`.
  static const FontWeight titleWeight = FontWeight.w700;

  /// The footer label's weight — `fontWeight: 600`.
  static const FontWeight footerWeight = FontWeight.w600;

  /// The frame colour of [tone].
  static Color frameFor(DabblerColors colors, DabblerPanelCardTone tone) =>
      switch (tone) {
        DabblerPanelCardTone.brand => colors.brandPrimary,
        DabblerPanelCardTone.amber => DabblerColors.tileAmber.surface,
        DabblerPanelCardTone.info => colors.info.solid,
        DabblerPanelCardTone.sport => DabblerPalette.sportP600,
        DabblerPanelCardTone.active => DabblerPalette.activeP600,
      };

  /// The ink on the frame colour of [tone].
  static Color onFrameFor(DabblerColors colors, DabblerPanelCardTone tone) =>
      switch (tone) {
        DabblerPanelCardTone.brand ||
        DabblerPanelCardTone.sport ||
        DabblerPanelCardTone.active => colors.onBrand,
        DabblerPanelCardTone.amber => DabblerColors.tileAmber.ink,
        DabblerPanelCardTone.info => DabblerPalette.paper,
      };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final Color on = onFrameFor(colors, tone);
    final Color panelBg = dark ? DabblerPalette.ink : colors.surfaceCard;
    final Color panelFg = dark
        ? DabblerPalette.surfacePage
        : colors.textPrimary;

    final bool hasFooter =
        footerLabel != null || onPrev != null || onNext != null;

    Widget arrow(String name, VoidCallback? fn, String label) {
      final Widget glyph = SizedBox(
        width: DabblerSizing.iconMd,
        height: DabblerSizing.iconMd,
        child: Center(
          child: Opacity(
            opacity: fn == null ? dimmedArrowOpacity : 1,
            child: DabblerIcon(name, size: DabblerSizing.iconSm, color: on),
          ),
        ),
      );
      if (fn == null) return glyph;
      return Semantics(
        button: true,
        label: label,
        onTap: fn,
        child: ExcludeSemantics(
          child: _Tappable(
            onTap: fn,
            ringRadius: DabblerRadius.smAll,
            child: SizedBox(
              width: DabblerSizing.touchTargetMin,
              height: DabblerSizing.touchTargetMin,
              child: Center(child: glyph),
            ),
          ),
        ),
      );
    }

    final Widget panel = DecoratedBox(
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: const BorderRadius.all(Radius.circular(panelRadius)),
      ),
      child: Padding(
        padding: headerInside
            ? const EdgeInsets.fromLTRB(
                DabblerSpacing.space5,
                DabblerSpacing.space5,
                DabblerSpacing.space5,
                DabblerSpacing.space2,
              )
            : EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (headerInside && title != null)
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title!,
                      style: DabblerType.headline
                          .resolveForDirection(direction)
                          .copyWith(fontWeight: titleWeight, color: panelFg),
                    ),
                  ),
                  if (onToggle != null)
                    Semantics(
                      button: true,
                      expanded: !collapsed,
                      label: collapsed ? 'Expand' : 'Collapse',
                      onTap: onToggle,
                      child: ExcludeSemantics(
                        child: _Tappable(
                          onTap: onToggle!,
                          ringRadius: DabblerRadius.pillAll,
                          child: SizedBox(
                            width: DabblerSizing.touchTargetMin,
                            height: DabblerSizing.touchTargetMin,
                            child: Center(
                              child: AnimatedRotation(
                                turns: collapsed ? 0 : 0.5,
                                duration: DabblerMotion.base,
                                child: DabblerIcon(
                                  // Down chevron — see `DabblerIconMirror`.
                                  'arrow-down-1',
                                  size: chevronSize,
                                  color: panelFg,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            DabblerCollapse(
              open: !collapsed,
              child: Padding(
                padding: EdgeInsets.only(
                  top: headerInside && title != null ? inset : 0,
                  bottom: headerInside ? DabblerSpacing.space3 : 0,
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: panelFg),
                  child: IconTheme.merge(
                    data: IconThemeData(color: panelFg),
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: frameFor(colors, tone),
          borderRadius: const BorderRadius.all(Radius.circular(frameRadius)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(inset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              panel,
              if (hasFooter) ...<Widget>[
                const SizedBox(height: inset),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DabblerSpacing.space4,
                    DabblerSpacing.space1,
                    DabblerSpacing.space4,
                    DabblerSpacing.space2,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: _footerLabel(direction, on)),
                      arrow('arrow-left-2', onPrev, 'Previous'),
                      arrow('arrow-right-3', onNext, 'Next'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLabel(TextDirection direction, Color on) {
    final Text text = Text(
      footerLabel ?? '',
      style: DabblerType.subheadline
          .resolveForDirection(direction)
          .copyWith(fontWeight: footerWeight, color: on),
    );
    if (onFooter == null || footerLabel == null) return text;
    return Semantics(
      button: true,
      label: footerLabel,
      onTap: onFooter,
      child: ExcludeSemantics(
        child: _Tappable(
          onTap: onFooter!,
          ringRadius: DabblerRadius.smAll,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: text,
          ),
        ),
      ),
    );
  }
}

/// Press, focus ring and Enter/Space around a tappable child.
class _Tappable extends StatefulWidget {
  const _Tappable({
    required this.onTap,
    required this.child,
    required this.ringRadius,
  });

  final VoidCallback onTap;
  final Widget child;
  final BorderRadius ringRadius;

  @override
  State<_Tappable> createState() => _TappableState();
}

class _TappableState extends State<_Tappable> {
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (bool v) => setState(() => _focused = v),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            widget.onTap();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
        onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: DabblerFocusRing.visible(
          visible: _focused,
          borderRadius: widget.ringRadius,
          child: DabblerPressScale(pressed: _pressed, child: widget.child),
        ),
      ),
    );
  }
}
