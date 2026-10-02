import 'package:flutter/widgets.dart';

/// Paragraph direction for user-authored messaging text — the Flutter
/// counterpart of HTML `dir="auto"`.
///
/// Message content and quoted reply text are written by people, so their
/// direction belongs to the text, not to the app's ambient [Directionality]:
/// an English message in an Arabic UI must still end with its own full stop
/// on the right (`I will bring one.`, not `.I will bring one`). The rule is
/// the HTML one: the first strong character decides; text with no strong
/// character (digits, emoji, punctuation) inherits the ambient direction.
///
/// Placement of the bubble itself stays on the ambient direction; only the
/// paragraph inside follows the text.
abstract final class DabblerAutoDirection {
  const DabblerAutoDirection._();

  static final RegExp _strong = RegExp(
    // RTL: Hebrew, Arabic, Syriac, Thaana, NKo, Samaritan, Arabic ext. and
    // presentation forms. LTR: Latin, Greek, Cyrillic and other alphabetic
    // letters outside those blocks.
    r'[֐-ࣿיִ-﷿ﹰ-﻿]|'
    r'[A-Za-zÀ-ɏͰ-ϿЀ-ԯ]',
  );

  static bool _isRtl(int c) =>
      (c >= 0x0590 && c <= 0x08FF) ||
      (c >= 0xFB1D && c <= 0xFDFF) ||
      (c >= 0xFE70 && c <= 0xFEFF);

  /// The direction of [text]'s first strong character, or null if none.
  static TextDirection? detect(String text) {
    final Match? m = _strong.firstMatch(text);
    if (m == null) return null;
    return _isRtl(m.group(0)!.codeUnitAt(0))
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// [detect], falling back to [ambient].
  static TextDirection resolve(String text, TextDirection ambient) =>
      detect(text) ?? ambient;
}

/// A [Text] whose paragraph direction and start alignment come from its own
/// content ([DabblerAutoDirection]), not from the ambient direction.
///
/// With [fill], the text takes the full available width so a short line sits
/// at its *own* start (use it only where the parent's width is bounded).
class DabblerAutoDirectionText extends StatelessWidget {
  /// Auto-direction text.
  const DabblerAutoDirectionText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.fill = false,
  });

  /// The user-authored string.
  final String data;

  /// The text style.
  final TextStyle? style;

  /// Maximum lines.
  final int? maxLines;

  /// Overflow treatment.
  final TextOverflow? overflow;

  /// Whether to take the full bounded width.
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final TextDirection d = DabblerAutoDirection.resolve(
      data,
      Directionality.of(context),
    );
    final Widget text = Text(
      data,
      textDirection: d,
      textAlign: TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
      style: style,
    );
    return fill ? SizedBox(width: double.infinity, child: text) : text;
  }
}
