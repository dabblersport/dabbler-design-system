import 'package:flutter/material.dart' show DayPeriod, TimeOfDay;
import 'package:flutter/widgets.dart';

import '../tokens/dabbler_type.dart';
import 'date_field.dart';
import 'picker_field.dart';

/// The time half of the formatting layer (AC1) and of the numerals rule (AC2).
///
/// Transcribed from `components/forms/TimeField.jsx:12-23`,
/// `TimeField.prompt.md` and `components/forms/fields.card.html:136` (unverified: file not mirrored).
///
/// ## Western Arabic numerals, regardless of locale (AC2)
///
/// Same two-sided guarantee as [DabblerDateFormat], for the same reason and by
/// the same mechanism: [format] builds from `int.toString()` and passes the
/// result through [DabblerType.toWesternDigits]; [parse] folds Arabic-Indic
/// and extended Arabic-Indic digits to Western ones before matching. Nothing
/// here touches `intl`'s `DateFormat.jm()`, which under an `ar` locale returns
/// `٦:٠٠ م` — both the wrong digits *and* the wrong meridiem for a product
/// whose format is `H:MM AM` *"in both scripts"*
/// (`TimeField.prompt.md` → RTL behaviour).
///
/// ## The meridiem is not localised either
///
/// `TimeField.jsx:12` formats the period as the literal `AM` / `PM` the value
/// already carries, and `fields.card.html:137` (unverified: file not mirrored) calls `H:MM AM` *"the product's
/// own format"*. [amLabel] and [pmLabel] are therefore constants, not a
/// locale lookup — a design-system decision transcribed, not an oversight.
abstract final class DabblerTimeFormat {
  const DabblerTimeFormat._();

  /// The placeholder — `TimeField.jsx:34`.
  static const String placeholder = 'H:MM AM';

  /// The before-noon marker.
  static const String amLabel = 'AM';

  /// The after-noon marker.
  static const String pmLabel = 'PM';

  /// `H:MM AM` in Western Arabic numerals, or `''` for null.
  ///
  /// `TimeField.jsx:12` — `${hour}:${pad(minute)} ${period}`. The hour is
  /// 12-hour and **not** zero-padded; the minute always is. Midnight and noon
  /// are `12`, which is what the source's `hour` already is — it never holds
  /// a `0`, because [parse] and its `TimePicker` both work in 1–12.
  static String format(TimeOfDay? time) {
    if (time == null) {
      return '';
    }
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String period = time.period == DayPeriod.am ? amLabel : pmLabel;
    return DabblerType.toWesternDigits(
      '$hour:${time.minute.toString().padLeft(2, '0')} $period',
    );
  }

  /// `6pm`, `6:00 PM`, `18:30`, `6.30 pm` — or null.
  ///
  /// `TimeField.jsx:14-22`, transcribed including its 24-hour fold: when no
  /// `am`/`pm` is typed, an hour of 12 or more is `PM` and anything above 12
  /// has 12 subtracted, so `18:30` is `6:30 PM` and `09:15` is `9:15 AM`.
  ///
  /// The source's hour range check (`hour < 1 || hour > 12`) is applied after
  /// that fold, so `00:30` is rejected — a real edge, transcribed rather than
  /// corrected, since the source's own `TimePicker` has no `12 AM` distinct
  /// from `12 PM` in its hour column either.
  static TimeOfDay? parse(String input) {
    final RegExpMatch? m = _pattern.firstMatch(
      DabblerType.toWesternDigits(input).trim(),
    );
    if (m == null) {
      return null;
    }
    int hour = int.parse(m.group(1)!);
    final int minute = m.group(2) == null ? 0 : int.parse(m.group(2)!);
    String? period = m.group(3)?.toUpperCase();
    if (period == null) {
      // A 24-hour hour above 23 is out of range. The source's fold would turn
      // `24:00` into `12:00 PM` (noon) silently; it is rejected instead.
      if (hour > 23) {
        return null;
      }
      period = hour >= 12 ? pmLabel : amLabel;
      if (hour > 12) {
        hour -= 12;
      }
    }
    if (hour < 1 || hour > 12 || minute > 59) {
      return null;
    }
    // Back to the 24-hour clock [TimeOfDay] stores: 12 AM is 0, 12 PM is 12.
    final int hour24 = (hour % 12) + (period == pmLabel ? 12 : 0);
    return TimeOfDay(hour: hour24, minute: minute);
  }

