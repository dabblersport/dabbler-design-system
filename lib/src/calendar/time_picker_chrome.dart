/// Part of the `time_picker.dart` library — the card, header, meridiem pill and footer shared by [DabblerTimePicker] and [DabblerTimeRuler].
///
/// **Why `part`, not a separate library.** Both pickers draw the same card
/// shell, header, AM/PM pill and Confirm / Cancel footer (live
/// `TimePicker.jsx:94-123`), and differ only in how the hour and minute are
/// reached. One private widget draws the shared frame so the two cannot drift
/// apart. `part`/`part of` keeps one logical library, so the private name stays
/// private and no public API is added. The imports are the library's.
part of 'time_picker.dart';

/// The shared frame: card, header, [body], footer.
///
/// [headerFontSize] null keeps the `headline` ramp step (the listbox picker);
/// a value sets that exact size, less 0.9 under RTL (the ruler's `20`).
class _TimePickerChrome extends StatelessWidget {
  const _TimePickerChrome({
    required this.value,
    required this.body,
    required this.gap,
    required this.headerGap,
    required this.commit,
    required this.valueKey,
    required this.amKey,
    required this.pmKey,
    required this.confirmKey,
    required this.cancelKey,
    required this.periodLabel,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.showActions,
    required this.onConfirm,
    required this.onCancel,
    this.headerFontSize,
  });

  final TimeOfDay value;
  final List<Widget> body;
  final double gap;
  final double headerGap;
  final ValueChanged<TimeOfDay> commit;
  final Key valueKey;
  final Key amKey;
  final Key pmKey;
  final Key confirmKey;
  final Key cancelKey;
  final String periodLabel;
  final String confirmLabel;
  final String cancelLabel;
  final bool showActions;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final double? headerFontSize;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        // `background: var(--surface-card)`, `border-radius: 18`
        // (`TimePicker.jsx:94`). Flat.
        color: colors.surfaceCard,
        borderRadius: const BorderRadius.all(
          Radius.circular(DabblerTimePicker.cardRadius),
        ),
      ),
      child: Padding(
        // `padding: 15` (`TimePicker.jsx:94`) — `--space-5`.
        padding: const EdgeInsets.all(DabblerSpacing.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: <Widget>[
            _header(colors, direction),
            ...body,
            if (showActions) _actions(),
          ],
        ),
      ),
    );
  }

  /// `TimePicker.jsx:95-108` — the formatted value and the AM/PM pill,
  /// centred.
  Widget _header(DabblerColors colors, TextDirection direction) {
    final bool rtl = direction == TextDirection.rtl;
    TextStyle style = DabblerType.headline
        .resolveForDirection(direction)
        .copyWith(color: colors.textPrimary, fontWeight: DabblerType.bold);
    if (headerFontSize != null) {
      // `fontSize: 20, fontWeight: 700`, sans (`TimePicker.jsx:96`); Arabic
      // size is Latin less 0.9.
      style = style.copyWith(fontSize: headerFontSize! - (rtl ? 0.9 : 0));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: headerGap,
      children: <Widget>[
        Text(
          DabblerTimeFormat.format(value),
          key: valueKey,
          // `H:MM AM` is the product's own format in both scripts; under an
          // RTL paragraph the bidi algorithm would draw `PM 6:35`.
          textDirection: TextDirection.ltr,
          // The sans ramp's nearest step to `fontSize: 20` is `.t-headline`
          // (17, sans); `.t-title-3` is a *display*-role style, and the source
          // asks for `font-family: var(--font-sans)` (`TimePicker.jsx:96`).
          style: style,
        ),
        _periodPill(colors, direction),
      ],
    );
  }

  /// The two-segment meridiem control — `TimePicker.jsx:99-107`.
  Widget _periodPill(DabblerColors colors, TextDirection direction) {
    return Semantics(
      container: true,
      label: periodLabel,
      child: ClipRRect(
        // `border-radius: 999; overflow: hidden` (`TimePicker.jsx:99`).
        borderRadius: DabblerRadius.pillAll,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: DabblerRadius.pillAll,
            border: Border.all(
              color: colors.borderDefault,
              width: DabblerSizing.borderDefault,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _segment(
                key: amKey,
                colors: colors,
                direction: direction,
                label: DabblerTimeFormat.amLabel,
                on: value.period == DayPeriod.am,
                period: DayPeriod.am,
              ),
              _segment(
                key: pmKey,
                colors: colors,
                direction: direction,
                label: DabblerTimeFormat.pmLabel,
                on: value.period == DayPeriod.pm,
                period: DayPeriod.pm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segment({
    required Key key,
    required DabblerColors colors,
    required TextDirection direction,
    required String label,
    required bool on,
    required DayPeriod period,
  }) {
    return Semantics(
      key: key,
      button: true,
      selected: on,
      child: DabblerFocusRing(
        borderRadius: DabblerRadius.pillAll,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => commit(DabblerTimeValues.withPeriod(value, period)),
          child: DabblerPressScale.gesture(
            child: Container(
              // `padding: '4px 10px'` (`TimePicker.jsx:102`) inside a 45px
              // target (the live pill paints about 24 tall).
              constraints: const BoxConstraints(
                minHeight: DabblerSizing.touchTargetMin,
                minWidth: DabblerSizing.touchTargetMin,
              ),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
              alignment: Alignment.center,
              color: on ? colors.brandPrimary : null,
              child: Text(
                label,
                // `fontSize: 12, fontWeight: 700`; inactive `--muted`
                // (`TimePicker.jsx:102-104`) — `textSecondary` under D-003(a).
                style: DabblerType.caption1
                    .resolveForDirection(direction)
                    .copyWith(
                      color: on ? colors.onBrand : colors.textSecondary,
                      fontWeight: DabblerType.bold,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Confirm / Cancel — `TimePicker.jsx:111-123`, centred.
  Widget _actions() {
    // A [Wrap] for the reason [DabblerCalendar]'s footer is one.
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: DabblerSpacing.space3,
      runSpacing: DabblerSpacing.space3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        DabblerButton(
          key: confirmKey,
          label: confirmLabel,
          onPressed: onConfirm,
          disabled: onConfirm == null,
        ),
        DabblerButton(
          key: cancelKey,
          label: cancelLabel,
          tone: DabblerButtonTone.text,
          onPressed: onCancel,
          disabled: onCancel == null,
        ),
      ],
    );
  }
}
