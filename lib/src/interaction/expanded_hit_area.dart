import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lets a control that is **laid out** smaller than the touch floor still be
/// hit from an area of at least [minimum], without that area taking any
/// layout space.
///
/// Used by the `compactHitArea` options of `DabblerToggle` and `DabblerChip`:
/// the frame lays them out at their visual size (a 28px switch, a 40px pill)
/// and the 45 box of the default is dropped from layout, but a thumb that
/// lands in the missing margin still reaches the control. The inflated area
/// is hit-test only. It does not paint, does not move siblings and is
/// clipped by any ancestor whose own bounds do not contain it, so a compact
/// control needs breathing room in its parent to keep the full target.
///
/// Exported because the package's own `compactHitArea` options use it and an
/// app that lays out its own compact control can do the same.
class DabblerExpandedHitArea extends SingleChildRenderObjectWidget {
  /// Wraps [child] so hits within [minimum] of its centre reach it.
  const DabblerExpandedHitArea({
    super.key,
    required this.minimum,
    required Widget super.child,
  });

  /// The smallest hit area, width by height, centred on the child.
  final Size minimum;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderExpandedHitArea(minimum);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderObject renderObject,
  ) {
    (renderObject as _RenderExpandedHitArea).minimum = minimum;
  }
}

class _RenderExpandedHitArea extends RenderProxyBox {
  _RenderExpandedHitArea(this._minimum);

  Size _minimum;

  set minimum(Size value) {
    _minimum = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final double dx = math.max(0, (_minimum.width - size.width) / 2);
    final double dy = math.max(0, (_minimum.height - size.height) / 2);
    final Rect area = Rect.fromLTRB(
      -dx,
      -dy,
      size.width + dx,
      size.height + dy,
    );
    if (!area.contains(position)) {
      return false;
    }
    // A hit in the margin is forwarded to the child at the nearest point of
    // its own box, which is where its gesture recogniser lives.
    final Offset inside = Offset(
      position.dx.clamp(0.0, math.max(0, size.width - 0.01)),
      position.dy.clamp(0.0, math.max(0, size.height - 0.01)),
    );
    return super.hitTest(result, position: inside);
  }
}
