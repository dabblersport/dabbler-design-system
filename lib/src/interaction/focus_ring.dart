import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';

/// Focus ring — the one visible focus indicator in the system.
///
/// Transcribed from the design source's `.dbl-focus` rule
/// (`tokens/spacing.css:65-74`), which is also what
/// `components/foundations/overlay.jsx:154-157` exports as `focusRingStyle`
/// and what `components/controls/Button.jsx:73` applies:
///
/// ```css
/// --focus-ring-width: 2px;
/// --focus-ring-offset: 2px;
/// .dbl-focus:focus-visible {
///   outline: var(--focus-ring-width) solid var(--color-focus-ring);
///   outline-offset: var(--focus-ring-offset);
/// }
/// ```
///
/// The colour is [DabblerColors.focusRing] — per theme and per brightness, and
/// never a literal. `guidelines/measurements.html:113` is explicit that the
/// ring is drawn with `outline` and **never** `box-shadow`, so the flat
/// no-shadow rule holds in computed styles; the Flutter equivalent is a
/// stroked border painted outside the child's bounds, which is what
/// [_FocusRingPainter] does. It is painted, not laid out, so **turning the
/// ring on never moves anything** — no reflow, no size change, no jump.
///
/// Required by `cpo` §5.2 Principle 3 (a visible focus indicator), and this is
/// the only implementation of it: no control in the cut draws its own.
///
/// ## It wraps an arbitrary child and assumes no control
///
/// There is no tap handler, no colour fill, no shape of its own and no
/// assumption about what is inside. Give it the [borderRadius] the child is
/// actually drawn with so the ring traces it; the default is a square corner.
///
/// Two ways to drive it:
///
/// * **[DabblerFocusRing.new]** — the primitive owns the focus tracking. It
///   inserts a [Focus] node (or adopts the [focusNode] you pass) and shows the
///   ring only when focus arrived **and the user is navigating by keyboard**,
///   which is Flutter's [FocusHighlightMode.traditional] and the faithful
///   equivalent of CSS `:focus-visible` — a mouse press on a button must not
///   raise a ring.
/// * **[DabblerFocusRing.visible]** — you own the state; the primitive only
///   paints. For a control that already has a [FocusNode], a
///   [WidgetStatesController], or focus handled by a parent.
///
/// ## Reduced motion
///
/// The ring does not animate in either direction, in the source or here. It is
/// an accessibility affordance: it appears at once and disappears at once, so
/// there is nothing for reduced motion to switch off.
class DabblerFocusRing extends StatefulWidget {
  /// Tracks focus itself and shows the ring on keyboard focus only.
  const DabblerFocusRing({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.width = ringWidth,
    this.offset = ringOffset,
  })  : _selfDriven = true,
        visible = false;

  /// Paints the ring when [visible]; tracks nothing.
  const DabblerFocusRing.visible({
    super.key,
    required this.child,
    required this.visible,
    this.borderRadius = BorderRadius.zero,
    this.enabled = true,
    this.width = ringWidth,
    this.offset = ringOffset,
  })  : _selfDriven = false,
        focusNode = null,
        autofocus = false,
        canRequestFocus = true,
        onFocusChange = null;

  /// `--focus-ring-width: 2px` (`tokens/spacing.css:65`).
  static const double ringWidth = 2;

  /// `--focus-ring-offset: 2px` (`tokens/spacing.css:66`) — the gap between
  /// the child's edge and the ring.
  static const double ringOffset = 2;

  /// The focusable thing. Any widget.
  final Widget child;

  /// Whether the ring is shown. Ignored by [DabblerFocusRing.new], which
  /// derives it from focus.
  final bool visible;

  /// The radius the [child] is drawn with, so the ring traces its shape. The
  /// ring's own corners are this radius grown by [offset] + [width] / 2, which
  /// keeps the gap even the whole way round.
  final BorderRadiusGeometry borderRadius;

  /// Whether a ring may be shown at all. `false` on a disabled control, which
  /// the source renders inert (`components/controls/Button.jsx:73`).
  final bool enabled;

  /// An existing node to adopt instead of creating one. Only for
  /// [DabblerFocusRing.new].
  final FocusNode? focusNode;

  /// Whether to take focus on first build. Only for [DabblerFocusRing.new].
  final bool autofocus;

  /// Whether the inserted node may take focus. Only for
  /// [DabblerFocusRing.new].
  final bool canRequestFocus;

  /// Called when the inserted node gains or loses focus, so a control can keep
  /// its own state in step. Only for [DabblerFocusRing.new].
  final ValueChanged<bool>? onFocusChange;

  /// Ring thickness. Defaults to the token; leave it alone.
  final double width;

  /// Ring gap. Defaults to the token; leave it alone.
  final double offset;

  final bool _selfDriven;

  @override
  State<DabblerFocusRing> createState() => _DabblerFocusRingState();
}

class _DabblerFocusRingState extends State<DabblerFocusRing> {
  FocusHighlightMode _highlightMode = FocusManager.instance.highlightMode;

  @override
  void initState() {
    super.initState();
    if (widget._selfDriven) {
      FocusManager.instance.addHighlightModeListener(_handleHighlightMode);
    }
  }

  @override
  void dispose() {
    if (widget._selfDriven) {
      FocusManager.instance.removeHighlightModeListener(_handleHighlightMode);
    }
    super.dispose();
  }

  void _handleHighlightMode(FocusHighlightMode mode) {
    if (!mounted || _highlightMode == mode) {
      return;
    }
    setState(() => _highlightMode = mode);
  }

  /// The `:focus-visible` equivalent: focused *and* the last interaction was a
  /// keyboard one. A pointer press must not raise a ring.
  bool _showRing(bool focused) =>
      widget.enabled &&
      focused &&
      (!widget._selfDriven ||
          _highlightMode == FocusHighlightMode.traditional);

  Widget _paint(BuildContext context, {required bool focused}) {
    return CustomPaint(
      // A foreground painter, so the ring sits above the child's own paint;
      // it draws outside the child's bounds and is never clipped to them.
      foregroundPainter: _showRing(focused)
          ? _FocusRingPainter(
              color: DabblerColors.of(context).focusRing,
              borderRadius:
                  widget.borderRadius.resolve(Directionality.maybeOf(context)),
              width: widget.width,
              offset: widget.offset,
            )
          : null,
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget._selfDriven) {
      return _paint(context, focused: widget.visible);
    }

    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      canRequestFocus: widget.enabled && widget.canRequestFocus,
      // Reported for the composing control's benefit. The ring itself reads
      // the node below rather than this callback's state: `Focus.of` makes the
      // paint a dependency of the focus node, so it is repainted whenever
      // focus moves, including when it moves to a sibling.
      onFocusChange: widget.onFocusChange,
      child: Builder(
        builder: (BuildContext context) =>
            _paint(context, focused: Focus.of(context).hasFocus),
      ),
    );
  }
}

/// Paints the ring as a stroked rounded rectangle [offset] outside the child.
///
/// The stroke is centred on its path, so the path is inflated by
/// `offset + width / 2` for the visible inner edge to land exactly [offset]
/// away from the child.
class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter({
    required this.color,
    required this.borderRadius,
    required this.width,
    required this.offset,
  });

  final Color color;
  final BorderRadius borderRadius;
  final double width;
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    final double grow = offset + width / 2;
    final RRect rrect = borderRadius
        .toRRect(Offset.zero & size)
        .inflate(grow);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.width != width ||
      oldDelegate.offset != offset;
}
