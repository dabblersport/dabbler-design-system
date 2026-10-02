import 'dart:math' as math;

import 'package:flutter/material.dart' show DayPeriod, TimeOfDay;
import 'package:flutter/services.dart'
    show KeyDownEvent, KeyEvent, KeyRepeatEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../forms/time_field.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../overlays/menu.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';
import 'calendar.dart';

part 'time_picker_chrome.dart';
part 'time_picker_column.dart';
part 'time_picker_ruler.dart';
part 'time_picker_values.dart';
part 'time_ruler.dart';

/// TimePicker — the hour, minute and meridiem picker that pairs with
/// [DabblerCalendar]. Each column is a selectable listbox.
///
/// This is the D-030 component (`Dabbler/dabbler-docs/DECISIONS.md`, D-030:
/// the shipped vertical side-by-side listbox columns "are correct and stay").
/// Its API and semantics are those of commit `9ed2a55`, restored.
///
/// Transcribed from `components/calendar/TimePicker.jsx` in the live Claude
/// Design project 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System),
/// read via DesignSync get_file on 2026-10-02 and transcribed to a local mirror
/// by the coordinator. Fidelity to live is unverified; no pixel comparison has
/// been run.
///
/// ```dart
/// DabblerTimePicker(
///   value: kickOff,
///   onChanged: (TimeOfDay next) => setState(() => kickOff = next),
///   onConfirm: close,
///   onCancel: close,
///   visibleRows: 3,
///   minuteStep: 5,
/// )
/// ```
///
/// ## What is transcribed, and the one thing that is not
///
/// Kept: the card shell (`--surface-card`, an 18px corner, 15px padding —
/// `TimePicker.jsx:94`); the centred header showing the value and the AM/PM
/// segmented pill (`:95-108`); the value set — twelve hours and twelve
/// five-minute steps (`:77-78`); the default of `7:00 AM` (`:86`); the
/// nearest-step fold (`:91`); and the Confirm / Cancel footer (`:111-123`).
///
/// **Not ported here: the two horizontal drag rulers** (`TimePicker.jsx:3-75`).
/// The live `Ruler` is driven entirely by pointer events, with no key handler,
/// no discrete target and no announced value, and its non-centre numerals are
/// drawn at `opacity: max(0.2, ...)`. D-030 rules that the listbox stays and
/// that a scroll-wheel picker "comes back as a new component with a drawn
/// source and a stated keyboard contract". The ruler is available only as the
/// separate, opt-in [DabblerTimeRuler]; this widget never builds it. Each
/// column here is a real list of [DabblerMenuItem] rows (DS-700's
/// [DabblerMenuList] at [DabblerMenuRole.listbox]): 45px targets, a visible
/// selected state, listitem children, and arrow-key navigation this widget
/// drives (see *Keyboard*).
///
/// ## The seam to DS-602
///
/// The header renders through [DabblerTimeFormat.format], so the picker prints
/// the field's own `H:MM AM`, and the value type is [TimeOfDay] — what
/// `DabblerTimeField` speaks. [minimum]/[maximum] are checked with
/// [DabblerTimeFormat.inBounds].
///
/// ## Keyboard
///
/// [DabblerMenuList] at [DabblerMenuRole.listbox] is driven by its composer and
/// handles no keys, so each column is one focus stop and this widget owns the
/// keys:
///
/// * **Up / Down** move to the previous or next **enabled** value, without
///   wrapping. A value disabled by [minimum]/[maximum] is skipped.
/// * **Home / End** jump to the first and last enabled value.
/// * Every move commits through [onChanged] immediately (the source's `set()`
///   fires on each change, `TimePicker.jsx:90`).
///
/// ## RTL
///
/// The columns and the AM/PM pill are [Row]s, so [TextDirection.rtl] mirrors
/// them: the hour column sits on the right. Numerals are Western Arabic in both
/// scripts and the meridiem stays the literal `AM`/`PM`.
///
/// ## Touch targets and contrast
///
/// Every value row is a [DabblerMenuItem] (minimum height
/// [DabblerSizing.touchTargetMin], 45). The inactive meridiem segment, `--muted`
/// in the source (`TimePicker.jsx:104`), is [DabblerColors.textSecondary] under
/// D-003(a).
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
    this.visibleRows = defaultVisibleRows,
  }) : assert(minuteStep > 0 && minuteStep <= 60, 'minuteStep must be 1..60'),
       assert(visibleRows > 0, 'visibleRows must be positive');

  /// `border-radius: 18` on the card (`TimePicker.jsx:94`) — the same shell as
  /// [DabblerCalendar], and the same constant.
  static const double cardRadius = DabblerCalendar.cardRadius;

  /// How many rows a column shows before it scrolls. Not a source value — the
  /// live ruler showed a fixed 64px strip and had no row concept.
  static const int defaultVisibleRows = 3;

  /// The height of one value row: a [DabblerMenuItem]'s `minHeight`.
  static const double rowExtent = DabblerSizing.touchTargetMin;

  /// The hour column's accessible name.
  static const String defaultHourColumnLabel = 'Hour';

  /// The minute column's accessible name.
  static const String defaultMinuteColumnLabel = 'Minute';

  /// The meridiem control's accessible name.
  static const String defaultPeriodLabel = 'AM or PM';

  /// The key of the hour column.
  static const Key hourColumnKey = ValueKey<String>('DabblerTimePicker.hours');

  /// The key of the minute column.
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

  /// The chosen time. Null shows [DabblerTimeValues.defaultValue].
  ///
  /// The live `TimePicker` takes `hour`, `minute` and `period` separately. One
  /// [TimeOfDay] replaces the three — a documented deviation: it is what a
  /// Flutter time field already speaks, and three loose fields admit
  /// combinations (`hour: 0`, `period: 'PM'`) that the type does not.
  final TimeOfDay? value;

  /// Called on every change — hour, minute or meridiem.
  final ValueChanged<TimeOfDay>? onChanged;

  /// The minute column's step. 5 in the source.
  final int minuteStep;

  /// The earliest selectable time, inclusive. A value before it renders
  /// disabled and is skipped by the arrow keys.
  ///
  /// Not in `TimePicker.jsx`, which has no bounds; `TimeField.jsx:51-57` has
  /// them on the typed path. The predicate is [DabblerTimeFormat.inBounds].
  final TimeOfDay? minimum;

  /// The latest selectable time, inclusive. See [minimum].
  final TimeOfDay? maximum;

  /// Whether to draw the Confirm / Cancel row (`showActions`,
  /// `TimePicker.jsx:87`, default true).
  final bool showActions;

  /// Fired by Confirm.
  final VoidCallback? onConfirm;

  /// Fired by Cancel.
  final VoidCallback? onCancel;

  /// The Confirm label.
  final String confirmLabel;

  /// The Cancel label.
  final String cancelLabel;

  /// The hour column's accessible name.
  final String hourColumnLabel;

  /// The minute column's accessible name.
  final String minuteColumnLabel;

  /// The meridiem control's accessible name.
  final String periodLabel;

  /// How many rows a column shows before it scrolls.
  final int visibleRows;

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
    final TimeOfDay value = widget.effectiveValue;

    return _TimePickerChrome(
      value: value,
      // `gap: 10` (`TimePicker.jsx:94`); the nearest base-3 step is
      // `--space-3` (9).
      gap: DabblerSpacing.space3,
      headerGap: DabblerSpacing.space3,
      commit: _commit,
      valueKey: DabblerTimePicker.valueKey,
      amKey: DabblerTimePicker.amKey,
      pmKey: DabblerTimePicker.pmKey,
      confirmKey: DabblerTimePicker.confirmKey,
      cancelKey: DabblerTimePicker.cancelKey,
      periodLabel: widget.periodLabel,
      confirmLabel: widget.confirmLabel,
      cancelLabel: widget.cancelLabel,
      showActions: widget.showActions,
      onConfirm: widget.onConfirm,
      onCancel: widget.onCancel,
      body: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DabblerSpacing.space3,
          children: <Widget>[
            Expanded(
              child: _ValueColumn(
                key: DabblerTimePicker.hourColumnKey,
                label: widget.hourColumnLabel,
                values: DabblerTimeValues.hours,
                selected: DabblerTimeValues.hourOfPeriodOf(value),
                enabledOf: (int hour) => widget.isAllowed(
                  DabblerTimeValues.withHourOfPeriod(value, hour),
                ),
                onSelected: (int hour) =>
                    _commit(DabblerTimeValues.withHourOfPeriod(value, hour)),
                visibleRows: widget.visibleRows,
              ),
            ),
            Expanded(
              child: _ValueColumn(
                key: DabblerTimePicker.minuteColumnKey,
                label: widget.minuteColumnLabel,
                values: DabblerTimeValues.minutesFor(widget.minuteStep),
                selected: DabblerTimeValues.nearestMinute(
                  value.minute,
                  widget.minuteStep,
                ),
                enabledOf: (int minute) => widget.isAllowed(
                  DabblerTimeValues.withMinute(value, minute),
                ),
                onSelected: (int minute) =>
                    _commit(DabblerTimeValues.withMinute(value, minute)),
                visibleRows: widget.visibleRows,
                padded: true,
              ),
            ),
          ],
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
