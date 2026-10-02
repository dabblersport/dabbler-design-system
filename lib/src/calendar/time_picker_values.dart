/// Part of the `time_picker.dart` library — [DabblerTimeValues], the pure time arithmetic the picker uses.
///
/// **Why `part`, not a separate library.** The file stood over the
/// project's 500-line house rule (`013`). These declarations were moved
/// verbatim; `part`/`part of` keeps one logical library, so private names
/// stay private and no public API changes. No exemption was recorded.
///
/// The imports are the library's — a part file declares none of its own.
part of 'time_picker.dart';

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
