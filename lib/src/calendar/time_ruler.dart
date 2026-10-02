/// Part of the `time_picker.dart` library — [DabblerTimeRuler], the opt-in drag-ruler time picker.
///
/// **Why `part`, not a separate library.** It shares the private card/header/
/// footer frame ([_TimePickerChrome]) with [DabblerTimePicker]. `part`/`part of`
/// keeps one logical library and keeps each file under the 500-line house rule.
/// The imports are the library's.
part of 'time_picker.dart';

/// TimeRuler — an OPT-IN horizontal drag-ruler time picker.
///
/// **Not the D-030 component.** [DabblerTimePicker] (the selectable listbox) is
/// the D-030 default and never builds this widget. No drawn source for a
/// scroll-wheel/ruler picker exists; this implements the live `TimePicker.jsx`
/// Ruler geometry (live Claude Design project
/// 4286affa-bf50-4ff6-9576-917f76a93ca1, `components/calendar/TimePicker.jsx`,
/// read via DesignSync get_file on 2026-10-02 and transcribed to a local
/// mirror by the coordinator) as an opt-in. Fidelity unverified, no pixel
/// comparison.
///
/// ```dart
/// DabblerTimeRuler(
///   value: kickOff,
///   onChanged: (TimeOfDay next) => setState(() => kickOff = next),
/// )
/// ```
///
/// ## Source to Dart
///
/// | Live (`TimePicker.jsx`) | Dart |
/// |---|---|
/// | card radius 18, padding 15, gap 10 (`:94`) | [DabblerTimePicker.cardRadius], [DabblerSpacing.space5], [cardGap] |
/// | header `20 / 700` sans, gap 10 (`:95-96`) | [headerFontSize], [headerGap] |
/// | `Ruler` height 64, pitch 46 (`:39`, `:3`) | [rulerHeight], [rulerPitch] |
/// | tick strip bottom 6, height 14, `1.5px` ticks every `pitch / 4` (`:41-44`) | [tickBottom], [tickHeight], [tickWidth] |
/// | numerals 24 selected / 18 other, opacity `max(.2, 1 - dist * .3)` (`:50`, `:57`) | [selectedFontSize], [otherFontSize], [minOpacity], [opacityStep] |
/// | centre window: top/bottom 4, width `pitch + 14`, radius 12, `2px` brand, shadow `0 2px 8px rgba(0,0,0,.05)` (`:65-67`) | [windowInset], [windowExtra], [windowRadius], [windowBorder], [windowShadowAlpha] |
/// | pin: bottom 8, `2 x 16`, radius 1 (`:70-71`) | [pinBottom], [pinWidth], [pinHeight] |
/// | track glide `200ms cubic-bezier(.2,.8,.2,1)` (`:16`, `:43`) | [glide], [glideCurve] |
/// | drag end: `shift = round(-dx / pitch)`, wraps modulo n (`:26-27`) | same |
/// | hours `1..12`, minutes `i * 5` (`:77-78`), default `7 AM` (`:86`) | [DabblerTimeValues] |
///
/// ## Additions beyond the source (accessibility)
///
/// The source ruler is pointer-only. Added here: Left/Down and Right/Up step to
/// the previous/next enabled value, Home/End jump to the first/last; each ruler
/// is an adjustable semantics node with increase/decrease actions; a tap picks
/// the numeral under the finger. Values outside [minimum]/[maximum] are never
/// committed. These do not make it the D-030 component: D-030 asks for a drawn
/// source and a stated keyboard contract, and neither exists.
///
/// ## The pin runs into the numerals — and so does live
///
/// Live `:70` puts the 2x16 pin at `bottom: 8` of the 64px box (y 40-56) while
/// numerals are centred at y 32, so the pin overlaps the lower edge of the
/// centred numeral. The port keeps that geometry.
///
/// ## Remaining documented deviations
///
/// * The meridiem segments keep a [DabblerSizing.touchTargetMin] minimum
///   height; the live `4px 10px` pill paints about 24 tall.
/// * Confirm / Cancel are [DabblerButton]s (D-023), not the live 40px spans.
/// * The ruler is drawn in a left-to-right frame in both directions: it is a
///   scale. Numerals use the Arabic size (Latin less 0.9px) under RTL.
class DabblerTimeRuler extends StatefulWidget {
  /// Creates a drag-ruler time picker.
  const DabblerTimeRuler({
    super.key,
    this.value,
    this.onChanged,
    this.minuteStep = DabblerTimeValues.defaultMinuteStep,
    this.minimum,
    this.maximum,
    this.showActions = true,
    this.onConfirm,
    this.onCancel,
    this.confirmLabel = DabblerCalendar.defaultConfirmLabel,
    this.cancelLabel = DabblerCalendar.defaultCancelLabel,
    this.hourColumnLabel = DabblerTimePicker.defaultHourColumnLabel,
    this.minuteColumnLabel = DabblerTimePicker.defaultMinuteColumnLabel,
    this.periodLabel = DabblerTimePicker.defaultPeriodLabel,
  }) : assert(minuteStep > 0 && minuteStep <= 60, 'minuteStep must be 1..60');