  /// Minutes since midnight — `to24` in `TimeField.jsx:53`.
  static int minutesOfDay(TimeOfDay time) => time.hour * 60 + time.minute;

  /// Whether [time] sits inside `min`/`max`, both inclusive.
  /// `TimeField.jsx:52-58`.
  static bool inBounds(TimeOfDay time, {TimeOfDay? min, TimeOfDay? max}) {
    final int v = minutesOfDay(time);
    return (min == null || v >= minutesOfDay(min)) &&
        (max == null || v <= minutesOfDay(max));
  }

  static final RegExp _pattern = RegExp(
    r'^(\d{1,2})\s*[:.]?\s*(\d{2})?\s*(am|pm)?$',
    caseSensitive: false,
  );
}

/// TimeField — a time of day, typed or picked.
///
/// Transcribed from `components/forms/TimeField.jsx`, `TimeField.d.ts`,
/// `TimeField.prompt.md` and `components/forms/fields.card.html:128-137` (unverified: file not mirrored).
///
/// ```dart
/// DabblerTimeField(
///   label: 'kick-off',
///   value: kickOff,
///   onChanged: (TimeOfDay? next) => setState(() => kickOff = next),
///   open: pickerOpen,
///   onOpenPicker: () => setState(() => pickerOpen = !pickerOpen),
/// )
/// ```
///
/// ## What this widget is, and what DS-806 adds
///
/// The field only: the box, the typed entry, the `H:MM AM` formatting layer,
/// the bounds check, the states, and [onOpenPicker]. It contains **no
/// `TimePicker`** — DS-806 owns that, and `TimeField.prompt.md` requires it be
/// *"used as-is"*. The seam is the same three members as [DabblerDateField]'s:
/// [onOpenPicker] to raise the surface, [open] to hold the field's focus state
/// and report `aria-expanded` while it is up, and [onChanged] so a picked time
/// travels the one value path typing already uses. [DabblerTimeFormat] is pure
/// and public, so the picker can render the field's format without a field.
///
/// ## The value type
///
/// **Documented deviation:** `TimeField.d.ts:4` (unverified: file not mirrored) types the value as the display
/// string itself — `"6:00 PM"`. This takes Flutter's [TimeOfDay] instead. The
/// string is a *rendering* of a time, and round-tripping every read through a
/// parser that can return null makes a caller handle a failure that cannot
/// happen; [TimeOfDay] is also what a Flutter time picker — DS-806's included
/// — already speaks, so the seam needs no adapter. The format itself is
/// unchanged and stays reachable as [DabblerTimeFormat.format], which is what
/// the field displays.
class DabblerTimeField extends StatefulWidget {
  /// Creates a time field.
  const DabblerTimeField({
    super.key,
    this.value,
    this.onChanged,
    this.minimum,
    this.maximum,
    this.label,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.placeholder,
    this.open = false,
    this.onOpenPicker,
    this.focusNode,
    this.invalidText = defaultInvalidText,
  });

  /// The default [invalidText]. English; callers override it.
  static const String defaultInvalidText = 'Enter a valid time, e.g. 6:30 PM';

  /// `icon="clock"` — `TimeField.jsx:67`.
  static const String iconName = 'clock';

  /// The chosen time, or null while unset (the source's `''`).
  final TimeOfDay? value;

  /// Called when the typed value commits to a new time, or clears to null.
  final ValueChanged<TimeOfDay?>? onChanged;

  /// The earliest acceptable time, inclusive. `min` in the source.
  final TimeOfDay? minimum;

  /// The latest acceptable time, inclusive. `max` in the source.
  final TimeOfDay? maximum;

  /// The label above the box.
  final String? label;

  /// The helper line below the box.
  final String? helperText;

  /// The error line below the box.
  final String? errorText;

  /// Whether the field accepts input.
  final bool enabled;

  /// The empty-state text. Defaults to [DabblerTimeFormat.placeholder].
  final String? placeholder;

  /// Whether the caller's picker surface is open.
  final bool open;

  /// Fired by the trailing button. The picker surface is the caller's.
  final VoidCallback? onOpenPicker;

  /// An external focus node.
  final FocusNode? focusNode;

