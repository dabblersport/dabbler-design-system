import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// One square of the month grid.
///
/// `Calendar.jsx:20-25` builds `{ n, out }` — a day *number* plus a flag for
/// "belongs to a neighbouring month". This carries the whole [DateTime]
/// instead, because a bare day number cannot answer the two questions AC1 and
/// AC4 need answered: which month a leading `31` belongs to, and whether a
/// cell is inside `minimum`/`maximum`. The source never asks either, because
/// its `range` is a list of day numbers scoped to the displayed month.
@immutable
class DabblerCalendarCell {
  /// Creates a cell.
  const DabblerCalendarCell({required this.date, required this.outside});

  /// The date this square stands for, at midnight local time.
  final DateTime date;

  /// Whether [date] falls outside the displayed month — the source's `out`.
  ///
  /// `Calendar.jsx:57` — an outside cell is muted and **not selectable**
  /// (`onClick={() => !c.out && …}`, `cursor: 'default'`).
  final bool outside;

  @override
  bool operator ==(Object other) =>
      other is DabblerCalendarCell &&
      other.date == date &&
      other.outside == outside;

  @override
  int get hashCode => Object.hash(date, outside);

  @override
  String toString() => 'DabblerCalendarCell($date, outside: $outside)';
}

/// The month grid's arithmetic, and the week-start convention (AC3).
///
/// Pure and public for the same reason `DabblerDateFormat` is: a composer — a
/// date field's overlay, a test, a range summary — can lay out or reason about
/// a month without building a widget.
///
/// ## The week start is a locale fact, not a direction fact (AC3)
///
/// `Calendar.jsx:5` fixes `DOW = ['MO' … 'SU']` and `:19` fixes
/// `lead = (first.getDay() + 6) % 7`, i.e. Monday-first, unconditionally. AC3
/// requires the week to start on *the correct day*, which for the Arabic
/// locales Dabbler ships to is Saturday, not Monday — and which is a property
/// of the **locale**, not of the text direction. The two are kept apart here:
///
/// * [cellsFor] takes `firstWeekday` explicitly and defaults to the source's
///   [DateTime.monday]. A caller that knows its locale passes the locale's
///   value and nothing guesses on its behalf.
/// * [defaultFirstWeekdayFor] is the *fallback* a widget uses when the caller
///   said nothing: Monday under [TextDirection.ltr], Saturday under
///   [TextDirection.rtl]. It is named as a default and documented as one
///   precisely so it is not mistaken for a locale lookup. **Extension beyond
///   the source**, which has no RTL behaviour at all.
///
/// The *column order* is the direction fact, and it is not computed here at
/// all: seven columns laid out in a [Row] run leading-to-trailing, so the
/// first day of the week sits on the right under [TextDirection.rtl] because
/// [Directionality] reverses the row, not because anything reversed a list.
/// See [DabblerCalendar] → *RTL*.
abstract final class DabblerCalendarMonth {
  const DabblerCalendarMonth._();

  /// Seven — the source's `repeat(7,1fr)` (`Calendar.jsx:47`).
  static const int daysInWeek = 7;

  /// The two-letter weekday abbreviations, keyed by [DateTime.weekday].
  ///
  /// `Calendar.jsx:5` — `['MO','TU','WE','TH','FR','SA','SU']`, re-keyed by
  /// weekday number so the list survives a week start other than Monday.
  /// Latin only; Arabic labels are a `content-manager` hand-off and are passed
  /// in through [DabblerCalendar.weekdayLabels].
  static const Map<int, String> weekdayAbbreviations = <int, String>{
    DateTime.monday: 'MO',
    DateTime.tuesday: 'TU',
    DateTime.wednesday: 'WE',
    DateTime.thursday: 'TH',
    DateTime.friday: 'FR',
    DateTime.saturday: 'SA',
    DateTime.sunday: 'SU',
  };

