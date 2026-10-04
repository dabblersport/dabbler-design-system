import 'package:flutter/widgets.dart';

import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// CounterLink — a bold figure beside a muted caption (`412 Followers`), as
/// the profile header's counters row draws it (`Profiles.dc.html:102-109`):
/// a 16/21 bold figure and a 13/18 caption on a shared baseline, 5 apart.
///
/// With [onTap] it is a button with the shared focus ring and press scale and
/// a hit area at least [DabblerSizing.touchTargetMin] tall; without it, inert.
/// The figure and caption sit in flow, so they swap sides in RTL.
class DabblerCounterLink extends StatefulWidget {
  /// A counter.
  const DabblerCounterLink({
    super.key,
    required this.value,
    required this.label,
    this.onTap,
  });

  /// The figure (already formatted).
  final String value;

  /// The caption.
  final String label;

  /// Makes the counter a button.
  final VoidCallback? onTap;

  @override
  State<DabblerCounterLink> createState() => _DabblerCounterLinkState();
}

class _DabblerCounterLinkState extends State<DabblerCounterLink> {
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(
          widget.value,
          style: DabblerType.headline
              .resolveForDirection(dir)
              .copyWith(
                color: colors.textPrimary,
                fontWeight: DabblerType.bold,
              ),
        ),
        const SizedBox(width: DabblerSpacing.space2),
        Text(
          widget.label,
          style: DabblerType.footnote
              .resolveForDirection(dir)
              .copyWith(color: colors.textSecondary),
        ),
      ],
    );
    final String name = '${widget.value} ${widget.label}';
    if (widget.onTap == null) {
      return Semantics(
        container: true,
        label: name,
        child: ExcludeSemantics(child: content),
      );
    }
    return Semantics(
      button: true,
      label: name,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (bool v) => setState(() => _focused = v),
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                widget.onTap?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
            onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: DabblerSizing.touchTargetMin,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: 1,
                child: DabblerFocusRing.visible(
                  visible: _focused,
                  enabled: true,
                  borderRadius: BorderRadius.circular(DabblerRadius.sm),
                  child: DabblerPressScale(
                    pressed: _pressed,
                    enabled: true,
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
