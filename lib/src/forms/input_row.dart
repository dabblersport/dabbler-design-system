import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/icon_mirror.dart' show DabblerIconMirror;
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'highlighted_text.dart';
import 'input_row_parts.dart';
import 'toggle.dart';

/// InputRow — the settings / content row.
///
/// Transcribed from `components/layout/InputRow.jsx:1-63`,
/// `InputRow.d.ts:1-26` (unverified: file not mirrored), `InputRow.prompt.md` and the specimen
/// `components/layout/layout.card.html:22-29` (unverified: file not mirrored).
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
    this.titleSpan,
    this.titleBadge,
    this.verified = false,
    this.value,
    this.tone = DabblerInputRowTone.standard,
    this.selected,
    this.trailingChips,
    this.flat = false,
    this.showDivider = true,
  }) : assert(
         title == null || titleSpan == null,
         'Pass title or titleSpan, not both.',
       );

  /// The info-button + toggle pattern (Settings rows with an explainer):
  /// `[info-circle] [DabblerToggle]` in the trailing slot. DS gaps 5, item 5.
  ///
  /// The row itself is not tappable — the toggle and the info button are two
  /// separate controls with their own semantics, so a screen reader reaches
  /// both. [onInfo] null drops the info button and leaves a plain toggle row.
  factory DabblerInputRow.toggle({
    Key? key,
    String? title,
    InlineSpan? titleSpan,
    String? subtitle,
    Widget? leading,
    required bool checked,
    ValueChanged<bool>? onChanged,
    bool disabled = false,
    VoidCallback? onInfo,
    String infoSemanticLabel = DabblerInputRowInfoButton.defaultSemanticLabel,
    String? toggleSemanticLabel,
    DabblerInputRowTone tone = DabblerInputRowTone.standard,
    bool flat = false,
    bool showDivider = true,
  }) {
    return DabblerInputRow(
      key: key,
      flat: flat,
      showDivider: showDivider,
      title: title,
      titleSpan: titleSpan,
      subtitle: subtitle,
      leading: leading,
      tone: tone,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (onInfo != null)
            DabblerInputRowInfoButton(
              onPressed: onInfo,
              semanticLabel: infoSemanticLabel,
            ),
          DabblerToggle(
            checked: checked,
            onChanged: onChanged,
            disabled: disabled,
            semanticLabel:
                toggleSemanticLabel ?? title ?? titleSpan?.toPlainText(),
          ),
        ],
      ),
    );
  }

  /// `borderRadius: 16` (`InputRow.jsx:32`), transcribed literally. **Token
  /// conflict:** the radius ramp has no 16 — it steps 12 → 18. See the class
  /// doc's table.
  static const double defaultRadius = 16;

  /// `padding: '14px 16px'` (`InputRow.jsx:32`), transcribed literally.
  /// **Token conflict:** neither 14 nor 16 is a [DabblerSpacing] step.
  /// Directional so it mirrors in RTL.
  static const EdgeInsetsDirectional defaultPadding =
      EdgeInsetsDirectional.symmetric(vertical: 14, horizontal: 16);

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

  /// A rich first line, the alternative to [title] — e.g. a search result
  /// with the matched run highlighted ([highlightSpan] builds exactly the
  /// [DabblerHighlightedText] treatment). The row's [titleStyleFor] and
  /// colour are the span's inherited base, so a plain child [TextSpan] reads
  /// like [title]. The accessible name is the span's plain text.
  final InlineSpan? titleSpan;

  /// A widget drawn right after the first line (inline-end), e.g. a badge.
  /// Takes precedence over [verified].
  final Widget? titleBadge;

  /// Draws the `verify` mark (bold, [DabblerColors.brandPrimary]) after the
  /// first line, labelled [verifiedSemanticLabel] for assistive technology.
  ///
  /// `Profiles.dc.html:94` draws `Icon name="verify" size="14" type="bold"`.
  /// **Deviation:** 14 is not an icon step; the mark takes
  /// [DabblerSizing.iconSm] (18), the nearest.
  final bool verified;

  /// A value shown before the trailing chevron/control — the Settings
  /// "summarised destination" (`Settings.dc.html:259-260`: 14/19, `--muted`,
  /// one line, max 150 wide, ellipsis). When [onTap] is set and [trailing]
  /// is null, a [DabblerChevron] follows it.
  ///
  /// **Deviation:** 14px has no ramp step, so the value takes
  /// [DabblerType.footnote] (13); `--muted` text maps to
  /// [DabblerColors.textSecondary] under D-003.
  final String? value;

  /// [DabblerInputRowTone.destructive] colours title, subtitle, the leading
  /// glyph (through [IconTheme]) and the chevron with the error role's
  /// `strong` step, and sets the title semibold — `Settings.dc.html:240-253`
  /// (`--color-status-error-strong`, `font-weight:600`).
  ///
  /// **Deviation:** the design keeps the subtitle `--muted`; the DS gaps 5
  /// brief asks for it in the error colour too, and that is what this does.
  final DabblerInputRowTone tone;

  /// Option-list selection. Null (default) is not an option row: no tick and
  /// no selected flag. `true` draws the bold `tick-circle` in
  /// [DabblerColors.brandPrimary] trailing (`Settings.dc.html:186`, and the
  /// `DabblerMenu` precedent) and marks the node selected; `false` marks it
  /// unselected with no tick.
  final bool? selected;

  /// Chips laid out on ONE line in the trailing area. They never wrap: the
  /// strip scrolls horizontally inside the space it is given (up to half the
  /// row), so a narrow width clips/scrolls rather than overflowing. The
  /// scroll follows the ambient direction, so RTL starts at the right.
  final List<Widget>? trailingChips;

  /// The unboxed variant for picker lists inside sheets and pages: no
  /// sunken fill, no radius, no inline padding — the row runs to its
  /// parent's gutter and the list's rhythm comes from [flatPadding] and the
  /// optional hairline under each row. DS gaps 6, item 5.
  ///
  /// Drawn at `Listings.dc.html:330` and `:338` (the location picker sheet):
  /// `display:flex; gap:12px; padding:12px 0; border-bottom:1px solid
  /// var(--faint)`. `12px 0` is [DabblerSpacing.space4] block / 0 inline,
  /// `gap:12px` is the existing [slotGap], and `--faint` is
  /// [DabblerColors.bgTertiary] at [DabblerSizing.borderDefault], the same
  /// mapping [DabblerDivider] and the reply composer use. Everything else
  /// (type, slots, tone, selection, semantics, the 45px floor) is the boxed
  /// row's. A tappable flat row keeps the press scale; its focus ring is
  /// square because there is no radius to follow.
  final bool flat;

  /// Draws the `--faint` hairline under a [flat] row. Ignored when [flat] is
  /// false. Turn it off on the last row of a list, or where the list draws
  /// its own separators.
  final bool showDivider;

  /// `padding:12px 0` (`Listings.dc.html:330`) — the [flat] row's padding.
  static const EdgeInsetsDirectional flatPadding =
      EdgeInsetsDirectional.symmetric(vertical: DabblerSpacing.space4);

  /// The default accessible name of the [verified] mark.
  static const String verifiedSemanticLabel = 'Verified';

  /// The [verified] glyph.
  static const String verifiedIconName = 'verify';

  /// The [selected] glyph.
  static const String selectedIconName = 'tick-circle';

  /// `max-width:150px` on the value (`Settings.dc.html:260`).
  static const double valueMaxWidth = 150;

  /// The span [DabblerHighlightedText] would draw for [text] with every
  /// [query] match highlighted (semibold on the brand tint), with no base
  /// style of its own so it inherits the row's title style.
  static TextSpan highlightSpan(
    String text,
    String query,
    DabblerColors colors,
  ) {
    final List<TextRange> ranges = DabblerHighlightedText.matchRanges(
      text,
      query,
    );
    if (ranges.isEmpty) {
      return TextSpan(text: text);
    }
    final TextStyle match = TextStyle(
      color: colors.brandPrimary,
      fontWeight: DabblerHighlightedText.matchWeight,
      background: Paint()
        ..color = Color.alphaBlend(
          colors.brandPrimary.withValues(
            alpha: DabblerHighlightedText.tintAlpha,
          ),
          colors.surfaceCard,
        ),
    );
    final List<InlineSpan> children = <InlineSpan>[];
    int at = 0;
    for (final TextRange range in ranges) {
      if (range.start > at) {
        children.add(TextSpan(text: text.substring(at, range.start)));
      }
      children.add(
        TextSpan(text: text.substring(range.start, range.end), style: match),
      );
      at = range.end;
    }
    if (at < text.length) {
      children.add(TextSpan(text: text.substring(at)));
    }
    return TextSpan(children: children);
  }

  /// [title]'s style — [DabblerType.subheadline], unmodified.
  static TextStyle titleStyleFor(TextDirection direction) => DabblerType
      .subheadline
      .resolveForDirection(direction)
      .copyWith(height: titleLeading / DabblerType.subheadline.fontSize);

  /// [subtitle]'s style — [DabblerType.footnote], unmodified.
  static TextStyle subtitleStyleFor(TextDirection direction) => DabblerType
      .footnote
      .resolveForDirection(direction)
      .copyWith(height: subtitleLeading / DabblerType.footnote.fontSize);

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool tappable = onTap != null;
    final bool interactive = tappable && enabled;
    final bool destructive = tone == DabblerInputRowTone.destructive;
    final Color? danger = destructive ? colors.error.strong : null;

    Widget? firstLine;
    if (title != null || titleSpan != null) {
      final TextStyle style = titleStyleFor(direction).copyWith(
        color: danger ?? colors.textPrimary,
        fontWeight: destructive ? DabblerType.semibold : null,
      );
      firstLine = titleSpan != null
          ? Text.rich(
              TextSpan(style: style, children: <InlineSpan>[titleSpan!]),
            )
          : Text(title!, style: style);
      final Widget? badge =
          titleBadge ??
          (verified
              ? DabblerIcon(
                  verifiedIconName,
                  weight: DabblerIconWeight.bold,
                  size: DabblerSizing.iconSm,
                  color: colors.brandPrimary,
                  semanticLabel: verifiedSemanticLabel,
                )
              : null);
      if (badge != null) {
        firstLine = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(child: firstLine),
            const SizedBox(width: DabblerSpacing.iconGap),
            badge,
          ],
        );
      }
    }

    final Widget? trailingSlot = _trailingSlot(colors, direction, danger);

    final Widget body = ConstrainedBox(
      // The floor sits outside the padding for the same reason it does in
      // `field_shell.dart`: the surface's height is its child's height, so 45
      // here is 45 on screen.
      constraints: const BoxConstraints(minHeight: minHeight),
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            danger == null
                ? leading!
                : IconTheme.merge(
                    data: IconThemeData(color: danger),
                    child: leading!,
                  ),
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
                  ?firstLine,
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      // D-003: the source's `--subtle` is not a text colour.
                      style: subtitleStyleFor(
                        direction,
                      ).copyWith(color: danger ?? colors.textSecondary),
                    ),
                ],
              ),
            ),
          ),
          if (trailingChips != null && trailingChips!.isNotEmpty) ...<Widget>[
            const SizedBox(width: slotGap),
            Flexible(child: DabblerInputRowChipStrip(chips: trailingChips!)),
          ],
          if (trailingSlot != null) ...<Widget>[
            const SizedBox(width: slotGap),
            tappable
                ? DabblerToggleRowScope(child: trailingSlot)
                : trailingSlot,
          ],
        ],
      ),
    );

    Widget row = flat
        ? DecoratedBox(
            decoration: BoxDecoration(
              border: showDivider
                  ? Border(
                      bottom: BorderSide(
                        color: colors.bgTertiary,
                        width: DabblerSizing.borderDefault,
                      ),
                    )
                  : null,
            ),
            child: Padding(padding: flatPadding, child: body),
          )
        : DabblerSurface(
            variant: DabblerSurfaceVariant.sunken,
            radius: defaultRadius,
            padding: defaultPadding,
            child: body,
          );

    if (!tappable) {
      if (selected == null) {
        return row;
      }
      return Semantics(container: true, selected: selected, child: row);
    }

    row = DabblerPressScale.gesture(enabled: interactive, child: row);

    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      selected: selected,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: interactive ? onTap : null,
        child: DabblerFocusRing(
          enabled: interactive,
          canRequestFocus: interactive,
          borderRadius: flat
              ? BorderRadius.zero
              : const BorderRadius.all(
                  Radius.circular(DabblerInputRow.defaultRadius),
                ),
          child: row,
        ),
      ),
    );
  }

  /// value → trailing (or the implied chevron) → selected tick.
  Widget? _trailingSlot(
    DabblerColors colors,
    TextDirection direction,
    Color? danger,
  ) {
    final Widget? end =
        trailing ??
        (value != null && onTap != null ? DabblerChevron(color: danger) : null);
    final List<Widget> parts = <Widget>[
      if (value != null)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: valueMaxWidth),
          child: Text(
            value!,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: DabblerType.footnote
                .resolveForDirection(direction)
                .copyWith(color: danger ?? colors.textSecondary),
          ),
        ),
      if (end != null)
        danger != null && end is DabblerChevron && end.color == null
            ? DabblerChevron(color: danger)
            : end,
      if (selected ?? false)
        DabblerIcon(
          selectedIconName,
          weight: DabblerIconWeight.bold,
          size: DabblerSizing.iconSm,
          color: colors.brandPrimary,
        ),
    ];
    if (parts.isEmpty) {
      return null;
    }
    if (parts.length == 1 && value == null) {
      return parts.single;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < parts.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: DabblerSpacing.iconGap),
          if (i == 0 && value != null) Flexible(child: parts[i]) else parts[i],
        ],
      ],
    );
  }
}

