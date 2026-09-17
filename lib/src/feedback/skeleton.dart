import 'package:flutter/widgets.dart';

import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';

/// The shapes [DabblerSkeleton] can take, transcribed from the design source
/// `components/feedback/Skeleton.d.ts`.
enum DabblerSkeletonVariant {
  /// Stacked bars. The last bar of a multi-line stack is 60% wide.
  text,

  /// One block. Height defaults to [DabblerSizing.touchTargetMin].
  rect,

  /// An avatar well — a pill-radius square.
  circle,

  /// A ready-made card shell: a 16:9 media block over two text bars, inside the
  /// standard card hairline.
  card,
}

/// Skeleton — placeholder geometry for content that has not arrived.
///
/// Transcribed from `components/feedback/Skeleton.jsx` and its
/// `Skeleton.prompt.md`. The screen keeps its final layout while data loads, so
/// nothing jumps when the real content lands.
///
/// ## Flat, never a shimmer
///
/// Every block is a **flat fill** of [DabblerPalette.surfaceSunken]: no
/// gradient, no travelling highlight, no shadow. The source is explicit that a
/// shimmer is *"a gradient by another name"*, and `cpo`'s §5.2 lists shimmer
/// loading treatments under what the app avoids. The only motion is the
/// source's `dbl-pulse` — a whole-block **opacity** cycle from 1 to 0.55 over
/// 1.2s, staggered 80ms per line. Opacity animates the block that is already
/// there; it never introduces a second colour across it, so the surface stays
/// flat at every frame.
///
/// Pass `animate: false` for a completely static placeholder. The pulse is also
/// dropped automatically when the platform asks for reduced motion
/// ([MediaQueryData.disableAnimations]), which renders the blocks at the
/// source's reduced-motion opacity of 0.72.
///
/// ## Accessibility
///
/// The whole widget is wrapped in [ExcludeSemantics] — the source marks every
/// block `aria-hidden="true"`. A skeleton is decorative; announce loading on the
/// *container* instead, so assistive technology hears one message rather than
/// twelve.
class DabblerSkeleton extends StatefulWidget {
  /// A stack of [lines] bars.
  const DabblerSkeleton.text({
    super.key,
    this.lines = 3,
    this.width,
    this.height,
    this.radius,
    this.animate = true,
  })  : variant = DabblerSkeletonVariant.text,
        assert(lines >= 1, 'a text skeleton needs at least one line');

  /// One block, [width] × [height].
  const DabblerSkeleton.rect({
    super.key,
    this.width,
    this.height,
    this.radius,
    this.animate = true,
  })  : variant = DabblerSkeletonVariant.rect,
        lines = 1;

  /// An avatar well. [width] is the diameter; it defaults to
  /// [DabblerSizing.touchTargetMin] (45).
  const DabblerSkeleton.circle({
    super.key,
    this.width,
    this.animate = true,
  })  : variant = DabblerSkeletonVariant.circle,
        lines = 1,
        height = null,
        radius = null;

  /// The generic card shell: 16:9 media, then a title and a meta bar.
  const DabblerSkeleton.card({
    super.key,
    this.width,
    this.radius,
    this.animate = true,
  })  : variant = DabblerSkeletonVariant.card,
        lines = 1,
        height = null;

  /// The shape this skeleton takes.
  final DabblerSkeletonVariant variant;

  /// [DabblerSkeletonVariant.text] only — how many bars to stack.
  final int lines;

  /// Width. Null means "fill the parent" for every variant but
  /// [DabblerSkeletonVariant.circle], where it is the diameter and defaults to
  /// [DabblerSizing.touchTargetMin].
  final double? width;

  /// Bar height for [DabblerSkeletonVariant.text] (default [lineHeight]), block
  /// height for [DabblerSkeletonVariant.rect] (default
  /// [DabblerSizing.touchTargetMin]).
  final double? height;

  /// Overrides the variant's default corner radius.
  final double? radius;

  /// Whether to run the opacity pulse. Reduced-motion settings override this to
  /// false regardless.
  final bool animate;

  /// `LINE_H` in the source — the default height of a text bar.
  static const double lineHeight = 12;

  /// The source's `dbl-pulse` period: `1.2s`.
  static const Duration pulsePeriod = Duration(milliseconds: 1200);

  /// The per-line `animationDelay` the source staggers text bars by.
  static const Duration pulseStagger = Duration(milliseconds: 80);

  /// The opacity the pulse travels between — `0%,100%{opacity:1}`,
  /// `50%{opacity:.55}`.
  static const double pulseMinOpacity = 0.55;

  /// The flat opacity used when motion is off —
  /// `.dbl-pulse{animation:none;opacity:.72}` under
  /// `prefers-reduced-motion: reduce`.
  static const double reducedMotionOpacity = 0.72;

