/// Gallery entries for the Home Feed rows: [DabblerPostRow],
/// [DabblerNewsCard] and [DabblerActivityRow].
///
/// Sample content follows the design file's own data (`Home Feed.dc.html`
/// `:2520-2634`). Media is a token-coloured placeholder box, never an image;
/// taps go nowhere.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_home_frame.dart';
import 'activity_row.dart';
import 'news_card.dart';
import 'notification_row.dart';
import 'post_row.dart';
import 'upcoming_reminder.dart';

/// The Home Feed rows' specimens.
const List<GalleryEntry> feedGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'post-row',
    page: 'components/post-row',
    group: GalleryPurpose.contentContainers,
    title: 'PostRow — one post in the feed',
    description:
        'Avatar, author line, time and place, body with a link run, sport pill '
        'and the like / vibe / reply / share / more actions; liked and vibed '
        'states and an Arabic row in RTL.',
    builder: _posts,
  ),
  GalleryEntry(
    id: 'news-card',
    page: 'components/news-card',
    group: GalleryPurpose.contentContainers,
    title: 'NewsCard — one story in the News tab',
    description:
        'A media slot with a sport pill, like / comment / view figures, the '
        'title and a two-line excerpt; liked, and an Arabic card in RTL.',
    builder: _news,
  ),
  GalleryEntry(
    id: 'activity-row',
    page: 'components/activity-row',
    group: GalleryPurpose.contentContainers,
    title: 'ActivityRow — one entry in the Active tab',
    description:
        'Person, group and system leading widgets, a filled or outlined action, '
        'a Live or sport badge, a group header, and an Arabic row in RTL.',
    builder: _activity,
  ),
  GalleryEntry(
    id: 'notification-row',
    page: 'components/notification-row',
    group: GalleryPurpose.contentContainers,
    title: 'NotificationRow — one entry in the notification list',
    description:
        'Person, group and system leading widgets, a status pill, time and '
        'unread dot, a meta line and up to two actions; an Arabic row in RTL.',
    builder: _notification,
  ),
  GalleryEntry(
    id: 'upcoming-reminder',
    page: 'components/upcoming-reminder',
    group: GalleryPurpose.contentContainers,
    title: 'UpcomingReminder — the next games on the Home Feed',
    description:
        'A single game with its countdown ring, three games folded as a '
        'stack, the opened list, the one-line strip, and an Arabic block in '
        'RTL.',
    builder: _upcoming,
  ),
];

void _noop() {}

Widget _frame(Widget child) => SizedBox(width: 360, child: child);

Widget _media(BuildContext context) =>
    ColoredBox(color: DabblerColors.of(context).surfaceGrey);

