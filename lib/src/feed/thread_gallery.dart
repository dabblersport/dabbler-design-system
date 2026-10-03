/// Gallery entries for the post thread parts: [DabblerCommentRow],
/// [DabblerReplyComposer], [DabblerAttachmentChip] and the
/// [DabblerPostRow] detail extras.
///
/// Sample content follows `Post.dc.html` (alpha-plan design set). Media is a
/// token-coloured placeholder box, never an image; taps go nowhere.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'attachment_chip.dart';
import 'comment_row.dart';
import 'post_detail.dart';
import 'post_row.dart';
import 'reply_composer.dart';

/// The thread parts' specimens.
const List<GalleryEntry> threadGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'comment-row',
    page: 'components/comment-row',
    group: GalleryPurpose.contentContainers,
    title: 'CommentRow — one reply under a post',
    description:
        'A top-level reply with a handle and the replies toggle, a liked '
        'nested reply, a reply with an attached image, and an Arabic reply '
        'in RTL.',
    builder: _comments,
  ),
  GalleryEntry(
    id: 'reply-composer',
    page: 'components/reply-composer',
    group: GalleryPurpose.selectionAndInput,
    title: 'ReplyComposer — the reply bar under a post',
    description:
        'Resting with attach buttons, replying to someone with an attachment '
        'and a multi-line field, sending, and an Arabic bar in RTL.',
    builder: _composers,
  ),
  GalleryEntry(
    id: 'attachment-chip',
    page: 'components/attachment-chip',
    group: GalleryPurpose.selectionAndInput,
    title: 'AttachmentChip — a removable attachment',
    description:
        'A thumbnail with its remove button, a place pill, and both in RTL.',
    builder: _chips,
  ),
  GalleryEntry(
    id: 'post-row/detail',
    page: 'components/post-row',
    group: GalleryPurpose.contentContainers,
    title: 'PostRow — the open post detail line',
    description:
        'The full timestamp, the edited marker and the visibility line, in '
        'LTR and RTL.',
    builder: _detail,
  ),
];

void _noop() {}

void _send(String _) {}

Widget _frame(Widget child) => SizedBox(width: 360, child: child);

Widget _media(BuildContext context) =>
    ColoredBox(color: DabblerColors.of(context).surfaceGrey);

Widget _comments(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'top level, with handle and replies toggle',
      child: _frame(
        const DabblerCommentRow(
          name: 'Karim Hassan',
          handle: '@karimh',
          time: '1h',
          body: 'Count me in. Bringing two more from the office.',
          likes: 4,
          onLike: _noop,
          onReply: _noop,
          onMore: _noop,
          repliesLabel: '2 replies',
          onViewReplies: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'nested, liked',
      child: _frame(
        const DabblerCommentRow(
          name: 'Lina Saeed',
          time: '45m',
          body: 'Same here, see you at gate 3.',
          likes: 2,
          liked: true,
          depth: 1,
          onLike: _noop,
          onReply: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'with an attached image',
      child: _frame(
        DabblerCommentRow(
          name: 'Omar Farouk',
          time: '20m',
          body: 'The pitch last week.',
          attachment: SizedBox(width: 160, height: 120, child: _media(context)),
          onLike: _noop,
          onReply: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'Arabic, RTL',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _frame(
          const DabblerCommentRow(
            name: 'سارة أحمد',
            time: '٣س',
            body: 'سأكون هناك مع فريقي.',
            likes: 7,
            onLike: _noop,
            onReply: _noop,
            replyLabel: 'رد',
          ),
        ),
      ),
    ),
  ],
);

Widget _composers(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'resting, with attach buttons',
      child: _frame(
        const DabblerReplyComposer(
          onSend: _send,
          padSafeArea: false,
          attachActions: <DabblerReplyComposerAction>[
            DabblerReplyComposerAction(
              icon: 'gallery',
              label: 'Add photo',
              onTap: _noop,
            ),
            DabblerReplyComposerAction(
              icon: 'location',
              label: 'Add place',
              onTap: _noop,
            ),
          ],
        ),
      ),
    ),
    GallerySpecimen(
      label: 'replying, with an attachment, multi-line',
      child: _frame(
        DabblerReplyComposer(
          onSend: _send,
          padSafeArea: false,
          multiline: true,
          replyingTo: '@moatazmustapha',
          onCancelReply: _noop,
          canSendEmpty: true,
          attachments: Wrap(
            spacing: DabblerSpacing.space3,
            runSpacing: DabblerSpacing.space3,
            children: <Widget>[
              DabblerAttachmentChip(
                thumbnail: _media(context),
                semanticLabel: 'Pitch photo',
                onRemove: _noop,
              ),
            ],
          ),
          attachActions: const <DabblerReplyComposerAction>[
            DabblerReplyComposerAction(
              icon: 'gallery',
              label: 'Add photo',
              onTap: _noop,
              active: true,
            ),
          ],
        ),
      ),
    ),
    GallerySpecimen(
      label: 'sending',
      child: _frame(
        const DabblerReplyComposer(
          onSend: _send,
          padSafeArea: false,
          sending: true,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'Arabic, RTL',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _frame(
          const DabblerReplyComposer(
            onSend: _send,
            padSafeArea: false,
            placeholder: 'اكتب ردك…',
            replyingToLabel: 'الرد على',
            replyingTo: '@sara',
            onCancelReply: _noop,
            attachActions: <DabblerReplyComposerAction>[
              DabblerReplyComposerAction(
                icon: 'gallery',
                label: 'إضافة صورة',
                onTap: _noop,
              ),
            ],
          ),
        ),
      ),
    ),
  ],
);

Widget _chips(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'thumbnail and place pill',
      child: Wrap(
        spacing: DabblerSpacing.space3,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          DabblerAttachmentChip(
            thumbnail: _media(context),
            semanticLabel: 'Pitch photo',
            onRemove: _noop,
          ),
          const DabblerAttachmentChip(
            icon: 'location',
            label: 'Al Quoz Pond Park',
            onRemove: _noop,
          ),
        ],
      ),
    ),
    GallerySpecimen(
      label: 'RTL',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Wrap(
          spacing: DabblerSpacing.space3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            DabblerAttachmentChip(
              thumbnail: _media(context),
              semanticLabel: 'صورة الملعب',
              onRemove: _noop,
              removeLabel: 'إزالة المرفق',
            ),
            const DabblerAttachmentChip(
              icon: 'location',
              label: 'حديقة القوز',
              onRemove: _noop,
              removeLabel: 'إزالة المرفق',
            ),
          ],
        ),
      ),
    ),
  ],
);

Widget _detail(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'open post: timestamp, edited, visibility',
      child: _frame(
        const DabblerPostRow(
          name: 'Moataz Mustapha',
          time: '2h',
          place: 'Al Quoz Pond Park',
          body:
              'Organising a Dubai football night this Sunday. All levels '
              'welcome.',
          likes: 24,
          replies: 6,
          divider: false,
          detail: DabblerPostDetail(
            timestamp: '8:00 PM · Aug 16, 2026',
            editedLabel: 'Edited',
            visibilityLabel: 'Public',
          ),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'Arabic, RTL',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _frame(
          const DabblerPostRow(
            name: 'معتز مصطفى',
            time: '2h',
            place: 'حديقة القوز',
            body: 'مباراة كرة قدم يوم الأحد.',
            divider: false,
            detail: DabblerPostDetail(
              timestamp: '8:00 م · 16 أغسطس 2026',
              editedLabel: 'معدل',
              visibilityLabel: 'عام',
              visibilityIcon: 'people',
            ),
          ),
        ),
      ),
    ),
  ],
);
