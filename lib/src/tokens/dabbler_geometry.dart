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

  // --- App layout extents (zero-literal pass). App roles, each a step or a
  // sum of steps; none is a design-source declaration. ---

  /// App role, mapped onto [space8] (24): the bottom inset that closes a
  /// scrolling list on a screen with **no** floating bar (Home feed tabs).
  static const double listBottomInset = space8;

  /// App role, `2 × space11` (96): the clearance a list keeps under the
  /// **floating** bottom navigation bar so its last row is not covered.
  static const double floatingBarClearance = space11 * 2;

  /// App role, `2 × space11` (96): the clearance a detail screen keeps above
  /// its sticky bottom action bar. Same value as [floatingBarClearance];
  /// kept as its own name because the two bars can diverge.
  static const double stickyActionBarClearance = space11 * 2;
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

  /// App role: top-only [xl] corners — a panel rising from the bottom edge
  /// with the DS sheet's own corner.
  static const BorderRadius xlTop = BorderRadius.vertical(
    top: Radius.circular(xl),
  );

  /// App role: top-only [xxl] corners — the app's composer drawer and modal
  /// route panel. Replaces `BorderRadius.vertical(top: Radius.circular(…))`.
  static const BorderRadius xxlTop = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );

  /// App role, alias of [xxlTop]: the bottom-drawer top corner the app draws
  /// (`core/widgets/composer_drawer_kit.dart`, modal routes; 28 → 24).
  static const BorderRadius topSheet = xxlTop;

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

  // --- App roles (zero-literal pass) ----------------------------------------
  //
  // Not design-source declarations: each names what the consuming app sizes,
  // and each is a [DabblerSpacing] step or a sum of steps, so the base-3 grid
  // holds. The app's near-miss numbers fold onto these (named per entry).

  /// App role, mapped onto `space4` (12): a meta glyph beside caption text
  /// (location pin, clock). The app's 10, 11 and 13 fold here.
  static const double iconXs = DabblerSpacing.space4;

  /// App role, mapped onto `space5` (15): an icon inside a chip or an inline
  /// label. The app's 14 and 16 fold here.
  static const double iconInline = DabblerSpacing.space5;

  /// App role, mapped onto `space7` (21): a list-row / field leading icon.
  /// The app's 20 and 22 fold here.
  static const double iconRow = DabblerSpacing.space7;

  /// App role, mapped onto `space10` (36): a standalone glyph heading an
  /// empty or notice block, and a small icon tile's extent.
  static const double iconXl = DabblerSpacing.space10;

  /// App role, mapped onto [touchTargetMin] (45): a medium icon tile / sport
  /// tile. The app's 44 folds here.
  static const double tileMd = touchTargetMin;

  /// The result-row tile (`Search.dc.html:262` draws 40; 39 is the nearest
  /// base-3 step).
  static const double tileSm = 39;

  /// App role, mapped onto `space11` (48): a large icon tile.
  static const double tileLg = DabblerSpacing.space11;

  /// App role, `space11 + space2` (54): a drawer's illustration tile. The
  /// app's 56 folds here.
  static const double illustrationSm =
      DabblerSpacing.space11 + DabblerSpacing.space2;

  /// App role, `space11 + space8` (72): an empty-state illustration — the
  /// same diameter as `DabblerHeroIcon.defaultSize`. The app's 80 folds here.
  static const double illustrationMd =
      DabblerSpacing.space11 + DabblerSpacing.space8;

  /// App role, `2 × space11` (96): a completion / celebration illustration.
  static const double illustrationLg = DabblerSpacing.space11 * 2;

  /// App role, mapped onto `space3` (9): a status / step dot.
  static const double dot = DabblerSpacing.space3;

  /// App role, mapped onto `space5` (15): a colour swatch chip. The app's 14
  /// folds here.
  static const double swatch = DabblerSpacing.space5;

  /// App role, mapped onto `space2` (6): a page indicator bar's thickness.
  /// The app's 5 folds here.
  static const double indicatorThickness = DabblerSpacing.space2;

  /// App role, `space11 + space4` (60): a square media thumbnail.
  static const double thumbnail =
      DabblerSpacing.space11 + DabblerSpacing.space4;

  /// App role, `space11 + space6` (66): a selectable option tile's height.
  static const double optionTileHeight =
      DabblerSpacing.space11 + DabblerSpacing.space6;

  /// App role, `3 × space9` (90): a fixed label column in a key/value row.
  /// The app's 88 folds here.
  static const double labelColumnWidth = DabblerSpacing.space9 * 3;

  /// App role, `5 × space11` (240): a detail screen's hero / cover height
  /// (before the safe-area top is added). The app's 232 folds here.
  static const double heroCoverHeight = DabblerSpacing.space11 * 5;

  /// App role, `6 × space9` (180): a map or media preview panel's height.
  /// The app's 200 folds here.
  static const double mediaPreviewHeight = DabblerSpacing.space9 * 6;

  /// App role, `4 × space9` (120): a compact preview / placeholder panel.
  static const double mediaPreviewCompactHeight = DabblerSpacing.space9 * 4;

  /// App role, `5 × space9` (150): a horizontal row of media tiles.
  static const double mediaRowHeight = DabblerSpacing.space9 * 5;

  /// App role, `3 × space11` (144): a section's loading placeholder height.
  /// The app's 140 folds here.
  static const double loadingBlockHeight = DabblerSpacing.space11 * 3;

  /// App role, `6 × space9` (180): a horizontal-rail card's width.
  static const double railCardWidth = DabblerSpacing.space9 * 6;

  /// App role, `2 × space11` (96): a horizontal-rail card's height.
  static const double railCardHeight = DabblerSpacing.space11 * 2;

  /// App role, mapped onto `space8` (24): a skeleton title bar's height. The
  /// app's 20 and 28 fold here.
  static const double skeletonTitleHeight = DabblerSpacing.space8;

  /// App role, mapped onto `space4` (12): a skeleton text line's height —
  /// equal to `DabblerSkeleton.lineHeight`. The app's 10 and 14 fold here.
  static const double skeletonLineHeight = DabblerSpacing.space4;

  /// App role, `3 × space9` (90): a skeleton content block's height. The
  /// app's 70, 80 and 100 fold here.
  static const double skeletonBlockHeight = DabblerSpacing.space9 * 3;

  /// App role, `4 × space11 + space8` (216): a long skeleton bar (a title).
  /// The app's 220 folds here.
  static const double skeletonWidthLong =
      DabblerSpacing.space11 * 4 + DabblerSpacing.space8;

  /// App role, `3 × space11 + space4` (156): a medium skeleton bar. The app's
  /// 160 folds here.
  static const double skeletonWidthMedium =
      DabblerSpacing.space11 * 3 + DabblerSpacing.space4;

  /// App role, `3 × space11` (144): a short skeleton bar. The app's 140 folds
  /// here.
  static const double skeletonWidthShort = DabblerSpacing.space11 * 3;

  /// App role, `2 × space11` (96): a meta skeleton bar. The app's 100 folds
  /// here.
  static const double skeletonWidthMeta = DabblerSpacing.space11 * 2;
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
  static final List<BoxShadow> dialogLight =
      List<BoxShadow>.unmodifiable(<BoxShadow>[
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
      ]);

  /// `--elevation-2` under `[data-mode="dark"]`. **Dialog (DS-702) only.**
  ///
  /// `0 9px 24px rgba(0, 0, 0, 0.28), 0 3px 6px rgba(0, 0, 0, 0.20)`.
  static final List<BoxShadow> dialogDark =
      List<BoxShadow>.unmodifiable(<BoxShadow>[
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
      ]);

  /// The legal dialog shadow for [brightness]. **Dialog (DS-702) only.**
  static List<BoxShadow> dialogFor(Brightness brightness) =>
      brightness == Brightness.dark ? dialogDark : dialogLight;
}
