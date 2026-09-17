import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// Section — a titled group of content.
///
/// Transcribed from `components/layout/Section.jsx`, `Section.d.ts` and
/// `Section.prompt.md`: an optional [title] with an optional trailing [action],
/// an optional [subtitle], then [children] stacked with 12px gaps.
///
/// Named `DabblerSection` and distinct from `DabblerSurfaceSection` — the
/// source's own comment calls this out, because the latter is the theme-section
/// enum, not a layout. This one is layout only: it draws no surface, no border
/// and no rule of its own. The source is explicit that a decorative rule under
/// a heading is *not* a `Divider`'s job precisely because *"`Section` already
/// carries that structure"*.
///
/// ## The geometry, and where each number comes from
///
/// | gap | design source | token |
/// |---|---|---|
/// | title ↔ action | `gap: 12`, `Section.jsx:18` | [DabblerSpacing.stackDefault] (12) |
/// | header ↔ subtitle | `margin-top: var(--stack-tight)`, `:26` | [DabblerSpacing.stackTight] (6) |
/// | header ↔ children | `margin-top: var(--stack-default)`, `:31` | [DabblerSpacing.stackDefault] (12) |
/// | child ↔ child | `gap: var(--stack-default)`, `:30` | [DabblerSpacing.stackDefault] (12) |
///
/// `Section.jsx:18` writes the header gap as the bare number `12` rather than
/// `var(--stack-default)`. It is the same value, and the two neighbouring gaps
/// in the same component are both `--stack-default`, so it is transcribed as
/// the token. Carrying it as a literal would put a number in the Dart that the
/// spacing scale already names.
///
/// The header→children gap appears **only when there is both a header and at
/// least one child** (`hasHeader && items.length ? … : 0`, `:31`). A subtitle
/// alone does not open it.
///
/// Section does **not** apply [DabblerSpacing.sectionGap] or
/// [DabblerSpacing.screenGutter] to itself. Those are the caller's: the gap
/// *between* sections belongs to whatever stacks them, and the screen gutter
/// belongs to the screen. A Section that padded itself could not be placed
/// flush.
///
/// ## Type
///
/// [title] is set in [DabblerType.title3] (20/25) at
/// [DabblerColors.textPrimary]; [subtitle] in [DabblerType.footnote] (13/18) at
/// [DabblerColors.textSecondary].
///
/// **Deviation, settled by `DECISIONS.md` D-013.** `Section.jsx:18-19` sets
/// the title inline as `font-sans` at `fontWeight: 300`, while the same file's
/// own header comment, its `.d.ts` and `Section.prompt.md` all say **title3**.
/// `cxo` ruled [DabblerType.title3] (20/25 at weight 400) correct; the inline
/// style in `Section.jsx` is the defect, and is corrected in the design source
/// separately.
///
/// **The reason is not that 300 is unrenderable — D-013 explicitly withdraws
/// that argument, and it must not be carried forward.** `--weight-light: 300`
/// *is* declared (`tokens/typography.css:55`) and `meral-sans-light.ttf` does
/// ship, so a 300-weight **sans** title is perfectly renderable. (What cannot
/// run Light is the *display* ramp — Gloock and Wingx each ship one weight.)
///
/// It is rejected because it is **unmotivated, unique and inconsistent**: the
/// inline style carries no rationale, and `Dialog.jsx`, `Sheet.jsx` and
/// `EmptyState.jsx` all reach `title3` through the `.t-title-3` class while
/// `Section.jsx` alone hand-rolls it — dropping the family (`--font-display`)
/// and the weight in the transcription, the two properties a hand-copy loses.
/// A declared step with exactly one user is a ramp entry waiting for a reason,
/// and it does not get one here. D-013 does **not** pre-refuse a light sans
/// heading: if one is ever wanted it is an ordinary new ramp step with a
/// stated role.
///
/// ## RTL
///
/// `Section.prompt.md`: *"Header swaps sides under RTL."* The title takes the
/// leading edge and the [action] the trailing edge, which a [Row] does on its
/// own from the ambient [Directionality] — so the swap is structural, not a
/// conditional. Nothing in this widget names `left` or `right`; the subtitle
/// and every child stretch to the section's width and lay their text out from
/// the leading edge in both directions.
class DabblerSection extends StatelessWidget {
  /// A section with an optional header, subtitle and stacked [children].
  const DabblerSection({
    super.key,
    this.title,
    this.subtitle,
    this.action,
    this.children = const <Widget>[],
  });

  /// The section heading. Set in [DabblerType.title3].
  final String? title;

  /// A line under the header. Set in [DabblerType.footnote] at
  /// [DabblerColors.textSecondary].
  final String? subtitle;

  /// Trailing header action — typically a small text button ("See all").
  ///
  /// Lands on the trailing edge in both directions. Present without a [title],
  /// it still sits trailing: the source keeps an empty flexing spacer in the
  /// title's place (`Section.jsx:22`).
  final Widget? action;

  /// The section's content, stacked with [DabblerSpacing.stackDefault] gaps.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    // Section.jsx:9 — `title != null || action != null`.
    final bool hasHeader = title != null || action != null;

    final List<Widget> column = <Widget>[];

    if (hasHeader) {
      final String? title = this.title;
      column.add(
        Row(
          children: <Widget>[
            // `flex: 1` on the title, or on an empty span when there is none,
            // so the action stays on the trailing edge either way.
            Expanded(
              child: title == null
                  ? const SizedBox.shrink()
                  : Text(
                      title,
                      // `fontSize: 20, lineHeight: '25px', fontWeight: 300`
                      // (`Section.jsx:19-20`) — `.t-title-3` at
                      // `--weight-light`, NOT at its own regular default. The
                      // previous cut left the weight alone, which draws the
                      // section heading a full step heavier than the specimen
                      // and is the single most visible thing about a Section.
                      style: DabblerType.title3
                          .resolveForDirection(direction)
                          .copyWith(
                            color: colors.textPrimary,
                            fontWeight: DabblerType.light,
                          ),
                    ),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(width: DabblerSpacing.stackDefault),
              action!,
            ],
          ],
        ),
      );
    }

    if (subtitle != null) {
      if (column.isNotEmpty) {
        column.add(const SizedBox(height: DabblerSpacing.stackTight));
      }
      column.add(
        Text(
          subtitle!,
          style: DabblerType.footnote
              .resolveForDirection(direction)
              .copyWith(color: colors.textSecondary),
        ),
      );
    }

    if (children.isNotEmpty) {
      if (hasHeader) {
        column.add(const SizedBox(height: DabblerSpacing.stackDefault));
      }
      for (int i = 0; i < children.length; i++) {
        if (i > 0) {
          column.add(const SizedBox(height: DabblerSpacing.stackDefault));
        }
        column.add(children[i]);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      // `display: flex; flex-direction: column` with the CSS default
      // `align-items: stretch` — children take the section's full width.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: column,
    );
  }
}
