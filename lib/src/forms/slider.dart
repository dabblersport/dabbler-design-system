import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// Slider — a value, or a band of values, on a continuous axis.
///
/// Transcribed from `components/forms/Slider.jsx`, `Slider.d.ts`,
/// `Slider.prompt.md` and the *Slider* half of
/// `components/forms/value-controls.card.html`, whose *Anatomy* table is the
/// authority for every number below.
///
/// ```dart
/// DabblerSlider(
///   label: 'distance',
///   max: 25,
///   value: km,
///   formatValue: (num v) => '$v km',
///   onChanged: (double v) => setState(() => km = v),
/// )
///
/// DabblerSlider.range(
///   label: 'price',
///   max: 200,
///   step: 5,
///   values: price,
///   marks: const <double>[0, 50, 100, 150, 200],
///   formatValue: (num v) => 'AED $v',
///   onChanged: (DabblerSliderRange v) => setState(() => price = v),
/// )
/// ```
///
/// ## A different interaction model from the rest of DS-603
///
/// Toggle, Checkbox, Radio and Stepper commit a **discrete** value on a tap.
/// This one is a continuous drag: pointer-down anywhere on the track jumps to
/// that value and starts a drag, and in range mode *"the nearer thumb is the
/// one that moves"*. It therefore composes no [DabblerFieldShell] — it is not
/// a field, has no box, no border states and no helper line — and shares with
/// the other four only the tokens, the focus ring and the 45px floor.
///
/// ## Anatomy
///
/// | part | treatment |
/// |---|---|
/// | track | [trackHeight] (6), [DabblerColors.bgTertiary], pill radii |
/// | fill | [DabblerColors.brandPrimary], inline start → thumb (between thumbs in range) |
/// | thumb | [thumbSize] (24) filled [DabblerColors.surfaceCard] with a 1px [DabblerColors.borderStrong] ring, inside a [DabblerSizing.touchTargetMin] hit area |
/// | readout | `.t-caption-1` at weight 500, from [formatValue] |
/// | marks | tick positions given in value space, not pixels |
///
/// No shadow, no lift while dragging, and no size prop — the source has none.
///
/// ## Touch target (AC2)
///
/// The painted thumb is 24, so each thumb carries a transparent
/// [DabblerSizing.touchTargetMin] (45) square hit area centred on it, and the
/// track row is 45 tall at every width. 45 ≥ 44 on both axes, which is
/// `cpo` §5.2 Principle 3, and the test measures the thumb's rect rather than
/// trusting this note.
///
/// ## RTL — the axis inverts, and so does everything that reads it
///
/// *"The thumb and fill are positioned with `inset-inline-start`, so **the
/// axis inverts automatically** in RTL: the minimum is on the right. Pointer
/// maths inverts with it, and the arrow keys swap so that 'increase' is always
/// the direction the fill grows."* Three separate things, all implemented:
///
/// * **paint** — the fill and every thumb are placed with
///   [PositionedDirectional], the Flutter equivalent of `inset-inline-start`,
///   as `lib/src/feedback/progress_bar.dart` places its determinate fill;
/// * **pointer** — the drag ratio is measured from the local x and then
///   inverted under [TextDirection.rtl], because a pointer position is
///   physical where the layout is logical;
/// * **keys** — [LogicalKeyboardKey.arrowLeft] *increases* under RTL, so the
///   key that grows the fill is always the one pointing the way it grows.
///
/// ## Keyboard
///
/// Arrow keys ±[step], PageUp / PageDown ±[pageStepMultiplier] steps, Home →
/// [min], End → [max]. Each thumb is separately focusable and draws the shared
/// [DabblerFocusRing] on keyboard focus only.
///
/// ## Accessibility
///
/// Each thumb is a [Semantics.slider] node carrying the formatted value and
/// its own increase / decrease actions. In range mode the thumbs bound each
/// other — *"the low thumb's max is the high value and vice versa"* — and are
/// named [minimumSemanticLabel] / [maximumSemanticLabel].
class DabblerSlider extends StatefulWidget {
  /// A single-value slider.
  const DabblerSlider({
    super.key,
    required double this.value,
    this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.label,
    this.formatValue,
    this.marks,
    this.disabled = false,
    this.semanticLabel,
  })  : values = null,
        onRangeChanged = null,
        minimumSemanticLabel = defaultMinimumLabel,
        maximumSemanticLabel = defaultMaximumLabel;

