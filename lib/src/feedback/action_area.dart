import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../navigation/bottom_bar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';

/// The three states the Action Area's surface can be in, transcribed from the
/// *Sequence* table of `status-feedback.card.html`.
enum DabblerActionAreaPhase {
  /// The real [DabblerNavigationBottomBar], untouched. No surface.
  idle,

  /// A [DabblerSizing.actionAreaSize] circle on the action footprint carrying
  /// the glyph. The bar stays live beside it.
  collapsed,

  /// The surface has grown along the inline axis to the bar's width (and, for
  /// [DabblerActionAreaFit.content], up to its content). The bar fades under
  /// it and is inert.
  expanded,
}

/// How tall an expanded surface is.
enum DabblerActionAreaFit {
  /// A row: [DabblerSizing.actionAreaSize] tall, [DabblerRadius.pill]. Toast,
  /// a labelled spinner, a progress row.
  row,

  /// Grown up to its content, never shorter than a row, radius easing to
  /// [DabblerRadius.xxl] — the create menu's radius. Banner and the expanded
  /// progress card.
  content,
}

/// The accessible role the surface announces itself with.
enum DabblerActionAreaRole {
  /// `role="status"` — polite. Activity, toasts and non-interrupting banners.
  status,

  /// `role="alert"` — interrupting. Error and warning banners only.
  alert,
}

/// Action Area — the bottom navigation as one surface for loading, progress
/// and status: the **real** [DabblerNavigationBottomBar], and one morphing
/// surface over its action footprint.
///
/// Transcribed from `components/feedback/ActionArea.jsx` as rendered on
/// `components/feedback/status-feedback.card.html` (*Action Area · system
/// states*, *Navigation interaction preview* — the `.jsx` itself was not
/// readable from this session, so the card's sequence table, geometry table
/// and usage notes are the source). It is the shared base behind
/// `DabblerNavigationFeedback` and `DabblerNavigationActivity`; an app does not
/// normally place it directly.
///
/// ## Phases
///
/// | [phase] | what is drawn |
/// |---|---|
/// | [DabblerActionAreaPhase.idle] | the bar alone |
/// | [DabblerActionAreaPhase.collapsed] | a [DabblerSizing.actionAreaSize] circle over the action, [glyph] centred |
/// | [DabblerActionAreaPhase.expanded] | the surface grown to the bar's width; [fit] decides the height |
///
/// The surface **originates on the action** at the inline end and grows
/// toward the inline start (and, for [DabblerActionAreaFit.content], upward
/// from the bar's baseline). [glyph] sits in a [DabblerSizing.actionAreaSize]
/// square anchored to the surface's **leading** edge, so it rides the growth
/// rather than staying behind on the action.
///
/// ## Sequence
///
/// * **Expand** — the surface's width (and height) grow over
///   [DabblerMotion.slow] on [DabblerMotion.easeOut]; only once it has room
///   does [child] fade in, over [DabblerMotion.base]. The bar fades under the
///   surface and becomes inert.
/// * **Contract** — [child] fades out first, over [DabblerMotion.fast], then
///   the surface shrinks back to the circle over [DabblerMotion.slow].
///
/// The phase itself is the caller's: this widget holds no lifecycle beyond
/// the order of those two steps. `DabblerNavigationFeedback` adds the
/// [DabblerMotion.actionAreaHold] timing; an app composes the rest.
///
/// ## Motion
///
/// Only width, height, radius, background, border colour and opacity
/// animate — **never a scale**, so text never zooms. Under reduced motion
/// ([MediaQueryData.disableAnimations]) the size transitions are dropped and
/// only opacity animates.
///
/// ## Colours are the caller's
///
/// [surface], [hairline] and [ink] are passed in; this widget paints no
/// colour of its own. `DabblerNavigationFeedback` passes the status tone
/// triple ([DabblerStatusToneColors]); `DabblerNavigationActivity` passes the
/// brand circle or the card row.
///
/// ## Direction
///
/// The surface follows the bar: anchored at the inline end, so under RTL it
/// originates on the left and grows rightward with the glyph leading on the
/// right. If [bar] pins its layout ([DabblerNavigationBottomBar.mirrorInRtl]
/// false) the surface pins with it, so it always sits over the action.
///
/// ## Safe area and width
///
/// The surface takes the bar's width and never sets a fixed width. The
/// device's bottom inset is applied **once, here**, below both the bar and
/// the surface ([safeArea]); the bar's own inset is removed so the two cannot
/// stack.
///
/// ## Accessibility
///
/// The surface carries [SemanticsRole.status] or [SemanticsRole.alert]
/// ([role]) — a live region by definition — and is excluded from semantics
/// while idle. While the surface is wider than the circle the navigation
/// underneath is excluded from semantics, focus and hit testing (the
/// source's `aria-hidden` + `inert`), and it recovers the moment the surface
/// is a circle again.
class DabblerActionArea extends StatefulWidget {
  /// Creates an Action Area over [bar].
  const DabblerActionArea({
    super.key,
    this.bar = const DabblerNavigationBottomBar(),
    this.phase = DabblerActionAreaPhase.idle,
    this.fit = DabblerActionAreaFit.row,
    this.surface,
    this.hairline,
    this.ink,
    this.glyph,
    this.keepGlyph = true,
    this.child,
    this.role = DabblerActionAreaRole.status,
    this.semanticLabel,
    this.safeArea = true,
  });