  /// The three-letter month abbreviations, `DateTime.january`-indexed at 1.
  ///
  /// `Calendar.jsx:6` — `['Jan' … 'Dec']`. Index 0 is a placeholder so
  /// `monthAbbreviations[date.month]` reads directly.
  static const List<String> monthAbbreviations = <String>[
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// The week start a widget falls back to when the caller named none.
  ///
  /// Monday under [TextDirection.ltr] — the source's convention, transcribed.
  /// Saturday under [TextDirection.rtl], which is the first day of the week
  /// across the Arabic-speaking markets Dabbler ships to.
  ///
  /// **This is a default, not a locale lookup.** A caller that knows its
  /// locale should pass [DabblerCalendar.firstWeekday] rather than let a text
  /// direction stand in for one.
  static int defaultFirstWeekdayFor(TextDirection direction) =>
      direction == TextDirection.rtl ? DateTime.saturday : DateTime.monday;

  /// The seven weekday numbers in column order, starting at [firstWeekday].
  ///
  /// Always in **logical** order — first column first. Nothing here reverses
  /// for RTL; the [Row] does that.
  static List<int> weekdayOrder(int firstWeekday) => <int>[
    for (int i = 0; i < daysInWeek; i++)
      ((firstWeekday - DateTime.monday + i) % daysInWeek) + DateTime.monday,
  ];

  /// How many leading cells the month needs before its first day.
  ///
  /// `Calendar.jsx:19` — `(first.getDay() + 6) % 7`, generalised. JavaScript's
  /// `getDay()` is 0 = Sunday; Dart's [DateTime.weekday] is 1 = Monday, which
  /// is what the `+ 6` in the source was converting to in the first place.
  static int leadingFor(DateTime month, {int firstWeekday = DateTime.monday}) {
    final DateTime first = DateTime(month.year, month.month);
    return (first.weekday - firstWeekday + daysInWeek) % daysInWeek;
  }

  /// The number of days in [month]'s month.
  ///
  /// `Calendar.jsx:20` — `new Date(year, month + 1, 0).getDate()`. Dart's
  /// [DateTime] normalises a zeroth day the same way.
  static int daysIn(DateTime month) =>
      DateTime(month.year, month.month + 1, 0).day;

  /// Every square of the grid, in reading order, padded to whole weeks.
  ///
  /// `Calendar.jsx:21-25`: the leading cells come from the previous month, the
  /// body from this one, and the trailing cells from the next until the length
  /// is a multiple of seven. The source spells the trailing number as
  /// `cells.length - lead - days + 1`, which evaluates to 1, 2, 3 … — i.e. the
  /// next month's opening days, which is what is built here directly.
  static List<DabblerCalendarCell> cellsFor(
    DateTime month, {
    int firstWeekday = DateTime.monday,
  }) {
    final int lead = leadingFor(month, firstWeekday: firstWeekday);
    final int days = daysIn(month);
    final DateTime first = DateTime(month.year, month.month);
    final List<DabblerCalendarCell> cells = <DabblerCalendarCell>[
      for (int i = lead; i > 0; i--)
        DabblerCalendarCell(
          date: DateTime(first.year, first.month, 1 - i),
          outside: true,
        ),
      for (int d = 1; d <= days; d++)
        DabblerCalendarCell(
          date: DateTime(first.year, first.month, d),
          outside: false,
        ),
    ];
    int trailing = 1;
    while (cells.length % daysInWeek != 0) {
      cells.add(
        DabblerCalendarCell(
          date: DateTime(first.year, first.month + 1, trailing++),
          outside: true,
        ),
      );
    }
    return cells;
  }

  /// [cellsFor] split into rows of seven.
  static List<List<DabblerCalendarCell>> weeksFor(
    DateTime month, {
    int firstWeekday = DateTime.monday,
  }) {
    final List<DabblerCalendarCell> cells = cellsFor(
      month,
      firstWeekday: firstWeekday,
    );
    return <List<DabblerCalendarCell>>[
      for (int i = 0; i < cells.length; i += daysInWeek)
        cells.sublist(i, i + daysInWeek),
    ];
  }

  /// [date] reduced to midnight, so two dates compare by day alone.
  static DateTime dayOf(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// The month [offset] months from [month], normalised to its first day.
  ///
  /// `onPrevMonth` / `onNextMonth` (`Calendar.d.ts:11-12`) are callbacks in
  /// the source and the parent does the arithmetic. This is that arithmetic,
  /// exposed so every caller does it the same way — and **always in calendar
  /// time**: "next" is later in both directions, whatever the text direction
  /// puts on which side of the header.
  static DateTime monthAdd(DateTime month, int offset) =>
      DateTime(month.year, month.month + offset);
}

/// Calendar — the month grid: a month/year header, a week of column labels, a
/// selectable grid and an optional Confirm / Cancel footer.
///
/// Transcribed from `components/calendar/Calendar.jsx`, `Calendar.d.ts`,
/// `Calendar.prompt.md` and the specimen `components/calendar/calendar.card.html`.
///
/// ```dart
/// DabblerCalendar(
///   month: shown,
///   selected: picked,
///   onSelect: (DateTime d) => setState(() => picked = <DateTime>{d}),
///   onMonthChanged: (DateTime m) => setState(() => shown = m),
///   onConfirm: close,
///   onCancel: close,
/// )
/// ```
///
/// ## Standalone, and the seam it attaches to
///
/// `Calendar.prompt.md` — *"Standalone; drop it into a `PanelCard` for the
/// framed date-picker card"*, and `DateField.prompt.md` requires the calendar
/// be *"used as-is — do not fork it for a field-specific variant"*. This widget
/// therefore raises no overlay of its own. A date field attaches it through
/// DS-602's three-member seam: `DabblerDateField.onOpenPicker` raises whatever
/// surface the composer likes, `DabblerDateField.open` is passed back so the
/// field holds its border, and a date chosen here is reported through
/// `DabblerDateField.onChanged` — the same path typing uses, so there is one
/// value path and not two. Formatting a chosen date in the field's own
/// `DD/MM/YYYY` is `DabblerDateFormat`, which is pure and needs no field.
///
/// ## Selection
///
/// `Calendar.d.ts:9` types `range` as `number[]` — *"a plain list of day
/// numbers, so non-contiguous selections work"* (`Calendar.prompt.md`). This
/// takes a `Set<DateTime>` instead. **Documented deviation.** Day numbers
/// cannot distinguish a selected `3` in the displayed month from a selected
/// `3` in the one either side of it, which the grid renders on screen at the
/// same time; they also cannot be bounds-checked. The *behaviour* is
/// unchanged — the set is plain, arbitrary and non-contiguous, and this widget
/// never interprets it as a span. Anything that is a range is the composer's,
/// exactly as it is the parent's in the source.
///
/// ## RTL (AC3)
///
/// Four separate facts, and only the third is this widget's own invention:
///
/// 1. **Column direction.** The seven columns are a [Row], so under
///    [TextDirection.rtl] the first day of the week is drawn on the **right**
///    and the week runs right-to-left. No list is reversed anywhere in this
///    file; [DabblerCalendarMonth.weekdayOrder] and
///    [DabblerCalendarMonth.cellsFor] return logical order in both directions.
/// 2. **Header controls.** Previous and next are the first and last children
///    of a [Row], so RTL mirrors their *positions* for free. Their *glyphs*
///    are swapped explicitly ([previousIconFor], [nextIconFor]) — an icon is a
///    picture and never mirrors itself (`Icon.prompt.md`, and DS-102's
///    [DabblerIcon] has no RTL prop by design).
/// 3. **Which way "next" goes.** Always forward in calendar time, in both
///    directions: [DabblerCalendarMonth.monthAdd] with `+1`. RTL moves where
///    the control sits and which way its arrow points; it does not turn
///    December into November.
/// 4. **Numerals.** Western Arabic in both scripts (DS-103a), by both halves
///    of the rule: every number is put through [DabblerType.toWesternDigits]
///    before it is laid out, and every style resolves with
///    [DabblerType.numeralFeatures] so an Arabic-aware face cannot substitute
///    Indic forms at draw time. Nothing here goes near `intl`'s `DateFormat`,
///    whose `ar` output is `٠٥/٠٩/٢٠٢٦` — the exact failure AC3 names.
///
/// ## Contrast and touch targets (AC4)
///
/// Measured against [DabblerColors.surfaceCard] in light
/// (`--surface-card` `#FFFFFF`), which is the card this grid draws on:
///
/// | Element | Source | Here | Why |
/// |---|---|---|---|
/// | Day in month | `--ink` | [DabblerColors.textPrimary] | 18.1:1 |
/// | Selected day | `--color-on-brand` on `--color-brand-primary` | same | 8.6:1 (main) |
/// | Weekday label | `--muted` | [DabblerColors.textPrimary] | **deviation**; see below |
/// | Outside day | `--subtle` | [DabblerColors.textSecondary] | **deviation**; 10.37:1 |
///
/// **Weekday label.** `Calendar.jsx:50` sets the column labels in `--muted`
/// (`#8C8C8C`), which measures **3.36:1** on `#FFFFFF` — below the 4.5:1 that
/// WCAG 1.4.3 requires of text at 11px/600 (not large text, which starts at
/// 18.66px bold). The labels are informative, not decorative, so no exemption
/// applies and AC4 is explicit that contrast is *"verified before shipping,
/// not deferred"*. They are set in [DabblerColors.textPrimary] instead. The
/// token-level finding — `--muted` cannot carry AA body text on a card — is
/// reported rather than patched here.
///
/// **Outside day.** `Calendar.jsx:58` sets these in `--subtle`, which
/// `DECISIONS.md` D-003 forbids as a text colour outright. They are set in
/// [DabblerColors.textSecondary], which since D-003(a) (KAN-260) resolves to
/// `--ink-soft` rather than `--muted` — **10.37:1** on the card. The WCAG
/// 1.4.3 inactive-component exemption this paragraph used to lean on is no
/// longer needed: no text in this widget, interactive or not, is below 4.5:1.
///
/// **Touch targets.** Every date cell is a target. Each is at least
/// [DabblerSizing.touchTargetMin] (45) **tall** — `Calendar.jsx:55` says `39`,
/// and the 45 is a **documented deviation** taken for AC4. Cell *width* is the
/// column width and is therefore set by the card, not by this file: seven
/// columns, six [DabblerSpacing.space1] gutters and two
/// [DabblerSpacing.space5] insets, i.e. `(cardWidth - 48) / 7`. That clears
/// WCAG 2.2 SC 2.5.8 Target Size (Minimum), which is 24×24, from a card width
/// of 216 up; it clears the 44 of the stricter SC 2.5.5 (Enhanced, AAA) from a
/// card width of 356 up. Both are measured in this ticket's tests at 320 and
/// 375. **A calendar narrower than ~356 has date cells under 44 wide, and
/// nothing inside this widget can fix that** — it is a layout decision the
/// composer makes when it sizes the card.
///
/// The month and year chips keep their 30px visual height
/// (`Calendar.jsx:29`) inside a 45px target, as do the two header arrows.
class DabblerCalendar extends StatelessWidget {
  /// Creates a month grid.
  const DabblerCalendar({
    super.key,
    required this.month,
    this.selected = const <DateTime>{},
    this.onSelect,
    this.onMonthChanged,
    this.minimum,
    this.maximum,
    this.firstWeekday,
    this.weekdayLabels,
    this.monthLabels,
    this.onMonthPressed,
    this.onYearPressed,
    this.showActions = true,
    this.onConfirm,
    this.onCancel,
    this.confirmLabel = defaultConfirmLabel,
    this.cancelLabel = defaultCancelLabel,
    this.previousMonthLabel = defaultPreviousMonthLabel,
    this.nextMonthLabel = defaultNextMonthLabel,
  });

  /// `Confirm` — `Calendar.jsx:70`.
  static const String defaultConfirmLabel = 'Confirm';

  /// `Cancel` — `Calendar.jsx:75`.
  static const String defaultCancelLabel = 'Cancel';

  /// The previous-month control's accessible name. Not in the source, which
  /// wraps a bare glyph in a `<span onClick>` with no name at all.
  static const String defaultPreviousMonthLabel = 'Previous month';

  /// The next-month control's accessible name. See
  /// [defaultPreviousMonthLabel].
  static const String defaultNextMonthLabel = 'Next month';

  /// `border-radius: 18` on the card (`Calendar.jsx:38`) — [DabblerRadius.xl].
  static const double cardRadius = DabblerRadius.xl;

  /// The chips' visual height, inside a [DabblerSizing.touchTargetMin] target
  /// (`Calendar.jsx:29`).
  static const double chipHeight = 30;

  /// The key of the previous-month control.
  static const Key previousMonthKey = ValueKey<String>(
    'DabblerCalendar.previous',
  );

  /// The key of the next-month control.
  static const Key nextMonthKey = ValueKey<String>('DabblerCalendar.next');

  /// The key of the month chip.
  static const Key monthChipKey = ValueKey<String>('DabblerCalendar.monthChip');

  /// The key of the year chip.
  static const Key yearChipKey = ValueKey<String>('DabblerCalendar.yearChip');

  /// The key of the confirm action.
  static const Key confirmKey = ValueKey<String>('DabblerCalendar.confirm');

  /// The key of the cancel action.
  static const Key cancelKey = ValueKey<String>('DabblerCalendar.cancel');

  /// The key of the cell standing for [date].
  static Key dayKey(DateTime date) => ValueKey<String>(
    'DabblerCalendar.day.${date.year}-${date.month}-${date.day}',
  );

  /// The key of the column label for [weekday] ([DateTime.monday] … ).
  static Key weekdayKey(int weekday) =>
      ValueKey<String>('DabblerCalendar.weekday.$weekday');

  /// The previous-month glyph for [direction] — see *RTL* fact 2.
  static String previousIconFor(TextDirection direction) =>
      direction == TextDirection.rtl ? 'arrow-right-3' : 'arrow-left-2';

  /// The next-month glyph for [direction] — see *RTL* fact 2.
  static String nextIconFor(TextDirection direction) =>
      direction == TextDirection.rtl ? 'arrow-left-2' : 'arrow-right-3';

  /// Any date inside the month to display. Only its year and month are read.
  ///
  /// `Calendar.d.ts:5-6` takes `month` (0-indexed) and `year` as two numbers.
  /// One [DateTime] replaces both — **documented deviation** — because two
  /// loose ints let a caller pass a month of `13`, and because every arithmetic
  /// this widget does ([DabblerCalendarMonth.monthAdd]) is already date
  /// arithmetic.
  final DateTime month;

  /// The selected days. See *Selection*.
  final Set<DateTime> selected;

  /// Called with the day tapped. `onSelect` — `Calendar.d.ts:10`.
  ///
  /// Never fired for an outside cell, nor for one outside
  /// [minimum]/[maximum].
  final ValueChanged<DateTime>? onSelect;

  /// Called with the month to show next.
  ///
  /// Replaces the source's two separate `onPrevMonth` / `onNextMonth`
  /// (`Calendar.d.ts:11-12`) — **documented deviation**. The two callbacks
  /// exist there because the parent holds `month` and `year` as loose numbers
  /// and must do its own wrapping; here the arithmetic is
  /// [DabblerCalendarMonth.monthAdd] and the widget hands the caller the
  /// answer rather than the question, which is what stops each caller
  /// re-deriving a December roll-over.
  final ValueChanged<DateTime>? onMonthChanged;

  /// The earliest selectable day, inclusive. A cell before it renders
  /// unselectable.
  ///
  /// Not in the source: `Calendar.jsx` has no bounds at all, and
  /// `DateField.jsx:100` leaves the picked path's bounds *"to whoever owns the
  /// picker"* — which, for a date field's overlay, is this widget. The check
  /// itself is DS-602's `DabblerDateFormat.inBounds`, not a second one.
  final DateTime? minimum;

  /// The latest selectable day, inclusive. See [minimum].
  final DateTime? maximum;

  /// The first column's weekday, [DateTime.monday] … [DateTime.sunday].
  ///
  /// Null falls back to [DabblerCalendarMonth.defaultFirstWeekdayFor] — read
  /// its doc before relying on it, and pass the locale's value when known.
  final int? firstWeekday;

  /// The column labels, keyed by [DateTime.weekday].
  ///
  /// Null uses [DabblerCalendarMonth.weekdayAbbreviations], which is Latin.
  /// Arabic labels are a `content-manager` hand-off and arrive here.
  final Map<int, String>? weekdayLabels;

  /// The month names, `DateTime.january`-indexed at 1 with a placeholder at 0.
  ///
  /// Null uses [DabblerCalendarMonth.monthAbbreviations].
  final List<String>? monthLabels;

  /// Fired by the month chip. Null renders the chip as a plain label with no
  /// affordance.
  ///
  /// `Calendar.jsx:29-34` draws both chips with a dropdown caret and a pointer
  /// cursor but wires **no handler** — the month/year *selects* the `d.ts`
  /// summary names are a stub in the source. They are a real seam here, and a
  /// caller that supplies neither gets a header that does not claim to be
  /// interactive.
  final VoidCallback? onMonthPressed;

  /// Fired by the year chip. See [onMonthPressed].
  final VoidCallback? onYearPressed;

  /// Whether to draw the Confirm / Cancel row. `showActions` —
  /// `Calendar.d.ts:17`, default true.
  final bool showActions;

  /// Fired by Confirm.
  final VoidCallback? onConfirm;

  /// Fired by Cancel.
  final VoidCallback? onCancel;

  /// The Confirm label.
  final String confirmLabel;

  /// The Cancel label.
  final String cancelLabel;

  /// The previous-month control's accessible name.
  final String previousMonthLabel;

  /// The next-month control's accessible name.
  final String nextMonthLabel;

  /// Whether [date] may be selected: inside the month, and inside the bounds.
  bool isSelectable(DabblerCalendarCell cell) =>
      !cell.outside &&
      (minimum == null ||
          !cell.date.isBefore(DabblerCalendarMonth.dayOf(minimum!))) &&
      (maximum == null ||
          !cell.date.isAfter(DabblerCalendarMonth.dayOf(maximum!)));

  /// Whether [cell] is in [selected], compared by day.
  bool isSelected(DabblerCalendarCell cell) =>
      selected.any((DateTime d) => DabblerCalendarMonth.dayOf(d) == cell.date);

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final int start =
        firstWeekday ?? DabblerCalendarMonth.defaultFirstWeekdayFor(direction);
    final List<List<DabblerCalendarCell>> weeks = DabblerCalendarMonth.weeksFor(
      month,
      firstWeekday: start,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        // `background: var(--surface-card)`, `border-radius: 18`
        // (`Calendar.jsx:38`). Flat — no shadow anywhere in this file.
        color: colors.surfaceCard,
        borderRadius: const BorderRadius.all(Radius.circular(cardRadius)),
      ),
      child: Padding(
        // `padding: 15` (`Calendar.jsx:38`) — `--space-5`.
        padding: const EdgeInsets.all(DabblerSpacing.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // `gap: 12` (`Calendar.jsx:38`) — `--space-4`.
          spacing: DabblerSpacing.space4,
          children: <Widget>[
            _header(context, colors, direction),
            _grid(context, colors, direction, start, weeks),
            if (showActions) _actions(colors, direction),
          ],
        ),
      ),
    );
  }

