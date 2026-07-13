import 'package:flutter/widgets.dart';

import '../../theme/dabbler_colors.dart';
import '../../theme/dabbler_spacing.dart';
import '../../theme/dabbler_type.dart';
import '../doc_blocks.dart';
import '../doc_model.dart';

String _radiusUse(String name) => switch (name) {
      'sm' => 'chips, inputs',
      'md' => 'buttons',
      'lg' => 'icon tiles, nested surfaces',
      'xl' => 'cards, sheets',
      'xxl' => 'search fields, hero glass',
      'pill' => 'pills, avatars, glass chips',
      _ => '',
    };

final radiusPage = DocPage(
  id: 'radius',
  group: DocGroup.foundations,
  title: 'Radius',
  definition: 'A base-3 corner-radius scale, from crisp chips to full pills.',
  keywords: ['foundation', 'radius', 'corner', 'rounding', 'shape'],
  builder: (context) => [
    DocSection(
      'Overview',
      const DocProse(
        'Corner radii are base-3 and mapped to component roles, so a button is '
        'always md (9) and a card is always lg (12). Use the semantic getters '
        '(buttonRadius, cardRadius) rather than picking a raw radius per widget.',
      ),
    ),
    DocSection('Live example', DocExampleFrame(child: _Swatches())),
    DocSection(
      'Specs',
      DocSpecsTable([
        for (final (name, value) in DabblerRadius.scale)
          SpecRow(
            '$name — ${_radiusUse(name)}',
            value >= 999 ? 'full' : '${value.toInt()} px',
            'DabblerRadius.$name',
          ),
      ]),
    ),
    DocSection(
      'Usage',
      const DocDoDont(
        dos: [
          'Use the role getter: buttonRadius, cardRadius, chipRadius.',
          'Keep radius consistent within a component family.',
        ],
        donts: [
          'Hardcode BorderRadius.circular(8) — 8 is off the base-3 scale.',
          'Mix radii on one surface.',
        ],
      ),
    ),
    DocSection(
      'Code',
      const DocCodeBlock('''
ClipRRect(borderRadius: DabblerRadius.cardRadius, child: …);   // lg (12)
Container(decoration: BoxDecoration(
  borderRadius: DabblerRadius.mdRadius));                      // md (9)'''),
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
        for (final (name, value) in DabblerRadius.scale)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: DabblerSpacing.space11,
                decoration: BoxDecoration(
                  color: d.surfaceCard,
                  borderRadius: BorderRadius.circular(value),
                  border: Border.all(
                      color: d.borderStrong,
                      width: DabblerSizing.borderHairline),
                ),
              ),
              const SizedBox(height: DabblerSpacing.stackTight),
              Text('$name · ${value >= 999 ? "full" : value.toInt()}',
                  style: DabblerType.caption2.copyWith(color: d.textTertiary)),
            ],
          ),
      ],
    );
  }
}