  /// A two-thumb slider with a filled band between the thumbs —
  /// `range` in the source.
  const DabblerSlider.range({
    super.key,
    required DabblerSliderRange this.values,
    ValueChanged<DabblerSliderRange>? onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.label,
    this.formatValue,
    this.marks,
    this.disabled = false,
    this.minimumSemanticLabel = defaultMinimumLabel,
    this.maximumSemanticLabel = defaultMaximumLabel,
  })  : value = null,
        onChanged = null,
        onRangeChanged = onChanged,
        semanticLabel = null;

  /// The value, on a single-value slider.
  final double? value;

  /// The pair, on a [DabblerSlider.range].
  final DabblerSliderRange? values;

  /// Called with the next value on a single-value slider.
  final ValueChanged<double>? onChanged;

  /// Called with the next pair on a [DabblerSlider.range], always ordered low
  /// first — the source sorts the pair before handing it back.
  final ValueChanged<DabblerSliderRange>? onRangeChanged;

  /// The axis minimum. `min = 0` (`Slider.jsx:17`).
  final double min;

  /// The axis maximum. `max = 100` (`Slider.jsx:18`).
  final double max;

  /// The snap increment. `step = 1` (`Slider.jsx:19`).
  final double step;

  /// The caption on the start edge of the readout row, `.t-subheadline` at
  /// [DabblerColors.textSecondary].
  final String? label;

  /// Formats the readout and the announced value, e.g. `(v) => '$v km'`.
  /// Defaults to the plain number, as the source's `String(v)` does.
  final String Function(num value)? formatValue;

  /// Tick positions **in value space, not pixels** (`marks` in
  /// `Slider.d.ts:16`). Decorative: they are excluded from semantics, exactly
  /// as the source marks them `aria-hidden="true"`.
  final List<double>? marks;

  /// Whether the slider is inert: [disabledOpacity], no pointer and no key
  /// handling.
  final bool disabled;

  /// The accessible name of a single-value slider. Defaults to [label].
  final String? semanticLabel;

  /// The low thumb's name in range mode — `aria-label="Minimum"`.
  final String minimumSemanticLabel;

  /// The high thumb's name in range mode — `aria-label="Maximum"`.
  final String maximumSemanticLabel;

  /// The source's `aria-label` for the low thumb.
  static const String defaultMinimumLabel = 'Minimum';

  /// The source's `aria-label` for the high thumb.
  static const String defaultMaximumLabel = 'Maximum';

  /// `height: 6` on the track and the fill (`Slider.jsx:139, 144`) —
  /// [DabblerSpacing.space2], the same 6 `DabblerProgressBar.trackHeightMd`
  /// resolves.
  static const double trackHeight = DabblerSpacing.space2;

  /// `width: 24, height: 24` on the thumb (`Slider.jsx:117`) —
  /// [DabblerSizing.iconMd].
  static const double thumbSize = DabblerSizing.iconMd;

  /// `height: 12` on a mark (`Slider.jsx:153`) — [DabblerSpacing.space4].
  static const double markHeight = DabblerSpacing.space4;

  /// `width: 1` on a mark (`Slider.jsx:153`) — [DabblerSizing.borderDefault].
  static const double markWidth = DabblerSizing.borderDefault;

  /// `opacity: disabled ? 0.45 : 1` (`Slider.jsx:131`), and the specimen's
  /// *"disabled (45% opacity, no pointer or key handling)"*.
  static const double disabledOpacity = 0.45;

  /// `gap: var(--space-2)` on the outer column (`Slider.jsx:131`).
  static const double columnGap = DabblerSpacing.space2;

  /// `gap: var(--space-3)` between the caption and the readout
  /// (`Slider.jsx:133`).
  static const double readoutGap = DabblerSpacing.space3;

  /// `step * 10` on PageUp / PageDown (`Slider.jsx:99-100`).
  static const int pageStepMultiplier = 10;

  /// Snaps [value] to [step] and clamps it into `[min, max]` — the source's
  /// `Math.min(max, Math.max(min, Math.round(v / step) * step))`.
  static double snap(
    double value, {
    required double min,
    required double max,
    required double step,
  }) {
    final double snapped = step <= 0 ? value : (value / step).roundToDouble() * step;
    return snapped.clamp(min, max);
  }

  /// [value] as a 0–1 fraction of the axis — the source's `pct(v)`, as a
  /// fraction rather than a percentage because Flutter positions in fractions.
  ///
  /// A zero-width axis (`min == max`) yields 0 rather than a NaN, which the
  /// source's arithmetic would produce.
  static double fractionOf(
    double value, {
    required double min,
    required double max,
  }) =>
      max == min ? 0 : ((value - min) / (max - min)).clamp(0.0, 1.0);