Widget _posts(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'default, with a hashtag run',
      child: _frame(
        const DabblerPostRow(
          name: 'Suraj Mehta',
          roleLabel: 'Player',
          distance: '1.1 km',
          time: '2h',
          place: 'Nad Al Sheba',
          segments: <DabblerPostSegment>[
            DabblerPostSegment(
              'Anyone playing cricket in Dubai this weekend? ',
            ),
            DabblerPostSegment('#dabblersport', link: true),
          ],
          sportLabel: 'Cricket',
          likes: 12,
          replies: 4,
          onTap: _noop,
          onLike: _noop,
          onVibe: _noop,
          onComment: _noop,
          onShare: _noop,
          onMore: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'liked and vibed, no divider',
      child: _frame(
        const DabblerPostRow(
          name: 'Khalid Al Mansouri',
          roleLabel: 'Player',
          distance: '4.2 km',
          time: '8h',
          place: 'Al Quoz',
          body: 'Weekly Dubai Football Night - All Welcome',
          sportLabel: 'Football',
          likes: 38,
          replies: 11,
          liked: true,
          vibed: true,
          divider: false,
          onLike: _noop,
          onVibe: _noop,
          onComment: _noop,
          onShare: _noop,
          onMore: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'drawn metrics — as the Home Feed frame measures it',
      child: _frame(
        const DabblerPostRow(
          metrics: DabblerFeedMetrics.drawn,
          name: 'Suraj Mehta',
          roleLabel: 'Player',
          distance: 'Dab',
          time: '2h',
          place: 'Nad Al Sheba',
          segments: <DabblerPostSegment>[
            DabblerPostSegment(
              'Anyone playing cricket in Dubai this weekend? ',
            ),
            DabblerPostSegment('#dabblersport', link: true),
          ],
          sportLabel: 'Cricket',
          likes: 12,
          replies: 4,
          onTap: _noop,
          onLike: _noop,
          onVibe: _noop,
          onComment: _noop,
          onShare: _noop,
          onMore: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'drawn metrics, Arabic (the frame\'s own copy)',
      child: _frame(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerPostRow(
            metrics: DabblerFeedMetrics.drawn,
            name: 'سوراج ميهتا',
            roleLabel: 'لاعب',
            distance: 'داب',
            time: '2h',
            place: 'ند الشبا',
            body:
                'أحد يلعب كريكيت في دبي نهاية الأسبوع؟ نحتاج لاعبَين لإكمال '
                'الفريق.',
            sportLabel: 'كريكيت',
            likes: 12,
            replies: 4,
            onTap: _noop,
            onLike: _noop,
            onVibe: _noop,
            onComment: _noop,
            onShare: _noop,
            onMore: _noop,
          ),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'Arabic, right-to-left',
      child: _frame(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerPostRow(
            name: 'سارة الهاشمي',
            roleLabel: 'لاعب',
            distance: '850 م',
            time: 'منذ يوم',
            place: 'الورقاء',
            body: 'هل من أحد يلعب البادل هذا الصباح؟',
            sportLabel: 'بادل',
            likes: 21,
            replies: 6,
            onTap: _noop,
            onLike: _noop,
            onVibe: _noop,
            onComment: _noop,
            onShare: _noop,
            onMore: _noop,
          ),
        ),
      ),
    ),
  ],
);

Widget _news(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'default',
      child: _frame(
        DabblerNewsCard(
          media: _media(context),
          sportLabel: 'Football',
          title:
              'Dubai adds twelve floodlit community pitches before the winter '
              'season',
          excerpt:
              'The municipality confirmed the first six sites open in '
              'November, with booking handled inside the same apps residents '
              'already use for public courts.',
          time: '3h ago',
          likes: 128,
          comments: 24,
          views: 1902,
          onTap: _noop,
          onLike: _noop,
          onComment: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'drawn metrics — as the Home Feed frame measures it',
      child: _frame(
        DabblerNewsCard(
          metrics: DabblerFeedMetrics.drawn,
          media: _media(context),
          sportLabel: 'Football',
          title:
              'Dubai adds twelve floodlit community pitches before the winter '
              'season',
          excerpt:
              'The municipality confirmed the first six sites open in '
              'November, with booking handled inside the same apps residents '
              'already use for public courts.',
          time: '3h ago',
          likes: 128,
          comments: 24,
          views: 1902,
          onTap: _noop,
          onLike: _noop,
          onComment: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'liked, no divider',
      child: _frame(
        DabblerNewsCard(
          media: _media(context),
          sportLabel: 'Padel',
          title: 'Padel overtakes tennis as the fastest growing racket sport',
          excerpt: 'Court counts tripled in three years.',
          time: '1d ago',
          likes: 76,
          comments: 11,
          views: 840,
          liked: true,
          divider: false,
          onLike: _noop,
          onComment: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'Arabic, right-to-left',
      child: _frame(
        Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerNewsCard(
            media: _media(context),
            sportLabel: 'كرة السلة',
            title: 'ميدان يفتح دوريا ليليا للفرق المختلطة',
            excerpt:
                'اثنا عشر لاعبا لكل فريق، والمباريات من الأحد إلى الأربعاء.',
            time: 'منذ يومين',
            likes: 45,
            comments: 8,
            views: 613,
            onTap: _noop,
            onLike: _noop,
            onComment: _noop,
          ),
        ),
      ),
    ),
  ],
);

Widget _activity(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'group, filled action, Live',
      child: _frame(
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DabblerActivityGroupHeader('Happening now', live: true),
            DabblerActivityRow(
              leading: DabblerAvatarGroup(
                people: <String>[
                  'Aisha Khan',
                  'Rahul Menon',
                  'Yousef Al Balushi',
                ],
              ),
              actor: 'Aisha and 3 others',
              verb: 'are playing right now',
              subject: 'Friday 5-a-side',
              place: 'Zayed Sports City',
              when: 'started 20m ago',
              distance: '3.8 km',
              actionLabel: 'Join in',
              actionFilled: true,
              onAction: _noop,
              count: '2 spots left',
              live: true,
            ),
          ],
        ),
      ),
    ),
    GallerySpecimen(
      label: 'system tile, outlined action, sport badge',
      child: _frame(
        const DabblerActivityRow(
          leading: DabblerActivitySystemTile('ticket-2'),
          actor: 'Meydan Padel',
          verb: 'opened a court for tonight',
          subject: 'Court 3 free 8:00 - 10:00 PM',
          place: 'Meydan',
          when: 'in 2h',
          distance: '2.6 km',
          actionLabel: 'Book',
          onAction: _noop,
          sportLabel: 'Padel',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'drawn metrics — system tile 42, action 35, badge 21',
      child: _frame(
        const DabblerActivityRow(
          metrics: DabblerFeedMetrics.drawn,
          leading: DabblerActivitySystemTile(
            'ticket-2',
            metrics: DabblerFeedMetrics.drawn,
          ),
          actor: 'Meydan Padel',
          verb: 'opened a court for tonight',
          subject: 'Court 3 free 8:00 - 10:00 PM',
          place: 'Meydan',
          when: 'in 2h',
          distance: '2.6 km',
          actionLabel: 'Book',
          onAction: _noop,
          sportLabel: 'Padel',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'person, filled action, count',
      child: _frame(
        const DabblerActivityRow(
          leading: DabblerAvatar(
            seed: 'Khalid Al Mansouri',
            size: DabblerAvatarSize.sm,
          ),
          actor: 'Khalid',
          verb: 'created a game',
          subject: 'Saturday net practice + match',
          place: 'Al Maryah Island',
          when: 'Sat 6:00 PM',
          distance: '5.4 km',
          actionLabel: 'Join game',
          actionFilled: true,
          onAction: _noop,
          count: '7/12 going',
          sportLabel: 'Cricket',
          onTap: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'Arabic, right-to-left',
      child: _frame(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerActivityRow(
            leading: DabblerAvatar(
              seed: 'Sara Al Hashimi',
              size: DabblerAvatarSize.sm,
            ),
            actor: 'سارة',
            verb: 'حجزت ملعبا',
            subject: 'ملعب الورقاء 2، الجمعة 7:00 ص',
            place: 'الورقاء',
            when: 'منذ 5 ساعات',
            distance: '850 م',
            actionLabel: 'اطلب الانضمام',
            onAction: _noop,
            sportLabel: 'بادل',
          ),
        ),
      ),
    ),
  ],
);

Widget _notification(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'person, unread, pill, meta and two actions',
      child: _frame(
        DabblerNotificationRow(
          leading: const DabblerAvatar(
            seed: 'Khalid Al Mansouri',
            size: DabblerAvatarSize.sm,
          ),
          actor: 'Khalid Al Mansouri',
          verb: 'invited you to play',
          subject: 'Thursday 5-a-side at Al Quoz',
          pillLabel: 'Invite',
          pillStatus: DabblerColors.of(context).info,
          time: '12m',
          unread: true,
          meta: const <DabblerNotificationMeta>[
            DabblerNotificationMeta('clock', 'Thu 9:00 PM'),
            DabblerNotificationMeta('people', '8/10 players', strong: true),
          ],
          actions: const <DabblerNotificationAction>[
            DabblerNotificationAction('Accept', filled: true, onPressed: _noop),
            DabblerNotificationAction('Decline', onPressed: _noop),
          ],
          onTap: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'system tile, read',
      child: _frame(
        const DabblerNotificationRow(
          leading: DabblerActivitySystemTile('wallet'),
          actor: 'Booking confirmed',
          verb: 'Zayed Sports City',
          time: '18:02',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'right-to-left',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _frame(
          const DabblerNotificationRow(
            leading: DabblerAvatar(seed: 'ليلى', size: DabblerAvatarSize.sm),
            actor: 'ليلى حداد',
            verb: 'طلبت الانضمام إلى مباراتك',
            time: '2س',
            unread: true,
          ),
        ),
      ),
    ),
  ],
);

const List<DabblerUpcomingItem> _games = <DabblerUpcomingItem>[
  DabblerUpcomingItem(
    month: 'OCT',
    day: '4',
    title: 'Tuesday 5-a-side',
    detail: 'Dubai Sports City · 7:30 PM',
    ringFraction: 0.97,
    ringBig: '2',
    ringSmall: 'hours',
    short: 'in 2h 10m',
    onTap: _noop,
  ),
  DabblerUpcomingItem(
    month: 'OCT',
    day: '6',
    title: 'Padel doubles',
    detail: 'Meydan Padel · 8:00 PM',
    ringFraction: 0.6,
    ringBig: '2',
    ringSmall: 'days',
    short: 'in 2d',
    onTap: _noop,
  ),
  DabblerUpcomingItem(
    month: 'OCT',
    day: '8',
    title: 'Friday net practice',
    detail: 'Al Maryah Island · 6:00 PM',
    ringFraction: 0.2,
    ringBig: '4',
    ringSmall: 'days',
    short: 'in 4d',
    onTap: _noop,
  ),
];

Widget _reminder({
  required List<DabblerUpcomingItem> items,
  bool collapsed = false,
  bool expanded = false,
  String title = 'Upcoming · 3',
  DabblerFeedMetrics metrics = DabblerFeedMetrics.touch,
}) => _frame(
  DabblerUpcomingReminder(
    metrics: metrics,
    items: items,
    title: title,
    collapsed: collapsed,
    expanded: expanded,
    onDismiss: _noop,
    onExpandStrip: _noop,
    onToggleExpanded: _noop,
    stripLabel: '3 upcoming',
    moreLabel: '2 more this week',
    showLessLabel: 'Show less',
    dismissLabel: 'Hide',
  ),
);

Widget _upcoming(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'one game',
      child: _reminder(items: _games.sublist(0, 1), title: 'Upcoming'),
    ),
    GallerySpecimen(
      label: 'three games, stacked',
      child: _reminder(items: _games),
    ),
    GallerySpecimen(
      label: 'opened as a list',
      child: _reminder(items: _games, expanded: true),
    ),
    GallerySpecimen(
      label: 'folded to the strip',
      child: _reminder(items: _games, collapsed: true),
    ),
    GallerySpecimen(
      label: 'drawn metrics — stacked, as the frame measures it',
      child: _reminder(items: _games, metrics: DabblerFeedMetrics.drawn),
    ),
    GallerySpecimen(
      label: 'drawn metrics — folded strip, 30 high',
      child: _reminder(
        items: _games,
        collapsed: true,
        metrics: DabblerFeedMetrics.drawn,
      ),
    ),
    GallerySpecimen(
      label:
          'drawn metrics, Arabic (hide button flush, frame margin is physical)',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _reminder(
          items: _games,
          title: 'القادمة · 3',
          metrics: DabblerFeedMetrics.drawn,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'Arabic, right-to-left',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _reminder(items: _games, title: 'القادمة · 3'),
      ),
    ),
  ],
);
