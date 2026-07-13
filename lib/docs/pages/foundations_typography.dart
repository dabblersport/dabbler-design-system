import 'package:flutter/widgets.dart';

import '../../theme/dabbler_colors.dart';
import '../../theme/dabbler_type.dart';
import '../doc_blocks.dart';
import '../doc_model.dart';

// The Apple-HIG ramp, read straight off the DabblerType definitions so the
// specimen and the Specs table can never drift from the code.
final List<(String, TextStyle)> _ramp = [
  ('Large Title', DabblerType.largeTitle),
  ('Title 1', DabblerType.title1),
  ('Title 2', DabblerType.title2),
  ('Title 3', DabblerType.title3),
  ('Headline', DabblerType.headline),
  ('Body', DabblerType.body),
  ('Callout', DabblerType.callout),
  ('Subheadline', DabblerType.subheadline),
  ('Footnote', DabblerType.footnote),
  ('Caption 1', DabblerType.caption1),
  ('Caption 2', DabblerType.caption2),
];

String _weightName(int w) => switch (w) {
      300 => 'Light',
      400 => 'Regular',
      500 => 'Medium',
      600 => 'SemiBold',
      700 => 'Bold',
      _ => 'w$w',
    };

final typographyPage = DocPage(
  id: 'typography',
  group: DocGroup.foundations,
  title: 'Typography',
  definition:
      'The Apple-HIG type ramp rendered in Readex Pro, Latin and Arabic in one face.',
  keywords: [
    'foundation',
    'typography',
    'type',
    'font',
    'readex',
    'text',
    ..._ramp.map((e) => e.$1),
  ],
  builder: (context) {
    return [
      DocSection(
        'Overview',
        const DocProse(
          'One ramp, eleven styles, from Large Title down to Caption 2. Titles run '
          'Light (300) and Headline runs Medium (500) — a deliberately lighter set '
          'than the platform default, tuned for Readex Pro, which carries both '
          'Latin and Arabic glyphs so there is no separate Arabic face.',
        ),
      ),
      DocSection('Live example', DocExampleFrame(child: _Specimen())),
      DocSection(
        'Specs',
        DocSpecsTable([
          for (final (name, style) in _ramp)
            SpecRow(
              name,
              '${style.fontSize!.round()} / ${(style.height! * style.fontSize!).round()} · ${_weightName(style.fontWeight!.value)}',
              'DabblerType.${_camel(name)}',
            ),
        ]),
      ),
      DocSection(
        'Usage',
        const DocDoDont(
          dos: [
            'Use Headline for buttons and row titles; Body for reading text.',
            'Let Material widgets inherit type from ThemeData.textTheme.',
            'Apply DabblerType.arabic() (taller leading) for Arabic text.',
          ],
          donts: [
            'Hardcode a fontSize or FontWeight — reference a ramp style.',
            'Add per-letter tracking; the ramp is tuned at zero.',
            'Mix another font family into the system.',
          ],
        ),
      ),
      DocSection(
        'Accessibility & RTL',
        const DocProse(
          'Arabic keeps the same sizes but takes ~1.18× leading for comfortable '
          'rendering; DabblerType.arabic() applies it. Type colour always comes '
          'from the on-surface / text tokens, so contrast holds in every theme.',
        ),
      ),
      DocSection(
        'Code',
        const DocCodeBlock('''
Text('Tuesday 5-a-side', style: DabblerType.headline);

// Arabic — same size, taller leading:
Text('خماسي الثلاثاء',
    textDirection: TextDirection.rtl,
    style: DabblerType.arabic(DabblerType.headline));'''),
      ),
    ];
  },
);

// 'Large Title' → 'largeTitle', 'Caption 2' → 'caption2'.
String _camel(String name) {
  final parts = name.split(' ');
  return parts.first.toLowerCase() + parts.skip(1).join();
}

class _Specimen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, style) in _ramp)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name · ${style.fontSize!.round()}/${(style.height! * style.fontSize!).round()} · w${style.fontWeight!.value}',
                  style: DabblerType.caption2.copyWith(color: d.textTertiary),
                ),
                const SizedBox(height: 2),
                Text('Sport belongs to everyone',
                    style: style.copyWith(color: d.textPrimary)),
                Text(
                  'الرياضة لكل من يحضر',
                  textDirection: TextDirection.rtl,
                  style: DabblerType.arabic(style).copyWith(color: d.textSecondary),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