  /// The real bottom navigation. Rendered verbatim; its own safe-area inset is
  /// removed in favour of [safeArea].
  final DabblerNavigationBottomBar bar;

  /// Which state the surface is in. The caller drives it.
  final DabblerActionAreaPhase phase;

  /// Row or content height once expanded.
  final DabblerActionAreaFit fit;

  /// The surface fill. Defaults to [DabblerColors.surfaceCard].
  final Color? surface;

  /// The 1px outline. Defaults to [DabblerColors.borderDefault].
  final Color? hairline;

  /// The ink [glyph] and [child] inherit, through [IconTheme] and
  /// [DefaultTextStyle]. Defaults to [DabblerColors.textPrimary].
  final Color? ink;

  /// The circle's content — a tone glyph, a spinner, a ring — centred in the
  /// [DabblerSizing.actionAreaSize] square at the surface's leading edge.
  final Widget? glyph;

  /// Whether [glyph] stays once expanded. Toasts, banners and the labelled
  /// spinner keep it; the progress rows drop it (*"the bar is the indicator;
  /// the ring or Spinner appears only in the collapsed circle"*), in which
  /// case it fades out as [child] fades in.
  final bool keepGlyph;

  /// The expanded content, laid out across the full surface width. Reserve
  /// [glyphSlot] at the inline start when [keepGlyph] is true. It fades in
  /// only after the surface has grown, and out before it shrinks.
  final Widget? child;

  /// `role="status"` or `role="alert"`.
  final DabblerActionAreaRole role;

  /// An optional accessible name for the surface. The content normally
  /// names itself.
  final String? semanticLabel;

  /// Whether to pad the block end by the device's bottom inset. Zero under an
  /// ancestor [SafeArea].
  final bool safeArea;

  /// The leading square the glyph occupies — [DabblerSizing.actionAreaSize].
  /// Content that keeps the glyph starts after it.
  static const double glyphSlot = DabblerSizing.actionAreaSize;

  /// Identifies the morphing surface, so a test can measure it.
  static const Key surfaceKey = Key('DabblerActionArea.surface');

  /// Identifies the glyph's square.
  static const Key glyphKey = Key('DabblerActionArea.glyph');

  /// Identifies the content layer whose opacity fades.
  static const Key contentKey = Key('DabblerActionArea.content');

  /// Identifies the bar layer.
  static const Key barKey = Key('DabblerActionArea.bar');

  /// How long an expansion takes from the circle to content visible:
  /// growth, then the content fade. Under reduced motion only the fade.
  static Duration expandDuration({required bool reduceMotion}) =>
      (reduceMotion ? Duration.zero : DabblerMotion.slow) + DabblerMotion.base;

