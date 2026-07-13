// =============================================================================
// Dabbler — Geometry tokens (spacing · radius · sizing · elevation)
// Version 2.0 · glass era
// -----------------------------------------------------------------------------
// Grid is BASE 3. Elevation: the old FLAT rule is RETIRED — surfaces are liquid
// glass (see dabbler_glass.dart for the surface/border/shadow sets).
// DabblerElevation.level2 remains only as the legacy floating shadow for
// Material dialogs / sheets / menus.
//
// Structural values 12 / 24 / 30 / 36 / 48 are multiples of BOTH 3 and 4, so
// they line up with 24px icons and platform components — prefer them for layout.
//
// Mirrors dabbler_spacing.css.
// =============================================================================

import 'package:flutter/widgets.dart';

/// Base-3 spacing scale + semantic aliases (logical pixels).
abstract final class DabblerSpacing {
  DabblerSpacing._();

  static const double space1 = 3;
  static const double space2 = 6;
  static const double space3 = 9;
  static const double space4 = 12;
  static const double space5 = 15;
  static const double space6 = 18;
  static const double space7 = 21;
  static const double space8 = 24;
  static const double space9 = 30;
  static const double space10 = 36;
  static const double space11 = 48;

  // Semantic aliases — reference these in UI, not raw numbers.
  static const double cardPadding = 18; // space6
  static const double screenGutter = 24; // space8
  static const double sectionGap = 30; // space9
  static const double stackTight = 6; // space2
  static const double stackDefault = 12; // space4
  static const double iconGap = 6; // space2

  /// Ordered scale (name → value), for token-driven UIs (e.g. the gallery).
  static const List<(String, double)> scale = [
    ('space1', space1),
    ('space2', space2),
    ('space3', space3),
    ('space4', space4),
    ('space5', space5),
    ('space6', space6),
    ('space7', space7),
    ('space8', space8),
    ('space9', space9),
    ('space10', space10),
    ('space11', space11),
  ];
}

/// Base-3 corner radii + ready-made [BorderRadius] helpers.
abstract final class DabblerRadius {
  DabblerRadius._();

  static const double sm = 6; // chips, small inputs
  static const double md = 9; // buttons
  static const double lg = 12; // icon tiles, nested surfaces
  static const double xl = 18; // cards, sheets, modals
  static const double xxl = 24; // search fields, hero glass surfaces
  static const double pill = 999; // pills, avatars, glass chips

  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlRadius = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(pill));

  // Semantic getters (glass era: cards sit at xl, glass chips are pills).
  static BorderRadius get chipRadius => pillRadius;
  static BorderRadius get buttonRadius => mdRadius;
  static BorderRadius get cardRadius => xlRadius;
  static BorderRadius get sheetRadius => xlRadius;
  static BorderRadius get fieldRadius => xxlRadius;

  /// Ordered scale (name · usage → value), for token-driven UIs.
  static const List<(String, double)> scale = [
    ('sm', sm),
    ('md', md),
    ('lg', lg),
    ('xl', xl),
    ('xxl', xxl),
    ('pill', pill),
  ];
}

/// Sizing tokens: tap targets, border widths, icon sizes.
abstract final class DabblerSizing {
  DabblerSizing._();

  /// Minimum tap target — base-3 and clears Apple's 44pt floor.
  static const double touchTargetMin = 45;

  static const double borderHairline = 0.5;
  static const double borderDefault = 1.0;

  static const double iconSm = 18;
  static const double iconMd = 24; // HugeIcons native grid
  static const double iconLg = 30;
}

/// Flat / Apple-style elevation. Only [level2] casts a shadow.
abstract final class DabblerElevation {
  DabblerElevation._();

  /// Ink used by the floating shadow (the theme's shared violet-cool near-black).
  static const Color shadowInk = Color(0xFF171123);

  /// Flat on the background — no shadow.
  static const List<BoxShadow> level0 = <BoxShadow>[];

  /// Raised surface — separation is border + surfaceCard tint only, no shadow.
  static const List<BoxShadow> level1 = <BoxShadow>[];

  /// The ONLY shadow. Floating surfaces: modals, bottom sheets, popovers, FAB.
  ///
  /// In DARK mode this reads as almost nothing — that is intentional; dark
  /// floating surfaces separate via their border + a lighter surface tint.
  /// Keep this subtle shadow, do not increase it for dark.
  static const List<BoxShadow> level2 = <BoxShadow>[
    BoxShadow(color: Color(0x24171123), offset: Offset(0, 9), blurRadius: 24),
    BoxShadow(color: Color(0x14171123), offset: Offset(0, 3), blurRadius: 6),
  ];
}