  @override
  State<DabblerSlider> createState() => _DabblerSliderState();
}

/// An ordered `[low, high]` pair — the source's `[lo, hi]` tuple.
@immutable
class DabblerSliderRange {
  /// Creates a pair. The two values are ordered on construction, because
  /// `commit` in the source sorts before it reports.
  const DabblerSliderRange(double a, double b)
      : low = a <= b ? a : b,
        high = a <= b ? b : a;

  /// The lower of the two values.
  final double low;

  /// The higher of the two values.
  final double high;

  @override
  bool operator ==(Object other) =>
      other is DabblerSliderRange && other.low == low && other.high == high;

  @override
  int get hashCode => Object.hash(low, high);

  @override
  String toString() => 'DabblerSliderRange($low, $high)';
}

/// Which thumb an interaction is addressing.
enum _Thumb { low, high }

/// A keyboard adjustment, resolved against the current direction at invoke
/// time so RTL inverts the arrow keys without a second shortcut map.
class _AdjustIntent extends Intent {
  const _AdjustIntent.forward()
      : steps = 1,
        absolute = null,
        directional = true;
  const _AdjustIntent.backward()
      : steps = -1,
        absolute = null,
        directional = true;
  const _AdjustIntent.up()
      : steps = 1,
        absolute = null,
        directional = false;
  const _AdjustIntent.down()
      : steps = -1,
        absolute = null,
        directional = false;
  const _AdjustIntent.page(this.steps)
      : absolute = null,
        directional = false;
  const _AdjustIntent.to(double this.absolute)
      : steps = 0,
        directional = false;

  /// How many [DabblerSlider.step]s to move, signed.
  final int steps;

  /// An absolute destination (Home / End), which overrides [steps].
  final double? absolute;

  /// Whether [steps] is expressed along the *physical* axis and must be
  /// inverted under RTL. Arrow Left / Right are; Arrow Up / Down, PageUp and
  /// PageDown are not.
  final bool directional;
}

class _DabblerSliderState extends State<DabblerSlider> {
  _Thumb? _dragging;
  final Map<_Thumb, bool> _ringVisible = <_Thumb, bool>{
    _Thumb.low: false,
    _Thumb.high: false,
  };

  bool get _isRange => widget.values != null;

  bool get _enabled =>
      !widget.disabled &&
      (_isRange ? widget.onRangeChanged != null : widget.onChanged != null);

  double get _low => _isRange ? widget.values!.low : widget.min;
  double get _high => _isRange ? widget.values!.high : widget.value!;

  double _valueOf(_Thumb thumb) => thumb == _Thumb.low ? _low : _high;

  /// The displayed and announced string for [value].
  ///
  /// The value handed to [DabblerSlider.formatValue] is narrowed to an [int]
  /// when it is integral, because the source's formatters are written against
  /// JavaScript numbers — `` (v) => `${v} km` `` prints `8 km`, not `8.0 km`,
  /// and a Dart formatter written from that example must produce the same
  /// string. The default formatter is `String(v)` over the same narrowed
  /// value.
  String _format(double value) {
    final num narrowed =
        value == value.roundToDouble() ? value.toInt() : value;
    return widget.formatValue?.call(narrowed) ?? '$narrowed';
  }

  void _commit(double raw, _Thumb thumb) {
    if (!_enabled) {
      return;
    }
    final double next = DabblerSlider.snap(
      raw,
      min: widget.min,
      max: widget.max,
      step: widget.step,
    );
    if (!_isRange) {
      if (next != _high) {
        widget.onChanged!(next);
      }
      return;
    }
    final DabblerSliderRange pair = thumb == _Thumb.low
        ? DabblerSliderRange(next, _high)
        : DabblerSliderRange(_low, next);
    if (pair != widget.values) {
      widget.onRangeChanged!(pair);
    }
  }

  /// The value under a local x inside a track of [width], with the axis
  /// inverted under RTL.
  double _valueAt(double dx, double width, TextDirection direction) {
    if (width <= 0) {
      return widget.min;
    }
    double ratio = (dx / width).clamp(0.0, 1.0);
    if (direction == TextDirection.rtl) {
      ratio = 1 - ratio;
    }
    return widget.min + ratio * (widget.max - widget.min);
  }

  /// *"in `range` mode the nearer thumb is the one that moves"*.
  _Thumb _nearest(double value) {
    if (!_isRange) {
      return _Thumb.high;
    }
    return (value - _low).abs() < (value - _high).abs()
        ? _Thumb.low
        : _Thumb.high;
  }

