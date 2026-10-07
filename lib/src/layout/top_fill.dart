import 'package:flutter/widgets.dart';

/// TopFill — paints the top safe-area inset in [color] over [child].
///
/// A tinted listing header bleeds up under the status bar (the Listings
/// frame's 50px status row), but the screen below it can only draw inside the
/// safe area, so the shell paints the inset here, over the page. A null
/// [color], or no inset, paints nothing and the widget is just [child].
///
/// ```dart
/// DabblerTopFill(color: bandColor, child: page);
/// ```
///
/// The strip ignores pointer input.
class DabblerTopFill extends StatelessWidget {
  /// A top fill over [child].
  const DabblerTopFill({super.key, this.color, required this.child});

  /// The colour to paint across the top inset. Null paints nothing.
  final Color? color;

  /// The content the strip is painted over.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color? fill = color;
    final double top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: <Widget>[
        Positioned.fill(child: child),
        if (fill != null && top > 0)
          PositionedDirectional(
            top: 0,
            start: 0,
            end: 0,
            height: top,
            child: IgnorePointer(child: ColoredBox(color: fill)),
          ),
      ],
    );
  }
}
