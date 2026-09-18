/// Gallery entries for [DabblerSpacing], [DabblerRadius], [DabblerSizing] and
/// [DabblerElevation] — the spacing & geometry token specimen (KAN-300,
/// `DECISIONS.md` D-034(b)).
///
/// ## What is compared against what
///
/// `guidelines/spacing-scale.html` and `guidelines/radius-scale.html` are
/// marked *"source-only — consolidated into `guidelines/measurements.html`"*
/// in their own header comments, so **`measurements.html` is the live page**
/// and the two named in the ticket are its ancestors. Everything below is
/// replicated from the consolidated page, which draws all eleven spacing steps
/// rather than the eight the older standalone page showed.
///
/// | design source | here |
/// |---|---|
/// | §Spacing — a `token / value / bar` table, one row per `--space-N`, bar width **= the value in px** | [_spacing] |
/// | §Spacing — the six semantic aliases and what each resolves to | [_spacing] |
/// | §Radius — six 88×62 tiles, brand at 14% on white with a 1px brand border, mono caption below | [_radius] |
/// | §Radius — the `token / value / documented application` table | [_radius] |
/// | §Borders & strokes — `--border-default` 1px, `--border-hairline` 0.5px | [_sizing] |
/// | §Touch targets — the 45×45 dashed target | [_sizing] |
/// | §Icon sizes — 18 / 24 / 30 brand squares with mono captions | [_sizing] |
/// | §Borders & strokes — *"Shadows: none"*, `--elevation-2` the one exception | [_elevation] |
///
/// ## The one place this specimen is AHEAD of the page it replicates
///
/// **`DabblerRadius.card` (16) is drawn here and `measurements.html` does not
/// draw it.** That is not a divergence to fix on this ticket: `cxo` ruling
/// **D-018** added the step after counting nine of nine card shells in the
/// design source drawing 16 and none drawing 12, `KAN-273` landed it in this
/// package, and the matching design-source amendment is `KAN-261`, which has
/// not run. So the source page still shows a six-step ramp whose `lg` is
/// annotated *"cards, icon tiles"* — the exact conflation D-018 settled.
///
/// This specimen is where that distinction has to be visible (KAN-300 AC3), so
/// it draws **both corners on one nested figure**: a card at 16 with a tile
/// inside it at 12. A well and its containing card sharing a corner is the
/// real bug D-018 was fixing — they read as one surface.
library;

import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_page.dart';
import '../gallery/gallery_specimen.dart';
import 'dabbler_colors.dart';
import 'dabbler_geometry.dart';
import 'dabbler_type.dart';

/// The geometry token specimens.
const List<GalleryEntry> geometryGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'spacing-geometry/spacing',
    page: 'foundations/spacing-geometry',
    group: null,
    title: 'Spacing — the base-3 scale and its aliases',
    description: 'All eleven steps drawn at their literal pixel width, then '
        'the six semantic aliases and the step each one IS.',
    builder: _spacing,
  ),
  GalleryEntry(
    id: 'spacing-geometry/radius',
    page: 'foundations/spacing-geometry',
    group: null,
    title: 'Radius — the ramp, and the 16-versus-12 card corner',
    description: 'Seven steps including D-018\'s 16px card corner, then the '
        'nested figure that shows why 16 and 12 are different corners.',
    builder: _radius,
  ),
  GalleryEntry(
    id: 'spacing-geometry/sizing',
    page: 'foundations/spacing-geometry',
    group: null,
    title: 'Sizing — touch target, borders, icon sizes',
    description: 'The 45px floor, the two stroke widths at real thickness, '
        'and the three icon sizes.',
    builder: _sizing,
  ),
  GalleryEntry(
    id: 'spacing-geometry/elevation',
    page: 'foundations/spacing-geometry',
    group: null,
    title: 'Elevation — the no-shadow law and its one exception',
    description: 'Flat by default. --elevation-2 is the only legal shadow and '
        'is reserved for Dialog.',
    builder: _elevation,
  ),
];

