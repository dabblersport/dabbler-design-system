import 'package:flutter/material.dart'
    show InputBorder, InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart' show TextInputAction, TextInputType;
import 'package:flutter/widgets.dart';

import '../feedback/spinner.dart';
import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';
import 'feed_atoms.dart';

/// ReplyComposer — the bar pinned under a post's replies: an optional
/// "Replying to" line with a cancel, a slot for attachment previews, attach
/// buttons, the field and the send button (KAN-412 gaps 5 item 9).
///
/// Transcribed from `Post.dc.html` (alpha-plan design set): the resting bar
/// at lines 329-341 and the "composing reply" frame at lines 525-580.
///
/// | Design (`Post.dc.html`) | Dart |
/// | --- | --- |
/// | `:329` bar `gap:9px; padding:12px 15px; border-top 1px --faint; --surface-page`, bottom 30 | `space3`; `space4` / `space5`; `bgTertiary` hairline; `bgPrimary`; bottom `space4` + the home-indicator inset |
/// | `:525` composing column `gap:12px` | `space4` between the reply line, [attachments] and the input row |
/// | `:528-532` `Replying to` 12/16 500 `--muted`, target 600 brand, `close-circle` 18 at the end | `caption1` `textSecondary`; [replyingTo] semibold `brandPrimary`; a 45px cancel target |
/// | `:330-336` attach glyphs 22, `gap:9px`, `--muted` | [attachActions] — caller [DabblerReplyComposerAction]s, 45px targets, `textSecondary` |
/// | `:338` input `height:42; padding 0 15; radius pill; --surface-sunken; 1px --outline-card`, 14/19 | `surfaceSunken`, `borderDefault`, [DabblerRadius.xxlAll] when [multiline], else pill; `subheadline` |
/// | `:339` send `42x42` circle, `send-2` 20 bold, brand / sunken | [sendSize] 45 circle, `brandPrimary` + `onBrand` when ready, `surfaceSunken` + `textTertiary` when not |
///
/// ## Deviations (recorded, not silent)
///
/// * **Send size.** 42 becomes the 45px touch minimum; the field's minimum
///   height follows (45).
/// * **Type.** 14/19 has no style; the field and placeholder take
///   `subheadline` (15/20).
/// * **The composing frame's boxed editor** (`:534`, a 2px brand border
///   around the previews and text, and a pill `Reply` button) is the same
///   content arranged for a full-height draft; this bar keeps the resting
///   layout and puts [attachments] above the input row.
///
/// ## Keyboard and safe area
///
/// Safe for `DabblerPage.bottomBar`: the page applies no bottom safe area
/// when a bottom bar is present, so this bar pads its own home-indicator
/// inset while the keyboard is closed, and drops it once the keyboard is
/// open (the page lifts the bar onto the keyboard).
///
/// RTL: attach buttons lead, send trails, the cancel sits at the inline end,
/// and the field aligns to the start of the text direction.
///
/// Accessibility: every button is at least 45px and named; the send button
/// is disabled (announced as such) while empty, [enabled] is false or
/// [sending].
class DabblerReplyComposer extends StatefulWidget {
  /// A reply bar.
  const DabblerReplyComposer({
    super.key,
    required this.onSend,
    this.controller,
    this.focusNode,
    this.placeholder = 'Post your reply…',
    this.replyingToLabel = 'Replying to',
    this.replyingTo,
    this.onCancelReply,
    this.attachments,
    this.attachActions = const <DabblerReplyComposerAction>[],
    this.multiline = false,
    this.maxLines = 5,
    this.sending = false,
    this.enabled = true,
    this.canSendEmpty = false,
    this.onChanged,
    this.sendLabel = 'Send',
    this.cancelReplyLabel = 'Cancel reply',
    this.padSafeArea = true,
    this.composing = false,
    this.counter,
    this.replyLabel = 'Reply',
  });

  /// Called with the field's text when send is pressed (or Enter in
  /// single-line mode). The caller clears the field.
  final ValueChanged<String> onSend;

  /// The field's controller; one is created when null.
  final TextEditingController? controller;

  /// The field's focus node; one is created when null.
  final FocusNode? focusNode;

  /// The field's hint, localised.
  final String placeholder;

  /// The lead-in of the reply line (`Replying to`), localised.
  final String replyingToLabel;

  /// Who is being replied to (`@moatazmustapha`). Null hides the line.
  final String? replyingTo;

