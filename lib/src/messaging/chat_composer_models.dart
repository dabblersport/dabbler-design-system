/// Part of the `chat_composer.dart` library — the composer's state enum and its reply and notice view-models.
///
/// **Why `part`, not a separate library.** The file stood over the
/// project's 500-line house rule (`013`). These declarations were moved
/// verbatim; `part`/`part of` keeps one logical library, so private names
/// stay private and no public API changes. No exemption was recorded.
///
/// The imports are the library's — a part file declares none of its own.
part of 'chat_composer.dart';

/// The state of a [DabblerChatComposer] — `state` in the source.
enum DabblerChatComposerState {
  /// `'default'` — the source's string; `default` is a Dart keyword.
  normal,

  /// A message is in flight: a spinner replaces the send glyph and the input
  /// and every target are inert.
  sending,

  /// Sunken field and every target inert.
  disabled,
}

/// The quoted message shown above the field — `replyTo` in the source.
@immutable
class DabblerComposerReply {
  /// A reply target. Set [content] for a text message, [attachmentLabel] for an
  /// attachment.
  const DabblerComposerReply({
    required this.sender,
    this.content,
    this.attachmentLabel,
    this.onCancel,
    this.cancelLabel = 'Cancel reply',
  });

  /// Who wrote the quoted message.
  final String sender;

  /// The quoted text (`content ?? text` in the source).
  final String? content;

  /// Set instead of [content] when the quoted message was an attachment.
  final String? attachmentLabel;

  /// Shows the cancel button when set.
  final VoidCallback? onCancel;

  /// The cancel button's accessible name.
  final String cancelLabel;
}

/// A reason the conversation cannot be posted to — `notice` in the source. It
/// replaces the input entirely.
@immutable
class DabblerComposerNotice {
  /// A notice.
  const DabblerComposerNotice({
    required this.text,
    this.icon = 'info-circle',
    this.actionLabel,
    this.onAction,
  });

  /// The explanation.
  final String text;

  /// The Iconsax glyph — `info-circle` by default (`notice.icon || 'info-circle'`).
  final String icon;

  /// Shows an outlined small action button when set.
  final String? actionLabel;

  /// Called by the action.
  final VoidCallback? onAction;
}
