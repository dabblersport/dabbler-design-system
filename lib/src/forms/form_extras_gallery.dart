/// Gallery entries for Alpha DS gaps 5 item 4 and the code-input half of
/// item 10: [DabblerTextField] inside a [Form] with a validator and a
/// `suffixText`, and [DabblerCodeInput]'s `fullWidth` mode.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'code_input.dart';
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
