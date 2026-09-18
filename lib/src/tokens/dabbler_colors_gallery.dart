/// Gallery entries for [DabblerPalette] and [DabblerColors] — the colour token
/// specimen (KAN-298, `DECISIONS.md` D-034(b)).
///
/// ## What is compared against what
///
/// | design source | here |
/// |---|---|
/// | `colors.html` §Brand — Main ladder — the 300/400/600/700 + secondary swatch row | [_brand] |
/// | `colors.html` §Brand — Section themes — one swatch per theme | [_brand] |
/// | `colors.html` §Surfaces — the paper ramp | [_surfaces] |
/// | `colors.html` §Ink & outline | [_surfaces] |
/// | `colors.html` §Semantic — status — base row, then surface + strong ink row | [_status] |
/// | `colors.html` §Decorative tile tones, §Pastel status tags | [_status] |
/// | `colors.html` §Theme & mode behaviour — the semantic-role resolution table | [_surfaces] |
/// | `colors-status-contrast.html` — every pair **measured live**, light and dark, plus the four theme overrides | [_contrast] |
///
/// The swatch itself is `colors.html`'s `.sw`: `--radius-md`, 8px padding,
/// 118×88, contents pushed to the bottom, an 11px/600 label over a 10px mono
/// token name and a 10px mono hex.
///
/// ## Fourteen pairs, and why that is this specimen's subject
///
/// **KAN-298 AC2 is the requirement that makes this page different from every
/// other one in the gallery**, and `D-034(b)` states the reason: `D-033(d)`
/// rejected a per-page theme rail *precisely so that theme could mean
/// something on the page where it actually varies*. A swatch grid that only
/// renders light/main is not this specimen.
///
/// So nothing here is drawn from a constant that cannot move. Every semantic
/// swatch resolves through [DabblerColors.of], which follows the gallery's own
/// [GalleryAppearance] — switch theme or brightness in the header and the grid
/// repaints. Two things make that *provable* rather than merely true:
///
/// 1. every entry opens with the resolved `(theme, brightness)` pair and the
///    ordinal of the fourteen it is showing, so a reviewer can walk all
///    fourteen and see the readout change; and
/// 2. the section-theme band resolves the **other six** themes through
///    [DabblerColors.resolve] at the current brightness, the way `colors.html`
///    draws five themes side by side — which a page reading only its own
///    inherited theme could not do.
///
/// **The primitives band is deliberately the exception.** [DabblerPalette] is
/// the literal-hex layer and does not resolve — that is what makes it the
/// primitive layer — so the brand ladders are constant across all fourteen
/// pairs, and saying otherwise would be false. The distinction between the
/// band that moves and the band that cannot is itself part of what the
/// specimen documents.
///
/// ## Contrast is computed, never typed
///
/// `colors-status-contrast.html` measures every pair at render time from the
/// resolved tokens, *"so this table cannot drift from the values components
/// actually paint"*. [_contrast] does the same thing with the same WCAG 2.x
/// relative-luminance formula ([_contrastRatio]), reading the *current*
/// resolution rather than a transcribed table. A number typed into this file
/// would be stale the first time `dabbler_dark_provisional.dart` is signed
/// off; a number computed here cannot be.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_page.dart';
import '../gallery/gallery_specimen.dart';
import 'dabbler_colors.dart';
import 'dabbler_geometry.dart';
import 'dabbler_palette.dart';
import 'dabbler_type.dart';

/// The colour token specimens.
const List<GalleryEntry> colorsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'colour/brand',
    page: 'foundations/colour',
    group: null,
    title: 'Colour — brand ladders and the seven section themes',
    description: 'The five primitive brand ramps, then all seven themes '
        'resolved side by side at the current brightness.',
    builder: _brand,
  ),
  GalleryEntry(
    id: 'colour/surfaces',
    page: 'foundations/colour',
    group: null,
    title: 'Colour — surfaces, ink and outline',
    description: 'The shared paper ramp and every semantic surface, text and '
        'border role, resolved under the current (theme, brightness) pair.',
    builder: _surfaces,
  ),
  GalleryEntry(
    id: 'colour/status',
    page: 'foundations/colour',
    group: null,
    title: 'Colour — status, tags and decorative tones',
    description: 'The four status tones in all four roles, the seven workflow '
        'tags and the three decorative tiles.',
    builder: _status,
  ),
  GalleryEntry(
    id: 'colour/contrast',
    page: 'foundations/colour',
    group: null,
    title: 'Colour — contrast, measured live',
    description: 'Every status pair measured from the resolved tokens at '
        'render time, not transcribed. Switch theme or brightness and the '
        'numbers change.',
    builder: _contrast,
  ),
];

