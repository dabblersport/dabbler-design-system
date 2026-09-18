/// Gallery entries for the bidirectionality axis — the *comparison* specimen
/// (KAN-316, `DECISIONS.md` D-035(c), extending D-034(b)).
///
/// ## Why this page exists although a direction switcher already does
///
/// The gallery header carries a direction switcher (KAN-294), and for a
/// **single** component it is the right control: `code-input.md`'s own
/// Direction section confirms its contract by driving it, and D-035(c) names
/// that as the correct, unblocked pattern. This page is the other case.
///
/// The foundation's subject is not "the system mirrors". It is **where
/// mirroring stops** — and a stop is a difference between two states, which a
/// switcher structurally cannot show because it replaces one with the other.
/// A reviewer flipping the switch sees a code input with its digits on the
/// left, then a code input with its digits on the left, and has no way to tell
/// that the second one *resisted* something. Beside its own mirrored self, the
/// resistance is the first thing visible.
///
/// So every band below renders its component twice, adjacent, under an
/// explicit [Directionality] each. Neither side follows the header switcher.
///
/// ## The six contracts, each verified against the source
///
/// | # | contract | where it lives |
/// |---|---|---|
/// | 1 | a code's digit boxes do **not** mirror | `code_input.dart:51` |
/// | 2 | a picker's editable is LTR-pinned inside mirrored chrome | `picker_field_shell.dart:255` |
/// | 3 | the week start is a locale fact the **caller** passes | `calendar.dart:126` |
/// | 4 | the slider's pointer mapping inverts | `slider.dart:373` |
/// | 5 | the type layer forks by script | `dabbler_type.dart:456` |
/// | 6 | directional glyphs are **selected**, never transformed | `input_row.dart:299` |
///
/// Cases 1–5 are KAN-316's acceptance criteria. Case 6 is the same family of
/// fact and is drawn here because the page would otherwise imply that every
/// glyph mirrors itself, which is exactly the assumption [DabblerIcon] refuses.
///
/// ### Case 2 is attributed to the shell, not to the field
///
/// KAN-316 AC2 asks for this explicitly, and it is easy to get wrong. The
/// LTR pin is `textDirection: TextDirection.ltr` on the editable inside
/// **[DabblerPickerFieldShell]** (`picker_field_shell.dart:255`), which every
/// picker field is built from — the date field, the time field, the select.
/// It is not a [DabblerDateField] behaviour, and a reader who took it for one
/// would assume the time field had to reimplement it.
library;

import 'package:flutter/widgets.dart';

import '../calendar/calendar.dart';
import '../forms/code_input.dart';
import '../forms/date_field.dart';
import '../forms/input_row.dart';
import '../forms/slider.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_page.dart';
import '../gallery/gallery_specimen.dart';
import 'dabbler_colors.dart';
import 'dabbler_geometry.dart';
import 'dabbler_type.dart';

/// The bidirectionality comparison specimen.
const List<GalleryEntry> directionGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'bidirectionality',
    page: 'foundations/bidirectionality',
    group: null,
    title: 'Direction — where mirroring stops',
    description: 'Six RTL contracts, each rendered LTR and RTL side by side. '
        'The subject is not that the system mirrors; it is what deliberately '
        'does not.',
    builder: _direction,
  ),
];

/// A fixed month, so the grid does not drift with the clock — the same choice
/// `calendar_gallery.dart` makes, for the same reason.
final DateTime _month = DateTime(2026, 9);

/// One side of a pair. Wide enough for a calendar, narrow enough for two of
/// them to sit beside each other on a review window.
const double _sideWidth = 320;

