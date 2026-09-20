import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// InputRow — the settings / content row.
///
/// Transcribed from `components/layout/InputRow.jsx:1-63`,
/// `InputRow.d.ts:1-26`, `InputRow.prompt.md` and the specimen
/// `components/layout/layout.card.html:22-29`.
///
/// ```dart
/// DabblerInputRow(
///   title: 'my friends',
///   subtitle: 'only friends can join',
///   trailing: DabblerToggle(value: on, onChanged: setOn),
/// )
/// DabblerInputRow(title: 'pinned link', trailing: const DabblerChevron(), onTap: open)
/// ```
///
/// ## It is a forms helper that files under `layout/` in the bundle
///
/// KAN-248's own note: the design bundle keeps this in `components/layout/`
/// while it is functionally a form helper, which is why the ticket sits in the
/// forms group and the Dart file with it. Nothing about the component changes
/// either way.
///
/// ## It does NOT compose `DabblerFieldShell`, and the source is why
///
/// KAN-248 was briefed as *"compose `DabblerFieldShell` directly, pass the
/// row's items as `children`, so the 6px gap and the 45px floor stay the
/// shell's"*. **The design source does not support that**, and the source is
/// authoritative under the standing brief, so it is not what this file does.
/// The two components disagree on every value the shell owns:
///
/// | | `DabblerFieldShell` | `InputRow.jsx` |
/// |---|---|---|
/// | fill | `--surface-card` | `--surface-sunken` (`:33`) |
/// | radius | `--radius-xxl` (24) | `16` (`:32`) |
/// | inner padding | `9px 12px` | `14px 16px` (`:32`) |
/// | row gap | `--icon-gap` (6) | `12` (`:31`) |
/// | content | one row of field affordances | leading + **two-line** text column + trailing (`:39-48`) |
/// | chrome it owns | label, helper line, error line, four border states | none — no label, no message, no border |
///
/// Composing the shell would therefore mean overriding its fill, its radius,
/// its padding and its gap, and leaving four states and two text slots unused —
/// which is not composition, it is a different component wearing the shell's
/// name. The one thing the brief wanted from the shell, the **45px floor**, is
/// in the source here too (`minHeight: 45`, `:36`) and is taken from the same
/// token, [DabblerSizing.touchTargetMin]. Reported to the orchestrator with
/// KAN-248.
///
/// What it does compose is [DabblerSurface] (fill, hairline law, radius),
/// [DabblerPressScale] and [DabblerFocusRing] — the same primitives every other
/// tappable surface in the package uses.
///
/// ## The geometry is the drawn geometry, not the nearest token
///
/// **Reverted 2026-09-17 under the CEO's visual-fidelity ruling.** This file
/// previously snapped three drawn values to the nearest ramp step and
/// documented it as "token-over-literal". The fidelity brief overturns that
/// reasoning explicitly — *"the token is nearest" is how the last pass
/// failed* — so each value is now transcribed from the source literal, with
/// the token conflict named rather than resolved away.
///
/// | Source literal | Taken here | Token conflict |
/// |---|---|---|
/// | `borderRadius: 16` (`:32`) | **16** | not a step of the radius ramp, which gives 12 (`--radius-lg`) and 18 (`--radius-xl`). No token expresses it. |
/// | `padding: '14px 16px'` (`:32`) | **14** block, **16** inline | neither is a step of [DabblerSpacing]; the grid gives 12, 15 and 18. No token expresses either. |
/// | `minHeight: 45` (`:36`) | [DabblerSizing.touchTargetMin] | none — the same number, read from the token. |
///
/// The 2px the source puts between its block and inline padding **is**
/// preserved: it is what makes the row read as wider than it is tall, which
/// is visible at a glance. `gap: 12` needs no literal at all: it is
/// [DabblerSpacing.stackDefault].
///
/// ## The press tint is not ported — the system presses by scale
///
/// `InputRow.jsx:33` darkens the fill while pressed
/// (`color-mix(in srgb, var(--surface-sunken) 94%, black)` over 80ms). That is
/// the same web-era tint `lib/src/cards/card.dart` declines for exactly the
/// same reason: the package has a system-wide press affordance in
/// [DabblerPressScale], whose own doc records the design source calling it
/// *"the system's only press transform"*, and a second, row-only press
/// language would contradict it. A tappable row therefore scales like every
/// other pressable thing in the system, over the same
/// [DabblerMotion.fast] the source's own transition uses.
///
/// ## `--subtle` is not a text colour — D-003 and D-027
///
/// The source paints [subtitle] and the [DabblerChevron] in `var(--subtle)`
/// (`:45`, `:62`). `cxo`'s ruling **D-003** is that `--muted` and `--subtle`
/// are surface neutrals wrongly exposed as text roles and that `--subtle`, at
/// 2.15:1, must **never** be used as a text colour. Neither can therefore take
/// the drawn value — but they do not land in the same place, because they are
/// not the same kind of thing.
///
/// * **[subtitle] — D-003.** It is text, so it takes
///   [DabblerColors.textSecondary] (`--ink-soft`), the role the system carries
///   for a second line. The same ruling is already recorded in
///   `lib/src/forms/field_shell.dart`.
/// * **[DabblerChevron] — D-027.** It is not text. It is a non-informational
///   directional glyph, which is `--subtle`'s bounded carve-out in the design
///   source, so it takes [DabblerColors.textTertiary] (`--muted`) — lighter
///   than the subtitle, as the drawing has it.
///
/// **Why the distinction is load-bearing (D-037).** `InputRow.jsx` draws the
/// two at different weights, and painting both at `textSecondary` collapsed
/// that: a chevron reading exactly as heavy as the sentence beside it competes
/// with content it is meant to sit behind. This is a fidelity correction, not
/// a contrast one.
///
/// **The carve-out is narrow.** D-003(a) permits `--muted` here for a
/// non-informational directional glyph *only*. It does not license it for a
/// glyph that carries meaning — a status icon, a sport mark, a badge glyph. A
/// component wanting the drawn `--subtle` tone is a new role request to `cxo`,
/// not a call-site re-point.
///
/// ## Typography
///
/// [title] is `fontSize: 15, fontWeight: 400` (`:41-42`), which is
/// [DabblerType.subheadline] exactly. [subtitle] is `fontSize: 13,
/// fontWeight: 400` (`:44-45`), which is [DabblerType.footnote] exactly.
///
/// The **leadings are the source's own `22.5px` and `19.5px`**, not the type
/// ramp's 20 and 18. Same reversal as the geometry above: the ramp steps made
/// a two-line row 4.5px shorter than the drawing and closed the gap between
/// the two lines, which is visible side by side. Token conflict, named not
/// resolved: no [DabblerType] step carries a half-pixel leading, so these two
/// are applied as explicit `height` overrides on the ramp's own styles.
class DabblerInputRow extends StatelessWidget {
  /// Creates a settings row for [title].
  const DabblerInputRow({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
  });

