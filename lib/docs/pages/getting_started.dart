import 'package:flutter/widgets.dart';

import '../doc_blocks.dart';
import '../doc_model.dart';

final gettingStartedPage = DocPage(
  id: 'introduction',
  group: DocGroup.gettingStarted,
  title: 'Introduction',
  definition:
      'A flat, bilingual, token-driven design system for the Dabbler sports app.',
  keywords: ['getting started', 'introduction', 'principles', 'tokens', 'setup'],
  builder: (context) => [
    DocSection(
      'Overview',
      const DocProse(
        'Dabbler is a Material 3 design system built for a bilingual (English / '
        'Arabic) sports app. Everything — colour, type, spacing, and every '
        'component — is expressed as tokens, and every screen reads those tokens '
        'rather than hard-coding values. This site is itself built from the '
        'system: the theme, direction, and mode controls in the header re-render '
        'the whole page live.',
      ),
    ),
    DocSection(
      'Principles',
      const DocAnatomy([
        AnatomyPart('Flat, not floating',
            'Separation comes from tinted surfaces and hairline borders, not shadows. Only genuinely floating things (modals, sheets) cast one.'),
        AnatomyPart('Tokens are the source of truth',
            'Colours, sizes, radii, and type live in the foundations. UI reads them; it never inlines a literal.'),
        AnatomyPart('Bilingual by default',
            'Every component is RTL-safe and picks up Arabic leading. Design in both directions from the start.'),
        AnatomyPart('Seven themes, one system',
            'Main, Sport, Social, Active, Bright, Simple, and Shade all share one structure. On-brand marks read from tokens so light-primaried themes stay legible.'),
      ]),
    ),
    DocSection(
      'Consuming the tokens',
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DocProse(
            'A screen reads colour from two places: Material roles via '
            'Theme.of(context).colorScheme, and Dabbler tokens via '
            'context.dabbler. Read geometry from DabblerSpacing / DabblerRadius / '
            'DabblerSizing, and type from DabblerType.',
          ),
          SizedBox(height: 16),
          DocCodeBlock('''
final tokens = context.dabbler;            // Dabbler semantic tokens
final colors = Theme.of(context).colorScheme; // Material roles

DabblerButton(
  label: 'Join game',
  onPressed: () {},
  // background = tokens.brandPrimary, label = tokens.onBrand (dark in Bright)
);

Text('Tuesday 5-a-side', style: DabblerType.headline);
Padding(padding: EdgeInsets.all(DabblerSpacing.cardPadding));'''),
        ],
      ),
    ),
    DocSection(
      'Usage',
      const DocDoDont(
        dos: [
          'Read every colour, size, and type style from a token.',
          'Use the on-* tokens (onBrand, onError) for text on coloured surfaces.',
          'Test each screen in Arabic (RTL), not just with an Arabic label.',
        ],
        donts: [
          'Hardcode a hex, a raw pixel value, or Colors.white.',
          'Add a shadow to a card or tile — the system is flat.',
          'Assume left/right; use start/end so layouts mirror.',
        ],
      ),
    ),
  ],
);
