import 'package:flutter/material.dart'
    show InputBorder, InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/widgets.dart';

import '../feed/feed_atoms.dart';
import '../feedback/spinner.dart';
import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_home_frame.dart';
import '../tokens/dabbler_type.dart';

/// EmojiTile — one square choice in a create sheet's sport row: an emoji over
/// a short label.
///
/// Transcribed from `Home Feed.dc.html` (alpha-plan design set) lines
/// 1144-1149 (Create meet-up) and 944-949 (Create game): `69px` square inside
/// a 1px hairline (content-box, so 71 measured), `--radius-lg`, the emoji at
/// `28px/34px`, the label 13/18 400; idle on the card fill with the card
/// hairline and `--ink-soft` label, selected on `--color-status-info-surface`
/// with a transparent hairline and the `--color-status-info-strong` label
/// (`tile()`, `:2952-2962`). Tiles sit `gap: 9px` apart, wrapping.
///
/// ## Deviations
///
/// * **Type.** 13/18 is `footnote`. The emoji is set in the sans role at
///   [emojiSize] / [emojiLeading]; the platform's emoji font draws it.
/// * **No check mark.** Unlike [DabblerSelectableCard]'s tile the frame draws
///   none; selection is the fill and the label ink.
///
/// RTL: tiles follow the row's direction (the frame's Arabic copy runs right to
/// left). Accessibility: one button, selected state, named by [label].
class DabblerEmojiTile extends StatelessWidget {
  /// An emoji choice tile.
  const DabblerEmojiTile({
    super.key,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
    this.semanticLabel,
  });

  /// The glyph, a Unicode emoji.
  final String emoji;

  /// The short name under it.
  final String label;

  /// Whether this tile is the chosen one.
  final bool selected;

  /// Called on tap; null disables the tile.
  final VoidCallback? onTap;

  /// The accessible name; falls back to [label].
  final String? semanticLabel;

  /// The measured outer side — `69px` declared, plus the 1px hairline each
  /// side under `box-sizing: content-box`: **71**.
  static const double side = 71;

  /// The emoji's size — `font-size: 28px`.
  static const double emojiSize = 28;