Widget _direction(BuildContext context) {
  return GallerySections(
    ruled: true,
    children: <Widget>[
      const GalleryUsage(
        '**Six contracts, twelve renders, no switching.** Each band below '
        'installs its own `Directionality` per side, so the two states are on '
        'screen at the same moment. Read each pair as one sentence: what '
        'flipped, and what refused to.',
      ),
      _band(
        name: '1 · A code does not mirror',
        usage: '**`code_input.dart:51`.** The box row is wrapped in an '
            'explicit `Directionality(textDirection: TextDirection.ltr)`. A '
            'verification code is a number, numbers read left to right in both '
            'scripts, and mirroring the boxes would change the value the user '
            'sees. Digit 1 is on the left in both renders — that is the '
            'contract, and it is the only component in the package that pins a '
            'direction. Arrow-key traversal follows the same pinned order.',
        child: const DabblerCodeInput(length: 4, value: '4207'),
      ),
      _band(
        name: '2 · A picker field pins its editable, not its chrome',
        usage: '**`picker_field_shell.dart:255` — the shared shell, not '
            '`DabblerDateField`.** The value run carries '
            '`textDirection: TextDirection.ltr` so `12/09/2026` cannot be '
            'reordered to `2026/09/12` by the bidi algorithm: `/` is '
            'bidi-neutral, and neutrals take the direction of what surrounds '
            'them. Everything around it still mirrors — the label, the trailing '
            'glyph and the box are `DabblerFieldShell`, which reads the ambient '
            'direction. Every picker field inherits this: the date field, the '
            'time field and the select alike.',
        child: const DabblerDateField(
          label: 'Date',
          value: null,
          placeholder: '12/09/2026',
        ),
      ),
      _band(
        name: '3 · The week start is the caller’s fact',
        usage: '**`calendar.dart:126`.** Nothing in the calendar decides a '
            'week start. `defaultFirstWeekdayFor` is a **fallback** for a '
            'caller that named none — Monday under LTR, Saturday under RTL, '
            'which is the first day across the Arabic-speaking markets Dabbler '
            'ships to — and a caller that knows its locale passes '
            '`firstWeekday` instead. The column *order* is not computed at all: '
            'seven columns in a `Row` run leading-to-trailing, so the first day '
            'lands on the right because `Directionality` reversed the row, not '
            'because a list was reversed.',
        child: DabblerCalendar(month: _month, showActions: false),
      ),
      _band(
        name: '4 · The slider inverts its pointer mapping',
        usage: '**`slider.dart:373`.** `_valueAt` takes the ratio of the drag '
            'x to the track width and, under RTL, uses `1 - ratio`. Without it '
            'the track would mirror while the gesture did not, and dragging '
            'toward the high end would lower the value. The filled portion '
            'grows from the inline start in both renders — which is the right '
            'edge under RTL.',
        child: const DabblerSlider(
          label: 'distance',
          min: 0,
          max: 25,
          value: 18,
        ),
      ),
      _TypeBand(),
      _band(
        name: '6 · A directional glyph is selected, never transformed',
        usage: '**`input_row.dart:299`.** Flutter has no ambient glyph '
            'mirroring and `DabblerIcon` never mirrors itself — the caller '
            'picks the name. `DabblerChevron` asks for `arrow-right` under LTR '
            'and `arrow-left` under RTL. A `Transform` would have been the '
            'obvious shortcut and is wrong: it flips the glyph’s optical '
            'weight with it, so a stroke tapered for a right-pointing chevron '
            'ends up tapered the wrong way.',
        child: const _ChevronReadout(),
      ),
    ],
  );
}

/// One contract: its name, its prose, then the component rendered under both
/// directions at once.
Widget _band({
  required String name,
  required String usage,
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      GallerySectionLabel(name),
      const SizedBox(height: DabblerSpacing.space2),
      GalleryUsage(usage),
      const SizedBox(height: DabblerSpacing.space4),
      Wrap(
        spacing: DabblerSpacing.space6,
        runSpacing: DabblerSpacing.space6,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: <Widget>[
          for (final TextDirection direction in TextDirection.values)
            _Side(direction: direction, child: child),
        ],
      ),
    ],
  );
}

