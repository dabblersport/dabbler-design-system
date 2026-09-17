import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_neutral_status.dart';
import '../tokens/dabbler_type.dart';

/// The eight **decorative** badge tones.
///
/// Transcribed verbatim from the `TONES` table of the design source
/// `components/surfaces/Badge.jsx:19-28`, which merges the Figma kit's eight
/// standalone Badge symbols into one component.
///
/// ## These names are not semantic, and that is deliberate
///
/// `Badge.prompt.md` is explicit: *"`tone` is decorative and keeps the Figma
/// file's own vocabulary, which is **not semantic**: `error` is **purple**,
/// `success` is **black**, `warning` is a neutral tint, `info` is indigo.
/// These names describe the file's symbols, not meaning — they are kept
/// verbatim so design and engineering say the same word. `tone="error"`
/// remains decorative purple and always will; that is documented behaviour,
/// not a bug."*
///
/// The mismatch has therefore been **transcribed, not corrected**. A badge that
/// means something takes [DabblerBadge.status] instead, which is the semantic
/// API and which wins whenever both are set.
enum DabblerBadgeTone {
  /// `--color-brand-primary` on `--surface-card` ink. The source's `default`,
  /// renamed only because `default` is a reserved word in Dart.
  defaultTone,

  /// `--color-accent` on `--surface-card` ink.
  primary,

  /// **Black**, not green: `--ink` on `--surface-card` ink
  /// (`Badge.jsx:25`).
  success,

  /// **A neutral tint**, not amber: `--faint` fill with `--muted` ink
  /// (`Badge.jsx:26`).
  warning,

  /// **Purple**, not red: the same `--color-brand-primary` pair as
  /// [defaultTone] (`Badge.jsx:21`). See the enum doc.
  error,

  /// Indigo — `--accent-indigo` in the source. See
  /// [DabblerBadge.decorativeIndigo] for why this is an approximation.
  info,

  /// `--color-accent`, identical to [primary] in the source
  /// (`Badge.jsx:23`). Kept as its own value because the Figma kit ships it as
  /// a separate symbol.
  pill,

  /// `--faint` / `--muted`, identical to [warning] in the source
  /// (`Badge.jsx:27`). Kept for the same reason as [pill]: it is one of the
  /// kit's eight symbols.
  withIcon,
}

/// Badge — the pill that labels a row, a card or a tab.
///
/// Transcribed from `components/surfaces/Badge.jsx`, `Badge.d.ts` and
/// `Badge.prompt.md`: *"Pill (9999), 4/10 padding, 11px Bold. Figma wins on
/// every value."*
///
/// ```dart
/// const DabblerBadge(label: 'live', tone: DabblerBadgeTone.pill);
/// DabblerBadge(label: 'cancelled', status: DabblerColors.of(context).error);
/// ```
///
/// ## Two APIs, and [status] wins
///
/// * [tone] is **decorative**. It carries the Figma file's own names, which do
///   not mean what they say — see [DabblerBadgeTone].
/// * [status] is **semantic**. It paints the status surface, the status
///   **strong** ink, and a 1px hairline of that strong colour at 20%.
///
/// When both are passed, [status] wins and [tone] is ignored entirely. That is
/// `Badge.jsx:34` (`const semantic = status ? … : null`) and it is asserted
/// directly in `test/surfaces/badge_test.dart`.
///
/// ## [status] is a [DabblerStatusColor], never a [Color]
///
/// The type is compiler-enforced, per DS-102's distinct-type criterion: a
/// status is a set of four related roles, and a bare [Color] cannot answer
/// which ink goes on it or which hairline it carries. Passing a [Color] here
/// does not compile. Reach the four semantic tones through
/// [DabblerColors.of] — `colors.success`, `colors.warning`, `colors.error`,
/// `colors.info` — or [DabblerColors.status] for one selected by
/// [DabblerStatusTone].
///
/// The source's fifth status value, `neutral`, has no entry in the
/// `--color-status-*` API and therefore no [DabblerColors] field; it is built
/// from the paper ramp by [neutralStatusOf].
///
/// ## Flat
///
/// One fill, one optional hairline, no shadow and no gradient — the system's
/// flat law. The decorative tones carry **no** border at all
/// (`Badge.jsx:41`: `border: semantic ? … : 'none'`).
///
/// ## RTL
///
/// [icon] and [label] sit in flow, so the glyph moves to the trailing side in
/// RTL, which is what `Badge.prompt.md` specifies. Numerals stay Western
/// Arabic, via [DabblerType.numeralFeatures] carried by the resolved style.
///
/// ## Accessibility
///
/// A badge is text and is read as text; no [Semantics] wrapper is added. Per
/// `Badge.prompt.md`, if the badge is the only carrier of a state, the
/// surrounding row must name that state too — colour and a short pill are not
/// enough on their own.
class DabblerBadge extends StatelessWidget {
  /// A badge showing [label].
  ///
  /// Pass [status] for a badge that means something; pass [tone] for a purely
  /// decorative one. [status] wins when both are set.
  const DabblerBadge({
    super.key,
    required this.label,
    this.tone = DabblerBadgeTone.defaultTone,
    this.status,
    this.icon,
  });