/// The row's colour treatment.
enum DabblerInputRowTone {
  /// Ink title, secondary subtitle — the default.
  standard,

  /// Error-strong title (semibold), subtitle, leading glyph and chevron —
  /// "Sign out" / "Delete account" (`Settings.dc.html:980-998`).
  destructive,
}

/// Chevron — the kit's trailing disclosure glyph.
///
/// `components/layout/InputRow.jsx:53-63`: web Iconsax `arrow-right` at 18, in
/// `var(--subtle)`. The phrase *"exported alongside for the trailing
/// disclosure glyph"* is quoted from `InputRow.prompt.md:9` (unverified: file
/// not mirrored), not from `InputRow.jsx`.
///
/// ## It mirrors by name, not by transform — and the names are measured
///
/// The source's note is that the glyph *"mirrors in RTL, because Iconsax
/// renders it inside the document's own direction"*. Flutter has no such
/// ambient mirroring, and DS-300's [DabblerIcon] states outright that it
/// *"has none and never mirrors itself; the caller picks the name"*. So this
/// **is** that caller: it asks for [forwardIconName] under
/// [TextDirection.ltr] and [backwardIconName] under [TextDirection.rtl].
///
/// **Corrected DS gaps 6 (item 13).** This used to ask for `arrow-right` /
/// `arrow-left`, which in `iconsax_flutter` 1.0.1 are neither the drawn glyph
/// nor a mirrored pair (measured in [DabblerIconMirror]'s table): linear
/// `arrow-right` renders a chevron inside a rounded square, and `arrow-left`
/// a long shafted arrow. The design draws the kit's `Chevron`
/// (`Settings.dc.html:94`, `:131`, `:173`, `:266`; the Arabic frame at
/// `:368` onwards, e.g. `:422`, `:459`), which is the web Iconsax `arrow-right`
/// at 18 — a bare open chevron. In `iconsax_flutter` that bare chevron is
/// published as `arrow-right-3`, and its pixel mirror is `arrow-left-2`
/// (the linear row of [DabblerIconMirror.linearPairs]). The pair is therefore
/// both the drawn glyph and a true mirror; `test/forms/chevron_mirror_test.dart`
/// re-renders it and fails if either stops being true.
///
/// The tint is [DabblerColors.textTertiary], not the source's `--subtle` —
/// **D-027**: a chevron is a non-informational directional glyph, not text, so
/// it takes the lighter role and sits behind the row's content rather than
/// level with it. See [DabblerInputRow]'s D-003/D-027 note.
class DabblerChevron extends StatelessWidget {
  /// Creates a disclosure chevron.
  const DabblerChevron({super.key, this.color, this.circled = false});

