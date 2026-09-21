import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// Which way a [DabblerDivider] runs.
///
/// Transcribed from `components/layout/Divider.d.ts` — `orientation?:
/// 'horizontal' | 'vertical'`, default `horizontal`.
enum DabblerDividerOrientation {
  /// A rule across the container. Fills the available width.
  horizontal,

  /// A rule down the container. Stretches to the parent's cross size, with a
  /// 24px minimum so it still reads inside a flex meta row.
  vertical,
}

/// Divider — the only line the system draws between things.
///
/// Transcribed from `components/layout/Divider.jsx`, `Divider.d.ts` and
/// `Divider.prompt.md`. The source is blunt about the mandate: this replaces
/// *"every hand-rolled `border-top`, `<hr>`, and 1px spacer div in the
/// product"*.
///
/// ## The two weights are two different jobs
///
/// The source names the weights by what they separate, not by how dark they
/// are:
///
/// | | design token | Dabbler role | separates |
/// |---|---|---|---|
/// | default | `--faint` | [DabblerColors.bgTertiary] | things **inside** one container |
/// | [strong] | `--outline-card` | [DabblerColors.borderDefault] | one container **from** another |
///
/// The mapping is taken from `tokens/colors.css`, which declares
/// `--faint:#E8E0CF` and then `--t-bg-3:var(--faint)` →
/// `--color-bg-tertiary`, and `--outline-card:#E0D9CC` then
/// `--t-border:var(--outline-card)` → `--color-border-default`. So the
/// *default* divider is the faint paper step and the *strong* one is the card
/// outline. Both step with the paper ramp, which is why a divider stays a paper
/// step in light and a lifted hairline in dark, in all seven themes.
///
/// The line is **always exactly 1px** ([DabblerSizing.borderDefault]) in both
/// orientations — the source hard-codes `height: 1` / `width: 1` and offers no
/// weight prop. [DabblerSizing.borderHairline] is deliberately *not* used: a
/// divider is a drawn line, not a border stroke.
///
/// ## Inset
///
/// [inset] is the distance the rule is pulled in from the container edges —
/// inline for [DabblerDividerOrientation.horizontal], block for
/// [DabblerDividerOrientation.vertical]. The source applies it through
/// `margin-inline` / `margin-block`, the logical properties, so it mirrors
/// under RTL for free; the Dart transcription uses [EdgeInsetsDirectional] for
/// the same reason. Inside a card, pass the card's own padding
/// ([DabblerSpacing.cardPadding]) so the line starts at the content column
/// rather than at the border.
///
/// [inset] is the one measurement a caller supplies, so it is a plain `double`
/// rather than a token: the token is what the caller passes *in*.
///
/// ## Accessibility
///
/// The source renders `role="separator"` with `aria-orientation`. Flutter has
/// no separator role, so the transcription carries the *intent* instead: a
/// plain rule is decorative and is wrapped in [ExcludeSemantics], while the
/// labelled variant keeps its label in the tree — the source's own reasoning is
/// that *"'or' carries meaning"*.
///
/// ## When not to use one
///
/// Between cards in a feed (spacing already separates them), under a heading
/// ([DabblerSection] already carries that structure), directly above a Sheet
/// footer or Dialog action row (both carry their own separation), and never to
/// fake elevation — the system is flat.
class DabblerDivider extends StatelessWidget {
  /// A rule across the container.
  const DabblerDivider({
    super.key,
    this.inset = 0,
    this.label,
    this.strong = false,
  }) : orientation = DabblerDividerOrientation.horizontal;

  /// A rule down the container. The source declares `label` horizontal-only, so
  /// this constructor does not take one.
  const DabblerDivider.vertical({
    super.key,
    this.inset = 0,
    this.strong = false,
  })  : orientation = DabblerDividerOrientation.vertical,
        label = null;

  /// Which way the rule runs.
  final DabblerDividerOrientation orientation;

  /// Distance pulled in from the container edges, in logical pixels. Inline for
  /// a horizontal rule, block for a vertical one. Mirrors under RTL.
  final double inset;

  /// Centres a caption between two rules. Horizontal only.
  ///
  /// Set in [DabblerType.caption1] at [DabblerColors.textSecondary], and kept in
  /// the accessibility tree.
  final String? label;

  /// Draw the card outline ([DabblerColors.borderDefault]) instead of the faint
  /// paper step ([DabblerColors.bgTertiary]).
  ///
  /// Use it for a line that separates two containers; leave it off for a line
  /// inside one.
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    // Divider.jsx:20 — `strong ? var(--outline-card) : var(--faint)`.
    final Color color = strong ? colors.borderDefault : colors.bgTertiary;

    switch (orientation) {
      case DabblerDividerOrientation.vertical:
        // Divider.jsx:24-25 — width 1, `align-self: stretch`, `min-height:
        // var(--space-8)`, `margin-block: inset`, `flex-shrink: 0`.
        return ExcludeSemantics(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: inset),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: DabblerSpacing.space8,
              ),
              // `align-self: stretch`: no height is imposed, so a tight
              // height from the parent (a [Row] at
              // [CrossAxisAlignment.stretch], or an [IntrinsicHeight]) fills
              // the rule, and a loose one drops it to the 24px floor. Forcing
              // `double.infinity` here would instead swallow the whole
              // viewport whenever the parent's constraints are loose.
              child: SizedBox(
                width: DabblerSizing.borderDefault,
                child: ColoredBox(color: color),
              ),
            ),
          ),
        );

      case DabblerDividerOrientation.horizontal:
        final String? label = this.label;
        if (label != null) {
          // Divider.jsx:29-40 — a flex row, `gap: var(--space-4)`, a caption
          // between two flexing rules.
          return Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: inset),
            child: Row(
              children: <Widget>[
                Expanded(child: _rule(color)),
                const SizedBox(width: DabblerSpacing.space4),
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: DabblerType.caption1
                      .resolveForDirection(Directionality.of(context))
                      // The source paints this `--color-text-tertiary`
                      // (`Divider.jsx:36`). D-003(a) permits `--muted` only at
                      // large-text sizes (≥24px, or ≥18.66px bold), and
                      // caption1 is 12px — body-sized — so the label takes the
                      // ink-soft-backed secondary role instead.
                      .copyWith(color: colors.textSecondary),
                ),
                const SizedBox(width: DabblerSpacing.space4),
                Expanded(child: _rule(color)),
              ],
            ),
          );
        }
        // Divider.jsx:39-40 — height 1, full width, `margin-inline: inset`.
        return ExcludeSemantics(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: inset),
            child: _rule(color),
          ),
        );
    }
  }

  /// One 1px rule in [color], filling the width it is given.
  Widget _rule(Color color) => SizedBox(
        height: DabblerSizing.borderDefault,
        width: double.infinity,
        child: ColoredBox(color: color),
      );
}