  /// `Calendar.jsx:39-44` — prev, the two chips, next, space-between.
  Widget _header(
    BuildContext context,
    DabblerColors colors,
    TextDirection direction,
  ) {
    final List<String> months =
        monthLabels ?? DabblerCalendarMonth.monthAbbreviations;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // `gap: 9` (`Calendar.jsx:39`) — `--space-3`.
      spacing: DabblerSpacing.space3,
      children: <Widget>[
        _arrow(
          key: previousMonthKey,
          colors: colors,
          icon: previousIconFor(direction),
          semanticLabel: previousMonthLabel,
          onPressed: onMonthChanged == null
              ? null
              : () => onMonthChanged!(DabblerCalendarMonth.monthAdd(month, -1)),
        ),
        // Flexible, because the chips carry content: a long Arabic month name
        // ('سبتمبر') is wider than 'Sep', and a fixed Row would assert rather
        // than shrink. The label ellipsises inside the chip instead.
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DabblerSpacing.space3,
            children: <Widget>[
              Flexible(
                child: _chip(
                  key: monthChipKey,
                  colors: colors,
                  direction: direction,
                  label: months[month.month],
                  onPressed: onMonthPressed,
                ),
              ),
              Flexible(
                child: _chip(
                  key: yearChipKey,
                  colors: colors,
                  direction: direction,
                  label: DabblerType.toWesternDigits('${month.year}'),
                  onPressed: onYearPressed,
                ),
              ),
            ],
          ),
        ),
        _arrow(
          key: nextMonthKey,
          colors: colors,
          icon: nextIconFor(direction),
          semanticLabel: nextMonthLabel,
          onPressed: onMonthChanged == null
              ? null
              : () => onMonthChanged!(DabblerCalendarMonth.monthAdd(month, 1)),
        ),
      ],
    );
  }

  /// One header arrow: an 18px glyph centred in a 45×45 target.
  ///
  /// `Calendar.jsx:40` draws the bare glyph with no box at all. The box is
  /// AC4's: a glyph on its own is an 18px target.
  Widget _arrow({
    required Key key,
    required DabblerColors colors,
    required String icon,
    required String semanticLabel,
    required VoidCallback? onPressed,
  }) {
    return Semantics(
      key: key,
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: DabblerFocusRing(
        borderRadius: DabblerRadius.mdAll,
        enabled: onPressed != null,
        canRequestFocus: onPressed != null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: DabblerPressScale.gesture(
            enabled: onPressed != null,
            child: SizedBox(
              width: DabblerSizing.touchTargetMin,
              height: DabblerSizing.touchTargetMin,
              child: Center(
                child: DabblerIcon(
                  icon,
                  size: DabblerSizing.iconSm,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The month or year chip — `Calendar.jsx:28-34`.
  Widget _chip({
    required Key key,
    required DabblerColors colors,
    required TextDirection direction,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final Widget pill = Container(
      height: chipHeight,
      // `padding: '0 10px'` (`Calendar.jsx:29`). 10 is off the base-3 grid and
      // is transcribed literally, as DS-401 transcribes its own off-grid
      // button padding.
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: DabblerRadius.pillAll,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        // `gap: 4` — the nearest token is `--space-1` (3), which is what is
        // used; 4 is not a step of the base-3 grid DS-104 defines.
        spacing: DabblerSpacing.space1,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // `fontSize: 14, fontWeight: 600` (`Calendar.jsx:31`). The ramp has
              // no 14; `.t-footnote` (13) is the nearest step and is what DS-103a
              // says to round to rather than invent one.
              style: DabblerType.footnote
                  .resolveForDirection(direction)
                  .copyWith(
                    color: colors.textPrimary,
                    fontWeight: DabblerType.semibold,
                  ),
            ),
          ),
          DabblerIcon(
            'arrow-down-1',
            // `size={14}` — the documented small step is 18; 14 is not one of
            // DS-104's three icon sizes.
            size: DabblerSizing.iconSm,
            color: colors.textPrimary,
          ),
        ],
      ),
    );

    if (onPressed == null) {
      return KeyedSubtree(key: key, child: pill);
    }
    return Semantics(
      key: key,
      button: true,
      child: DabblerFocusRing(
        borderRadius: DabblerRadius.pillAll,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: DabblerPressScale.gesture(
            child: SizedBox(
              height: DabblerSizing.touchTargetMin,
              child: Center(child: pill),
            ),
          ),
        ),
      ),
    );
  }

  /// The column labels and the weeks — `Calendar.jsx:46-64`.
  Widget _grid(
    BuildContext context,
    DabblerColors colors,
    TextDirection direction,
    int start,
    List<List<DabblerCalendarCell>> weeks,
  ) {
    final Map<int, String> labels =
        weekdayLabels ?? DabblerCalendarMonth.weekdayAbbreviations;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // `gap: 3` on the grid (`Calendar.jsx:47`) — `--space-1`, applied on both
      // axes as a CSS grid `gap` does.
      spacing: DabblerSpacing.space1,
      children: <Widget>[
        Row(
          spacing: DabblerSpacing.space1,
          children: <Widget>[
            for (final int weekday in DabblerCalendarMonth.weekdayOrder(start))
              Expanded(
                child: Semantics(
                  key: DabblerCalendar.weekdayKey(weekday),
                  child: Text(
                    labels[weekday] ?? '',
                    textAlign: TextAlign.center,
                    // `fontSize: 11, fontWeight: 600` (`Calendar.jsx:50`) —
                    // `.t-caption-2` at semibold. The colour deviates; see
                    // *Contrast and touch targets*.
                    style: DabblerType.caption2
                        .resolveForDirection(direction)
                        .copyWith(
                          color: colors.textPrimary,
                          fontWeight: DabblerType.semibold,
                        ),
                  ),
                ),
              ),
          ],
        ),
        for (final List<DabblerCalendarCell> week in weeks)
          Row(
            spacing: DabblerSpacing.space1,
            children: <Widget>[
              for (final DabblerCalendarCell cell in week)
                Expanded(child: _cell(colors, direction, cell)),
            ],
          ),
      ],
    );
  }

  /// One date square — `Calendar.jsx:52-63`.
  Widget _cell(
    DabblerColors colors,
    TextDirection direction,
    DabblerCalendarCell cell,
  ) {
    final bool on = isSelected(cell);
    final bool selectable = isSelectable(cell);
    final Color foreground = on
        ? colors.onBrand
        : cell.outside
        ? colors.textSecondary
        : colors.textPrimary;

    final Widget square = Container(
      // `height: 39` in the source; 45 here for AC4 — see the class doc.
      height: DabblerSizing.touchTargetMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: on ? colors.brandPrimary : null,
        borderRadius: DabblerRadius.pillAll,
      ),
      child: Text(
        DabblerType.toWesternDigits('${cell.date.day}'),
        // `fontSize: 13, fontWeight: on ? 700 : 500` (`Calendar.jsx:61`) —
        // `.t-footnote` at bold or medium.
        style: DabblerType.footnote
            .resolveForDirection(direction)
            .copyWith(
              color: foreground,
              fontWeight: on ? DabblerType.bold : DabblerType.medium,
            ),
      ),
    );

    if (!selectable) {
      // `cursor: 'default'` and a guarded handler (`Calendar.jsx:53`): an
      // outside or out-of-bounds cell is inert, and is hidden from assistive
      // technology as a control rather than announced as a dead one.
      return KeyedSubtree(
        key: DabblerCalendar.dayKey(cell.date),
        child: square,
      );
    }

    return Semantics(
      key: DabblerCalendar.dayKey(cell.date),
      button: true,
      selected: on,
      child: DabblerFocusRing(
        borderRadius: DabblerRadius.pillAll,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSelect == null ? null : () => onSelect!(cell.date),
          child: DabblerPressScale.gesture(child: square),
        ),
      ),
    );
  }

  /// Confirm / Cancel — `Calendar.jsx:67-78`.
  Widget _actions(DabblerColors colors, TextDirection direction) {
    // A [Wrap], not a [Row]: the source lays the two actions out in a
    // `flex-direction: row` that is free to overflow its 320px card, and a
    // Flutter [Row] asserts instead of overflowing. Wrap keeps the same
    // leading-aligned order, mirrors with [Directionality] the same way, and
    // drops Cancel onto a second line rather than clipping it when the card is
    // narrow or the label is a long Arabic one.
    return Wrap(
      textDirection: direction,
      // `gap: 9` (`Calendar.jsx:68`) — `--space-3`, on both axes.
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
        DabblerCalendarTextAction(
          key: cancelKey,
          label: cancelLabel,
          onPressed: onCancel,
        ),
      ],
    );
  }
}