  /// Shown as the error line when typed text cannot be read as a time
  /// (`25:61`, `13:00 PM`, `half six`). [errorText] wins when both are set.
  /// Cleared by the next successful commit.
  final String invalidText;

  /// The value as the field displays it.
  String get displayText => DabblerTimeFormat.format(value);

  @override
  State<DabblerTimeField> createState() => _DabblerTimeFieldState();
}

class _DabblerTimeFieldState extends State<DabblerTimeField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.displayText,
  );

  @override
  void didUpdateWidget(DabblerTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `useEffect(() => setText(value), [value])` — `TimeField.jsx:40`.
    if (widget.value != oldWidget.value) {
      _reported = null;
    }
    final String display = widget.displayText;
    if (display != oldWidget.displayText && display != _controller.text) {
      _controller.text = display;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Set when typed text could not be read; drives the error line.
  String? _invalid;

  void _setInvalid(String? value) {
    if (_invalid != value) setState(() => _invalid = value);
  }

  /// `commitText` — `TimeField.jsx:43-49`.
  ///
  /// **Documented deviation:** the source parses but does **not** bounds-check
  /// the typed path — `inBounds` is wired only to the `TimePicker`'s
  /// `onChange` (`TimeField.jsx:78`). `DateField.prompt.md`, the sibling this
  /// pair is specified against, states *"`min`/`max` are enforced on both
  /// paths"*, so bounds are enforced here too (retained provisionally, ruling
  /// cdispatch-5e71152a item 3), and nothing is silently dropped:
  ///
  /// * a readable time outside [DabblerTimeField.minimum] /
  ///   [DabblerTimeField.maximum] is **clamped** to the nearer bound and
  ///   committed;
  /// * unreadable or impossible text (`25:61`, `13:00 PM`, `24:00`) reverts
  ///   to the current value **and shows** [DabblerTimeField.invalidText].
  void _commit(String raw) {
    // The blur after Enter re-commits the text this method just restored;
    // unchanged text commits nothing and keeps any error showing.
    if (raw.trim().isNotEmpty && raw.trim() == widget.displayText) {
      return;
    }
    if (raw.trim().isEmpty) {
      _setInvalid(null);
      if (widget.value != null) {
        widget.onChanged?.call(null);
      }
      return;
    }
    final TimeOfDay? parsed = DabblerTimeFormat.parse(raw);
    if (parsed == null) {
      final String display = widget.displayText;
      if (_controller.text != display) {
        _controller.text = display;
      }
      _setInvalid(widget.invalidText);
      return;
    }
    _setInvalid(null);
    TimeOfDay next = parsed;
    final TimeOfDay? min = widget.minimum;
    final TimeOfDay? max = widget.maximum;
    if (min != null &&
        DabblerTimeFormat.minutesOfDay(next) <
            DabblerTimeFormat.minutesOfDay(min)) {
      next = min;
    } else if (max != null &&
        DabblerTimeFormat.minutesOfDay(next) >
            DabblerTimeFormat.minutesOfDay(max)) {
      next = max;
    }
    // Show the committed (possibly clamped) value at once; the parent's
    // rebuild agrees with it.
    final String shown = DabblerTimeFormat.format(next);
    if (_controller.text != shown) {
      _controller.text = shown;
    }
    // Enter commits, and the blur that follows commits the same text again;
    // an unchanged value is dropped so one edit is one callback. See
    // [DabblerDateField]'s `_report`.
    if (next != widget.value && next != _reported) {
      _reported = next;
      widget.onChanged?.call(next);
    }
  }

  /// The last value reported and not yet echoed back through
  /// [DabblerTimeField.value]; stops a clamped Enter + blur reporting twice.
  TimeOfDay? _reported;

  @override
  Widget build(BuildContext context) {
    return DabblerPickerFieldShell(
      controller: _controller,
      iconName: DabblerTimeField.iconName,
      label: widget.label,
      placeholder: widget.placeholder ?? DabblerTimeFormat.placeholder,
      helperText: widget.helperText,
      errorText: widget.errorText ?? _invalid,
      enabled: widget.enabled,
      open: widget.open,
      onOpenPressed: widget.onOpenPicker,
      onCommit: _commit,
      focusNode: widget.focusNode,
    );
  }
}
