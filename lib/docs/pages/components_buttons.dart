import 'package:flutter/material.dart';

import '../../components/dabbler_button.dart';
import '../../theme/dabbler_spacing.dart';
import '../doc_blocks.dart';
import '../doc_model.dart';

String _titleCase(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

final buttonsPage = DocPage(
  id: 'buttons',
  group: DocGroup.components,
  title: 'Buttons',
  definition: 'A token-driven glass button in six variants and three sizes.',
  keywords: [
    'component',
    'button',
    'filled',
    'tonal',
    'outlined',
    'text',
    'destructive',
    'icon',
    'cta',
  ],
  builder: (context) => [
    DocSection(
      'Overview',
      const DocProse(
        'Buttons trigger actions. Filled and destructive carry the brand-filled '
        'glass treatment (near-opaque fill, top-lit sheen, white stroke, '
        'selected shadow); tonal and outlined are glass surfaces with the '
        'gradient hairline; text stays bare. Press deepens the glass shadow '
        'with a slight scale. The label colour is always onBrand / onError so '
        'it stays legible on light-primaried themes.',
      ),
    ),
    DocSection(
      'Live example',
      DocExampleFrame(
        align: AlignmentDirectional.center,
        child: DabblerButton(
            label: 'Join game', leadingIcon: Icons.sports_soccer, onPressed: () {}),
      ),
    ),
    DocSection(
      'Anatomy',
      const DocAnatomy([
        AnatomyPart('Container',
            'Glass or brand-filled surface, radius md (9); icon variant is a circular glass button.'),
        AnatomyPart('Label', 'DabblerType.headline (Medium 500), colour onBrand.'),
        AnatomyPart('Icon', 'Optional leading/trailing at iconMd (24); mirrors in RTL.'),
        AnatomyPart('States',
            'default · pressed (deeper shadow + slight scale) · disabled · loading.'),
      ]),
    ),
    DocSection(
      'Variants',
      DocCaptionedGrid([
        for (final v in DabblerButtonVariant.values)
          Captioned(
            v.name,
            v == DabblerButtonVariant.icon
                ? DabblerButton.icon(icon: Icons.favorite_border, onPressed: () {})
                : DabblerButton(
                    label: _titleCase(v.name), variant: v, onPressed: () {}),
          ),
      ]),
    ),
    DocSection(
      'States',
      DocCaptionedGrid([
        Captioned('default', DabblerButton(label: 'Default', onPressed: () {})),
        Captioned('pressed (hold)', DabblerButton(label: 'Pressed', onPressed: () {})),
        const Captioned('disabled', DabblerButton(label: 'Disabled')),
        Captioned('loading',
            DabblerButton(label: 'Loading', isLoading: true, onPressed: () {})),
      ]),
    ),
    DocSection(
      'Specs',
      DocSpecsTable([
        for (final s in DabblerButtonSize.values)
          SpecRow(
            'Height · ${s.name}',
            '${s.height.toInt()} px',
            'DabblerButtonMetrics.height',
          ),
        for (final s in DabblerButtonSize.values)
          SpecRow(
            'H-padding · ${s.name}',
            '${s.horizontalPadding.toInt()} px',
            'DabblerSpacing',
          ),
        for (final s in DabblerButtonSize.values)
          SpecRow('Label size · ${s.name}', '${s.labelSize.toInt()} pt',
              'DabblerButtonMetrics.labelSize'),
        const SpecRow('Radius', '9 px', 'DabblerRadius.md'),
        const SpecRow('Label style', 'Headline · 17/500', 'DabblerType.headline'),
        SpecRow('Min tap target', '${DabblerSizing.touchTargetMin.toInt()} px',
            'DabblerSizing.touchTargetMin'),
      ]),
    ),
    DocSection(
      'Usage',
      const DocDoDont(
        dos: [
          'Use one primary (Filled) button per screen for the main action.',
          'Use Destructive for irreversible actions; Text/Outlined for secondary.',
          'Show isLoading while an action is in flight — it swallows taps.',
        ],
        donts: [
          'Hardcode white label text — Bright and Sport need dark onBrand.',
          'Invent a custom shadow; press feedback is the deepened glass cast.',
          'Stack multiple Filled buttons competing for attention.',
        ],
      ),
    ),
    DocSection(
      'Accessibility & RTL',
      const DocProse(
        'Every button clears the 45px tap target, even the small size (it pads its '
        'hit area). Leading/trailing icons use start/end, so they mirror in RTL. '
        'Label colour comes from onBrand/onError, guaranteeing contrast in all '
        'seven themes.',
      ),
    ),
    DocSection(
      'Code',
      const DocCodeBlock('''
DabblerButton(
  label: 'Join game',
  leadingIcon: Icons.sports_soccer,
  variant: DabblerButtonVariant.filled,   // default
  size: DabblerButtonSize.medium,         // 45
  onPressed: () => join(),
);

DabblerButton.icon(icon: Icons.favorite_border, onPressed: () {});'''),
    ),
  ],
);