  /// The pill's text.
  final String label;

  /// The decorative tone. Ignored when [status] is set. Defaults to
  /// [DabblerBadgeTone.defaultTone].
  final DabblerBadgeTone tone;

  /// The semantic status. Overrides [tone] when set.
  final DabblerStatusColor? status;

  /// Leading glyph. Adds a [iconGap] gap; sits on the leading side, so it moves
  /// to the right in RTL.
  final Widget? icon;

  /// Vertical padding — `4` (`Badge.jsx:39`, `padding: '4px 10px'`).
  ///
  /// **Off the spacing scale, on purpose.** [DabblerSpacing] is a 3px ramp and
  /// declares no `4`. The source's own header says *"Figma wins on every
  /// value"*, so the Figma padding is transcribed rather than snapped to
  /// [DabblerSpacing.space1] (`3`) or [DabblerSpacing.space2] (`6`), either of
  /// which would change the pill's rendered height.
  static const double verticalPadding = 4;

  /// Horizontal padding — `10` (`Badge.jsx:39`). Off the scale for the same
  /// reason as [verticalPadding].
  static const double horizontalPadding = 10;

  /// The gap between [icon] and [label] — `4` (`Badge.jsx:37`,
  /// `gap: icon ? 4 : 0`). Not [DabblerSpacing.iconGap] (`6`), which would
  /// widen the pill past the Figma symbol.
  static const double iconGap = 4;

  /// The opacity the semantic hairline takes over [DabblerStatusColor.strong] —
  /// `0.20`, from `statusHairline` in
  /// `components/foundations/overlay.jsx:169-173`.
  static const double hairlineOpacity = 0.20;

  /// The badge's text style: 11px **Bold**, leading 1.5.
  ///
  /// [DabblerType.caption2] is the ramp's only 11px step and supplies the size
  /// and the face; the source sets `fontWeight: 700` and `lineHeight: 1.5`
  /// (`Badge.jsx:43`), where the ramp step is weight 400 at 13px leading. Both
  /// deltas are the source's, so they are applied on top of the step rather
  /// than a new step being invented.
  static TextStyle textStyleFor(TextDirection direction) =>
      DabblerType.caption2.resolveForDirection(direction).copyWith(
            fontWeight: DabblerType.bold,
            height: 1.5,
          );

  /// The source's fifth `status` value, `neutral`, resolved against [colors].
  ///
  /// The triple itself — surface `--surface-card`, strong ink `--ink`, base
  /// `--outline-card`, all from `overlay.jsx:161` — lives in
  /// [dabblerNeutralStatus], which carries the full provenance and the reason
  /// `neutral` sits outside the `--color-status-*` API. Badge composes it
  /// rather than re-deriving it (KAN-266): `DabblerToastTone.neutral` wants the
  /// identical triple, and two sites wanting the same three values is a role.
  ///
  /// `statusHairline` (`overlay.jsx:171`) returns that bare `--outline-card`
  /// for `neutral` instead of a 20% mix, which [hairlineFor] reproduces by
  /// recognising this exact value.
  static DabblerStatusColor neutralStatusOf(DabblerColors colors) =>
      dabblerNeutralStatus(colors);

