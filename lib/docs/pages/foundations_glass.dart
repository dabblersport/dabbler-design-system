import 'package:flutter/material.dart';

import '../../components/dabbler_chip.dart';
import '../../theme/dabbler_colors.dart';
import '../../theme/dabbler_glass.dart';
import '../../theme/dabbler_spacing.dart';
import '../../theme/dabbler_type.dart';
import '../doc_blocks.dart';
import '../doc_model.dart';

final glassPage = DocPage(
  id: 'glass',
  group: DocGroup.foundations,
  title: 'Glass',
  definition:
      'The liquid-glass surface system — blur, gradient hairline, coloured cast, '
      'and the orb background it reads against.',
  keywords: [
    'foundation',
    'glass',
    'blur',
    'backdrop',
    'translucent',
    'elevation',
    'shadow',
    'gradient border',
    'background',
    'orbs',
  ],
  builder: (context) => [
    DocSection(
      'Overview',
      const DocProse(
        'Glass replaces the retired flat-elevation rule. A surface is a '
        'translucent fill over a backdrop blur, edged with a 1px gradient '
        'hairline and grounded by a two-part shadow: a coloured cast derived '
        'from the theme\'s brandPrimary plus a thin white lip highlight. '
        'Every colour derives from the active theme — switch to Sport and the '
        'glass re-tints green; nothing hardcodes the violet.',
      ),
    ),
    DocSection(
      'Live example',
      DocExampleFrame(
        align: AlignmentDirectional.center,
        child: Builder(builder: (context) {
          final d = context.dabbler;
          final b = Theme.of(context).brightness;
          return DabblerGlassSurface(
            borderRadius: DabblerRadius.xlRadius,
            shadows: DabblerGlass.cardShadows(d, b),
            padding: const EdgeInsets.all(DabblerSpacing.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Glass surface',
                    style:
                        DabblerType.headline.copyWith(color: d.textPrimary)),
                const SizedBox(height: DabblerSpacing.stackTight),
                Text('Blur + gradient hairline + coloured cast.',
                    style:
                        DabblerType.footnote.copyWith(color: d.textSecondary)),
                const SizedBox(height: DabblerSpacing.stackDefault),
                Wrap(
                  spacing: DabblerSpacing.stackTight,
                  runSpacing: DabblerSpacing.stackTight,
                  children: [
                    DabblerChip(label: 'Selected', selected: true, onTap: () {}),
                    DabblerChip(label: 'Glass', onTap: () {}),
                    const DabblerIconTile(icon: Icons.sports_soccer),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    ),
    DocSection(
      'Anatomy',
      const DocAnatomy([
        AnatomyPart('Fill',
            'White 45% (light) / ~12% (dark) over a BackdropFilter blur.'),
        AnatomyPart('Hairline',
            'A 1px top-to-bottom gradient: white → brand-light 33% → brand 25% → white 90%. Re-tints per theme.'),
        AnatomyPart('Cast + lip',
            'A brand-coloured drop shadow below plus a 1px white highlight along the top edge.'),
        AnatomyPart('Background',
            'DabblerGlassBackground: a theme-tinted base wash with four brand/accent radial orbs.'),
        AnatomyPart('Selected / active',
            'brandPrimary @ 85% + a top-lit sheen + a white 70% stroke; the label is onBrand (dark in Bright/Sport).'),
      ]),
    ),
    DocSection(
      'Specs',
      const DocSpecsTable([
        SpecRow('Fill · light', 'white @ 45%', 'DabblerGlass.fillLight'),
        SpecRow('Fill · dark', 'white @ 12%', 'DabblerGlass.fillDark'),
        SpecRow('Blur · cards / lists', '${DabblerGlass.blurCard}',
            'DabblerGlass.blurCard'),
        SpecRow('Blur · fields / icon tiles', '${DabblerGlass.blurField}',
            'DabblerGlass.blurField'),
        SpecRow('Blur · chips / small', '${DabblerGlass.blurSmall}',
            'DabblerGlass.blurSmall'),
        SpecRow('Blur · selected', '${DabblerGlass.blurSelected}',
            'DabblerGlass.blurSelected'),
        SpecRow('Card shadow', 'brand 15% · blur 32 · (0,14) + white lip',
            'DabblerGlass.cardShadows'),
        SpecRow('Raised shadow', 'brand 14% · blur 18 · (0,6) + white lip',
            'DabblerGlass.raisedShadows'),
        SpecRow('Inset shadow', 'brand 20% · blur 12 · (0,4) + lip above',
            'DabblerGlass.insetShadows'),
        SpecRow('Selected shadow', 'brand 40% · blur 20 · (0,8) + white lip',
            'DabblerGlass.selectedShadows'),
        SpecRow('Selected fill', 'brandPrimary @ 85% + top-lit sheen',
            'DabblerGlass.selectedFill / selectedOverlay'),
        SpecRow('Selected stroke', 'white @ 70% · 1px',
            'DabblerGlass.selectedStroke'),
        SpecRow('Icon tile', 'brand @ 10% fill · brand-light 40% stroke',
            'DabblerGlass.iconTileFill / iconTileStroke'),
        SpecRow('Glass divider', 'brandPrimary @ 10%', 'DabblerGlass.divider'),
      ]),
    ),
    DocSection(
      'Performance',
      const DocProse(
        'BackdropFilter is expensive, so DabblerGlassSurface enforces the rules: '
        'one blur per surface and never nested (a surface inside another glass '
        'surface skips its own filter automatically), each surface sits in a '
        'RepaintBoundary, and scrolling lists blur the container once — never '
        'each row. DabblerGlass.enabled plus the platform high-contrast / '
        'disable-animations signals degrade every surface to a solid tinted '
        'fill with a plain border.',
      ),
    ),
    DocSection(
      'Usage',
      const DocDoDont(
        dos: [
          'Put glass on DabblerGlassBackground — it needs the orbs to read.',
          'Blur a list container once; rows inside stay unblurred.',
          'Use onBrand for labels on the selected fill.',
        ],
        donts: [
          'Nest BackdropFilters — the inner surface must skip its blur.',
          'Hardcode the violet: every glass colour derives from the theme.',
          'Keep glass on when the platform asks for reduced transparency.',
        ],
      ),
    ),
    DocSection(
      'Accessibility & RTL',
      const DocProse(
        'Glass reduces contrast, so the fill opacities are chosen to keep body '
        'text at WCAG AA (4.5:1) over the orb background in all seven themes, '
        'both modes — verified by an automated contrast test. When the platform '
        'requests high contrast or reduced motion, surfaces become opaque.',
      ),
    ),
    DocSection(
      'Code',
      const DocCodeBlock('''
DabblerGlassBackground(
  child: DabblerGlassSurface(
    borderRadius: DabblerRadius.xlRadius,
    shadows: DabblerGlass.cardShadows(context.dabbler, brightness),
    padding: const EdgeInsets.all(DabblerSpacing.cardPadding),
    child: content,
  ),
);

// App-level reduce-transparency switch:
DabblerGlass.enabled = false; // every surface degrades to solid + border'''),
    ),
  ],
);
