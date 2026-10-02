/// The shared messaging parts: the reply reference, the reaction row, the
/// reaction picker and the in-thread notice. The shared-object card lives in
/// `messaging_shared_object_card.dart` (re-exported here) to keep both files
/// under the 500-line ceiling.
///
/// Source: live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
/// (Dabbler Design System), files `components/messaging/*.jsx` and
/// `*.prompt.md`, read via DesignSync get_file on 2026-10-02 and transcribed to
/// a local mirror by the coordinator.
library;

import 'package:flutter/widgets.dart';

import '../feedback/banner.dart';
import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'messaging_auto_direction.dart';
import 'messaging_foundations.dart';

export 'messaging_shared_object_card.dart';

TextStyle _t(BuildContext c, DabblerTypeStyle s) =>
    s.resolveForDirection(Directionality.of(c));

/// The variants of a [DabblerMessageReplyReference].
enum DabblerReplyVariant {
  /// Inside an incoming bubble — a brand rule, muted body.
  message,

  /// Inside an outgoing bubble — an on-brand rule and body.
  onBrand,

  /// Above the composer — on a sunken fill with a cancel button.
  composer,
}

/// MessageReplyReference — the quoted message.
///
/// Source: `components/messaging/MessageReplyReference.jsx`.
///
/// | Source | Dart |
/// |---|---|
/// | `borderInlineStart: 2px solid rule` | start rule, [ruleWidth] |
/// | rule `--color-brand-primary` / `--color-on-brand` | `brandPrimary` / `onBrand` |
/// | body `--muted` / `--color-on-brand` | `textSecondary` (D-003(a)) / `onBrand` |
/// | `paddingInlineStart: --space-3`, `paddingBlock: --space-1` | 9 / 3 |
/// | composer: `--surface-sunken`, `--radius-md`, `paddingInlineEnd: --space-3` | `surfaceSunken`, 9px radius, end 9 |
/// | `gap: --space-3` text ↔ cancel | [cancelGap] 9 |
/// | cancel `marginInlineEnd: -space-2` | end padding shrunk by 6 (no negative padding in Flutter) |
/// | cancel `marginBlock: -space-2` | **not ported**: the 45px target keeps its full height, so the row is 12px taller than live |
/// | sender `.t-caption-2` 700, rule colour, unclamped | caption2 w700 |
/// | body `.t-caption-1` `.dbl-clamp-2` | caption1, 2 lines, ellipsis |
/// | attachment `gallery` 13px + `--space-1` gap | `gallery` 13 + 3 |
/// | cancel `close-circle` 18, `--muted` glyph | iconSm, `textTertiary` (the `--muted` light value) |
class DabblerMessageReplyReference extends StatelessWidget {
  /// A reply reference.
  const DabblerMessageReplyReference({
    super.key,
    required this.sender,
    this.content,
    this.attachmentLabel,
    this.variant = DabblerReplyVariant.message,
    this.onCancel,
    this.cancelLabel = 'Cancel reply',
  });

  /// Who wrote the quoted message.
  final String sender;

  /// The quoted text.
  final String? content;

  /// Set instead of [content] when the quoted message was an attachment.
  final String? attachmentLabel;

  /// Where it is drawn.
  final DabblerReplyVariant variant;

  /// Shows the cancel button when set.
  final VoidCallback? onCancel;

  /// The cancel button's accessible name.
  final String cancelLabel;

  /// The rule width — `2px`.
  static const double ruleWidth = 2;

  /// The text ↔ cancel gap — `gap: var(--space-3)`.
  static const double cancelGap = DabblerSpacing.space3;

  /// The attachment glyph — `size={13}`.
  static const double attachmentGlyph = 13;

  /// The cancel's negative inline-end margin — `calc(var(--space-2) * -1)`.
  static const double cancelPull = DabblerSpacing.space2;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool onBrand = variant == DabblerReplyVariant.onBrand;
    final bool composer = variant == DabblerReplyVariant.composer;
    final Color rule = onBrand ? colors.onBrand : colors.brandPrimary;
    final Color body = onBrand ? colors.onBrand : colors.textSecondary;
    final double baseEnd = composer ? DabblerSpacing.space3 : 0;
    final double end = onCancel == null
        ? baseEnd
        : (baseEnd - cancelPull).clamp(0, baseEnd).toDouble();
    final TextStyle bodyStyle = _t(
      context,
      DabblerType.caption1,
    ).copyWith(color: body);