/// A bare text action: a label, no fill, no border, no glyph.
///
/// `Calendar.jsx:74-77` and `TimePicker.jsx:119-122` draw Cancel as text
/// alone — `height: 40`, `padding: '0 20px'`, `fontSize: 15, fontWeight: 500`,
/// `color: var(--ink)`, and no background and no outline.
///
/// **This is not a [DabblerButton], and that is a reported gap, not a
/// preference.** DS-401's nine [DabblerButtonTone]s are `primary`, `secondary`,
/// `accent`, `neutral`, `filled`, `outlined`, `destructive`, `iconLabel` and
/// `icon`. Every one of them paints a fill or a hairline; there is no text /
/// ghost tone, so no [DabblerButton] can render this. Rather than fork Button
/// or widen another ticket's file, this composes DS-200's [DabblerPressScale]
/// and DS-403's [DabblerFocusRing] directly — the same two primitives
/// [DabblerButton] composes — and restates no scale factor, no duration, no
/// curve and no ring geometry. A text tone belongs in DS-401; see the report.
///
/// Public because `DabblerTimePicker` needs the same action and a second
/// private copy would be the duplication this note exists to avoid.
class DabblerCalendarTextAction extends StatelessWidget {
  /// Creates a bare text action.
  const DabblerCalendarTextAction({
    super.key,
    required this.label,
    this.onPressed,
  });

  /// `height: 40` (`Calendar.jsx:75`). Below [DabblerSizing.touchTargetMin],
  /// so the target is grown to 45 and the 40 is not drawn at all — there is no
  /// fill or border for the visual height to be visible in.
  static const double sourceHeight = 40;

  /// The label.
  final String label;

  /// Fired on tap. Null disables the action.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: DabblerFocusRing(
        borderRadius: DabblerRadius.pillAll,
        enabled: onPressed != null,
        canRequestFocus: onPressed != null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: DabblerPressScale.gesture(
            enabled: onPressed != null,
            child: Container(
              height: DabblerSizing.touchTargetMin,
              // `padding: '0 20px'`. 20 is off the base-3 grid and is
              // transcribed literally, as DS-401 transcribes its own.
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: Text(
                label,
                // `fontSize: 15, fontWeight: 500` — `.t-subheadline` at medium.
                style: DabblerType.subheadline
                    .resolveForDirection(direction)
                    .copyWith(
                      color: colors.textPrimary,
                      fontWeight: DabblerType.medium,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
