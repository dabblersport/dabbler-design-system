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

/// The time picker's value arithmetic, pure and public.
///
/// The same shape as [DabblerTimeFormat] and [DabblerCalendarMonth]: a
/// composer that needs to know which values the picker offers, or to move a
/// [TimeOfDay] one column at a time, does not have to build a widget to find
/// out.
abstract final class DabblerTimeValues {
  const DabblerTimeValues._();

  /// The hour column, 1 … 12.
  ///
  /// `TimePicker.jsx:77` — `Array.from({length: 12}, (_, i) => i + 1)`. There
  /// is no `0` and no `24`; the source's hour column is 12-hour and the period
  /// is a separate control, which is also what [DabblerTimeFormat] parses and
  /// prints.
  static const List<int> hours = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  /// `5` — `TimePicker.jsx:78` builds `i * 5`, twelve steps.
  static const int defaultMinuteStep = 5;

  /// The default value: `7:00 AM`.
  ///
  /// `TimePicker.jsx:86` — `hour = 7, minute = 0, period = 'AM'`.
  static const TimeOfDay defaultValue = TimeOfDay(hour: 7, minute: 0);

  /// The minute column at [step] minutes — `0, step, 2·step …` below 60.
  static List<int> minutesFor(int step) => <int>[
    for (int m = 0; m < TimeOfDay.minutesPerHour; m += step) m,
  ];

  /// The 1–12 hour [time] shows. `12` for both midnight and noon, which is
  /// what [DabblerTimeFormat.format] prints.
  static int hourOfPeriodOf(TimeOfDay time) =>
      time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;

  /// [time] with its 12-hour hour replaced, keeping minute and period.
  static TimeOfDay withHourOfPeriod(TimeOfDay time, int hour12) => TimeOfDay(
    hour: (hour12 % 12) + (time.period == DayPeriod.pm ? 12 : 0),
    minute: time.minute,
  );

  /// [time] with its minute replaced.
  static TimeOfDay withMinute(TimeOfDay time, int minute) =>
      TimeOfDay(hour: time.hour, minute: minute);

  /// [time] moved to [period], keeping the 12-hour hour and the minute.
  static TimeOfDay withPeriod(TimeOfDay time, DayPeriod period) => TimeOfDay(
    hour: (hourOfPeriodOf(time) % 12) + (period == DayPeriod.pm ? 12 : 0),
    minute: time.minute,
  );

  /// The value of [step] column nearest [minute], never above it by more than
  /// half a step.
  ///
  /// `TimePicker.jsx:91` — `MINUTE_STEPS.reduce(…)`, the nearest step, so a
  /// `6:37` arriving from a typed field shows `35` under the window rather
  /// than nothing.
  static int nearestMinute(int minute, int step) {
    int best = 0;
    for (final int candidate in minutesFor(step)) {
      if ((candidate - minute).abs() < (best - minute).abs()) {
        best = candidate;
      }
    }
    return best;
  }
}

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

/// The `Ruler` of `TimePicker.jsx:3-75`: a looping strip of numerals under a
/// fixed centre window, dragged horizontally.
class _TimeRuler extends StatefulWidget {
  const _TimeRuler({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.enabledOf,
    required this.onSelected,
  });

  final String label;
  final List<int> values;
  final int selected;
  final bool Function(int) enabledOf;
  final ValueChanged<int> onSelected;

  @override
  State<_TimeRuler> createState() => _TimeRulerState();
}

class _TimeRulerState extends State<_TimeRuler> {
  final FocusNode _node = FocusNode(debugLabel: 'DabblerTimePicker ruler');
  double _dragPx = 0;
  bool _dragging = false;
  bool _focused = false;

  int get _n => widget.values.length;
  int get _idx => math.max(0, widget.values.indexOf(widget.selected));

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  void _pick(int index) {
    final int wrapped = ((index % _n) + _n) % _n;
    final int v = widget.values[wrapped];
    if (widget.enabledOf(v)) {
      widget.onSelected(v);
    }
  }

