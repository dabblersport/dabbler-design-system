/// Gallery entries for the theme/brightness axis — the *comparison* specimen
/// (KAN-315, `DECISIONS.md` D-035(c), extending D-034(b)).
///
/// ## Why this page exists although a theme switcher already does
///
/// The gallery header carries a theme switcher and a brightness toggle
/// (KAN-285). Neither is a specimen of this axis, and D-035(c) says why:
///
/// > A control that changes state is not a specimen of that axis when the
/// > page's subject is the comparison.
///
/// A switcher *replaces*. This page's subject is a **difference** — that the
/// paper ramp is shared by all seven themes while only the brand roles
/// re-tint — and a difference is not visible one state at a time. However
/// carefully a reviewer flips through fourteen palettes, "the card surface
/// never moved" is a memory claim, not something seen. Side by side it is one
/// glance.
///
/// So every cell below is rendered under its **own** resolved
/// `(theme, brightness)` pair, adjacent to the others, and none of them
/// follows the header's switcher. That is the whole point of the page.
///
/// ## What is asserted, and where
///
/// `test/tokens/dabbler_colors_test.dart` already encodes exactly what may and
/// may not vary: over all 21 unordered theme pairs at each brightness it
/// asserts thirteen paper roles *identical* (`bgPrimary`, `bgSecondary`,
/// `bgTertiary`, `surfaceCard`, `surfaceSunken`, `surfaceGrey`, `textPrimary`,
/// `textSecondary`, `textTertiary`, `borderDefault`, `borderStrong`, `scrim`,
/// `spotlight`) and the brand roles *different* (`brandPrimary`, `accent`,
/// `focusRing`). This page is the visual form of that same statement: [_shared]
/// draws the roles that test pins identical, [_retinted] the ones it pins
/// different, and [_component] shows what the two together do to a real
/// control.
///
/// The hexes are read from the live resolution, never transcribed, so the page
/// cannot drift from the tokens the way a typed table would.
///
/// ## How a cell renders in a theme that is not the page's
///
/// [DabblerColors] travels as a [ThemeExtension], so a subtree renders under a
/// different palette by installing a different [ThemeData] over it —
/// `galleryTheme(theme, brightness)`, the same builder the gallery app uses
/// for the whole app. `material.dart` is imported for [Theme] alone, which is
/// the extension's carrier and a mechanism, not an appearance (D-017). Nothing
/// here reads a Material value for paint.
///
/// A cell also reinstalls the page's [DefaultTextStyle] from *its own*
/// resolution: a dark-brightness cell sitting on the light page would
/// otherwise inherit the page's dark ink and paint it on dark paper.
library;

// `material.dart` for [Theme] and [ThemeData] only — the carrier the
// [DabblerColors] extension travels in. D-017.
import 'package:flutter/material.dart' show Theme, ThemeData;
import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../gallery/gallery_app.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_page.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/surface.dart';
import 'dabbler_colors.dart';
import 'dabbler_geometry.dart';
import 'dabbler_type.dart';

/// The theme/brightness comparison specimens.
const List<GalleryEntry> themesGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'themes/palettes',
    page: 'foundations/themes',
    group: null,
    title: 'Themes — one control across all fourteen palettes',
    description: 'The same card rendered simultaneously under seven themes at '
        'both brightnesses. Not the header switcher: every cell holds its own '
        'palette at once.',
    builder: _component,
  ),
  GalleryEntry(
    id: 'themes/paper',
    page: 'foundations/themes',
    group: null,
    title: 'Themes — paper shared, brand retinted',
    description: 'The invariant as hex, read live: thirteen paper roles '
        'identical down every row, three brand roles different in every cell.',
    builder: _invariant,
  ),
];

/// The seven themes, in declaration order.
const List<DabblerTheme> _themes = DabblerTheme.values;

/// A cell's width. Seven across a wide review window, reflowing below that.
const double _cellWidth = 196;

// --- Entry 1 — the component grid ---------------------------------------

Widget _component(BuildContext context) {
  return GallerySections(
    children: <Widget>[
      const GalleryUsage(
        '**One component, fourteen palettes, all at once.** Each cell installs '
        'its own `(theme, brightness)` resolution, so none of them follows the '
        'switcher in the page header. Read across a row: the card surface, the '
        'ink, the hairline and the neutral button never move — only the filled '
        'button, the link-coloured label and the focus tint retint. Read down '
        'a column: that is the same theme at the other brightness.',
      ),
      for (final Brightness brightness in Brightness.values)
        GalleryGroup(
          name: brightness == Brightness.light ? 'Light' : 'Dark',
          children: <Widget>[
            for (final DabblerTheme theme in _themes)
              _ThemeCell(
                theme: theme,
                brightness: brightness,
                child: const _Specimen(),
              ),
          ],
        ),
    ],
  );
}

