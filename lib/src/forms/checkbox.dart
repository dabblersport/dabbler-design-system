import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// Checkbox — the flat selection control.
///
/// Transcribed from `components/forms/Checkbox.jsx`, `Checkbox.d.ts`,
/// `Checkbox.prompt.md` and the specimen
/// `components/forms/selection.card.html` (the *Checkbox* section and the
/// token table under *Relevant tokens & measurements*).
///
/// ```dart
/// DabblerCheckbox(
///   label: 'Notify me',
///   checked: notify,
///   onChanged: (bool v) => setState(() => notify = v),
/// )
/// ```
///
/// ## Flat, not glass
///
/// *"the flat selection control (not glass) — the layering law keeps content
/// controls opaque"* (`Checkbox.prompt.md`). A 24px box at
/// [DabblerRadius.sm]: checked, it fills [DabblerColors.brandPrimary] and
/// draws the mark in [DabblerColors.onBrand]; unchecked, it is a
/// [DabblerSizing.borderDefault] [DabblerColors.borderDefault] outline over
/// nothing at all. No shadow, no gradient, no fill behind the outline.
///
/// ## Independent values, and no indeterminate state
///
/// *"Selections are independent — each box is its own value, so any number can
/// be on at once. There is no indeterminate state and no size prop in the
/// current implementation."* Both absences are transcribed, not oversights: a
/// tri-state checkbox would be a component the source does not have.
///
/// ## Row, target and RTL
///
/// The whole row is the control: box, then [DabblerSpacing.stackDefault] (12),
/// then the label, floored at [DabblerSizing.touchTargetMin] so *"the visual
/// control is small but the target always clears 45px"*. The row is plain flow
/// with a logical gap, so *"the box moves to the right of the label under
/// dir="rtl" with no directional prop"* — there is no `left`/`right` anywhere
/// in this file.
///
/// ## Keyboard and semantics
///
/// The port of `role="checkbox"` + `tabIndex={disabled ? -1 : 0}`: one focus
/// stop for the row, Space or Enter to flip it, the shared [DabblerFocusRing]
/// around the **box** (not the row) on keyboard focus only, and no focus stop
/// at all while [disabled]. [Semantics.checked] makes assistive technology
/// announce the state, which is what `aria-checked` does in the source.
class DabblerCheckbox extends StatefulWidget {
  /// Creates a controlled checkbox.
  const DabblerCheckbox({
    super.key,
    required this.checked,
    this.onChanged,
    this.disabled = false,
    this.label,
    this.semanticLabel,
  });

  /// Whether the box is ticked. Controlled: this widget holds no value.
  final bool checked;

  /// Called with the next value.
  final ValueChanged<bool>? onChanged;

  /// Whether the control is inert: 50% opacity and no click
  /// (`Checkbox.jsx:29`, and the specimen's *"Disabled drops to 50% opacity
  /// and takes no click"*).
  final bool disabled;

  /// The optional trailing label, `.t-body` at [DabblerColors.textPrimary]
  /// (`Checkbox.jsx:32-33` — `fontSize: 16, lineHeight: '21px'`, which is the
  /// `.t-body` step).
  final String? label;

  /// The accessible name when [label] is null or when the announced name
  /// should differ from the visible one.
  final String? semanticLabel;

  /// `width: 24, height: 24` (`Checkbox.jsx:11`) — [DabblerSizing.iconMd], and
  /// the specimen's *"24px — the Checkbox box, the Radio circle, the Toggle
  /// knob"*.
  static const double boxSize = DabblerSizing.iconMd;

  /// `width="18" height="18"` on the check mark's `svg`
  /// (`Checkbox.jsx:15`) — [DabblerSizing.iconSm].
  static const double markSize = DabblerSizing.iconSm;

  /// `strokeWidth="3"` in the mark's own 24-unit viewBox (`Checkbox.jsx:15`),
  /// expressed here in those same viewBox units; [DabblerCheckMarkPainter]
  /// scales it with the path.
  static const double markStrokeWidth = 3;