  /// The emoji's line — `line-height: 34px`.
  static const double emojiLeading = 34;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final TextStyle base = DabblerType.footnote.resolveForDirection(dir);
    return Semantics(
      selected: selected,
      child: DabblerFeedTappable(
        onTap: onTap,
        semanticLabel: semanticLabel ?? label,
        excludeChildSemantics: true,
        borderRadius: DabblerRadius.lgAll,
        child: Container(
          width: side,
          height: side,
          decoration: BoxDecoration(
            color: selected ? colors.info.surface : colors.surfaceCard,
            borderRadius: DabblerRadius.lgAll,
            border: Border.all(
              color: selected
                  ? colors.info.surface.withValues(alpha: 0)
                  : colors.borderDefault,
              width: DabblerSizing.borderDefault,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                emoji,
                maxLines: 1,
                style: base.copyWith(
                  fontSize: emojiSize,
                  height: emojiLeading / emojiSize,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DabblerSpacing.space1,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: base.copyWith(
                    color: selected ? colors.info.strong : colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ComposerField — the plain input of a create sheet: title (one line) or
/// description (several).
///
/// Transcribed from `Home Feed.dc.html` (alpha-plan design set) line 1151
/// (Create meet-up; the Create game sheet draws the same): card fill, 1px card
/// hairline, `--radius-lg`, `padding: 0 15px` (one line, `height: 48px`) or
/// `padding: 15px` (`min-height: 96px`), 15/20 ink, `box-sizing: border-box`.
///
/// ## Deviations
///
/// * **Type.** 15/20 is `subheadline`; the hint takes `textSecondary` as
///   [DabblerComposerBox] does (the frame leaves it to the browser default).
///
/// RTL: the text aligns to the reading direction.
class DabblerComposerField extends StatefulWidget {
  /// A create-sheet input.
  const DabblerComposerField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.onChanged,
    this.multiline = false,
    this.focusNode,
  });

  /// The field's controller.
  final TextEditingController controller;

  /// The hint shown while empty.
  final String placeholder;

  /// Called as the text changes.
  final ValueChanged<String>? onChanged;

  /// The description shape: top-aligned, [multilineMinHeight] tall at least.
  final bool multiline;

  /// The field's focus node.
  final FocusNode? focusNode;

  /// The one-line height — `height: 48px`.
  static const double height = DabblerSpacing.space11;

  /// The description's floor — `min-height: 96px`.
  static const double multilineMinHeight = DabblerSpacing.space11 * 2;

  /// Text to the box edge: the 15 padding inside the 1px hairline.
  static const double inset =
      DabblerSpacing.space5 + DabblerSizing.borderDefault;

  @override
  State<DabblerComposerField> createState() => _DabblerComposerFieldState();
}

class _DabblerComposerFieldState extends State<DabblerComposerField> {
  FocusNode? _own;

  FocusNode get _focus => widget.focusNode ?? (_own ??= FocusNode());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final TextStyle input = DabblerType.subheadline
        .resolveForDirection(dir)
        .copyWith(color: colors.textPrimary);
    final bool multiline = widget.multiline;
    const double height = DabblerComposerField.height;
    const double multilineMinHeight = DabblerComposerField.multilineMinHeight;
    const double inset = DabblerComposerField.inset;
    // The whole box focuses the input: the description's floor is taller
    // than its first line, and a tap anywhere in it should start typing.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focus.requestFocus,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: multiline ? multilineMinHeight : height,
          maxHeight: multiline ? double.infinity : height,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: DabblerRadius.lgAll,
            border: Border.all(
              color: colors.borderDefault,
              width: DabblerSizing.borderDefault,
            ),
          ),
          child: Padding(
            padding: multiline
                ? const EdgeInsets.all(inset)
                : const EdgeInsets.symmetric(horizontal: inset),
            child: Align(
              alignment: multiline
                  ? AlignmentDirectional.topStart
                  : AlignmentDirectional.centerStart,
              heightFactor: 1,
              child: Material(
                type: MaterialType.transparency,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  onChanged: widget.onChanged,
                  minLines: 1,
                  maxLines: multiline ? 6 : 1,
                  style: input,
                  cursorColor: colors.brandPrimary,
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: widget.placeholder,
                    hintStyle: input.copyWith(color: colors.textSecondary),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ComposerSubmit — a create sheet's call to action.
///
/// Transcribed from `Home Feed.dc.html` (alpha-plan design set) line 1277
/// (Create meet-up) and 1060 (Create game): `height: 48px`, pill, 15/20 400;
/// enabled on `--color-brand-primary` with `--color-on-brand` ink, disabled on
/// `--surface-sunken` with `--subtle` ink (`meetupCtaBg` / `meetupCtaFg`,
/// `:3469-3470`). It is not a dimmed button: the disabled state is its own
/// paint.
///
/// ## Deviations
///
/// * **Disabled ink.** `--subtle` is barred as a text colour (`D-003(a)`,
///   2.15:1); the disabled label takes `textTertiary` (`--muted`).
/// * **Type.** 15/20 is `subheadline`.
/// * **Loading.** The frame draws none; a small on-brand spinner replaces the
///   label while [loading].
///
/// Accessibility: one button named [label], disabled while not [enabled].
class DabblerComposerSubmit extends StatelessWidget {
  /// A create-sheet call to action.
  const DabblerComposerSubmit({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
    this.footer = false,
  });

  /// Draws the frame's footer block round the button: a 1px `--faint` rule
  /// above, 12 over and 24 under it (`padding-block:12px 24px;
  /// border-top:1px solid var(--faint)`, `Home Feed.dc.html:1276`).
  final bool footer;

  /// The action's words.
  final String label;

  /// Called on tap while [enabled] and not [loading].
  final VoidCallback? onPressed;

  /// Whether the action can run; false draws the sunken paint.
  final bool enabled;

  /// Whether the action is running.
  final bool loading;

  /// The button's height — `height: 48px`.
  static const double height = DabblerSpacing.space11;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final bool live = enabled && !loading && onPressed != null;
    final Color fill = enabled ? colors.brandPrimary : colors.surfaceSunken;
    final Color ink = enabled ? colors.onBrand : colors.textTertiary;
    final Widget button = Semantics(
      button: true,
      enabled: live,
      label: label,
      excludeSemantics: true,
      child: DabblerFeedTappable(
        onTap: live ? onPressed : null,
        borderRadius: DabblerRadius.pillAll,
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: DabblerRadius.pillAll,
          ),
          child: loading
              ? const DabblerSpinner(
                  size: DabblerSpinnerSize.sm,
                  tone: DabblerSpinnerTone.onBrand,
                )
              : Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DabblerType.subheadline
                      .resolveForDirection(dir)
                      .copyWith(color: ink),
                ),
        ),
      ),
    );
    if (!footer) return button;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colors.bgTertiary,
            width: DabblerSizing.borderDefault,
          ),
        ),
      ),
      child: Padding(
        // The rule is painted inside the box; the 12 starts under it.
        padding: const EdgeInsets.only(
          top: DabblerSpacing.space4 + DabblerSizing.borderDefault,
          bottom: DabblerSpacing.space8,
        ),
        child: button,
      ),
    );
  }
}

/// ComposerRow — one setting in a create sheet: a leading glyph, the
/// setting's name over a one-line caption, and a control at the end.
///
/// Transcribed from `Home Feed.dc.html` (alpha-plan design set) lines
/// 1155-1196 and 1204-1270 (Create meet-up; the Create game rows are the
/// same): `display:flex; gap:12px; padding:14px 0; border-bottom:1px solid
/// var(--faint)`, a 20px glyph in `--ink-soft`, the name 15/20 `--ink`, the
/// caption 13/18 `--muted` 1px under it. The last row of a group drops the
/// rule (`border-style: none`).
///
/// | Design | Dart |
/// | --- | --- |
/// | padding 14 / 0 | [DabblerHomeFrame.actionRowPaddingBlock] |
/// | glyph 20 `--ink-soft`, gap 12 | [DabblerHomeFrame.listRowGlyph] `textSecondary`, `space4` |
/// | name 15/20 `--ink` | `subheadline`, `textPrimary` |
/// | caption 13/18 `--muted`, gap 1 | `footnote`, `textTertiary`, [DabblerHomeFrame.listRowSubtitleGap] |
/// | rule 1px `--faint` | `borderDefault` width, `bgTertiary` |
///
/// RTL: the glyph leads at the inline start and the control trails.
class DabblerComposerRow extends StatelessWidget {
  /// A create-sheet setting row.
  const DabblerComposerRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.divider = true,
  });

  /// The kebab-case Iconsax name.
  final String icon;

  /// The setting's name.
  final String title;

  /// The caption under the name.
  final String? subtitle;

  /// The control at the inline end.
  final Widget? trailing;

  /// Whether the 1px `--faint` rule closes the row.
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(
                bottom: BorderSide(
                  color: colors.bgTertiary,
                  width: DabblerSizing.borderDefault,
                ),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DabblerHomeFrame.actionRowPaddingBlock,
        ),
        child: Row(
          spacing: DabblerSpacing.space4,
          children: <Widget>[
            DabblerIcon(
              icon,
              size: DabblerHomeFrame.listRowGlyph,
              color: colors.textSecondary,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: DabblerHomeFrame.listRowSubtitleGap,
                children: <Widget>[
                  Text(
                    title,
                    style: DabblerType.subheadline
                        .resolveForDirection(dir)
                        .copyWith(color: colors.textPrimary),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DabblerType.footnote
                          .resolveForDirection(dir)
                          .copyWith(color: colors.textTertiary),
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
