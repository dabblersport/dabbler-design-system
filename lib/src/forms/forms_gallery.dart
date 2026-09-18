/// Gallery entries for the form family.
///
/// **Rebuilt 2026-09-17 against the rendered design**, not against the written
/// acceptance criteria. Each entry below mirrors one section of the design's
/// own specimen pages, so a reviewer putting the two side by side sees the
/// same sheet rather than a stack of lone fields:
///
/// | entry | specimen section |
/// |---|---|
/// | Fields — anatomy and shared states | `components/forms/fields.card.html` §*Field anatomy* + §*Shared states* |
/// | TextField — the five variants | `fields.card.html` §*TextField* |
/// | Selection — checkbox, radio, toggle | `components/forms/forms-states.card.html` |
/// | Select — choosing from a list | `components/forms/selection.card.html` §*Select* |
/// | Slider and Stepper | `components/forms/value-controls.card.html` |
/// | Pickers — date, time, code | `fields.card.html` §*PickerField / DateField / TimeField / CodeInput* |
/// | InputRow | `components/layout/layout.card.html` |
///
/// The content is the specimen's content — the same labels, the same values,
/// the same helper and error strings, the same field widths (230, or 260 for
/// the anatomy pair) and the same 20px wrap gap — because a specimen built
/// from different words is a different drawing.
///
/// The fields are rendered in their **controlled** states rather than wired to
/// local state: a gallery's job is to show every state at once, and a live
/// field shows exactly one.
library;

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'checkbox.dart';
import 'code_input.dart';
import 'date_field.dart';
import 'field_shell.dart';
import 'input_row.dart';
import 'picker_field.dart';
import 'radio.dart';
import 'select.dart';
import 'slider.dart';
import 'stepper.dart';
import 'text_field.dart';
import 'time_field.dart';
import 'toggle.dart';

/// The specimen's own `Field` width — `width = 230` on
/// `fields.card.html`'s `Field` helper.
const double _fieldWidth = 230;

/// The wider pair in the anatomy row — `width={260}`.
const double _anatomyWidth = 260;

/// The specimen's `Wrap` gap — `gap: 20` on `fields.card.html`'s `Wrap`
/// and on `forms-states.card.html`'s `Row`. Not a [DabblerSpacing] step; it is
/// specimen-sheet chrome, not a component value, so it is written literally.
const double _wrapGap = 20;

/// The specimen's column gap between sections — `gap: 20`.
const double _sectionGap = 20;

/// One labelled, fixed-width specimen, which is the design page's own `Field`
/// helper: a column of the label and the field, [_fieldWidth] wide.
Widget _field(String label, Widget child, {double width = _fieldWidth}) =>
    SizedBox(
      width: width,
      child: GallerySpecimen(
        label: label,
        // The specimen's `Field` is `display:flex; flexDirection:column`, so
        // the field fills the declared width. A [GallerySpecimen] column
        // passes loose constraints, which would let each field shrink to its
        // own content and break the drawn grid — hence the explicit stretch.
        child: SizedBox(width: double.infinity, child: child),
      ),
    );

/// The specimen's `Wrap` — `display:flex; gap:20; flexWrap:wrap;
/// alignItems:flex-start`.
Widget _wrap(List<Widget> children) => Wrap(
  spacing: _wrapGap,
  runSpacing: _wrapGap,
  crossAxisAlignment: WrapCrossAlignment.start,
  children: children,
);

/// The specimen's `Row` — the same wrap, centred on the cross axis, which is
/// what `forms-states.card.html` uses for the selection controls.
Widget _controlRow(List<Widget> children) => Wrap(
  spacing: _wrapGap,
  runSpacing: _wrapGap,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: children,
);

/// A section heading, which the specimen renders as its `<h2>`.
class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: DabblerType.headline
        .resolveForDirection(Directionality.of(context))
        .copyWith(color: DabblerColors.of(context).textPrimary),
  );
}

/// A section: a heading over its rows, the specimen's `.sec`.
Widget _section(String heading, List<Widget> rows) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: <Widget>[
    _Heading(heading),
    for (final Widget row in rows) ...<Widget>[
      const SizedBox(height: DabblerSpacing.space4),
      row,
    ],
  ],
);

