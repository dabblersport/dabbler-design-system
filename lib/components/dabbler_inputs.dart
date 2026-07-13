// =============================================================================
// Dabbler — Selection controls (checkbox · radio · switch)
// -----------------------------------------------------------------------------
// Flat, token-driven companions to DabblerTextField. Every colour, size, and
// radius comes from tokens; on-brand marks read `onBrand` (never a hardcoded
// white) so Bright / Sport light primaries stay legible. Each control clears the
// 45pt tap-target floor and supports default / selected / disabled.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/dabbler_colors.dart';
import '../theme/dabbler_spacing.dart';

/// Wrap a visual control in a >= touchTargetMin square, tappable when [onTap]
/// is non-null, dimmed to half opacity when disabled.
class _TapTarget extends StatelessWidget {
  const _TapTarget({
    required this.child,
    required this.onTap,
    required this.enabled,
    this.semanticsLabel,
    this.checked,
    this.inRadioGroup = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final String? semanticsLabel;
  final bool? checked;
  final bool inRadioGroup;

  @override
  Widget build(BuildContext context) {
    Widget control = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: DabblerSizing.touchTargetMin,
        minHeight: DabblerSizing.touchTargetMin,
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: child,
      ),
    );

    if (!enabled) control = Opacity(opacity: 0.5, child: control);

    return Semantics(
      label: semanticsLabel,
      checked: inRadioGroup ? null : checked,
      inMutuallyExclusiveGroup: inRadioGroup,
      selected: inRadioGroup ? checked : null,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: control,
      ),
    );
  }
}

/// Flat checkbox: radius sm, checked fill brandPrimary, check mark onBrand.
class DabblerCheckbox extends StatelessWidget {
  const DabblerCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticsLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final enabled = onChanged != null;

    return _TapTarget(
      enabled: enabled,
      checked: value,
      semanticsLabel: semanticsLabel,
      onTap: () => onChanged?.call(!value),
      child: Container(
        width: DabblerSizing.iconMd, // 24
        height: DabblerSizing.iconMd,
        decoration: BoxDecoration(
          color: value ? d.brandPrimary : Colors.transparent,
          borderRadius: DabblerRadius.smRadius, // 6
          border: Border.all(
            color: value ? d.brandPrimary : d.borderDefault,
            // ignore: avoid_redundant_argument_values  (token-driven, not a literal)
            width: DabblerSizing.borderDefault,
          ),
        ),
        child: value
            ? Icon(Icons.check, size: DabblerSizing.iconSm, color: d.onBrand)
            : null,
      ),
    );
  }
}

/// Flat radio: unselected ring borderDefault; selected ring + dot brandPrimary.
class DabblerRadio<T> extends StatelessWidget {
  const DabblerRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.semanticsLabel,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final enabled = onChanged != null;
    final selected = value == groupValue;

    return _TapTarget(
      enabled: enabled,
      checked: selected,
      inRadioGroup: true,
      semanticsLabel: semanticsLabel,
      onTap: () => onChanged?.call(value),
      child: Container(
        width: DabblerSizing.iconMd,
        height: DabblerSizing.iconMd,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? d.brandPrimary : d.borderDefault,
            width: DabblerSizing.borderDefault + (selected ? 1 : 0),
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: DabblerSizing.iconSm / 2,
                  height: DabblerSizing.iconSm / 2,
                  decoration: BoxDecoration(
                    color: d.brandPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// Flat switch: brand track when on, borderDefault track when off; thumb is
/// surfaceCard (with a hairline so it reads on light brand tracks). The thumb
/// position mirrors under RTL (start when off, end when on).
class DabblerSwitch extends StatelessWidget {
  const DabblerSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticsLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticsLabel;

  static const double _trackWidth = DabblerSpacing.space7 * 2; // 42
  static const double _trackHeight = DabblerSpacing.space8; // 24
  static const double _thumb = DabblerSizing.iconSm; // 18

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final enabled = onChanged != null;

    return _TapTarget(
      enabled: enabled,
      checked: value,
      semanticsLabel: semanticsLabel,
      onTap: () => onChanged?.call(!value),
      child: SizedBox(
        width: _trackWidth,
        height: _trackHeight,
        child: Stack(
          children: [
            // Track — brand fill when on, neutral border colour when off.
            Container(
              decoration: BoxDecoration(
                color: value ? d.brandPrimary : d.borderDefault,
                borderRadius: DabblerRadius.pillRadius,
              ),
            ),
            // Thumb — mirrors under RTL via AlignmentDirectional.
            AnimatedAlign(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              alignment: value
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.all(DabblerSpacing.space1), // 3
                child: Container(
                  width: _thumb,
                  height: _thumb,
                  decoration: BoxDecoration(
                    color: d.surfaceCard,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: d.borderDefault,
                      width: DabblerSizing.borderHairline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
