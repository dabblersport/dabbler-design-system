import 'package:flutter/widgets.dart';

import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';
import '../tokens/dabbler_type.dart';
import 'card.dart';

/// The five colours the ticket's header strip is drawn in.
///
/// Transcribed from the `HEADERS` table at the head of
/// `components/cards/CardTicket.jsx`. Each value carries its own fill **and**
/// its own ink, because four of the five are decorative tile tones whose ink is
/// fixed by the tone rather than by the theme.
enum DabblerTicketHeader {
  /// `--color-brand-primary` / `--color-on-brand`. The only entry that follows
  /// the active theme.
  brand,

  /// `--accent-indigo` / `--neutral-white`. **The source default**, and a known
  /// defect here — see [DabblerCardTicket.indigoFill].
  indigo,

  /// `--tile-amber-surface` / `--tile-amber-ink`.
  amber,

  /// `--color-status-success-surface` / `--color-status-success-strong`. The
  /// one header that reads off the status API; the source calls it *mint*.
  mint,

  /// `--tile-accent-surface` / `--tile-accent-ink`.
  pink,
}

/// The eleven tones the ticket's status pill is drawn in.
///
/// Transcribed from the `STATUSES` table in `CardTicket.jsx`. Seven are the
/// workflow tags of `tokens/colors.css`; the last four are the **booking
/// aliases** `CardTicket.prompt.md` names, each pointing at one of the seven.
/// They are kept as distinct values rather than collapsed, because the product
/// says "upcoming", not "progress", and a component that forces the caller to
/// translate is a component that will be translated wrongly.
enum DabblerTicketStatusTone {
  /// `--tag-pending-*`.
  pending,

  /// `--tag-progress-*`.
  progress,

  /// `--tag-submitted-*`.
  submitted,

  /// `--tag-review-*`.
  review,

  /// `--tag-success-*`.
  success,

  /// `--tag-failed-*`.
  failed,

  /// `--tag-expired-*`.
  expired,

  /// Booking alias → `--tag-progress-*`. The source default.
  upcoming,

  /// Booking alias → `--tag-review-*`.
  past,

  /// Booking alias → `--tag-success-*`.
  live,

  /// Booking alias → `--tag-failed-*`.
  cancelled,
}

/// One ink pill on the ticket's bottom row.
@immutable
class DabblerTicketAction {
  /// An action labelled [label].
  const DabblerTicketAction({required this.label, this.onPressed});

  /// The pill's text — *"Register"*, *"View Detail"*.
  final String label;

  /// Tapping it. Null renders an inert pill, which is how a disabled action
  /// reads.
  final VoidCallback? onPressed;
}

/// CardTicket — a booking as a ticket: a coloured header strip carrying a
/// reference code and a date, over a white body with the organiser, the title,
/// a status pill, a dashed rule, and the price beside its actions.
///
/// Transcribed from `components/cards/CardTicket.jsx`, `CardTicket.d.ts` and
/// `CardTicket.prompt.md`, and checked against the four specimens in
/// `components/cards/cards.card.html:63-66`.
///
/// ```dart
/// DabblerCardTicket(
///   header: DabblerTicketHeader.indigo,
///   code: 'GBD99763JS',
///   date: '24/09/2024',
///   organiser: 'Reform Padel Club',
///   title: 'Tuesday Padel Doubles',
///   status: 'Upcoming',
///   statusTone: DabblerTicketStatusTone.upcoming,
///   price: 'AED 45',
///   actions: <DabblerTicketAction>[
///     DabblerTicketAction(label: 'Register'),
///     DabblerTicketAction(label: 'Done'),
///   ],
/// )
/// ```
///
/// `CardTicket.prompt.md`: *"Pass one action for a past booking ("View
/// Detail"), two for an open one. Omit `status` to drop the pill."*
///
/// ## It composes [DabblerCard] and adds no chrome (KAN-234 AC1)
///
/// Four slots, exactly as DS-800 published them:
///
/// * [DabblerCard.media] — the coloured strip. The slot is full-bleed and
///   clipped to the radius, which is what the strip needs and what the padded
///   slots could not give it.
/// * [DabblerCard.header] — organiser, title, status pill.
/// * [DabblerCard.child] — the dashed rule.
/// * [DabblerCard.footer] — price beside actions.
///
/// with [DabblerCardVariant.white] (`background: var(--surface-card)`) and
/// [DabblerRadius.xxl]. The radius is the one place `CardTicket` gets to
/// override DS-800's default and the source and the ramp agree for once:
/// `borderRadius: 24` is `--radius-xxl` exactly, and DS-800's own doc names
/// `CardTicket` as the variant expected to pass it.
///
/// ## The one structural simplification, stated
///
/// The source nests two boxes: an outer box filled with the header colour, and
/// an inner white box that carries **its own** `borderRadius: 24`, so the white
/// body's top corners curve over the coloured strip. Composed on [DabblerCard]
/// the card is one white surface with the strip in [DabblerCard.media], so the
/// strip's bottom edge is straight.
///
/// This is deliberate. Reproducing the overlap needs either a second nested
/// card — re-deriving chrome DS-800 exists to settle — or a clip the slot
/// contract does not offer. The delta is two 24px corners on an internal seam;
/// the cost of removing it is the thing KAN-233/234/242 were split out to
/// avoid. Recorded rather than hidden.
///
/// ## `indigo` is a KNOWN DEFECT pending `DECISIONS.md` D-004
///
/// See [indigoFill]. The wording there is deliberately the same as
/// `lib/src/surfaces/avatar.dart`'s, because it is the same defect at a third
/// call site and all three move together.
class DabblerCardTicket extends StatelessWidget {
  /// A ticket card.
  const DabblerCardTicket({
    super.key,
    this.code,
    this.date,
    this.organiser,
    this.title,
    this.price,
    this.status,
    this.statusTone = DabblerTicketStatusTone.upcoming,
    this.actions = const <DabblerTicketAction>[],
    this.header = DabblerTicketHeader.indigo,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
    this.width,
  });