  /// The fill of every block. Flat, and never re-tinted per theme, so a
  /// placeholder does not read as brand-coloured content.
  static const Color fill = DabblerPalette.surfaceSunken;

  @override
  State<DabblerSkeleton> createState() => _DabblerSkeletonState();
}

class _DabblerSkeletonState extends State<DabblerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: DabblerSkeleton.pulsePeriod,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Runs or parks the pulse to match the current settings. Called from
  /// [build], because reduced motion arrives through the [MediaQuery].
  void _syncController(bool pulsing) {
    if (pulsing) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final bool pulsing = widget.animate && !reduceMotion;
    _syncController(pulsing);

    final Widget body = switch (widget.variant) {
      DabblerSkeletonVariant.text => _buildText(pulsing),
      DabblerSkeletonVariant.rect => _buildRect(pulsing),
      DabblerSkeletonVariant.circle => _buildCircle(pulsing),
      DabblerSkeletonVariant.card => _buildCard(pulsing),
    };

    return ExcludeSemantics(child: body);
  }

  /// One flat block, pulsing on its own [phase] of the shared cycle.
  Widget _block({
    required bool pulsing,
    required double radius,
    double? width,
    double? height,
    int phase = 0,
    Widget? child,
  }) {
    final Widget box = SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // A solid colour — the flatness the criterion asks for. No gradient
          // field is set, and no BoxShadow: DabblerElevation reserves the one
          // legal shadow for Dialog.
          color: DabblerSkeleton.fill,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
        child: child,
      ),
    );

    if (!pulsing) {
      return Opacity(
        opacity: widget.animate
            ? DabblerSkeleton.reducedMotionOpacity
            : 1,
        child: box,
      );
    }

    final double offset = phase *
        DabblerSkeleton.pulseStagger.inMilliseconds /
        DabblerSkeleton.pulsePeriod.inMilliseconds;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) => Opacity(
        opacity: pulseOpacityAt(_controller.value + offset),
        child: child,
      ),
      child: box,
    );
  }

  Widget _buildText(bool pulsing) {
    final double barHeight = widget.height ?? DabblerSkeleton.lineHeight;
    final List<Widget> bars = <Widget>[];
    for (int i = 0; i < widget.lines; i++) {
      // The source narrows the last bar of a multi-line stack to 60%.
      final bool short = widget.lines > 1 && i == widget.lines - 1;
      final Widget bar = _block(
        pulsing: pulsing,
        radius: widget.radius ?? DabblerRadius.sm,
        height: barHeight,
        phase: i,
      );
      bars.add(
        short
            ? FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: 0.6,
                child: bar,
              )
            : bar,
      );
      if (i != widget.lines - 1) {
        bars.add(const SizedBox(height: DabblerSpacing.space3));
      }
    }

    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: bars,
      ),
    );
  }

  Widget _buildRect(bool pulsing) => _block(
        pulsing: pulsing,
        radius: widget.radius ?? DabblerRadius.sm,
        width: widget.width,
        height: widget.height ?? DabblerSizing.touchTargetMin,
      );

  Widget _buildCircle(bool pulsing) {
    final double diameter = widget.width ?? DabblerSizing.touchTargetMin;
    return _block(
      pulsing: pulsing,
      radius: DabblerRadius.pill,
      width: diameter,
      height: diameter,
    );
  }

  Widget _buildCard(bool pulsing) {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.all(DabblerSpacing.space4),
      decoration: BoxDecoration(
        color: DabblerPalette.surfaceCard,
        borderRadius:
            BorderRadius.all(Radius.circular(widget.radius ?? DabblerRadius.lg)),
        border: Border.all(
          color: DabblerPalette.outlineCard,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _block(pulsing: pulsing, radius: DabblerRadius.md),
          ),
          const SizedBox(height: DabblerSpacing.space4),
          FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 0.7,
            child: _block(
              pulsing: pulsing,
              radius: DabblerRadius.sm,
              height: DabblerSkeleton.lineHeight + 4,
            ),
          ),
          const SizedBox(height: DabblerSpacing.space3),
          FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 0.45,
            child: _block(
              pulsing: pulsing,
              radius: DabblerRadius.sm,
              height: DabblerSkeleton.lineHeight,
              phase: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// The source keyframe `0%,100%{opacity:1} 50%{opacity:.55}` eased in and out,
/// sampled at [t] cycles (fractional; values outside `[0,1)` wrap).
///
/// Exposed for the test, which checks the curve's endpoints and midpoint rather
/// than pumping frames.
double pulseOpacityAt(double t) {
  final double cycle = t % 1.0;
  // 0 → .5 travels down to the minimum, .5 → 1 returns.
  final double leg = cycle < 0.5 ? cycle * 2 : (1 - cycle) * 2;
  final double eased = Curves.easeInOut.transform(leg);
  return 1 + (DabblerSkeleton.pulseMinOpacity - 1) * eased;
}
