/// Gallery entries for Alpha DS gaps 5 item 4 and the code-input half of
/// item 10: [DabblerTextField] inside a [Form] with a validator and a
/// `suffixText`, and [DabblerCodeInput]'s `fullWidth` mode.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import 'code_input.dart';
import 'composer_box.dart';
import 'select_pill.dart';
import 'stepper_pill.dart';
import 'text_field.dart';

/// Form-integration and full-width specimens.
const List<GalleryEntry> formExtrasGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'text-field/form',
    page: 'components/text-field',
    group: GalleryPurpose.selectionAndInput,
    title: 'TextField — validator, Form and suffix text',
    description:
        'Validates as you type after the first edit; a unit suffix at the '
        'trailing edge.',
    builder: _formFields,
  ),
  GalleryEntry(
    id: 'text-field/composer-box',
    page: 'components/text-field',
    group: GalleryPurpose.selectionAndInput,
    title: 'ComposerBox and SelectPill — the post editor',
    description:
        'The editor card with its counter and tool row, and the tinted '
        'pills that open the post type and audience.',
    builder: _composer,
  ),
  GalleryEntry(
    id: 'code-input/full-width',
    page: 'components/code-input',
    group: GalleryPurpose.selectionAndInput,
    title: 'CodeInput — full width',
    description:
        'Boxes widen to fill the row, capped so a box is never wider than '
        'it is tall.',
    builder: _codes,
  ),
];

const double _width = 280;

String? _required(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Enter a title' : null;

Widget _formFields(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'validator — onUserInteraction',
      child: SizedBox(
        width: _width,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: const DabblerTextField(
            label: 'Title',
            initialValue: 'Sunday 7-a-side',
            validator: _required,
          ),
        ),
      ),
    ),
    const GallerySpecimen(
      label: 'suffix text',
      child: SizedBox(
        width: _width,
        child: DabblerTextField(
          label: 'Duration',
          initialValue: '90',
          suffixText: 'min',
        ),
      ),
    ),
    const GallerySpecimen(
      label: 'suffix text — RTL',
      child: SizedBox(
        width: _width,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerTextField(
            label: 'المدة',
            initialValue: '90',
            suffixText: 'دقيقة',
          ),
        ),
      ),
    ),
  ],
);

Widget _codes(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'fullWidth — 320 row',
      child: SizedBox(
        width: 320,
        child: DabblerCodeInput(fullWidth: true, value: '418'),
      ),
    ),
    GallerySpecimen(
      label: 'fullWidth — capped, 4 boxes',
      child: SizedBox(
        width: 320,
        child: DabblerCodeInput(length: 4, fullWidth: true),
      ),
    ),
  ],
);

Widget _composer(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return GalleryStack(
    children: <Widget>[
      GallerySpecimen(
        label: 'select pills',
        child: Wrap(
          spacing: 6,
          children: <Widget>[
            DabblerSelectPill(
              label: 'Dab',
              icon: 'like-1',
              tone: colors.info,
              onTap: () {},
            ),
            DabblerSelectPill(
              label: 'Public',
              icon: 'global',
              tone: colors.success,
              onTap: () {},
            ),
          ],
        ),
      ),
      GallerySpecimen(
        label: 'stepper pills',
        child: Wrap(
          spacing: 6,
          children: <Widget>[
            DabblerStepperPill(value: 4, suffix: 'min', onChanged: (_) {}),
            DabblerStepperPill(value: 10, suffix: 'max', onChanged: (_) {}),
          ],
        ),
      ),
      GallerySpecimen(
        label: 'editor',
        child: SizedBox(
          width: _width,
          child: DabblerComposerBox(
            controller: TextEditingController(),
            placeholder: "What's on your mind? Use #hashtags",
            counter: '0/2000',
            minLines: 3,
            tools: <DabblerComposerTool>[
              DabblerComposerTool(
                icon: 'gallery',
                label: 'Media',
                onTap: () {},
              ),
              DabblerComposerTool(
                icon: 'location',
                label: 'Location',
                active: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