  /// `gap: 10` between the card's rows (`TimePicker.jsx:94`).
  static const double cardGap = 10;

  /// `gap: 10` between the value and the meridiem pill (`:95`).
  static const double headerGap = 10;

  /// `fontSize: 20` of the header value (`:96`).
  static const double headerFontSize = 20;

  /// `height: 64` of a ruler (`:39`).
  static const double rulerHeight = 64;

  /// `pitch = 46` — the width of one numeral cell (`:3`).
  static const double rulerPitch = 46;

  /// Tick strip `bottom: 6` (`:41`).
  static const double tickBottom = 6;

  /// Tick strip `height: 14` (`:41`).
  static const double tickHeight = 14;

  /// Tick width `1.5px` (`:44`).
  static const double tickWidth = 1.5;

  /// Numeral size when centred (`:57`).
  static const double selectedFontSize = 24;

  /// Numeral size when not centred (`:57`).
  static const double otherFontSize = 18;

  /// Opacity floor of a non-centre numeral (`:50`).
  static const double minOpacity = 0.2;

  /// Opacity lost per cell of distance (`:50`).
  static const double opacityStep = 0.3;

  /// Window `top: 4; bottom: 4` (`:65`).
  static const double windowInset = 4;

  /// Window width is `pitch + 14` (`:65`).
  static const double windowExtra = 14;

  /// Window `borderRadius: 12` (`:66`).
  static const double windowRadius = 12;

  /// Window `border: 2px solid brand` (`:66`).
  static const double windowBorder = 2;

  /// Window shadow alpha, `rgba(0,0,0,0.05)` (`:67`).
  static const double windowShadowAlpha = 0.05;

  /// Pin `bottom: 8` (`:70`).
  static const double pinBottom = 8;

  /// Pin `width: 2` (`:70`).
  static const double pinWidth = 2;

  /// Pin `height: 16` (`:70`).
  static const double pinHeight = 16;

  /// Track transition `200ms` (`:16`, `:43`).
  static const Duration glide = Duration(milliseconds: 200);

  /// Track transition `cubic-bezier(.2,.8,.2,1)` (`:16`, `:43`).
  static const Cubic glideCurve = Cubic(0.2, 0.8, 0.2, 1);

  /// The key of the hour ruler.
  static const Key hourColumnKey = ValueKey<String>('DabblerTimeRuler.hours');

  /// The key of the minute ruler.
  static const Key minuteColumnKey = ValueKey<String>(
    'DabblerTimeRuler.minutes',
  );

  /// The key of the header's formatted value.
  static const Key valueKey = ValueKey<String>('DabblerTimeRuler.value');

  /// The key of the AM segment.
  static const Key amKey = ValueKey<String>('DabblerTimeRuler.am');

  /// The key of the PM segment.
  static const Key pmKey = ValueKey<String>('DabblerTimeRuler.pm');

  /// The key of the confirm action.
  static const Key confirmKey = ValueKey<String>('DabblerTimeRuler.confirm');

  /// The key of the cancel action.
  static const Key cancelKey = ValueKey<String>('DabblerTimeRuler.cancel');

