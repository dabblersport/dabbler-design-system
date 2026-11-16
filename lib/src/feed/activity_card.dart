import 'package:flutter/material.dart';

import '../foundations/icon.dart';
import 'feed_pill.dart';
import '../tokens/dabbler_activity_tones.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_home_frame.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';

/// ActivityCard — one card of the Home Feed's Active tab, transcribed from
/// `project/ActivityCard.dc.html` (KAN-965).
///
/// ```text
/// ┌───────────────────────────────────────── [mark, 120, 14%]
/// │ (kicker pill) time
/// │ body (player / event / venue)      ← the app composes these
/// │ stat block (optional)
/// │ host · chips ……………………… (action)
/// └──────────────────────────────────────────
/// ```
///
/// | element | source | here |
/// |---|---|---|
/// | card | `padding:18px`, `gap:12px`, `--radius-xl`, `background:toneBg`, no border, `overflow:hidden` | [padding], [gap], [radius] |
/// | mark | `position:absolute; inset-inline-end:-18px; top:-12px`, Icon 120 bold, `color:toneInk; opacity:0.14` | [markSize], [markInsetEnd], [markInsetTop], [markOpacity] |
///
/// The mark is painted behind the content (`position:relative` rows over an
/// absolute span) and takes no hit or semantics (`aria-hidden`,
/// `pointer-events:none`).
///
/// ## Brightness
///
/// The card follows the theme (KAN-972): pass the [DabblerActivityTone]'s pair
/// for the ambient brightness, and the parts read the ambient
/// [DabblerColors] (`--surface-card`, `--ink`, `--ink-soft` resolve dark in
/// dark mode).
class DabblerActivityCard extends StatelessWidget {
  /// A card in [tone] with the [mark] glyph behind [children].
  const DabblerActivityCard({
    super.key,
    required this.tone,
    required this.mark,
    required this.children,
  });

  /// The card's ground ([DabblerToneColor.surface]) and its mark's ink.
  final DabblerToneColor tone;

  /// The Iconsax name of the large background glyph (`a.mark`).
  final String mark;

  /// The rows, [gap] apart.
  final List<Widget> children;

  /// `padding:18px`.
  static const double padding = DabblerSpacing.space6;

  /// `gap:12px` between the rows.
  static const double gap = DabblerSpacing.space4;

  /// `--radius-xl`.
  static const double radius = DabblerRadius.xl;

  /// The mark's glyph size: `size="120"`.
  static const double markSize = 120;

  /// `inset-inline-end:-18px`.
  static const double markInsetEnd = -DabblerSpacing.space6;

  /// `top:-12px`.
  static const double markInsetTop = -DabblerSpacing.space4;

