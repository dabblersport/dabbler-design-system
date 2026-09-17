/// Gallery entries for the form family (KAN-259 AC2).
///
/// One colocated file for the family: the fields share a shell and a source
/// specimen sheet, and a reviewer reads them against each other rather than
/// one at a time.
///
/// The fields here are rendered in their **controlled** states rather than
/// wired to local state — a gallery's job is to show every state at once, and
/// a live field shows exactly one.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'checkbox.dart';
import 'code_input.dart';
import 'date_field.dart';
import 'input_row.dart';
import 'picker_field.dart';
import 'radio.dart';
import 'select.dart';
import 'slider.dart';
import 'stepper.dart';
import 'text_field.dart';
import 'time_field.dart';
import 'toggle.dart';

/// The form family's specimens.
const List<GalleryEntry> formsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'TextField — variants and states',
    description: 'Every DabblerTextFieldVariant, plus helper, error and '
        'disabled.',
    builder: _textFields,
  ),
  GalleryEntry(
    title: 'Selection — checkbox, radio, toggle',
    description: 'Each in its on, off and disabled states.',
    builder: _selection,
  ),
  GalleryEntry(
    title: 'Select, Stepper, Slider',
    description: 'Single and multiple select, both stepper sizes, and the '
        'single and range sliders.',
    builder: _valueControls,
  ),
  GalleryEntry(
    title: 'Date, time, picker and code fields',
    description: 'The typed-or-picked fields, closed.',
    builder: _pickers,
  ),
  GalleryEntry(
    title: 'InputRow',
    description: 'The settings-style row, with and without a chevron.',
    builder: _rows,
  ),
];

Widget _textFields(BuildContext context) => GalleryStack(
  children: <Widget>[
    for (final DabblerTextFieldVariant variant
        in DabblerTextFieldVariant.values)
      GallerySpecimen(
        label: variant.name,
        child: DabblerTextField(
          variant: variant,
          label: 'Your name',
          placeholder: 'Nephthys',
        ),
      ),
    const GallerySpecimen(
      label: 'with helper text',
      child: DabblerTextField(label: 'Email', helperText: 'We never share it.'),
    ),
    const GallerySpecimen(
      label: 'with an error',
      child: DabblerTextField(label: 'Email', errorText: 'That is not valid.'),
    ),
    const GallerySpecimen(
      label: 'disabled',
      child: DabblerTextField(label: 'Email', enabled: false),
    ),
  ],
);

Widget _selection(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        GallerySpecimen(
          label: 'checkbox, off',
          child: DabblerCheckbox(checked: false, label: 'Remember me'),
        ),
        GallerySpecimen(
          label: 'checkbox, on',
          child: DabblerCheckbox(checked: true, label: 'Remember me'),
        ),
        GallerySpecimen(
          label: 'checkbox, disabled',
          child: DabblerCheckbox(
            checked: true,
            disabled: true,
            label: 'Remember me',
          ),
        ),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        GallerySpecimen(
          label: 'radio, off',
          child: DabblerRadio(selected: false, label: 'Football'),
        ),
        GallerySpecimen(
          label: 'radio, on',
          child: DabblerRadio(selected: true, label: 'Padel'),
        ),
        GallerySpecimen(
          label: 'radio, disabled',
          child: DabblerRadio(
            selected: false,
            disabled: true,
            label: 'Tennis',
          ),
        ),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        GallerySpecimen(
          label: 'toggle, off',
          child: DabblerToggle(checked: false, semanticLabel: 'Notifications'),
        ),
        GallerySpecimen(
          label: 'toggle, on',
          child: DabblerToggle(checked: true, semanticLabel: 'Notifications'),
        ),
        GallerySpecimen(
          label: 'toggle, disabled',
          child: DabblerToggle(
            checked: true,
            disabled: true,
            semanticLabel: 'Notifications',
          ),
        ),
      ],
    ),
  ],
);

const List<DabblerSelectOption<String>> _options = <DabblerSelectOption<String>>[
  DabblerSelectOption<String>(value: 'football', label: 'Football'),
  DabblerSelectOption<String>(value: 'padel', label: 'Padel'),
  DabblerSelectOption<String>(value: 'tennis', label: 'Tennis'),
];

Widget _valueControls(BuildContext context) => GalleryStack(
  children: <Widget>[
    const GallerySpecimen(
      label: 'select',
      child: DabblerSelect<String>(options: _options, label: 'Sport'),
    ),
    const GallerySpecimen(
      label: 'select, searchable and multiple',
      child: DabblerSelect<String>.multiple(
        options: _options,
        label: 'Sports',
        searchable: true,
      ),
    ),
    for (final DabblerStepperSize size in DabblerStepperSize.values)
      GallerySpecimen(
        label: 'stepper, ${size.name}',
        child: DabblerStepper(value: 4, size: size, label: 'Players'),
      ),
    const GallerySpecimen(
      label: 'slider',
      child: DabblerSlider(value: 40, label: 'Distance'),
    ),
    GallerySpecimen(
      label: 'slider, range',
      child: DabblerSlider.range(
        values: DabblerSliderRange(20, 70),
        label: 'Price',
      ),
    ),
  ],
);

Widget _pickers(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(label: 'date', child: DabblerDateField(label: 'Date')),
    GallerySpecimen(
      label: 'date, range',
      child: DabblerDateField.range(label: 'Dates'),
    ),
    GallerySpecimen(label: 'time', child: DabblerTimeField(label: 'Kick-off')),
    GallerySpecimen(
      label: 'picker field',
      child: DabblerPickerField(label: 'Venue', placeholder: 'Pick one'),
    ),
    GallerySpecimen(label: 'code input', child: DabblerCodeInput()),
    GallerySpecimen(
      label: 'code input, masked and in error',
      child: DabblerCodeInput(masked: true, error: true),
    ),
  ],
);

Widget _rows(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'title and subtitle',
      child: DabblerInputRow(title: 'Notifications', subtitle: 'All games'),
    ),
    GallerySpecimen(
      label: 'with a chevron',
      child: DabblerInputRow(title: 'Account', trailing: DabblerChevron()),
    ),
    GallerySpecimen(
      label: 'disabled',
      child: DabblerInputRow(title: 'Billing', enabled: false),
    ),
  ],
);
