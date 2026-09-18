/// Gallery entries for [DabblerType] — the type token specimen (KAN-299,
/// `DECISIONS.md` D-034(b)).
///
/// ## What is compared against what
///
/// The source is `guidelines/typography.html`, and this file replicates its
/// three load-bearing figures rather than its whole twenty-section prose page
/// (the prose belongs to the Foundations documentation page this specimen
/// unblocks, not to the specimen).
///
/// | design source | here |
/// |---|---|
/// | §Font families — four cards, each setting its own face at 32px with a mono provenance line | [_faces] |
/// | §The complete type scale — a two-column English/Arabic grid, every style set in itself | [_scale] |
/// | §The complete type scale — the `class / role / size / leading (Latin) / leading (Arabic) / weight` table | [_scale] |
/// | §Weights — 400/500/600/700 in both faces, and which classes use each | [_weights] |
/// | §Numerals — Western digits in both scripts, never Arabic-Indic | [_scale] |
///
/// The source's own samples are used verbatim — *"Body — book a slot, invite
/// friends."*, *"النص الأساسي — احجز ملعبك وادعُ أصدقاءك."* and the rest —
/// because a specimen that substitutes lorem loses the thing the design page
/// is actually demonstrating: that the two scripts read at matching optical
/// weight at the same size.
///
/// ## D-024 is visible here, not hidden — the ONE trap in this ticket
///
/// `DabblerButton` sets its label at **16 / 14 / 12, all at weight 600**
/// (`button.dart:365-374`). Those three values are **not steps of this ramp**
/// and are drawn below in their own band, under the heading that says so.
///
/// `cxo` ruling **D-024** is why. The design system has *three* ways of
/// specifying type across its 79 source components — 30 on `.t-*` from
/// `tokens/typography.css`, 13 on `--font-size-*` from
/// `tokens/figma/fig-tokens.css`, and 25 on raw inline literals — and the
/// first two are **different ramps, not two spellings of one**:
/// `typography.css` is HIG-shaped with `--type-body: 16` and **contains no 14
/// at all**, while the Figma file's body size *is* 14. `Button.jsx:22` is a
/// transcription from the second. D-024(c) extended `D-004` to type and made
/// `tokens/typography.css` the **sole** type source of truth, with
/// `fig-tokens.css` an export artefact that is never transcribed from.
///
/// So presenting 16/14/12-at-600 as ramp steps would do two wrong things at
/// once: invent three entries D-024 explicitly refused, and hide the split
/// that is still an open question. Drawing them labelled as outside the ramp
/// is the only honest rendering, and it is what KAN-299 AC2 asks for.
///
/// **A second thing the source page says that the code contradicts, reported
/// rather than smoothed over:** `typography.html` §Typography & components
/// lists `.t-label` as *"`Button` label text"*. It is not — `DabblerButton`
/// takes `.t-label`'s **role** (sans) and overrides its metrics, exactly as
/// D-024 ruled correct, and D-024(d) found `.t-label` has **zero** consumers
/// in the design source. The ramp band below still draws `label`, because it
/// is a declared step of `typography.css`; the usage claim is not repeated.
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_page.dart';
import '../gallery/gallery_specimen.dart';
import 'dabbler_colors.dart';
import 'dabbler_geometry.dart';
import 'dabbler_type.dart';

/// The type token specimens.
const List<GalleryEntry> typeGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'type/faces',
    page: 'foundations/type',
    group: null,
    title: 'Type — the four faces',
    description: 'Gloock, Wingx, Glory and Meral Sans, each set in itself, '
        'with its coverage and its provenance.',
    builder: _faces,
  ),
  GalleryEntry(
    id: 'type/ramp',
    page: 'foundations/type',
    group: null,
    title: 'Type — the complete ramp, Latin and Arabic',
    description: 'All twelve declared styles side by side in both scripts, '
        'each labelled with its size, leading and weight.',
    builder: _scale,
  ),
  GalleryEntry(
    id: 'type/weights',
    page: 'foundations/type',
    group: null,
    title: 'Type — weights, and the values outside the ramp',
    description: 'The five weight tokens, then Button\'s 16/14/12-at-600 '
        'shown as what D-024 says it is: a second ramp, not three steps.',
    builder: _weights,
  ),
];