  /// `opacity:0.14`.
  static const double markOpacity = 0.14;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[
      for (int i = 0; i < children.length; i++) ...<Widget>[
        if (i > 0) const SizedBox(height: gap),
        children[i],
      ],
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: tone.surface,
        child: Stack(
          children: <Widget>[
            PositionedDirectional(
              end: markInsetEnd,
              top: markInsetTop,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: DabblerIcon(
                    mark,
                    key: const ValueKey<String>('activity-card-mark'),
                    size: markSize,
                    weight: DabblerIconWeight.bold,
                    color: tone.ink.withValues(alpha: markOpacity),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: rows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle _style(BuildContext context, DabblerTypeStyle s, Color color) =>
    s.resolveForDirection(Directionality.of(context)).copyWith(color: color);

/// The kicker pill: `background:var(--surface-card)`, `--radius-pill`,
/// `padding:4px 10px 4px 8px`, 11/13. Live: the [DabblerLiveDot], `gap:6px`,
/// the label in `--color-status-success-strong`. Otherwise the family glyph
/// (12, bold) in the tone ink, `gap:5px`, the label in the tone ink.
class DabblerActivityKicker extends StatelessWidget {
  /// A kicker.
  const DabblerActivityKicker({
    super.key,
    required this.label,
    required this.ink,
    this.icon,
    this.live = false,
    this.compact = false,
  });

  final String label;

  /// The tone ink (ignored while [live]).
  final Color ink;

  /// The family glyph; not drawn while [live].
  final String? icon;
  final bool live;

  /// The trending pair box's tighter pill, `padding:4px 9px 4px 7px`
  /// ([compactPadding], KAN-967).
  final bool compact;

  /// `padding:4px 10px 4px 8px`.
  static const EdgeInsetsDirectional padding = EdgeInsetsDirectional.fromSTEB(
    8,
    4,
    10,
    4,
  );

  /// `padding:4px 9px 4px 7px` (the pair box).
  static const EdgeInsetsDirectional compactPadding =
      EdgeInsetsDirectional.fromSTEB(7, 4, 9, 4);

  /// `gap:6px` beside the live dot.
  static const double liveGap = DabblerSpacing.space2;

  /// `gap:5px` beside the glyph.
  static const double iconGap = 5;

  /// The glyph: `size="12"`.
  static const double iconSize = DabblerSpacing.space4;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Color text = live ? colors.success.strong : ink;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: DabblerRadius.pillAll,
      ),
      child: Padding(
        padding: compact ? compactPadding : padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (live) ...<Widget>[
              const DabblerLiveDot(),
              const SizedBox(width: liveGap),
            ] else if (icon != null) ...<Widget>[
              DabblerIcon(
                icon!,
                size: iconSize,
                weight: DabblerIconWeight.bold,
                color: ink,
              ),
              const SizedBox(width: iconGap),
            ],
            Flexible(
              child: Text(
                DabblerType.toWesternDigits(label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _style(context, DabblerType.caption2, text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The 7px live dot in `--color-status-success`, with the source's
/// `act-pulse`: a ring that grows from 0 to 7px while fading from 55% to
/// nothing, `1.6s ease-out infinite`. Under reduced motion the dot is still
/// (`animation:none`).
class DabblerLiveDot extends StatefulWidget {
  /// The dot.
  const DabblerLiveDot({super.key});

  /// `width:7px;height:7px`.
  static const double size = 7;

  /// The ring's final spread: `box-shadow: 0 0 0 7px`.
  static const double pulseSpread = 7;

  /// The ring's opening strength: `color-mix(... 55%, transparent)`.
  static const double pulseAlpha = 0.55;

  /// `1.6s`.
  static const Duration pulse = Duration(milliseconds: 1600);

  /// `ease-out`.
  static const Curve pulseCurve = Curves.easeOut;

  @override
  State<DabblerLiveDot> createState() => _DabblerLiveDotState();
}

class _DabblerLiveDotState extends State<DabblerLiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: DabblerLiveDot.pulse,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (DabblerMotion.reduceMotion(context)) {
      _c.stop();
      _c.value = 0;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color base = DabblerColors.of(context).success.base;
    final bool still = DabblerMotion.reduceMotion(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, Widget? _) {
        final double t = DabblerLiveDot.pulseCurve.transform(_c.value);
        return DecoratedBox(
          key: const ValueKey<String>('activity-live-dot'),
          decoration: BoxDecoration(
            color: base,
            shape: BoxShape.circle,
            boxShadow: still
                ? null
                : <BoxShadow>[
                    BoxShadow(
                      color: base.withValues(
                        alpha: DabblerLiveDot.pulseAlpha * (1 - t),
                      ),
                      spreadRadius: DabblerLiveDot.pulseSpread * t,
                    ),
                  ],
          ),
          child: const SizedBox.square(dimension: DabblerLiveDot.size),
        );
      },
    );
  }
}

/// The event date tile: 56 x 62, `--radius-lg`, `--surface-card`; the month
/// at 11/13 in the tone ink over the day at 28/32 display in `--ink`.
class DabblerActivityDateTile extends StatelessWidget {
  /// A tile.
  const DabblerActivityDateTile({
    super.key,
    required this.month,
    required this.day,
    required this.ink,
  });

  final String month;
  final String day;
  final Color ink;

  /// `width:56px`.
  static const double width = 56;

  /// `height:62px`.
  static const double height = 62;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(DabblerRadius.lg),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              DabblerType.toWesternDigits(month),
              maxLines: 1,
              style: _style(context, DabblerType.caption2, ink),
            ),
            Text(
              DabblerType.toWesternDigits(day),
              maxLines: 1,
              style: _style(
                context,
                DabblerType.displayDay,
                colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The stat block: `padding:9px 12px`, `--radius-lg`, `--surface-card`,
/// `gap:6px`; a 16 bold glyph in the tone ink and the line at 13/18 `--ink`,
/// `gap:6px`; and, given [fraction], the capacity bar.
class DabblerActivityStat extends StatelessWidget {
  /// A stat block.
  const DabblerActivityStat({
    super.key,
    required this.icon,
    required this.text,
    required this.tone,
    this.fraction,
  });

  final String icon;
  final String text;
  final DabblerToneColor tone;

  /// The bar's fill, 0–1; null draws no bar.
  final double? fraction;

  /// `padding:9px 12px`.
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: DabblerSpacing.space4,
    vertical: DabblerSpacing.space3,
  );

  /// `gap:6px`.
  static const double gap = DabblerSpacing.space2;

  /// The glyph: `size="16"`.
  static const double iconSize = 16;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double? bar = fraction;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(DabblerRadius.lg),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                DabblerIcon(
                  icon,
                  size: iconSize,
                  weight: DabblerIconWeight.bold,
                  color: tone.ink,
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: Text(
                    DabblerType.toWesternDigits(text),
                    style: _style(
                      context,
                      DabblerType.footnote,
                      colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (bar != null) ...<Widget>[
              const SizedBox(height: gap),
              DabblerActivityBar(fraction: bar, tone: tone),
            ],
          ],
        ),
      ),
    );
  }
}

/// The capacity bar in the card's tone: 6 tall, `--radius-pill`, the track in
/// the tone's surface, the fill in its ink at `Math.round(a / b * 100)%`.
class DabblerActivityBar extends StatelessWidget {
  /// A bar.
  const DabblerActivityBar({
    super.key,
    required this.fraction,
    required this.tone,
  });

  final double fraction;
  final DabblerToneColor tone;

  /// `height:6px`.
  static const double height = DabblerSpacing.space2;

  /// The drawn fill: the source rounds to a whole percent.
  static double drawnFraction(double fraction) =>
      (fraction.clamp(0, 1) * 100).round() / 100;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: const ValueKey<String>('activity-bar'),
      borderRadius: DabblerRadius.pillAll,
      child: ColoredBox(
        color: tone.surface,
        child: SizedBox(
          height: height,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: drawnFraction(fraction),
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tone.ink,
                  borderRadius: DabblerRadius.pillAll,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A sport chip: `padding:4px 10px`, `--radius-pill`, the card surface at
/// 70% over the tone, 11/13 `--ink-soft`.
///
/// ## Emoji
///
/// [emoji] is drawn before the label with [DabblerFeedPill]'s emoji metrics:
/// `subheadline` (15/20), [DabblerHomeFrame.sportPillGap] (5) to the label.
/// The package prescribes no smaller emoji for an 11/13 label, so the pill's
/// own metrics are used and the chip grows to the emoji line: 28 tall, 31 in
/// Arabic (subheadline's Arabic leading is 23, as on the pill).
/// Added by the CEO's order of 2026-11-16 (KAN-965: the card's sport chips
/// show the same emoji as the home post's sport tag). The emoji is data;
/// none is named here. Decorative: the label carries the accessible name.
class DabblerActivityChip extends StatelessWidget {
  /// A chip.
  const DabblerActivityChip({super.key, required this.label, this.emoji});

  final String label;

  /// An emoji before the label, drawn at 15/20; null draws the label alone.
  final String? emoji;

  /// `padding:4px 10px`.
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );

  /// `color-mix(in srgb, var(--surface-card) 70%, transparent)`.
  static const double fillAlpha = 0.7;

  /// The emoji's style: [DabblerFeedPill]'s, `subheadline` (15/20).
  static const DabblerTypeStyle emojiStyle = DabblerType.subheadline;

  /// The emoji-to-label gap: [DabblerFeedPill]'s drawn
  /// [DabblerHomeFrame.sportPillGap] (5).
  static const double emojiGap = DabblerHomeFrame.sportPillGap;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Widget text = Text(
      DabblerType.toWesternDigits(label),
      maxLines: 1,
      style: _style(context, DabblerType.caption2, colors.textSecondary),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard.withValues(alpha: fillAlpha),
        borderRadius: DabblerRadius.pillAll,
      ),
      child: Padding(
        padding: padding,
        child: emoji == null
            ? text
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ExcludeSemantics(
                    child: Text(
                      emoji!,
                      key: const ValueKey<String>('activity-chip-emoji'),
                      style: emojiStyle.resolveForDirection(
                        Directionality.of(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: emojiGap),
                  Flexible(child: text),
                ],
              ),
      ),
    );
  }
}

/// The action pill: `min-height:40px`, `padding:0 18px`, `--radius-pill`,
/// the tone ink filled, 14/18 in `--surface-card`, one line.
class DabblerActivityAction extends StatelessWidget {
  /// An action.
  const DabblerActivityAction({
    super.key,
    required this.label,
    required this.ink,
  });

  final String label;

  /// The fill (`ctaBg`, the tone ink).
  final Color ink;

  /// `min-height:40px`.
  static const double minHeight = 40;

  /// `padding:0 18px`.
  static const double paddingInline = DabblerSpacing.space6;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DecoratedBox(
      key: const ValueKey<String>('activity-action'),
      decoration: BoxDecoration(
        color: ink,
        borderRadius: DabblerRadius.pillAll,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: paddingInline),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(
              DabblerType.toWesternDigits(label),
              maxLines: 1,
              softWrap: false,
              style: _style(
                context,
                DabblerType.smallCompact,
                colors.surfaceCard,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