  /// The fill for [tone], resolved against [colors].
  static Color backgroundOf(DabblerBadgeTone tone, DabblerColors colors) =>
      switch (tone) {
        // `--color-brand-primary`. `error` shares this row with `default` in
        // the source, which is why the decorative `error` is purple.
        DabblerBadgeTone.defaultTone ||
        DabblerBadgeTone.error =>
          colors.brandPrimary,
        // `--color-accent`.
        DabblerBadgeTone.primary || DabblerBadgeTone.pill => colors.accent,
        // `--accent-indigo`, approximated — see [decorativeIndigo].
        DabblerBadgeTone.info => decorativeIndigo(colors),
        // `--ink`, whose semantic role in the token layer is
        // `--color-text-primary`.
        DabblerBadgeTone.success => colors.textPrimary,
        // `--faint`, whose semantic role is `--color-bg-tertiary`.
        DabblerBadgeTone.warning ||
        DabblerBadgeTone.withIcon =>
          colors.bgTertiary,
      };

  /// The ink for [tone], resolved against [colors].
  static Color foregroundOf(DabblerBadgeTone tone, DabblerColors colors) =>
      switch (tone) {
        // `--muted`, whose semantic role is `--color-text-secondary`.
        DabblerBadgeTone.warning ||
        DabblerBadgeTone.withIcon =>
          colors.textSecondary,
        // Six of the eight tones name `--surface-card` as the foreground.
        _ => colors.surfaceCard,
      };

  /// **Approximation, pending a token.** `Badge.jsx:24` paints the decorative
  /// `info` tone with `--accent-indigo` (`rgb(92, 80, 230)`), a token declared
  /// only in `tokens/figma/fig-tokens.css:5` and **not** in `tokens/colors.css`,
  /// which is the stated source of the palette layer and is enforced by
  /// `test/tokens/dabbler_palette_test.dart`.
  ///
  /// `DabblerColors.info.base` is what this tone paints today. **Corrected
  /// 2026-09-17 against the rendered specimen:** this comment used to call that
  /// value `#6366F1`, "the nearest indigo the palette actually declares". It is
  /// neither. [DabblerPalette.info500] is **`#3B82F6`** — a blue, not an indigo
  /// — so the gap is wider than it was written to be. Measured side by side,
  /// the specimen paints `rgb(92, 80, 230)` and this paints `rgb(59, 130, 246)`:
  /// visibly bluer, not a near-match. This is the
  /// same hand-off `lib/src/controls/fab.dart` raised on KAN-222 for the FAB's
  /// `indigo` tone: adopting `--accent-indigo` widens the palette's stated
  /// source, which is a `cto`/`cxo` call rather than a developer's, and both
  /// sites should move together when it is made.
  static Color decorativeIndigo(DabblerColors colors) => colors.info.base;

  /// The hairline a semantic badge draws for [status].
  ///
  /// [DabblerStatusColor.strong] at [hairlineOpacity], except for the neutral
  /// status of [neutralStatusOf], which takes the bare `--outline-card`
  /// (`overlay.jsx:171`).
  static Color hairlineFor(DabblerStatusColor status, DabblerColors colors) =>
      status == neutralStatusOf(colors)
          ? colors.borderDefault
          : status.strong.withValues(alpha: hairlineOpacity);

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final DabblerStatusColor? semantic = status;

    final Color background =
        semantic?.surface ?? backgroundOf(tone, colors);
    final Color foreground = semantic?.strong ?? foregroundOf(tone, colors);
    // `Badge.jsx:41` — decorative tones draw no border at all.
    final Color? hairline =
        semantic == null ? null : hairlineFor(semantic, colors);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: DabblerRadius.pillAll,
        border: hairline == null
            ? null
            : Border.all(
                color: hairline,
                width: DabblerSizing.borderDefault,
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              // `color: t.fg` sits on the badge in `Badge.jsx:40`, so the
              // glyph inherits it as `currentColor` — the specimen's `pill`
              // dot is literally `background: currentColor`, and neither
              // icon-bearing badge passes a colour of its own. Without this
              // the glyph fell back to `textPrimary` and read as a foreign
              // ink on the six dark-filled tones.
              IconTheme.merge(
                data: IconThemeData(color: foreground),
                child: icon!,
              ),
              const SizedBox(width: iconGap),
            ],
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              style: textStyleFor(direction).copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
