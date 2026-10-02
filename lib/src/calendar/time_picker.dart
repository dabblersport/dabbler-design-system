import 'dart:math' as math;

import 'package:flutter/material.dart' show DayPeriod, TimeOfDay;
import 'package:flutter/services.dart'
    show KeyDownEvent, KeyEvent, KeyRepeatEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../forms/time_field.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'calendar.dart';

part 'time_picker_ruler.dart';
part 'time_picker_values.dart';

/// TimePicker — the hour, minute and meridiem picker that pairs with
/// [DabblerCalendar].
///
/// Transcribed from `components/calendar/TimePicker.jsx` in the live Claude
/// Design project 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System),
/// read via DesignSync get_file on 2026-10-02 and transcribed to a local mirror
/// by the coordinator.
///
/// ```dart
/// DabblerTimePicker(
///   value: kickOff,
///   onChanged: (TimeOfDay next) => setState(() => kickOff = next),
///   onConfirm: close,
///   onCancel: close,
/// )
/// ```
///
/// ## Source to Dart
///
/// | Live (`TimePicker.jsx`) | Dart |
/// |---|---|
/// | card `--surface-card`, radius 18, padding 15, gap 10 (`:98`) | [cardRadius], [DabblerSpacing.space5], [cardGap] |
/// | header `20 / 700` sans, gap 10 (`:95-96`) | [headerFontSize], [headerGap] |
/// | meridiem pill, `1px --outline-card`, `4px 10px`, `12 / 700`, inactive `--muted` (`:99-104`) | [DabblerColors.textSecondary] for `--muted` (D-003(a)) |
/// | `Ruler` height 64, pitch 46 (`:3`, `:39`) | [rulerHeight], [rulerPitch] |
/// | tick strip bottom 6, height 14, `1.5px` ticks every `pitch / 4` (`:41-44`) | [tickBottom], [tickHeight], [tickWidth] |
/// | numerals display face, 24 selected / 18 other, opacity `max(.2, 1 - dist * .3)` (`:50-57`) | [selectedFontSize], [otherFontSize], [minOpacity], [opacityStep] |
/// | centre window: top/bottom 4, width `pitch + 14`, radius 12, `2px` brand, shadow `0 2px 8px rgba(0,0,0,.05)` (`:65-68`) | [windowInset], [windowExtra], [windowRadius], [windowBorder] |
/// | pin: bottom 8, `2 x 16`, radius 1 (`:70-72`) | [pinBottom], [pinWidth], [pinHeight] |
/// | track glide `200ms cubic-bezier(.2,.8,.2,1)` (`:16`, `:43`) | [glide], [glideCurve] |
/// | drag end: `shift = round(-dx / pitch)`, wraps modulo n (`:26-27`) | same |
/// | hours `1..12`, minutes `i * 5` (`:77-78`), default `7 AM` (`:86`) | [DabblerTimeValues] |
///
/// ## Additions beyond the source (accessibility)
///
/// The source ruler is pointer-only. Kept on top of the faithful drawing:
///
/// * **Keyboard.** Each ruler is one focus stop: Left/Down step to the previous
///   enabled value, Right/Up to the next, Home/End jump to the first/last
///   enabled value. Every move commits through [onChanged] at once, as the
///   source does on pointer-up.
/// * **Semantics.** A ruler is an adjustable node with increase/decrease
///   actions and its two-digit value.
/// * **Tap.** A tap picks the numeral under the finger, so a discrete target
///   exists. The source's tap changes nothing.
///
/// Values disabled by [minimum]/[maximum] are never committed (the source's
/// `TimeField` `inBounds` guard, applied here where the value is chosen) and
/// are skipped by the keys.
///
/// ## The pin runs into the numerals — and so does live
///
/// Live `TimePicker.jsx:70` puts the 2x16 pin at `bottom: 8` of the 64px box
/// (y 40-56) while numerals are centred at y 32 (24px glyphs reach about y 44),
/// so the pin overlaps the lower edge of the centred numeral. The port keeps
/// that geometry; it is not a defect of the Dart port.
///
/// ## Remaining documented deviations
///
/// * The meridiem segments keep a [DabblerSizing.touchTargetMin] (45) minimum
///   height; the live `4px 10px` pill paints 24 tall.
/// * Confirm / Cancel are [DabblerButton]s (D-023), not the live 40px spans.
/// * The ruler is drawn in a left-to-right frame in both directions: it is a
///   scale (numbers ascend to the right), exactly as the physical CSS is. The
///   numerals use the Arabic size (Latin less 0.9px) under RTL.
class DabblerTimePicker extends StatefulWidget {
  /// Creates a time picker.
  const DabblerTimePicker({
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
    this.hourColumnLabel = defaultHourColumnLabel,
    this.minuteColumnLabel = defaultMinuteColumnLabel,
    this.periodLabel = defaultPeriodLabel,
  }) : assert(minuteStep > 0 && minuteStep <= 60, 'minuteStep must be 1..60');

  /// `border-radius: 18` (`TimePicker.jsx:94`).
  static const double cardRadius = DabblerCalendar.cardRadius;

  /// `gap: 10` between the card's rows (`TimePicker.jsx:94`).
  static const double cardGap = 10;

  /// `gap: 10` between the value and the meridiem pill (`:95`).
  static const double headerGap = 10;

  /// `fontSize: 20` of the header value (`:101`).
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

  /// The hour column's accessible name.
  static const String defaultHourColumnLabel = 'Hour';

