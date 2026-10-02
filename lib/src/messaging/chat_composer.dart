import 'package:flutter/material.dart'
    show InputBorder, InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart' show TextInputAction, TextInputType;
import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../feedback/spinner.dart';
import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';
import 'messaging_foundations.dart';
import 'messaging_parts.dart';

part 'chat_composer_models.dart';
part 'chat_composer_targets.dart';
part 'chat_composer_notice.dart';

/// ChatComposer — the persistent input surface for composing and sending a
/// message inside a conversation.
///
/// Ported from the live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
/// (Dabbler Design System), `components/messaging/ChatComposer.jsx` and
/// `ChatComposer.prompt.md`, read via DesignSync `get_file` on 2026-10-02 and
/// hand-transcribed to the coordinator's local mirror (no byte check). No browser or
/// side-by-side comparison has been done.
///
/// **Injected view-model only.** The widget holds no backend, audio, realtime or
/// draft state: [value] is controlled (the caller feeds it back through
/// [onChange]), and every action is a callback.
///
/// ## Source-to-Dart mapping
///
/// | Source (`ChatComposer.jsx`) | Dart |
/// |---|---|
/// | root `paddingInline: --space-3`, `paddingBlockStart: --space-3`, `paddingBlockEnd: --space-4`, gap `--space-3` | 9 / 9 / 12, gap 9 |
/// | `borderBlockStart: 1px solid --faint`, `background: --surface-page` | top border [DabblerColors.bgTertiary], fill [DabblerColors.bgPrimary] |
/// | notice: padding `--space-3 --space-4`, `--radius-md`, `--surface-sunken`, 1px `--faint`, gap `--space-3` | 9 / 12, radius 9, [DabblerColors.surfaceSunken], 1px [DabblerColors.bgTertiary], gap 9 |
/// | notice icon 18 `--muted`, text `t-caption-1` `--muted`, action `Button outlined small` | 18 [DabblerColors.textSecondary], [DabblerType.caption1], [DabblerButton] outlined small |
/// | quick-reply rail: gap `--space-2`, `paddingInline --space-1`, `overflowX: auto` | gap 6, inline padding 3, horizontal scroll from the inline start |
/// | quick reply: min-height 45, `paddingInline --space-5`, `--radius-pill`, `--surface-card`, 1px `--outline-card`, `t-footnote` weight 500 `--ink` | min-height 45, inline 15, pill, [DabblerColors.surfaceCard], 1px [DabblerColors.borderDefault], [DabblerType.footnote] w500 [DabblerColors.textPrimary] |
/// | input row: `alignItems: flex-end`, gap `--space-1` | cross-axis end, gap 3 |
/// | attach: 45x45 pill, transparent, glyph `add-circle` 24, `--ink` (off: `--subtle`) | same; off glyph [DabblerColors.textTertiary] (see below) |
/// | field: min-height 45, `paddingInline --space-5`, `--radius-xxl`, `--surface-card` (off: `--surface-sunken`), 1px `--outline-card`, gap `--space-2` | min-height 45, inline 15, radius 24, same fills, 1px border, gap 6 |
/// | input: `t-subheadline`, `--ink`, `paddingBlock --space-4` | [DabblerType.subheadline] (Arabic 14.1/23), [DabblerColors.textPrimary], block 12 |
/// | emoji: 45x45, `marginInlineEnd: calc(--space-3 * -1)`, `emoji-happy` 20 `--muted`, no press scale | 45x45, the field's end padding is 15 - 9 = 6, [DabblerColors.textSecondary], no press scale |
/// | send: 45x45 pill, `--color-brand-primary` / `--color-on-brand` when ready, else `--surface-sunken` / `--subtle`; `send-2` bold 20; sending: `Spinner sm`; `transition background --motion-fast --ease-out` | same; off glyph [DabblerColors.textTertiary]; [DabblerMotion.fast], [DabblerMotion.easeOut], zero under reduced motion |
/// | `ready = value.trim().length > 0 && !off`; Enter sends when ready | same |
///
/// ## Deliberate deviations
///
/// * `--muted` and `--subtle` are surface-ramp neutrals that `D-003(a)` demoted
///   from text roles: muted text and glyphs use the secondary role, and the
///   disabled glyphs (live `--subtle`) use [DabblerColors.textTertiary], the
///   role the system gives inactive controls. This also lets them follow dark
///   mode, which the light-only palette literals cannot.
/// * The source sets no placeholder colour (the browser default applies); this
///   uses [DabblerColors.textSecondary], the system's placeholder role
///   (`D-003(a)`), and [DabblerColors.textTertiary] when [off] (`D-025`).
/// * The prompt says the field "takes the shared `.dbl-focus` ring"; the JSX
///   attaches no focus class to the input or its wrapper (its own outline is
///   `none`). The focus ring is drawn around the field, as the prompt states.
class DabblerChatComposer extends StatefulWidget {
  /// A composer.
  const DabblerChatComposer({
    super.key,
    this.value = '',
    this.onChange,
    this.onSend,
    this.placeholder,
    this.onAttach,
    this.onEmoji,
    this.attachLabel = 'Add attachment',
    this.emojiLabel = 'Emoji',
    this.sendLabel = 'Send',
    this.quickReplies = const <String>[],
    this.onQuickReply,
    this.replyTo,
    this.notice,
    this.state = DabblerChatComposerState.normal,
    this.disabled = false,
  });

