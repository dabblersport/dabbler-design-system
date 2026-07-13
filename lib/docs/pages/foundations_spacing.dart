import 'package:flutter/widgets.dart';

import '../../theme/dabbler_colors.dart';
import '../../theme/dabbler_spacing.dart';
import '../../theme/dabbler_type.dart';
import '../doc_blocks.dart';
import '../doc_model.dart';

final spacingPage = DocPage(
  id: 'spacing',
  group: DocGroup.foundations,
  title: 'Spacing & Layout',
  definition: 'A base-3 spacing scale plus tap-target and icon sizing tokens.',
  keywords: [
    'foundation',
    'spacing',
    'layout',
    'grid',
    'padding',
    'gap',
    'sizing',
    'tap target',
  ],
  builder: (context) => [
    DocSection(
      'Overview',
      const DocProse(
        'The grid is base-3: every step is a multiple of 3, and the structural '
        'values (12 / 24 / 30 / 36 / 48) are multiples of both 3 and 4 so they '
        'line up with 24px icons and platform components. Reference the semantic '
        'aliases (cardPadding, screenGutter, sectionGap…) in UI, not raw numbers.',
      ),
    ),
    DocSection('Live example', DocExampleFrame(child: _Scale())),
    DocSection(
      'Specs',
      DocSpecsTable([
        for (final (name, value) in DabblerSpacing.scale)
          SpecRow(name, '${value.toInt()} px', 'DabblerSpacing.$name'),
      ]),
    ),
    DocSection(
      'Semantic aliases',
      const DocSpecsTable([
        SpecRow('cardPadding', '18 px', 'DabblerSpacing.cardPadding'),
        SpecRow('screenGutter', '24 px', 'DabblerSpacing.screenGutter'),
        SpecRow('sectionGap', '30 px', 'DabblerSpacing.sectionGap'),
        SpecRow('stackDefault', '12 px', 'DabblerSpacing.stackDefault'),
        SpecRow('stackTight', '6 px', 'DabblerSpacing.stackTight'),
        SpecRow('iconGap', '6 px', 'DabblerSpacing.iconGap'),
      ]),
    ),
    DocSection(
      'Sizing',
      DocSpecsTable([
        SpecRow('touchTargetMin', '${DabblerSizing.touchTargetMin.toInt()} px',
            'DabblerSizing.touchTargetMin'),
        SpecRow('iconSm', '${DabblerSizing.iconSm.toInt()} px',
            'DabblerSizing.iconSm'),
        SpecRow('iconMd', '${DabblerSizing.iconMd.toInt()} px',
            'DabblerSizing.iconMd'),
        SpecRow('iconLg', '${DabblerSizing.iconLg.toInt()} px',
            'DabblerSizing.iconLg'),
        const SpecRow('borderHairline', '${DabblerSizing.borderHairline} px',
            'DabblerSizing.borderHairline'),
        const SpecRow('borderDefault', '${DabblerSizing.borderDefault} px',
            'DabblerSizing.borderDefault'),
      ]),
    ),
    DocSection(
      'Usage',
      const DocDoDont(
        dos: [
          'Reach for a semantic alias first (cardPadding, sectionGap).',
          'Prefer 12 / 24 / 30 / 36 / 48 for structural layout values.',
          'Keep every tap target at least touchTargetMin (45).',
        ],
        donts: [
          'Inline a raw number like 16 or 20 — they are off the base-3 grid.',
          'Invent one-off spacing that no token expresses.',
        ],
      ),
    ),
    DocSection(
      'Code',
      const DocCodeBlock('''
Padding(padding: EdgeInsets.all(DabblerSpacing.cardPadding));      // 18
SizedBox(height: DabblerSpacing.sectionGap);                       // 30
ConstrainedBox(
  constraints: BoxConstraints(minHeight: DabblerSizing.touchTargetMin)); // 45'''),
    ),
  ],
);

class _Scale extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, value) in DabblerSpacing.scale)
          Padding(
            padding: const EdgeInsets.only(bottom: DabblerSpacing.stackTight),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text('$name · ${value.toInt()}',
                      style: DabblerType.caption1
                          .copyWith(color: d.textSecondary)),
                ),
                Container(
                  width: value,
                  height: DabblerSpacing.space3,
                  decoration: BoxDecoration(
                    color: d.brandPrimary,
                    borderRadius: DabblerRadius.smRadius,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