  /// `opacity: disabled ? 0.5 : 1` (`Checkbox.jsx:29`).
  static const double disabledOpacity = 0.5;

  /// The box fill: brand when checked, nothing when not
  /// (`background: checked ? 'var(--color-brand-primary)' : 'transparent'`).
  static Color? fillFor(DabblerColors colors, {required bool checked}) =>
      checked ? colors.brandPrimary : null;

  /// The box outline: brand when checked, `--color-border-default` when not.
  static Color borderColorFor(DabblerColors colors, {required bool checked}) =>
      checked ? colors.brandPrimary : colors.borderDefault;

  @override
  State<DabblerCheckbox> createState() => _DabblerCheckboxState();
}

class _DabblerCheckboxState extends State<DabblerCheckbox> {
  bool _ringVisible = false;

  bool get _enabled => !widget.disabled && widget.onChanged != null;

  void _toggle() {
    if (!_enabled) {
      return;
    }
    widget.onChanged!(!widget.checked);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    final Widget box = DabblerFocusRing.visible(
      visible: _ringVisible,
      enabled: _enabled,
      borderRadius: DabblerRadius.smAll,
      child: Container(
        width: DabblerCheckbox.boxSize,
        height: DabblerCheckbox.boxSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: DabblerCheckbox.fillFor(colors, checked: widget.checked),
          borderRadius: DabblerRadius.smAll,
          border: Border.all(
            color: DabblerCheckbox.borderColorFor(
              colors,
              checked: widget.checked,
            ),
            width: DabblerSizing.borderDefault,
          ),
        ),
        child: widget.checked
            ? CustomPaint(
                size: const Size.square(DabblerCheckbox.markSize),
                painter: DabblerCheckMarkPainter(color: colors.onBrand),
              )
            : null,
      ),
    );

    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        box,
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
      checked: widget.checked,
      enabled: _enabled,
      onTap: _enabled ? _toggle : null,
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
                _toggle();
                return null;
              },
            ),
          },
          mouseCursor:
              _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _enabled ? _toggle : null,
            child: Opacity(
              opacity:
                  widget.disabled ? DabblerCheckbox.disabledOpacity : 1,
              child: ConstrainedBox(
                // `minHeight: var(--touch-target-min)` (`Checkbox.jsx:27`).
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

/// The check mark, painted from the source's own path.
///
/// `Checkbox.jsx:15` draws `<path d="M20 6 9 17l-5-5" />` in a 24-unit
/// viewBox, `fill="none"`, `strokeWidth="3"`, `strokeLinecap="round"`,
/// `strokeLinejoin="round"`, rendered at 18×18. The three points are therefore
/// (20, 6), (9, 17) and (4, 12) in viewBox units, scaled to whatever size the
/// painter is given — the stroke width scales with them, so the mark keeps the
/// source's proportions at any size rather than thickening as it shrinks.
///
/// It is a path rather than an Iconsax glyph because the source draws it
/// inline: the icon set has no mark at these coordinates, and substituting one
/// would be a redraw of the component, not a transcription of it.
class DabblerCheckMarkPainter extends CustomPainter {
  /// Creates the painter. [color] is [DabblerColors.onBrand] in the source.
  const DabblerCheckMarkPainter({required this.color});

  /// The stroke colour — `stroke="var(--color-on-brand)"`.
  final Color color;

  /// The source's viewBox edge, `viewBox="0 0 24 24"`.
  static const double viewBox = 24;

  /// The path's three points in viewBox units, in drawing order.
  static const List<Offset> points = <Offset>[
    Offset(20, 6),
    Offset(9, 17),
    Offset(4, 12),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.shortestSide / viewBox;
    final Path path = Path()
      ..moveTo(points.first.dx * scale, points.first.dy * scale);
    for (final Offset point in points.skip(1)) {
      path.lineTo(point.dx * scale, point.dy * scale);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = DabblerCheckbox.markStrokeWidth * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(DabblerCheckMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
