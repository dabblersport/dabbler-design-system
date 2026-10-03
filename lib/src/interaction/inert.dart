import 'package:flutter/widgets.dart';

/// Dims and disables a block of content — the DS replacement for the app's
/// hand-rolled `Opacity(opacity: <n>, child: IgnorePointer(…))`. App role.
///
/// The dimming is [disabledOpacity] (0.45), the same value every disabled DS
/// control already draws (`DabblerToggle.disabledOpacity`,
/// `DabblerSlider.disabledOpacity`), so a section the app disables reads as
/// disabled in the system's own terms. The app's 0.5 and 0.55 fold here.
///
/// While [inert], pointer input is ignored and the subtree is excluded from
/// focus traversal; semantics are kept so the content is still announced.
class DabblerInert extends StatelessWidget {
  /// Wraps [child], dimmed and non-interactive while [inert].
  const DabblerInert({super.key, required this.inert, required this.child});

  /// Whether the content is disabled.
  final bool inert;

  /// The content.
  final Widget child;

  /// The system's disabled opacity — equal to `DabblerToggle.disabledOpacity`.
  static const double disabledOpacity = 0.45;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: inert ? disabledOpacity : 1,
      child: IgnorePointer(
        ignoring: inert,
        child: ExcludeFocus(excluding: inert, child: child),
      ),
    );
  }
}
