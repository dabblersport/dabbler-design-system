/// Part of the `calendar.dart` library — the opt-in built-in year picker
/// (Alpha DS gaps 5, item 10).
///
/// **Why `part`.** The host reuses [DabblerCalendar]'s private header and card
/// build; a part keeps that access without widening the public API.
/// `calendar.dart` was already over the 500-line house rule before this item;
/// the new code lives here so that file grows by as little as possible.
part of 'calendar.dart';

/// A grid of years, three to a row, for jumping a calendar between years.
///
/// The design source draws the year chip with a caret but wires no list
/// (`Calendar.jsx:28-34`; see [DabblerCalendar.onMonthPressed]). This is the
/// list it implies, drawn with the day cell's own vocabulary so the two read
/// as one control: each year is a [DabblerCalendar.cellPillHeight] pill in a
/// [DabblerSizing.touchTargetMin] target, `.t-footnote` medium in
/// [DabblerColors.textPrimary], and the selected year is
/// [DabblerColors.brandPrimary] with [DabblerColors.onBrand] at bold — exactly
/// a selected day.
///
/// **Deviation:** no design file draws the open year list; the layout (three
/// columns, scrolling, opened in place of the days) is this package's, built
/// only from existing tokens.
///
/// RTL: the rows are [Row]s, so years run right-to-left under
/// [TextDirection.rtl], as the weekday columns do; numerals stay Western
/// ([DabblerType.toWesternDigits], [DabblerType.numeralFeatures]). There is no
/// animation, so reduced motion has nothing to switch off.
class DabblerCalendarYearGrid extends StatefulWidget {
  /// Creates a grid of the years [firstYear]..[lastYear] inclusive.
  const DabblerCalendarYearGrid({
    super.key,
    required this.firstYear,
    required this.lastYear,
    required this.selectedYear,
    required this.onYearSelected,
  }) : assert(lastYear >= firstYear, 'an empty year range');

  /// Years per row.
  static const int columns = 3;

  /// The visible height: six rows of [DabblerSizing.touchTargetMin] with
  /// [DabblerSpacing.space1] between them — the height of six weeks of days,
  /// so the card does not jump when the picker opens. Longer ranges scroll.
  static const double height =
      6 * DabblerSizing.touchTargetMin + 5 * DabblerSpacing.space1;

  /// The key of [year]'s cell, for tests and composition.
  static Key yearKey(int year) =>
      ValueKey<String>('DabblerCalendar.year.$year');

  /// First year listed.
  final int firstYear;

  /// Last year listed.
  final int lastYear;

  /// The highlighted year, scrolled into view on open.
  final int selectedYear;

  /// Fired with the chosen year.
  final ValueChanged<int> onYearSelected;

  @override
  State<DabblerCalendarYearGrid> createState() =>
      _DabblerCalendarYearGridState();
}

class _DabblerCalendarYearGridState extends State<DabblerCalendarYearGrid> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    final int row =
        (widget.selectedYear - widget.firstYear).clamp(0, 1 << 20) ~/
        DabblerCalendarYearGrid.columns;
    // Put the selected year's row in the middle of the six visible rows.
    _scroll = ScrollController(
      initialScrollOffset: ((row - 2) * _pitch).clamp(0, double.infinity),
    );
  }

  static const double _pitch =
      DabblerSizing.touchTargetMin + DabblerSpacing.space1;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final int count = widget.lastYear - widget.firstYear + 1;
    const int cols = DabblerCalendarYearGrid.columns;
    return SizedBox(
      height: DabblerCalendarYearGrid.height,
      child: SingleChildScrollView(
        controller: _scroll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: DabblerSpacing.space1,
          children: <Widget>[
            for (int r = 0; r * cols < count; r++)
              Row(
                spacing: DabblerSpacing.space1,
                children: <Widget>[
                  for (int c = 0; c < cols; c++)
                    Expanded(
                      child: r * cols + c < count
                          ? _year(
                              colors,
                              direction,
                              widget.firstYear + r * cols + c,
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _year(DabblerColors colors, TextDirection direction, int year) {
    final bool on = year == widget.selectedYear;
    final Widget pill = Container(
      height: DabblerCalendar.cellPillHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: on ? colors.brandPrimary : null,
        borderRadius: DabblerRadius.pillAll,
      ),
      child: Text(
        DabblerType.toWesternDigits('$year'),
        style: DabblerType.footnote
            .resolveForDirection(direction)
            .copyWith(
              color: on ? colors.onBrand : colors.textPrimary,
              fontWeight: on ? DabblerType.bold : DabblerType.medium,
              fontFeatures: DabblerType.numeralFeatures,
            ),
      ),
    );
    return Semantics(
      key: DabblerCalendarYearGrid.yearKey(year),
      button: true,
      selected: on,
      child: DabblerFocusRing(
        borderRadius: DabblerRadius.pillAll,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onYearSelected(year),
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
}

/// Holds whether the built-in year list is open for a [DabblerCalendar] with
/// [DabblerCalendar.yearPicker] on.
class _DabblerCalendarYearHost extends StatefulWidget {
  const _DabblerCalendarYearHost({required this.calendar});

  final DabblerCalendar calendar;

  @override
  State<_DabblerCalendarYearHost> createState() =>
      _DabblerCalendarYearHostState();
}

class _DabblerCalendarYearHostState extends State<_DabblerCalendarYearHost> {
  bool _open = false;

  void _toggle() {
    widget.calendar.onYearPressed?.call();
    setState(() => _open = !_open);
  }

  void _pick(int year) {
    final DabblerCalendar cal = widget.calendar;
    DateTime next = DateTime(year, cal.month.month);
    final DateTime? min = cal.minimum;
    final DateTime? max = cal.maximum;
    if (min != null && next.isBefore(DateTime(min.year, min.month))) {
      next = DateTime(min.year, min.month);
    }
    if (max != null && next.isAfter(DateTime(max.year, max.month))) {
      next = DateTime(max.year, max.month);
    }
    setState(() => _open = false);
    cal.onMonthChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerCalendar cal = widget.calendar;
    final int year = cal.month.year;
    return cal._body(
      context,
      _toggle,
      _open
          ? DabblerCalendarYearGrid(
              firstYear: cal.minimum?.year ?? year - cal.yearPickerSpan,
              lastYear: cal.maximum?.year ?? year + cal.yearPickerSpan,
              selectedYear: year,
              onYearSelected: _pick,
            )
          : null,
    );
  }
}
