import 'package:flutter/widgets.dart';

import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// MeetupAttendees — who is going to a meetup: an avatar stack, the going
/// count and the capacity line beside it.
///
/// Drawn from the Listings meetup card, `Listings.dc.html:545-553`: a
/// [DabblerAvatarGroup] (`size="sm" max="3"`), then a column of the going count
/// (13/17, 600) over the capacity (11/15, muted), 9 apart. It is the meetup's
/// counterpart of [DabblerCardEventPlayers], and goes in the same `progress`
/// slot of a [DabblerCardGame].
///
/// ```dart
/// DabblerMeetupAttendees(
///   people: <String>['Ahmed Farouk', 'Lina Haddad', 'Yousef Amer', 'Nadia Saleh'],
///   goingLabel: '24 going',
///   capacityLabel: 'Max 40',
/// )
/// ```
///
/// ## States
///
/// * **open** — the capacity line in the muted ink.
/// * **full** — [full] draws the capacity line in the error ink. The words
///   (`Full`) must still say it; colour only reinforces them.
/// * **nobody yet** — an empty [people] draws no stack, only the text.
///
/// ## RTL
///
/// The stack leads at the inline start and the text follows it; the stack
/// itself overlaps towards the inline end.
///
/// ## Accessibility
///
/// One node: the going count, then the capacity. The faces are decorative.
class DabblerMeetupAttendees extends StatelessWidget {
  /// An attendee summary.
  const DabblerMeetupAttendees({
    super.key,
    this.people = const <String>[],
    this.imageUrls,
    this.maxAvatars = defaultMaxAvatars,
    required this.goingLabel,
    this.capacityLabel,
    this.full = false,
  }) : assert(maxAvatars >= 0, 'a stack cannot hold fewer than none');

  /// Seeds of the people going, in order.
  final List<String> people;

  /// Photo URLs aligned with [people]; see [DabblerAvatarGroup.imageUrls].
  final List<String?>? imageUrls;

  /// How many faces the stack shows before the `+N` chip. Default 3, the
  /// card's `max="3"`.
  final int maxAvatars;

  /// The going count, already formatted — `24 going`.
  final String goingLabel;

  /// The capacity line — `Max 40`, `Full`. Null draws none.
  final String? capacityLabel;

  /// Draws [capacityLabel] in the error ink.
  final bool full;

  /// The card's `max="3"`.
  static const int defaultMaxAvatars = 3;

  /// The gap between the stack and the text — `gap: 9`,
  /// [DabblerSpacing.space3].
  static const double gap = DabblerSpacing.space3;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final int shown = people.length < maxAvatars ? people.length : maxAvatars;
    final int more = people.length - shown;
    final Widget text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          goingLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // `13/17, 600, --ink` — `.t-footnote-tight`.
          style: DabblerType.footnoteTight
              .resolveForDirection(direction)
              .copyWith(color: colors.textPrimary),
        ),
        if (capacityLabel != null)
          Text(
            capacityLabel!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // `11/15, --muted` — the tag step at regular weight.
            style: DabblerType.tag
                .resolveForDirection(direction)
                .copyWith(
                  color: full ? colors.error.strong : colors.textSecondary,
                  fontWeight: DabblerType.regular,
                ),
          ),
      ],
    );
    return Semantics(
      container: true,
      label: <String>[goingLabel, ?capacityLabel].join(', '),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: gap,
          children: <Widget>[
            if (shown > 0)
              DabblerAvatarGroup(
                people: people.take(shown).toList(),
                imageUrls: imageUrls?.take(shown).toList(),
                overflow: more,
              ),
            Flexible(child: text),
          ],
        ),
      ),
    );
  }
}
