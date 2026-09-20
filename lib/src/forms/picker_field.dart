/// PickerField — the typed-or-picked field, and the shell every one of them
/// paints from.
///
/// This library is split across two files under KAN-277, purely for the
/// 500-line house rule: [DabblerPickerFieldShell] and its trailing button live
/// in `picker_field_shell.dart`, which is a `part` of this library rather than
/// a library of its own, so nothing that was private became public. Nothing
/// else moved and no public API changed.
library;

import 'package:flutter/material.dart'
    show InputBorder, InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart' show TextInputAction, TextInputType;
import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../overlays/menu.dart';
import '../overlays/sheet.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'date_field.dart';
import 'field_shell.dart';
import 'time_field.dart';

part 'picker_field_shell.dart';

/// PickerField — [DabblerPickerFieldShell] plus the responsive presentation
/// of the picker.
///
/// Transcribed from `components/forms/PickerField.jsx:1-119`,
/// `PickerField.d.ts`, `PickerField.prompt.md` and the specimen
/// `components/forms/fields.card.html:115-123`.
///
/// The shell above is the box and the typed input — the half `DateField` and
/// `TimeField` use, because each of those owns its own picker surface. This
/// widget is that shell **plus** the presentation branch the source writes at
/// `PickerField.jsx:97-118`: a [DabblerSheet] below
/// [DabblerMenu.sheetBreakpoint] and an anchored [DabblerMenu] above it, so a
/// call site that does not want to own an overlay does not have to. Both
/// halves are DS-700's, not a second popover and not a second sheet.
///
/// It is a composition primitive, not a screen control
/// (`PickerField.prompt.md` — *When not to use*). Why it is not
/// `TextField(variant: select)` is set out on the shell.
///
/// ```dart
/// DabblerPickerField(
///   label: 'Date',
///   text: typed,
///   onTextChanged: (String v) => setState(() => typed = v),
///   onTextCommitted: parse,
///   open: open,
///   onOpenChanged: (bool v) => setState(() => open = v),
///   child: const Placeholder(),          // the picker itself
/// )
/// ```
///
/// ## One way to open it
///
/// `PickerField.prompt.md` — *Composition rules*: *"Do not add a second way
/// to open the picker (e.g. opening on focus) — typing must stay possible."*
/// [DabblerMenu] toggles on any tap on its trigger, so this field turns that
/// off with [DabblerMenu.openOnTriggerTap] `false` and opens only from the
/// trailing button, which calls [onOpenChanged] itself. A tap on the input or
/// on blank shell area focuses the input instead.
///
/// It used to rely on an absorbing [GestureDetector] winning the gesture arena
/// instead. That stopped being a mechanism under KAN-286, where the menu's
/// wrapper became a [Listener] — which takes pointer events without entering
/// the arena and so cannot be absorbed. The intent is unchanged and is now
/// stated rather than inferred from gesture precedence.
class DabblerPickerField extends StatefulWidget {
  /// Creates a picker field.
  const DabblerPickerField({
    super.key,
    this.label,
    this.text = '',
    this.placeholder,
    this.onTextChanged,
    this.onTextCommitted,
    this.icon = defaultIcon,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.open = false,
    this.onOpenChanged,
    this.sheetTitle,
    this.detents = defaultDetents,
    this.openLabel = DabblerPickerFieldShell.defaultOpenSemanticsLabel,
    this.closeLabel = DabblerPickerFieldShell.defaultCloseSemanticsLabel,
    this.child,
  });

  /// `icon = 'calendar'` (`PickerField.jsx:25`).
  static const String defaultIcon = 'calendar';

  /// `detents = [0.62]` (`PickerField.jsx:31`) — taller than Menu's 0.45,
  /// because a calendar needs the room.
  static const List<double> defaultDetents = <double>[0.62];

  /// The key the trailing target carries; [DabblerPickerFieldShell]'s.
  static const Key trailingButtonKey =
      DabblerPickerFieldShell.pickerButtonKey;

  /// The label above the box.
  final String? label;

  /// The typed text shown in the field.
  final String text;

  /// The empty-state text.
  final String? placeholder;

  /// Called on every keystroke.
  final ValueChanged<String>? onTextChanged;

  /// Called on blur and on Enter — *"parse the typed text here"*
  /// (`PickerField.d.ts:10`).
  final ValueChanged<String>? onTextCommitted;

  /// Kebab-case Iconsax name for the trailing button.
  final String icon;

  /// The helper line; replaced by [errorText], which also draws the error
  /// border. Both are [DabblerFieldShell]'s.
  final String? helperText;

  /// The error line, and the trigger for the error border.
  final String? errorText;

  /// Whether the field accepts input and opens. `false` is `disabled`.
  final bool enabled;