  /// `borderRadius: 16` (`InputRow.jsx:32`), transcribed literally. **Token
  /// conflict:** the radius ramp has no 16 — it steps 12 → 18. See the class
  /// doc's table.
  static const double defaultRadius = 16;

  /// `padding: '14px 16px'` (`InputRow.jsx:32`), transcribed literally.
  /// **Token conflict:** neither 14 nor 16 is a [DabblerSpacing] step.
  /// Directional so it mirrors in RTL.
  static const EdgeInsetsDirectional defaultPadding =
      EdgeInsetsDirectional.symmetric(
    vertical: 14,
    horizontal: 16,
  );

  /// `lineHeight: '22.5px'` on the title (`InputRow.jsx:41-42`).
  static const double titleLeading = 22.5;

  /// `lineHeight: '19.5px'` on the subtitle (`InputRow.jsx:44-45`).
  static const double subtitleLeading = 19.5;

  /// `gap: 12` between the row's three slots (`InputRow.jsx:31`) —
  /// [DabblerSpacing.stackDefault], no deviation.
  static const double slotGap = DabblerSpacing.stackDefault;

  /// `minHeight: 45` (`InputRow.jsx:36`) — [DabblerSizing.touchTargetMin],
  /// which is also what makes a tappable row a legal target.
  static const double minHeight = DabblerSizing.touchTargetMin;

  /// The first line. Null drops the line; a row with neither [title] nor
  /// [subtitle] is a bare leading/trailing pair, which the source also allows.
  final String? title;

  /// The 13px second line. Null renders a single-line row — the source's
  /// `subtitle != null &&` (`InputRow.jsx:43`).
  final String? subtitle;

  /// The leading slot — an avatar, an icon tile or a glyph.
  final Widget? leading;

  /// The trailing slot — a [DabblerChevron], a toggle or a badge.
  final Widget? trailing;

  /// Makes the row tappable and adds the system press and focus affordances.
  /// Null leaves it inert, which is the source's `onClick`-absent default.
  final VoidCallback? onTap;

  /// Whether a tappable row accepts input. Ignored when [onTap] is null.
  final bool enabled;

