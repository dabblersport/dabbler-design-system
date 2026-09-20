import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'card.dart';

/// The two shapes an empty state takes.
///
/// Transcribed from `components/cards/EmptyState.prompt.md` → *Variants*.
enum DabblerEmptyStateSize {
  /// The bordered card that sits inside a section — `--surface-card`, 1px
  /// `--outline-card`, `--radius-lg`, 30/12 padding, 45×45 icon well. The
  /// source's default.
  inline,

  /// The same content centred in the viewport with 36px of vertical padding,
  /// no frame, `min-height: 60dvh`, title at `.t-title-3` and copy capped at
  /// 320px. For a whole empty screen.
  page,
}

/// EmptyState — the "nothing here yet" state for a section, a list, or a whole
/// screen.
///
/// Transcribed from `components/cards/EmptyState.jsx`, `EmptyState.d.ts` and
/// `EmptyState.prompt.md`, and checked against the specimen at
/// `components/cards/cards.card.html:100`.
///
/// ```dart
/// DabblerEmptyState(
///   icon: 'game',
///   title: 'no games near you',
///   text: 'widen the distance filter or create your own.',
/// )
/// ```
///
/// From `EmptyState.prompt.md` → *Composition rules*: *"This is the **only**
/// empty state… Do not build a screen-specific empty state."* and *"One action
/// at most. Two actions means the screen is really a decision."* — hence the
/// single [action].
///
/// ## When NOT to use it — the third outcome, `D-040`
///
/// An empty region has **three** outcomes, and this component covers two of
/// them. The third is to draw nothing at all.
///
/// | The empty region is… | Outcome |
/// |---|---|
/// | the answer to what the user came for | [DabblerEmptyStateSize.page] |
/// | a subordinate section holding the **only** way to create the first item | [DabblerEmptyStateSize.inline] |
/// | a subordinate section offering no affordance the user cannot reach elsewhere | **omitted entirely, heading and all** |
///
/// The one-line test: **is this empty region the answer to what the user came
/// for?** If it is not, and it offers nothing the user cannot get to another
/// way, the section does not appear — an empty card that only says "nothing
/// here" is chrome charging rent on a screen.
///
/// **Two bounds, or this reads as licence to hide things.**
///
/// 1. **Never omit where absence is ambiguous with failure.** "No results" and
///    "the request did not load" must not look alike. A region that might be
///    empty *because something broke* belongs to the *Telling the user
///    something happened* pattern, not to this one.
/// 2. **Never omit the only path to the first item.** If the section holds the
///    sole affordance for creating the thing, omitting it strands the user
///    with no way in. That case is exactly what
///    [DabblerEmptyStateSize.inline] exists for.
///
/// This section is here because a component documenting two sizes and no
/// "when not to use" will keep reproducing the question it just answered.
///
/// ## AC1: there is no illustration, and that is the feature
///
/// KAN-242's only acceptance criterion is a **constraint**: *"No elaborate hero
/// illustration (cpo §5.2 "What the App Avoids") — composes DS-300's Icon
/// inside DS-800/DS-500 only."*
///
/// The design source has an `illustration` prop. `EmptyState.jsx:34` swaps the
/// icon well for artwork from `assets/illustrations/*` (`court.svg`,
/// `crowd.svg`, `racket.svg`, `whistle.svg`) at 120px inline and 180px on a
/// page. **It is not ported, and no equivalent is offered** — not as a
/// `Widget? illustration`, not as an asset hook, not as a slot a caller could
/// fill. An escape hatch would make the ticket's constraint advisory, and the
/// first screen to use it would be the elaborate hero the criterion forbids.
///
/// What remains is the icon well: [DabblerIcon] (DS-300) inside the
/// [DabblerCard] shell (DS-800). That is the whole of the visual vocabulary
/// here, deliberately.
///
/// ## Which shell each size composes
///
/// [DabblerEmptyStateSize.inline] is a [DabblerCard] on
/// [DabblerCardVariant.white] — the source's `--surface-card` fill with a 1px
/// `--outline-card` hairline, which is that variant precisely, and DS-800's own
/// doc names `EmptyState (size: 'inline')` as the shell's user.
///
/// [DabblerEmptyStateSize.page] composes **no card**, because the source gives
/// it none: `background: transparent`, `border: none`, `borderRadius: 0`. A
/// [DabblerCard] rendered invisible would be chrome pretending not to be
/// chrome. The content is identical; only the frame differs.
///
/// ## The radius, for once, needs no correction
///
/// `--radius-lg` is written as a token here rather than as a Figma literal, so
/// [DabblerCard.defaultRadius] is already the right answer and nothing is
/// overridden.
class DabblerEmptyState extends StatelessWidget {
  /// An empty state.
  const DabblerEmptyState({
    super.key,
    this.icon,
    this.iconWidget,
    this.title,
    this.text,
    this.size = DabblerEmptyStateSize.inline,
    this.action,
  });

  /// The kebab-case Iconsax name shown in the 45×45 well — see
  /// [DabblerIconRegistry] for the vocabulary. Null, with [iconWidget] also
  /// null, drops the well.
  final String? icon;

  /// A pre-built mark for the well, for the rare caller that has one. Wins over
  /// [icon].
  ///
  /// This is **not** the illustration hatch: it is rendered inside the same
  /// 45×45 well, clipped to it, and tinted by the well's [IconTheme]. See the
  /// class doc's AC1 note.
  final Widget? iconWidget;

  /// The heading — *"no games near you"*. `EmptyState.prompt.md` →
  /// *Accessibility*: *"make the title a statement of fact… rather than an
  /// error."*
  final String? title;

  /// The body copy — *"widen the distance filter or create your own."*
  final String? text;