  /// Cancels the targeted reply; null hides the cancel button.
  final VoidCallback? onCancelReply;

  /// Previews of what is attached — usually a row of
  /// `DabblerAttachmentChip`s. Null draws nothing.
  final Widget? attachments;

  /// Attach buttons at the start of the input row.
  final List<DabblerReplyComposerAction> attachActions;

  /// Whether the field grows to [maxLines] lines; Enter then adds a line.
  final bool multiline;

  /// The tallest the field grows in [multiline] mode.
  final int maxLines;

  /// Shows a spinner in the send button and disables it.
  final bool sending;

  /// Whether the field and buttons are live.
  final bool enabled;

  /// Whether send is live with an empty field (an attachment-only reply).
  final bool canSendEmpty;

  /// Called as the text changes.
  final ValueChanged<String>? onChanged;

  /// The send button's accessible name.
  final String sendLabel;

  /// The cancel button's accessible name.
  final String cancelReplyLabel;

  /// Whether the bar pads the home-indicator inset while the keyboard is
  /// closed. Turn off when the host already does.
  final bool padSafeArea;

  /// Draws the composing frame (`Post.dc.html:525-580`): previews and a
  /// multi-line field inside a boxed editor with a 2px brand border, and a
  /// toolbar of attach glyphs, [counter] and a pill [replyLabel] button
  /// under it. False keeps the resting bar.
  final bool composing;

  /// The length counter (`82/280`) at the toolbar's end; null hides it.
  final String? counter;

  /// The composing frame's pill button text (`Reply`); also the send name
  /// there.
  final String replyLabel;

  /// Send button and field minimum — the 45px touch minimum (design 42).
  static const double sendSize = DabblerSizing.touchTargetMin;

  /// Attach glyph side — `size="22"` (`:332`).
  static const double attachGlyphSize = 22;

  @override
  State<DabblerReplyComposer> createState() => _DabblerReplyComposerState();
}

/// One attach button in a [DabblerReplyComposer] — `gallery`, `location`.
@immutable
class DabblerReplyComposerAction {
  /// An attach button.
  const DabblerReplyComposerAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  }) : text = null;

  /// A text attach button — a pill reading [label] (e.g. `GIF`), which is
  /// also its accessible name (DS gaps 6, item 14). **Design frame
  /// missing:** `Post.dc.html` draws only icon actions (`:330-336`); the pill
  /// borrows the input's pill radius (`:338`), `caption1` semibold, a
  /// `borderDefault`-wide hairline and text in the glyphs' tint, `space3`
  /// inline padding and the 45px target.
  const DabblerReplyComposerAction.text({
    required this.label,
    required this.onTap,
    this.active = false,
  }) : icon = '',
       text = label;

  /// The Iconsax glyph name. Empty for a [DabblerReplyComposerAction.text].
  final String icon;

  /// The pill's visible text; null for an icon action.
  final String? text;

  /// The accessible name, localised.
  final String label;

  /// Called on tap; null draws it disabled.
  final VoidCallback? onTap;

  /// Whether something of this kind is attached — bold and brand-coloured,
  /// as in the composing frame (`:569-575`).
  final bool active;
}

