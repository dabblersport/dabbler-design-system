import 'package:flutter/services.dart' show KeyDownEvent, KeyEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../overlays/menu.dart';
import '../tokens/dabbler_geometry.dart';
import 'text_field.dart';

/// One row of a [DabblerSelect]'s option list.
///
/// Transcribed from `components/forms/Select.d.ts:3-10` — *"value, label,
/// icon, disabled"*. [icon] is the kebab-case Iconsax name the source
/// documents as *"shown leading in the option list"*, which is exactly
/// [DabblerMenuEntry.icon].
@immutable
class DabblerSelectOption<T> {
  /// Creates an option.
  const DabblerSelectOption({
    required this.value,
    required this.label,
    this.icon,
    this.disabled = false,
  });

  /// The value handed back to `onChanged`.
  final T value;

  /// The row's text, and the field's display text once chosen.
  ///
  /// `Select.d.ts:5` types this `ReactNode`; here it is a [String], because
  /// [DabblerMenuEntry.label] is a [String] and the type-ahead in DS-700
  /// matches on it. A row that cannot be typed at is a row the source's own
  /// keyboard contract cannot reach.
  final String label;

  /// Kebab-case Iconsax name, drawn leading in the option list.
  final String? icon;

  /// Skipped by the arrows and type-ahead, but kept in the list — DS-700's
  /// contract, inherited rather than restated.
  final bool disabled;
}

/// Select — choosing from a known list of options, single or multiple.
///
/// Transcribed from `components/forms/Select.jsx:1-96`, `Select.d.ts`,
/// `Select.prompt.md` and the specimens `components/forms/fields.card.html`
/// (lines 104-113) and `forms.card.html:38-42`.
///
/// ```dart
/// DabblerSelect<String>(
///   label: 'sport',
///   value: sport,
///   onChanged: (String? v) => setState(() => sport = v),
///   options: const <DabblerSelectOption<String>>[
///     DabblerSelectOption<String>(value: 'padel', label: 'padel'),
///     DabblerSelectOption<String>(value: 'tennis', label: 'tennis'),
///   ],
/// )
/// ```
///
/// ## It composes; it restates nothing
///
/// `Select.prompt.md` — *Composition rules*: *"`Select` = `TextField` shell +
/// `Menu`. If you need a different picker (date, time, duration), compose the
/// same two rather than forking either."* So this file contains **no box
/// geometry and no list keyboard**:
///
/// * The closed state is [DabblerTextField] with
///   [DabblerTextFieldVariant.select] — DS-600. That is where the 45px
///   minimum height, the `--radius-xxl` corners, the 1px hairline, the four
///   border states, the `focused || open` rule, the ellipsis truncation and
///   the rotating `arrow-down` live. Not one of them is re-expressed here.
/// * The option list is [DabblerMenu] — DS-700. That is where viewport-aware
///   flipping, outside-click dismissal, Escape, roving arrow-key focus with
///   wrap, Home/End, type-ahead, disabled-row skipping and **the switch to a
///   `Sheet` below 480px** live. Not one of them is re-expressed here
///   either.
///
/// `test/forms/select_test.dart` proves both halves of that by widget type,
/// so a future fork fails the build rather than the eye.
///
/// ## Why [DabblerMenu] and not [DabblerMenuList]
///
/// DS-700 offers both, and the choice is deliberate. `Select.jsx:63-95` wraps
/// the whole field in `<Menu fullWidth open closeOnSelect header trigger …>`
/// and passes **no `role`**, so the list is the default `role="menu"`, which
/// `fields.card.html:113` states outright: *"the list is `role="menu"` with
/// `role="menuitem"` options carrying `aria-checked` when selected"*.
/// [DabblerMenuList] alone would mean owning the popover, its anchoring, its
/// dismissal and the sheet breakpoint — a second popover, which
/// `Menu.prompt.md` forbids — and, at [DabblerMenuRole.listbox], driving the
/// roving focus by hand.
///
/// **This deviates from DS-700's own dartdoc**, which says `Select` composes
/// the list at [DabblerMenuRole.listbox]. The design source is the authority
/// the brief names, and it says `menu`; the widened surface DS-700 built for
/// a listbox composer is still right for `TimePicker`, which genuinely owns
/// its own container.
///
/// ## Keyboard
///
/// `Select.prompt.md` — *Accessibility*: *"focus field → Enter/Space opens →
/// arrows move → Enter selects → Escape closes"*. The middle three are the
/// menu's. This widget owns only the first: [DabblerTextField]'s `select`
/// shell is a tap target, not a focus stop, so [DabblerSelect] supplies the
/// [FocusNode] and opens on Enter, Space, ArrowDown or ArrowUp. Escape is the
/// menu's; what this widget adds is the return trip — focus comes back to the
/// field whenever the list closes, so the next Tab continues from the field
/// rather than from the top of the form.
///
/// ## Single and multiple
///
/// The source carries one `value` prop that *"is an array when `multiple`"*
/// (`Select.d.ts:14`). Dart has no such union, so the two are two
/// constructors: [DabblerSelect.new] with `value`/`onChanged`, and
/// [DabblerSelect.multiple] with `values`/`onChangedAll`. The behavioural
/// difference is the source's: multiple keeps the list open
/// (`closeOnSelect={!multiple}`, `Select.jsx:69`) and toggles membership;
/// single closes and replaces.
///
/// ## RTL
///
/// Nothing in this file is sided. The arrow, the option alignment and the
/// popover's inline flip are DS-600's and DS-700's; the multi-value display
/// joins with `', '`, which `Select.prompt.md` — *RTL behaviour* — states
/// *"reads correctly in both directions"*.
class DabblerSelect<T> extends StatefulWidget {
  /// A single-value select.
  const DabblerSelect({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.label,
    this.placeholder = defaultPlaceholder,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.searchable = false,
    this.searchPlaceholder = defaultSearchPlaceholder,
  }) : multiple = false,
       values = const <Never>[],
       onChangedAll = null;