/// The four faces, with the coverage table's own verdicts.
const List<(String, DabblerTypeRole, DabblerTypeScript, String, String)>
    _faces_ = <(String, DabblerTypeRole, DabblerTypeScript, String, String)>[
  (
    'Gloock',
    DabblerTypeRole.display,
    DabblerTypeScript.latin,
    '--font-display-en · Latin · weight 400 only · Google Fonts, OFL',
    'Arabic coverage: none',
  ),
  (
    'وينكس',
    DabblerTypeRole.display,
    DabblerTypeScript.arabic,
    '--font-display-ar · Wingx · Arabic-only · weight 400 only',
    'Latin coverage: none — falls back to a system serif',
  ),
  (
    'Glory',
    DabblerTypeRole.sans,
    DabblerTypeScript.latin,
    '--font-sans-en · Latin · weights 100–800 · Google Fonts, OFL',
    'Arabic coverage: none',
  ),
  (
    'ميرال سانس',
    DabblerTypeRole.sans,
    DabblerTypeScript.arabic,
    '--font-sans-ar · Meral Sans · Latin + Arabic · weights 100–900',
    'Latin coverage: yes',
  ),
];

Widget _faces(BuildContext context) => GalleryStack(
      children: <Widget>[
        const GalleryUsage(
          '**Four faces on two roles.** `--font-display` resolves to Gloock '
          '(Latin) or Wingx (Arabic); `--font-sans` to Glory or Meral Sans. '
          '**Coverage is strict:** Wingx must never be set on Latin text and '
          'Gloock/Glory must never be set on Arabic — the shaping breaks and '
          'the platform silently substitutes a system face. Going through the '
          'role tokens avoids this entirely, which is the reason the two role '
          'tokens exist rather than direct family references.',
        ),
        GalleryWrap(
          children: <Widget>[
            for (final (
                  String sample,
                  DabblerTypeRole role,
                  DabblerTypeScript script,
                  String provenance,
                  String coverage,
                ) in _faces_)
              _FaceCard(
                sample: sample,
                role: role,
                script: script,
                provenance: provenance,
                coverage: coverage,
              ),
          ],
        ),
      ],
    );

/// The source page's own sample string per style, Latin then Arabic.
const Map<String, (String, String)> _samples = <String, (String, String)>{
  'largeTitle': ('Large Title', 'عنوان كبير'),
  'title1': ('Title 1', 'عنوان أول'),
  'title2': ('Title 2', 'عنوان ثانٍ'),
  'title3': ('Title 3', 'عنوان ثالث'),
  'headline': ('Headline', 'عنوان فرعي'),
  'body': (
    'Body — book a slot, invite friends.',
    'النص الأساسي — احجز ملعبك وادعُ أصدقاءك.',
  ),
  'callout': (
    'Callout — Zayed Sports City, Court 3',
    'نص بارز — مدينة زايد الرياضية، ملعب 3',
  ),
  'subheadline': (
    'Subheadline — 8 players confirmed',
    'نص ثانوي — 8 لاعبين مؤكدين',
  ),
  'footnote': ('Footnote — updated 2 minutes ago', 'حاشية — آخر تحديث قبل دقيقتين'),
  'caption1': (
    'Caption 1 — skill level: intermediate',
    'تعليق أول — المستوى: متوسط',
  ),
  'caption2': ('Caption 2 — terms apply', 'تعليق ثانٍ — تُطبق الشروط'),
  'label': ('Label — JOIN GAME', 'زر — انضم للمباراة'),
};

