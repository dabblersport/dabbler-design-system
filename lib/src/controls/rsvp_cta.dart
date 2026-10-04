import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../feed/feed_atoms.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'button.dart';

/// Every state the RSVP call to action can be in. The state decides the colour,
/// the glyph and whether the control takes a press; the **words** come from the
/// caller, who localises them.
enum DabblerRsvpCtaState {
  /// Open to join: the brand fill — `Join meetup`.
  join(_Look.brand, null, true),

  /// Joining needs the organiser's approval: the brand fill — `Request to join`.
  request(_Look.brand, null, true),

  /// The viewer is going: success surface, a bold tick — `You are going`.
  going(_Look.success, 'tick-circle', true),

  /// The viewer is interested: warning surface, a clock — `Maybe going`.
  interested(_Look.warning, 'clock', true),

  /// A join request is waiting: info surface, a clock — `Request sent`.
  pending(_Look.info, 'clock', true),

  /// No room left, and the viewer is recorded as interested: warning surface —
  /// `Full - you're interested`. Still a press, to change the answer.
  full(_Look.warning, 'clock', true),

  /// Registration is closed: inert, the sunken fill.
  closed(_Look.inert, null, false),

  /// The meetup was cancelled: error surface, a cross. Inert.
  cancelled(_Look.error, 'close-circle', false),

  /// The meetup has started: inert, the sunken fill.
  started(_Look.inert, null, false),

  /// The viewer cannot see this meetup: inert, the sunken fill.
  notVisible(_Look.inert, null, false),

  /// The viewer's persona cannot join: the sunken fill, but still a press — it
  /// takes the viewer to switch profile.
  notAllowed(_Look.inert, null, true);

  const DabblerRsvpCtaState(this._look, this.glyph, this.interactive);

  final _Look _look;

  /// The bold Iconsax glyph before the label; null draws none.
  final String? glyph;

  /// Whether the state takes a press at all.
  final bool interactive;
}

enum _Look { brand, success, warning, info, error, inert }

/// The two sizes of an RSVP call to action.
enum DabblerRsvpCtaSize {
  /// The pinned bar's pill: [DabblerButton.fullHeight] (52) tall, label 15/20.
  bar,

  /// The listing card's action: [DabblerSizing.touchTargetMin] (45) tall, the
  /// height of a medium [DabblerButton] there.
  card,
}

/// RsvpCta — the call to action for a meetup, in every state the RSVP can be:
/// join, request, going, interested, pending, full, closed, cancelled, started,
/// not visible and not allowed.
///
/// Drawn from the meetup details bar, `Details.dc.html:359-364` and its
/// `cta()` map (`:681-702`): a full-width pill, 52 tall, 2px border, label
/// 15/20 600 with an optional bold 18 glyph before it. Idle it is the brand
/// fill; once answered it takes the status surface, its strong ink and its
/// border — success for going, warning for maybe, error for not going. The
/// frame draws three of the states; the others are the RPC's
/// (`can_current_user_rsvp_meetup`) and take the nearest role the frame has:
/// pending is the info status (no frame draws it), the closed, started,
/// not-visible and not-allowed states are the inert sunken fill the venue
/// frame's unready `Pick a space` bar draws (`:786-789`), and a cancelled
/// meetup is the error status.
///
/// ```dart
/// DabblerRsvpCta(
///   state: DabblerRsvpCtaState.going,
///   label: 'You are going',
///   onPressed: openSheet,
/// )
/// ```
///
/// ## Placing it
///
/// In a [DabblerActionBar] as `primary`, at [DabblerRsvpCtaSize.bar]; or as the
/// `action` of a [DabblerCardGame], at [DabblerRsvpCtaSize.card].
///
/// ## Accessibility
///
/// One button named [label], disabled and announced as such in an inert state,
/// a [loading] pill blocks presses. The glyph is decoration: the **label** says
/// the state, colour only reinforces it.
///
/// ## RTL
///
/// The glyph leads the label at the inline start of the pair; the pill is
/// centred and symmetrical.
class DabblerRsvpCta extends StatelessWidget {
  /// An RSVP call to action in [state].
  const DabblerRsvpCta({
    super.key,
    required this.state,
    required this.label,
    this.onPressed,
    this.size = DabblerRsvpCtaSize.bar,
    this.loading = false,
    this.semanticLabel,
  });