  /// The minute column's accessible name.
  static const String defaultMinuteColumnLabel = 'Minute';

  /// The meridiem control's accessible name.
  static const String defaultPeriodLabel = 'AM or PM';

  /// The key of the hour ruler.
  static const Key hourColumnKey = ValueKey<String>('DabblerTimePicker.hours');

  /// The key of the minute ruler.
  static const Key minuteColumnKey = ValueKey<String>(
    'DabblerTimePicker.minutes',
  );

  /// The key of the header's formatted value.
  static const Key valueKey = ValueKey<String>('DabblerTimePicker.value');

  /// The key of the AM segment.
  static const Key amKey = ValueKey<String>('DabblerTimePicker.am');

  /// The key of the PM segment.
  static const Key pmKey = ValueKey<String>('DabblerTimePicker.pm');

  /// The key of the confirm action.
  static const Key confirmKey = ValueKey<String>('DabblerTimePicker.confirm');

  /// The key of the cancel action.
  static const Key cancelKey = ValueKey<String>('DabblerTimePicker.cancel');

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
  State<DabblerTimePicker> createState() => _DabblerTimePickerState();
}

class _DabblerTimePickerState extends State<DabblerTimePicker> {
  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final TimeOfDay value = widget.effectiveValue;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: const BorderRadius.all(
          Radius.circular(DabblerTimePicker.cardRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DabblerSpacing.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DabblerTimePicker.cardGap,
          children: <Widget>[
            _header(colors, direction, value),
            _TimeRuler(
              key: DabblerTimePicker.hourColumnKey,
              label: widget.hourColumnLabel,
              values: DabblerTimeValues.hours,
              selected: DabblerTimeValues.hourOfPeriodOf(value),
              enabledOf: (int hour) => widget.isAllowed(
                DabblerTimeValues.withHourOfPeriod(value, hour),
              ),
              onSelected: (int hour) =>
                  _commit(DabblerTimeValues.withHourOfPeriod(value, hour)),
            ),
            _TimeRuler(
              key: DabblerTimePicker.minuteColumnKey,
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
            if (widget.showActions) _actions(),
          ],
        ),
      ),
    );
  }

  void _commit(TimeOfDay next) {
    if (!widget.isAllowed(next) || next == widget.effectiveValue) {
      return;
    }
    widget.onChanged?.call(next);
  }

  Widget _header(
    DabblerColors colors,
    TextDirection direction,
    TimeOfDay value,
  ) {
    final bool rtl = direction == TextDirection.rtl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: DabblerTimePicker.headerGap,
      children: <Widget>[
        Text(
          DabblerTimeFormat.format(value),
          key: DabblerTimePicker.valueKey,
          // `H:MM AM` is the product's own format in both scripts; under an RTL
          // paragraph the bidi algorithm would draw `PM 6:35`.
          textDirection: TextDirection.ltr,
          // `fontSize: 20, fontWeight: 700`, sans (`TimePicker.jsx:96`);
          // Arabic size is Latin less 0.9.
          style: DabblerType.headline
              .resolveForDirection(direction)
              .copyWith(
                fontSize: DabblerTimePicker.headerFontSize - (rtl ? 0.9 : 0),
                color: colors.textPrimary,
                fontWeight: DabblerType.bold,
              ),
        ),
        _periodPill(colors, direction, value),
      ],
    );
  }

  Widget _periodPill(
    DabblerColors colors,
    TextDirection direction,
    TimeOfDay value,
  ) {
    return Semantics(
      container: true,
      label: widget.periodLabel,
      child: ClipRRect(
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
              _periodSegment(
                key: DabblerTimePicker.amKey,
                colors: colors,
                direction: direction,
                label: DabblerTimeFormat.amLabel,
                on: value.period == DayPeriod.am,
                onPressed: () =>
                    _commit(DabblerTimeValues.withPeriod(value, DayPeriod.am)),
              ),
              _periodSegment(
                key: DabblerTimePicker.pmKey,
                colors: colors,
                direction: direction,
                label: DabblerTimeFormat.pmLabel,
                on: value.period == DayPeriod.pm,
                onPressed: () =>
                    _commit(DabblerTimeValues.withPeriod(value, DayPeriod.pm)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _periodSegment({
    required Key key,
    required DabblerColors colors,
    required TextDirection direction,
    required String label,
    required bool on,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      key: key,
      button: true,
      selected: on,
      child: DabblerFocusRing(
        borderRadius: DabblerRadius.pillAll,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: DabblerPressScale.gesture(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: DabblerSizing.touchTargetMin,
                minWidth: DabblerSizing.touchTargetMin,
              ),
              // `padding: '4px 10px'` (`TimePicker.jsx:102`).
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
              alignment: Alignment.center,
              color: on ? colors.brandPrimary : null,
              child: Text(
                label,
                // `12 / 700`; inactive `--muted` (`:102-104`).
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

  Widget _actions() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: DabblerSpacing.space3,
      runSpacing: DabblerSpacing.space3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        DabblerButton(
          key: DabblerTimePicker.confirmKey,
          label: widget.confirmLabel,
          onPressed: widget.onConfirm,
          disabled: widget.onConfirm == null,
        ),
        DabblerButton(
          key: DabblerTimePicker.cancelKey,
          label: widget.cancelLabel,
          tone: DabblerButtonTone.text,
          onPressed: widget.onCancel,
          disabled: widget.onCancel == null,
        ),
      ],
    );
  }
}