  /// The draft — controlled; feed it back through [onChange].
  final String value;

  /// Called with the new text on every edit.
  final ValueChanged<String>? onChange;

  /// Called by the send button and by Enter, only when there is something to
  /// send and the composer is not [off].
  final VoidCallback? onSend;

  /// The field's placeholder.
  final String? placeholder;

  /// The attach target appears only when this is set.
  final VoidCallback? onAttach;

  /// The emoji target appears only when this is set.
  final VoidCallback? onEmoji;

  /// The attach target's accessible name.
  final String attachLabel;

  /// The emoji target's accessible name.
  final String emojiLabel;

  /// The send target's accessible name.
  final String sendLabel;

  /// Suggested one-tap replies, shown only when there is no [notice] and no
  /// [replyTo].
  final List<String> quickReplies;

  /// Called with the chosen quick reply.
  final ValueChanged<String>? onQuickReply;

  /// The message being replied to; shown above the field.
  final DabblerComposerReply? replyTo;

  /// Replaces the input entirely, for conversations that cannot be posted to.
  final DabblerComposerNotice? notice;

  /// The composer's state.
  final DabblerChatComposerState state;

  /// Makes every target inert.
  final bool disabled;

  /// `--touch-target-min` — every icon target and the field's floor.
  static const double target = DabblerSizing.touchTargetMin;

  /// Whether the field and every target are inert — `off` in the source.
  bool get off =>
      disabled ||
      state == DabblerChatComposerState.disabled ||
      state == DabblerChatComposerState.sending;

  /// Whether the send target is live — `ready` in the source.
  bool get ready => value.trim().isNotEmpty && !off;

  @override
  State<DabblerChatComposer> createState() => _DabblerChatComposerState();
}