Widget _sections(List<Widget> sections) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: <Widget>[
    for (int i = 0; i < sections.length; i++) ...<Widget>[
      if (i > 0) const SizedBox(height: _sectionGap),
      sections[i],
    ],
  ],
);

/// The form family's specimens.
const List<GalleryEntry> formsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'field-shell',
    page: 'components/field-shell',
    group: GalleryPurpose.selectionAndInput,
    title: 'Fields — the shared shell and its five states',
    description: 'The anatomy pair and the rest / filled / helper / error / '
        'disabled matrix, over the raw FieldShell holding each state open.',
    builder: _fields,
  ),
  GalleryEntry(
    id: 'text-field/variants',
    page: 'components/text-field',
    group: GalleryPurpose.selectionAndInput,
    title: 'TextField — the five variants',
    description: 'standard · search · password · multiline · select, closed '
        'and open.',
    builder: _textFieldVariants,
  ),
  GalleryEntry(
    id: 'checkbox/selection-controls',
    page: 'components/checkbox',
    group: GalleryPurpose.selectionAndInput,
    title: 'Selection — checkbox, radio, toggle',
    description: 'Each control across off, on and both disabled forms.',
    builder: _selection,
  ),
  GalleryEntry(
    id: 'select',
    page: 'components/select',
    group: GalleryPurpose.selectionAndInput,
    title: 'Select — choosing from a list',
    description: 'Single, multiple, searchable and disabled.',
    builder: _selects,
  ),
  GalleryEntry(
    id: 'slider/value-controls',
    page: 'components/slider',
    group: GalleryPurpose.selectionAndInput,
    title: 'Slider and Stepper',
    description: 'Distance, price range, marks and disabled; both stepper '
        'sizes with their bound, error and disabled states.',
    builder: _valueControls,
  ),
  GalleryEntry(
    id: 'picker-field/pickers',
    page: 'components/picker-field',
    group: GalleryPurpose.selectionAndInput,
    title: 'Pickers — date, time, picker field and code',
    description: 'The typed-or-picked fields, closed, plus the OTP boxes.',
    builder: _pickers,
  ),
  GalleryEntry(
    id: 'input-row',
    page: 'components/input-row',
    group: GalleryPurpose.selectionAndInput,
    title: 'InputRow',
    description: 'The settings row: plain, with a subtitle, with a chevron '
        'and with a toggle.',
    builder: _rows,
  ),
];

// ---------------------------------------------------------------------------
// fields.card.html — "Field anatomy" and "Shared states"
// ---------------------------------------------------------------------------

Widget _fields(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return _sections(<Widget>[
    _section('Field anatomy — the shared shell', <Widget>[
      _wrap(<Widget>[
        _field(
          'label · shell · helper line',
          const DabblerTextField(
            label: 'Venue',
            initialValue: 'Zayed Sports City',
            helperText: 'players see this on the card',
          ),
          width: _anatomyWidth,
        ),
        _field(
          'leading + trailing content',
          DabblerTextField(
            label: 'Price',
            initialValue: '60',
            prefixIcon: const DabblerIcon(
              'wallet',
              size: DabblerSizing.iconMd,
            ),
            // `<span style={{fontSize:13,color:'var(--muted)'}}>AED</span>`
            // (`fields.card.html:56`) — specimen demo content, and the one
            // place the forms area paints a surface neutral as text. It is
            // the sheet's own inline label, not a component role, so it takes
            // the field's secondary ink here.
            suffixIcon: Text(
              'AED',
              style: DabblerType.footnote
                  .resolveForDirection(Directionality.of(context))
                  .copyWith(color: colors.textSecondary),
            ),
          ),
          width: _anatomyWidth,
        ),
      ]),
    ]),
    _section('Shared states', <Widget>[
      _wrap(<Widget>[
        _field(
          'rest — placeholder',
          const DabblerTextField(
            label: 'Title',
            placeholder: 'Sunday 7-a-side',
          ),
        ),
        _field(
          'filled',
          const DabblerTextField(
            label: 'Title',
            initialValue: 'Sunday 7-a-side',
          ),
        ),
        _field(
          'helper text',
          const DabblerTextField(
            label: 'Venue',
            initialValue: 'Zayed Sports City',
            helperText: 'players see this on the card',
          ),
        ),
        _field(
          'error',
          const DabblerTextField(
            label: 'Email',
            initialValue: 'not-an-email',
            errorText: 'Enter a valid email',
          ),
        ),
        _field(
          'disabled',
          const DabblerTextField(
            label: 'Organiser',
            initialValue: 'you',
            enabled: false,
          ),
        ),
      ]),
      // The specimen's second row holds each shell state open with a bare
      // `FieldShell`, because a live field shows one state at a time.
      _wrap(<Widget>[
        _field('FieldShell — rest', _shell(context, 'any content')),
        _field(
          'FieldShell — focused',
          _shell(context, 'focus ring held', focused: true),
        ),
        _field(
          'FieldShell — error',
          _shell(context, 'any content', errorText: 'something is off'),
        ),
        _field(
          'FieldShell — disabled',
          _shell(context, 'any content', disabled: true),
        ),
      ]),
    ]),
  ]);
}