  /// Which state to draw.
  final DabblerRsvpCtaState state;

  /// The words, already localised.
  final String label;

  /// Runs the press. Ignored in an inert state, which is also what a null
  /// callback gives.
  final VoidCallback? onPressed;

  /// The pill's size.
  final DabblerRsvpCtaSize size;

  /// Marks the control busy and blocks presses; the pill keeps its look.
  final bool loading;

  /// Overrides the spoken name.
  final String? semanticLabel;

  /// The border's width — `border: 2px solid` (`Details.dc.html:359`).
  static const double borderWidth = 2;

  /// The glyph's side — `size="18"`, [DabblerSizing.iconSm].
  static const double glyphSize = DabblerSizing.iconSm;

  /// The bar's height — [DabblerButton.fullHeight].
  static const double barHeight = DabblerButton.fullHeight;

  /// The card's height — [DabblerSizing.touchTargetMin].
  static const double cardHeight = DabblerSizing.touchTargetMin;

  /// Whether a press reaches [onPressed].
  bool get enabled => state.interactive && onPressed != null && !loading;

  /// The pill's fill in [colors].
  static Color fillOf(DabblerColors colors, DabblerRsvpCtaState state) =>
      switch (state._look) {
        _Look.brand => colors.brandPrimary,
        _Look.success => colors.success.surface,
        _Look.warning => colors.warning.surface,
        _Look.info => colors.info.surface,
        _Look.error => colors.error.surface,
        _Look.inert => colors.surfaceSunken,
      };

  /// The label and glyph ink in [colors].
  static Color inkOf(DabblerColors colors, DabblerRsvpCtaState state) =>
      switch (state._look) {
        _Look.brand => colors.onBrand,
        _Look.success => colors.success.strong,
        _Look.warning => colors.warning.strong,
        _Look.info => colors.info.strong,
        _Look.error => colors.error.strong,
        _Look.inert => colors.textTertiary,
      };

  /// The border's colour in [colors].
  static Color borderOf(DabblerColors colors, DabblerRsvpCtaState state) =>
      switch (state._look) {
        _Look.brand => colors.brandPrimary,
        _Look.success => colors.success.base,
        _Look.warning => colors.warning.base,
        _Look.info => colors.info.base,
        _Look.error => colors.error.base,
        _Look.inert => colors.surfaceSunken,
      };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final Color ink = inkOf(colors, state);
    final Widget pill = DabblerSurface(
      fill: fillOf(colors, state),
      borderColor: borderOf(colors, state),
      borderWidth: borderWidth,
      radius: DabblerRadius.pill,
      width: double.infinity,
      height: size == DabblerRsvpCtaSize.bar ? barHeight : cardHeight,
      center: true,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerSpacing.space5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DabblerSpacing.space3 - 1,
        children: <Widget>[
          if (state.glyph != null)
            ExcludeSemantics(
              child: DabblerIcon(
                state.glyph!,
                weight: DabblerIconWeight.bold,
                size: glyphSize,
                color: ink,
              ),
            ),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // `15/20, 600` — `.t-subheadline` at semibold.
              style: DabblerType.subheadline
                  .resolveForDirection(direction)
                  .copyWith(color: ink, fontWeight: DabblerType.semibold),
            ),
          ),
        ],
      ),
    );
    return Semantics(
      container: true,
      enabled: enabled,
      child: DabblerFeedTappable(
        onTap: enabled ? onPressed : null,
        semanticLabel: semanticLabel ?? label,
        excludeChildSemantics: true,
        borderRadius: DabblerRadius.pillAll,
        child: pill,
      ),
    );
  }
}
