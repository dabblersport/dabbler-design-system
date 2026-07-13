import 'package:flutter/widgets.dart';

import '../../theme/dabbler_colors.dart';
import '../../theme/dabbler_spacing.dart';
import '../../theme/dabbler_type.dart';
import '../doc_blocks.dart';
import '../doc_model.dart';

final elevationPage = DocPage(
  id: 'elevation',
  group: DocGroup.foundations,
  title: 'Elevation',
  definition:
      'RETIRED flat rule — elevation now belongs to the Glass foundation.',
  keywords: ['foundation', 'elevation', 'shadow', 'flat', 'depth', 'layer'],
  builder: (context) => [
    DocSection(
      'Overview',
      const DocProse(
        'The flat-elevation rule is RETIRED. Surfaces are now liquid glass — '
        'see Foundations · Glass for the surface, hairline, and shadow sets '
        '(cards and chips DO cast the glass shadows). What remains here is the '
        'legacy DabblerElevation.level2 shadow, still used by Material dialogs, '
        'sheets, and menus via dabblerThemeData.',
      ),
    ),
    DocSection('Live example', DocExampleFrame(child: _Levels())),
    DocSection(
      'Specs',
      const DocSpecsTable([
        SpecRow('level0', 'no shadow (flat on background)',
            'DabblerElevation.level0'),
        SpecRow('level1', 'no shadow (border + surface tint)',
            'DabblerElevation.level1'),
        SpecRow('level2', 'the only shadow — floating surfaces',
            'DabblerElevation.level2'),
      ]),
    ),
    DocSection(
      'Usage',
      const DocDoDont(
        dos: [
          'Use the DabblerGlass shadow sets for cards, chips, and fields.',
          'Reserve level2 for Material modals, sheets, and popovers.',
        ],
        donts: [
          'Follow the old flat guidance — it is retired.',
          'Invent one-off BoxShadows; every shadow is a glass token.',
        ],
      ),
    ),
    DocSection(
      'Code',
      const DocCodeBlock('''
// Floating surface (the only shadow):
Container(decoration: BoxDecoration(
  boxShadow: DabblerElevation.level2));

// Everything else stays flat: elevation: 0, surfaceTintColor: transparent.'''),
    ),
  ],
);

class _Levels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    Widget card(String label, List<BoxShadow> shadow, bool bordered) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: DabblerSpacing.space11 * 2,
              height: DabblerSpacing.space8 * 3,
              decoration: BoxDecoration(
                color: d.surfaceCard,
                borderRadius: DabblerRadius.lgRadius,
                border: bordered
                    ? Border.all(
                        color: d.borderDefault,
                        width: DabblerSizing.borderHairline)
                    : null,
                boxShadow: shadow,
              ),
            ),
            const SizedBox(height: DabblerSpacing.stackTight),
            Text(label,
                style: DabblerType.caption2.copyWith(color: d.textTertiary)),
          ],
        );

    return Wrap(
      spacing: DabblerSpacing.sectionGap,
      runSpacing: DabblerSpacing.stackDefault,
      children: [
        card('level0', DabblerElevation.level0, false),
        card('level1', DabblerElevation.level1, true),
        card('level2 (float)', DabblerElevation.level2, true),
      ],
    );
  }
}