  /// Draws the glyph inside its ring — the disclosure mark the Settings frames
  /// render (`Settings.dc.html:97`, `:134`, `:269`): `arrow-circle-right` in
  /// LTR, `arrow-circle-left` in RTL, both at [size]. Default false, which is
  /// the bare open chevron every other row uses.
  final bool circled;

  /// [circled]'s glyph in a left-to-right layout.
  static const String circledForwardIconName = 'arrow-circle-right';

  /// [circled]'s glyph in a right-to-left layout.
  static const String circledBackwardIconName = 'arrow-circle-left';

  /// `size={18}` (`InputRow.jsx:62`) — [DabblerSizing.iconSm].
  static const double size = DabblerSizing.iconSm;

  /// The glyph in a left-to-right layout.
  static const String forwardIconName = 'arrow-right-3';

  /// The glyph in a right-to-left layout — the measured pixel mirror of
  /// [forwardIconName], not a flipped glyph.
  static const String backwardIconName = 'arrow-left-2';

  /// Overrides the tint. Null takes [DabblerColors.textTertiary].
  final Color? color;

  /// The Iconsax name for [direction].
  static String iconNameFor(TextDirection direction) =>
      direction == TextDirection.rtl ? backwardIconName : forwardIconName;

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);
    return DabblerIcon(
      circled
          ? (direction == TextDirection.rtl
                ? circledBackwardIconName
                : circledForwardIconName)
          : iconNameFor(direction),
      size: size,
      color: color ?? DabblerColors.of(context).textTertiary,
    );
  }
}