/// The thing every cell draws: a card carrying one brand-painted control, one
/// paper-painted control, body ink and a hairline.
///
/// Deliberately small and deliberately mixed. A cell holding only a primary
/// button would show the brand moving and say nothing about the paper; a cell
/// holding only text would show the reverse. The invariant is a statement
/// about *both halves at the same time*, so the specimen carries both.
class _Specimen extends StatelessWidget {
  const _Specimen();

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return DabblerSurface.card(
      padding: const EdgeInsets.all(DabblerSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Saturday five-a-side',
            style: DabblerType.callout
                .resolveForDirection(direction)
                .copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: DabblerSpacing.space1),
          Text(
            'Two places left',
            style: DabblerType.caption1
                .resolveForDirection(direction)
                .copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: DabblerSpacing.space3),
          const GalleryRule(),
          const SizedBox(height: DabblerSpacing.space3),
          Wrap(
            spacing: DabblerSpacing.space2,
            runSpacing: DabblerSpacing.space2,
            children: const <Widget>[
              DabblerButton(
                label: 'Join',
                size: DabblerButtonSize.small,
              ),
              DabblerButton(
                label: 'Details',
                tone: DabblerButtonTone.outlined,
                size: DabblerButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Entry 2 — the invariant as hex --------------------------------------

Widget _invariant(BuildContext context) {
  return GallerySections(
    ruled: true,
    children: <Widget>[
      const GalleryUsage(
        '**The same statement `test/tokens/dabbler_colors_test.dart` makes, '
        'drawn.** That suite walks all 21 unordered theme pairs at each '
        'brightness and asserts thirteen paper roles equal and the brand roles '
        'unequal. Below, every swatch is read from the live '
        '`DabblerColors.resolve` — a hex here cannot drift from the token the '
        'way a transcribed table would.',
      ),
      for (final Brightness brightness in Brightness.values) ...<Widget>[
        _shared(brightness),
        _retinted(brightness),
      ],
    ],
  );
}

/// The roles the test pins identical across every pair of themes.
Widget _shared(Brightness brightness) {
  return _RoleTable(
    name: '${_brightnessName(brightness)} — paper: identical across all seven',
    brightness: brightness,
    usage: 'Every hex repeats seven times. That repetition is the invariant: '
        'a theme is a **brand**, not a skin, so a card, a page, an ink and a '
        'hairline are the same pixels in `sport` as in `shade`.',
    roles: const <_Role>[
      _Role('bgPrimary', _bgPrimary),
      _Role('bgSecondary', _bgSecondary),
      _Role('bgTertiary', _bgTertiary),
      _Role('surfaceCard', _surfaceCard),
      _Role('surfaceSunken', _surfaceSunken),
      _Role('surfaceGrey', _surfaceGrey),
      _Role('textPrimary', _textPrimary),
      _Role('textSecondary', _textSecondary),
      _Role('textTertiary', _textTertiary),
      _Role('borderDefault', _borderDefault),
      _Role('borderStrong', _borderStrong),
      _Role('spotlight', _spotlight),
    ],
  );
}

/// The roles the test pins different for every pair of themes.
Widget _retinted(Brightness brightness) {
  return _RoleTable(
    name: '${_brightnessName(brightness)} — brand: different in every theme',
    brightness: brightness,
    usage: 'No hex repeats along a row. These three roles are the entire '
        'difference between one theme and another — `brandPrimary` fills the '
        'primary button, `accent` the secondary, `focusRing` the focus '
        'indicator.',
    roles: const <_Role>[
      _Role('brandPrimary', _brandPrimary),
      _Role('accent', _accent),
      _Role('focusRing', _focusRing),
    ],
  );
}

String _brightnessName(Brightness brightness) =>
    brightness == Brightness.light ? 'Light' : 'Dark';

/// One named role and the accessor that reads it off a resolution.
///
/// A record of `(name, getter)` rather than a switch on a string, so a role
/// named here that does not exist is a compile error.
class _Role {
  const _Role(this.name, this.read);

  final String name;
  final Color Function(DabblerColors colors) read;
}

// Top-level accessors, so the `_Role` list can stay `const`.
Color _bgPrimary(DabblerColors c) => c.bgPrimary;
Color _bgSecondary(DabblerColors c) => c.bgSecondary;
Color _bgTertiary(DabblerColors c) => c.bgTertiary;
Color _surfaceCard(DabblerColors c) => c.surfaceCard;
Color _surfaceSunken(DabblerColors c) => c.surfaceSunken;
Color _surfaceGrey(DabblerColors c) => c.surfaceGrey;
Color _textPrimary(DabblerColors c) => c.textPrimary;
Color _textSecondary(DabblerColors c) => c.textSecondary;
Color _textTertiary(DabblerColors c) => c.textTertiary;
Color _borderDefault(DabblerColors c) => c.borderDefault;
Color _borderStrong(DabblerColors c) => c.borderStrong;
Color _spotlight(DabblerColors c) => c.spotlight;
Color _brandPrimary(DabblerColors c) => c.brandPrimary;
Color _accent(DabblerColors c) => c.accent;
Color _focusRing(DabblerColors c) => c.focusRing;

/// A band of roles as rows, with the seven themes as columns.
class _RoleTable extends StatelessWidget {
  const _RoleTable({
    required this.name,
    required this.brightness,
    required this.usage,
    required this.roles,
  });

  final String name;
  final Brightness brightness;
  final String usage;
  final List<_Role> roles;

  /// The label gutter. Wide enough for `textSecondary` at footnote size.
  static const double _labelWidth = 118;

  /// One theme's column.
  static const double _columnWidth = 84;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GallerySectionLabel(name),
        const SizedBox(height: DabblerSpacing.space2),
        GalleryUsage(usage),
        const SizedBox(height: DabblerSpacing.space4),
        // The table is wider than a phone; the page scrolls vertically, so
        // this axis gets its own scroller rather than shrinking the swatches
        // to where a hex is unreadable.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _header(context),
              const SizedBox(height: DabblerSpacing.space2),
              for (final _Role role in roles) ...<Widget>[
                _row(context, role),
                const SizedBox(height: DabblerSpacing.space2),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const SizedBox(width: _labelWidth),
        for (final DabblerTheme theme in _themes)
          SizedBox(
            width: _columnWidth,
            child: GalleryMono(theme.name),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, _Role role) {
    final DabblerColors pageColors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: _labelWidth,
          child: Text(
            role.name,
            style: DabblerType.footnote
                .resolveForDirection(direction)
                .copyWith(color: pageColors.textPrimary),
          ),
        ),
        for (final DabblerTheme theme in _themes)
          SizedBox(
            width: _columnWidth,
            child: _Swatch(
              color: role.read(
                DabblerColors.resolve(theme: theme, brightness: brightness),
              ),
            ),
          ),
      ],
    );
  }
}

/// A colour chip over its hex, drawn in the *page's* ink so the reading is
/// legible whichever brightness the row is describing.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final DabblerColors pageColors = DabblerColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: _RoleTable._columnWidth - DabblerSpacing.space3,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: pageColors.borderDefault),
            borderRadius: DabblerRadius.smAll,
          ),
        ),
        const SizedBox(height: DabblerSpacing.space1),
        GalleryMono(_hex(color)),
      ],
    );
  }
}

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