/// The eleven steps with the token name `measurements.html` prints beside each.
const List<(String, double)> _spacingSteps = <(String, double)>[
  ('--space-1', DabblerSpacing.space1),
  ('--space-2', DabblerSpacing.space2),
  ('--space-3', DabblerSpacing.space3),
  ('--space-4', DabblerSpacing.space4),
  ('--space-5', DabblerSpacing.space5),
  ('--space-6', DabblerSpacing.space6),
  ('--space-7', DabblerSpacing.space7),
  ('--space-8', DabblerSpacing.space8),
  ('--space-9', DabblerSpacing.space9),
  ('--space-10', DabblerSpacing.space10),
  ('--space-11', DabblerSpacing.space11),
];

/// The six aliases, each with the step it resolves to and the role the source
/// page gives it.
const List<(String, String, double, String)> _spacingAliases =
    <(String, String, double, String)>[
  (
    '--card-padding',
    '--space-6',
    DabblerSpacing.cardPadding,
    'padding inside a card',
  ),
  (
    '--screen-gutter',
    '--space-8',
    DabblerSpacing.screenGutter,
    'screen edge gutter',
  ),
  (
    '--section-gap',
    '--space-9',
    DabblerSpacing.sectionGap,
    'gap between sections',
  ),
  (
    '--stack-default',
    '--space-4',
    DabblerSpacing.stackDefault,
    'default vertical stack gap',
  ),
  ('--stack-tight', '--space-2', DabblerSpacing.stackTight, 'tight stack gap'),
  ('--icon-gap', '--space-2', DabblerSpacing.iconGap, 'icon → label gap'),
];

Widget _spacing(BuildContext context) => GalleryStack(
      children: <Widget>[
        const GalleryUsage(
          '**Every dimension comes off a base-3 grid** — 3 · 6 · 9 · 12 · 15 · '
          '18 · 21 · 24 · 30 · 36 · 48. *"Prefer 12 / 24 / 30 / 36 / 48 for '
          'structural values"* (`measurements.html`): they are multiples of '
          'both 3 and 4, so they line up with 24px icons and with platform '
          'components. Each bar below is drawn at **its own value in logical '
          'pixels**, the way the source page draws it — the bar IS the token.',
        ),
        GalleryGroup(
          name: 'The scale',
          wrap: false,
          children: <Widget>[
            for (final (String token, double value) in _spacingSteps)
              _ScaleRow(token: token, value: value),
          ],
        ),
        const GalleryUsage(
          '**Reach for the semantic alias when one exists** — it carries the '
          'intent, and changing the alias changes every consumer. Each alias '
          '**is** a step of the scale, never a new value.',
        ),
        GalleryGroup(
          name: 'Semantic aliases',
          wrap: false,
          children: <Widget>[
            for (final (String alias, String step, double value, String role)
                in _spacingAliases)
              _AliasRow(alias: alias, step: step, value: value, role: role),
          ],
        ),
      ],
    );

/// The radius ramp with the role `measurements.html` documents for each step.
///
/// [DabblerRadius.card] carries no source-page row of its own — see the
/// library dartdoc — so its role text is D-018's own wording.
const List<(String, double, String)> _radiusSteps = <(String, double, String)>[
  ('sm', DabblerRadius.sm, 'chips, small inputs · Tooltip, Skeleton default'),
  ('md', DabblerRadius.md, 'buttons · Menu item icon tiles'),
  (
    'lg',
    DabblerRadius.lg,
    'the corner of a tile INSIDE a card · Banner, Toast, CodeInput boxes, Menu',
  ),
  ('card', DabblerRadius.card, 'the card shell itself — D-018, not base-3'),
  ('xl', DabblerRadius.xl, 'sheets and modals · Sheet top corners, Dialog'),
  ('xxl', DabblerRadius.xxl, 'text fields and search · every FieldShell'),
  (
    'pill',
    DabblerRadius.pill,
    'pills and avatars · Badge, Chip, Avatar, nav pill, progress track',
  ),
];