/// `<FieldShell label="Shell">…</FieldShell>` — the specimen's own use of the
/// shell as a state swatch.
Widget _shell(
  BuildContext context,
  String content, {
  bool focused = false,
  bool disabled = false,
  String? errorText,
}) {
  final DabblerColors colors = DabblerColors.of(context);
  return DabblerFieldShell(
    label: 'Shell',
    focused: focused,
    disabled: disabled,
    errorText: errorText,
    children: <Widget>[
      Expanded(
        child: Text(
          content,
          style: DabblerType.subheadline
              .resolveForDirection(Directionality.of(context))
              .copyWith(
                color: disabled ? colors.textTertiary : colors.textPrimary,
              ),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// fields.card.html — "TextField"
// ---------------------------------------------------------------------------

Widget _textFieldVariants(BuildContext context) => _sections(<Widget>[
  _section('TextField', <Widget>[
    _wrap(<Widget>[
      _field(
        'standard',
        const DabblerTextField(
          label: 'Title',
          placeholder: 'Sunday 7-a-side',
        ),
      ),
      _field(
        'search',
        const DabblerTextField(
          variant: DabblerTextFieldVariant.search,
          placeholder: 'Search venues',
        ),
      ),
      _field(
        'password',
        const DabblerTextField(
          label: 'Password',
          variant: DabblerTextFieldVariant.password,
          initialValue: 'dabbler123',
        ),
      ),
      _field(
        'multiline',
        const DabblerTextField(
          label: 'Notes',
          variant: DabblerTextFieldVariant.multiline,
          rows: 2,
          initialValue: 'Bring a light and a dark shirt.',
        ),
      ),
      _field(
        'select shell — closed',
        const DabblerTextField(
          label: 'Sport',
          variant: DabblerTextFieldVariant.select,
          value: 'padel',
        ),
      ),
      _field(
        'select shell — open',
        const DabblerTextField(
          label: 'Sport',
          variant: DabblerTextFieldVariant.select,
          value: 'padel',
          open: true,
        ),
      ),
    ]),
  ]),
]);

// ---------------------------------------------------------------------------
// forms-states.card.html
// ---------------------------------------------------------------------------

Widget _selection(BuildContext context) => _sections(<Widget>[
  _section('Checkbox', <Widget>[
    GallerySpecimen(
      label: 'off · on · disabled off · disabled on',
      child: _controlRow(const <Widget>[
        DabblerCheckbox(checked: false, label: 'Recurring'),
        DabblerCheckbox(checked: true, label: 'Recurring'),
        DabblerCheckbox(checked: false, disabled: true, label: 'Recurring'),
        DabblerCheckbox(checked: true, disabled: true, label: 'Recurring'),
      ]),
    ),
  ]),
  _section('Radio', <Widget>[
    GallerySpecimen(
      label: 'one group, selected and disabled',
      child: _controlRow(const <Widget>[
        DabblerRadio(selected: false, label: 'beginner'),
        DabblerRadio(selected: true, label: 'intermediate'),
        DabblerRadio(selected: false, label: 'advanced'),
        DabblerRadio(selected: false, disabled: true, label: 'pro'),
        DabblerRadio(selected: true, disabled: true, label: 'pro'),
      ]),
    ),
  ]),
  _section('Toggle', <Widget>[
    GallerySpecimen(
      label: 'off · on · disabled off · disabled on',
      child: _controlRow(const <Widget>[
        DabblerToggle(checked: false, semanticLabel: 'Notifications'),
        DabblerToggle(checked: true, semanticLabel: 'Notifications'),
        DabblerToggle(
          checked: false,
          disabled: true,
          semanticLabel: 'Notifications',
        ),
        DabblerToggle(
          checked: true,
          disabled: true,
          semanticLabel: 'Notifications',
        ),
      ]),
    ),
  ]),
]);

// ---------------------------------------------------------------------------
// selection.card.html — "Select — choosing from a list"
// ---------------------------------------------------------------------------

const List<DabblerSelectOption<String>> _sports =
    <DabblerSelectOption<String>>[
  DabblerSelectOption<String>(value: 'football', label: 'football'),
  DabblerSelectOption<String>(value: 'padel', label: 'padel'),
  DabblerSelectOption<String>(value: 'tennis', label: 'tennis'),
];

const List<DabblerSelectOption<String>> _levels =
    <DabblerSelectOption<String>>[
  DabblerSelectOption<String>(value: 'beginner', label: 'beginner'),
  DabblerSelectOption<String>(value: 'intermediate', label: 'intermediate'),
  DabblerSelectOption<String>(value: 'advanced', label: 'advanced'),
];

const List<DabblerSelectOption<String>> _cities =
    <DabblerSelectOption<String>>[
  DabblerSelectOption<String>(value: 'abu-dhabi', label: 'abu dhabi'),
  DabblerSelectOption<String>(value: 'dubai', label: 'dubai'),
  DabblerSelectOption<String>(value: 'sharjah', label: 'sharjah'),
];

Widget _selects(BuildContext context) => _sections(<Widget>[
  _section('Select — choosing from a list', <Widget>[
    _wrap(<Widget>[
      _field(
        'single value — the list closes on select',
        const DabblerSelect<String>(
          label: 'sport',
          value: 'padel',
          options: _sports,
        ),
      ),
      _field(
        'multiple — the list stays open',
        const DabblerSelect<String>.multiple(
          label: 'skill level',
          values: <String>['intermediate'],
          options: _levels,
        ),
      ),
      _field(
        'searchable — filters by label',
        const DabblerSelect<String>(
          label: 'city',
          searchable: true,
          placeholder: 'pick a city',
          options: _cities,
        ),
      ),
      _field(
        'disabled',
        const DabblerSelect<String>(
          label: 'sport',
          value: 'padel',
          enabled: false,
          options: _sports,
        ),
      ),
    ]),
  ]),
]);

// ---------------------------------------------------------------------------
// value-controls.card.html
// ---------------------------------------------------------------------------

Widget _valueControls(BuildContext context) => _sections(<Widget>[
  _section('Slider', <Widget>[
    _wrap(<Widget>[
      _field(
        'distance',
        DabblerSlider(
          label: 'distance',
          min: 0,
          max: 25,
          value: 12,
          formatValue: (num v) => '${v.round()} km',
        ),
      ),
      _field(
        'price — range',
        DabblerSlider.range(
          label: 'price',
          min: 0,
          max: 200,
          step: 5,
          values: const DabblerSliderRange(40, 120),
          formatValue: (num v) => 'AED ${v.round()}',
        ),
      ),
      _field(
        'marks',
        DabblerSlider(
          label: 'fill',
          min: 0,
          max: 100,
          step: 5,
          value: 50,
          marks: const <double>[0, 25, 50, 75, 100],
          formatValue: (num v) => '${v.round()}%',
        ),
      ),
      _field(
        'disabled',
        DabblerSlider(
          label: 'distance',
          min: 0,
          max: 25,
          value: 12,
          disabled: true,
          formatValue: (num v) => '${v.round()} km',
        ),
      ),
    ]),
  ]),
  _section('Stepper', <Widget>[
    _wrap(<Widget>[
      _field(
        'players — with bounds in the helper line',
        const DabblerStepper(
          label: 'players',
          min: 4,
          max: 22,
          value: 10,
          helperText: '4 to 22 players',
        ),
      ),
      _field(
        'at min — decrement disabled',
        const DabblerStepper(label: 'tickets', min: 1, max: 6, value: 1),
      ),
      _field(
        'at max — increment disabled',
        const DabblerStepper(label: 'sets', min: 1, max: 6, value: 6),
      ),
      _field(
        'size sm — 39px controls',
        const DabblerStepper(
          label: 'tickets',
          min: 1,
          max: 6,
          value: 2,
          size: DabblerStepperSize.sm,
        ),
      ),
      _field(
        'error',
        const DabblerStepper(
          label: 'players',
          min: 4,
          max: 22,
          value: 4,
          errorText: 'pick at least 6 for a 7-a-side',
        ),
      ),
      _field(
        'disabled',
        const DabblerStepper(
          label: 'players',
          min: 4,
          max: 22,
          value: 10,
          disabled: true,
        ),
      ),
    ]),
  ]),
]);

// ---------------------------------------------------------------------------
// fields.card.html — the picker fields and CodeInput
// ---------------------------------------------------------------------------

Widget _pickers(BuildContext context) => _sections(<Widget>[
  _section('PickerField, DateField and TimeField', <Widget>[
    _wrap(<Widget>[
      _field(
        'date',
        DabblerDateField(
          label: 'Date',
          value: DateTime(2026, 9, 12),
        ),
      ),
      _field(
        'date — range',
        DabblerDateField.range(
          label: 'Dates',
          span: DabblerDateSpan(
            start: DateTime(2026, 9, 12),
            end: DateTime(2026, 9, 19),
          ),
        ),
      ),
      _field(
        'time',
        const DabblerTimeField(
          label: 'Kick-off',
          value: TimeOfDay(hour: 18, minute: 0),
        ),
      ),
      _field(
        'picker field — the shared shell',
        const DabblerPickerField(label: 'Venue', placeholder: 'Pick one'),
      ),
    ]),
  ]),
  _section('CodeInput', <Widget>[
    GallerySpecimen(
      label: 'four digits, filled',
      child: _controlRow(const <Widget>[
        DabblerCodeInput(length: 4, value: '4207'),
      ]),
    ),
    GallerySpecimen(
      label: 'six digits, partial · masked · in error · disabled',
      child: _controlRow(const <Widget>[
        DabblerCodeInput(value: '12'),
        DabblerCodeInput(value: '1234', masked: true),
        DabblerCodeInput(value: '12', error: true),
        DabblerCodeInput(value: '12', enabled: false),
      ]),
    ),
  ]),
]);

// ---------------------------------------------------------------------------
// layout.card.html — InputRow
// ---------------------------------------------------------------------------

Widget _rows(BuildContext context) => _sections(<Widget>[
  _section('InputRow', <Widget>[
    GallerySpecimen(
      label: 'plain · with a subtitle · with a chevron · with a toggle',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          DabblerInputRow(title: 'Account'),
          SizedBox(height: DabblerSpacing.space3),
          DabblerInputRow(title: 'Notifications', subtitle: 'All games'),
          SizedBox(height: DabblerSpacing.space3),
          DabblerInputRow(
            title: 'my friends',
            subtitle: 'only friends can join',
            trailing: DabblerChevron(),
          ),
          SizedBox(height: DabblerSpacing.space3),
          DabblerInputRow(
            title: 'push notifications',
            trailing: DabblerToggle(
              checked: true,
              semanticLabel: 'push notifications',
            ),
          ),
          SizedBox(height: DabblerSpacing.space3),
          DabblerInputRow(title: 'Billing', enabled: false),
        ],
      ),
    ),
  ]),
]);