// --- The adjacency mechanism ---------------------------------------------

/// One labelled cell rendered under its own `(theme, brightness)`.
///
/// This is what makes the page a comparison rather than a control: the
/// resolution is installed here, per cell, instead of being read from the
/// gallery's [GalleryAppearance].
class _ThemeCell extends StatelessWidget {
  const _ThemeCell({
    required this.theme,
    required this.brightness,
    required this.child,
  });

  final DabblerTheme theme;
  final Brightness brightness;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData data = galleryTheme(theme, brightness);
    return SizedBox(
      width: _cellWidth,
      child: GallerySpecimen(
        label: '${theme.name} · ${_brightnessName(brightness)}',
        child: Theme(
          data: data,
          child: Builder(
            builder: (BuildContext inner) {
              final DabblerColors colors = DabblerColors.of(inner);
              // The cell paints its own paper under the specimen, because the
              // point of a dark cell on a light page is that its paper is
              // visibly the *other* paper — and reinstalls the text style from
              // its own resolution, since the page's inherited ink belongs to
              // the page's brightness.
              return DefaultTextStyle(
                style: galleryTextStyle(inner),
                child: Container(
                  padding: const EdgeInsets.all(DabblerSpacing.space3),
                  decoration: BoxDecoration(
                    color: colors.bgPrimary,
                    borderRadius: DabblerRadius.lgAll,
                  ),
                  child: child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