    final Widget box = DecoratedBox(
      decoration: BoxDecoration(
        color: composer ? colors.surfaceSunken : null,
        border: BorderDirectional(
          start: BorderSide(color: rule, width: ruleWidth),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          // A CSS border sits outside the padding; a painted Flutter border
          // does not, so the 2px rule is added to the 9px start padding.
          start: ruleWidth + DabblerSpacing.space3,
          end: end,
          top: DabblerSpacing.space1,
          bottom: DabblerSpacing.space1,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DabblerAutoDirectionText(
                    sender,
                    fill: true,
                    style: _t(
                      context,
                      DabblerType.caption2,
                    ).copyWith(fontWeight: FontWeight.w700, color: rule),
                  ),
                  if (attachmentLabel != null)
                    Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                end: DabblerSpacing.space1,
                              ),
                              child: DabblerIcon(
                                'gallery',
                                size: attachmentGlyph,
                                color: body,
                              ),
                            ),
                          ),
                          TextSpan(text: attachmentLabel),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: bodyStyle,
                    )
                  else
                    DabblerAutoDirectionText(
                      content ?? '',
                      fill: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: bodyStyle,
                    ),
                ],
              ),
            ),
            if (onCancel != null) ...<Widget>[
              const SizedBox(width: cancelGap),
              DabblerMessagingTap(
                onTap: onCancel,
                label: cancelLabel,
                ringRadius: DabblerRadius.pillAll,
                child: SizedBox(
                  width: DabblerSizing.touchTargetMin,
                  height: DabblerSizing.touchTargetMin,
                  child: Center(
                    child: DabblerIcon(
                      'close-circle',
                      size: DabblerSizing.iconSm,
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    // A one-sided border cannot take a radius in Flutter; clipping the box to
    // the radius curves the rule the way the browser does.
    return composer
        ? ClipRRect(borderRadius: DabblerRadius.mdAll, child: box)
        : box;
  }
}

/// One reaction tally on a message.
@immutable
class DabblerMessageReaction {
  /// A tally.
  const DabblerMessageReaction({
    required this.key,
    required this.count,
    this.mine = false,
  });

  /// A [DabblerReactions] key.
  final String key;

  /// How many people reacted.
  final int count;

  /// Whether the viewer reacted.
  final bool mine;
}

/// ReactionGroup — the reaction tallies under a message.
///
/// Source: `components/messaging/ReactionGroup.jsx`.
///
/// | Source | Dart |
/// |---|---|
/// | row `flexWrap`, `gap: --space-1` | `Wrap` spacing and runSpacing 3 |
/// | target `min --touch-target-min` | 45 × 45 minimum |
/// | pill `height: --icon-md`, `paddingInline: --space-2`, pill radius | [pillHeight] 24, 6 |
/// | mine fill `color-mix(brand 12%, --surface-card)` | brand at [mineAlpha] over `surfaceCard` |
/// | border `1px` brand / `--outline-card` | `brandPrimary` / `borderDefault` |
/// | ink brand / `--ink-soft` | `brandPrimary` / `textSecondary` (light `#404040` = `--ink-soft`) |
/// | glyph 13, bold when mine; count `.t-caption-2` 700 | [glyphSize], caption2 w700 |
/// | `aria-label="{label} · {count}"`, `aria-pressed` | semantics label, `selected` |
/// | add: 24 round, `--muted` glyph `emoji-happy` | 24 circle, `textTertiary` glyph |
class DabblerReactionGroup extends StatelessWidget {
  /// A reaction row.
  const DabblerReactionGroup({
    super.key,
    this.reactions = const <DabblerMessageReaction>[],
    this.onToggle,
    this.onAdd,
    this.addLabel = 'Add reaction',
  });

  /// The tallies.
  final List<DabblerMessageReaction> reactions;

  /// Called with the reaction key when a pill is pressed.
  final ValueChanged<String>? onToggle;

  /// Shows the add button when set.
  final VoidCallback? onAdd;

  /// The add button's accessible name.
  final String addLabel;

  /// The pill height — `var(--icon-md)`.
  static const double pillHeight = DabblerSizing.iconMd;

  /// The glyph size — `size={13}`.
  static const double glyphSize = 13;

  /// The `mine` fill — brand at 12% over the card.
  static const double mineAlpha = 0.12;

  /// The accessible name of a tally — `"{label} · {count}"`.
  static String labelFor(DabblerMessageReaction r) =>
      '${DabblerReactions.byKey(r.key).label} · ${r.count}';

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty && onAdd == null) return const SizedBox.shrink();
    final DabblerColors colors = DabblerColors.of(context);
    Widget target(
      Widget pill, {
      required VoidCallback? tap,
      String? label,
      bool? pressed,
    }) => DabblerMessagingTap(
      onTap: tap,
      label: label,
      selected: pressed,
      ringRadius: DabblerRadius.pillAll,
      scale: false,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: DabblerSizing.touchTargetMin,
          minHeight: DabblerSizing.touchTargetMin,
        ),
        child: Center(widthFactor: 1, heightFactor: 1, child: pill),
      ),
    );

    return Wrap(
      spacing: DabblerSpacing.space1,
      runSpacing: DabblerSpacing.space1,
      children: <Widget>[
        for (final DabblerMessageReaction r in reactions)
          target(
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: DabblerRadius.pillAll,
                color: r.mine
                    ? Color.alphaBlend(
                        colors.brandPrimary.withValues(alpha: mineAlpha),
                        colors.surfaceCard,
                      )
                    : colors.surfaceCard,
                border: Border.all(
                  color: r.mine ? colors.brandPrimary : colors.borderDefault,
                  width: DabblerSizing.borderDefault,
                ),
              ),
              child: SizedBox(
                height: pillHeight,
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: DabblerSpacing.space2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DabblerIcon(
                        DabblerReactions.byKey(r.key).icon,
                        weight: r.mine
                            ? DabblerIconWeight.bold
                            : DabblerIconWeight.linear,
                        size: glyphSize,
                        color: r.mine
                            ? colors.brandPrimary
                            : colors.textSecondary,
                      ),
                      const SizedBox(width: DabblerSpacing.space1),
                      Text(
                        '${r.count}',
                        style: _t(context, DabblerType.caption2).copyWith(
                          fontWeight: FontWeight.w700,
                          color: r.mine
                              ? colors.brandPrimary
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            tap: onToggle == null ? null : () => onToggle!(r.key),
            label: labelFor(r),
            pressed: r.mine,
          ),
        if (onAdd != null)
          target(
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceCard,
                border: Border.all(
                  color: colors.borderDefault,
                  width: DabblerSizing.borderDefault,
                ),
              ),
              child: SizedBox(
                width: pillHeight,
                height: pillHeight,
                child: Center(
                  child: DabblerIcon(
                    'emoji-happy',
                    size: glyphSize,
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ),
            tap: onAdd,
            label: addLabel,
          ),
      ],
    );
  }
}

/// ReactionPicker — the six reactions in one pill, to choose from.
///
/// Source: `components/messaging/ReactionPicker.jsx`.
///
/// | Source | Dart |
/// |---|---|
/// | `role="group"`, `aria-label={groupLabel}` | container semantics, [groupLabel] |
/// | `padding: --space-2`, `gap: --space-1` | 6 / 3 |
/// | `--surface-card`, `1px --outline-card`, pill radius | `surfaceCard`, `borderDefault` |
/// | six 45px round buttons, `dbl-press` | 45 × 45, press scale |
/// | active fill brand, on-brand bold glyph | `brandPrimary`, `onBrand` |
/// | idle `--ink-soft` linear glyph, 19px | `textSecondary`, [glyphSize] |
/// | `aria-pressed`, `aria-label={r.label}` | `selected`, label |
class DabblerReactionPicker extends StatelessWidget {
  /// A picker.
  const DabblerReactionPicker({
    super.key,
    this.onPick,
    this.active = const <String>[],
    this.groupLabel = 'React',
  });

  /// Called with the chosen reaction key.
  final ValueChanged<String>? onPick;

  /// The keys already chosen.
  final List<String> active;

  /// The group's accessible name.
  final String groupLabel;

  /// The glyph size — `size={19}`.
  static const double glyphSize = 19;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: groupLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: DabblerRadius.pillAll,
          border: Border.all(
            color: colors.borderDefault,
            width: DabblerSizing.borderDefault,
          ),
        ),
        child: Padding(
          // CSS content-box: the 1px border sits outside the 6px padding.
          padding: const EdgeInsets.all(
            DabblerSpacing.space2 + DabblerSizing.borderDefault,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final DabblerReactionDef r
                  in DabblerReactions.all) ...<Widget>[
                if (r != DabblerReactions.all.first)
                  const SizedBox(width: DabblerSpacing.space1),
                _PickerButton(
                  def: r,
                  on: active.contains(r.key),
                  onTap: onPick == null ? null : () => onPick!(r.key),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({required this.def, required this.on, this.onTap});

  final DabblerReactionDef def;
  final bool on;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DabblerMessagingTap(
      onTap: onTap,
      label: def.label,
      selected: on,
      ringRadius: DabblerRadius.pillAll,
      child: Container(
        width: DabblerSizing.touchTargetMin,
        height: DabblerSizing.touchTargetMin,
        alignment: Alignment.center,
        decoration: on
            ? BoxDecoration(shape: BoxShape.circle, color: colors.brandPrimary)
            : null,
        child: DabblerIcon(
          def.icon,
          weight: on ? DabblerIconWeight.bold : DabblerIconWeight.linear,
          size: DabblerReactionPicker.glyphSize,
          color: on ? colors.onBrand : colors.textSecondary,
        ),
      ),
    );
  }
}

/// The tone of a [DabblerConversationNotice] — `critical` is an alias of `error`.
enum DabblerNoticeTone {
  /// Info.
  info,

  /// Success.
  success,

  /// Warning.
  warning,

  /// Error.
  error,

  /// Alias of [error].
  critical,
}

/// ConversationNotice — an important update inside a thread, a `Banner`.
///
/// Source: `components/messaging/ConversationNotice.jsx`.
///
/// | Source | Dart |
/// |---|---|
/// | `paddingInline: --space-2` | 6 each side |
/// | column `gap: SPACING.metaGap` | [DabblerMessagingSpacing.metaGap] 3 |
/// | `Banner tone={critical ? 'error' : tone}` | [bannerToneFor] |
/// | `action={{label, onPress}}` only when `actionLabel` | [DabblerBannerAction] |
/// | timestamp `.t-caption-1`, `--muted`, `alignSelf: center` | caption1, `textSecondary` (D-003(a)), centred |
class DabblerConversationNotice extends StatelessWidget {
  /// A notice.
  const DabblerConversationNotice({
    super.key,
    this.tone = DabblerNoticeTone.info,
    this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.timestamp,
  });

  /// The tone.
  final DabblerNoticeTone tone;

  /// The headline.
  final String? title;

  /// The body.
  final String? description;

  /// The action button label.
  final String? actionLabel;

  /// Called by the action.
  final VoidCallback? onAction;

  /// Shows the dismiss button when set.
  final VoidCallback? onDismiss;

  /// A caption under the banner.
  final String? timestamp;

  /// The banner tone for [tone].
  static DabblerBannerTone bannerToneFor(DabblerNoticeTone tone) =>
      switch (tone) {
        DabblerNoticeTone.info => DabblerBannerTone.info,
        DabblerNoticeTone.success => DabblerBannerTone.success,
        DabblerNoticeTone.warning => DabblerBannerTone.warning,
        DabblerNoticeTone.error ||
        DabblerNoticeTone.critical => DabblerBannerTone.error,
      };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerSpacing.space2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DabblerBanner(
            tone: bannerToneFor(tone),
            title: title,
            message: description,
            action: actionLabel == null
                ? null
                : DabblerBannerAction(label: actionLabel!, onPressed: onAction),
            onDismiss: onDismiss,
          ),
          if (timestamp != null) ...<Widget>[
            const SizedBox(height: DabblerMessagingSpacing.metaGap),
            Center(
              child: Text(
                timestamp!,
                style: _t(
                  context,
                  DabblerType.caption1,
                ).copyWith(color: colors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
