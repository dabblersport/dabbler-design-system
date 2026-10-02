/// Part of the `time_picker.dart` library — the `Ruler` strip ([_TimeRuler]) and its tick painter.
///
/// **Why `part`, not a separate library.** The file stood over the
/// project's 500-line house rule (`013`). These declarations were moved
/// verbatim; `part`/`part of` keeps one logical library, so private names
/// stay private and no public API changes. No exemption was recorded.
///
/// The imports are the library's — a part file declares none of its own.
part of 'time_picker.dart';

/// The `Ruler` of `TimePicker.jsx:3-75`: a looping strip of numerals under a
/// fixed centre window, dragged horizontally.
class _TimeRuler extends StatefulWidget {
  const _TimeRuler({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.enabledOf,
    required this.onSelected,
  });

  final String label;
  final List<int> values;
  final int selected;
  final bool Function(int) enabledOf;
  final ValueChanged<int> onSelected;

  @override
  State<_TimeRuler> createState() => _TimeRulerState();
}

class _TimeRulerState extends State<_TimeRuler> {
  final FocusNode _node = FocusNode(debugLabel: 'DabblerTimePicker ruler');
  double _dragPx = 0;
  bool _dragging = false;
  bool _focused = false;

  int get _n => widget.values.length;
  int get _idx => math.max(0, widget.values.indexOf(widget.selected));

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  void _pick(int index) {
    final int wrapped = ((index % _n) + _n) % _n;
    final int v = widget.values[wrapped];
    if (widget.enabledOf(v)) {
      widget.onSelected(v);
    }
  }

  List<int> get _enabled => <int>[
    for (int i = 0; i < _n; i++)
      if (widget.enabledOf(widget.values[i])) i,
  ];

