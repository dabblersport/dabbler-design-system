/// Gallery entries for the Alpha shell additions (DS-3, shell part): the
/// [DabblerPage] scaffold, the titled top bar, and the new post-row,
/// news-card and activity-row slots.
///
/// Media and thumbnails are token-coloured placeholder boxes, never images;
/// taps go nowhere.
library;

import 'package:flutter/widgets.dart';

import '../controls/chip.dart';
import '../feed/activity_row.dart';
import '../feed/news_card.dart';
import '../feed/post_row.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../navigation/bottom_bar.dart';
import '../navigation/top_bar.dart';
import '../surfaces/avatar.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'page.dart';

/// The shell additions' specimens.
const List<GalleryEntry> shellGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'page',
    page: 'components/page',
    group: GalleryPurpose.structure,
    title: 'Page — the screen scaffold',
    description:
        'Page background, a top bar, the body and a bottom bar; the safe area '
        'applies only on an edge without a bar.',
    builder: _page,
  ),
  GalleryEntry(
    id: 'page/overlay',
    page: 'components/page',
    group: GalleryPurpose.structure,
    title: 'Page — floating bottom overlay',
    description:
        'A bottom bar floating over scrolling rows with the page-colour fade '
        'behind it; the rows scroll clear of the bar.',
    builder: _pageOverlay,
  ),
  GalleryEntry(
    id: 'top-bar/titled',
    page: 'components/top-bar',
    group: GalleryPurpose.navigation,
    title: 'Navigation — titled top bar',
    description:
        'Back button, title and trailing actions, with the bottom rule; the '
        'back glyph points to the reading start in RTL.',
    builder: _titled,
  ),
  GalleryEntry(
    id: 'post-row/slots',
    page: 'components/post-row',
    group: GalleryPurpose.contentContainers,
    title: 'PostRow — photo, media, repost, reactions, kind and views',
    description:
        'An author photo and author tap, a media slot, the repost action, a '
        'reaction summary, a kind badge and the author-only view count.',
    builder: _postSlots,
  ),
  GalleryEntry(
    id: 'news-card/reaction',
    page: 'components/news-card',
    group: GalleryPurpose.contentContainers,
    title: 'NewsCard — reaction picker on long press',
    description:
        'Long-press the heart to open a reaction picker; a tap still toggles '
        'the like.',
    builder: _newsReaction,
  ),
  GalleryEntry(
    id: 'activity-row/thumbnail',
    page: 'components/activity-row',
    group: GalleryPurpose.contentContainers,
    title: 'ActivityRow — cover thumbnail',
    description:
        'A 40px rounded thumbnail at the end of the row, in LTR and RTL.',
    builder: _activityThumb,
  ),
];

void _noop() {}

Widget _frame(Widget child) => SizedBox(width: 360, child: child);

Widget _placeholder(BuildContext context, {double? height}) => SizedBox(
  height: height,
  child: ColoredBox(color: DabblerColors.of(context).surfaceGrey),
);

const List<DabblerNavigationAction> _actions = <DabblerNavigationAction>[
  DabblerNavigationAction(icon: 'archive-add', label: 'Save'),
  DabblerNavigationAction(icon: 'share', label: 'Share'),
];

Widget _page(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'top bar, body, no bottom bar',
      child: _frame(
        SizedBox(
          height: 240,
          child: DabblerPage(
            topBar: const DabblerNavigationTopBar.titled(
              title: 'Settings',
              onBack: _noop,
              border: true,
              safeArea: false,
            ),
            body: Padding(
              padding: const EdgeInsets.all(DabblerSpacing.space6),
              child: Text(
                'Body',
                style: DabblerType.body
                    .resolveForDirection(Directionality.of(context))
                    .copyWith(color: DabblerColors.of(context).textPrimary),
              ),
            ),
          ),
        ),
      ),
    ),
  ],
);

Widget _pageOverlayFrame(TextDirection direction) => GallerySpecimen(
  label: direction == TextDirection.rtl ? 'RTL, fade on' : 'LTR, fade on',
  child: _frame(
    Directionality(
      textDirection: direction,
      child: SizedBox(
        height: 320,
        child: DabblerPage(
          body: ListView.builder(
            itemCount: 12,
            itemBuilder: (BuildContext context, int i) => Padding(
              padding: const EdgeInsets.all(DabblerSpacing.space6),
              child: Text(
                direction == TextDirection.rtl ? 'صف $i' : 'Row $i',
                style: DabblerType.body
                    .resolveForDirection(direction)
                    .copyWith(color: DabblerColors.of(context).textPrimary),
              ),
            ),
          ),
          bottomOverlay: const DabblerNavigationBottomBar(
            safeArea: false,
            createItems: <DabblerNavigationCreateItem>[],
          ),
        ),
      ),
    ),
  ),
);

Widget _pageOverlay(BuildContext context) => GalleryStack(
  children: <Widget>[
    _pageOverlayFrame(TextDirection.ltr),
    _pageOverlayFrame(TextDirection.rtl),
  ],
);

Widget _titled(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'LTR, with the bottom rule',
      child: _frame(
        const DabblerNavigationTopBar.titled(
          title: 'Notifications',
          onBack: _noop,
          actions: _actions,
          border: true,
          safeArea: false,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'RTL',
      child: _frame(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerNavigationTopBar.titled(
            title: 'الإشعارات',
            onBack: _noop,
            actions: _actions,
            safeArea: false,
          ),
        ),
      ),
    ),
  ],
);

Widget _postSlots(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'all slots',
      child: _frame(
        DabblerPostRow(
          name: 'Khalid Al Mansouri',
          roleLabel: 'Player',
          time: '8h',
          place: 'Al Quoz',
          body: 'Weekly Dubai Football Night — all welcome',
          sportLabel: 'Football',
          likes: 38,
          replies: 11,
          reposts: 3,
          views: 412,
          onTap: _noop,
          onAuthorTap: _noop,
          onLike: _noop,
          onVibe: _noop,
          onComment: _noop,
          onRepost: _noop,
          onMore: _noop,
          kindBadge: const DabblerBadge(label: 'Dab'),
          media: _placeholder(context, height: 160),
          reactions: Wrap(
            spacing: DabblerSpacing.space2,
            children: const <Widget>[
              DabblerChip(label: 'Hyped 4', selected: true),
              DabblerChip(label: 'Proud 2'),
            ],
          ),
        ),
      ),
    ),
  ],
);

Widget _newsReaction(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'liked; long-press the heart',
      child: _frame(
        DabblerNewsCard(
          media: _placeholder(context),
          sportLabel: 'Padel',
          title: 'Dubai Padel Open returns with a record prize pool',
          excerpt: 'Organisers confirmed 64 pairs will compete.',
          time: '5h',
          likes: 21,
          comments: 3,
          views: 120,
          liked: true,
          onLike: _noop,
          onLikeLongPress: _noop,
        ),
      ),
    ),
  ],
);

Widget _activityThumb(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'LTR',
      child: _frame(
        DabblerActivityRow(
          leading: const DabblerAvatar(seed: 'Khalid', size: DabblerAvatarSize.sm),
          actor: 'khalid',
          verb: 'commented on',
          subject: 'Dubai Padel Open returns',
          when: '2h',
          thumbnail: _placeholder(context),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'RTL',
      child: _frame(
        Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerActivityRow(
            leading: const DabblerAvatar(seed: 'Khalid', size: DabblerAvatarSize.sm),
            actor: 'خالد',
            verb: 'علّق على',
            subject: 'بطولة دبي للبادل',
            when: '2h',
            thumbnail: _placeholder(context),
          ),
        ),
      ),
    ),
  ],
);
