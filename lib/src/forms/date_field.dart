import 'package:flutter/widgets.dart';

import '../tokens/dabbler_type.dart';
import 'picker_field.dart';

/// A date span — the port of `DateField`'s `[Date | null, Date | null]`
/// (`DateField.d.ts:5`).
///
/// Flutter's own `DateTimeRange` cannot express it: both of its ends are
/// non-null, and the source's whole range interaction depends on a half-open
/// span existing between the first tap and the second (`DateField.jsx:109-115`
/// — *"first tap sets the start, second the end"*).
@immutable
class DabblerDateSpan {
  /// Creates a span. Both ends are optional and independent.
  const DabblerDateSpan({this.start, this.end});

  /// The empty span — `[null, null]` in the source.
  static const DabblerDateSpan empty = DabblerDateSpan();

  /// The first date, or null while nothing is chosen.
  final DateTime? start;

  /// The second date, or null while only the start is chosen.
  final DateTime? end;

  /// Whether neither end is set.
  bool get isEmpty => start == null && end == null;

  @override
  bool operator ==(Object other) =>
      other is DabblerDateSpan && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DabblerDateSpan($start, $end)';
}

/// The date half of the formatting layer (AC1) and of the numerals rule (AC2).
///
/// Every method here is pure, so a consumer — including DS-806's calendar
/// overlay — can format and parse without building a widget.
///
/// ## Western Arabic numerals, regardless of locale (AC2)
///
/// `DateField.prompt.md` → *"The date string itself keeps `DD/MM/YYYY` order
/// with Western Arabic numerals in both scripts"*, and `fields.card.html:183`
/// → *"Numerals are Western Arabic (0–9) in both scripts throughout"*. That is
/// DS-103a's rule as [DabblerType.toWesternDigits] states it, and it is
/// enforced on **both** directions of the layer, not just one:
///
/// * **Out** — [format] builds the string from `int.toString()`, which is
///   ASCII by construction in Dart whatever the ambient locale, and then passes
///   it through [DabblerType.toWesternDigits] anyway so the guarantee is a
///   property of this function rather than of the platform. Nothing here goes
///   near `intl`'s `DateFormat`, whose output under an `ar` locale with the
///   `arab` numbering system is `٠٥/٠٩/٢٠٢٦` — the exact failure AC2 names.
/// * **In** — [parse] folds Arabic-Indic (`٠`–`٩`) and extended Arabic-Indic
///   (`۰`–`۹`) digits to Western ones *before* matching, so a user on an Arabic
///   keyboard can type a date that the field then re-renders in `0`-`9`.
///
/// The render half of the rule — the font features that stop an Arabic-aware
/// face substituting Indic forms at draw time — is already carried by every
/// resolved [DabblerType] style ([DabblerType.numeralFeatures]), which is what
/// [DabblerDateField] paints its value with.
/// ## Provenance
///
/// `components/forms/forms-pickers.card.html` was read and is **not** a source
/// for this ticket: its first line marks it `source-only (consolidated into
/// components/forms/value-controls.card.html)` and its subtitle says in so many
/// words that *"CodeInput, DateField and TimeField live in the Fields & text
/// inputs reference"* — i.e. `fields.card.html`, which is what this file is
/// transcribed from instead, together with `DateField.jsx`, `DateField.d.ts`,
/// `DateField.prompt.md`, `PickerField.jsx` and `PickerField.prompt.md`.
abstract final class DabblerDateFormat {
  const DabblerDateFormat._();

  /// The single-value placeholder — `DateField.jsx:36`.
  static const String placeholder = 'DD/MM/YYYY';

  /// The en-dash-joined range placeholder — `DateField.jsx:36`.
  static const String rangePlaceholder = 'DD/MM/YYYY – DD/MM/YYYY';

  /// The separator a formatted range is joined with — `' – '`, an en dash
  /// (U+2013) with a space on each side (`DateField.jsx:45`).
  static const String rangeJoiner = ' – ';