Widget _scale(BuildContext context) => GalleryStack(
      children: <Widget>[
        const GalleryUsage(
          '**Eleven styles plus one button/label convenience.** '
          '**Arabic runs the SAME sizes as Latin at every step — there is no '
          'size bump.** Only four text styles take extra Arabic leading — '
          '`headline`, `body`, `callout`, `subheadline`. Titles, footnote and '
          'the captions inherit Latin\'s leading unchanged, and `.t-label` is '
          '*not* one of the four exceptions despite sharing headline\'s '
          'size. Do not assume symmetry across the scale.',
        ),
        GalleryGroup(
          name: 'The ramp — every declared step',
          wrap: false,
          children: <Widget>[
            for (final DabblerTypeStyle style in DabblerType.styles)
              _RampRow(style: style),
          ],
        ),
        const GalleryUsage(
          '**Line heights are set in fixed pixels, not unitless multipliers** '
          '— each style pins its own leading rather than inheriting a ratio, '
          'which is why the ratio is not constant down the ramp (1.21 at 34px, '
          '1.38 at 13px, 1.18 at 11px). Do not compute a new size by '
          'multiplying an existing leading ratio. **Tracking is 0 on every '
          'style in both scripts**, and Arabic tracking is never adjusted.',
        ),
        const GalleryUsage(
          '**Numerals are always Western Arabic (0–9) in both scripts, never '
          'Eastern Arabic-Indic (٠–٩).** Enforced twice: '
          '`DabblerType.numeralFeatures` disables the OpenType `anum` feature '
          'and pins lining figures on every resolved style, and '
          '`DabblerType.toWesternDigits` rewrites the string at the source. '
          'The Arabic callout and subheadline rows above carry digits, which '
          'is where to check it.',
        ),
      ],
    );

/// The five weight tokens with the source table's own "where it's used" text.
const List<(String, FontWeight, String)> _weights_ =
    <(String, FontWeight, String)>[
  ('--weight-light', DabblerType.light, 'not used by any current style'),
  (
    '--weight-regular',
    DabblerType.regular,
    'titles, body, subheadline, footnote, captions',
  ),
  ('--weight-medium', DabblerType.medium, 'callout, label'),
  ('--weight-semibold', DabblerType.semibold, 'headline only'),
  (
    '--weight-bold',
    DabblerType.bold,
    'not assigned to a current style; ad-hoc emphasis only',
  ),
];

Widget _weights(BuildContext context) => GalleryStack(
      children: <Widget>[
        const GalleryUsage(
          '**Gloock and Wingx each ship exactly one weight (400)** — every '
          'title-role style is 400 in both scripts; titles never run Light, '
          'and there is no bold title. Glory covers 100–800 and Meral Sans '
          '100–900, but the ramp itself only ever assigns 400 / 500 / 600.',
        ),
        GalleryGroup(
          name: 'Weights',
          wrap: false,
          children: <Widget>[
            for (final (String token, FontWeight weight, String usage)
                in _weights_)
              _WeightRow(token: token, weight: weight, usage: usage),
          ],
        ),
        const GalleryRule(),
        const GallerySectionLabel('Outside the ramp — D-024'),
        const SizedBox(height: DabblerSpacing.space3),
        const GalleryUsage(
          '**These are NOT steps of the ramp above.** `DabblerButton` sets its '
          'label at 16 / 14 / 12, all at weight 600 '
          '(`button.dart:365-374`). `tokens/typography.css` **contains no 14 '
          'at all**, and semibold appears in it only at `headline`\'s 17 — so '
          'none of these three is expressible as a ramp step, and `cxo` ruling '
          '**D-024** declined to add them: *"a ramp step earns its place by '
          'being a role the system names and several unrelated things reach '
          'for. Three entries justified by one component fail it."*',
        ),
        GalleryGroup(
          name: 'Button label scale — a second ramp, drawn for contrast only',
          wrap: false,
          children: <Widget>[
            for (final DabblerButtonSize size in DabblerButtonSize.values)
              _OffRampRow(size: size),
          ],
        ),
        const GalleryUsage(
          '**Where they come from.** D-024 measured the design source: 30 of '
          'its 79 components specify type with `.t-*` from '
          '`tokens/typography.css`, 13 with `--font-size-*` from '
          '`tokens/figma/fig-tokens.css`, and 25 with raw inline literals. The '
          '13 are a coherent family — cards, navigation and rooms — '
          'transcribed from the Figma export, **whose body size is 14**. '
          '`Button.jsx:22` is one of them. D-024(c) extended `D-004` to type: '
          '`tokens/typography.css` is the sole source of truth and '
          '`fig-tokens.css` is an export artefact, never transcribed from. '
          '**The question of what happens to the 13 is open**, which is '
          'exactly why this band is drawn rather than quietly folded into the '
          'ramp.',
        ),
      ],
    );

/// §Font families' card: the face set in itself, over its provenance lines.
class _FaceCard extends StatelessWidget {
  const _FaceCard({
    required this.sample,
    required this.role,
    required this.script,
    required this.provenance,
    required this.coverage,
  });

