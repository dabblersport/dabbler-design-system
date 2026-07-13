import 'package:flutter/material.dart';

import '../../components/dabbler_inputs.dart';
import '../../components/dabbler_text_field.dart';
import '../../theme/dabbler_spacing.dart';
import '../doc_blocks.dart';
import '../doc_model.dart';

Widget _field(Widget child) => SizedBox(width: 260, child: child);

final inputsPage = DocPage(
  id: 'inputs',
  group: DocGroup.components,
  title: 'Text Fields & Inputs',
  definition:
      'Flat text fields (standard, multiline, search, password) plus checkbox, radio, and switch.',
  keywords: [
    'component',
    'text field',
    'input',
    'form',
    'search',
    'password',
    'checkbox',
    'radio',
    'switch',
  ],
  builder: (context) => [
    DocSection(
      'Overview',
      const DocProse(
        'Text fields capture input; the selection controls capture choices. All '
        'are flat: every InputDecoration border is set explicitly so no Material '
        'underline or filled default leaks through, and nothing casts a shadow. '
        'Focus draws a 2px focusRing and turns the label brandPrimary.',
      ),
    ),
    DocSection(
      'Live example',
      DocExampleFrame(
        child: _field(const DabblerTextField(
          label: 'Full name',
          hint: 'Enter your name',
          helperText: 'As printed on your ID',
        )),
      ),
    ),
    DocSection(
      'Anatomy',
      const DocAnatomy([
        AnatomyPart('Label', 'Above the field — subheadline; brandPrimary on focus.'),
        AnatomyPart('Container', 'Fill bgSecondary, hairline border, radius sm.'),
        AnatomyPart('Hint', 'Placeholder — body, textTertiary.'),
        AnatomyPart('Helper / error', 'Below — footnote; error text replaces helper.'),
        AnatomyPart('Prefix / suffix', 'Start/end icon slots; mirror in RTL.'),
      ]),
    ),
    DocSection(
      'Variants',
      DocCaptionedGrid([
        Captioned('standard', _field(const DabblerTextField(hint: 'Standard'))),
        Captioned(
            'multiline',
            _field(const DabblerTextField(
                variant: DabblerTextFieldVariant.multiline,
                hint: 'Notes',
                minLines: 2,
                maxLines: 4))),
        Captioned('search', _field(const DabblerTextField.search(hint: 'Search games'))),
        Captioned(
            'password', _field(const DabblerTextField.password(label: 'Password'))),
      ]),
    ),
    DocSection(
      'States',
      DocCaptionedGrid([
        Captioned('default', _field(const DabblerTextField(hint: 'Default'))),
        Captioned(
            'error',
            _field(const DabblerTextField(
                hint: 'Email', errorText: 'This field is required'))),
        Captioned('disabled',
            _field(const DabblerTextField(hint: 'Disabled', enabled: false))),
      ]),
    ),
    DocSection(
      'Selection controls',
      const DocExampleFrame(child: _SelectionDemo()),
    ),
    DocSection(
      'Specs',
      DocSpecsTable([
        SpecRow('Min height', '${DabblerSizing.touchTargetMin.toInt()} px',
            'DabblerSizing.touchTargetMin'),
        SpecRow('Radius · standard', '${DabblerRadius.sm.toInt()} px',
            'DabblerRadius.sm'),
        SpecRow('Radius · multiline', '${DabblerRadius.md.toInt()} px',
            'DabblerRadius.md'),
        const SpecRow('Radius · search', 'full', 'DabblerRadius.pill'),
        const SpecRow('Focus border', '2 px focusRing', 'DabblerSizing.borderDefault + 1'),
        SpecRow('H-padding', '${DabblerSpacing.space4.toInt()} px',
            'DabblerSpacing.space4'),
        SpecRow('V-padding', '${DabblerSpacing.space3.toInt()} px',
            'DabblerSpacing.space3'),
        const SpecRow('Input text', 'Body · 17/400', 'DabblerType.body'),
        const SpecRow('Label', 'Subheadline · 15', 'DabblerType.subheadline'),
        const SpecRow('Helper / error', 'Footnote · 13', 'DabblerType.footnote'),
      ]),
    ),
    DocSection(
      'Usage',
      const DocDoDont(
        dos: [
          'Give every field a clear label; use helperText for constraints.',
          'Use the search variant for filtering — it clears with one tap.',
          'Wire validator for form validation; the border turns error automatically.',
        ],
        donts: [
          'Let a Material underline show — borders are set explicitly.',
          'Hardcode a check-mark or switch colour; on-brand marks read onBrand.',
          'Place prefix/suffix with left/right — use the start/end slots.',
        ],
      ),
    ),
    DocSection(
      'Accessibility & RTL',
      const DocProse(
        'Prefix and suffix (including the clear × and the password toggle) sit in '
        'the start/end slots, so they land on the correct side in RTL. Arabic '
        'input takes DabblerType.arabic() leading, and selection controls each '
        'clear the 45px tap target with dark on-brand marks in Bright/Sport.',
      ),
    ),
    DocSection(
      'Code',
      const DocCodeBlock('''
DabblerTextField(
  label: 'Full name',
  hint: 'Enter your name',
  helperText: 'As printed on your ID',
  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
);

DabblerTextField.search(hint: 'Search games', controller: c);
DabblerCheckbox(value: agreed, onChanged: (v) => setState(() => agreed = v));'''),
    ),
  ],
);

class _SelectionDemo extends StatefulWidget {
  const _SelectionDemo();

  @override
  State<_SelectionDemo> createState() => _SelectionDemoState();
}

class _SelectionDemoState extends State<_SelectionDemo> {
  bool _check = true;
  int _radio = 0;
  bool _switch = true;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DabblerSpacing.sectionGap,
      runSpacing: DabblerSpacing.stackDefault,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DabblerCheckbox(
            value: _check, onChanged: (v) => setState(() => _check = v)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              DabblerRadio<int>(
                value: i,
                groupValue: _radio,
                onChanged: i == 2 ? null : (v) => setState(() => _radio = v),
              ),
          ],
        ),
        DabblerSwitch(
            value: _switch, onChanged: (v) => setState(() => _switch = v)),
      ],
    );
  }
}