  /// The booking reference, at the leading end of the strip. Ellipsised — it is
  /// the only thing on the strip that may be long.
  final String? code;

  /// The date, at the trailing end of the strip. Never shrinks.
  final String? date;

  /// The small muted line above [title].
  final String? organiser;

  /// The booking's title.
  final String? title;

  /// The large figure on the bottom row — *"AED 45"*.
  final String? price;

  /// The status pill's text. Null drops the pill, per `CardTicket.prompt.md`.
  final String? status;

  /// The pill's colour. Ignored when [status] is null. Defaults to
  /// [DabblerTicketStatusTone.upcoming], the source's own default.
  final DabblerTicketStatusTone statusTone;

  /// The ink pills on the bottom row, leading to trailing.
  final List<DabblerTicketAction> actions;

  /// The strip's colour. Defaults to [DabblerTicketHeader.indigo], the source's
  /// own default — see [indigoFill] before relying on it.
  final DabblerTicketHeader header;

  /// Makes the whole card tappable — opening the booking.
  final VoidCallback? onTap;

  /// Whether the card and its actions accept input.
  final bool enabled;

  /// The accessible label of a tappable card. Ignored when [onTap] is null.
  final String? semanticLabel;

  /// Fixed width. The specimens pass `width={400}`; null takes the column's.
  final double? width;

  /// `borderRadius: 24` — [DabblerRadius.xxl], no deviation.
  static const double radius = DabblerRadius.xxl;

  /// The strip's padding — `padding: '15px 24px'`.
  ///
  /// [DabblerSpacing.space5] (15) and [DabblerSpacing.space8] (24), both on the
  /// base-3 grid, both transcribed without deviation.
  static const EdgeInsetsDirectional stripPadding =
      EdgeInsetsDirectional.symmetric(
    vertical: DabblerSpacing.space5,
    horizontal: DabblerSpacing.space8,
  );

  /// The body's padding — `padding: '18px 24px 21px'`.
  ///
  /// 18 is [DabblerSpacing.cardPadding], 24 is [DabblerSpacing.space8] and 21
  /// is [DabblerSpacing.space7]. All three are grid steps, so
  /// [DabblerCard.defaultPadding] is overridden with the source's asymmetric
  /// figure rather than flattened to 18 — unlike the radius and padding
  /// literals DS-800 had to correct, nothing here is off the ramp.
  static const EdgeInsetsDirectional bodyPadding =
      EdgeInsetsDirectional.fromSTEB(
    DabblerSpacing.space8,
    DabblerSpacing.cardPadding,
    DabblerSpacing.space8,
    DabblerSpacing.space7,
  );

  /// The gap between the body's three slots — `gap: 15`
  /// ([DabblerSpacing.space5]), not [DabblerCard]'s default 12.
  static const double bodyGap = DabblerSpacing.space5;

  /// The gap inside a row — `gap: 12` ([DabblerSpacing.stackDefault]) on the
  /// strip, the title row and the footer alike.
  static const double rowGap = DabblerSpacing.stackDefault;

