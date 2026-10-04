import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/text.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The tone of a [DabblerInlineMessage].
enum DabblerInlineMessageTone {
  /// `--color-status-error-strong`, the `danger` glyph.
  error(DabblerTextTone.error, 'danger'),

  /// `--color-status-success-strong`, the `tick-circle` glyph.
  success(DabblerTextTone.success, 'tick-circle'),

  /// `--color-status-warning-strong`, the `warning-2` glyph.
  warning(DabblerTextTone.warning, 'warning-2'),

  /// `--color-status-info-strong`, the `info-circle` glyph.
  info(DabblerTextTone.info, 'info-circle');

  const DabblerInlineMessageTone(this.textTone, this.glyph);

  /// The text role the message and its glyph are drawn in.
  final DabblerTextTone textTone;

  /// The tone's default Iconsax glyph.
  final String glyph;
}

/// InlineMessage — one line of status text with a bold glyph, set directly
/// under the control it explains.
///
/// Transcribed from the OTP frame of `Auth and Onboarding.dc.html:230-235`
/// (and the states board's code-input group, `:885-893`): a row,
/// `gap: 6px`, in `--color-status-error-strong`, holding a bold `danger`
/// glyph at `size="16"` and a `13px/18px`, weight 500 message — *"That code
/// is not right. Check the email and try again."*, with `clock` for the
/// expired code.
///
/// It is not a [DabblerBanner]: there is no fill, hairline or radius, only the
/// glyph and the words, so it sits under a field the way a field's own error
/// line does. Use it for a control that has no `errorText` of its own — a
/// code input, a toggle row. A field with `errorText` keeps using that.
///
/// ```dart
/// DabblerInlineMessage('That code is not right.')
/// DabblerInlineMessage('This code has expired.', icon: 'clock')
/// DabblerInlineMessage('Available.', tone: DabblerInlineMessageTone.success)
/// ```
///
/// | source | here |
/// |---|---|
/// | `gap: 6px` | [DabblerSpacing.iconGap] |
/// | glyph `size="16"`, `type="bold"` | [DabblerSizing.iconInline] (15), bold |
/// | `13px/18px`, weight 500 | [DabblerType.footnote] at medium |
/// | `color: var(--color-status-error-strong)` | the tone's strong role, glyph and text alike |
///
/// **Deviation:** the glyph is 15, the nearest step of the sizing roles to the
/// source's 16.
///
/// ## Meaning is never the colour alone
///
/// The glyph and the words carry the state; the tint only reinforces them.
/// An error or warning is a live region, so a screen reader announces it when
/// it appears.
///
/// ## RTL
///
/// A [Row]: the glyph sits at the inline start and the message flows from it.
/// Nothing is mirrored by hand.
class DabblerInlineMessage extends StatelessWidget {
  /// Creates an inline message.
  const DabblerInlineMessage(
    this.message, {
    super.key,
    this.tone = DabblerInlineMessageTone.error,
    this.icon,
  });

  /// The words.
  final String message;

  /// Which status the message reports. Default [DabblerInlineMessageTone.error].
  final DabblerInlineMessageTone tone;

  /// An Iconsax glyph name replacing the tone's own — `clock` for an expired
  /// code. Always drawn bold.
  final String? icon;

  /// Whether a screen reader is interrupted when the message appears.
  bool get interrupts =>
      tone == DabblerInlineMessageTone.error ||
      tone == DabblerInlineMessageTone.warning;

  @override
  Widget build(BuildContext context) {
    final Color color = tone.textTone.colorIn(DabblerColors.of(context))!;
    return Semantics(
      container: true,
      liveRegion: interrupts,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ExcludeSemantics(
            child: DabblerIcon(
              icon ?? tone.glyph,
              weight: DabblerIconWeight.bold,
              size: DabblerSizing.iconInline,
              color: color,
            ),
          ),
          const SizedBox(width: DabblerSpacing.iconGap),
          Expanded(
            child: DabblerText(
              message,
              style: DabblerType.footnote,
              weight: DabblerTextWeight.medium,
              tone: tone.textTone,
            ),
          ),
        ],
      ),
    );
  }
}
