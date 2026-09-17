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
/// **Deviation, recorded.** `Section.jsx:20-21` sets the title inline as
/// `font-sans` at `fontWeight: 300`, while the same file's own docstring, its
/// `.d.ts` and `Section.prompt.md` all say **title3**. `title3` is a *display*
/// role style at weight 400 — Gloock and Wingx each ship one weight, so a 300
/// title is not a face the system has. The three prose sources agree against
/// one inline style, and only one of the four describes a renderable face, so
/// the prose wins and this uses [DabblerType.title3]. Flagged to `cxo` rather
/// than settled here.
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
                      style: DabblerType.title3
                          .resolveForDirection(direction)
                          .copyWith(color: colors.textPrimary),
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
