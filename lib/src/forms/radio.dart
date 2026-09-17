import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// Radio — the flat single-choice control.
///
/// Transcribed from `components/forms/Radio.jsx`, `Radio.d.ts`,
/// `Radio.prompt.md` and the *Radio* section of
/// `components/forms/selection.card.html`.
///
/// ```dart
/// for (final String level in levels)
///   DabblerRadio(
///     label: level,
///     selected: chosen == level,
///     onChanged: (_) => setState(() => chosen = level),
///   ),
/// ```
///
/// ## There is no radio group, and that is the design
///
/// *"Mutual exclusivity lives in that shared value, so **there is no
/// RadioGroup component**; a visual group is several Radios reading one piece
/// of state."* [onChanged] fires with `true` for the option that was tapped —
/// never with `false` — exactly as the source's `onChange(true)` does, because
/// a radio is deselected only by another one being selected.
///
/// ## Geometry
///
/// A 24px circle. Unselected: a [DabblerSizing.borderDefault]
/// [DabblerColors.borderDefault] ring. Selected: a 2px
/// [DabblerColors.brandPrimary] ring with a 9px brand dot
/// (`Radio.jsx:11-14`). The ring **thickens** on selection rather than
/// changing colour alone, which is why [selectedRingWidth] exists as its own
/// value; it is [DabblerFocusRing.ringWidth]'s number but not its meaning, so
/// it is declared here against the source rather than borrowed.
///
/// ## Row, target, RTL, keyboard
///
/// *"Accessibility: each control is `role="radio"` with `aria-checked` and
/// `aria-disabled`, focusable and 45px-tall like Checkbox. RTL: identical to
/// Checkbox — flow order plus a logical 12px gap."* Space or Enter selects;
/// the shared [DabblerFocusRing] traces the circle on keyboard focus only.
/// [Semantics.inMutuallyExclusiveGroup] is what makes assistive technology
/// announce it as a radio rather than a tick box.
class DabblerRadio extends StatefulWidget {
  /// Creates a controlled radio.
  const DabblerRadio({
    super.key,
    required this.selected,
    this.onChanged,
    this.disabled = false,
    this.label,
    this.semanticLabel,
  });

  /// Whether this option is the chosen one. Derived by the caller from the
  /// group's single value — this widget holds nothing.
  final bool selected;

  /// Called with `true` when this option is tapped. Never called with `false`:
  /// the source's handler is `() => onChange(true)`.
  final ValueChanged<bool>? onChanged;

  /// Whether the control is inert: 50% opacity, no click, no focus stop
  /// (`Radio.jsx:22`).
  final bool disabled;

  /// The optional trailing label, `.t-body` at [DabblerColors.textPrimary].
  final String? label;

  /// The accessible name when [label] is null or should differ.
  final String? semanticLabel;

  /// `width: 24, height: 24` (`Radio.jsx:11`) — [DabblerSizing.iconMd].
  static const double circleSize = DabblerSizing.iconMd;

  /// `width: 9, height: 9` on the selected dot (`Radio.jsx:14`). 9 is
  /// [DabblerSpacing.space3], so the dot is on the base-3 grid.
  static const double dotSize = DabblerSpacing.space3;

  /// `${selected ? 2 : 1}px solid …` (`Radio.jsx:13`) — the selected ring.
  static const double selectedRingWidth = 2;

  /// `opacity: disabled ? 0.5 : 1` (`Radio.jsx:22`).
  static const double disabledOpacity = 0.5;

  /// The ring colour: brand when selected, `--color-border-default` when not.
  static Color ringColorFor(DabblerColors colors, {required bool selected}) =>
      selected ? colors.brandPrimary : colors.borderDefault;

  /// The ring width: 2 when selected, [DabblerSizing.borderDefault] when not.
  static double ringWidthFor({required bool selected}) =>
      selected ? selectedRingWidth : DabblerSizing.borderDefault;

  @override
  State<DabblerRadio> createState() => _DabblerRadioState();
}

class _DabblerRadioState extends State<DabblerRadio> {
  bool _ringVisible = false;

  bool get _enabled => !widget.disabled && widget.onChanged != null;

  void _select() {
    if (!_enabled) {
      return;
    }
    widget.onChanged!(true);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    final Widget circle = DabblerFocusRing.visible(
      visible: _ringVisible,
      enabled: _enabled,
      borderRadius: DabblerRadius.pillAll,
      child: Container(
        width: DabblerRadio.circleSize,
        height: DabblerRadio.circleSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: DabblerRadio.ringColorFor(
              colors,
              selected: widget.selected,
            ),
            width: DabblerRadio.ringWidthFor(selected: widget.selected),
          ),
        ),
        child: widget.selected
            ? Container(
                width: DabblerRadio.dotSize,
                height: DabblerRadio.dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.brandPrimary,
                ),
              )
            : null,
      ),
    );

    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        circle,
        if (widget.label != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.stackDefault),
          Flexible(
            child: Text(
              widget.label!,
              style: DabblerType.body
                  .resolveForDirection(direction)
                  .copyWith(color: colors.textPrimary),
            ),
          ),
        ],
      ],
    );

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      checked: widget.selected,
      inMutuallyExclusiveGroup: true,
      enabled: _enabled,
      onTap: _enabled ? _select : null,
      container: true,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: _enabled,
          onShowFocusHighlight: (bool visible) {
            if (_ringVisible != visible) {
              setState(() => _ringVisible = visible);
            }
          },
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                _select();
                return null;
              },
            ),
          },
          mouseCursor:
              _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _enabled ? _select : null,
            child: Opacity(
              opacity: widget.disabled ? DabblerRadio.disabledOpacity : 1,
              child: ConstrainedBox(
                // `minHeight: var(--touch-target-min)` (`Radio.jsx:20`).
                constraints: const BoxConstraints(
                  minHeight: DabblerSizing.touchTargetMin,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  // `heightFactor: 1` keeps the row's own height: an [Align]
                  // otherwise grows to whatever space it is offered, which
                  // would turn the 45 floor into a 45 *minimum* on a box that
                  // has already filled the screen.
                  heightFactor: 1,
                  child: row,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