  void _step(int direction) {
    final List<int> enabled = _enabled;
    if (enabled.isEmpty) {
      return;
    }
    final int? next = direction > 0
        ? enabled.where((int i) => i > _idx).firstOrNull
        : enabled.where((int i) => i < _idx).lastOrNull;
    if (next != null) {
      widget.onSelected(widget.values[next]);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp) {
      _step(1);
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowDown) {
      _step(-1);
    } else if (key == LogicalKeyboardKey.home) {
      final List<int> e = _enabled;
      if (e.isNotEmpty) {
        widget.onSelected(widget.values[e.first]);
      }
    } else if (key == LogicalKeyboardKey.end) {
      final List<int> e = _enabled;
      if (e.isNotEmpty) {
        widget.onSelected(widget.values[e.last]);
      }
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _dragEnd() {
    final int shift = (-_dragPx / DabblerTimePicker.rulerPitch).round();
    setState(() {
      _dragPx = 0;
      _dragging = false;
    });
    _pick(_idx + shift);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool rtl = direction == TextDirection.rtl;
    const double pitch = DabblerTimePicker.rulerPitch;
    final int n = _n;
    final int trackLen = n * 3;
    final int centerAbs = n + _idx;
    final double translate = -(centerAbs * pitch + pitch / 2) + _dragPx;
    final Duration duration = (_dragging || DabblerMotion.reduceMotion(context))
        ? Duration.zero
        : DabblerTimePicker.glide;
    final String valueText = DabblerType.toWesternDigits(
      widget.selected.toString().padLeft(2, '0'),
    );

    final TextStyle base = DabblerType.title3.resolveForDirection(direction);

    Widget ruler = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double w = box.maxWidth;
        return SizedBox(
          height: DabblerTimePicker.rulerHeight,
          width: w,
          child: ClipRect(
            child: Directionality(
              // A scale: ascends to the right in both directions.
              textDirection: TextDirection.ltr,
              child: Stack(
                children: <Widget>[
                  // The window's outer shadow, painted first. CSS clips an outer
                  // `box-shadow` to outside the border box, so the box under the
                  // numerals is an opaque card-coloured fill that the shadow
                  // cannot show through, and the ticks and numerals draw above.
                  Positioned(
                    left: (w - (pitch + DabblerTimePicker.windowExtra)) / 2,
                    top: DabblerTimePicker.windowInset,
                    bottom: DabblerTimePicker.windowInset,
                    width: pitch + DabblerTimePicker.windowExtra,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaceCard,
                        borderRadius: BorderRadius.circular(
                          DabblerTimePicker.windowRadius,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            // `0 2px 8px rgba(0,0,0,0.05)` — ink at 5%.
                            color: colors.textPrimary.withValues(
                              alpha: DabblerTimePicker.windowShadowAlpha,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: w / 2,
                    bottom: DabblerTimePicker.tickBottom,
                    height: DabblerTimePicker.tickHeight,
                    width: trackLen * pitch,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: translate),
                      duration: duration,
                      curve: DabblerTimePicker.glideCurve,
                      builder: (BuildContext c, double t, Widget? _) =>
                          Transform.translate(
                            offset: Offset(t, 0),
                            child: CustomPaint(
                              painter: _TickPainter(
                                color: colors.borderDefault,
                                period: pitch / 4,
                              ),
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    left: w / 2,
                    top: 0,
                    height: DabblerTimePicker.rulerHeight,
                    width: trackLen * pitch,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: translate),
                      duration: duration,
                      curve: DabblerTimePicker.glideCurve,
                      builder: (BuildContext c, double t, Widget? _) =>
                          Transform.translate(
                            key: DabblerTimePicker.trackKey(widget.key!),
                            offset: Offset(t, 0),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                for (int i = 0; i < trackLen; i++)
                                  _cell(
                                    colors,
                                    base,
                                    rtl,
                                    i,
                                    (i - centerAbs).abs(),
                                    pitch,
                                  ),
                              ],
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    left: (w - (pitch + DabblerTimePicker.windowExtra)) / 2,
                    top: DabblerTimePicker.windowInset,
                    bottom: DabblerTimePicker.windowInset,
                    width: pitch + DabblerTimePicker.windowExtra,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            DabblerTimePicker.windowRadius,
                          ),
                          border: Border.all(
                            color: colors.brandPrimary,
                            width: DabblerTimePicker.windowBorder,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (w - DabblerTimePicker.pinWidth) / 2,
                    bottom: DabblerTimePicker.pinBottom,
                    width: DabblerTimePicker.pinWidth,
                    height: DabblerTimePicker.pinHeight,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.brandPrimary,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    ruler = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails d) {
        _node.requestFocus();
        setState(() => _dragging = true);
      },
      onHorizontalDragUpdate: (DragUpdateDetails d) =>
          setState(() => _dragPx += d.delta.dx),
      onHorizontalDragEnd: (DragEndDetails d) => _dragEnd(),
      onHorizontalDragCancel: () => setState(() {
        _dragPx = 0;
        _dragging = false;
      }),
      onTapUp: (TapUpDetails d) {
        _node.requestFocus();
        final RenderBox box = context.findRenderObject()! as RenderBox;
        final double dx = d.localPosition.dx - box.size.width / 2;
        _pick(_idx + (dx / pitch).round());
      },
      child: ruler,
    );

    return Semantics(
      container: true,
      label: widget.label,
      value: valueText,
      increasedValue: valueText,
      decreasedValue: valueText,
      onIncrease: () => _step(1),
      onDecrease: () => _step(-1),
      child: Focus(
        focusNode: _node,
        onKeyEvent: _onKey,
        onFocusChange: (bool f) => setState(() => _focused = f),
        child: MouseRegion(
          cursor: _dragging
              ? SystemMouseCursors.grabbing
              : SystemMouseCursors.grab,
          child: DabblerFocusRing.visible(
            visible: _focused,
            borderRadius: DabblerRadius.lgAll,
            child: ExcludeSemantics(child: ruler),
          ),
        ),
      ),
    );
  }

  Widget _cell(
    DabblerColors colors,
    TextStyle base,
    bool rtl,
    int absIdx,
    int dist,
    double pitch,
  ) {
    final bool on = dist == 0;
    final double opacity = on
        ? 1
        : math.max(
            DabblerTimePicker.minOpacity,
            1 - dist * DabblerTimePicker.opacityStep,
          );
    final double size =
        (on
            ? DabblerTimePicker.selectedFontSize
            : DabblerTimePicker.otherFontSize) -
        (rtl ? 0.9 : 0);
    return Positioned(
      left: absIdx * pitch,
      width: pitch,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Center(
          child: Text(
            DabblerType.toWesternDigits(
              widget.values[absIdx % _n].toString().padLeft(2, '0'),
            ),
            key: DabblerTimePicker.cellKey(widget.key!, absIdx),
            style: base.copyWith(
              fontSize: size,
              height: 1,
              fontWeight: DabblerType.regular,
              color: (on ? colors.brandPrimary : colors.textPrimary).withValues(
                alpha: opacity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `repeating-linear-gradient(to right, c 0 1.5px, transparent 1.5px period)`.
class _TickPainter extends CustomPainter {
  const _TickPainter({required this.color, required this.period});

  final Color color;
  final double period;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    for (double x = 0; x < size.width; x += period) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, DabblerTimePicker.tickWidth, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TickPainter old) =>
      old.color != color || old.period != period;
}