// --- Entries -------------------------------------------------------------

Widget _brand(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return GalleryStack(
    children: <Widget>[
      const _AppearanceReadout(),
      const GalleryUsage(
        '**Seven themes share one structure; the default is Main violet.** '
        '*"Themes re-tint the brand, never the paper"* — the warm cream '
        'surface ramp is inherited verbatim from the Figma file and is shared '
        'by every theme. Every background is a flat solid colour, never a '
        'gradient.',
      ),
      GalleryGroup(
        name: 'Section themes — resolved at this brightness',
        wrap: false,
        children: <Widget>[
          _SwatchRow(
            children: <Widget>[
              for (final DabblerTheme theme in DabblerTheme.values)
                _ThemeSwatch(theme: theme, brightness: colors.brightness),
            ],
          ),
        ],
      ),
      const GalleryUsage(
        '**This band is the proof of AC2.** Each swatch above is '
        '`DabblerColors.resolve(theme: …, brightness: …)` at the brightness '
        'the gallery is currently in — so switching brightness repaints all '
        'seven, and switching theme moves the `current` mark. `simple` and '
        '`shade` carry no brand ramp of their own and resolve through the '
        'shared ink ramp, which is why they read as near-black and grey '
        'rather than as a hue.',
      ),
      const GalleryRule(),
      const GalleryUsage(
        '**The ladders below are `DabblerPalette` primitives and do NOT '
        'resolve.** They are the literal hex layer transcribed from '
        '`tokens/colors.css`, so they are identical under all fourteen pairs '
        '— by construction, not by oversight. Product code never reads them: '
        'it consumes the `--color-*` semantic layer, which is the next entry.',
      ),
      for (final (String name, List<(String, String, Color)> ladder)
          in _brandLadders)
        GalleryGroup(
          name: '$name ladder',
          wrap: false,
          children: <Widget>[
            _SwatchRow(
              children: <Widget>[
                for (final (String step, String token, Color color) in ladder)
                  _Swatch(label: step, token: token, color: color),
              ],
            ),
          ],
        ),
      const GalleryUsage(
        '**600 is the default brand primary**, reached through '
        '`--color-brand-primary`; **700 is its hover.** Selected and active '
        'states are the solid brand fill with `--color-on-brand` text — no '
        'stroke, no sheen. Colour re-tints from the active brand primary; '
        'never hardcode the violet.',
      ),
    ],
  );
}