  List<int> get _enabled => <int>[
    for (int i = 0; i < _n; i++)
      if (widget.enabledOf(widget.values[i])) i,
  ];

  void _step(int direction) {
    final List<int> enabled = _enabled;
    if (enabled.isEmpty) {
      return;
    }
    final int? next = direction > 0
        ? enabled.where((int i) => i > _idx).firstOrNull
        : enabled.where((int i) => i < _idx).lastOrNull;
    if (next != null) {
      widget.onSelected(widget.values[next]);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp) {
      _step(1);
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowDown) {
      _step(-1);
    } else if (key == LogicalKeyboardKey.home) {
      final List<int> e = _enabled;
      if (e.isNotEmpty) {
        widget.onSelected(widget.values[e.first]);
      }
    } else if (key == LogicalKeyboardKey.end) {
      final List<int> e = _enabled;
      if (e.isNotEmpty) {
        widget.onSelected(widget.values[e.last]);
      }
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _dragEnd() {
    final int shift = (-_dragPx / DabblerTimePicker.rulerPitch).round();
    setState(() {
      _dragPx = 0;
      _dragging = false;
    });
    _pick(_idx + shift);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool rtl = direction == TextDirection.rtl;
    const double pitch = DabblerTimePicker.rulerPitch;
    final int n = _n;
    final int trackLen = n * 3;
    final int centerAbs = n + _idx;
    final double translate = -(centerAbs * pitch + pitch / 2) + _dragPx;
    final Duration duration = (_dragging || DabblerMotion.reduceMotion(context))
        ? Duration.zero
        : DabblerTimePicker.glide;
    final String valueText = DabblerType.toWesternDigits(
      widget.selected.toString().padLeft(2, '0'),
    );

    final TextStyle base = DabblerType.title3.resolveForDirection(direction);

    Widget ruler = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double w = box.maxWidth;
        return SizedBox(
          height: DabblerTimePicker.rulerHeight,
          width: w,
          child: ClipRect(
            child: Directionality(
              // A scale: ascends to the right in both directions.
              textDirection: TextDirection.ltr,
              child: Stack(
                children: <Widget>[
                  // The window's outer shadow, painted first. CSS clips an outer
                  // `box-shadow` to outside the border box, so the box under the
                  // numerals is an opaque card-coloured fill that the shadow
                  // cannot show through, and the ticks and numerals draw above.
                  Positioned(
                    left: (w - (pitch + DabblerTimePicker.windowExtra)) / 2,
                    top: DabblerTimePicker.windowInset,
                    bottom: DabblerTimePicker.windowInset,
                    width: pitch + DabblerTimePicker.windowExtra,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaceCard,
                        borderRadius: BorderRadius.circular(
                          DabblerTimePicker.windowRadius,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            // `0 2px 8px rgba(0,0,0,0.05)` — ink at 5%.
                            color: colors.textPrimary.withValues(
                              alpha: DabblerTimePicker.windowShadowAlpha,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: w / 2,
                    bottom: DabblerTimePicker.tickBottom,
                    height: DabblerTimePicker.tickHeight,
                    width: trackLen * pitch,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: translate),
                      duration: duration,
                      curve: DabblerTimePicker.glideCurve,
                      builder: (BuildContext c, double t, Widget? _) =>
                          Transform.translate(
                            offset: Offset(t, 0),
                            child: CustomPaint(
                              painter: _TickPainter(
                                color: colors.borderDefault,
                                period: pitch / 4,
                              ),
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    left: w / 2,
                    top: 0,
                    height: DabblerTimePicker.rulerHeight,
                    width: trackLen * pitch,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: translate),
                      duration: duration,
                      curve: DabblerTimePicker.glideCurve,
                      builder: (BuildContext c, double t, Widget? _) =>
                          Transform.translate(
                            key: DabblerTimePicker.trackKey(widget.key!),
                            offset: Offset(t, 0),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                for (int i = 0; i < trackLen; i++)
                                  _cell(
                                    colors,
                                    base,
                                    rtl,
                                    i,
                                    (i - centerAbs).abs(),
                                    pitch,
                                  ),
                              ],
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    left: (w - (pitch + DabblerTimePicker.windowExtra)) / 2,
                    top: DabblerTimePicker.windowInset,
                    bottom: DabblerTimePicker.windowInset,
                    width: pitch + DabblerTimePicker.windowExtra,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            DabblerTimePicker.windowRadius,
                          ),
                          border: Border.all(
                            color: colors.brandPrimary,
                            width: DabblerTimePicker.windowBorder,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (w - DabblerTimePicker.pinWidth) / 2,
                    bottom: DabblerTimePicker.pinBottom,
                    width: DabblerTimePicker.pinWidth,
                    height: DabblerTimePicker.pinHeight,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.brandPrimary,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    ruler = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails d) {
        _node.requestFocus();
        setState(() => _dragging = true);
      },
      onHorizontalDragUpdate: (DragUpdateDetails d) =>
          setState(() => _dragPx += d.delta.dx),
      onHorizontalDragEnd: (DragEndDetails d) => _dragEnd(),
      onHorizontalDragCancel: () => setState(() {
        _dragPx = 0;
        _dragging = false;
      }),
      onTapUp: (TapUpDetails d) {
        _node.requestFocus();
        final RenderBox box = context.findRenderObject()! as RenderBox;
        final double dx = d.localPosition.dx - box.size.width / 2;
        _pick(_idx + (dx / pitch).round());
      },
      child: ruler,
    );

    return Semantics(
      container: true,
      label: widget.label,
      value: valueText,
      increasedValue: valueText,
      decreasedValue: valueText,
      onIncrease: () => _step(1),
      onDecrease: () => _step(-1),
      child: Focus(
        focusNode: _node,
        onKeyEvent: _onKey,
        onFocusChange: (bool f) => setState(() => _focused = f),
        child: MouseRegion(
          cursor: _dragging
              ? SystemMouseCursors.grabbing
              : SystemMouseCursors.grab,
          child: DabblerFocusRing.visible(
            visible: _focused,
            borderRadius: DabblerRadius.lgAll,
            child: ExcludeSemantics(child: ruler),
          ),
        ),
      ),
    );
  }

  Widget _cell(
    DabblerColors colors,
    TextStyle base,
    bool rtl,
    int absIdx,
    int dist,
    double pitch,
  ) {
    final bool on = dist == 0;
    final double opacity = on
        ? 1
        : math.max(
            DabblerTimePicker.minOpacity,
            1 - dist * DabblerTimePicker.opacityStep,
          );
    final double size =
        (on
            ? DabblerTimePicker.selectedFontSize
            : DabblerTimePicker.otherFontSize) -
        (rtl ? 0.9 : 0);
    return Positioned(
      left: absIdx * pitch,
      width: pitch,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Center(
          child: Text(
            DabblerType.toWesternDigits(
              widget.values[absIdx % _n].toString().padLeft(2, '0'),
            ),
            key: DabblerTimePicker.cellKey(widget.key!, absIdx),
            style: base.copyWith(
              fontSize: size,
              height: 1,
              fontWeight: DabblerType.regular,
              color: (on ? colors.brandPrimary : colors.textPrimary).withValues(
                alpha: opacity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `repeating-linear-gradient(to right, c 0 1.5px, transparent 1.5px period)`.
class _TickPainter extends CustomPainter {
  const _TickPainter({required this.color, required this.period});

  final Color color;
  final double period;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    for (double x = 0; x < size.width; x += period) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, DabblerTimePicker.tickWidth, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TickPainter old) =>
      old.color != color || old.period != period;
}