  /// A multi-value select: the list stays open and chosen rows show a tick.
  const DabblerSelect.multiple({
    super.key,
    required this.options,
    this.values = const <Never>[],
    this.onChangedAll,
    this.label,
    this.placeholder = defaultPlaceholder,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.searchable = false,
    this.searchPlaceholder = defaultSearchPlaceholder,
  }) : multiple = true,
       value = null,
       onChanged = null;

  /// `placeholder = 'select'` (`Select.jsx:19`).
  static const String defaultPlaceholder = 'select';

  /// `placeholder="search"` on the searchable header's field
  /// (`Select.jsx:76`).
  static const String defaultSearchPlaceholder = 'search';

  /// The rows, in order.
  final List<DabblerSelectOption<T>> options;

  /// The chosen value of a single-value select.
  final T? value;

  /// Called with the newly chosen value.
  final ValueChanged<T>? onChanged;

  /// The chosen values of a [DabblerSelect.multiple].
  final List<T> values;

  /// Called with the whole next selection — the source passes the array back,
  /// not the delta (`Select.jsx:48-51`).
  final ValueChanged<List<T>>? onChangedAll;

  /// Whether this is the multi-value form.
  final bool multiple;

  /// The label above the field.
  final String? label;

  /// Empty-state text, in `--color-text-tertiary`.
  final String placeholder;

  /// The helper line below the field.
  final String? helperText;

  /// The error line, and the trigger for the error border.
  final String? errorText;

  /// Whether the field opens. `false` is the source's `disabled`.
  final bool enabled;

  /// Adds a search field above the option list and filters by label
  /// (`Select.jsx:39-41`). `Select.prompt.md` asks for it at 8+ options.
  final bool searchable;

  /// The search field's placeholder.
  final String searchPlaceholder;

  /// The field's display text for [selected] — the source's `display`
  /// (`Select.jsx:34-37`).
  ///
  /// Public and pure so the join rule is testable without pumping a frame:
  /// an unknown value falls back to its own `toString`, which is the source's
  /// `hit ? hit.label : v`.
  static String displayOf<T>(
    List<DabblerSelectOption<T>> options,
    List<T> selected,
  ) => selected.map((T v) => labelOf<T>(options, v)).join(', ');

  /// The label of [value] among [options], or its `toString`
  /// (`Select.jsx:29-32`).
  static String labelOf<T>(List<DabblerSelectOption<T>> options, T value) {
    for (final DabblerSelectOption<T> option in options) {
      if (option.value == value) {
        return option.label;
      }
    }
    return '$value';
  }