Widget _surfaces(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return GalleryStack(
    children: <Widget>[
      const _AppearanceReadout(),
      const GalleryUsage(
        '**Flat, warm, opaque.** Every surface is an opaque fill plus a 1px '
        'hairline: no backdrop blur, no sheen, no elevation. Separation comes '
        'from **fill steps and hairlines**, not shadow. `bgTertiary` '
        '(`--faint`) is the divider step *inside* a container; '
        '`borderDefault` (`--outline-card`) separates containers.',
      ),
      GalleryGroup(
        name: 'Surfaces — the paper ramp',
        wrap: false,
        children: <Widget>[
          _SwatchRow(
            children: <Widget>[
              _Swatch(
                label: 'page bg',
                token: '--color-bg-primary',
                color: colors.bgPrimary,
              ),
              _Swatch(
                label: 'card',
                token: '--color-surface-card',
                color: colors.surfaceCard,
                outline: colors.borderDefault,
              ),
              _Swatch(
                label: 'sunken',
                token: '--color-surface-sunken',
                color: colors.surfaceSunken,
              ),
              _Swatch(
                label: 'grey',
                token: '--color-surface-grey',
                color: colors.surfaceGrey,
              ),
              _Swatch(
                label: 'secondary',
                token: '--color-bg-secondary',
                color: colors.bgSecondary,
              ),
              _Swatch(
                label: 'tertiary / faint',
                token: '--color-bg-tertiary',
                color: colors.bgTertiary,
              ),
            ],
          ),
        ],
      ),
      GalleryGroup(
        name: 'Ink & outline',
        wrap: false,
        children: <Widget>[
          _SwatchRow(
            children: <Widget>[
              _Swatch(
                label: 'text primary',
                token: '--color-text-primary',
                color: colors.textPrimary,
              ),
              _Swatch(
                label: 'text secondary',
                token: '--color-text-secondary',
                color: colors.textSecondary,
              ),
              _Swatch(
                label: 'text tertiary',
                token: '--color-text-tertiary',
                color: colors.textTertiary,
              ),
              _Swatch(
                label: 'border default',
                token: '--color-border-default',
                color: colors.borderDefault,
              ),
              _Swatch(
                label: 'border strong',
                token: '--color-border-strong',
                color: colors.borderStrong,
              ),
            ],
          ),
        ],
      ),
      const GalleryUsage(
        '**`textSecondary` is the only secondary body-text role, and every '
        'placeholder belongs to it** — `DECISIONS.md` D-003(a). `--muted` and '
        '`--subtle` are signed-off Figma *surface-ramp* neutrals that the '
        'semantic layer once wrongly exposed as text roles. `textTertiary` is '
        'de-emphasis for **large text, icons and inactive controls only** — '
        'never body text and never a placeholder. The live ratios are in the '
        '**Contrast** entry.',
      ),
      GalleryGroup(
        name: 'Brand roles — the part that re-tints',
        wrap: false,
        children: <Widget>[
          _SwatchRow(
            children: <Widget>[
              _Swatch(
                label: 'brand primary',
                token: '--color-brand-primary',
                color: colors.brandPrimary,
              ),
              _Swatch(
                label: 'brand hover',
                token: '--color-brand-primary-hover',
                color: colors.brandPrimaryHover,
              ),
              _Swatch(
                label: 'on brand',
                token: '--color-on-brand',
                color: colors.onBrand,
                outline: colors.borderDefault,
              ),
              _Swatch(
                label: 'accent',
                token: '--color-accent',
                color: colors.accent,
              ),
              _Swatch(
                label: 'accent hover',
                token: '--color-accent-hover',
                color: colors.accentHover,
              ),
              _Swatch(
                label: 'on accent',
                token: '--color-on-accent',
                color: colors.onAccent,
                outline: colors.borderDefault,
              ),
              _Swatch(
                label: 'focus ring',
                token: '--color-focus-ring',
                color: colors.focusRing,
              ),
              _Swatch(
                label: 'spotlight',
                token: '--color-spotlight',
                color: colors.spotlight,
              ),
            ],
          ),
        ],
      ),
      const GalleryUsage(
        '**Only these eight roles and the four per-theme status overrides '
        'vary across themes.** At a given brightness all seven themes share '
        'one background, card, ink and border ramp byte for byte — '
        '`tokens/colors.css`: *"Neutrals are the Figma paper ramp — literal, '
        'shared, never a brand tint"*. Switch theme in the header and only '
        'this band moves.',
      ),
      GallerySpecimen(
        label: '--color-scrim · the wash behind every overlay',
        child: _ScrimSample(colors: colors),
      ),
      const GalleryUsage(
        '`--color-scrim` is ink at 45% in light and `--ink-950` at 65% in '
        'dark. **Overlays consume this and never invent their own opacity** — '
        'Sheet, Dialog and the mobile Menu all read the same token.',
      ),
      if (colors.brightness == Brightness.dark)
        const GalleryUsage(
          '**Dark is provisional.** Every dark hex is declared once, in '
          '`DabblerProvisionalDark`, and is inferred rather than signed off. '
          'The *structure* is final; the values are not, and D-003(c) has not '
          'been actioned. Read this brightness as a shape, not as a palette.',
        ),
    ],
  );
}

