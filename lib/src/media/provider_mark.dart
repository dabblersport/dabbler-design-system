import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';

/// The two sign-in vendors whose marks [DabblerProviderMark] draws.
enum DabblerProviderMarkVendor {
  /// Google — the four-colour "G" on its official square tile.
  google,

  /// Apple — the Apple logo on its official monochrome tile.
  apple,
}

/// ProviderMark — a sign-in vendor's OFFICIAL mark, bundled and drawn
/// unmodified, for the "Continue with Google" / "Continue with Apple" rows.
///
/// ```dart
/// const DabblerProviderMark.google()
/// const DabblerProviderMark.apple(size: 24)
/// ```
///
/// ## What it draws
///
/// The vendors' own PNG tiles, bundled under `assets/provider_marks/` as
/// resolution-aware assets (base = 1x, `2.0x/`, `3.0x/`, `4.0x/`) and loaded
/// with `AssetImage(package: 'dabbler_design_system')`. Nothing is recoloured,
/// cropped, rounded, tinted or redrawn: the tile is the artwork.
///
/// | Vendor | Light surface | Dark surface | Native size | Source |
/// | --- | --- | --- | --- | --- |
/// | Google | light tile | dark tile | 40 x 40 | Google Identity `signin-assets.zip`, "Show text = No, Shape = Square", Android + Web |
/// | Apple | black tile | white tile | 44 x 44 | "Logo Only", Sign in with Apple resources |
///
/// The tile follows the resolved [DabblerColors.brightness] — the way every
/// component here reads it — so a mark on a dark theme gets the dark Google
/// tile and the white Apple tile.
///
/// Design source: `Auth and Onboarding.dc.html:123-125, 164-166, 195-197`
/// (the Google and Apple buttons; the design draws them as plain outlined
/// buttons with no vendor art, so the art is taken from the vendors, not the
/// design).
///
/// ## Deviations (recorded, not silent)
///
/// * **PNG, not SVG.** The vendors' SVGs cannot be bundled: Google's is a
///   Figma export built on `foreignObject`, a CSS `conic-gradient` and blur
///   filters, none of which Flutter renders; Apple's carries an embedded white
///   rectangle. The official PNG tiles are bundled instead.
/// * **"Monochrome following the text colour" is realised as a black or white
///   tile chosen by brightness.** Apple's resource ships those two tiles; the
///   mark is not tinted by the text colour.
/// * **The tile carries vendor colour.** The G's four colours and the tile
///   fill and stroke are vendor artwork, not [DabblerColors] roles; see the
///   docs page's Exception section.
///
/// ## Size
///
/// [size] is the logical edge of the square mark. The default is the tile's
/// native logical size: [googleNativeSize] (40) or [appleNativeSize] (44).
/// Scaling keeps the 1:1 aspect ratio; do not stretch.
///
/// ## Usage rule (Google)
///
/// Google's guidelines forbid the icon by itself, without a button boundary or
/// text saying what the action is. Place this mark inside a button whose label
/// names the action ("Continue with Google").
///
/// ## Accessibility
///
/// The mark is announced as "Google" or "Apple" ([semanticLabel] overrides).
/// When it sits in a button whose own label already names the provider, pass
/// [excludeFromSemantics] so the vendor is not read twice.
///
/// RTL: the mark is symmetric artwork and is never mirrored.
class DabblerProviderMark extends StatelessWidget {
  /// Creates a mark for [vendor].
  const DabblerProviderMark({
    super.key,
    required this.vendor,
    this.size,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  /// Google's official "G" tile.
  const DabblerProviderMark.google({
    Key? key,
    double? size,
    String? semanticLabel,
    bool excludeFromSemantics = false,
  }) : this(
         key: key,
         vendor: DabblerProviderMarkVendor.google,
         size: size,
         semanticLabel: semanticLabel,
         excludeFromSemantics: excludeFromSemantics,
       );

  /// Apple's official logo tile.
  const DabblerProviderMark.apple({
    Key? key,
    double? size,
    String? semanticLabel,
    bool excludeFromSemantics = false,
  }) : this(
         key: key,
         vendor: DabblerProviderMarkVendor.apple,
         size: size,
         semanticLabel: semanticLabel,
         excludeFromSemantics: excludeFromSemantics,
       );

  /// Google's tile edge at 1x, in logical pixels.
  static const double googleNativeSize = 40;

  /// Apple's tile edge at 1x, in logical pixels.
  static const double appleNativeSize = 44;

  /// The package the bundled tiles belong to.
  static const String assetPackage = 'dabbler_design_system';

  /// Which vendor's mark to draw.
  final DabblerProviderMarkVendor vendor;

  /// The logical edge of the square mark; null is the vendor's native size.
  final double? size;

  /// Overrides the announced name ("Google" / "Apple").
  final String? semanticLabel;

  /// True when an enclosing control already names the provider.
  final bool excludeFromSemantics;

  /// The 1x asset path (without package prefix) for [vendor] at [brightness].
  /// Higher densities resolve from the `2.0x/`, `3.0x/`, `4.0x/` siblings.
  static String assetFor(
    DabblerProviderMarkVendor vendor,
    Brightness brightness,
  ) {
    final bool dark = brightness == Brightness.dark;
    switch (vendor) {
      case DabblerProviderMarkVendor.google:
        return 'assets/provider_marks/${dark ? 'google-dark' : 'google-light'}.png';
      case DabblerProviderMarkVendor.apple:
        return 'assets/provider_marks/${dark ? 'apple-white' : 'apple-black'}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = DabblerColors.of(context).brightness;
    final double edge =
        size ??
        (vendor == DabblerProviderMarkVendor.google
            ? googleNativeSize
            : appleNativeSize);
    final Widget image = Image(
      image: AssetImage(assetFor(vendor, brightness), package: assetPackage),
      width: edge,
      height: edge,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    );
    if (excludeFromSemantics) return ExcludeSemantics(child: image);
    return Semantics(
      label:
          semanticLabel ??
          (vendor == DabblerProviderMarkVendor.google ? 'Google' : 'Apple'),
      image: true,
      child: ExcludeSemantics(child: image),
    );
  }
}