Widget _radius(BuildContext context) => GalleryStack(
      children: <Widget>[
        const GalleryUsage(
          '**Rounded and generous.** Seven steps: `sm` 6 · `md` 9 · `lg` 12 · '
          '**`card` 16** · `xl` 18 · `xxl` 24 · `pill` 999. A component that '
          'needs a corner picks the token whose *role* it matches rather than '
          'a new value.',
        ),
        GalleryWrap(
          children: <Widget>[
            for (final (String name, double value, _) in _radiusSteps)
              _RadiusTile(name: name, value: value),
          ],
        ),
        GalleryGroup(
          name: 'Documented application',
          wrap: false,
          children: <Widget>[
            for (final (String name, double value, String role) in _radiusSteps)
              _RadiusRow(name: name, value: value, role: role),
          ],
        ),
        const GalleryUsage(
          '**16 and 12 are two different corners, and this is the specimen '
          'that has to show it.** `cxo` ruling **D-018**: all nine top-level '
          'card shells in the design source draw `borderRadius: 16` and not '
          'one draws 12, while `--radius-lg` (12) is the corner of a tile '
          '*inside* a card. `CardHouse.jsx` draws both, in the same file — 16 '
          'at `:9` for the shell and 12 at `:36` for the icon tile. Where a '
          'comment and nine drawings disagree, the drawings are the design '
          'system.',
        ),
        const GallerySpecimen(
          label: 'card 16 outside, lg 12 inside — the nesting D-018 fixes',
          child: _NestedCorners(),
        ),
        const GalleryUsage(
          '**What the wrong version looks like** is the right-hand figure: a '
          'well and its containing card sharing one corner value read as a '
          'single surface, and the nesting disappears. That was a real bug, '
          'not a theoretical one. `--radius-xl` (18) was considered instead of '
          '16 — it is base-3 — and rejected, because 18 is the corner sheets '
          'and modals draw and snapping the specimen\'s 16 onto it is a '
          'visible change.',
        ),
      ],
    );

Widget _sizing(BuildContext context) => GalleryStack(
      children: <Widget>[
        const GalleryUsage(
          '**45×45 is the minimum interactive size** — base-3, and it clears '
          'Apple\'s 44pt floor. *"Every interactive element clears 45px and '
          'uses the shared focus ring and press scale — no component invents '
          'its own"* (`measurements.html`).',
        ),
        const GalleryWrap(
          children: <Widget>[
            GallerySpecimen(
              label: '--touch-target-min · 45px',
              child: _TouchTarget(),
            ),
          ],
        ),
        const GalleryUsage(
          '**Every surface is an opaque fill plus a 1px solid hairline.** '
          '`--border-default` is the standard line; `--border-hairline` (0.5) '
          'is the sub-pixel form. Both are drawn below at their real '
          'thickness, which is the only way to tell them apart.',
        ),
        GalleryWrap(
          children: <Widget>[
            for (final (String token, double width) in <(String, double)>[
              ('--border-default', DabblerSizing.borderDefault),
              ('--border-hairline', DabblerSizing.borderHairline),
            ])
              GallerySpecimen(
                label: '$token · ${_trim(width)}px',
                child: _StrokeSample(width: width),
              ),
          ],
        ),
        const GalleryUsage(
          '**24px is the native Iconsax grid**, and the reason the structural '
          'spacing values are multiples of 4 as well as 3. `Icon` and '
          '`SportIcon` both default to 24. Avatar sizes are a component-level '
          'scale documented with `Avatar`, not a global token.',
        ),
        GalleryWrap(
          children: <Widget>[
            for (final (String name, double size) in <(String, double)>[
              ('--icon-sm', DabblerSizing.iconSm),
              ('--icon-md', DabblerSizing.iconMd),
              ('--icon-lg', DabblerSizing.iconLg),
            ])
              GallerySpecimen(
                label: '$name · ${_trim(size)}',
                child: _IconSquare(size: size),
              ),
          ],
        ),
      ],
    );