  /// Replaces the accessible name of a tappable row.
  ///
  /// Null is the normal case and the better one: the row's own [title] and
  /// [subtitle] merge into the button's name, so it announces what it shows.
  /// Setting this **replaces** those lines rather than prefixing them — see
  /// the [ExcludeSemantics] in [build].
  final String? semanticLabel;

  /// [title]'s style — [DabblerType.subheadline], unmodified.
  static TextStyle titleStyleFor(TextDirection direction) =>
      DabblerType.subheadline
          .resolveForDirection(direction)
          .copyWith(height: titleLeading / DabblerType.subheadline.fontSize);

  /// [subtitle]'s style — [DabblerType.footnote], unmodified.
  static TextStyle subtitleStyleFor(TextDirection direction) =>
      DabblerType.footnote
          .resolveForDirection(direction)
          .copyWith(height: subtitleLeading / DabblerType.footnote.fontSize);

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool tappable = onTap != null;
    final bool interactive = tappable && enabled;

    Widget row = DabblerSurface(
      variant: DabblerSurfaceVariant.sunken,
      radius: defaultRadius,
      padding: defaultPadding,
      child: ConstrainedBox(
        // The floor sits outside the padding for the same reason it does in
        // `field_shell.dart`: the surface's height is its child's height, so 45
        // here is 45 on screen.
        constraints: const BoxConstraints(minHeight: minHeight),
        child: Row(
          children: <Widget>[
            if (leading != null) ...<Widget>[
              leading!,
              const SizedBox(width: slotGap),
            ],
            Expanded(
              // A tappable row is one button, so its content merges into one
              // accessible name. [semanticLabel] is a *replacement* for that
              // name rather than an addition to it, so the text column drops
              // out of the tree when one is given — otherwise the row would
              // announce the override and then read the same lines again.
              child: ExcludeSemantics(
                excluding: onTap != null && semanticLabel != null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (title != null)
                      Text(
                        title!,
                        style: titleStyleFor(direction).copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        // D-003: the source's `--subtle` is not a text colour.
                        style: subtitleStyleFor(direction).copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: slotGap),
              trailing!,
            ],
          ],
        ),
      ),
    );

    if (!tappable) {
      return row;
    }

    row = DabblerPressScale.gesture(
      enabled: interactive,
      child: row,
    );

    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: interactive ? onTap : null,
        child: DabblerFocusRing(
          enabled: interactive,
          canRequestFocus: interactive,
          borderRadius: const BorderRadius.all(
            Radius.circular(DabblerInputRow.defaultRadius),
          ),
          child: row,
        ),
      ),
    );
  }
}

/// Chevron — the kit's trailing disclosure glyph.
///
/// `components/layout/InputRow.jsx:53-63`: `arrow-right` at 18, in
/// `var(--subtle)`, *"exported alongside for the trailing disclosure glyph"*
/// (`InputRow.prompt.md:9`).
///
/// ## It mirrors by name, not by transform
///
/// The source's note is that the glyph *"mirrors in RTL, because Iconsax
/// renders it inside the document's own direction"*. Flutter has no such
/// ambient mirroring, and DS-300's [DabblerIcon] states outright that it
/// *"has none and never mirrors itself; the caller picks the name"*. So this
/// **is** that caller: it asks for `arrow-right` under [TextDirection.ltr] and
/// `arrow-left` under [TextDirection.rtl], which is the system's own mechanism
/// rather than a [Transform] that would flip the glyph's optical weight with
/// it.
///
/// The tint is [DabblerColors.textTertiary], not the source's `--subtle` —
/// **D-027**: a chevron is a non-informational directional glyph, not text, so
/// it takes the lighter role and sits behind the row's content rather than
/// level with it. See [DabblerInputRow]'s D-003/D-027 note.
class DabblerChevron extends StatelessWidget {
  /// Creates a disclosure chevron.
  const DabblerChevron({super.key, this.color});

  /// `size={18}` (`InputRow.jsx:62`) — [DabblerSizing.iconSm].
  static const double size = DabblerSizing.iconSm;

  /// The glyph in a left-to-right layout.
  static const String forwardIconName = 'arrow-right';

  /// The glyph in a right-to-left layout — the mirrored name, not a flipped
  /// `arrow-right`.
  static const String backwardIconName = 'arrow-left';

  /// Overrides the tint. Null takes [DabblerColors.textTertiary].
  final Color? color;

  /// The Iconsax name for [direction].
  static String iconNameFor(TextDirection direction) =>
      direction == TextDirection.rtl ? backwardIconName : forwardIconName;

  @override
  Widget build(BuildContext context) {
    return DabblerIcon(
      iconNameFor(Directionality.of(context)),
      size: size,
      color: color ?? DabblerColors.of(context).textTertiary,
    );
  }
}
