import 'package:flutter/material.dart';

import '../../components/dabbler_card.dart';
import '../../components/dabbler_inputs.dart';
import '../../components/dabbler_surface.dart';
import '../../theme/dabbler_colors.dart';
import '../../theme/dabbler_spacing.dart';
import '../../theme/dabbler_type.dart';
import '../doc_blocks.dart';
import '../doc_model.dart';

String _titleCase(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

Widget _variantCard(BuildContext context, DabblerCardVariant v) {
  final d = context.dabbler;
  return SizedBox(
    width: 220,
    child: DabblerCard(
      variant: v,
      onTap: v == DabblerCardVariant.interactive ? () {} : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_titleCase(v.name),
              style: DabblerType.headline.copyWith(color: d.textPrimary)),
          const SizedBox(height: DabblerSpacing.stackTight),
          Text('Tint + border, no shadow.',
              style: DabblerType.footnote.copyWith(color: d.textSecondary)),
        ],
      ),
    ),
  );
}

final cardsPage = DocPage(
  id: 'cards',
  group: DocGroup.components,
  title: 'Cards & Lists',
  definition:
      'Flat surfaces, a titled section grouping, and the workhorse list tile.',
  keywords: [
    'component',
    'card',
    'surface',
    'list',
    'tile',
    'section',
    'chevron',
    'nested',
  ],
  builder: (context) => [
    DocSection(
      'Overview',
      const DocProse(
        'Cards group related content on a flat surface. Separation comes from the '
        'tinted-neutral ladder (bgPrimary → surfaceCard → bgTertiary) and a '
        'hairline border — never a shadow. The list tile is the workhorse row; '
        'the section groups tiles and cards under a title.',
      ),
    ),
    DocSection(
      'Live example',
      DocExampleFrame(
        child: SizedBox(
          width: 300,
          child: DabblerCard(
            padding: EdgeInsets.zero,
            child: DabblerListTile(
              leading: Icon(Icons.sports_soccer,
                  size: DabblerSizing.iconMd,
                  color: context.dabbler.textSecondary),
              title: 'Tuesday 5-a-side',
              subtitle: 'Business Bay · 7:00 PM',
              trailing: const DabblerChevron(),
              onTap: () {},
            ),
          ),
        ),
      ),
    ),
    DocSection(
      'Anatomy',
      const DocAnatomy([
        AnatomyPart('Container', 'surfaceCard fill, radius lg (12), elevation 0.'),
        AnatomyPart('Border', 'Hairline (0.5px) borderDefault — the separation cue.'),
        AnatomyPart('Padding', 'cardPadding (18) by default; override per case.'),
        AnatomyPart('States', 'interactive press shifts tonally toward bgTertiary.'),
      ]),
    ),
    DocSection(
      'Variants',
      DocCaptionedGrid([
        for (final v in DabblerCardVariant.values)
          Captioned(v.name, _variantCard(context, v)),
      ]),
    ),
    DocSection(
      'Nested surfaces (flat-ladder proof)',
      DocExampleFrame(
        child: SizedBox(
          width: 320,
          child: DabblerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Standard card',
                    style: DabblerType.headline
                        .copyWith(color: context.dabbler.textPrimary)),
                const SizedBox(height: DabblerSpacing.stackDefault),
                DabblerCard(
                  variant: DabblerCardVariant.filled,
                  child: Text(
                    'Filled card nested inside — a distinct layer with no shadow.',
                    style: DabblerType.footnote
                        .copyWith(color: context.dabbler.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    DocSection(
      'List tiles',
      const DocExampleFrame(
        child: SizedBox(width: 320, child: _TileDemo()),
      ),
    ),
    DocSection(
      'Specs',
      DocSpecsTable([
        SpecRow('Card radius', '${DabblerRadius.lg.toInt()} px', 'DabblerRadius.lg'),
        SpecRow('Card padding', '${DabblerSpacing.cardPadding.toInt()} px',
            'DabblerSpacing.cardPadding'),
        const SpecRow('Border', '${DabblerSizing.borderHairline} px',
            'DabblerSizing.borderHairline'),
        const SpecRow('Selected border', '2 px brandPrimary',
            'DabblerSizing.borderDefault + 1'),
        SpecRow('Tile min height', '${DabblerSizing.touchTargetMin.toInt()} px',
            'DabblerSizing.touchTargetMin'),
        SpecRow('Tile (dense)', '${DabblerSpacing.space10.toInt()} px',
            'DabblerSpacing.space10'),
        const SpecRow('Tile title', 'Body · 17/400', 'DabblerType.body'),
        const SpecRow('Tile subtitle', 'Footnote · 13', 'DabblerType.footnote'),
      ]),
    ),
    DocSection(
      'Usage',
      const DocDoDont(
        dos: [
          'Nest with filled cards; let tint + border show the layers.',
          'Use interactive cards for whole-row taps; DabblerListTile for rows.',
          'Group related rows under a DabblerSurfaceSection with a title.',
        ],
        donts: [
          'Add a BoxShadow to lift a card — the system is flat.',
          'Use raw Material Card default elevation/tint.',
          'Inset a divider with left/right — it must mirror in RTL.',
        ],
      ),
    ),
    DocSection(
      'Accessibility & RTL',
      const DocProse(
        'Interactive cards and tiles clear the 45px tap target and clip their '
        'ripple to the radius. The list-tile divider insets to the title start '
        'and mirrors under RTL, and DabblerChevron flips its glyph (› → ‹).',
      ),
    ),
    DocSection(
      'Code',
      const DocCodeBlock('''
DabblerCard(
  variant: DabblerCardVariant.interactive,
  onTap: () => open(),
  child: DabblerListTile(
    leading: Icon(Icons.sports_soccer, size: DabblerSizing.iconMd),
    title: 'Tuesday 5-a-side',
    subtitle: 'Business Bay · 7:00 PM',
    trailing: const DabblerChevron(),
  ),
);'''),
    ),
  ],
);

class _TileDemo extends StatefulWidget {
  const _TileDemo();

  @override
  State<_TileDemo> createState() => _TileDemoState();
}

class _TileDemoState extends State<_TileDemo> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return DabblerCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          DabblerListTile(
            leading: Icon(Icons.event, size: DabblerSizing.iconMd, color: d.textSecondary),
            title: 'With icon + chevron',
            subtitle: 'Leading icon, trailing chevron',
            trailing: const DabblerChevron(),
            onTap: () {},
            showDivider: true,
          ),
          DabblerListTile(
            leading: Icon(Icons.notifications_outlined,
                size: DabblerSizing.iconMd, color: d.textSecondary),
            title: 'With switch',
            trailing:
                DabblerSwitch(value: _on, onChanged: (v) => setState(() => _on = v)),
            showDivider: true,
          ),
          const DabblerListTile(
            dense: true,
            title: 'Dense tile',
          ),
        ],
      ),
    );
  }
}