  void _adjust(_AdjustIntent intent, _Thumb thumb, TextDirection direction) {
    final double current = _valueOf(thumb);
    if (intent.absolute != null) {
      _commit(intent.absolute!, thumb);
      return;
    }
    final int sign =
        intent.directional && direction == TextDirection.rtl ? -1 : 1;
    _commit(current + widget.step * intent.steps * sign, thumb);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    return Opacity(
      opacity: widget.disabled ? DabblerSlider.disabledOpacity : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ...?_readout(colors, direction),
          _track(colors, direction),
        ],
      ),
    );
  }

  /// The label / value row. The source renders it for `(label || value !==
  /// undefined)`, which for this widget is always: a value is required by both
  /// constructors, and *"a slider with no readout is a guess"*.
  List<Widget>? _readout(DabblerColors colors, TextDirection direction) {
    final String text = _isRange
        // `${fmt(lo)} – ${fmt(hi)}` — an en dash, as the source has.
        ? '${_format(_low)} – ${_format(_high)}'
        : _format(_high);

    return <Widget>[
      // The row repeats what the thumbs already announce, so it is excluded
      // from semantics — the same treatment `DabblerProgressBar` gives its own
      // caption row, and for the same reason.
      ExcludeSemantics(
        child: Row(
          children: <Widget>[
            Expanded(
              child: widget.label == null
                  ? const SizedBox.shrink()
                  : Text(
                      widget.label!,
                      style: DabblerType.subheadline
                          .resolveForDirection(direction)
                          .copyWith(color: colors.textSecondary),
                    ),
            ),
            const SizedBox(width: DabblerSlider.readoutGap),
            Text(
              text,
              style: DabblerType.caption1
                  .resolveForDirection(direction)
                  .copyWith(
                    color: colors.textPrimary,
                    fontWeight: DabblerType.medium,
                  ),
            ),
          ],
        ),
      ),
      const SizedBox(height: DabblerSlider.columnGap),
    ];
  }

  /// The 45px interaction row: track, fill, marks and thumbs in a stack.
  Widget _track(DabblerColors colors, TextDirection direction) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double lowFraction = DabblerSlider.fractionOf(
          _low,
          min: widget.min,
          max: widget.max,
        );
        final double highFraction = DabblerSlider.fractionOf(
          _high,
          min: widget.min,
          max: widget.max,
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled
              ? (TapDownDetails details) {
                  final double value = _valueAt(
                    details.localPosition.dx,
                    width,
                    direction,
                  );
                  _commit(value, _nearest(value));
                }
              : null,
          onHorizontalDragStart: _enabled
              ? (DragStartDetails details) {
                  final double value = _valueAt(
                    details.localPosition.dx,
                    width,
                    direction,
                  );
                  _dragging = _nearest(value);
                  _commit(value, _dragging!);
                }
              : null,
          onHorizontalDragUpdate: _enabled
              ? (DragUpdateDetails details) {
                  final _Thumb thumb = _dragging ?? _Thumb.high;
                  _commit(
                    _valueAt(details.localPosition.dx, width, direction),
                    thumb,
                  );
                }
              : null,
          onHorizontalDragEnd: (DragEndDetails details) => _dragging = null,
          onHorizontalDragCancel: () => _dragging = null,
          child: SizedBox(
            // `minHeight: var(--touch-target-min)` (`Slider.jsx:136`) — the
            // hit area stays 45 tall at every width.
            height: DabblerSizing.touchTargetMin,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                // The track: `insetInline: 0`, centred on the row.
                Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      height: DabblerSlider.trackHeight,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.bgTertiary,
                          borderRadius: DabblerRadius.pillAll,
                        ),
                      ),
                    ),
                  ),
                ),
                // The fill: from the inline start to the thumb, or between the
                // thumbs in range mode.
                PositionedDirectional(
                  start: (_isRange ? lowFraction : 0) * width,
                  width: (_isRange ? highFraction - lowFraction : highFraction) *
                      width,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: SizedBox(
                      height: DabblerSlider.trackHeight,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.brandPrimary,
                          borderRadius: DabblerRadius.pillAll,
                        ),
                      ),
                    ),
                  ),
                ),
                ...?widget.marks?.map(
                  (double mark) => PositionedDirectional(
                    start: DabblerSlider.fractionOf(
                          mark,
                          min: widget.min,
                          max: widget.max,
                        ) *
                            width -
                        DabblerSlider.markWidth / 2,
                    top: 0,
                    bottom: 0,
                    child: ExcludeSemantics(
                      child: Center(
                        child: SizedBox(
                          width: DabblerSlider.markWidth,
                          height: DabblerSlider.markHeight,
                          child: ColoredBox(color: colors.borderDefault),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isRange)
                  _thumb(colors, direction, _Thumb.low, lowFraction, width),
                _thumb(colors, direction, _Thumb.high, highFraction, width),
              ],
            ),
          ),
        );
      },
    );
  }

  /// One thumb: the 24px visual centred inside a 45px hit area, positioned
  /// with [PositionedDirectional] so the axis inverts in RTL.
  Widget _thumb(
    DabblerColors colors,
    TextDirection direction,
    _Thumb thumb,
    double fraction,
    double width,
  ) {
    final double value = _valueOf(thumb);
    // `translate: '-50% -50%'` — the hit area, not the visual, is what is
    // centred on the value, so the tappable square is symmetric about it.
    final double start = fraction * width - DabblerSizing.touchTargetMin / 2;

    final Widget visual = Container(
      width: DabblerSlider.thumbSize,
      height: DabblerSlider.thumbSize,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.borderStrong,
          width: DabblerSizing.borderDefault,
        ),
      ),
    );

    return PositionedDirectional(
      start: start,
      top: 0,
      bottom: 0,
      width: DabblerSizing.touchTargetMin,
      child: Semantics(
        slider: true,
        label: _isRange
            ? (thumb == _Thumb.low
                ? widget.minimumSemanticLabel
                : widget.maximumSemanticLabel)
            : (widget.semanticLabel ?? widget.label),
        value: _format(value),
        enabled: _enabled,
        // The thumbs bound each other in range mode, which is the source's
        // `aria-valuemin` / `aria-valuemax` pairing.
        increasedValue: _format(
          DabblerSlider.snap(
            value + widget.step,
            min: widget.min,
            max: _isRange && thumb == _Thumb.low ? _high : widget.max,
            step: widget.step,
          ),
        ),
        decreasedValue: _format(
          DabblerSlider.snap(
            value - widget.step,
            min: _isRange && thumb == _Thumb.high ? _low : widget.min,
            max: widget.max,
            step: widget.step,
          ),
        ),
        onIncrease: _enabled ? () => _commit(value + widget.step, thumb) : null,
        onDecrease: _enabled ? () => _commit(value - widget.step, thumb) : null,
        container: true,
        child: ExcludeSemantics(
          // The shortcut map is an ancestor of the focus node rather than a
          // child of it: a key event travels from the focused node upwards, so
          // a `Shortcuts` below it would never see one. It is built here, not
          // declared const, because Home and End carry this slider's own
          // bounds.
          child: Shortcuts(
            shortcuts: <ShortcutActivator, Intent>{
              const SingleActivator(LogicalKeyboardKey.arrowRight):
                  const _AdjustIntent.forward(),
              const SingleActivator(LogicalKeyboardKey.arrowLeft):
                  const _AdjustIntent.backward(),
              const SingleActivator(LogicalKeyboardKey.arrowUp):
                  const _AdjustIntent.up(),
              const SingleActivator(LogicalKeyboardKey.arrowDown):
                  const _AdjustIntent.down(),
              const SingleActivator(LogicalKeyboardKey.pageUp):
                  const _AdjustIntent.page(DabblerSlider.pageStepMultiplier),
              const SingleActivator(LogicalKeyboardKey.pageDown):
                  const _AdjustIntent.page(-DabblerSlider.pageStepMultiplier),
              const SingleActivator(LogicalKeyboardKey.home):
                  _AdjustIntent.to(widget.min),
              const SingleActivator(LogicalKeyboardKey.end):
                  _AdjustIntent.to(widget.max),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                _AdjustIntent: CallbackAction<_AdjustIntent>(
                  onInvoke: (_AdjustIntent intent) {
                    _adjust(intent, thumb, direction);
                    return null;
                  },
                ),
              },
              child: FocusableActionDetector(
                enabled: _enabled,
                onShowFocusHighlight: (bool visible) {
                  if (_ringVisible[thumb] != visible) {
                    setState(() => _ringVisible[thumb] = visible);
                  }
                },
                mouseCursor: _enabled
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                child: Center(
                  child: DabblerFocusRing.visible(
                    visible: _ringVisible[thumb] ?? false,
                    enabled: _enabled,
                    borderRadius: DabblerRadius.pillAll,
                    child: visual,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