class _DabblerReplyComposerState extends State<DabblerReplyComposer> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(DabblerReplyComposer old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      (old.controller ?? _ownController)?.removeListener(_onText);
      _controller.addListener(_onText);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onText);
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _onText() => setState(() {});

  bool get _ready =>
      widget.enabled &&
      !widget.sending &&
      (widget.canSendEmpty || _controller.text.trim().isNotEmpty);

  void _send() {
    if (_ready) widget.onSend(_controller.text);
  }

  /// [width] null: the 45px square; else the child's width, floored at 45.
  Widget _target({
    required String label,
    required VoidCallback? onTap,
    required Widget child,
    double? width,
  }) {
    final Widget box = width == null
        ? SizedBox(
            width: DabblerReplyComposer.sendSize,
            height: DabblerReplyComposer.sendSize,
            child: Center(child: child),
          )
        : ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: DabblerReplyComposer.sendSize,
              minHeight: DabblerReplyComposer.sendSize,
              maxHeight: DabblerReplyComposer.sendSize,
            ),
            child: Center(widthFactor: 1, child: child),
          );
    if (onTap == null) {
      return Semantics(
        button: true,
        enabled: false,
        label: label,
        excludeSemantics: true,
        child: box,
      );
    }
    return MergeSemantics(
      child: Semantics(
        enabled: true,
        child: DabblerFeedTappable(
          onTap: onTap,
          semanticLabel: label,
          excludeChildSemantics: true,
          borderRadius: DabblerRadius.pillAll,
          child: box,
        ),
      ),
    );
  }

  Widget _textPill(String text, Color ink, TextDirection dir) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: DabblerSpacing.space3,
      vertical: DabblerSpacing.space1,
    ),
    decoration: BoxDecoration(
      borderRadius: DabblerRadius.pillAll,
      border: Border.all(color: ink, width: DabblerSizing.borderDefault),
    ),
    child: Text(
      text,
      maxLines: 1,
      softWrap: false,
      style: DabblerType.caption1
          .resolveForDirection(dir)
          .copyWith(color: ink, fontWeight: DabblerType.semibold),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final bool live = widget.enabled && !widget.sending;
    final bool ready = _ready;
    final Duration fade = DabblerMotion.reduceMotion(context)
        ? Duration.zero
        : DabblerMotion.fast;
    final MediaQueryData? mq = MediaQuery.maybeOf(context);
    final double keyboard = mq?.viewInsets.bottom ?? 0;
    final double homeInset = widget.padSafeArea && keyboard == 0
        ? (mq?.viewPadding.bottom ?? 0)
        : 0;

    final TextStyle caption = DabblerType.caption1
        .resolveForDirection(dir)
        .copyWith(color: colors.textSecondary);
    final TextStyle inputStyle = DabblerType.subheadline
        .resolveForDirection(dir)
        .copyWith(color: colors.textPrimary);

    final Widget? replyLine = widget.replyingTo == null
        ? null
        : Row(
            children: <Widget>[
              Text(widget.replyingToLabel, maxLines: 1, style: caption),
              const SizedBox(width: DabblerSpacing.space2),
              Flexible(
                child: Text(
                  widget.replyingTo!,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: caption.copyWith(
                    color: colors.brandPrimary,
                    fontWeight: DabblerType.semibold,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.onCancelReply != null)
                _target(
                  label: widget.cancelReplyLabel,
                  onTap: widget.onCancelReply,
                  child: DabblerIcon(
                    'close-circle',
                    size: DabblerSizing.iconSm,
                    color: colors.textSecondary,
                  ),
                ),
            ],
          );

    final Widget textField = Material(
      type: MaterialType.transparency,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        enabled: widget.enabled,
        style: inputStyle,
        cursorColor: colors.textPrimary,
        minLines: 1,
        maxLines: widget.multiline ? widget.maxLines : 1,
        keyboardType: widget.multiline
            ? TextInputType.multiline
            : TextInputType.text,
        textInputAction: widget.multiline
            ? TextInputAction.newline
            : TextInputAction.send,
        onChanged: widget.onChanged,
        onSubmitted: widget.multiline ? null : (_) => _send(),
        decoration: InputDecoration(
          isDense: true,
          isCollapsed: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: widget.placeholder,
          hintStyle: inputStyle.copyWith(color: colors.textSecondary),
          hintMaxLines: 1,
        ),
      ),
    );

    final Widget field = AnimatedContainer(
      duration: fade,
      curve: DabblerMotion.easeOut,
      constraints: const BoxConstraints(
        minHeight: DabblerReplyComposer.sendSize,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DabblerSpacing.space5,
        vertical: DabblerSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: widget.multiline
            ? DabblerRadius.xxlAll
            : DabblerRadius.pillAll,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: textField,
    );

    final Widget send = _target(
      label: widget.sendLabel,
      onTap: ready ? _send : null,
      child: AnimatedContainer(
        duration: fade,
        curve: DabblerMotion.easeOut,
        width: DabblerReplyComposer.sendSize,
        height: DabblerReplyComposer.sendSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ready ? colors.brandPrimary : colors.surfaceSunken,
        ),
        child: Center(
          child: widget.sending
              ? const DabblerSpinner(size: DabblerSpinnerSize.sm)
              : DabblerIcon(
                  'send-2',
                  size: 20,
                  weight: DabblerIconWeight.bold,
                  color: ready ? colors.onBrand : colors.textTertiary,
                ),
        ),
      ),
    );

    final Widget inputRow = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        for (final DabblerReplyComposerAction a in widget.attachActions)
          _target(
            label: a.label,
            onTap: live ? a.onTap : null,
            width: a.text == null ? null : 0,
            child: Builder(
              builder: (_) {
                final Color ink = !live
                    ? colors.textTertiary
                    : a.active
                    ? colors.brandPrimary
                    : colors.textSecondary;
                if (a.text != null) return _textPill(a.text!, ink, dir);
                return DabblerIcon(
                  a.icon,
                  size: DabblerReplyComposer.attachGlyphSize,
                  weight: a.active
                      ? DabblerIconWeight.bold
                      : DabblerIconWeight.linear,
                  color: ink,
                );
              },
            ),
          ),
        if (widget.attachActions.isNotEmpty)
          const SizedBox(width: DabblerSpacing.space1),
        Expanded(child: field),
        const SizedBox(width: DabblerSpacing.space3),
        send,
      ],
    );

    if (widget.composing) {
      final Widget editor = DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: DabblerRadius.xlAll,
          border: Border.all(color: colors.brandPrimary, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DabblerSpacing.space4,
            vertical: DabblerSpacing.space3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (widget.attachments != null) ...<Widget>[
                widget.attachments!,
                const SizedBox(height: DabblerSpacing.space3),
              ],
              textField,
            ],
          ),
        ),
      );
      final Widget toolbar = Row(
        children: <Widget>[
          for (final DabblerReplyComposerAction a in widget.attachActions)
            _target(
              label: a.label,
              onTap: live ? a.onTap : null,
              width: a.text == null ? null : 0,
              child: a.text != null
                  ? _textPill(a.text!, colors.textSecondary, dir)
                  : DabblerIcon(
                      a.icon,
                      size: DabblerReplyComposer.attachGlyphSize,
                      weight: a.active
                          ? DabblerIconWeight.bold
                          : DabblerIconWeight.linear,
                      color: a.active
                          ? colors.brandPrimary
                          : colors.textSecondary,
                    ),
            ),
          const Spacer(),
          if (widget.counter != null) ...<Widget>[
            Text(
              DabblerType.toWesternDigits(widget.counter!),
              maxLines: 1,
              style: caption.copyWith(fontWeight: DabblerType.semibold),
            ),
            const SizedBox(width: DabblerSpacing.space4),
          ],
          _target(
            label: widget.sendLabel,
            onTap: ready ? _send : null,
            width: 0,
            child: AnimatedContainer(
              duration: fade,
              curve: DabblerMotion.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: DabblerSpacing.space7,
                vertical: DabblerSpacing.space3,
              ),
              decoration: BoxDecoration(
                borderRadius: DabblerRadius.pillAll,
                color: ready ? colors.brandPrimary : colors.surfaceSunken,
              ),
              child: widget.sending
                  ? const DabblerSpinner(size: DabblerSpinnerSize.sm)
                  : Text(
                      widget.replyLabel,
                      maxLines: 1,
                      style: DabblerType.subheadline
                          .resolveForDirection(dir)
                          .copyWith(
                            color: ready ? colors.onBrand : colors.textTertiary,
                            fontWeight: DabblerType.semibold,
                          ),
                    ),
            ),
          ),
        ],
      );
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.bgPrimary,
          border: Border(
            top: BorderSide(
              color: colors.bgTertiary,
              width: DabblerSizing.borderDefault,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: DabblerSpacing.space5,
            end: DabblerSpacing.space5,
            top: DabblerSpacing.space4,
            bottom: DabblerSpacing.space4 + homeInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (replyLine != null) ...<Widget>[
                replyLine,
                const SizedBox(height: DabblerSpacing.space2),
              ],
              editor,
              const SizedBox(height: DabblerSpacing.space2),
              toolbar,
            ],
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgPrimary,
        border: Border(
          top: BorderSide(
            color: colors.bgTertiary,
            width: DabblerSizing.borderDefault,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: DabblerSpacing.space5,
          end: DabblerSpacing.space5,
          top: DabblerSpacing.space4,
          bottom: DabblerSpacing.space4 + homeInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (replyLine != null) ...<Widget>[
              replyLine,
              const SizedBox(height: DabblerSpacing.space2),
            ],
            if (widget.attachments != null) ...<Widget>[
              widget.attachments!,
              const SizedBox(height: DabblerSpacing.space4),
            ],
            inputRow,
          ],
        ),
      ),
    );
  }
}
