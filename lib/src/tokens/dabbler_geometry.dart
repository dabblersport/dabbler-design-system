import 'package:flutter/material.dart';

import 'dabbler_palette.dart';

/// The base geometry of the Dabbler design system: spacing, radius, sizing and
/// elevation.
///
/// Every value here is transcribed from the design source
/// `tokens/spacing.css`. That file's `:root` block is the single origin of the
/// base-3 grid (`--space-1` … `--space-11`), the radius ramp, the sizing
/// constants and the elevation entries.
///
/// Like [DabblerType], this is a **plain const class, not a `ThemeExtension`**.
/// Geometry does not vary by theme — the Dabbler themes differ in colour only —
/// so the grid is a compile-time constant rather than a value resolved off a
/// [BuildContext].
///
/// ## Base 3, not base 4
///
/// The scale steps in 3s. The source's own guidance: prefer 12 / 24 / 30 / 36 /
/// 48 for structural values, because those are multiples of **both** 3 and 4
/// and therefore line up with 24px icons and platform components.
abstract final class DabblerSpacing {
  const DabblerSpacing._();

  // --- The base-3 scale: --space-1 … --space-11 ---

  /// `--space-1` — 3px.
  static const double space1 = 3;

  /// `--space-2` — 6px.
  static const double space2 = 6;

  /// `--space-3` — 9px.
  static const double space3 = 9;

  /// `--space-4` — 12px.
  static const double space4 = 12;

  /// `--space-5` — 15px.
  static const double space5 = 15;

  /// `--space-6` — 18px.
  static const double space6 = 18;

  /// `--space-7` — 21px.
  static const double space7 = 21;

  /// `--space-8` — 24px.
  static const double space8 = 24;

  /// `--space-9` — 30px.
  static const double space9 = 30;

  /// `--space-10` — 36px.
  static const double space10 = 36;

  /// `--space-11` — 48px.
  static const double space11 = 48;

  /// The eleven steps in source order, for gallery rendering and for the test
  /// that checks the scale against `spacing.css`.
  static const List<double> scale = <double>[
    space1,
    space2,
    space3,
    space4,
    space5,
    space6,
    space7,
    space8,
    space9,
    space10,
    space11,
  ];

  // --- Semantic aliases. Each one IS a step of the scale, never a new value ---

  /// `--card-padding` — `--space-6` (18).
  static const double cardPadding = space6;

  /// `--screen-gutter` — `--space-8` (24).
  static const double screenGutter = space8;

  /// `--section-gap` — `--space-9` (30).
  static const double sectionGap = space9;

  /// `--stack-tight` — `--space-2` (6).
  static const double stackTight = space2;

  /// `--stack-default` — `--space-4` (12).
  static const double stackDefault = space4;

  /// `--icon-gap` — `--space-2` (6).
  static const double iconGap = space2;
}

/// The radius ramp — `--radius-*` in `tokens/spacing.css`.
///
/// The ramp is base-3 like the spacing scale, with one ruled exception:
/// [card] (16), added by `cxo` ruling **D-018** because nine of the nine card
/// shells in the design source draw it and none draws a base-3 step. Each step
/// carries the source's own note about what it is for; components pick a step
/// by that role rather than by eyeballing a corner.
abstract final class DabblerRadius {
  const DabblerRadius._();

  /// `--radius-sm` — 6px. Chips, small inputs.
  static const double sm = 6;

  /// `--radius-md` — 9px. Buttons.
  static const double md = 9;

  /// `--radius-lg` — 12px. **The corner of a tile *inside* a card**, not the
  /// corner of a card.
  ///
  /// `tokens/spacing.css:27` annotates this step *"cards, icon tiles"*, which
  /// conflates two different corners: `CardHouse.jsx` draws 16 for its shell
  /// (`:9`) and 12 for the icon tile inside it (`:36`), in the same file. `cxo`
  /// ruling **D-018** settles the split — 12 is the inner tile, [card] (16) is
  /// the card. The source's own annotation is amended on the design side under
  /// KAN-261; this step's value is unchanged.
  static const double lg = 12;

  /// **16px — the card corner.** Added by `cxo` ruling **D-018**.
  ///
  /// Not a base-3 step, and deliberately so: all nine top-level card shells in
  /// the design source draw `borderRadius: 16` (`CardEventLarge:9`,
  /// `CardEventMedium:21`, `CardEventSmall:21`, `CardActiveRoom:10`,
  /// `CardPricingDefault:8`, `CardPricingSelected:8`, `CardHouse:9`,
  /// `CardPoll:9`, `CardRoom:8`) and not one draws 12. D-018: *"Where a comment
  /// and nine drawings disagree, the drawings are the design system."* 18 was
  /// considered and rejected — it is base-3, but it is the corner sheets and
  /// modals draw, and snapping the specimen's 16 onto it is a visible change.
  ///
  /// Not yet declared in `tokens/spacing.css`; that half is KAN-261.
  static const double card = 16;