Widget _status(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return GalleryStack(
    children: <Widget>[
      const _AppearanceReadout(),
      const GalleryUsage(
        '**The status API separates four roles, because one token cannot do '
        'all three jobs.** `base` is the bare indicator — a dot, a bar; '
        '`surface` + `strong` is what badges, banners and toasts use; `solid` '
        'is the fill that carries white text on destructive buttons and the '
        'PanelCard info frame. **The base tints are far too light to carry '
        'white (2.1–3.8:1), which is exactly why `solid` exists.**',
      ),
      GalleryGroup(
        name: 'Base — indicators, dots, bars',
        wrap: false,
        children: <Widget>[
          _SwatchRow(
            children: <Widget>[
              for (final DabblerStatusTone tone in DabblerStatusTone.values)
                _Swatch(
                  label: tone.name,
                  token: '--color-status-${tone.name}',
                  color: colors.status(tone).base,
                ),
              _Swatch(
                label: 'spotlight',
                token: '--color-spotlight',
                color: colors.spotlight,
              ),
            ],
          ),
        ],
      ),
      GalleryGroup(
        name: 'Surface + strong ink — badges, banners, toasts',
        wrap: false,
        children: <Widget>[
          _SwatchRow(
            children: <Widget>[
              for (final DabblerStatusTone tone in DabblerStatusTone.values)
                _Swatch(
                  label: '${tone.name} surface',
                  token: '-surface / -strong',
                  color: colors.status(tone).surface,
                  ink: colors.status(tone).strong,
                ),
            ],
          ),
        ],
      ),
      GalleryGroup(
        name: 'Solid — the fill that carries white',
        wrap: false,
        children: <Widget>[
          _SwatchRow(
            children: <Widget>[
              for (final DabblerStatusTone tone in DabblerStatusTone.values)
                _Swatch(
                  label: '${tone.name} solid',
                  token: '-solid',
                  color: colors.status(tone).solid,
                  ink: DabblerPalette.paper,
                ),
            ],
          ),
        ],
      ),
      const GalleryUsage(
        '**Per-theme overrides exist where a theme needs its own hue:** '
        '`sport` overrides success, `social` overrides info, `active` '
        'overrides error, `bright` overrides warning. Switch theme in the '
        'header and one of the four rows above changes while the other three '
        'hold — which is the cheapest way to see that the override is real.',
      ),
      const GalleryRule(),
      GalleryGroup(
        name: 'Pastel status tags — theme- and brightness-invariant',
        children: <Widget>[
          for (final (String name, DabblerToneColor tone) in _tags)
            _TagChip(label: name, tone: tone),
        ],
      ),
      const GalleryUsage(
        'Surface + label pairs for the seven workflow states. '
        '`DabblerCardTicket`\'s `statusTone` draws from this palette. These '
        'are `static const` on `DabblerColors` and do **not** vary by theme or '
        'brightness — the same deliberate constancy as the primitives.',
      ),
      GalleryGroup(
        name: 'Decorative tile tones — separate from status',
        wrap: false,
        children: <Widget>[
          _SwatchRow(
            children: <Widget>[
              for (final (String name, DabblerToneColor tone) in _tiles)
                _Swatch(
                  label: name,
                  token: '--tile-$name-surface / -ink',
                  color: tone.surface,
                  ink: tone.ink,
                ),
            ],
          ),
        ],
      ),
      const GalleryUsage(
        '**The amber / blue / pink fills carry no state meaning**, so they are '
        'deliberately *not* part of the `--color-status-*` API. `StatTile`, '
        '`CardTicket` and `PanelCard` read these tokens; screens pass a tone, '
        'never a colour value. A third, unrelated set — `Badge`\'s `tone` prop '
        '— is the Figma kit\'s decorative vocabulary and is not semantic '
        'either (`tone="error"` is purple). Use `Badge status` for real state.',
      ),
    ],
  );
}

