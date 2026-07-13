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
      'A flat, Apple-style system — separation is tint + border, only one shadow.',
  keywords: ['foundation', 'elevation', 'shadow', 'flat', 'depth', 'layer'],
  builder: (context) => [
    DocSection(
      'Overview',
      const DocProse(
        'Elevation is flat. Surfaces separate through the tinted-neutral ladder '
        '(bgPrimary → surfaceCard → bgTertiary) and hairline borders — not '
        'shadows. Only genuinely floating things (modals, sheets, popovers) cast '
        'the single shadow, level2. Cards and tiles never do.',
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
          'Separate cards with surfaceCard/bgTertiary tint + a hairline border.',
          'Reserve level2 for modals, sheets, and popovers only.',
        ],
        donts: [
          'Add a BoxShadow to a card, tile, button, or app bar.',
          'Raise the dark-mode shadow — it is faint on purpose.',
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