  /// The two-digit-year pivot. `DateField.jsx:20` — `2000 + Number(m[3])`,
  /// unconditionally, so `26` is 2026 and `99` is 2099.
  static const int twoDigitYearBase = 2000;

  /// `DD/MM/YYYY` in Western Arabic numerals, or `''` for null.
  ///
  /// `DateField.jsx:15-16` — `pad(getDate())/pad(getMonth()+1)/getFullYear()`.
  /// The day and month are zero-padded to two; the year is not padded, which
  /// matches the source exactly.
  static String format(DateTime? date) {
    if (date == null) {
      return '';
    }
    final String out = '${_pad(date.day)}/${_pad(date.month)}/${date.year}';
    return DabblerType.toWesternDigits(out);
  }

  /// A span as `DD/MM/YYYY – DD/MM/YYYY`, dropping an unset end.
  ///
  /// `DateField.jsx:44-46` — `[fmt(a), fmt(b)].filter(Boolean).join(' – ')`,
  /// so a half-chosen range renders as the start alone with no dangling dash.
  static String formatSpan(DabblerDateSpan span) => <String>[
        format(span.start),
        format(span.end),
      ].where((String s) => s.isNotEmpty).join(rangeJoiner);

  /// `DD/MM/YYYY`, `.` or `-` separators, and a two-digit year — or null.
  ///
  /// `DateField.jsx:18-24`. The regexp is transcribed character for character:
  /// one or two digits, a `/`, `.` or `-` with optional space either side, one
  /// or two digits, the same separator class, then two to four digits.
  ///
  /// Returns null for anything else, which is what makes the field's *revert*
  /// behaviour possible: `DateField.jsx:56` and `:70` restore the displayed
  /// value rather than clearing it when a parse fails.
  ///
  /// A parse that rolls over — `32/01/2026` — is rejected rather than silently
  /// becoming `01/02/2026`. **Documented deviation:** JavaScript's
  /// `new Date(y, m, d)` normalises out-of-range components and only
  /// `Number.isNaN` catches a total failure, so the source accepts `32/01/2026`
  /// as 1 February. Dart's [DateTime] normalises identically, so the round-trip
  /// check below is what the source's `Number.isNaN(d.getTime())` was reaching
  /// for; keeping the silent roll-over would let `min`/`max` be walked past by
  /// typing a day number that does not exist.
  static DateTime? parse(String input) {
    final RegExpMatch? m = _datePattern.firstMatch(
      DabblerType.toWesternDigits(input).trim(),
    );
    if (m == null) {
      return null;
    }
    final String rawYear = m.group(3)!;
    final int year = rawYear.length == 2
        ? twoDigitYearBase + int.parse(rawYear)
        : int.parse(rawYear);
    final int month = int.parse(m.group(2)!);
    final int day = int.parse(m.group(1)!);
    final DateTime parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }

  /// A typed range — two dates around an en dash, an em dash or a spaced
  /// hyphen. `DateField.jsx:52` splits on `/[–—]|(?:\s-\s)/`.
  ///
  /// The spaced hyphen must stay spaced, or `05-09-2026` would split into
  /// nonsense before [parse] ever saw it.
  static DabblerDateSpan parseSpan(String input) {
    final List<String> parts = DabblerType.toWesternDigits(
      input,
    ).split(_rangeSplitPattern);
    return DabblerDateSpan(
      start: parts.isEmpty ? null : parse(parts[0]),
      end: parts.length > 1 ? parse(parts[1]) : null,
    );
  }

  /// Whether [date] sits inside `min`/`max`, both inclusive.
  ///
  /// `DateField.jsx:58` — `(!min || d >= min) && (!max || d <= max)`.
  static bool inBounds(DateTime date, {DateTime? min, DateTime? max}) =>
      (min == null || !date.isBefore(min)) &&
      (max == null || !date.isAfter(max));

  static String _pad(int n) => n.toString().padLeft(2, '0');