  /// Whether the picker is showing. Controlled, as in the source.
  final bool open;

  /// Reports every open and close.
  final ValueChanged<bool>? onOpenChanged;

  /// The sheet's title below the breakpoint; falls back to [label].
  final String? sheetTitle;

  /// The sheet's detents.
  final List<double> detents;

  /// The trailing button's accessible name while closed.
  final String openLabel;

  /// The trailing button's accessible name while open.
  final String closeLabel;

  /// The picker itself — a `Calendar`, a `TimePicker`, anything.
  final Widget? child;

  @override
  State<DabblerPickerField> createState() => _DabblerPickerFieldState();
}

class _DabblerPickerFieldState extends State<DabblerPickerField> {
  final FocusNode _inputFocus = FocusNode(
    debugLabel: 'DabblerPickerField input',
  );
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );
  final OverlayPortalController _sheetPortal = OverlayPortalController();

  /// The text last handed to [DabblerPickerField.onTextCommitted]; cleared by
  /// the next edit.
  ///
  /// The source commits on Enter *and* on blur (`PickerField.jsx:56,58`), and
  /// on the web those are two different moments. In Flutter, submitting the
  /// keyboard action also drops focus, so the shell would parse the same text
  /// twice. Committing the same string twice is the deviation, not the guard.
  String? _committed;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleEdit);
    // Shown after the first frame, never during one.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted && !_sheetPortal.isShowing) {
        _sheetPortal.show();
      }
    });
  }

  @override
  void didUpdateWidget(DabblerPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The text is the owner's; the controller only mirrors it, so a commit
    // that reformats ("6pm" → "6:00 PM") shows without the field owning state.
    if (widget.text != _controller.text && !_inputFocus.hasFocus) {
      _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleEdit);
    _controller.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  /// The shell owns the input, so per-keystroke reporting is read off the
  /// controller rather than duplicating its `onChanged`.
  void _handleEdit() {
    if (_controller.text == _committed) {
      return;
    }
    _committed = null;
    widget.onTextChanged?.call(_controller.text);
  }

  void _commit(String text) {
    if (_committed == text) {
      return;
    }
    _committed = text;
    widget.onTextCommitted?.call(text);
  }

  void _toggle() {
    if (!widget.enabled) {
      return;
    }
    widget.onOpenChanged?.call(!widget.open);
  }

  void _close() => widget.onOpenChanged?.call(false);

  @override
  Widget build(BuildContext context) {
    final bool asSheet =
        MediaQuery.sizeOf(context).width < DabblerMenu.sheetBreakpoint;

    final Widget field = DabblerPickerFieldShell(
      controller: _controller,
      focusNode: _inputFocus,
      iconName: widget.icon,
      label: widget.label,
      placeholder: widget.placeholder,
      helperText: widget.helperText,
      errorText: widget.errorText,
      enabled: widget.enabled,
      open: widget.open,
      onOpenPressed: _toggle,
      onCommit: _commit,
      openPickerSemanticsLabel: widget.openLabel,
      closePickerSemanticsLabel: widget.closeLabel,
    );

    if (asSheet) {
      // The sheet paints its own full-viewport scrim and panel, so it cannot
      // be a sibling of the field in the layout — it would stretch the field
      // to the viewport. It goes in the [Overlay] instead, which is where the
      // source's fixed-position sheet effectively lives. The portal is shown
      // once and stays shown: [DabblerSheet] already renders itself away when
      // closed (`Visibility` + `IgnorePointer`), so nothing is ever toggled
      // during a build.
      return OverlayPortal(
        controller: _sheetPortal,
        overlayChildBuilder: (BuildContext _) => DabblerSheet(
          open: widget.open && widget.enabled,
          onClose: _close,
          title: widget.sheetTitle ?? widget.label,
          detents: widget.detents,
          child: widget.child,
        ),
        child: field,
      );
    }

    return DabblerMenu(
      // `fullWidth` (`PickerField.jsx:112`): the popover is the field's width.
      fullWidth: true,
      open: widget.open && widget.enabled,
      onOpenChanged: (bool v) => widget.onOpenChanged?.call(v),
      // See the class doc: only the trailing button opens this field.
      openOnTriggerTap: false,
      label: widget.label,
      // No rows: the picker is the whole content, which is what the menu's
      // header slot is — the same slot Select puts its search field in.
      items: const <DabblerMenuEntry>[],
      header: widget.child,
      trigger: GestureDetector(
        // The absorber described in the class doc: the menu must not open on
        // a tap anywhere on the field.
        behavior: HitTestBehavior.opaque,
        onTap: () => _inputFocus.requestFocus(),
        child: field,
      ),
    );
  }
}