Widget _elevation(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return GalleryStack(
    children: <Widget>[
      const GalleryUsage(
        '**Shadows: none.** `--elevation-0` and `--elevation-1` are both '
        'literally `none` in the source, and are exposed here as the empty '
        'shadow list so a caller reaching for "elevation" still gets '
        'flatness. *"Separation comes from fill steps and the hairline, never '
        'blur or shadow"* (`measurements.html`).',
      ),
      GalleryWrap(
        children: <Widget>[
          GallerySpecimen(
            label: 'DabblerElevation.none — []',
            child: _Panel(shadows: DabblerElevation.none, colors: colors),
          ),
          GallerySpecimen(
            label: 'DabblerElevation.flat — []',
            child: _Panel(shadows: DabblerElevation.flat, colors: colors),
          ),
          GallerySpecimen(
            label: 'dialogFor(${colors.brightness.name}) — Dialog ONLY',
            child: _Panel(
              shadows: DabblerElevation.dialogFor(colors.brightness),
              colors: colors,
            ),
          ),
        ],
      ),
      const GalleryUsage(
        '**`--elevation-2` is the one legal shadow and it is reserved for '
        '`Dialog`.** No other component in the cut may reference it — the FAB '
        'keeps its own separately documented shadow exception from the source '
        'kit and does not draw on this token either. It is also the one '
        'geometry value that differs between modes, because the source '
        'redeclares it under `[data-mode="dark"]`; switch brightness above and '
        'the third panel changes.',
      ),
    ],
  );
}

/// One row of the spacing scale: the token, the bar at its own width, and the
/// value — the three columns `measurements.html` prints.
class _ScaleRow extends StatelessWidget {
  const _ScaleRow({required this.token, required this.value});

  final String token;
  final double value;

  /// Wide enough for `--space-11` without the bars reflowing between rows.
  static const double _tokenColumn = 96;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: DabblerSpacing.space2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: _tokenColumn, child: GalleryMono(token)),
          // `.bar{height:12px;border-radius:3px}`, width = the token's value.
          Container(
            width: value,
            height: DabblerSpacing.space4,
            decoration: BoxDecoration(
              color: colors.brandPrimary,
              borderRadius: const BorderRadius.all(
                Radius.circular(DabblerSpacing.space1),
              ),
            ),
          ),
          const SizedBox(width: DabblerSpacing.space4),
          GalleryMono('${_trim(value)}px'),
        ],
      ),
    );
  }
}

/// One alias row: the alias, the step it resolves to, and its role.
class _AliasRow extends StatelessWidget {
  const _AliasRow({
    required this.alias,
    required this.step,
    required this.value,
    required this.role,
  });

  final String alias;
  final String step;
  final double value;
  final String role;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: DabblerSpacing.space2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(width: 0),
          SizedBox(width: 132, child: GalleryMono(alias)),
          SizedBox(
            width: 132,
            child: GalleryMono('$step · ${_trim(value)}px'),
          ),
          Text(
            role,
            style: DabblerType.caption1
                .resolveForDirection(Directionality.of(context))
                .copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// `.rd{width:88px;height:62px;background:color-mix(brand 14%, white);
/// border:1px solid brand}` with the source's mono caption below.
class _RadiusTile extends StatelessWidget {
  const _RadiusTile({required this.name, required this.value});

  final String name;
  final double value;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    // `pill` is drawn as a 62-wide square on the source page so the fully
    // rounded corner reads as a circle rather than a stadium.
    final bool pill = value >= DabblerRadius.pill;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: pill ? 62 : 88,
          height: 62,
          decoration: BoxDecoration(
            // `color-mix(in srgb, brand 14%, white)`.
            color: Color.lerp(colors.surfaceCard, colors.brandPrimary, 0.14),
            border: Border.all(color: colors.brandPrimary),
            borderRadius: BorderRadius.all(Radius.circular(value)),
          ),
        ),
        const SizedBox(height: DabblerSpacing.space2),
        GalleryMono(pill ? 'pill' : '$name · ${_trim(value)}px'),
      ],
    );
  }
}

/// One row of the radius application table.
class _RadiusRow extends StatelessWidget {
  const _RadiusRow({
    required this.name,
    required this.value,
    required this.role,
  });

