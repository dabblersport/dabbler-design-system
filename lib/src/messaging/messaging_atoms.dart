import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';
import '../foundations/sport_icon.dart';
import '../foundations/sports.dart';
import 'messaging_foundations.dart';

TextStyle _t(BuildContext c, DabblerTypeStyle s) =>
    s.resolveForDirection(Directionality.of(c));

/// DateSeparator — the day boundary pill in a thread.
///
/// `DateSeparator.jsx`: a centred sunken pill, `caption-1` at weight 600 in the
/// muted ink, 12 inline and 3 block padding, on a 6px block band.
class DabblerDateSeparator extends StatelessWidget {
  /// A day pill reading [label].
  const DabblerDateSeparator({super.key, required this.label});

  /// The day text, e.g. `Today`.
  final String label;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DabblerSpacing.space2),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceSunken,
            borderRadius: DabblerRadius.pillAll,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DabblerSpacing.space3,
              vertical: DabblerSpacing.space1,
            ),
            child: Text(
              label,
              style: _t(context, DabblerType.caption1).copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// UnreadDivider — the "new messages" rule, in the brand colour.
///
/// `UnreadDivider.jsx`: a labelled divider whose rule colour is the brand
/// colour and whose label is `caption-2` at weight 700.
class DabblerUnreadDivider extends StatelessWidget {
  /// A divider labelled [label].
  const DabblerUnreadDivider({super.key, required this.label});

  /// The label, e.g. `New messages`.
  final String label;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(DabblerSpacing.space2),
      child: Semantics(
        label: label,
        container: true,
        child: ExcludeSemantics(
          child: Row(
            children: <Widget>[
              Expanded(child: _Rule(color: colors.brandPrimary)),
              const SizedBox(width: DabblerSpacing.space4),
              Text(
                label,
                style: _t(context, DabblerType.caption2).copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.brandPrimary,
                ),
              ),
              const SizedBox(width: DabblerSpacing.space4),
              Expanded(child: _Rule(color: colors.brandPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: DabblerSizing.borderDefault,
        child: ColoredBox(color: color),
      );
}

/// SystemMessage — centred activity text ("Mina joined"), never a bubble.
///
/// `SystemMessage.jsx`: an optional 14px glyph, `caption-1` text, an optional
/// ` · timestamp`; neutral is muted, `positive` is the success strong ink.
class DabblerSystemMessage extends StatelessWidget {
  /// A system line.
  const DabblerSystemMessage({
    super.key,
    required this.text,
    this.icon,
    this.timestamp,
    this.positive = false,
  });

  /// The text.
  final String text;

  /// An optional Iconsax glyph.
  final String? icon;

  /// An optional timestamp appended as ` · …`.
  final String? timestamp;

  /// The success tone.
  final bool positive;

  /// The glyph size — `size={14}`.
  static const double glyphSize = 14;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Color ink = positive ? colors.success.strong : colors.textSecondary;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DabblerMessagingSpacing.systemBlock,
          horizontal: DabblerSpacing.space6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              ExcludeSemantics(
                child: DabblerIcon(
                  icon!,
                  size: glyphSize,
                  color: positive ? colors.success.strong : colors.textTertiary,
                ),
              ),
              const SizedBox(width: DabblerSpacing.space2),
            ],
            Flexible(
              child: Text(
                timestamp == null ? text : '$text · $timestamp',
                textAlign: TextAlign.center,
                style: _t(context, DabblerType.caption1).copyWith(color: ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// TypingIndicator — three pulsing dots, with or without the sentence.
///
/// `TypingIndicator.jsx`: 4px dots 3 apart, opacity `.25 → 1` over 1200ms with
/// 180ms stagger; the sentence is built from [names] when [label] is null.
/// Reduced motion draws the dots still at full opacity.
class DabblerTypingIndicator extends StatefulWidget {
  /// A typing indicator.
  const DabblerTypingIndicator({
    super.key,
    this.names = const <String>[],
    this.label,
    this.dotsOnly = false,
  });

  /// Who is typing.
  final List<String> names;

  /// Overrides the generated sentence.
  final String? label;

  /// Draw only the dots.
  final bool dotsOnly;

  /// The dot diameter — `width: 4`.
  static const double dotSize = 4;

  /// The cycle — `1200ms`.
  static const Duration period = Duration(milliseconds: 1200);

  /// The per-dot stagger — `i * 180ms`.
  static const Duration stagger = Duration(milliseconds: 180);

  /// The sentence for [names], as the source composes it.
  static String textFor(List<String> names, {String? label}) {
    if (label != null) return label;
    if (names.length == 1) return '${names[0]} is typing';
    if (names.length == 2) return '${names[0]} and ${names[1]} are typing';
    if (names.length > 2) {
      return '${names[0]} and ${names.length - 1} others are typing';
    }
    return 'typing';
  }

  /// The opacity of dot [index] at cycle position [t] in `0..1`.
  static double opacityAt(double t, int index) {
    final double shifted =
        (t - index * stagger.inMilliseconds / period.inMilliseconds) % 1.0;
    final double p = shifted < 0 ? shifted + 1 : shifted;
    // keyframes 0%,70%,100% → .25 ; 35% → 1, linear between.
    if (p <= 0.35) return 0.25 + 0.75 * (p / 0.35);
    if (p <= 0.70) return 1 - 0.75 * ((p - 0.35) / 0.35);
    return 0.25;
  }

  @override
  State<DabblerTypingIndicator> createState() =>
      _DabblerTypingIndicatorState();
}

class _DabblerTypingIndicatorState extends State<DabblerTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: DabblerTypingIndicator.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (DabblerMotion.reduceMotion(context)) {
      _c.stop();
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
    final DabblerColors colors = DabblerColors.of(context);
    final bool still = DabblerMotion.reduceMotion(context);
    final Widget dots = ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (BuildContext context, Widget? _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < 3; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: DabblerSpacing.space1),
              Opacity(
                opacity: still
                    ? 1
                    : DabblerTypingIndicator.opacityAt(_c.value, i),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.textSecondary,
                  ),
                  child: const SizedBox(
                    width: DabblerTypingIndicator.dotSize,
                    height: DabblerTypingIndicator.dotSize,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    if (widget.dotsOnly) return dots;
    final String text = DabblerTypingIndicator.textFor(
      widget.names,
      label: widget.label,
    );
    return Semantics(
      liveRegion: true,
      label: text,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            dots,
            const SizedBox(width: DabblerSpacing.space2),
            Flexible(
              child: Text(
                text,
                style: _t(context, DabblerType.caption1)
                    .copyWith(color: colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ConversationAvatar — an identity avatar with a kind tile and a presence dot.
///
/// `ConversationAvatar.jsx`: the avatar (xs/sm/md from the pixel size), a kind
/// tile at the inline-end bottom corner (a paper tile with a hairline carrying
/// the kind glyph; `game` uses the sport glyph), and for `player` an online dot
/// in the success colour with a 2px page-coloured ring. Interim until
/// `Avatar` gains a status dot (DSG-NEW-008).
class DabblerConversationAvatar extends StatelessWidget {
  /// A conversation avatar.
  const DabblerConversationAvatar({
    super.key,
    this.kind = DabblerConversationKind.player,
    this.sport,
    this.seed,
    this.size = 48,
    this.online = false,
  });

  /// What the conversation is.
  final DabblerConversationKind kind;

  /// The sport for a `game`.
  final DabblerSport? sport;

  /// The avatar seed.
  final String? seed;

  /// The overall pixel size.
  final double size;

  /// Whether the player is online.
  final bool online;

  /// The [DabblerAvatarSize] for [size] — `md` from 48, `sm` from 36, else `xs`.
  static DabblerAvatarSize avatarSizeFor(double size) => size >= 48
      ? DabblerAvatarSize.md
      : size >= 36
          ? DabblerAvatarSize.sm
          : DabblerAvatarSize.xs;

  /// The kind tile's side — `round(size * 0.4)`.
  static double tileFor(double size) => (size * 0.4).roundToDouble();

  /// The glyph inside the tile — `round(tile * 0.62)`.
  static double glyphFor(double size) => (tileFor(size) * 0.62).roundToDouble();

  /// The presence dot's diameter — `round(size * 0.24)`.
  static double dotFor(double size) => (size * 0.24).roundToDouble();

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double tile = tileFor(size);
    final double glyph = glyphFor(size);
    final double dot = dotFor(size);
    final String? name = kind.glyph;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: DabblerAvatar(seed: seed, size: avatarSizeFor(size)),
          ),
          if (name != null || kind == DabblerConversationKind.game)
            PositionedDirectional(
              end: -2,
              bottom: -2,
              child: ExcludeSemantics(
                child: Container(
                  width: tile,
                  height: tile,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    borderRadius: DabblerRadius.smAll,
                    border: Border.all(
                      color: colors.borderDefault,
                      width: DabblerSizing.borderDefault,
                    ),
                  ),
                  child: kind == DabblerConversationKind.game
                      ? DabblerSportIcon(
                          sport ?? DabblerSport.football,
                          weight: DabblerIconWeight.bold,
                          size: glyph,
                          color: colors.textPrimary,
                        )
                      : DabblerIcon(
                          name!,
                          weight: DabblerIconWeight.bold,
                          size: glyph,
                          color: colors.textPrimary,
                        ),
                ),
              ),
            ),
          if (kind == DabblerConversationKind.player && online)
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: ExcludeSemantics(
                child: Container(
                  width: dot + 4,
                  height: dot + 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.success.base,
                    border: Border.all(color: colors.bgPrimary, width: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