/// One side of a comparison, under an explicit [Directionality].
///
/// The [DefaultTextStyle] is reinstalled from *this* side's direction rather
/// than inherited from the page, because the type layer forks by script
/// (`dabbler_type.dart:456`) and an inherited Latin style would silently
/// suppress the very fact band 5 is about.
class _Side extends StatelessWidget {
  const _Side({required this.direction, required this.child});

  final TextDirection direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _sideWidth,
      child: Directionality(
        textDirection: direction,
        child: Builder(
          builder: (BuildContext inner) => DefaultTextStyle(
            style: galleryTextStyle(inner),
            child: GallerySpecimen(
              label: direction == TextDirection.ltr ? 'LTR' : 'RTL',
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Band 5 — the type fork, shown as the resolved style rather than as a widget
/// pair, because the fact is in the [TextStyle] and not in a layout.
///
/// `DabblerTypeStyle.resolveForDirection` maps [TextDirection.rtl] to
/// [DabblerTypeScript.arabic], which changes the family **and** the leading:
/// Arabic ascenders and descenders need more line box than the Latin step
/// allows. Both are read live below, so the readout cannot drift from the
/// ramp.
class _TypeBand extends StatelessWidget {
  const _TypeBand();

  /// A Latin and an Arabic run, so each side shows its own script rendered in
  /// the face that side resolves to.
  static const String _latin = 'Saturday five-a-side, two places left';
  static const String _arabic = 'مباراة السبت، مكانان متبقيان';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const GallerySectionLabel('5 · The type layer forks by script'),
        const SizedBox(height: DabblerSpacing.space2),
        const GalleryUsage(
          '**`dabbler_type.dart:456`.** `resolveForDirection` is not a '
          'direction switch on layout — it picks a **script**, and the Arabic '
          'script resolves a different family and a different leading, because '
          'Arabic ascenders and descenders need more line box than the Latin '
          'step allows. The two readouts below are read from the live ramp at '
          'the body step, not transcribed. Note what this does **not** do: it '
          'does not translate. A specimen whose text stays English under RTL '
          'is behaving correctly — direction and language are separate axes.',
        ),
        const SizedBox(height: DabblerSpacing.space4),
        Wrap(
          spacing: DabblerSpacing.space6,
          runSpacing: DabblerSpacing.space6,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: <Widget>[
            for (final TextDirection direction in TextDirection.values)
              _Side(
                direction: direction,
                child: _TypeReadout(direction: direction),
              ),
          ],
        ),
      ],
    );
  }
}

/// The body step as it resolves for one direction, plus what it renders.
class _TypeReadout extends StatelessWidget {
  const _TypeReadout({required this.direction});

  final TextDirection direction;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextStyle body = DabblerType.body.resolveForDirection(direction);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          _TypeBand._latin,
          style: body.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: DabblerSpacing.space2),
        Text(
          _TypeBand._arabic,
          style: body.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: DabblerSpacing.space3),
        // The family arrives package-qualified (`packages/<pkg>/<Family>`),
        // which is how Flutter addresses a bundled face and not a name a
        // reviewer needs to read. Only the face itself is the fact here.
        GalleryMono('family: ${_faceOf(body.fontFamily)}'),
        GalleryMono(
          'leading: ${((body.height ?? 1) * (body.fontSize ?? 0)).toStringAsFixed(1)}px',
        ),
      ],
    );
  }
}

/// The disclosure chevron beside the glyph name the direction selected.
///
/// The name is derived the same way [DabblerChevron] derives it, so the
/// readout states what is actually being drawn rather than a caption about it.
class _ChevronReadout extends StatelessWidget {
  const _ChevronReadout();

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);
    final String name =
        direction == TextDirection.rtl ? 'arrow-left' : 'arrow-right';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const DabblerChevron(),
        const SizedBox(width: DabblerSpacing.space3),
        GalleryMono(name),
      ],
    );
  }
}

/// The bare face name from a package-qualified `fontFamily`.
String _faceOf(String? family) {
  if (family == null) return '—';
  final int at = family.lastIndexOf('/');
  return at < 0 ? family : family.substring(at + 1);
}