  @override
  State<DabblerSelect<T>> createState() => _DabblerSelectState<T>();
}

class _DabblerSelectState<T> extends State<DabblerSelect<T>> {
  /// The field's own focus. [DabblerTextField] listens to it for the focus
  /// ring; the [Focus] below makes it a real focus stop, which the `select`
  /// shell alone is not.
  final FocusNode _fieldFocus = FocusNode(debugLabel: 'DabblerSelect field');

  bool _open = false;
  String _query = '';

  @override
  void dispose() {
    _fieldFocus.dispose();
    super.dispose();
  }

  List<T> get _selected =>
      widget.multiple ? widget.values : <T>[if (widget.value != null) widget.value as T];

  bool _isOn(T value) => _selected.contains(value);

  /// `Select.jsx:43-52` — single replaces, multiple toggles membership.
  void _pick(DabblerSelectOption<T> option) {
    if (!widget.multiple) {
      widget.onChanged?.call(option.value);
      return;
    }
    final List<T> next = <T>[
      for (final T v in widget.values)
        if (v != option.value) v,
      if (!_isOn(option.value)) option.value,
    ];
    widget.onChangedAll?.call(next);
  }

  /// `onOpenChange={(v) => { setOpen(v); if (!v) setQuery(''); }}`
  /// (`Select.jsx:67`), plus the focus return the web gets for free from the
  /// browser restoring focus to the trigger.
  void _setOpen(bool value) {
    if (_open == value) {
      return;
    }
    setState(() {
      _open = value;
      if (!value) {
        _query = '';
      }
    });
    if (!value) {
      _fieldFocus.requestFocus();
    }
  }

  KeyEventResult _handleFieldKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _open || !widget.enabled) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      _setOpen(true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// `Select.jsx:39-41` — filtered by label, case-insensitively, only while a
  /// query is typed.
  List<DabblerSelectOption<T>> get _shown {
    if (!widget.searchable || _query.isEmpty) {
      return widget.options;
    }
    final String needle = _query.toLowerCase();
    return <DabblerSelectOption<T>>[
      for (final DabblerSelectOption<T> option in widget.options)
        if (option.label.toLowerCase().contains(needle)) option,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = !widget.enabled;
    final List<DabblerMenuEntry> items = <DabblerMenuEntry>[
      for (final DabblerSelectOption<T> option in _shown)
        DabblerMenuEntry(
          label: option.label,
          id: '${option.value}',
          icon: option.icon,
          disabled: option.disabled,
          selected: _isOn(option.value),
          onSelect: (DabblerMenuEntry _) => _pick(option),
        ),
    ];

    final Widget field = Focus(
      focusNode: _fieldFocus,
      onKeyEvent: _handleFieldKey,
      child: DabblerTextField(
        variant: DabblerTextFieldVariant.select,
        label: widget.label,
        value: DabblerSelect.displayOf<T>(widget.options, _selected),
        placeholder: widget.placeholder,
        helperText: widget.helperText,
        errorText: widget.errorText,
        enabled: widget.enabled,
        // `open={open && !disabled}` (`Select.jsx:88`).
        open: _open && !disabled,
        focusNode: _fieldFocus,
        onPressed: disabled
            ? null
            : () {
                _fieldFocus.requestFocus();
                _setOpen(!_open);
              },
      ),
    );

    return DabblerMenu(
      // `fullWidth` — the dropdown is the width of the field (`Select.jsx:65`).
      fullWidth: true,
      open: _open && !disabled,
      onOpenChanged: _setOpen,
      // `closeOnSelect={!multiple}` (`Select.jsx:69`).
      closeOnSelect: !widget.multiple,
      label: widget.label,
      items: items,
      header: widget.searchable ? _searchHeader() : null,
      trigger: field,
    );
  }

  /// `Select.jsx:74-79` — a `TextField variant="search"` above the list, in
  /// `--space-1 --space-1 --space-2` padding.
  Widget _searchHeader() => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(
      DabblerSpacing.space1,
      DabblerSpacing.space1,
      DabblerSpacing.space1,
      DabblerSpacing.space2,
    ),
    child: DabblerTextField(
      variant: DabblerTextFieldVariant.search,
      placeholder: widget.searchPlaceholder,
      onChanged: (String v) => setState(() => _query = v),
    ),
  );
}
