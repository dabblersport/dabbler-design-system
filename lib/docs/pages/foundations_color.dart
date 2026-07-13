import 'package:flutter/widgets.dart';

import '../../theme/dabbler_colors.dart';
import '../../theme/dabbler_spacing.dart';
import '../../theme/dabbler_type.dart';
import '../doc_blocks.dart';
import '../doc_model.dart';

String _hex(Color c) {
  final v = c.toARGB32() & 0xFFFFFF;
  return '#${v.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

/// (label, color, token-source) — computed live from the active theme.
List<(String, Color, String)> _tokens(DabblerColors d) => [
      ('brandPrimary', d.brandPrimary, 'context.dabbler.brandPrimary'),
      ('onBrand', d.onBrand, 'context.dabbler.onBrand'),
      ('accent', d.accent, 'context.dabbler.accent'),
      ('onAccent', d.onAccent, 'context.dabbler.onAccent'),
      ('bgPrimary', d.bgPrimary, 'context.dabbler.bgPrimary'),
      ('surfaceCard', d.surfaceCard, 'context.dabbler.surfaceCard'),
      ('bgTertiary', d.bgTertiary, 'context.dabbler.bgTertiary'),
      ('textPrimary', d.textPrimary, 'context.dabbler.textPrimary'),
      ('textSecondary', d.textSecondary, 'context.dabbler.textSecondary'),
      ('borderDefault', d.borderDefault, 'context.dabbler.borderDefault'),
      ('focusRing', d.focusRing, 'context.dabbler.focusRing'),
      ('success', d.success, 'context.dabbler.success'),
      ('warning', d.warning, 'context.dabbler.warning'),
      ('error', d.error, 'context.dabbler.error'),
      ('info', d.info, 'context.dabbler.info'),
      ('spotlight', d.spotlight, 'context.dabbler.spotlight'),
    ];

final colorPage = DocPage(
  id: 'color',
  group: DocGroup.foundations,
  title: 'Color',
  definition:
      'Seven themes over one token structure, with tinted neutrals and paired on-colors.',
  keywords: [
    'foundation',
    'color',
    'colour',
    'brand',
    'theme',
    'tokens',
    'onBrand',
    'contrast',
  ],
  builder: (context) => [
    DocSection(
      'Overview',
      const DocProse(
        'Colour reads from two places: Material roles (Theme.of(context).'
        'colorScheme) and Dabbler tokens (context.dabbler). Neutrals are never '
        'pure white or black — each is a faint tint of the active theme. Every '
        'brand and semantic colour ships with a paired on-colour, so text on a '
        'coloured surface is always legible — including the light-primaried '
        'themes (Bright, Sport) where onBrand is dark.',
      ),
    ),
    DocSection('Live example', DocExampleFrame(child: _Swatches())),
    DocSection(
      'Anatomy',
      const DocAnatomy([
        AnatomyPart('Brand + accent',
            'brandPrimary / accent carry identity; onBrand / onAccent are their legible foregrounds.'),
        AnatomyPart('Tinted neutrals',
            'bgPrimary → surfaceCard → bgTertiary form the surface ladder; text* and border* are tints of the same seed.'),
        AnatomyPart('Semantics',
            'success / warning / error / info, each with a surface and an on-color.'),
      ]),
    ),
    DocSection(
      'Specs',
      Builder(builder: (context) {
        final d = context.dabbler;
        return DocSpecsTable([
          for (final (name, color, src) in _tokens(d))
            SpecRow(name, _hex(color), src),
        ]);
      }),
    ),
    DocSection(
      'Usage',
      const DocDoDont(
        dos: [
          'Put text/icons on brand surfaces in onBrand / onAccent.',
          'Use semantic tokens (error, success) for status, not raw brand.',
          'Let the tinted neutrals be — do not "correct" them to pure white.',
        ],
        donts: [
          'Hardcode Colors.white on a primary — Bright & Sport need dark onBrand.',
          'Add a hex literal in UI code; add a token instead.',
          'Assume a fixed light/dark palette; there are seven themes.',
        ],
      ),
    ),
    DocSection(
      'Accessibility & RTL',
      const DocProse(
        'On-colours are chosen per theme so foreground/background contrast holds '
        'in light and dark. Because everything is a token, switching theme or '
        'mode can never strand a hardcoded colour at low contrast.',
      ),
    ),
    DocSection(
      'Code',
      const DocCodeBlock('''
final tokens = context.dabbler;
Container(
  color: tokens.brandPrimary,
  child: Text('Join', style: TextStyle(color: tokens.onBrand)), // never Colors.white
);'''),
    ),
  ],
);

class _Swatches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return Wrap(
      spacing: DabblerSpacing.stackDefault,
      runSpacing: DabblerSpacing.stackDefault,
      children: [
        for (final (name, color, _) in _tokens(d))
          Container(
            width: 132,
            padding: const EdgeInsets.all(DabblerSpacing.space3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: DabblerRadius.mdRadius,
              border: Border.all(
                  color: d.borderDefault, width: DabblerSizing.borderHairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: DabblerType.caption1
                        .copyWith(color: _readable(color, d))),
                Text(_hex(color),
                    style: DabblerType.caption2
                        .copyWith(color: _readable(color, d))),
              ],
            ),
          ),
      ],
    );
  }

  // Swatch caption: the system's near-black or near-white primitive, whichever
  // reads on this swatch.
  Color _readable(Color bg, DabblerColors d) =>
      bg.computeLuminance() > 0.5 ? DabblerPalette.ink900 : DabblerPalette.paper;
}
