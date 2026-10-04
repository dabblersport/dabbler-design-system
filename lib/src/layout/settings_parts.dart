/// The two parts the Settings pages are built from: [DabblerSettingsHeader],
/// the tinted hero at the top of the root page, and [DabblerRowGroup], a titled
/// card of flat [DabblerInputRow]s separated by hairlines.
///
/// Source: Claude Design file `Settings.dc.html` — the hero at `:77-95`, the
/// group at `:131-240`.
library;

import 'package:flutter/widgets.dart';

import '../forms/input_row.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'divider.dart';

/// The Settings root's hero: a brand-tinted band holding the top bar, a version
/// pill, the page title, a line of description and an optional identity row.
class DabblerSettingsHeader extends StatelessWidget {
  /// A hero reading [title].
  const DabblerSettingsHeader({
    super.key,
    required this.title,
    this.topBar,
    this.versionLabel,
    this.subtitle,
    this.identity,
  });

  /// The page title, in the display face.
  final String title;

  /// The bar drawn on the tint above the pill — a titled top bar.
  final Widget? topBar;

  /// The version pill's text; omitted when null.
  final String? versionLabel;

  /// The line under the title.
  final String? subtitle;

  /// The identity row at the foot of the hero — a [DabblerInputRow] with
  /// `flat: true` and `showDivider: false`.
  final Widget? identity;

  /// The brand share of the tint — `color-mix(brand 14%, #FFF)`.
  static const double tintAlpha = 0.14;

  /// The tint over the card surface.
  static Color tintFor(DabblerColors colors) => Color.alphaBlend(
    colors.brandPrimary.withValues(alpha: tintAlpha),
    colors.surfaceCard,
  );

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    return ColoredBox(
      color: tintFor(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ?topBar,
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              DabblerSpacing.space6,
              DabblerSpacing.space1,
              DabblerSpacing.space6,
              DabblerSpacing.space7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (versionLabel != null)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.textPrimary.withValues(alpha: 0.1),
                      borderRadius: DabblerRadius.pillAll,
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: DabblerSpacing.space4,
                        vertical: DabblerSpacing.space1,
                      ),
                      child: Text(
                        DabblerType.toWesternDigits(versionLabel!),
                        style: DabblerType.caption1
                            .resolveForDirection(dir)
                            .copyWith(
                              color: colors.textPrimary,
                              fontWeight: DabblerType.bold,
                            ),
                      ),
                    ),
                  ),
                const SizedBox(height: DabblerSpacing.space2),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: DabblerType.largeTitle
                        .resolveForDirection(dir)
                        .copyWith(color: colors.textPrimary),
                  ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: DabblerSpacing.space2),
                  Text(
                    subtitle!,
                    style: DabblerType.footnote
                        .resolveForDirection(dir)
                        .copyWith(color: colors.textSecondary),
                  ),
                ],
                if (identity != null) ...<Widget>[
                  const SizedBox(height: DabblerSpacing.space5),
                  DabblerSurface(
                    fill: colors.surfaceCard.withValues(alpha: 0.62),
                    borderWidth: 0,
                    radius: DabblerRadius.lg,
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: DabblerSpacing.space4,
                    ),
                    child: identity,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled card of rows: an optional [header] and [note] over a card whose
/// [children] — flat [DabblerInputRow]s with `showDivider: false` — are
/// separated by hairlines.
class DabblerRowGroup extends StatelessWidget {
  /// A group of [children].
  const DabblerRowGroup({
    super.key,
    required this.children,
    this.header,
    this.note,
  });

  /// The rows.
  final List<Widget> children;

  /// The group heading; omitted when null.
  final String? header;

  /// A line under the heading.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (header != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: DabblerSpacing.space2,
              end: DabblerSpacing.space2,
              bottom: DabblerSpacing.space3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(
                    header!,
                    style: DabblerType.footnote
                        .resolveForDirection(dir)
                        .copyWith(
                          color: colors.textSecondary,
                          fontWeight: DabblerType.semibold,
                        ),
                  ),
                ),
                if (note != null)
                  Text(
                    note!,
                    style: DabblerType.caption1
                        .resolveForDirection(dir)
                        .copyWith(color: colors.textTertiary),
                  ),
              ],
            ),
          ),
        DabblerSurface.card(
          radius: DabblerRadius.xl,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: DabblerSpacing.space5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < children.length; i++) ...<Widget>[
                if (i > 0) const DabblerDivider(),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A row of small round colour dots — a palette preview, drawn from the colours
/// the caller resolves (another theme's roles, not the active tokens).
class DabblerColorDots extends StatelessWidget {
  /// Dots in each of [colors].
  const DabblerColorDots({super.key, required this.colors});

  /// The dot colours, in reading order.
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < colors.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: DabblerSpacing.space2),
            SizedBox(
              width: DabblerSizing.swatch,
              height: DabblerSizing.swatch,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