  static final RegExp _datePattern = RegExp(
    r'^(\d{1,2})\s*[/.-]\s*(\d{1,2})\s*[/.-]\s*(\d{2,4})$',
  );

  static final RegExp _rangeSplitPattern = RegExp(r'[–—]|\s-\s');
}

/// DateField — a date, or a date range, typed or picked.
///
/// Transcribed from `components/forms/DateField.jsx`, `DateField.d.ts`,
/// `DateField.prompt.md` and `components/forms/fields.card.html:128-137`.
///
/// ```dart
/// DabblerDateField(
///   label: 'game date',
///   value: date,
///   minimum: DateTime.now(),
///   onChanged: (DateTime? next) => setState(() => date = next),
///   open: pickerOpen,
///   onOpenPicker: () => setState(() => pickerOpen = !pickerOpen),
/// )
/// ```
///
/// ## What this widget is, and what DS-806 adds
///
/// This is the **field**: the box, the typed entry, the `DD/MM/YYYY`
/// formatting layer, the bounds check, the states, and the callback that asks
/// for a picker. It deliberately contains **no calendar** — DS-806 owns
/// `Calendar`, and `DateField.prompt.md` is explicit that the `Calendar` is
/// *"used as-is — do not fork it for a field-specific variant"*, which is only
/// possible if the field does not carry one.
///
/// The seam DS-806 attaches to is three members, and nothing else:
///
/// * [onOpenPicker] — fired by the trailing button. The consumer opens
///   whatever surface it likes there (`PickerField.jsx:75-96` is a `Sheet`
///   below 480px and an anchored `Menu` above it; `DabblerMenuList` is the
///   reusable list body for the latter).
/// * [open] — told back to the field, so the border holds the focus state
///   (`focused || open`) and the button reports `aria-expanded` while the
///   surface is up.
/// * [onChanged] / [onSpanChanged] — the calendar reports a chosen date
///   through the same callback typing does, so the field has one value path
///   and not two.
///
/// Formatting and parsing are [DabblerDateFormat], which is pure and public:
/// DS-806 can render a chosen date in the field's own format without holding
/// a field.
///
/// ## Bounds
///
/// [minimum] and [maximum] are enforced on the typed path here
/// (`DateField.jsx:59-72` — an out-of-bounds parse reverts rather than
/// commits). The picked path is enforced by whoever owns the picker, which is
/// the source's arrangement too (`DateField.jsx:100`).
class DabblerDateField extends StatefulWidget {
  /// A single date.
  const DabblerDateField({
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
  })  : range = false,
        span = DabblerDateSpan.empty,
        onSpanChanged = null;

  /// A date range: `DD/MM/YYYY – DD/MM/YYYY`.
  ///
  /// `DateField.d.ts:8` — *"Two-date selection: first tap sets the start, the
  /// second the end."* Split from the default constructor rather than made a
  /// `range` boolean over a dynamically-typed `value`, because Dart has no
  /// `Date | [Date, Date]` and a caller should not have to cast.
  const DabblerDateField.range({
    super.key,
    this.span = DabblerDateSpan.empty,
    this.onSpanChanged,
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
  })  : range = true,
        value = null,
        onChanged = null;

  /// `icon="calendar"` — `DateField.jsx:120`.
  static const String iconName = 'calendar';

  /// Whether this is the range form.
  final bool range;

  /// The chosen date. Single form only.
  final DateTime? value;

  /// Called when the typed value commits to a new date, or clears to null.
  /// Single form only.
  final ValueChanged<DateTime?>? onChanged;

  /// The chosen span. Range form only.
  final DabblerDateSpan span;

  /// Called when the typed value commits to a new span. Range form only.
  final ValueChanged<DabblerDateSpan>? onSpanChanged;

  /// The earliest acceptable date, inclusive. `min` in the source.
  final DateTime? minimum;

  /// The latest acceptable date, inclusive. `max` in the source.
  final DateTime? maximum;

  /// The label above the box.
  final String? label;

  /// The helper line below the box.
  final String? helperText;

