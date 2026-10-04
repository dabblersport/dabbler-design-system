import 'package:flutter/widgets.dart';

import '../foundations/text.dart';
import '../interaction/press_scale.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_layout.dart';
import '../tokens/dabbler_type.dart';

/// DateColumns — a date picked from three side-by-side scrolling columns:
/// day, month and year.
///
/// The date-of-birth sheet of `Auth and Onboarding.dc.html:569-586`: a birth
/// year is decades back, so the calendar grid is the wrong tool and the design
/// lists each part instead. Each column has a small uppercase caption
/// (`12/16`, weight 600, `--muted`, `:575`) over a fixed-height scrolling list
/// of options; the chosen option is filled with the brand colour and reads in
/// `on-brand` at weight 600 (`pick()`, `:1820-1824`); the others are plain.
///
/// ```dart
/// DabblerDateColumns(
///   day: day, month: month, year: year,
///   dayLabel: 'Day', monthLabel: 'Month', yearLabel: 'Year',
///   monthNames: const ['January', /* … */ 'December'],
///   firstYear: 1950, lastYear: 2010,
///   onDayChanged: (d) => setState(() => day = d),
///   onMonthChanged: (m) => setState(() => month = m),
///   onYearChanged: (y) => setState(() => year = y),
/// )
/// ```
///
/// ## Values
///
/// [day] is 1-31, [month] is 1-12 and [year] a calendar year; any may be null
/// until chosen. The columns hold no state and never reconcile an impossible
/// date (31 February): that is the caller's, which owns the rule for the
/// field. Years run from [lastYear] down to [firstYear], newest first
/// (`:1815-1816`).
///
/// ## Layout
///
/// The columns share the width 1 : 1.4 : 1.2 with `space3` between
/// (`grid-template-columns:1fr 1.4fr 1.2fr;gap:9px`, `:571`). Each list is
/// [listHeight] tall — the source's 200px, the nearest step being 192 — with
/// `space1` between options and the option `space3` / `space2` padded
/// (`:581`). Months are given by the caller so they can be localised.
///
/// **Deviation:** the source's list-end inset (`padding-right:3px`) is
/// `space1` at the inline end.
///
/// ## RTL
///
/// The columns run in reading order, so Day is at the right in RTL; the
/// caption and option text centre. Digits are drawn Western through
/// [DabblerType.toWesternDigits], as every numeral in the system is.
///
/// ## Accessibility
///
/// Each option is one node: a button named by its label, with a selected
/// state.
class DabblerDateColumns extends StatelessWidget {
  /// Creates the three columns.
  const DabblerDateColumns({
    super.key,
    required this.dayLabel,
    required this.monthLabel,
    required this.yearLabel,
    required this.monthNames,
    required this.firstYear,
    required this.lastYear,
    this.day,
    this.month,
    this.year,
    this.onDayChanged,
    this.onMonthChanged,
    this.onYearChanged,
  }) : assert(monthNames.length == 12, 'twelve month names'),
       assert(firstYear <= lastYear, 'firstYear is the earliest year');

  /// The caption over the day column.
  final String dayLabel;

  /// The caption over the month column.
  final String monthLabel;

  /// The caption over the year column.
  final String yearLabel;

  /// The twelve month names, January first, already localised.
  final List<String> monthNames;

  /// The earliest year offered.
  final int firstYear;

  /// The latest year offered.
  final int lastYear;

  /// The chosen day, 1-31.
  final int? day;

  /// The chosen month, 1-12.
  final int? month;

  /// The chosen year.
  final int? year;

  /// Called with the tapped day.
  final ValueChanged<int>? onDayChanged;

  /// Called with the tapped month, 1-12.
  final ValueChanged<int>? onMonthChanged;

  /// Called with the tapped year.
  final ValueChanged<int>? onYearChanged;

  /// The height of each list, `192`.
  static const double listHeight = DabblerSpacing.space11 * 4;

  /// The most days a month has.
  static const int maxDays = 31;

  /// The number of months in a year.
  static const int monthCount = 12;

  /// The flex of the day, month and year columns, `1 : 1.4 : 1.2`.
  static const List<double> columnFlex = <double>[1, 1.4, 1.2];

  @override
  Widget build(BuildContext context) {
    final List<_Option> days = <_Option>[
      for (int d = 1; d <= maxDays; d++) _Option(d, '$d'),
    ];
    final List<_Option> months = <_Option>[
      for (int m = 1; m <= monthCount; m++) _Option(m, monthNames[m - 1]),
    ];
    final List<_Option> years = <_Option>[
      for (int y = lastYear; y >= firstYear; y--) _Option(y, '$y'),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _column(dayLabel, days, day, onDayChanged, columnFlex[0]),
        const DabblerGap.h(DabblerSpacing.space3),
        _column(monthLabel, months, month, onMonthChanged, columnFlex[1]),
        const DabblerGap.h(DabblerSpacing.space3),
        _column(yearLabel, years, year, onYearChanged, columnFlex[2]),
      ],
    );
  }

  Widget _column(
    String label,
    List<_Option> options,
    int? selected,
    ValueChanged<int>? onChanged,
    double flex,
  ) {
    return Expanded(
      flex: (flex * 10).round(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DabblerText(
            label.toUpperCase(),
            style: DabblerType.caption1,
            weight: DabblerTextWeight.semibold,
            tone: DabblerTextTone.tertiary,
          ),
          const DabblerGap.v(DabblerSpacing.space2),
          SizedBox(
            height: listHeight,
            child: ListView.separated(
              padding: const EdgeInsetsDirectional.only(
                end: DabblerSpacing.space1,
              ),
              itemCount: options.length,
              separatorBuilder: (BuildContext _, int _) =>
                  const DabblerGap.v(DabblerSpacing.space1),
              itemBuilder: (BuildContext context, int i) => _OptionTile(
                label: options[i].label,
                selected: options[i].value == selected,
                onTap: onChanged == null
                    ? null
                    : () => onChanged(options[i].value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Option {
  const _Option(this.value, this.label);

  final int value;
  final String label;
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    vertical: DabblerSpacing.space3,
    horizontal: DabblerSpacing.space2,
  );

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final Widget content = Center(
      child: Text(
        DabblerType.toWesternDigits(label),
        textAlign: TextAlign.center,
        style: DabblerType.subheadline
            .resolveForDirection(direction)
            .copyWith(
              color: selected ? colors.onBrand : colors.textPrimary,
              fontWeight: selected ? DabblerType.semibold : DabblerType.regular,
            ),
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: DabblerPressScale.gesture(
            enabled: onTap != null,
            child: selected
                ? DabblerSurface(
                    radius: DabblerRadius.sm,
                    fill: colors.brandPrimary,
                    borderWidth: 0,
                    padding: _padding,
                    child: content,
                  )
                : Padding(padding: _padding, child: content),
          ),
        ),
      ),
    );
  }
}