Widget _contrast(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return GalleryStack(
    children: <Widget>[
      const _AppearanceReadout(),
      const GalleryUsage(
        '**Read live from the resolved tokens, not typed in** — so this table '
        'cannot drift from the values components actually paint. AA body text '
        'needs **4.5:1**. `strong` is the status ink (mode- and theme-aware); '
        '`solid` is the fill that carries white. Every number below is '
        '`_contrastRatio` over the pair beside it, computed this frame under '
        'the pair named above.',
      ),
      GalleryGroup(
        name: 'Status pairs',
        wrap: false,
        children: <Widget>[
          for (final DabblerStatusTone tone in DabblerStatusTone.values)
            _ContrastRow(
              label: '${tone.name} surface × strong',
              background: colors.status(tone).surface,
              foreground: colors.status(tone).strong,
            ),
          for (final DabblerStatusTone tone in DabblerStatusTone.values)
            _ContrastRow(
              label: '${tone.name} solid × white',
              background: colors.status(tone).solid,
              foreground: DabblerPalette.paper,
            ),
          for (final DabblerStatusTone tone in DabblerStatusTone.values)
            _ContrastRow(
              label: '${tone.name} strong on card',
              background: colors.surfaceCard,
              foreground: colors.status(tone).strong,
            ),
        ],
      ),
      const GalleryUsage(
        '**The base tints are indicators only.** White on them measures '
        '2.1–3.8:1, which is why solid controls use `solid` instead — the row '
        'below measures that claim rather than repeating it.',
      ),
      GalleryGroup(
        name: 'Base × white — the pairs that must NOT be used for text',
        wrap: false,
        children: <Widget>[
          for (final DabblerStatusTone tone in DabblerStatusTone.values)
            _ContrastRow(
              label: '${tone.name} base × white',
              background: colors.status(tone).base,
              foreground: DabblerPalette.paper,
              expectedToFail: true,
            ),
        ],
      ),
      GalleryGroup(
        name: 'Text roles — D-003(a), measured',
        wrap: false,
        children: <Widget>[
          _ContrastRow(
            label: 'text primary on card',
            background: colors.surfaceCard,
            foreground: colors.textPrimary,
          ),
          _ContrastRow(
            label: 'text secondary on card',
            background: colors.surfaceCard,
            foreground: colors.textSecondary,
          ),
          _ContrastRow(
            label: 'text secondary on page',
            background: colors.bgPrimary,
            foreground: colors.textSecondary,
          ),
          _ContrastRow(
            label: 'text tertiary on card — AA-large only, by ruling',
            background: colors.surfaceCard,
            foreground: colors.textTertiary,
            expectedToFail: true,
          ),
          _ContrastRow(
            label: 'on-brand × brand primary',
            background: colors.brandPrimary,
            foreground: colors.onBrand,
          ),
        ],
      ),
      const GalleryUsage(
        '**`textTertiary` failing 4.5:1 here is the ruling, not a defect.** '
        'D-003(a) demoted `--muted` out of the secondary-text role for exactly '
        'this reason: at 3.36:1 on a card it clears AA-large (≥24px, or '
        '≥18.66px bold) and nothing else, so its legitimate uses are large '
        'text, icons, non-informational rules and the disabled state of a '
        'control — which WCAG 1.4.3 exempts by name as an inactive '
        'user-interface component.',
      ),
      const GalleryUsage(
        '**Walk the brightness switch to see the measurement move.** Light '
        '`surface × strong` measures 5.49–6.80:1 and dark 12.44–13.77:1, '
        'because `strong` flips to the light tint in dark mode. '
        '(`colors.html` states the light range as *"6.4–6.8:1"*; measured '
        'here and on the source\'s own contrast page, `info` is **5.49:1** — '
        'still AA, but below the range the prose claims. Reported, not '
        'smoothed over.) Nothing on this page '
        'is transcribed, so the dark figures will change by themselves the '
        'day `DabblerProvisionalDark` is signed off — which is the whole '
        'reason the source page measures rather than tabulates.',
      ),
    ],
  );
}

// --- Data ----------------------------------------------------------------