  /// The gap between the organiser line and the title — `gap: 3`
  /// ([DabblerSpacing.space1]).
  static const double titleGap = DabblerSpacing.space1;

  /// An action pill's height.
  ///
  /// [DabblerSizing.touchTargetMin] (45), **not** the source's `height: 40`.
  /// `--touch-target-min` is 45 and the source's own annotation says it clears
  /// Apple's 44pt floor; 40 clears neither. The token wins, on the same
  /// token-over-literal reasoning DS-800 applied to radius and padding.
  static const double actionHeight = DabblerSizing.touchTargetMin;

  /// An action pill's horizontal padding — `padding: '0 20px'`.
  ///
  /// **Off the base-3 grid, and transcribed anyway.** 20 is not a step of
  /// [DabblerSpacing]; snapping it to 18 or 21 would narrow or widen every
  /// action pill in the product to satisfy a grid the source did not use here.
  static const double actionPadding = 20;

  /// The dashed rule's dash and gap lengths.
  ///
  /// **Not design-source values.** The source writes
  /// `borderTop: '1px dashed var(--outline-card)'` and leaves the dash pattern
  /// to the browser, which has no specified length — Blink draws roughly 2:2 at
  /// 1px. Flutter has no dashed border, so the pattern must be named somewhere;
  /// [DabblerSpacing.space1] (3) on and 3 off is the nearest grid value to what
  /// the browsers actually paint, and it is a step rather than a magic number.
  static const double dashLength = DabblerSpacing.space1;

  /// The gap between dashes. See [dashLength].
  static const double dashGap = DabblerSpacing.space1;

  /// **A KNOWN DEFECT pending `DECISIONS.md` D-004.**
  ///
  /// `CardTicket.jsx` fills the `indigo` strip with `var(--accent-indigo)`,
  /// which `tokens/colors.css` never declares. `cxo` ruled (D-004) that this is
  /// a real omission: the token is `#5C50E6`, it will be declared in the CSS,
  /// then transcribed to `DabblerPalette.accentIndigo`, and only then does this
  /// call site change. Until that sequence completes, `indigo` resolves to
  /// [DabblerPalette.socialInfo] (`--social-info`, `#6366F1`).
  ///
  /// **That stand-in is a defect, not a close-enough approximation** — the
  /// wording, and the value, are `lib/src/surfaces/avatar.dart`'s, because it
  /// is the same defect. `cxo` measured the contrast loss there; a strip is a
  /// larger area than a badge, so the loss is at least as visible here. This is
  /// the third call site (`avatar.dart`, `fab.dart`, this file) and all three
  /// move together. Do not treat this line as settled, and do not copy it.
  static Color indigoFill(DabblerColors colors) => DabblerPalette.socialInfo;

  /// The strip's fill for [header], resolved against [colors].
  static Color headerFillOf(
    DabblerTicketHeader header,
    DabblerColors colors,
  ) =>
      switch (header) {
        DabblerTicketHeader.brand => colors.brandPrimary,
        DabblerTicketHeader.indigo => indigoFill(colors),
        DabblerTicketHeader.amber => DabblerColors.tileAmber.surface,
        DabblerTicketHeader.mint => colors.success.surface,
        DabblerTicketHeader.pink => DabblerColors.tileAccent.surface,
      };

  /// The strip's ink for [header], resolved against [colors].
  ///
  /// `indigo` names `--neutral-white`, a literal rather than a theme role, so
  /// it takes [DabblerPalette.paper] directly: the strip's fill is
  /// brightness-invariant, so its ink has to be too, and `--surface-card` is
  /// not white in dark mode.
  static Color headerInkOf(
    DabblerTicketHeader header,
    DabblerColors colors,
  ) =>
      switch (header) {
        DabblerTicketHeader.brand => colors.onBrand,
        DabblerTicketHeader.indigo => DabblerPalette.paper,
        DabblerTicketHeader.amber => DabblerColors.tileAmber.ink,
        DabblerTicketHeader.mint => colors.success.strong,
        DabblerTicketHeader.pink => DabblerColors.tileAccent.ink,
      };

  /// The `--tag-*` pair [tone] draws in, with the four booking aliases resolved
  /// to the workflow tag each one points at.
  static DabblerToneColor toneColorOf(DabblerTicketStatusTone tone) =>
      switch (tone) {
        DabblerTicketStatusTone.pending => DabblerColors.tagPending,
        DabblerTicketStatusTone.progress ||
        DabblerTicketStatusTone.upcoming =>
          DabblerColors.tagProgress,
        DabblerTicketStatusTone.submitted => DabblerColors.tagSubmitted,
        DabblerTicketStatusTone.review ||
        DabblerTicketStatusTone.past =>
          DabblerColors.tagReview,
        DabblerTicketStatusTone.success ||
        DabblerTicketStatusTone.live =>
          DabblerColors.tagSuccess,
        DabblerTicketStatusTone.failed ||
        DabblerTicketStatusTone.cancelled =>
          DabblerColors.tagFailed,
        DabblerTicketStatusTone.expired => DabblerColors.tagExpired,
      };

