part of 'page.dart';

/// The floating-overlay half of [DabblerPage] (KAN-412 W1 gap 7).
///
/// A `part`, not a separate library, because [DabblerPage._wrapOverlay] and the
/// stack are private to the page.
extension _DabblerPageOverlay on DabblerPage {
  /// [DabblerPage.bottomOverlay] in its fade and padding.
  Widget _wrapOverlay() {
    final Widget bar = bottomOverlay!;
    if (overlayFade) {
      return DabblerFade(
        padding: overlayPadding ?? DabblerPage.overlayPaddingDefault,
        child: bar,
      );
    }
    final EdgeInsetsGeometry? padding = overlayPadding;
    return padding == null ? bar : Padding(padding: padding, child: bar);
  }
}

/// Stacks [overlay] at the bottom of the space the body fills, measures it, and
/// raises the body's `MediaQuery` bottom padding by that height.
class _DabblerPageOverlayStack extends StatefulWidget {
  const _DabblerPageOverlayStack({
    required this.safeTop,
    required this.overlay,
    required this.body,
  });

  final bool safeTop;
  final Widget overlay;
  final Widget body;

  @override
  State<_DabblerPageOverlayStack> createState() =>
      _DabblerPageOverlayStackState();
}

class _DabblerPageOverlayStackState extends State<_DabblerPageOverlayStack> {
  double _height = 0;

  void _measured(double height) {
    if (!mounted || height == _height) return;
    setState(() => _height = height);
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    // The overlay pads its own home-indicator inset, so its measured height
    // *replaces* the bottom inset rather than adding to it.
    final MediaQueryData inset = media.copyWith(
      padding: media.padding.copyWith(bottom: _height),
      viewPadding: media.viewPadding.copyWith(bottom: _height),
    );
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: MediaQuery(
            data: inset,
            child: SafeArea(
              top: widget.safeTop,
              bottom: false,
              child: widget.body,
            ),
          ),
        ),
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          child: _SizeReporter(onSize: _measured, child: widget.overlay),
        ),
      ],
    );
  }
}

/// Reports its child's height after layout, on the next frame.
class _SizeReporter extends SingleChildRenderObjectWidget {
  const _SizeReporter({required this.onSize, required super.child});

  final ValueChanged<double> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSizeReporter(onSize);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderSizeReporter renderObject,
  ) {
    renderObject.onSize = onSize;
  }
}

class _RenderSizeReporter extends RenderProxyBox {
  _RenderSizeReporter(this.onSize);

  ValueChanged<double> onSize;
  double? _last;

  @override
  void performLayout() {
    super.performLayout();
    final double height = size.height;
    if (height == _last) return;
    _last = height;
    SchedulerBinding.instance.addPostFrameCallback((_) => onSize(height));
  }
}
