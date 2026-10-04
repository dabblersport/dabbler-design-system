part of 'input_row.dart';

/// The sheet option row — the Language and Region lists
/// (`Auth and Onboarding.dc.html:557-569`): a [DabblerType.bodyRelaxed] title
/// (400, semibold while selected) with the bold `tick-circle` at the end, in a
/// row whose content box is [DabblerInputRow.optionMinHeight] (52) with `9 3`
/// padding and the `--faint` hairline under it, so it is 71 tall.
class _DabblerOptionRow extends DabblerInputRow {
  const _DabblerOptionRow({
    super.key,
    required String super.title,
    required bool super.selected,
    super.onTap,
    this.textDirection,
    super.semanticLabel,
    super.showDivider,
  });

  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool on = selected ?? false;

    final Widget row = DecoratedBox(
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
      // The hairline sits outside the 52 content box and its padding, as the
      // frame's `border-bottom` does, so it adds its own pixel.
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          bottom: showDivider ? DabblerSizing.borderDefault : 0,
        ),
        child: Padding(
          padding: DabblerInputRow.optionPadding,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: DabblerInputRow.optionMinHeight,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title!,
                    textDirection: textDirection,
                    textAlign: TextAlign.start,
                    style: DabblerType.bodyRelaxed
                        .resolveForDirection(textDirection ?? direction)
                        .copyWith(
                          color: colors.textPrimary,
                          fontWeight: on
                              ? DabblerType.semibold
                              : DabblerType.regular,
                        ),
                  ),
                ),
                if (on) ...<Widget>[
                  const SizedBox(width: DabblerInputRow.slotGap),
                  DabblerIcon(
                    DabblerInputRow.selectedIconName,
                    weight: DabblerIconWeight.bold,
                    size: DabblerInputRow.optionTickSize,
                    color: colors.brandPrimary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (onTap == null) {
      return Semantics(container: true, selected: on, child: row);
    }
    return Semantics(
      container: true,
      button: true,
      selected: on,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DabblerFocusRing(
          enabled: true,
          canRequestFocus: true,
          borderRadius: BorderRadius.zero,
          child: row,
        ),
      ),
    );
  }
}