  /// [tone] expressed as the [DabblerStatusColor] [DabblerBadge] consumes.
  ///
  /// The tag palette is a surface/ink **pair**; `DabblerStatusColor` wants
  /// four roles. `surface` takes the pair's surface and `strong` its ink, which
  /// are the only two [DabblerBadge] reads. `base` and `solid` are filled with
  /// the ink so neither can silently paint a colour the tag palette does not
  /// contain — the badge never reads them.
  static DabblerStatusColor statusColorOf(DabblerTicketStatusTone tone) {
    final DabblerToneColor pair = toneColorOf(tone);
    return DabblerStatusColor(
      base: pair.ink,
      surface: pair.surface,
      strong: pair.ink,
      solid: pair.ink,
    );
  }

  /// The strip's text style — `fontSize: 17, lineHeight: '22px',
  /// fontWeight: 500`, which is `.t-callout` exactly. No deviation.
  static TextStyle codeStyleFor(TextDirection direction) =>
      DabblerType.callout.resolveForDirection(direction);

  /// The organiser line — `fontSize: 14, lineHeight: '19px'`.
  ///
  /// **The ramp has no 14.** `.t-footnote` (13/18, weight 400) is the nearest
  /// step and the one the system uses for a muted line under a title; taking it
  /// loses 1px of size rather than introducing a step the ramp does not have.
  static TextStyle organiserStyleFor(TextDirection direction) =>
      DabblerType.footnote.resolveForDirection(direction);

  /// The title — `fontSize: 22, lineHeight: '28px', fontWeight: 500` set in
  /// `var(--font-sans)`.
  ///
  /// `.t-title-2` is 22/28 exactly, so the metrics are the ramp's. But every
  /// title step is a **display**-role style at weight 400, and the source
  /// explicitly sets the *sans* face at Medium. Both of those are the source's
  /// own instructions, so both are applied on top of the step — see
  /// [_sansAt], and see `lib/src/surfaces/badge.dart` for the precedent of
  /// applying a source weight to a ramp step.
  static TextStyle titleStyleFor(TextDirection direction) =>
      _sansAt(DabblerType.title2, direction, DabblerType.medium);

  /// The price — `fontSize: 28, lineHeight: '34px', fontWeight: 500` in
  /// `var(--font-sans)`. `.t-title-1` metrics, sans face, Medium. See
  /// [titleStyleFor].
  static TextStyle priceStyleFor(TextDirection direction) =>
      _sansAt(DabblerType.title1, direction, DabblerType.medium);

  /// An action pill's label — `fontSize: 15, lineHeight: '20px',
  /// fontWeight: 500`, which is `.t-subheadline`'s metrics at Medium where the
  /// step carries 400.
  static TextStyle actionStyleFor(TextDirection direction) =>
      DabblerType.subheadline
          .resolveForDirection(direction)
          .copyWith(fontWeight: DabblerType.medium);

  /// [step]'s metrics, re-set in the sans face at [weight].
  ///
  /// Used only where the source pairs a title-sized figure with
  /// `var(--font-sans)`. It re-points the family and the fallbacks together;
  /// changing one and not the other would leave the step falling back to a
  /// serif the moment the display binary is missing.
  static TextStyle _sansAt(
    DabblerTypeStyle step,
    TextDirection direction,
    FontWeight weight,
  ) {
    final DabblerTypeScript script = direction == TextDirection.rtl
        ? DabblerTypeScript.arabic
        : DabblerTypeScript.latin;
    return step.resolve(script).copyWith(
          fontFamily:
              DabblerType.fontFamilyFor(DabblerTypeRole.sans, script),
          fontFamilyFallback:
              DabblerType.fontFamilyFallbackFor(DabblerTypeRole.sans, script),
          fontWeight: weight,
        );
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    return DabblerCard(
      variant: DabblerCardVariant.white,
      radius: radius,
      width: width,
      padding: bodyPadding,
      gap: bodyGap,
      onTap: onTap,
      enabled: enabled,
      semanticLabel: semanticLabel,
      media: _strip(colors, direction),
      header: _titleRow(colors, direction),
      footer: _footer(colors, direction),
      child: _DashedRule(color: colors.borderDefault),
    );
  }

