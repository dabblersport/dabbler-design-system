/// Gallery entries for [DabblerChatComposer].
///
/// The specimen shows the states the live `ChatComposer.prompt.md` lists —
/// empty, ready, sending, disabled and notice — and the reply and quick-reply
/// variants. The first composer is live (a typed draft enables send); the rest
/// are fixed. Nothing is sent anywhere.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'chat_composer.dart';

/// ChatComposer's specimens.
const List<GalleryEntry> chatComposerGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'chat-composer',
    page: 'components/chat-composer',
    group: GalleryPurpose.selectionAndInput,
    title: 'ChatComposer — the message input',
    description:
        'A live composer, then empty, ready, sending, disabled, reply, '
        'quick replies and a notice.',
    builder: _composers,
  ),
];

void _noop() {}

Widget _composers(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'live — type to enable send',
      child: SizedBox(width: 360, child: _LiveComposer()),
    ),
    GallerySpecimen(
      label: 'empty — send is inert',
      child: SizedBox(
        width: 360,
        child: DabblerChatComposer(
          placeholder: 'Message',
          onAttach: _noop,
          onEmoji: _noop,
          onSend: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'ready',
      child: SizedBox(
        width: 360,
        child: DabblerChatComposer(
          value: 'Running late, 10 minutes',
          onAttach: _noop,
          onEmoji: _noop,
          onSend: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'sending',
      child: SizedBox(
        width: 360,
        child: DabblerChatComposer(
          value: 'On my way',
          state: DabblerChatComposerState.sending,
          onAttach: _noop,
          onEmoji: _noop,
          onSend: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'disabled',
      child: SizedBox(
        width: 360,
        child: DabblerChatComposer(
          placeholder: 'Message',
          state: DabblerChatComposerState.disabled,
          onAttach: _noop,
          onEmoji: _noop,
          onSend: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'replyTo',
      child: SizedBox(
        width: 360,
        child: DabblerChatComposer(
          placeholder: 'Message',
          replyTo: DabblerComposerReply(
            sender: 'Layla',
            content: 'Court 2 is booked for 7pm.',
            onCancel: _noop,
          ),
          onAttach: _noop,
          onSend: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'quickReplies',
      child: SizedBox(
        width: 360,
        child: DabblerChatComposer(
          placeholder: 'Message',
          quickReplies: <String>["I'm in", 'Running late', "Can't make it"],
          onSend: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'notice — the input is replaced',
      child: SizedBox(
        width: 360,
        child: DabblerChatComposer(
          notice: DabblerComposerNotice(
            text: 'Only admins can post in this huddle.',
            actionLabel: 'Learn more',
            onAction: _noop,
          ),
        ),
      ),
    ),
  ],
);

class _LiveComposer extends StatefulWidget {
  @override
  State<_LiveComposer> createState() => _LiveComposerState();
}

class _LiveComposerState extends State<_LiveComposer> {
  String _draft = '';

  @override
  Widget build(BuildContext context) => DabblerChatComposer(
    value: _draft,
    placeholder: 'Message',
    onChange: (String v) => setState(() => _draft = v),
    onSend: () => setState(() => _draft = ''),
    onAttach: _noop,
    onEmoji: _noop,
  );
}
