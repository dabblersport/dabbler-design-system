import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';
import '../tokens/dabbler_type.dart';

/// One option of a [DabblerCardPoll]: a result bar and its percentage text.
@immutable
class DabblerPollOption {
  /// An option whose bar is filled to [fraction] (0 to 1).
  const DabblerPollOption({
    required this.fraction,
    required this.percentLabel,
    this.color,
    this.semanticLabel,
  });

  /// How much of the track the fill covers, `0..1`.
  final double fraction;

  /// The percentage text beside the bar, e.g. `65%`.
  final String percentLabel;

  /// The fill and text colour. Null takes the option's positional default:
  /// the first is [DabblerColors.brandPrimary], later ones
  /// [DabblerPalette.activeP600].
  final Color? color;

  /// The accessible name; defaults to [percentLabel].
  final String? semanticLabel;
}

/// CardPoll — a poll result: a tinted question header, one bar per option and a
/// footer with the vote count and an `end poll` link.
///
/// Ported from the live design project's `components/cards/CardPoll.jsx` (Figma
/// node `8:35`, design system 1.2.0). The source is a fixed 417.5x153.5 export;
/// this widget takes its width from the column. All text is injected.
///
/// ## Where the port differs, each on purpose
///
/// | Source | Here | Why |
/// |---|---|---|
/// | `417.5 x 153.5` frame | flexible width, content height | a Figma frame measurement is not a specification |
/// | question `15 / 22.5 / 700` | `subheadline` 15/20 at weight 700 | the ramp has no 15/700; leading snaps one step to the ramp's 20, as `CardHouse` and `CardPricing` already record |
/// | percent `12 / 18 / 700` | `caption-1` 12/16 at weight 700 | weight override on a named step |
/// | footer `11 / 16.5` | `caption-2` 11/13 | leading snaps to the ramp |
/// | header fill `rgba(155,93,229,0.133)` | [DabblerColors.brandPrimary] at 13.3% | the source colour is a raw literal; the tint now follows the active theme |
/// | `--purple-600` / `--pink-600` fills | brand primary and `DabblerPalette.activeP600` | both are `fig-tokens` aliases the reference's `colors.css` does not declare; a design-source gap, not a package one |
///
/// The `end poll` link is [onEndPoll]; with none it is plain underlined text.
class DabblerCardPoll extends StatelessWidget {
  /// A poll card.
  const DabblerCardPoll({
    super.key,
    required this.question,
    required this.options,
    required this.votesLabel,
    this.endPollLabel = 'end poll',
    this.onEndPoll,
  });

  /// The question, in the tinted header.
  final String question;

  /// The result bars, top to bottom.
  final List<DabblerPollOption> options;

  /// The vote count text, e.g. `42 votes`.
  final String votesLabel;

  /// The end-poll link text.
  final String endPollLabel;

  /// Called when the end-poll link is pressed; null leaves it inert.
  final VoidCallback? onEndPoll;

  /// The header tint opacity — `rgba(…, 0.133)`.
  static const double headerTintAlpha = 0.133;

  /// The bar height — `height: 8`.
  static const double barHeight = 8;

  /// The gap between a bar and its percentage — `gap: 12`.
  static const double barGap = DabblerSpacing.space4;

  /// The default colour of option [index].
  static Color optionColorFor(DabblerColors colors, int index) =>
      index == 0 ? colors.brandPrimary : DabblerPalette.activeP600;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final TextStyle caption2 = DabblerType.caption2.resolveForDirection(
      direction,
    );

    final Widget header = ColoredBox(
      color: colors.brandPrimary.withValues(alpha: headerTintAlpha),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DabblerSpacing.space4,
          horizontal: DabblerSpacing.space4 + 4,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            question,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DabblerType.subheadline
                .resolveForDirection(direction)
                .copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
          ),
        ),
      ),
    );

    final Widget bars = ColoredBox(
      color: colors.surfaceCard,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DabblerSpacing.space4 + 4,
          DabblerSpacing.space4,
          DabblerSpacing.space4 + 4,
          DabblerSpacing.space4,
        ),
        child: Column(
          children: <Widget>[
            for (int i = 0; i < options.length; i++)
              Semantics(
                label: options[i].semanticLabel ?? options[i].percentLabel,
                excludeSemantics: true,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: i == 0 ? 0 : DabblerSpacing.space2,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _Bar(
                          fraction: options[i].fraction,
                          fill: options[i].color ?? optionColorFor(colors, i),
                          track: colors.surfaceSunken,
                        ),
                      ),
                      const SizedBox(width: barGap),
                      Text(
                        options[i].percentLabel,
                        maxLines: 1,
                        style: DabblerType.caption1
                            .resolveForDirection(direction)
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              color:
                                  options[i].color ?? optionColorFor(colors, i),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    final Widget endPoll = Text(
      endPollLabel,
      style: caption2.copyWith(
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        decoration: TextDecoration.underline,
      ),
    );

    final Widget footer = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border.all(
          color: colors.surfaceSunken,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DabblerSpacing.space4 + 4,
          0,
          DabblerSpacing.space4 + 4,
          DabblerSpacing.space4,
        ),
        child: Row(
          children: <Widget>[
            Text(
              votesLabel,
              style: caption2.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(width: 8),
            Text(
              '·',
              style: DabblerType.body
                  .resolveForDirection(direction)
                  .copyWith(color: colors.textSecondary),
            ),
            const SizedBox(width: 8),
            if (onEndPoll == null)
              endPoll
            else
              Semantics(
                button: true,
                label: endPollLabel,
                onTap: onEndPoll,
                child: ExcludeSemantics(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onEndPoll,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: endPoll,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: DabblerRadius.cardAll,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: ClipRRect(
        borderRadius: DabblerRadius.cardAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[header, bars, footer],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.fill, required this.track});

  final double fraction;
  final Color fill;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DabblerCardPoll.barHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: track,
          borderRadius: DabblerRadius.pillAll,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: fraction.clamp(0.0, 1.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fill,
                borderRadius: DabblerRadius.pillAll,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