  /// The key of the track inside the ruler keyed [columnKey].
  static Key trackKey(Key columnKey) =>
      ValueKey<String>('${(columnKey as ValueKey<String>).value}.track');

  /// The key of the numeral cell at absolute index [absIdx] of [columnKey].
  static Key cellKey(Key columnKey, int absIdx) =>
      ValueKey<String>('${(columnKey as ValueKey<String>).value}.cell.$absIdx');

  /// The chosen time. Null shows [DabblerTimeValues.defaultValue].
  final TimeOfDay? value;

  /// Called on every change — hour, minute or meridiem.
  final ValueChanged<TimeOfDay>? onChanged;

  /// The minute ruler's step. 5 in the source.
  final int minuteStep;

  /// The earliest selectable time, inclusive.
  final TimeOfDay? minimum;

  /// The latest selectable time, inclusive.
  final TimeOfDay? maximum;

  /// Whether to draw the Confirm / Cancel row.
  final bool showActions;

  /// Fired by Confirm.
  final VoidCallback? onConfirm;

  /// Fired by Cancel.
  final VoidCallback? onCancel;

  /// The Confirm label.
  final String confirmLabel;

  /// The Cancel label.
  final String cancelLabel;

  /// The hour ruler's accessible name.
  final String hourColumnLabel;

  /// The minute ruler's accessible name.
  final String minuteColumnLabel;

  /// The meridiem control's accessible name.
  final String periodLabel;

  /// The value in force: [value], or [DabblerTimeValues.defaultValue].
  TimeOfDay get effectiveValue => value ?? DabblerTimeValues.defaultValue;

  /// Whether [candidate] is inside [minimum] / [maximum].
  bool isAllowed(TimeOfDay candidate) =>
      DabblerTimeFormat.inBounds(candidate, min: minimum, max: maximum);

  @override
  State<DabblerTimeRuler> createState() => _DabblerTimeRulerState();
}

class _DabblerTimeRulerState extends State<DabblerTimeRuler> {
  @override
  Widget build(BuildContext context) {
    final TimeOfDay value = widget.effectiveValue;
    return _TimePickerChrome(
      value: value,
      gap: DabblerTimeRuler.cardGap,
      headerGap: DabblerTimeRuler.headerGap,
      headerFontSize: DabblerTimeRuler.headerFontSize,
      commit: _commit,
      valueKey: DabblerTimeRuler.valueKey,
      amKey: DabblerTimeRuler.amKey,
      pmKey: DabblerTimeRuler.pmKey,
      confirmKey: DabblerTimeRuler.confirmKey,
      cancelKey: DabblerTimeRuler.cancelKey,
      periodLabel: widget.periodLabel,
      confirmLabel: widget.confirmLabel,
      cancelLabel: widget.cancelLabel,
      showActions: widget.showActions,
      onConfirm: widget.onConfirm,
      onCancel: widget.onCancel,
      body: <Widget>[
        _TimeRuler(
          key: DabblerTimeRuler.hourColumnKey,
          label: widget.hourColumnLabel,
          values: DabblerTimeValues.hours,
          selected: DabblerTimeValues.hourOfPeriodOf(value),
          enabledOf: (int hour) =>
              widget.isAllowed(DabblerTimeValues.withHourOfPeriod(value, hour)),
          onSelected: (int hour) =>
              _commit(DabblerTimeValues.withHourOfPeriod(value, hour)),
        ),
        _TimeRuler(
          key: DabblerTimeRuler.minuteColumnKey,
          label: widget.minuteColumnLabel,
          values: DabblerTimeValues.minutesFor(widget.minuteStep),
          selected: DabblerTimeValues.nearestMinute(
            value.minute,
            widget.minuteStep,
          ),
          enabledOf: (int minute) =>
              widget.isAllowed(DabblerTimeValues.withMinute(value, minute)),
          onSelected: (int minute) =>
              _commit(DabblerTimeValues.withMinute(value, minute)),
        ),
      ],
    );
  }

  void _commit(TimeOfDay next) {
    if (!widget.isAllowed(next) || next == widget.effectiveValue) {
      return;
    }
    widget.onChanged?.call(next);
  }
}
