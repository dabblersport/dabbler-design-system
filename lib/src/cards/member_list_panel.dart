import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';
import '../tokens/dabbler_type.dart';

/// One person in a [DabblerMemberListPanel].
@immutable
class DabblerMember {
  /// A member row.
  const DabblerMember({
    required this.name,
    required this.role,
    this.added = false,
    this.badge,
    this.badgeTone = DabblerAvatarBadgeTone.primary,
  });

  /// The name — also the avatar seed, never drawn as initials.
  final String name;

  /// The role line under the name.
  final String role;

  /// Whether the member is added; an added row inverts its button to a filled
  /// minus.
  final bool added;

  /// An optional avatar badge.
  final Widget? badge;

  /// The badge fill.
  final DabblerAvatarBadgeTone badgeTone;
}

/// MemberListPanel — avatar rows with a name, a role, and a round add/remove
/// button. Added rows invert the button to a filled minus.
///
/// Ported from the live design project's
/// `components/cards/MemberListPanel.jsx` (design system 1.2.0). Rows are 12
/// apart, the avatar is [DabblerAvatarSize.sm], the name is `subheadline`
/// (15/20) at weight 700 and the role is `footnote` (13/18) muted — the 15/700
/// is a weight override on a named step, recorded in the type-override
/// register.
///
/// The button is drawn 32 round as in the source; its hit area is the 45px
/// touch target. Data is injected; the widget owns none.
class DabblerMemberListPanel extends StatelessWidget {
  /// A member list.
  const DabblerMemberListPanel({
    super.key,
    this.people = const <DabblerMember>[],
    this.onToggle,
    this.dark = false,
  });

  /// The rows.
  final List<DabblerMember> people;

  /// Called with the row index when its button is pressed.
  final ValueChanged<int>? onToggle;

  /// The ink-panel treatment.
  final bool dark;

  /// Gap between rows — `gap: 12`.
  static const double rowGap = DabblerSpacing.space4;

  /// Gap between the name and the role — `gap: 1` (a hairline, not a step).
  static const double nameRoleGap = 1;

  /// The button's drawn diameter — `width: 32`.
  static const double buttonSide = 32;

  /// The name's weight — `fontWeight: 700`.
  static const FontWeight nameWeight = FontWeight.w700;

  /// The dark border of an un-added button — `rgba(245,240,230,0.28)`.
  static const double darkBorderAlpha = 0.28;

  /// The button's fill.
  static Color buttonFillFor(
    DabblerColors colors, {
    required bool added,
    required bool dark,
  }) {
    if (!added) return const Color.fromARGB(0, 0, 0, 0);
    return dark ? colors.surfaceCard : DabblerPalette.ink;
  }

  /// The button's glyph colour.
  static Color buttonInkFor(
    DabblerColors colors, {
    required bool added,
    required bool dark,
  }) {
    if (added) return dark ? DabblerPalette.ink : colors.surfaceCard;
    return dark ? DabblerPalette.surfacePage : colors.textPrimary;
  }

  /// The button's 1px border, or null when added.
  static Color? buttonBorderFor(
    DabblerColors colors, {
    required bool added,
    required bool dark,
  }) {
    if (added) return null;
    return dark
        ? DabblerPalette.surfacePage.withValues(alpha: darkBorderAlpha)
        : colors.borderDefault;
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < people.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: rowGap),
          Row(
            children: <Widget>[
              DabblerAvatar(
                seed: people[i].name,
                size: DabblerAvatarSize.sm,
                badge: people[i].badge,
                badgeTone: people[i].badgeTone,
              ),
              const SizedBox(width: DabblerSpacing.space4),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      people[i].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DabblerType.subheadline
                          .resolveForDirection(direction)
                          .copyWith(
                            fontWeight: nameWeight,
                            color: dark
                                ? DabblerPalette.surfacePage
                                : colors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: nameRoleGap),
                    Text(
                      people[i].role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DabblerType.footnote
                          .resolveForDirection(direction)
                          .copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DabblerSpacing.space4),
              _ToggleButton(
                added: people[i].added,
                dark: dark,
                label: people[i].added
                    ? 'Remove ${people[i].name}'
                    : 'Add ${people[i].name}',
                onTap: onToggle == null ? null : () => onToggle!(i),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ToggleButton extends StatefulWidget {
  const _ToggleButton({
    required this.added,
    required this.dark,
    required this.label,
    required this.onTap,
  });

  final bool added;
  final bool dark;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<_ToggleButton> {
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Color ink = DabblerMemberListPanel.buttonInkFor(
      colors,
      added: widget.added,
      dark: widget.dark,
    );
    final Color? border = DabblerMemberListPanel.buttonBorderFor(
      colors,
      added: widget.added,
      dark: widget.dark,
    );
    final Widget disc = Container(
      width: DabblerMemberListPanel.buttonSide,
      height: DabblerMemberListPanel.buttonSide,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: DabblerMemberListPanel.buttonFillFor(
          colors,
          added: widget.added,
          dark: widget.dark,
        ),
        border: border == null
            ? null
            : Border.all(color: border, width: DabblerSizing.borderDefault),
      ),
      child: DabblerIcon(
        widget.added ? 'minus' : 'add',
        size: DabblerSizing.iconSm,
        color: ink,
      ),
    );

    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.label,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: widget.onTap != null,
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
            child: SizedBox(
              width: DabblerSizing.touchTargetMin,
              height: DabblerSizing.touchTargetMin,
              child: Center(
                child: DabblerFocusRing.visible(
                  visible: _focused,
                  borderRadius: DabblerRadius.pillAll,
                  child: DabblerPressScale(pressed: _pressed, child: disc),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
