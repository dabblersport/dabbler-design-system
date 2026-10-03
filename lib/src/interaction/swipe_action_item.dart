part of 'swipe_action.dart';

/// The fill of a [DabblerSwipeActionItem], drawn from roles that already
/// exist: each tone resolves through [DabblerButton]'s own fill and ink, so a
/// revealed action and a button of the same tone are the same colour.
enum DabblerSwipeActionTone {
  /// `--color-status-error-solid` with paper ink — hide, delete, remove.
  destructive(DabblerButtonTone.destructive),

  /// `surfaceSunken` with `textPrimary` ink — mute, archive, more.
  neutral(DabblerButtonTone.neutral),

  /// `brandPrimary` with `onBrand` ink — pin, save.
  brand(DabblerButtonTone.primary);

  const DabblerSwipeActionTone(this.buttonTone);

  /// The [DabblerButtonTone] whose fill and ink this tone borrows.
  final DabblerButtonTone buttonTone;
}

/// One action revealed by [DabblerSwipeAction].
@immutable
class DabblerSwipeActionItem {
  /// An action labelled [label], with the Iconsax [icon], firing [onPressed].
  const DabblerSwipeActionItem({
    required this.label,
    required this.onPressed,
    this.icon,
    this.tone = DabblerSwipeActionTone.neutral,
  });

  /// The visible label, and the screen-reader custom action's name.
  final String label;

  /// The kebab-case Iconsax name drawn above [label]. Null draws the label
  /// alone.
  final String? icon;

  /// The fill and ink.
  final DabblerSwipeActionTone tone;

  /// Fired when the action is tapped, or invoked by a screen reader. The row
  /// closes after it fires.
  final VoidCallback onPressed;
}

/// One revealed action box: full row height, [DabblerSwipeAction.actionWidth]
/// wide, never under the 45px touch target on either axis.
class _ActionBox extends StatelessWidget {
  const _ActionBox({required this.item, required this.onTap});

  final DabblerSwipeActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Color fill = DabblerButton.backgroundFor(
      colors,
      item.tone.buttonTone,
    );
    final Color ink = DabblerButton.foregroundFor(colors, item.tone.buttonTone);
    return Semantics(
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: DabblerSizing.touchTargetMin,
            minHeight: DabblerSizing.touchTargetMin,
          ),
          child: ColoredBox(
            color: fill,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DabblerSpacing.space1,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (item.icon != null) ...<Widget>[
                      DabblerIcon(
                        item.icon!,
                        size: DabblerSizing.iconSm,
                        color: ink,
                      ),
                      const SizedBox(height: DabblerSpacing.space1),
                    ],
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: DabblerType.caption1
                          .resolveForDirection(Directionality.of(context))
                          .copyWith(color: ink, fontWeight: DabblerType.medium),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