class _DabblerChatComposerState extends State<DabblerChatComposer> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(_onFocus);
  }

  void _onFocus() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void didUpdateWidget(DabblerChatComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (widget.ready) widget.onSend?.call();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool hasNotice = widget.notice != null;
    final bool hasReply = !hasNotice && widget.replyTo != null;
    final bool hasQuick =
        !hasNotice && !hasReply && widget.quickReplies.isNotEmpty;
    final List<Widget> children = <Widget>[
      if (hasNotice) _buildNotice(context, colors, widget.notice!),
      if (hasReply) _buildReply(widget.replyTo!),
      if (hasQuick) _buildQuickReplies(context, colors),
      if (!hasNotice) _buildInputRow(context, colors),
    ];
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
        padding: const EdgeInsetsDirectional.fromSTEB(
          DabblerSpacing.space3,
          DabblerSpacing.space3,
          DabblerSpacing.space3,
          DabblerSpacing.space4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int i = 0; i < children.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: DabblerSpacing.space3),
              children[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReply(DabblerComposerReply reply) =>
      DabblerMessageReplyReference(
        variant: DabblerReplyVariant.composer,
        sender: reply.sender,
        content: reply.content,
        attachmentLabel: reply.attachmentLabel,
        onCancel: reply.onCancel,
        cancelLabel: reply.cancelLabel,
      );

  Widget _buildQuickReplies(BuildContext context, DabblerColors colors) {
    final TextDirection dir = Directionality.of(context);
    final bool off = widget.off;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: DabblerSpacing.space1,
        ),
        child: Row(
          children: <Widget>[
            for (int i = 0; i < widget.quickReplies.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: DabblerSpacing.space2),
              _Target(
                label: widget.quickReplies[i],
                onTap: off
                    ? null
                    : () => widget.onQuickReply?.call(widget.quickReplies[i]),
                ringRadius: DabblerRadius.pillAll,
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: DabblerChatComposer.target,
                  ),
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: DabblerSpacing.space5,
                  ),
                  alignment: AlignmentDirectional.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    borderRadius: DabblerRadius.pillAll,
                    border: Border.all(
                      color: colors.borderDefault,
                      width: DabblerSizing.borderDefault,
                    ),
                  ),
                  child: Text(
                    widget.quickReplies[i],
                    maxLines: 1,
                    softWrap: false,
                    style: DabblerType.footnote
                        .resolveForDirection(dir)
                        .copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(BuildContext context, DabblerColors colors) {
    final bool off = widget.off;
    final bool ready = widget.ready;
    final bool sending = widget.state == DabblerChatComposerState.sending;
    final TextDirection dir = Directionality.of(context);
    final Color disabledGlyph = colors.textTertiary;
    final Duration fade = DabblerMotion.reduceMotion(context)
        ? Duration.zero
        : DabblerMotion.fast;

    final TextStyle inputStyle = DabblerType.subheadline
        .resolveForDirection(dir)
        .copyWith(color: colors.textPrimary);

    final Widget field = _FieldRing(
      visible: _focused,
      child: AnimatedContainer(
        duration: fade,
        curve: DabblerMotion.easeOut,
        constraints: const BoxConstraints(
          minHeight: DabblerChatComposer.target,
        ),
        // `paddingInline --space-5` (15); with the emoji target the source's
        // `marginInlineEnd: -9` leaves 6 between it and the field edge.
        padding: EdgeInsetsDirectional.only(
          start: DabblerSpacing.space5,
          end: widget.onEmoji != null
              ? DabblerSpacing.space5 - DabblerSpacing.space3
              : DabblerSpacing.space5,
        ),
        decoration: BoxDecoration(
          color: off ? colors.surfaceSunken : colors.surfaceCard,
          borderRadius: DabblerRadius.xxlAll,
          border: Border.all(
            color: colors.borderDefault,
            width: DabblerSizing.borderDefault,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: DabblerSpacing.space4,
                ),
                // Material's TextField needs a Material ancestor for its
                // selection toolbar; transparency paints nothing.
                child: Material(
                  type: MaterialType.transparency,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !off,
                    style: inputStyle,
                    // The source sets no caret colour, so the caret is the
                    // input's own ink.
                    cursorColor: colors.textPrimary,
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    onChanged: widget.onChange,
                    // Enter sends when ready; keeping the handler stops the
                    // default "done" behaviour from dropping focus.
                    onEditingComplete: _send,
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
                      hintStyle: inputStyle.copyWith(
                        color: off ? colors.textTertiary : colors.textSecondary,
                      ),
                      hintMaxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.onEmoji != null) ...<Widget>[
              const SizedBox(width: DabblerSpacing.space2),
              _Target(
                label: widget.emojiLabel,
                onTap: off ? null : widget.onEmoji,
                ringRadius: DabblerRadius.pillAll,
                scale: false,
                child: SizedBox(
                  width: DabblerChatComposer.target,
                  height: DabblerChatComposer.target,
                  child: Center(
                    child: DabblerIcon(
                      'emoji-happy',
                      size: 20,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (widget.onAttach != null) ...<Widget>[
          _Target(
            label: widget.attachLabel,
            onTap: off ? null : widget.onAttach,
            ringRadius: DabblerRadius.pillAll,
            child: SizedBox(
              width: DabblerChatComposer.target,
              height: DabblerChatComposer.target,
              child: Center(
                child: DabblerIcon(
                  'add-circle',
                  size: DabblerSizing.iconMd,
                  color: off ? disabledGlyph : colors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: DabblerSpacing.space1),
        ],
        Expanded(child: field),
        const SizedBox(width: DabblerSpacing.space1),
        _Target(
          label: widget.sendLabel,
          onTap: ready ? _send : null,
          ringRadius: DabblerRadius.pillAll,
          child: AnimatedContainer(
            duration: fade,
            curve: DabblerMotion.easeOut,
            width: DabblerChatComposer.target,
            height: DabblerChatComposer.target,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ready ? colors.brandPrimary : colors.surfaceSunken,
            ),
            child: Center(
              child: sending
                  ? const DabblerSpinner(size: DabblerSpinnerSize.sm)
                  : DabblerIcon(
                      'send-2',
                      weight: DabblerIconWeight.bold,
                      size: 20,
                      color: ready ? colors.onBrand : disabledGlyph,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