  /// Which shape to draw. Defaults to [DabblerEmptyStateSize.inline], the
  /// source's default.
  final DabblerEmptyStateSize size;

  /// The single optional action, usually a button. At most one — see the class
  /// doc.
  final Widget? action;

  /// The icon well's side — `width: 45, height: 45`.
  ///
  /// This is [DabblerSizing.touchTargetMin] by value, which is a coincidence
  /// worth stating rather than relying on: the well is decorative and takes no
  /// input, so it is written as its own constant and would not follow a change
  /// to the touch-target token.
  static const double wellSide = 45;

  /// The well's radius — `--radius-md` ([DabblerRadius.md], 9). A token in the
  /// source, so no deviation.
  static const double wellRadius = DabblerRadius.md;

  /// The vertical gap between well, title, copy and action — `gap: 12`
  /// ([DabblerSpacing.stackDefault]) at both sizes.
  static const double gap = DabblerSpacing.stackDefault;

  /// The extra space above [action] — `marginBlockStart: var(--space-2)` (6).
  static const double actionGap = DabblerSpacing.stackTight;

  /// `size: 'inline'` padding — `'30px 12px'`, i.e.
  /// [DabblerSpacing.space9] and [DabblerSpacing.space4].
  static const EdgeInsetsDirectional inlinePadding =
      EdgeInsetsDirectional.symmetric(
    vertical: DabblerSpacing.space9,
    horizontal: DabblerSpacing.space4,
  );

  /// `size: 'page'` padding — `var(--space-10) var(--space-6)`, i.e. 36 and 18.
  static const EdgeInsetsDirectional pagePadding =
      EdgeInsetsDirectional.symmetric(
    vertical: DabblerSpacing.space10,
    horizontal: DabblerSpacing.space6,
  );

  /// `min-height: 60dvh` on the page size, as a fraction of the viewport.
  static const double pageMinHeightFraction = 0.60;

  /// `max-width: 320` on the page size's copy.
  ///
  /// **Off the base-3 grid, and transcribed anyway** — it is a measure, not a
  /// spacing step, and there is no token for one.
  static const double pageTextMaxWidth = 320;

  /// The title's style at [size].
  ///
  /// * `page` — `.t-title-3`, which the source names by class (`t-title-3`).
  /// * `inline` — `fontSize: 16, lineHeight: '21px', fontWeight: 600`, which is
  ///   `.t-body`'s metrics exactly at Semibold where the step carries 400. The
  ///   source's weight is applied on top of the step rather than a step being
  ///   invented — the precedent `lib/src/surfaces/badge.dart` set.
  static TextStyle titleStyleFor(
    DabblerEmptyStateSize size,
    TextDirection direction,
  ) =>
      switch (size) {
        DabblerEmptyStateSize.page =>
          DabblerType.title3.resolveForDirection(direction),
        DabblerEmptyStateSize.inline => DabblerType.body
            .resolveForDirection(direction)
            .copyWith(fontWeight: DabblerType.semibold),
      };

  /// The copy's style — `fontSize: 14, lineHeight: '19px'` at both sizes.
  ///
  /// **The ramp has no 14.** `.t-footnote` (13/18) is the nearest step and the
  /// one the system already uses for muted supporting copy.
  static TextStyle textStyleFor(TextDirection direction) =>
      DabblerType.footnote.resolveForDirection(direction);

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final Widget content = _content(colors, direction);

    return switch (size) {
      DabblerEmptyStateSize.inline => DabblerCard(
          variant: DabblerCardVariant.white,
          padding: inlinePadding,
          child: content,
        ),
      DabblerEmptyStateSize.page => ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.sizeOf(context).height * pageMinHeightFraction,
          ),
          child: Padding(
            padding: pagePadding,
            child: Center(child: content),
          ),
        ),
    };
  }

  /// Well, title, copy and action — identical at both sizes bar the title step
  /// and the copy's measure.
  Widget _content(DabblerColors colors, TextDirection direction) {
    final bool page = size == DabblerEmptyStateSize.page;
    final List<Widget> children = <Widget>[];

    void add(Widget child, {double space = gap}) {
      if (children.isNotEmpty) children.add(SizedBox(height: space));
      children.add(child);
    }

    if (icon != null || iconWidget != null) add(_well(colors));

    if (title != null) {
      add(Text(
        title!,
        textAlign: TextAlign.center,
        style: titleStyleFor(size, direction)
            .copyWith(color: colors.textPrimary),
      ));
    }

    if (text != null) {
      final Widget copy = Text(
        text!,
        textAlign: TextAlign.center,
        style: textStyleFor(direction).copyWith(color: colors.textSecondary),
      );
      add(page
          ? ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: pageTextMaxWidth),
              child: copy,
            )
          : copy);
    }

    if (action != null) add(action!, space: gap + actionGap);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  /// The 45×45 icon well: `--surface-page` fill, 1px `--faint` hairline,
  /// `--subtle` ink.
  ///
  /// Those three aliases resolve through `tokens/colors.css:112-121` to
  /// [DabblerColors.bgPrimary], [DabblerColors.bgTertiary] and
  /// [DabblerColors.textTertiary] respectively, which is why no literal
  /// appears here.
  Widget _well(DabblerColors colors) {
    return Container(
      width: wellSide,
      height: wellSide,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.bgPrimary,
        borderRadius: const BorderRadius.all(Radius.circular(wellRadius)),
        border: Border.all(
          color: colors.bgTertiary,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: colors.textTertiary),
        child: iconWidget ??
            DabblerIcon(
              icon!,
              size: DabblerSizing.iconMd,
              color: colors.textTertiary,
            ),
      ),
    );
  }
}