/// The five brand ladders `colors.html` draws, as `(step, token, colour)`.
///
/// `simple` and `shade` have no ladder of their own — they resolve through the
/// shared ink ramp — so there are five ladders for seven themes.
const List<(String, List<(String, String, Color)>)> _brandLadders =
    <(String, List<(String, String, Color)>)>[
  ('Main', <(String, String, Color)>[
    ('300', '--main-p-300', DabblerPalette.mainP300),
    ('400', '--main-p-400', DabblerPalette.mainP400),
    ('600 · primary', '--main-p-600', DabblerPalette.mainP600),
    ('700 · hover', '--main-p-700', DabblerPalette.mainP700),
    ('secondary 400', '--main-s-400', DabblerPalette.mainS400),
    ('secondary 600', '--main-s-600', DabblerPalette.mainS600),
    ('secondary 700', '--main-s-700', DabblerPalette.mainS700),
  ]),
  ('Sport', <(String, String, Color)>[
    ('300', '--sport-p-300', DabblerPalette.sportP300),
    ('400', '--sport-p-400', DabblerPalette.sportP400),
    ('600 · primary', '--sport-p-600', DabblerPalette.sportP600),
    ('700 · hover', '--sport-p-700', DabblerPalette.sportP700),
    ('secondary 400', '--sport-s-400', DabblerPalette.sportS400),
    ('secondary 600', '--sport-s-600', DabblerPalette.sportS600),
    ('secondary 700', '--sport-s-700', DabblerPalette.sportS700),
  ]),
  ('Social', <(String, String, Color)>[
    ('300', '--social-p-300', DabblerPalette.socialP300),
    ('400', '--social-p-400', DabblerPalette.socialP400),
    ('600 · primary', '--social-p-600', DabblerPalette.socialP600),
    ('700 · hover', '--social-p-700', DabblerPalette.socialP700),
    ('secondary 400', '--social-s-400', DabblerPalette.socialS400),
    ('secondary 600', '--social-s-600', DabblerPalette.socialS600),
    ('secondary 700', '--social-s-700', DabblerPalette.socialS700),
  ]),
  ('Active', <(String, String, Color)>[
    ('300', '--active-p-300', DabblerPalette.activeP300),
    ('400', '--active-p-400', DabblerPalette.activeP400),
    ('600 · primary', '--active-p-600', DabblerPalette.activeP600),
    ('700 · hover', '--active-p-700', DabblerPalette.activeP700),
    ('secondary 400', '--active-s-400', DabblerPalette.activeS400),
    ('secondary 600', '--active-s-600', DabblerPalette.activeS600),
    ('secondary 700', '--active-s-700', DabblerPalette.activeS700),
  ]),
  ('Bright', <(String, String, Color)>[
    ('300', '--bright-p-300', DabblerPalette.brightP300),
    ('400', '--bright-p-400', DabblerPalette.brightP400),
    ('600 · primary', '--bright-p-600', DabblerPalette.brightP600),
    ('700 · hover', '--bright-p-700', DabblerPalette.brightP700),
    ('secondary 400', '--bright-s-400', DabblerPalette.brightS400),
    ('secondary 600', '--bright-s-600', DabblerPalette.brightS600),
    ('secondary 700', '--bright-s-700', DabblerPalette.brightS700),
  ]),
];

/// The seven workflow tags, in `colors.html`'s order, with its own labels.
const List<(String, DabblerToneColor)> _tags = <(String, DabblerToneColor)>[
  ('Pending', DabblerColors.tagPending),
  ('In progress', DabblerColors.tagProgress),
  ('Submitted', DabblerColors.tagSubmitted),
  ('In review', DabblerColors.tagReview),
  ('Success', DabblerColors.tagSuccess),
  ('Failed', DabblerColors.tagFailed),
  ('Expired', DabblerColors.tagExpired),
];

/// The three decorative tiles.
const List<(String, DabblerToneColor)> _tiles = <(String, DabblerToneColor)>[
  ('amber', DabblerColors.tileAmber),
  ('info', DabblerColors.tileInfo),
  ('accent', DabblerColors.tileAccent),
];

// --- Measurement ---------------------------------------------------------