  final String sample;
  final DabblerTypeRole role;
  final DabblerTypeScript script;
  final String provenance;
  final String coverage;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool arabic = script == DabblerTypeScript.arabic;
    return Container(
      width: 300,
      padding: const EdgeInsets.all(DabblerSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border.all(color: colors.borderDefault),
        borderRadius: DabblerRadius.cardAll,
      ),
      child: Directionality(
        textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              sample,
              style: TextStyle(
                fontFamily: DabblerType.fontFamilyFor(role, script),
                fontFamilyFallback:
                    DabblerType.fontFamilyFallbackFor(role, script),
                fontSize: 32,
                fontWeight: role == DabblerTypeRole.sans
                    ? DabblerType.medium
                    : DabblerType.regular,
                color: colors.textPrimary,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: DabblerSpacing.space2),
            GalleryMono(provenance),
            const SizedBox(height: DabblerSpacing.space1),
            GalleryMono(coverage),
          ],
        ),
      ),
    );
  }
}

/// One ramp step: the spec, then the same step set in both scripts.
class _RampRow extends StatelessWidget {
  const _RampRow({required this.style});

  final DabblerTypeStyle style;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final (String latin, String arabic) = _samples[style.name]!;
    final String leading = style.takesArabicExtraLeading
        ? '${_n(style.latinLeading)} Latin / ${_n(style.arabicLeading)} Arabic'
        : '${_n(style.latinLeading)} both';

    return Padding(
      padding: const EdgeInsets.only(bottom: DabblerSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GalleryMono(
            '${style.name} · ${style.role.name} · ${_n(style.fontSize)}px · '
            'leading $leading · weight ${style.fontWeight.value}'
            '${style.takesArabicExtraLeading ? ' · Arabic takes extra leading' : ''}',
          ),
          const SizedBox(height: DabblerSpacing.space2),
          Wrap(
            spacing: DabblerSpacing.space8,
            runSpacing: DabblerSpacing.space3,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    latin,
                    style: style
                        .resolve(DabblerTypeScript.latin)
                        .copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    arabic,
                    style: style
                        .resolve(DabblerTypeScript.arabic)
                        .copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One weight row: the token set at that weight, in both faces, and its usage.
class _WeightRow extends StatelessWidget {
  const _WeightRow({
    required this.token,
    required this.weight,
    required this.usage,
  });

  final String token;
  final FontWeight weight;
  final String usage;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextStyle base = DabblerType.body
        .resolve(DabblerTypeScript.latin)
        .copyWith(fontWeight: weight, color: colors.textPrimary);
    return Padding(
      padding: const EdgeInsets.only(bottom: DabblerSpacing.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GalleryMono('$token · ${weight.value} · $usage'),
          const SizedBox(height: DabblerSpacing.space1),
          Wrap(
            spacing: DabblerSpacing.space8,
            children: <Widget>[
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text('Glory ${weight.value} — five-a-side', style: base),
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'ميرال سانس ${weight.value} — خمسة لاعبين',
                  style: DabblerType.body
                      .resolve(DabblerTypeScript.arabic)
                      .copyWith(fontWeight: weight, color: colors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One Button label size, drawn in the warning ink so it cannot be mistaken
/// for a ramp step even at a glance.
class _OffRampRow extends StatelessWidget {
  const _OffRampRow({required this.size});

  final DabblerButtonSize size;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double fontSize = DabblerButton.fontSizeFor(size);
    return Padding(
      padding: const EdgeInsets.only(bottom: DabblerSpacing.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GalleryMono(
            'DabblerButtonSize.${size.name} · ${_n(fontSize)}px · '
            'weight 600 · line-height ${DabblerButton.lineHeightFactor} · '
            'NOT A RAMP STEP',
          ),
          const SizedBox(height: DabblerSpacing.space1),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              'Join game — ${_n(fontSize)}/600',
              style: DabblerButton.labelStyle
                  .resolve(DabblerTypeScript.latin)
                  .copyWith(
                    fontSize: fontSize,
                    height: DabblerButton.lineHeightFactor,
                    fontWeight: DabblerType.semibold,
                    color: colors.warning.strong,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `34.0` reads as `34` — the source page prints integers.
String _n(double value) =>
    value == value.roundToDouble() ? '${value.toInt()}' : '$value';