  /// How long a contraction takes from content visible to the circle: the
  /// content fade, then the shrink. Under reduced motion only the fade.
  static Duration contractDuration({required bool reduceMotion}) =>
      DabblerMotion.fast + (reduceMotion ? Duration.zero : DabblerMotion.slow);

  @override
  State<DabblerActionArea> createState() => _DabblerActionAreaState();
}

class _DabblerActionAreaState extends State<DabblerActionArea>
    with SingleTickerProviderStateMixin {
  /// 0 = the circle, 1 = fully grown.
  late final AnimationController _growth = AnimationController(
    vsync: this,
    duration: DabblerMotion.slow,
    value: widget.phase == DabblerActionAreaPhase.expanded ? 1 : 0,
  );

  /// Whether [DabblerActionArea.child] is (fading) in. True from the first
  /// frame when mounted expanded, so a pinned specimen renders complete.
  late bool _contentShown = widget.phase == DabblerActionAreaPhase.expanded;

  Timer? _step;

  bool get _reduceMotion => DabblerMotion.reduceMotion(context);

  @override
  void didUpdateWidget(DabblerActionArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.phase != oldWidget.phase) {
      _toPhase(widget.phase);
    }
  }

  void _toPhase(DabblerActionAreaPhase phase) {
    _step?.cancel();
    _step = null;
    if (phase == DabblerActionAreaPhase.expanded) {
      _expand();
    } else {
      _contract();
    }
  }

  /// Grow first, then let the content in.
  void _expand() {
    if (_reduceMotion) {
      _growth.value = 1;
      setState(() => _contentShown = true);
      return;
    }
    _growth.animateTo(1, curve: DabblerMotion.easeOut).whenCompleteOrCancel(() {
      if (mounted &&
          widget.phase == DabblerActionAreaPhase.expanded &&
          _growth.value == 1) {
        setState(() => _contentShown = true);
      }
    });
  }

  /// Let the content out first, then shrink.
  void _contract() {
    final bool wasShown = _contentShown;
    setState(() => _contentShown = false);
    void shrink() {
      if (!mounted || widget.phase == DabblerActionAreaPhase.expanded) {
        return;
      }
      if (_reduceMotion) {
        _growth.value = 0;
      } else {
        _growth.animateBack(0, curve: DabblerMotion.easeOut);
      }
    }

    if (wasShown && _growth.value > 0) {
      _step = Timer(DabblerMotion.fast, shrink);
    } else {
      shrink();
    }
  }

  @override
  void dispose() {
    _step?.cancel();
    _growth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection ambient = Directionality.of(context);
    // The surface sits over the action, so it follows the bar's layout
    // direction — which is pinned LTR when the bar does not mirror.
    final TextDirection layout = widget.bar.mirrorInRtl
        ? ambient
        : TextDirection.ltr;
    final bool reduceMotion = _reduceMotion;
    final bool idle = widget.phase == DabblerActionAreaPhase.idle;

    // Idle borrows the action's own fill, so idle → collapsed cross-fades
    // the brand action into the tone circle instead of popping.
    final Color surface = idle
        ? colors.brandPrimary
        : widget.surface ?? colors.surfaceCard;
    final Color hairline = idle
        ? colors.brandPrimary
        : widget.hairline ?? colors.borderDefault;
    final Color ink = widget.ink ?? colors.textPrimary;

    final Widget bar = MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: widget.bar,
    );

    final Widget area = AnimatedBuilder(
      animation: _growth,
      builder: (BuildContext context, Widget? _) {
        final double t = _growth.value;
        // Grown past the circle (or growing): the navigation is covered.
        final bool covered =
            widget.phase == DabblerActionAreaPhase.expanded || t > 0;
        final bool surfaceVisible = !idle || t > 0;

        return Stack(
          alignment: layout == TextDirection.ltr
              ? Alignment.bottomRight
              : Alignment.bottomLeft,
          children: <Widget>[
            KeyedSubtree(
              key: DabblerActionArea.barKey,
              child: AnimatedOpacity(
                opacity: covered ? 0 : 1,
                duration: DabblerMotion.slow,
                curve: DabblerMotion.easeOut,
                child: IgnorePointer(
                  ignoring: covered,
                  child: ExcludeFocus(
                    excluding: covered,
                    child: ExcludeSemantics(excluding: covered, child: bar),
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: surfaceVisible ? 1 : 0,
              duration: DabblerMotion.base,
              curve: DabblerMotion.easeOut,
              child: IgnorePointer(
                ignoring: !surfaceVisible,
                child: ExcludeSemantics(
                  excluding: idle,
                  child: _surface(
                    t: t,
                    layout: layout,
                    surface: surface,
                    hairline: hairline,
                    ink: ink,
                    reduceMotion: reduceMotion,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!widget.safeArea) {
      return area;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: area,
    );
  }

  Widget _surface({
    required double t,
    required TextDirection layout,
    required Color surface,
    required Color hairline,
    required Color ink,
    required bool reduceMotion,
  }) {
    const double size = DabblerSizing.actionAreaSize;
    final bool content = widget.fit == DabblerActionAreaFit.content;
    // Rows stay a pill; a content-fitted surface eases from the circle's own
    // radius to the create menu's.
    final BorderRadius radius = content
        ? BorderRadius.circular(
            lerpDouble(size / 2, DabblerRadius.xxl, t) ?? DabblerRadius.xxl,
          )
        : DabblerRadius.pillAll;
    final bool leadingLeft = layout == TextDirection.ltr;
    final Duration fade = _contentShown
        ? DabblerMotion.base
        : DabblerMotion.fast;

    final Widget? glyph = widget.glyph == null
        ? null
        : Positioned(
            key: DabblerActionArea.glyphKey,
            top: 0,
            left: leadingLeft ? 0 : null,
            right: leadingLeft ? null : 0,
            width: DabblerActionArea.glyphSlot,
            height: DabblerActionArea.glyphSlot,
            child: AnimatedOpacity(
              opacity: widget.keepGlyph || !_contentShown ? 1 : 0,
              duration: fade,
              curve: DabblerMotion.easeOut,
              child: Center(child: widget.glyph),
            ),
          );

    final Widget layer = AnimatedOpacity(
      key: DabblerActionArea.contentKey,
      opacity: _contentShown ? 1 : 0,
      duration: fade,
      curve: DabblerMotion.easeOut,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: size,
          maxHeight: content ? double.infinity : size,
        ),
        child: widget.child ?? const SizedBox.shrink(),
      ),
    );

    final Widget surfaceBox = TweenAnimationBuilder<_SurfacePaint>(
      tween: _SurfacePaintTween(
        end: _SurfacePaint(fill: surface, hairline: hairline),
      ),
      duration: DabblerMotion.base,
      curve: DabblerMotion.easeOut,
      builder: (BuildContext context, _SurfacePaint paint, Widget? child) =>
          DecoratedBox(
            key: DabblerActionArea.surfaceKey,
            decoration: BoxDecoration(
              color: paint.fill,
              borderRadius: radius,
              border: Border.all(
                color: paint.hairline,
                width: DabblerSizing.borderDefault,
              ),
            ),
            child: ClipRRect(borderRadius: radius, child: child),
          ),
      child: _GrowingSurface(
        t: t,
        extent: size,
        fitContent: content,
        leadingLeft: leadingLeft,
        child: IconTheme.merge(
          data: IconThemeData(color: ink),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: ink),
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[layer, ?glyph],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: widget.role == DabblerActionAreaRole.alert
          ? SemanticsRole.alert
          : SemanticsRole.status,
      label: widget.semanticLabel,
      child: surfaceBox,
    );
  }
}

/// The surface's two colours, interpolated together so background and
/// border cross-fade as one.
@immutable
class _SurfacePaint {
  const _SurfacePaint({required this.fill, required this.hairline});

  final Color fill;
  final Color hairline;

  @override
  bool operator ==(Object other) =>
      other is _SurfacePaint && other.fill == fill && other.hairline == hairline;

  @override
  int get hashCode => Object.hash(fill, hairline);
}

class _SurfacePaintTween extends Tween<_SurfacePaint> {
  _SurfacePaintTween({super.end});

  @override
  _SurfacePaint lerp(double t) => _SurfacePaint(
    fill: Color.lerp(begin!.fill, end!.fill, t)!,
    hairline: Color.lerp(begin!.hairline, end!.hairline, t)!,
  );
}

/// Lays its child out at the **full** grown size — the available width, and
/// either one [extent] row or the child's own height — and sizes itself
/// between the [extent] circle (t = 0) and that full size (t = 1).
///
/// The child is pinned to the surface's **leading, top** corner, so whatever
/// the child draws in its leading [extent] square (the glyph) stays at the
/// surface's leading edge while the surface grows: it rides the growth. The
/// part of the child beyond the current size is clipped by the caller.
///
/// This is a render object rather than an implicit size animation because
/// the target height of a content-fitted surface is the child's measured
/// height, which no implicit widget exposes before the growth starts.
class _GrowingSurface extends SingleChildRenderObjectWidget {
  const _GrowingSurface({
    required this.t,
    required this.extent,
    required this.fitContent,
    required this.leadingLeft,
    super.child,
  });

  final double t;
  final double extent;
  final bool fitContent;
  final bool leadingLeft;

  @override
  _RenderGrowingSurface createRenderObject(BuildContext context) =>
      _RenderGrowingSurface(
        t: t,
        extent: extent,
        fitContent: fitContent,
        leadingLeft: leadingLeft,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderGrowingSurface renderObject,
  ) {
    renderObject
      ..t = t
      ..extent = extent
      ..fitContent = fitContent
      ..leadingLeft = leadingLeft;
  }
}

class _RenderGrowingSurface extends RenderShiftedBox {
  _RenderGrowingSurface({
    required double t,
    required double extent,
    required bool fitContent,
    required bool leadingLeft,
  }) : _t = t,
       _extent = extent,
       _fitContent = fitContent,
       _leadingLeft = leadingLeft,
       super(null);

  double _t;
  set t(double value) {
    if (value == _t) return;
    _t = value;
    markNeedsLayout();
  }

  double _extent;
  set extent(double value) {
    if (value == _extent) return;
    _extent = value;
    markNeedsLayout();
  }

  bool _fitContent;
  set fitContent(bool value) {
    if (value == _fitContent) return;
    _fitContent = value;
    markNeedsLayout();
  }

  bool _leadingLeft;
  set leadingLeft(bool value) {
    if (value == _leadingLeft) return;
    _leadingLeft = value;
    markNeedsLayout();
  }

  /// The grown width: everything offered, never less than the circle.
  double _fullWidth(BoxConstraints constraints) =>
      constraints.hasBoundedWidth && constraints.maxWidth > _extent
      ? constraints.maxWidth
      : _extent;

  BoxConstraints _childConstraints(double width) => BoxConstraints(
    minWidth: width,
    maxWidth: width,
    minHeight: _extent,
    maxHeight: _fitContent ? double.infinity : _extent,
  );

  Size _sizeFor(BoxConstraints constraints, Size full) => constraints.constrain(
    Size(
      lerpDouble(_extent, full.width, _t)!,
      lerpDouble(_extent, full.height, _t)!,
    ),
  );

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final double width = _fullWidth(constraints);
    final Size full =
        child?.getDryLayout(_childConstraints(width)) ?? Size(width, _extent);
    return _sizeFor(constraints, full);
  }

  @override
  void performLayout() {
    final double width = _fullWidth(constraints);
    final RenderBox? box = child;
    if (box == null) {
      size = _sizeFor(constraints, Size(width, _extent));
      return;
    }
    box.layout(_childConstraints(width), parentUsesSize: true);
    size = _sizeFor(constraints, box.size);
    final BoxParentData data = box.parentData! as BoxParentData;
    // Pinned to the leading, top corner of the current size.
    data.offset = Offset(_leadingLeft ? 0 : size.width - box.size.width, 0);
  }
}
