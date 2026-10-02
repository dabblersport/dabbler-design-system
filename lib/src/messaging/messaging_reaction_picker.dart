/// Part of the `messaging_parts.dart` library — [DabblerReactionPicker] and its private button.
///
/// **Why `part`, not a separate library.** The file stood over the
/// project's 500-line house rule (`013`). These declarations were moved
/// verbatim; `part`/`part of` keeps one logical library, so private names
/// stay private and no public API changes. No exemption was recorded.
///
/// The imports are the library's — a part file declares none of its own.
part of 'messaging_parts.dart';

/// ReactionPicker — the six reactions in one pill, to choose from.
///
/// Source: `components/messaging/ReactionPicker.jsx`.
///
/// | Source | Dart |
/// |---|---|
/// | `role="group"`, `aria-label={groupLabel}` | container semantics, [groupLabel] |
/// | `padding: --space-2`, `gap: --space-1` | 6 / 3 |
/// | `--surface-card`, `1px --outline-card`, pill radius | `surfaceCard`, `borderDefault` |
/// | six 45px round buttons, `dbl-press` | 45 × 45, press scale |
/// | active fill brand, on-brand bold glyph | `brandPrimary`, `onBrand` |
/// | idle `--ink-soft` linear glyph, 19px | `textSecondary`, [glyphSize] |
/// | `aria-pressed`, `aria-label={r.label}` | `selected`, label |
class DabblerReactionPicker extends StatelessWidget {
  /// A picker.
  const DabblerReactionPicker({
    super.key,
    this.onPick,
    this.active = const <String>[],
    this.groupLabel = 'React',
  });

  /// Called with the chosen reaction key.
  final ValueChanged<String>? onPick;

  /// The keys already chosen.
  final List<String> active;

  /// The group's accessible name.
  final String groupLabel;

  /// The glyph size — `size={19}`.
  static const double glyphSize = 19;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: groupLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: DabblerRadius.pillAll,
          border: Border.all(
            color: colors.borderDefault,
            width: DabblerSizing.borderDefault,
          ),
        ),
        child: Padding(
          // CSS content-box: the 1px border sits outside the 6px padding.
          padding: const EdgeInsets.all(
            DabblerSpacing.space2 + DabblerSizing.borderDefault,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final DabblerReactionDef r
                  in DabblerReactions.all) ...<Widget>[
                if (r != DabblerReactions.all.first)
                  const SizedBox(width: DabblerSpacing.space1),
                _PickerButton(
                  def: r,
                  on: active.contains(r.key),
                  onTap: onPick == null ? null : () => onPick!(r.key),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({required this.def, required this.on, this.onTap});

  final DabblerReactionDef def;
  final bool on;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DabblerMessagingTap(
      onTap: onTap,
      label: def.label,
      selected: on,
      ringRadius: DabblerRadius.pillAll,
      child: Container(
        width: DabblerSizing.touchTargetMin,
        height: DabblerSizing.touchTargetMin,
        alignment: Alignment.center,
        decoration: on
            ? BoxDecoration(shape: BoxShape.circle, color: colors.brandPrimary)
            : null,
        child: DabblerIcon(
          def.icon,
          weight: on ? DabblerIconWeight.bold : DabblerIconWeight.linear,
          size: DabblerReactionPicker.glyphSize,
          color: on ? colors.onBrand : colors.textSecondary,
        ),
      ),
    );
  }
}
