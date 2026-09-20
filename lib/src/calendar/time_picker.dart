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
  /// `TimePicker.jsx:80` — `Array.from({length: 12}, (_, i) => i + 1)`. There
  /// is no `0` and no `24`; the source's hour column is 12-hour and the period
  /// is a separate control, which is also what [DabblerTimeFormat] parses and
  /// prints.
  static const List<int> hours = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  /// `5` — `TimePicker.jsx:81` builds `i * 5`, twelve steps.
  static const int defaultMinuteStep = 5;

  /// The default value: `7:00 AM`.
  ///
  /// `TimePicker.jsx:88` — `hour = 7, minute = 0, period = 'AM'`.
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
  /// `TimePicker.jsx:93` — `MINUTE_STEPS.reduce(…)`, the nearest step, so a
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
/// Transcribed from `components/calendar/TimePicker.jsx`, `TimePicker.d.ts`,
/// `TimePicker.prompt.md` and the specimen
/// `components/calendar/calendar.card.html`.
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
/// ## What is transcribed, and the one thing that is not
///
/// Kept exactly: the card shell (`--surface-card`, an 18px corner, 15px
/// padding — `TimePicker.jsx:98`); the centred header showing the value and
/// the AM/PM segmented pill (`:99-114`); the value set — twelve hours and
/// twelve five-minute steps (`:80-81`); the default of `7:00 AM` (`:88`); the
/// nearest-step fold (`:93`); and the Confirm / Cancel footer (`:116-124`).
///
/// **Replaced: the two horizontal drag rulers.** `TimePicker.jsx:3-77` renders
/// each column as a `Ruler` — a 64px-tall strip of numbers dragged left and
/// right under a fixed centre window, driven entirely by `pointerdown` /
/// `pointermove` / `pointerup`. It is not ported, for two reasons that are
/// both this ticket's acceptance criteria:
///
/// * **AC4.** The ruler has no keyboard path at all and no discrete target:
///   a value is reached only by a pointer drag of `pitch` pixels, and the
///   non-centre numbers are drawn at `opacity: Math.max(0.2, …)`, which is a
///   contrast the token layer cannot state a ratio for. There is nothing to
///   measure a 44×44 target against because there are no targets.
/// * **AC2**, which names the composition to build instead: DS-700's
///   [DabblerMenuList] at [DabblerMenuRole.listbox]. DS-700 widened that
///   surface for exactly this component and says so — `DabblerSelect`'s own
///   note records that the listbox form *"is still right for `TimePicker`,
///   which genuinely owns its own container"*. Each column is therefore a real
///   list of [DabblerMenuItem] rows: 45px targets, a visible selected state,
///   [SemanticsRole.listItem] children, and arrow-key navigation this widget
///   drives (see *Keyboard*).
///
/// The *value semantics* are unchanged — same twelve hours, same twelve
/// minutes, same meridiem control, same default, same nearest-step fold. What
/// changed is how a finger or a keyboard reaches them.
///
/// ## The seam to DS-602
///
/// The header renders through [DabblerTimeFormat.format], so the picker prints
/// the field's own `H:MM AM` rather than a second format, and the value type is
/// [TimeOfDay] — what `DabblerTimeField` already speaks, so the two need no
/// adapter. A time field attaches this the same way a date field attaches
/// [DabblerCalendar]: `onOpenPicker` raises the surface, `open` comes back so
/// the field holds its border, and a picked time reports through the field's
/// `onChanged`. Bounds on the picked path are this widget's
/// ([minimum]/[maximum]) and are checked with [DabblerTimeFormat.inBounds] —
/// DS-602's own predicate, not a second one.
///
/// ## Keyboard
///
/// [DabblerMenuList] at [DabblerMenuRole.listbox] *"is driven by its
/// composer"* and deliberately handles no keys, so each column here is one
/// focus stop — a native `<select>`, not a roving list — and this widget owns
/// the keys:
///
/// * **Up / Down** move the selection to the previous or next **enabled**
///   value, without wrapping. A value disabled by [minimum]/[maximum] is
///   skipped, not landed on.
/// * **Home / End** jump to the first and last enabled value.
/// * Every move commits through [onChanged] immediately, which is what the
///   source does too (`TimePicker.jsx:92` — `set()` fires on each change and
///   there is no staged value).
///
/// ## RTL (AC3)
///
/// The two columns and the AM/PM pill are [Row]s, so [TextDirection.rtl]
/// mirrors their order for free: the hour column sits on the right, which is
/// where a right-to-left reader starts. Nothing in this file reverses a list,
/// and nothing is keyed off direction. Every number is rendered through
/// [DabblerTimeFormat.format] or [DabblerType.toWesternDigits], so the digits
/// are Western Arabic in both scripts (DS-103a) — and the meridiem stays the
/// literal `AM`/`PM`, which `TimeField.prompt.md` calls *"the product's own
/// format"* in both scripts and [DabblerTimeFormat] already carries as
/// constants.
///
/// ## Touch targets and contrast (AC4)
///
/// Every value row is a [DabblerMenuItem], whose minimum height is
/// [DabblerSizing.touchTargetMin] (45). The meridiem segments are the source's
/// `4px 10px` visual inside a 45px target. Row labels are
/// [DabblerColors.textPrimary] on [DabblerColors.surfaceCard] (18.1:1); the
/// selected row is [DabblerColors.onBrand] on [DabblerColors.brandPrimary]
/// (8.6:1 on `main`). `TimePicker.jsx:112` sets the *unselected* meridiem
/// segment in `--muted`, which measures 3.36:1 and is a **documented
/// deviation** for the same reason [DabblerCalendar]'s weekday labels are:
/// it is set in [DabblerColors.textPrimary] here.
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

  /// `border-radius: 18` on the card (`TimePicker.jsx:98`) — the same shell as
  /// [DabblerCalendar], and the same constant.
  static const double cardRadius = DabblerCalendar.cardRadius;

  /// How many rows a column shows before it scrolls. Not a source value — the
  /// ruler showed a fixed 64px strip and had no row concept. Three keeps the
  /// picker roughly the ruler's height while leaving the selection centred.
  static const int defaultVisibleRows = 3;

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
  /// `TimePicker.d.ts:5-7` splits it into `hour`, `minute` and `period`. One
  /// [TimeOfDay] replaces the three — **documented deviation**, for the reason
  /// DS-602 gives for its own value type: it is what a Flutter time field
  /// already speaks, so the seam needs no adapter, and three loose fields
  /// admit combinations (`hour: 0`, `period: 'PM'`) that the type does not.
  final TimeOfDay? value;

  /// Called on every change — hour, minute or meridiem.
  final ValueChanged<TimeOfDay>? onChanged;

  /// The minute column's step. 5 in the source.
  final int minuteStep;

  /// The earliest selectable time, inclusive. A value before it renders
  /// disabled and is skipped by the arrow keys.
  ///
  /// Not in `TimePicker.jsx`, which has no bounds. `TimeField.jsx:52-58` has
  /// them on the typed path and leaves the picked path to the picker's owner,
  /// which is this widget. The predicate is
  /// [DabblerTimeFormat.inBounds].
  final TimeOfDay? minimum;

  /// The latest selectable time, inclusive. See [minimum].
  final TimeOfDay? maximum;

  /// Whether to draw the Confirm / Cancel row. `showActions` —
  /// `TimePicker.d.ts:12`, default true.
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
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final TimeOfDay value = widget.effectiveValue;

    return DecoratedBox(
      decoration: BoxDecoration(
        // `background: var(--surface-card)`, `border-radius: 18`
        // (`TimePicker.jsx:98`). Flat.
        color: colors.surfaceCard,
        borderRadius: const BorderRadius.all(
          Radius.circular(DabblerTimePicker.cardRadius),
        ),
      ),
      child: Padding(
        // `padding: 15` — `--space-5`.
        padding: const EdgeInsets.all(DabblerSpacing.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // `gap: 10` (`TimePicker.jsx:98`). The nearest base-3 step is
          // `--space-3` (9), which is what DS-104 says to round to.
          spacing: DabblerSpacing.space3,
          children: <Widget>[
            _header(colors, direction, value),
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
                    onSelected: (int hour) => _commit(
                      DabblerTimeValues.withHourOfPeriod(value, hour),
                    ),
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

  /// `TimePicker.jsx:99-114` — the formatted value and the AM/PM pill,
  /// centred.
  Widget _header(
    DabblerColors colors,
    TextDirection direction,
    TimeOfDay value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: DabblerSpacing.space3,
      children: <Widget>[
        Text(
          DabblerTimeFormat.format(value),
          key: DabblerTimePicker.valueKey,
          // `fontSize: 20, fontWeight: 700` (`TimePicker.jsx:101`). The sans
          // ramp's nearest step is `.t-title-3` (20) — but title-3 is a
          // *display*-role style, and a numeric readout set in Gloock/Wingx is
          // not what the source asks for (`font-family: var(--font-sans)`).
          // `.t-headline` (17, sans, semibold) is the nearest **sans** step,
          // taken at bold.
          style: DabblerType.headline
              .resolveForDirection(direction)
              .copyWith(
                color: colors.textPrimary,
                fontWeight: DabblerType.bold,
              ),
        ),
        _periodPill(colors, direction, value),
      ],
    );
  }

  /// The two-segment meridiem control — `TimePicker.jsx:104-113`.
  Widget _periodPill(
    DabblerColors colors,
    TextDirection direction,
    TimeOfDay value,
  ) {
    return Semantics(
      container: true,
      label: widget.periodLabel,
      child: ClipRRect(
        // `border-radius: 999; overflow: hidden` (`TimePicker.jsx:104`).
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
              // `padding: '4px 10px'` (`TimePicker.jsx:107`) inside a 45px
              // target — AC4, exactly as [DabblerCalendar]'s chips.
              constraints: const BoxConstraints(
                minHeight: DabblerSizing.touchTargetMin,
                minWidth: DabblerSizing.touchTargetMin,
              ),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
              alignment: Alignment.center,
              color: on ? colors.brandPrimary : null,
              child: Text(
                label,
                // `fontSize: 12, fontWeight: 700` — `.t-caption-1` at bold.
                style: DabblerType.caption1
                    .resolveForDirection(direction)
                    .copyWith(
                      color: on ? colors.onBrand : colors.textPrimary,
                      fontWeight: DabblerType.bold,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Confirm / Cancel — `TimePicker.jsx:116-124`, centred rather than
  /// start-aligned, which is the one layout difference the source keeps
  /// between the two components.
  Widget _actions() {
    // A [Wrap] for the reason [DabblerCalendar]'s footer is one.
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

/// One value column: a [DabblerMenuList] at [DabblerMenuRole.listbox], bounded
/// to [visibleRows] rows, with its selection scrolled into view and the arrow
/// keys driven from here.
///
/// See [DabblerTimePicker] → *Keyboard* for why the keys are this widget's and
/// not the list's.
class _ValueColumn extends StatefulWidget {
  const _ValueColumn({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.enabledOf,
    required this.onSelected,
    required this.visibleRows,
    this.padded = false,
  });

  final String label;
  final List<int> values;
  final int selected;
  final bool Function(int) enabledOf;
  final ValueChanged<int> onSelected;
  final int visibleRows;

  /// Whether to zero-pad the label to two digits.
  ///
  /// `TimePicker.jsx:68` pads **both** columns — `String(c.val).padStart(2)`.
  /// The hour column is not padded here, so the column and
  /// [DabblerTimeFormat.format] agree: that formatter prints `7:05 PM`, not
  /// `07:05 PM` (`TimeField.jsx:14` — the hour is not padded), and a picker
  /// showing `07` beside a field showing `7` is two formats for one value.
  final bool padded;

  /// The row height a [DabblerMenuItem] lays out at — its `minHeight`.
  static const double rowExtent = DabblerSizing.touchTargetMin;

  @override
  State<_ValueColumn> createState() => _ValueColumnState();
}

class _ValueColumnState extends State<_ValueColumn> {
  final ScrollController _controller = ScrollController();
  final FocusNode _node = FocusNode(debugLabel: 'DabblerTimePicker column');
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
  }

  @override
  void didUpdateWidget(_ValueColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
    super.dispose();
  }

  /// Puts the selected row in the middle of the window.
  ///
  /// Arithmetic rather than [Scrollable.ensureVisible] because the rows live
  /// inside [DabblerMenuList] and this widget holds no handle on their
  /// contexts. Every row is exactly [_ValueColumn.rowExtent] tall — a
  /// [DabblerMenuItem]'s `minHeight`, asserted by this ticket's tests — so the
  /// offset is an index times that, clamped to the real extent.
  void _revealSelected() {
    if (!_controller.hasClients) {
      return;
    }
    final int index = widget.values.indexOf(widget.selected);
    if (index < 0) {
      return;
    }
    final double centred =
        (index - (widget.visibleRows - 1) / 2) * _ValueColumn.rowExtent;
    _controller.jumpTo(centred.clamp(0, _controller.position.maxScrollExtent));
  }

  /// The indices of the values a key may land on.
  List<int> get _enabled => <int>[
    for (int i = 0; i < widget.values.length; i++)
      if (widget.enabledOf(widget.values[i])) i,
  ];

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final List<int> enabled = _enabled;
    if (enabled.isEmpty) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    final int current = widget.values.indexOf(widget.selected);
    if (key == LogicalKeyboardKey.arrowDown) {
      final int? next = enabled.where((int i) => i > current).firstOrNull;
      if (next != null) {
        widget.onSelected(widget.values[next]);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      final int? prev = enabled.where((int i) => i < current).lastOrNull;
      if (prev != null) {
        widget.onSelected(widget.values[prev]);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      widget.onSelected(widget.values[enabled.first]);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      widget.onSelected(widget.values[enabled.last]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  String _labelOf(int value) {
    final String digits = widget.padded
        ? value.toString().padLeft(2, '0')
        : value.toString();
    return DabblerType.toWesternDigits(digits);
  }

  @override
  Widget build(BuildContext context) {
    final List<DabblerMenuEntry> entries = <DabblerMenuEntry>[
      for (final int value in widget.values)
        DabblerMenuEntry(
          id: '$value',
          label: _labelOf(value),
          selected: value == widget.selected,
          disabled: !widget.enabledOf(value),
        ),
    ];

    // The ring is driven by this widget's own [Focus] rather than by a
    // self-driven [DabblerFocusRing]: the column is one focus stop, and it has
    // to be *this* node that receives the key events, so the ring cannot be
    // the thing that owns focus.
    return Listener(
      // Pointer-down focus: a pointer user who taps into a column can then
      // arrow through it, which is what a native `<select>` does and what
      // makes the keyboard path reachable without a Tab-from-the-top.
      onPointerDown: (PointerDownEvent _) => _node.requestFocus(),
      child: Focus(
        focusNode: _node,
        onKeyEvent: _handleKey,
        onFocusChange: (bool focused) => setState(() => _focused = focused),
        child: DabblerFocusRing.visible(
          visible: _focused,
          borderRadius: DabblerRadius.lgAll,
          child: SizedBox(
            height: _ValueColumn.rowExtent * widget.visibleRows,
            // [DabblerMenuList.controller] hands this controller straight to
            // the list's internal `SingleChildScrollView`, which is what lets
            // [_revealSelected] move it. This used to go through a
            // [PrimaryScrollController] wrapper with
            // `automaticallyInheritForPlatforms: TargetPlatform.values` — the
            // list had no controller parameter of its own, so the only route
            // in was ambient inheritance. KAN-278 added the parameter and the
            // wrapper came out with it: the composer now drives the list
            // directly, which is the composition this widget was designed for.
            child: DabblerMenuList(
              items: entries,
              controller: _controller,
              label: widget.label,
              role: DabblerMenuRole.listbox,
              // The column draws no card of its own: it sits inside the
              // picker's card, exactly as a list inside a Sheet does
              // (`DabblerMenuList.decorated`). This also keeps every row at
              // exactly `rowExtent`, which [_revealSelected] depends on.
              decorated: false,
              autofocus: false,
              onSelected: (DabblerMenuEntry entry) =>
                  widget.onSelected(int.parse(entry.id!)),
            ),
          ),
        ),
      ),
    );
  }
}