/// WCAG 2.x relative luminance of [color], over its opaque channels.
///
/// The same formula `colors-status-contrast.html` runs in its own script:
/// each channel is linearised (`c/12.92` below 0.03928, else
/// `((c+0.055)/1.055)^2.4`) and weighted 0.2126 / 0.7152 / 0.0722.
double _luminance(Color color) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// The contrast ratio between [a] and [b], `(L1 + 0.05) / (L2 + 0.05)`.
double _contrastRatio(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// `#RRGGBB`, upper case — the form `colors.html` prints in its `.hex` line.
String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// The ink that reads on [background]: whichever of paper and ink measures
/// higher against it.
///
/// `colors.html` hardcodes a `color:` per swatch. Computing it instead is what
/// keeps the grid legible across all fourteen pairs — a hardcoded ink chosen
/// for the light ramp turns unreadable the moment the dark ramp lands under
/// it, which is the failure mode this specimen exists to rule out.
Color _inkOn(Color background) =>
    _contrastRatio(background, DabblerPalette.paper) >=
            _contrastRatio(background, DabblerPalette.ink)
        ? DabblerPalette.paper
        : DabblerPalette.ink;

// --- Widgets -------------------------------------------------------------

/// The `(theme, brightness)` readout that opens every entry — AC2's proof.
class _AppearanceReadout extends StatelessWidget {
  const _AppearanceReadout();

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    // The ordinal within `DabblerColors.all`, which enumerates the fourteen in
    // `(theme, brightness)` order.
    final int ordinal =
        colors.theme.index * Brightness.values.length + colors.brightness.index;
    return Container(
      padding: const EdgeInsets.all(DabblerSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: DabblerRadius.mdAll,
      ),
      child: GalleryMono(
        'resolved: theme=${colors.theme.name} · '
        'brightness=${colors.brightness.name} · '
        'pair ${ordinal + 1} of ${DabblerColors.all.length}',
      ),
    );
  }
}

/// `colors.html`'s `.sw`: 118×88, `--radius-md`, 8px padding, contents pushed
/// to the bottom — an 11px/600 label over a 10px mono token and a 10px mono
/// hex.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.label,
    required this.token,
    required this.color,
    this.ink,
    this.outline,
  });

  /// The `.lbl` line.
  final String label;

  /// The `.tok` line — the CSS custom property this swatch is.
  final String token;

  /// The fill.
  final Color color;

  /// The `color:` the source hardcodes per swatch. Computed when omitted.
  final Color? ink;

  /// A hairline, for a swatch that would otherwise vanish into the page.
  final Color? outline;

  /// `.sw{min-width:118px;height:88px}`.
  ///
  /// The width is a **minimum**, not a size: the source's `.sw` carries
  /// `flex:1`, so a row of swatches spans the page rather than sitting as a
  /// left-aligned strip of tiles. [_SwatchRow] is what supplies that.
  static const double minWidth = 118;
  static const double _height = 88;

  @override
  Widget build(BuildContext context) {
    final Color on = ink ?? _inkOn(color);
    final TextStyle mono = DabblerType.caption2
        .resolve()
        .copyWith(color: on.withValues(alpha: 0.75), fontSize: 10);
    return Container(
      height: _height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: DabblerRadius.mdAll,
        border: outline == null ? null : Border.all(color: outline!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DabblerType.caption2.resolve().copyWith(
                  color: on,
                  fontWeight: DabblerType.semibold,
                ),
          ),
          Text(token, maxLines: 1, overflow: TextOverflow.ellipsis, style: mono),
          Text(_hex(color), style: mono),
        ],
      ),
    );
  }
}

/// `colors.html`'s `.row{display:flex;gap:9px;flex-wrap:wrap}` over children
/// that each carry `flex:1;min-width:118px`.
///
/// **Neither [Wrap] nor [Row] alone is this.** A `Wrap` lays fixed-size tiles
/// out from the start edge and leaves the rest of the line empty; a `Row` of
/// `Expanded`s fills the line but never wraps. The source does both: swatches
/// share the line equally *and* the line breaks once they would fall under
/// 118px. So the line count is computed from the available width and each line
/// is then a `Row` of `Expanded`s — which is exactly what the CSS resolves to,
/// arrived at the long way because Flutter has no flex-wrap.
class _SwatchRow extends StatelessWidget {
  const _SwatchRow({required this.children});

  final List<Widget> children;

