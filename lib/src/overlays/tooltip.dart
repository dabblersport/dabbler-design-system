import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// Where a [DabblerTooltip] sits relative to the control it labels —
/// `TooltipPlacement` in `components/overlays/Tooltip.d.ts`.
///
/// [start] and [end] are **inline** edges, not left and right, so they mirror
/// under RTL exactly as the source's `insetInlineStart` / `insetInlineEnd` do.
enum DabblerTooltipPlacement {
  /// Above the control. The source's default.
  top,

  /// Below the control.
  bottom,

  /// At the inline start of the control.
  start,

  /// At the inline end of the control.
  end,
}

/// Tooltip — a short label for a control that carries no visible text.
///
/// Transcribed from `components/overlays/Tooltip.jsx`. **This component did
/// not exist in the package before this pass**: the design draws it on
/// `components/overlays/overlays.card.html`, beside `Menu`, and the Flutter
/// cut skipped it, so an icon-only control had no way to name itself visually.
///
/// ## Ink on paper, inverted
///
/// The one place in the system where the page's ink becomes the fill: a
/// [DabblerColors.textPrimary] panel carrying [DabblerColors.surfaceCard] text
/// at [DabblerType.caption1], [DabblerRadius.sm] corners, `6px 9px` padding,
/// capped at 220 wide, **no arrow** (`Tooltip.jsx:8`).
///
/// ## Flat
///
/// No shadow: the one legal shadow in the system belongs to Dialog.
///
/// ## Never the only carrier
///
/// The source is emphatic, and it is repeated here because it governs how the
/// widget may be used rather than how it looks: a tooltip is *"unavailable to
/// touch users who tap rather than hold, invisible in print, and gone the
/// moment the pointer moves"*. Anything the user must know belongs in the
/// interface. [message] is therefore also published as the subtree's
/// [Semantics.tooltip], so a screen reader reads it whether or not the visual
/// panel is ever shown.
///
/// ## Opening
///
/// Hover or keyboard focus after [delay] (400ms), long-press after
/// [touchDelay] (450ms), as the source does. It closes on exit, blur, pointer
/// release and cancel.
class DabblerTooltip extends StatefulWidget {
  /// Wraps [child] — **the specific control**, never a whole card or row.
  const DabblerTooltip({
    super.key,
    required this.message,
    required this.child,
    this.placement = DabblerTooltipPlacement.top,
    this.delay = defaultDelay,
    this.touchDelay = defaultTouchDelay,
  });

  /// The label. A few words, sentence case.
  final String message;

  /// The control being labelled.
  final Widget child;

  /// Which edge the panel sits on. `top` by default (`Tooltip.jsx:19`).
  final DabblerTooltipPlacement placement;

  /// Hover / focus delay — `delay = 400` (`Tooltip.jsx:20`).
  final Duration delay;

  /// Long-press delay — the source's second, longer 450ms timer
  /// (`Tooltip.jsx:58`).
  final Duration touchDelay;

  /// 400ms.
  static const Duration defaultDelay = Duration(milliseconds: 400);

  /// 450ms.
  static const Duration defaultTouchDelay = Duration(milliseconds: 450);

  /// `maxWidth: 220` (`Tooltip.jsx:70`). Not on any ramp; transcribed.
  static const double maxWidth = 220;

  /// `calc(100% + var(--space-2))` — the gap between control and panel
  /// (`Tooltip.jsx:38,44`).
  static const double gap = DabblerSpacing.space2;

  @override
  State<DabblerTooltip> createState() => _DabblerTooltipState();
}

class _DabblerTooltipState extends State<DabblerTooltip> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _show(Duration after) {
    _timer?.cancel();
    _timer = Timer(after, () {
      if (mounted) {
        _controller.show();
      }
    });
  }

  void _hide() {
    _timer?.cancel();
    if (_controller.isShowing) {
      _controller.hide();
    }
  }

  /// The panel's own anchor point and the follower point on the control, for
  /// each of the four placements. Both are resolved through the ambient
  /// [Directionality], so `start` and `end` mirror.
  ({Alignment target, Alignment follower, Offset offset}) _anchor(
    TextDirection direction,
  ) {
    return switch (widget.placement) {
      DabblerTooltipPlacement.top => (
          target: Alignment.topCenter,
          follower: Alignment.bottomCenter,
          offset: const Offset(0, -DabblerTooltip.gap),
        ),
      DabblerTooltipPlacement.bottom => (
          target: Alignment.bottomCenter,
          follower: Alignment.topCenter,
          offset: const Offset(0, DabblerTooltip.gap),
        ),
      DabblerTooltipPlacement.start => (
          target: AlignmentDirectional.centerStart.resolve(direction),
          follower: AlignmentDirectional.centerEnd.resolve(direction),
          offset: Offset(
            direction == TextDirection.rtl
                ? DabblerTooltip.gap
                : -DabblerTooltip.gap,
            0,
          ),
        ),
      DabblerTooltipPlacement.end => (
          target: AlignmentDirectional.centerEnd.resolve(direction),
          follower: AlignmentDirectional.centerStart.resolve(direction),
          offset: Offset(
            direction == TextDirection.rtl
                ? -DabblerTooltip.gap
                : DabblerTooltip.gap,
            0,
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final ({Alignment target, Alignment follower, Offset offset}) anchor =
        _anchor(direction);

    final Widget panel = Container(
      constraints: const BoxConstraints(maxWidth: DabblerTooltip.maxWidth),
      // `padding: '6px 9px'` (`Tooltip.jsx:74`) — `--space-2` / `--space-3`.
      padding: const EdgeInsets.symmetric(
        vertical: DabblerSpacing.space2,
        horizontal: DabblerSpacing.space3,
      ),
      decoration: BoxDecoration(
        // `background: var(--ink); color: var(--paper)` — the inversion.
        color: colors.textPrimary,
        borderRadius: DabblerRadius.smAll,
      ),
      child: Text(
        widget.message,
        style: DabblerType.caption1
            .resolveForDirection(direction)
            .copyWith(color: colors.surfaceCard),
      ),
    );

    final Widget host = CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (BuildContext context) => Positioned(
          // `pointerEvents: 'none'` (`Tooltip.jsx:75`) — the panel never
          // intercepts the gesture that is keeping it open.
          child: IgnorePointer(
            child: CompositedTransformFollower(
              link: _link,
              targetAnchor: anchor.target,
              followerAnchor: anchor.follower,
              offset: anchor.offset,
              child: Directionality(
                textDirection: direction,
                child: panel,
              ),
            ),
          ),
        ),
        child: widget.child,
      ),
    );

    return Semantics(
      // The visual panel is a confirmation; this is the carrier a screen
      // reader actually gets.
      tooltip: widget.message,
      child: MouseRegion(
        onEnter: (_) => _show(widget.delay),
        onExit: (_) => _hide(),
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: (bool focused) =>
              focused ? _show(widget.delay) : _hide(),
          child: Listener(
            onPointerDown: (PointerDownEvent event) {
              if (event.kind == PointerDeviceKind.touch) {
                _show(widget.touchDelay);
              }
            },
            onPointerUp: (_) => _hide(),
            onPointerCancel: (_) => _hide(),
            child: host,
          ),
        ),
      ),
    );
  }
}
