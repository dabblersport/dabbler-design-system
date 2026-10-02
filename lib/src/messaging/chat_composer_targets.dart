/// Part of the `chat_composer.dart` library — the private field ring and round target widgets.
///
/// **Why `part`, not a separate library.** The file stood over the
/// project's 500-line house rule (`013`). These declarations were moved
/// verbatim; `part`/`part of` keeps one logical library, so private names
/// stay private and no public API changes. No exemption was recorded.
///
/// The imports are the library's — a part file declares none of its own.
part of 'chat_composer.dart';

/// The focus ring around the field, shown while the input holds focus.
class _FieldRing extends StatelessWidget {
  const _FieldRing({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) => DabblerFocusRing.visible(
    visible: visible,
    borderRadius: DabblerRadius.xxlAll,
    child: child,
  );
}

/// A button target: press scale, focus ring and keyboard activation when live;
/// a disabled, named button in the semantics tree when [onTap] is null (the
/// source's `<button disabled aria-label>`).
class _Target extends StatelessWidget {
  const _Target({
    required this.label,
    required this.onTap,
    required this.child,
    required this.ringRadius,
    this.scale = true,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget child;
  final BorderRadius ringRadius;
  final bool scale;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return Semantics(
        button: true,
        enabled: false,
        label: label,
        excludeSemantics: true,
        child: child,
      );
    }
    return Semantics(
      enabled: true,
      child: DabblerMessagingTap(
        onTap: onTap,
        label: label,
        ringRadius: ringRadius,
        scale: scale,
        child: child,
      ),
    );
  }
}