  /// `--radius-xl` — 18px. Sheets, modals.
  static const double xl = 18;

  /// `--radius-xxl` — 24px. Text fields, search.
  static const double xxl = 24;

  /// `--radius-pill` — 999px. Pills, avatars.
  static const double pill = 999;

  /// [BorderRadius] forms of each step, for direct use in widget code.
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  /// The seven steps in ascending order, smallest first. [card] (16) sits
  /// between [lg] (12) and [xl] (18) — see D-018.
  static const List<double> ramp = <double>[sm, md, lg, card, xl, xxl, pill];
}

/// Sizing constants — the `/* Sizing */` block of `tokens/spacing.css`.
abstract final class DabblerSizing {
  const DabblerSizing._();

  /// `--touch-target-min` — 45px. Base-3, and clears Apple's 44pt floor.
  static const double touchTargetMin = 45;

  /// `--border-hairline` — 0.5px.
  static const double borderHairline = 0.5;

  /// `--border-default` — 1px.
  static const double borderDefault = 1;

  /// `--icon-sm` — 18px.
  static const double iconSm = 18;

  /// `--icon-md` — 24px. The native icon grid.
  static const double iconMd = 24;

  /// `--icon-lg` — 30px.
  static const double iconLg = 30;
}

/// Elevation — and the system's no-shadow law.
///
/// Dabbler surfaces are **flat**: no blur, no gradient, no shadow. `--elevation-0`
/// and `--elevation-1` are both literally `none` in the source, and are exposed
/// here as the empty shadow list so a caller that reaches for "elevation" still
/// gets flatness.
///
/// [dialog] is the transcription of `--elevation-2`, which the source calls
/// *"the ONE legal shadow and only for Material dialogs"*. It is **reserved for
/// Dialog (DS-702)**: no other component in the cut may reference it. The FAB
/// (DS-402) keeps its own separately-documented shadow exception from the source
/// kit and does not draw on this token either.
///
/// The shadow is the one geometry value that differs between modes, because the
/// source redeclares `--elevation-2` under `[data-mode="dark"]`; hence
/// [dialogFor], and hence the two explicit lists.
abstract final class DabblerElevation {
  const DabblerElevation._();

  /// `--elevation-0` — `none`.
  static const List<BoxShadow> none = <BoxShadow>[];

  /// `--elevation-1` — `none`. Present so the ramp is complete; it is flat.
  static const List<BoxShadow> flat = <BoxShadow>[];

  /// `--elevation-2`, light mode. **Dialog (DS-702) only.**
  ///
  /// `0 9px 24px rgba(23, 17, 35, 0.14), 0 3px 6px rgba(23, 17, 35, 0.08)`.
  ///
  /// `rgb(23, 17, 35)` is `#171123`, which is [DabblerPalette.ink950] — the
  /// shadow does not introduce a colour of its own, so it is expressed through
  /// the palette rather than as a hex literal.
  static final List<BoxShadow> dialogLight = List<BoxShadow>.unmodifiable(
    <BoxShadow>[
      BoxShadow(
        color: DabblerPalette.ink950.withValues(alpha: 0.14),
        offset: const Offset(0, DabblerSpacing.space3),
        blurRadius: DabblerSpacing.space8,
      ),
      BoxShadow(
        color: DabblerPalette.ink950.withValues(alpha: 0.08),
        offset: const Offset(0, DabblerSpacing.space1),
        blurRadius: DabblerSpacing.space2,
      ),
    ],
  );

  /// `--elevation-2` under `[data-mode="dark"]`. **Dialog (DS-702) only.**
  ///
  /// `0 9px 24px rgba(0, 0, 0, 0.28), 0 3px 6px rgba(0, 0, 0, 0.20)`.
  static final List<BoxShadow> dialogDark = List<BoxShadow>.unmodifiable(
    <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.28),
        offset: const Offset(0, DabblerSpacing.space3),
        blurRadius: DabblerSpacing.space8,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.20),
        offset: const Offset(0, DabblerSpacing.space1),
        blurRadius: DabblerSpacing.space2,
      ),
    ],
  );

  /// The legal dialog shadow for [brightness]. **Dialog (DS-702) only.**
  static List<BoxShadow> dialogFor(Brightness brightness) =>
      brightness == Brightness.dark ? dialogDark : dialogLight;
}
