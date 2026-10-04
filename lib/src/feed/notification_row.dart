/// NotificationRow — one entry in the notification list: who, what, when, an
/// optional status pill, an unread dot, a meta line and up to two actions.
///
/// Source: Claude Design file `Notifications.dc.html`, the row at `:116-175`
/// (a borderless row under a hairline, not the Home Feed's card).
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'activity_row.dart' show DabblerActivityRow;
import 'feed_atoms.dart';

/// One glyph-and-text item on a [DabblerNotificationRow]'s meta line.
@immutable
class DabblerNotificationMeta {
  /// A meta item drawing the kebab-case Iconsax [icon] beside [text].
  const DabblerNotificationMeta(this.icon, this.text, {this.strong = false});

  /// The kebab-case Iconsax name.
  final String icon;

  /// The already-localised text.
  final String text;

  /// Whether the item is emphasised (semibold, primary ink).
  final bool strong;
}

/// One action button on a [DabblerNotificationRow].
@immutable
class DabblerNotificationAction {
  /// An action labelled [label].
  const DabblerNotificationAction(
    this.label, {
    this.onPressed,
    this.filled = false,
  });

  /// The button text.
  final String label;

  /// Runs the action.
  final VoidCallback? onPressed;

  /// Filled (brand) when true, outlined when false.
  final bool filled;
}

/// The notification list row. The [leading] is a [DabblerAvatar], a
/// [DabblerAvatarGroup] or a [DabblerActivitySystemTile].
class DabblerNotificationRow extends StatelessWidget {
  /// A notification row.
  const DabblerNotificationRow({
    super.key,
    required this.leading,
    required this.actor,
    this.verb,
    this.subject,
    this.pillLabel,
    this.pillStatus,
    this.time,
    this.unread = false,
    this.meta = const <DabblerNotificationMeta>[],
    this.actions = const <DabblerNotificationAction>[],
    this.onTap,
  });

  /// The leading widget.
  final Widget leading;

  /// Who or what, in primary ink.
  final String actor;

  /// What happened, in secondary ink.
  final String? verb;

  /// The subject line.
  final String? subject;

  /// The status pill's text; omitted when null.
  final String? pillLabel;

  /// The pill's tone; the neutral status when null.
  final DabblerStatusColor? pillStatus;

  /// The already-formatted time.
  final String? time;

  /// Whether the brand unread dot is drawn after the time.
  final bool unread;

  /// The meta line.
  final List<DabblerNotificationMeta> meta;

  /// Up to two actions under the row.
  final List<DabblerNotificationAction> actions;

  /// Opens the notification. Null leaves the row inert.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    TextStyle t(DabblerTypeStyle s) => s.resolveForDirection(dir);
    final TextStyle sub = t(DabblerType.subheadline);
    final TextStyle caption = t(DabblerType.caption1);

    final Widget head = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Expanded(
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: actor,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: DabblerType.semibold,
                  ),
                ),
                if (verb != null)
                  TextSpan(
                    text: ' $verb',
                    style: TextStyle(color: colors.textSecondary),
                  ),
              ],
            ),
            style: sub,
          ),
        ),
        if (pillLabel != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          DabblerBadge(
            label: pillLabel!,
            status: pillStatus ?? DabblerBadge.neutralStatusOf(colors),
          ),
        ],
        if (time != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          Text(
            DabblerType.toWesternDigits(time!),
            style: caption.copyWith(color: colors.textTertiary),
          ),
        ],
        if (unread) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          const DabblerBadge.dot(),
        ],
      ],
    );

    final Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        head,
        if (subject != null) ...<Widget>[
          const SizedBox(height: DabblerSpacing.space1),
          Text(subject!, style: sub.copyWith(color: colors.textPrimary)),
        ],
        if (meta.isNotEmpty) ...<Widget>[
          const SizedBox(height: DabblerSpacing.space1),
          Wrap(
            spacing: DabblerSpacing.space3,
            runSpacing: DabblerSpacing.space1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              for (final DabblerNotificationMeta m in meta)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DabblerIcon(
                      m.icon,
                      size: DabblerActivityRow.metaGlyphSize,
                      color: m.strong
                          ? colors.brandPrimary
                          : colors.textTertiary,
                    ),
                    const SizedBox(width: DabblerSpacing.space1),
                    Flexible(
                      child: Text(
                        DabblerType.toWesternDigits(m.text),
                        style: caption.copyWith(
                          color: m.strong
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
        if (actions.isNotEmpty) ...<Widget>[
          const SizedBox(height: DabblerSpacing.space3),
          Row(
            children: <Widget>[
              for (final DabblerNotificationAction a in actions) ...<Widget>[
                _ActionPill(action: a),
                const SizedBox(width: DabblerSpacing.space2),
              ],
            ],
          ),
        ],
      ],
    );

    return DabblerFeedTappable(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.bgTertiary,
              width: DabblerSizing.borderDefault,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            top: DabblerSpacing.space4,
            bottom: DabblerSpacing.space3,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              leading,
              const SizedBox(width: DabblerSpacing.space4),
              Expanded(child: column),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 33px action pill — filled (brand) or outlined, inside a 45px target.
class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.action});

  final DabblerNotificationAction action;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    return DabblerFeedTappable(
      onTap: action.onPressed,
      semanticLabel: action.label,
      excludeChildSemantics: true,
      borderRadius: DabblerRadius.pillAll,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: DabblerSizing.touchTargetMin,
          minWidth: DabblerSizing.touchTargetMin,
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Container(
            height: DabblerActivityRow.actionHeight,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: DabblerSpacing.space5,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: action.filled ? colors.brandPrimary : null,
              borderRadius: DabblerRadius.pillAll,
              border: Border.all(
                color: action.filled
                    ? colors.brandPrimary
                    : colors.borderDefault,
                width: DabblerSizing.borderDefault,
              ),
            ),
            child: Text(
              action.label,
              maxLines: 1,
              style: DabblerType.footnote
                  .resolveForDirection(dir)
                  .copyWith(
                    color: action.filled ? colors.onBrand : colors.textPrimary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