  /// The error line below the box.
  final String? errorText;

  /// Whether the field accepts input.
  final bool enabled;

  /// The empty-state text. Defaults to [DabblerDateFormat.placeholder], or
  /// [DabblerDateFormat.rangePlaceholder] in the range form
  /// (`DateField.jsx:36`).
  final String? placeholder;

  /// Whether the caller's picker surface is open.
  final bool open;

  /// Fired by the trailing button. The picker surface is the caller's.
  final VoidCallback? onOpenPicker;

  /// An external focus node.
  final FocusNode? focusNode;

  /// The value as the field displays it, for the current form.
  String get displayText => range
      ? DabblerDateFormat.formatSpan(span)
      : DabblerDateFormat.format(value);

  @override
  State<DabblerDateField> createState() => _DabblerDateFieldState();
}

class _DabblerDateFieldState extends State<DabblerDateField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.displayText);

  @override
  void didUpdateWidget(DabblerDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `React.useEffect(() => { setText(display); }, [display])`
    // (`DateField.jsx:51`) — the typed text follows the committed value, and
    // only the committed value.
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

  bool _inBounds(DateTime d) => DabblerDateFormat.inBounds(
        d,
        min: widget.minimum,
        max: widget.maximum,
      );

  /// `commitText` — `DateField.jsx:60-73`.
  void _commit(String raw) {
    if (raw.trim().isEmpty) {
      if (widget.range) {
        _report(
          !widget.span.isEmpty,
          () => widget.onSpanChanged?.call(DabblerDateSpan.empty),
        );
      } else {
        _report(widget.value != null, () => widget.onChanged?.call(null));
      }
      return;
    }

    if (widget.range) {
      final DabblerDateSpan typed = DabblerDateFormat.parseSpan(raw);
      final DateTime? a = typed.start;
      final DateTime? b = typed.end;
      if (a == null || !_inBounds(a)) {
        _revert();
        return;
      }
      final DateTime? okB = b != null && _inBounds(b) ? b : null;
      // `b && inBounds(b) && b < a ? [b, a] : [a, okB]` — a range typed
      // backwards is reordered, not rejected.
      final DabblerDateSpan next = okB != null && okB.isBefore(a)
          ? DabblerDateSpan(start: okB, end: a)
          : DabblerDateSpan(start: a, end: okB);
      _report(next != widget.span, () => widget.onSpanChanged?.call(next));
      return;
    }

    final DateTime? a = DabblerDateFormat.parse(raw);
    if (a != null && _inBounds(a)) {
      _report(a != widget.value, () => widget.onChanged?.call(a));
    } else {
      _revert();
    }
  }

  /// Fires [report] only when the commit is a real change.
  ///
  /// Enter commits, and then the blur that usually follows it commits the same
  /// text a second time (`PickerField.jsx:50` fires `onTextCommit` from both,
  /// and so does this shell). React's `setState` collapses the repeat; a Dart
  /// callback does not, so an unchanged value is dropped here instead — a
  /// consumer should never see two identical `onChanged` calls for one edit,
  /// and after a revert the value on screen *is* the current one.
  void _report(bool changed, VoidCallback report) {
    if (changed) {
      report();
    }
  }

  /// `setText(display)` — unparseable or out-of-bounds text is put back, never
  /// left standing and never cleared.
  void _revert() {
    final String display = widget.displayText;
    if (_controller.text != display) {
      _controller.text = display;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DabblerPickerFieldShell(
      controller: _controller,
      iconName: DabblerDateField.iconName,
      label: widget.label,
      placeholder: widget.placeholder ??
          (widget.range
              ? DabblerDateFormat.rangePlaceholder
              : DabblerDateFormat.placeholder),
      helperText: widget.helperText,
      errorText: widget.errorText,
      enabled: widget.enabled,
      open: widget.open,
      onOpenPressed: widget.onOpenPicker,
      onCommit: _commit,
      focusNode: widget.focusNode,
    );
  }
}