  /// `.row{gap:9px}`.
  static const double _gap = DabblerSpacing.space3;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // How many `min-width:118px` swatches, plus their gaps, fit.
          final int perLine = constraints.maxWidth.isFinite
              ? ((constraints.maxWidth + _gap) / (_Swatch.minWidth + _gap))
                  .floor()
                  .clamp(1, children.length)
              : children.length;
          final List<List<Widget>> lines = <List<Widget>>[
            for (int i = 0; i < children.length; i += perLine)
              children.sublist(
                i,
                (i + perLine).clamp(0, children.length),
              ),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int line = 0; line < lines.length; line++) ...<Widget>[
                if (line > 0) const SizedBox(height: _gap),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (int i = 0; i < lines[line].length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(width: _gap),
                      Expanded(child: lines[line][i]),
                    ],
                    // A short last line keeps its swatches at the same width
                    // as the full lines above it, rather than stretching two
                    // swatches across the page.
                    if (lines[line].length < perLine)
                      Spacer(flex: perLine - lines[line].length),
                  ],
                ),
              ],
            ],
          );
        },
      );
}

/// One of the seven themes, resolved at [brightness] — the band that proves
/// the specimen is not reading a single fixed palette.
class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.theme, required this.brightness});

  final DabblerTheme theme;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final DabblerColors resolved =
        DabblerColors.resolve(theme: theme, brightness: brightness);
    final bool current = DabblerColors.of(context).theme == theme;
    return _Swatch(
      label: current ? '${theme.name} · current' : theme.name,
      token: '--color-brand-primary',
      color: resolved.brandPrimary,
      ink: resolved.onBrand,
      outline: current ? resolved.onBrand : null,
    );
  }
}

/// A workflow tag drawn as the chip `colors.html` draws: 9/16 padding,
/// `--radius-lg`, 15px at weight 600.
class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.tone});

  final String label;
  final DabblerToneColor tone;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: DabblerSpacing.space3,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: tone.surface,
              borderRadius: DabblerRadius.lgAll,
            ),
            child: Text(
              label,
              style: DabblerType.subheadline.resolve().copyWith(
                    color: tone.ink,
                    fontWeight: DabblerType.semibold,
                  ),
            ),
          ),
          const SizedBox(height: DabblerSpacing.space2),
          GalleryMono('${_hex(tone.surface)} · ${_hex(tone.ink)}'),
        ],
      );
}

/// One measured pair: the sample painted in the real colours, and the ratio
/// computed from them this frame.
class _ContrastRow extends StatelessWidget {
  const _ContrastRow({
    required this.label,
    required this.background,
    required this.foreground,
    this.expectedToFail = false,
  });

  final String label;
  final Color background;
  final Color foreground;

  /// Whether falling below 4.5:1 is the documented, correct behaviour for this
  /// pair rather than a defect — a base tint, or `textTertiary`.
  final bool expectedToFail;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double ratio = _contrastRatio(background, foreground);
    final bool passes = ratio >= 4.5;
    return Padding(
      padding: const EdgeInsets.only(bottom: DabblerSpacing.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 280, child: GalleryMono(label)),
          Container(
            constraints: const BoxConstraints(minWidth: 96),
            padding: const EdgeInsets.symmetric(
              vertical: DabblerSpacing.space1,
              horizontal: DabblerSpacing.space3,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: DabblerRadius.smAll,
              border: Border.all(color: colors.borderDefault),
            ),
            child: Text(
              'Aa 0123',
              textAlign: TextAlign.center,
              style: DabblerType.caption1
                  .resolve()
                  .copyWith(color: foreground, fontWeight: DabblerType.medium),
            ),
          ),
          const SizedBox(width: DabblerSpacing.space4),
          Text(
            '${ratio.toStringAsFixed(2)}:1  '
            '${passes ? 'AA' : (expectedToFail ? 'by design' : 'FAIL')}',
            style: DabblerType.caption1.resolve().copyWith(
                  color: passes
                      ? colors.success.strong
                      : (expectedToFail
                          ? colors.textTertiary
                          : colors.error.strong),
                  fontWeight: DabblerType.semibold,
                ),
          ),
        ],
      ),
    );
  }
}

/// The scrim over a card, so the wash reads as a wash rather than a swatch.
class _ScrimSample extends StatelessWidget {
  const _ScrimSample({required this.colors});

  final DabblerColors colors;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 240,
        height: 88,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  border: Border.all(color: colors.borderDefault),
                  borderRadius: DabblerRadius.lgAll,
                ),
              ),
            ),
            PositionedDirectional(
              start: 120,
              top: 0,
              bottom: 0,
              width: 120,
              child: ColoredBox(color: colors.scrim),
            ),
          ],
        ),
      );
}