  /// The coloured header strip: code at the leading end, date at the trailing.
  Widget _strip(DabblerColors colors, TextDirection direction) {
    final TextStyle style = codeStyleFor(direction)
        .copyWith(color: headerInkOf(header, colors));

    return Container(
      color: headerFillOf(header, colors),
      padding: stripPadding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              code ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          if (date != null) ...<Widget>[
            const SizedBox(width: rowGap),
            Text(date!, maxLines: 1, style: style),
          ],
        ],
      ),
    );
  }

  /// Organiser and title, with the status pill trailing.
  Widget _titleRow(DabblerColors colors, TextDirection direction) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (organiser != null)
                Text(
                  organiser!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: organiserStyleFor(direction)
                      .copyWith(color: colors.textSecondary),
                ),
              if (organiser != null && title != null)
                const SizedBox(height: titleGap),
              if (title != null)
                Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyleFor(direction)
                      .copyWith(color: colors.textPrimary),
                ),
            ],
          ),
        ),
        if (status != null) ...<Widget>[
          const SizedBox(width: rowGap),
          DabblerBadge(
            label: status!,
            status: statusColorOf(statusTone),
          ),
        ],
      ],
    );
  }

  /// The price beside its action pills.
  Widget _footer(DabblerColors colors, TextDirection direction) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            price ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                priceStyleFor(direction).copyWith(color: colors.textPrimary),
          ),
        ),
        for (final DabblerTicketAction action in actions) ...<Widget>[
          const SizedBox(width: rowGap),
          _action(action, colors, direction),
        ],
      ],
    );
  }

  /// One ink pill.
  ///
  /// Drawn here rather than composed, and that is a **temporary** state worth
  /// reading before copying.
  ///
  /// The pill is the source's `Action` (`CardTicket.jsx:41-49`) — `--ink` fill,
  /// `--surface-page` ink, pill radius — wrapped in the system's own press and
  /// focus primitives so it does not invent an interaction language.
  ///
  /// `lib/src/controls/button.dart` (`DabblerButton`) landed **while KAN-234
  /// was being written**, and it is another ticket's surface, so it is not
  /// composed here: doing so would mean this card asserting a tone/size mapping
  /// against an API that had not yet been reviewed. The follow-up is concrete
  /// and small — replace this method with a `DabblerButton` whose tone paints
  /// `--ink` — and it is reported as a hand-off with KAN-234. `CardHouse`'s
  /// join pill carries the same follow-up.
  Widget _action(
    DabblerTicketAction action,
    DabblerColors colors,
    TextDirection direction,
  ) {
    final bool live = action.onPressed != null && enabled;

    final Widget pill = Container(
      height: actionHeight,
      alignment: Alignment.center,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: actionPadding,
      ),
      decoration: BoxDecoration(
        color: colors.textPrimary,
        borderRadius: DabblerRadius.pillAll,
      ),
      child: Text(
        action.label,
        maxLines: 1,
        style: actionStyleFor(direction).copyWith(color: colors.bgPrimary),
      ),
    );

    if (!live) return pill;

    return Semantics(
      button: true,
      label: action.label,
      onTap: action.onPressed,
      child: DabblerFocusRing(
        borderRadius: DabblerRadius.pillAll,
        child: DabblerPressScale.gesture(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: action.onPressed,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: pill,
            ),
          ),
        ),
      ),
    );
  }
}

/// The `1px dashed var(--outline-card)` rule between the ticket's title row and
/// its price row (`CardTicket.jsx:93`).
///
/// A [CustomPaint] rather than a [Border], because Flutter's border painters
/// draw solid strokes only. It is deliberately not part of DS-600's
/// `DabblerDivider`, which declares no dashed style: adding one there is a
/// change to another ticket's surface.
class _DashedRule extends StatelessWidget {
  const _DashedRule({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DabblerSizing.borderDefault,
      width: double.infinity,
      child: CustomPaint(painter: _DashedRulePainter(color: color)),
    );
  }
}

class _DashedRulePainter extends CustomPainter {
  const _DashedRulePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = DabblerSizing.borderDefault;
    final double y = size.height / 2;
    const double step =
        DabblerCardTicket.dashLength + DabblerCardTicket.dashGap;

    for (double x = 0; x < size.width; x += step) {
      final double end =
          (x + DabblerCardTicket.dashLength).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRulePainter oldDelegate) =>
      oldDelegate.color != color;
}