  final String name;
  final double value;
  final String role;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    // The 16 step is the one with no row on the source page; mark it so a
    // reviewer comparing the two pages is not left wondering.
    final bool addedByRuling = value == DabblerRadius.card;
    return Padding(
      padding: const EdgeInsets.only(bottom: DabblerSpacing.space2),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: GalleryUsage.maxWidth),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 132,
              child: GalleryMono('DabblerRadius.$name · ${_trim(value)}'),
            ),
            Expanded(
              child: Text(
                addedByRuling ? '$role · not yet in spacing.css (KAN-261)'
                    : role,
                style: DabblerType.caption1
                    .resolveForDirection(Directionality.of(context))
                    .copyWith(
                      color: addedByRuling
                          ? colors.warning.strong
                          : colors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The D-018 figure: the right corner nesting beside the wrong one.
class _NestedCorners extends StatelessWidget {
  const _NestedCorners();

  @override
  Widget build(BuildContext context) => const GalleryWrap(
        children: <Widget>[
          GallerySpecimen(
            label: 'CORRECT — shell 16, inner tile 12',
            child: _CardWithTile(shell: DabblerRadius.card),
          ),
          GallerySpecimen(
            label: 'WRONG — shell 12, inner tile 12',
            child: _CardWithTile(shell: DabblerRadius.lg),
          ),
        ],
      );
}

/// A card shell at [shell] with a sunken tile at [DabblerRadius.lg] inside it.
class _CardWithTile extends StatelessWidget {
  const _CardWithTile({required this.shell});

  final double shell;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Container(
      width: 200,
      padding: const EdgeInsets.all(DabblerSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border.all(color: colors.borderDefault),
        borderRadius: BorderRadius.all(Radius.circular(shell)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GalleryMono('shell ${_trim(shell)}'),
          const SizedBox(height: DabblerSpacing.space3),
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              borderRadius: DabblerRadius.lgAll,
            ),
            alignment: Alignment.center,
            child: const GalleryMono('tile 12'),
          ),
        ],
      ),
    );
  }
}

/// `measurements.html`'s dashed 45×45 target.
///
/// Drawn with a real dashed stroke rather than a solid one, because that is
/// how the source distinguishes the *target* (a measurement) from the *card*
/// (a surface) sitting beside it in the same row.
class _TouchTarget extends StatelessWidget {
  const _TouchTarget();

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return SizedBox(
      width: DabblerSizing.touchTargetMin,
      height: DabblerSizing.touchTargetMin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.lerp(colors.surfaceCard, colors.brandPrimary, 0.14),
          borderRadius: DabblerRadius.mdAll,
        ),
        child: CustomPaint(painter: _DashedBorder(color: colors.brandPrimary)),
      ),
    );
  }
}

/// The dashed outline of the touch-target figure.
class _DashedBorder extends CustomPainter {
  const _DashedBorder({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const double dash = 4;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = DabblerSizing.borderDefault;
    final Path outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(DabblerRadius.md),
        ),
      );
    for (final PathMetric metric in outline.computeMetrics()) {
      double at = 0;
      while (at < metric.length) {
        canvas.drawPath(
          metric.extractPath(at, (at + dash).clamp(0, metric.length)),
          paint,
        );
        at += dash * 2;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder oldDelegate) => oldDelegate.color != color;
}

/// A short rule drawn at exactly [width], so 1 and 0.5 can be told apart.
class _StrokeSample extends StatelessWidget {
  const _StrokeSample({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return SizedBox(
      width: 132,
      height: DabblerSpacing.space4,
      child: Center(
        child: SizedBox(
          height: width,
          child: ColoredBox(color: colors.borderStrong),
        ),
      ),
    );
  }
}

/// `measurements.html`'s icon-size figure: a brand square at the token's size.
class _IconSquare extends StatelessWidget {
  const _IconSquare({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return SizedBox(
      width: DabblerSizing.iconLg,
      height: DabblerSizing.iconLg,
      child: Align(
        alignment: AlignmentDirectional.bottomStart,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.brandPrimary,
            borderRadius: const BorderRadius.all(
              Radius.circular(DabblerSpacing.space1),
            ),
          ),
        ),
      ),
    );
  }
}

/// A card-sized panel carrying [shadows], for the elevation row.
class _Panel extends StatelessWidget {
  const _Panel({required this.shadows, required this.colors});

  final List<BoxShadow> shadows;
  final DabblerColors colors;

  @override
  Widget build(BuildContext context) => Container(
        width: 132,
        height: 76,
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          border: Border.all(color: colors.borderDefault),
          borderRadius: DabblerRadius.cardAll,
          boxShadow: shadows,
        ),
      );
}

/// `24.0` reads as `24`, `0.5` stays `0.5` — the source page prints integers.
String _trim(double value) =>
    value == value.roundToDouble() ? '${value.toInt()}' : '$value';
