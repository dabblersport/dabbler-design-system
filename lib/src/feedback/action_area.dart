import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../navigation/bottom_bar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';

/// The three states the Action Area's surface can be in
/// (`ActionArea.jsx` `phase`).
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

/// How tall an expanded surface is (`ActionArea.jsx` `fit`).
enum DabblerActionAreaFit {
  /// A row: [DabblerSizing.actionAreaSize] tall, radius `9999` (the
  /// [DabblerRadius.pill] token). Toast, a labelled spinner, a progress row.
  /// The content row is centred on the cross axis.
  row,

  /// `max(contentHeight, S)` tall, radius [DabblerRadius.xxl], the content row
  /// aligned to its top with [DabblerSpacing.space5] block padding. Banner and
  /// the expanded progress card.
  content,
}

/// The accessible role the surface announces itself with — given by the
/// caller, as in the source.
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
/// Transcribed from `components/feedback/ActionArea.jsx` (values relayed by the
/// orchestrator from the source file, 2026-10-06) and its specimen
/// `components/feedback/status-feedback.card.html`. It is the shared base
/// behind `DabblerNavigationFeedback` and `DabblerNavigationActivity`; an app
/// does not normally place it directly.
///
/// ## Geometry — `S = --action-area-size`
///
/// | source | here |
/// |---|---|
/// | surface: absolute, inline-end 0, bottom 0, 1px hairline, overflow hidden | bottom/inline-end aligned over [bar], [DabblerSizing.borderDefault] border, clipped |
/// | collapsed: `S × S`, radius 9999 | [DabblerSizing.actionAreaSize], [DabblerRadius.pill] |
/// | expanded width | the bar's width |
/// | expanded height: row `S`, content `max(contentHeight, S)` | the same |
/// | expanded radius: 9999 rows, `--radius-xxl` content | [DabblerRadius.pill] / [DabblerRadius.xxl] |
/// | `glyphInset = (S − 2 − glyphSize) / 2` (border counted) | [glyphInsetFor] |
/// | glyph: inline-start `glyphInset`, bottom `glyphInset` — or top 15 when `glyphAtTop` and expanded | the same; 15 is [DabblerSpacing.space5] |
/// | content box: absolute, insetInline 0, bottom 0, flex row, gap `--space-3`, minHeight `S − 2` | a bottom-pinned [Row], [DabblerSpacing.space3] apart |
/// | alignItems: center (row) / flex-start (content) | [CrossAxisAlignment.center] / [CrossAxisAlignment.start] |
/// | paddingBlock 15, content fit only | [DabblerSpacing.space5] |
/// | paddingInlineStart `glyph ? glyphInset × 2 + glyphSize + 6 : 15`; end 15 | [contentStartFor] (6 is [DabblerSpacing.space2]); [DabblerSpacing.space5] |
///
/// Absolute children are placed in the surface's padding box, i.e. inside the
/// 1px border, exactly as CSS places them; that is why the glyph inset counts
/// the border twice and the content box is `S − 2` tall.
///
/// ## Motion
///
/// | change | duration |
/// |---|---|
/// | width, height, border-radius | [DabblerMotion.slow], [DabblerMotion.easeOut] |
/// | background, border-color, color | [DabblerMotion.base] |
/// | expanding: content opacity | [DabblerMotion.base], **after** the growth ([DabblerMotion.slow]) |
/// | collapsing: content opacity | [DabblerMotion.fast]; the size change waits that long first |
/// | bar opacity | [DabblerMotion.base] |
///
/// Never a scale. Under reduced motion only background, colour and opacity
/// animate — the size jumps.
///
/// ## The bar underneath
///
/// Opacity 0, inert (no hit testing, no focus) and `aria-hidden` (excluded
/// from semantics) **only while [phase] is expanded**. Collapsed, it stays
/// live beside the circle.
///
/// ## Direction
///
/// The surface follows the bar: inline-end anchored, so under RTL it
/// originates on the left and grows rightward with the glyph leading on the
/// right. If [bar] pins its layout ([DabblerNavigationBottomBar.mirrorInRtl]
/// false) the surface pins with it, so it always sits over the action.
///
/// ## Safe area
///
/// The device's bottom inset is applied once, below both the bar and the
/// surface ([safeArea]); the bar's own inset is removed so they cannot stack.
///
/// ## Accessibility
///
/// The surface carries [SemanticsRole.status] or [SemanticsRole.alert]
/// ([role]) — a live region by definition — and is excluded from semantics
/// while idle. The content is out of the focus order unless expanded (the
/// source's `tabIndex = -1`). [onPause] / [onResume] are the source's
/// mouse-enter/focus and leave/blur on the surface.
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
    this.glyphSize = DabblerSizing.iconMd,
    this.glyphAtTop = false,
    this.children = const <Widget>[],
    this.overlay,
    this.role = DabblerActionAreaRole.status,
    this.semanticLabel,
    this.onPause,
    this.onResume,
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

  /// The ink [glyph] and [children] inherit, through [IconTheme] and
  /// [DefaultTextStyle]. Defaults to [DabblerColors.textPrimary].
  final Color? ink;

  /// The glyph — a tone icon, a spinner, a ring. Null draws none, and the
  /// content then starts [DabblerSpacing.space5] in.
  final Widget? glyph;

  /// The glyph's box — 24 by default, 32 for the ring.
  final double glyphSize;

  /// Whether the glyph moves to the top (15 in) once expanded. Otherwise it
  /// stays bottom-anchored.
  final bool glyphAtTop;

  /// The content box's flex row. They fade in only after the surface has
  /// grown, and out before it shrinks.
  final List<Widget> children;

  /// Painted over the content box (in its own padding-free frame), for a
  /// target the source pulls out with negative margins — the banner's
  /// dismiss. Position it with [PositionedDirectional].
  final Widget? overlay;

  /// `role="status"` or `role="alert"`.
  final DabblerActionAreaRole role;

  /// An optional accessible name for the surface.
  final String? semanticLabel;

  /// Pointer entered, or focus arrived inside, the surface.
  final VoidCallback? onPause;

  /// Pointer left and focus left the surface.
  final VoidCallback? onResume;

  /// Whether to pad the block end by the device's bottom inset. Zero under an
  /// ancestor [SafeArea].
  final bool safeArea;

  /// `glyphInset = (S − 2 − glyphSize) / 2` — the border counted on both
  /// sides, so the glyph is centred in the collapsed circle.
  static double glyphInsetFor(double glyphSize) =>
      (DabblerSizing.actionAreaSize -
          DabblerSizing.borderDefault * 2 -
          glyphSize) /
      2;

  /// `paddingInlineStart = glyph ? glyphInset × 2 + glyphSize + 6 : 15`.
  static double contentStartFor({required bool hasGlyph, double? glyphSize}) {
    if (!hasGlyph) return DabblerSpacing.space5;
    final double size = glyphSize ?? DabblerSizing.iconMd;
    return glyphInsetFor(size) * 2 + size + DabblerSpacing.space2;
  }

  /// Identifies the morphing surface, so a test can measure it.
  static const Key surfaceKey = Key('DabblerActionArea.surface');

  /// Identifies the glyph's box.
  static const Key glyphKey = Key('DabblerActionArea.glyph');

  /// Identifies the content box whose opacity fades.
  static const Key contentKey = Key('DabblerActionArea.content');

  /// Identifies the bar layer.
  static const Key barKey = Key('DabblerActionArea.bar');

  /// From the expanded phase to content fully visible: the growth, then the
  /// content fade. Under reduced motion only the fade.
  static Duration expandDuration({required bool reduceMotion}) =>
      (reduceMotion ? Duration.zero : DabblerMotion.slow) + DabblerMotion.base;

  /// From content visible to the circle: the content fade, then the shrink.
  /// Under reduced motion only the fade.
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

  /// Whether the content box is (fading) in. True from the first frame when
  /// mounted expanded, so a pinned specimen renders complete.
  late bool _contentShown = widget.phase == DabblerActionAreaPhase.expanded;

  Timer? _step;
  bool _hovered = false;
  bool _focused = false;

  bool get _reduceMotion => DabblerMotion.reduceMotion(context);

  @override
  void didUpdateWidget(DabblerActionArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.phase != oldWidget.phase) {
      _step?.cancel();
      _step = null;
      widget.phase == DabblerActionAreaPhase.expanded ? _expand() : _contract();
    }
  }

  /// Grow first (`--motion-slow`), then let the content in — the source's
  /// opacity transition delayed by `--motion-slow`.
  void _expand() {
    if (_reduceMotion) {
      _growth.value = 1;
      _contentShown = true;
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

  /// Let the content out first (`--motion-fast`), then shrink — the source's
  /// size transition delayed by `--motion-fast`.
  void _contract() {
    final bool wasShown = _contentShown;
    _contentShown = false;
    void shrink() {
      if (!mounted || widget.phase == DabblerActionAreaPhase.expanded) return;
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

  void _engage({bool? hovered, bool? focused}) {
    final bool before = _hovered || _focused;
    _hovered = hovered ?? _hovered;
    _focused = focused ?? _focused;
    final bool after = _hovered || _focused;
    if (after == before) return;
    after ? widget.onPause?.call() : widget.onResume?.call();
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
    // direction — pinned LTR when the bar does not mirror.
    final TextDirection layout = widget.bar.mirrorInRtl
        ? ambient
        : TextDirection.ltr;
    final bool idle = widget.phase == DabblerActionAreaPhase.idle;
    final bool expanded = widget.phase == DabblerActionAreaPhase.expanded;

    // Idle borrows the action's own fill, so idle → collapsed cross-fades the
    // brand action into the surface instead of popping.
    final _SurfacePaint paint = _SurfacePaint(
      fill: idle ? colors.brandPrimary : widget.surface ?? colors.surfaceCard,
      hairline: idle
          ? colors.brandPrimary
          : widget.hairline ?? colors.borderDefault,
      ink: widget.ink ?? colors.textPrimary,
    );

    final Widget bar = MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: widget.bar,
    );

    final Widget area = Stack(
      alignment: layout == TextDirection.ltr
          ? Alignment.bottomRight
          : Alignment.bottomLeft,
      children: <Widget>[
        KeyedSubtree(
          key: DabblerActionArea.barKey,
          child: AnimatedOpacity(
            opacity: expanded ? 0 : 1,
            duration: DabblerMotion.base,
            curve: DabblerMotion.easeOut,
            child: IgnorePointer(
              ignoring: expanded,
              child: ExcludeFocus(
                excluding: expanded,
                child: ExcludeSemantics(excluding: expanded, child: bar),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _growth,
          builder: (BuildContext context, Widget? _) {
            final bool visible = !idle || _growth.value > 0;
            return AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: DabblerMotion.base,
              curve: DabblerMotion.easeOut,
              child: IgnorePointer(
                ignoring: !visible,
                child: ExcludeSemantics(
                  excluding: idle,
                  child: _surface(_growth.value, layout, paint),
                ),
              ),
            );
          },
        ),
      ],
    );

    if (!widget.safeArea) return area;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: area,
    );
  }

  Widget _surface(double t, TextDirection layout, _SurfacePaint target) {
    const double size = DabblerSizing.actionAreaSize;
    const double border = DabblerSizing.borderDefault;
    final bool content = widget.fit == DabblerActionAreaFit.content;
    final bool expanded = widget.phase == DabblerActionAreaPhase.expanded;
    // `border-radius` transitions with the size: 9999 → xxl for content.
    final BorderRadius radius = BorderRadius.circular(
      content
          ? lerpDouble(DabblerRadius.pill, DabblerRadius.xxl, t)!
          : DabblerRadius.pill,
    );
    final bool leadingLeft = layout == TextDirection.ltr;
    final bool hasGlyph = widget.glyph != null;
    final double inset = DabblerActionArea.glyphInsetFor(widget.glyphSize);
    final bool atTop = widget.glyphAtTop && expanded;

    final Widget contentBox = AnimatedOpacity(
      key: DabblerActionArea.contentKey,
      opacity: _contentShown ? 1 : 0,
      duration: _contentShown ? DabblerMotion.base : DabblerMotion.fast,
      curve: DabblerMotion.easeOut,
      child: ExcludeFocus(
        excluding: !expanded,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: DabblerActionArea.contentStartFor(
                  hasGlyph: hasGlyph,
                  glyphSize: widget.glyphSize,
                ),
                end: DabblerSpacing.space5,
                top: content ? DabblerSpacing.space5 : 0,
                bottom: content ? DabblerSpacing.space5 : 0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: content
                      ? 0
                      : size - border * 2,
                ),
                child: Row(
                  crossAxisAlignment: content
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  spacing: DabblerSpacing.space3,
                  children: widget.children,
                ),
              ),
            ),
            ?widget.overlay,
          ],
        ),
      ),
    );

    return TweenAnimationBuilder<_SurfacePaint>(
      tween: _SurfacePaintTween(end: target),
      duration: DabblerMotion.base,
      curve: DabblerMotion.easeOut,
      builder: (BuildContext context, _SurfacePaint p, Widget? _) {
        final Widget inner = Stack(
          children: <Widget>[
            _GrowingSurface(
              t: t,
              extent: size - border * 2,
              fitContent: content,
              leadingLeft: leadingLeft,
              border: border,
              child: contentBox,
            ),
            if (hasGlyph)
              Positioned(
                key: DabblerActionArea.glyphKey,
                left: leadingLeft ? inset : null,
                right: leadingLeft ? null : inset,
                top: atTop ? DabblerSpacing.space5 : null,
                bottom: atTop ? null : inset,
                width: widget.glyphSize,
                height: widget.glyphSize,
                child: Center(child: widget.glyph),
              ),
          ],
        );
        return Semantics(
          container: true,
          explicitChildNodes: true,
          role: widget.role == DabblerActionAreaRole.alert
              ? SemanticsRole.alert
              : SemanticsRole.status,
          label: widget.semanticLabel,
          child: MouseRegion(
            onEnter: (_) => _engage(hovered: true),
            onExit: (_) => _engage(hovered: false),
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onFocusChange: (bool f) => _engage(focused: f),
              child: DecoratedBox(
                key: DabblerActionArea.surfaceKey,
                decoration: BoxDecoration(
                  color: p.fill,
                  borderRadius: radius,
                  border: Border.all(color: p.hairline, width: border),
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: Padding(
                    // Absolute children sit in the padding box, inside the
                    // 1px border.
                    padding: const EdgeInsets.all(border),
                    child: IconTheme.merge(
                      data: IconThemeData(color: p.ink),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(color: p.ink),
                        child: inner,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Background, border colour and ink, interpolated together over
/// `--motion-base`.
@immutable
class _SurfacePaint {
  const _SurfacePaint({
    required this.fill,
    required this.hairline,
    required this.ink,
  });

  final Color fill;
  final Color hairline;
  final Color ink;

  @override
  bool operator ==(Object other) =>
      other is _SurfacePaint &&
      other.fill == fill &&
      other.hairline == hairline &&
      other.ink == ink;

  @override
  int get hashCode => Object.hash(fill, hairline, ink);
}

class _SurfacePaintTween extends Tween<_SurfacePaint> {
  _SurfacePaintTween({super.end});

  @override
  _SurfacePaint lerp(double t) => _SurfacePaint(
    fill: Color.lerp(begin!.fill, end!.fill, t)!,
    hairline: Color.lerp(begin!.hairline, end!.hairline, t)!,
    ink: Color.lerp(begin!.ink, end!.ink, t)!,
  );
}

/// The surface's padding box. Lays the content box out at the **full**
/// grown width and its natural height, and sizes itself between the
/// collapsed `S − 2` square (t = 0) and the expanded padding box (t = 1):
/// the offered width, and for a content fit `max(contentHeight, S) − 2`.
///
/// The content box is pinned to the **bottom, leading** corner — the source's
/// `insetInline: 0; bottom: 0` — so whatever overflows the current size is
/// clipped at the top and at the trailing edge by the surface.
///
/// A render object rather than an implicit size animation because the
/// content-fit target is the content's measured height, which no implicit
/// widget exposes before the growth starts.
class _GrowingSurface extends SingleChildRenderObjectWidget {
  const _GrowingSurface({
    required this.t,
    required this.extent,
    required this.fitContent,
    required this.leadingLeft,
    required this.border,
    super.child,
  });

  final double t;
  final double extent;
  final bool fitContent;
  final bool leadingLeft;
  final double border;

  @override
  _RenderGrowingSurface createRenderObject(BuildContext context) =>
      _RenderGrowingSurface(
        t: t,
        extent: extent,
        fitContent: fitContent,
        leadingLeft: leadingLeft,
        border: border,
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
      ..leadingLeft = leadingLeft
      ..border = border;
  }
}

class _RenderGrowingSurface extends RenderShiftedBox {
  _RenderGrowingSurface({
    required double t,
    required double extent,
    required bool fitContent,
    required bool leadingLeft,
    required double border,
  }) : _t = t,
       _extent = extent,
       _fitContent = fitContent,
       _leadingLeft = leadingLeft,
       _border = border,
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

  double _border;
  set border(double value) {
    if (value == _border) return;
    _border = value;
    markNeedsLayout();
  }

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

  /// `max(contentHeight, S)` on the border box, i.e. minus both borders here.
  double _fullHeight(double childHeight) => _fitContent
      ? (childHeight - _border * 2).clamp(_extent, double.infinity)
      : _extent;

  Size _sizeFor(BoxConstraints constraints, double width, double childH) =>
      constraints.constrain(
        Size(
          lerpDouble(_extent, width, _t)!,
          lerpDouble(_extent, _fullHeight(childH), _t)!,
        ),
      );

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final double width = _fullWidth(constraints);
    final double childH =
        child?.getDryLayout(_childConstraints(width)).height ?? _extent;
    return _sizeFor(constraints, width, childH);
  }

  @override
  void performLayout() {
    final double width = _fullWidth(constraints);
    final RenderBox? box = child;
    if (box == null) {
      size = _sizeFor(constraints, width, _extent);
      return;
    }
    box.layout(_childConstraints(width), parentUsesSize: true);
    size = _sizeFor(constraints, width, box.size.height);
    final BoxParentData data = box.parentData! as BoxParentData;
    data.offset = Offset(
      _leadingLeft ? 0 : size.width - box.size.width,
      size.height - box.size.height,
    );
  }
}
