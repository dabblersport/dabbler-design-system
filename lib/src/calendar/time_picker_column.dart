/// Part of the `time_picker.dart` library — one listbox value column ([_ValueColumn]) of [DabblerTimePicker].
///
/// **Why `part`, not a separate library.** Keeps `time_picker.dart` under the
/// project's 500-line house rule (`013`). The declarations are the pre-rewrite
/// ones (commit `9ed2a55`); `part`/`part of` keeps one logical library, so
/// private names stay private and no public API changes. The imports are the
/// library's.
part of 'time_picker.dart';

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
  /// `TimePicker.jsx:59` pads **both** columns — `String(c.val).padStart(2,
  /// '0')`. The hour column is not padded here, so the column and
  /// [DabblerTimeFormat.format] agree: that formatter prints `7:05 PM`, not
  /// `07:05 PM` (`TimeField.jsx:12` — the hour is not padded), and a picker
  /// showing `07` beside a field showing `7` is two formats for one value.
  final bool padded;

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
  /// contexts. Every row is exactly [DabblerTimePicker.rowExtent] tall — a
  /// [DabblerMenuItem]'s `minHeight`, asserted by the tests — so the offset is
  /// an index times that, clamped to the real extent.
  void _revealSelected() {
    if (!_controller.hasClients) {
      return;
    }
    final int index = widget.values.indexOf(widget.selected);
    if (index < 0) {
      return;
    }
    final double centred =
        (index - (widget.visibleRows - 1) / 2) * DabblerTimePicker.rowExtent;
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
            height: DabblerTimePicker.rowExtent * widget.visibleRows,
            // [DabblerMenuList.controller] hands this controller straight to
            // the list's internal `SingleChildScrollView`, which is what lets
            // [_revealSelected] move it.
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
