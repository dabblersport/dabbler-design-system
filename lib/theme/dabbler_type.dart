// =============================================================================
// Dabbler — Typography (Apple HIG ramp in Readex Pro)
// Version 1.0
// -----------------------------------------------------------------------------
// Sizes, leading, and weights follow Apple's Human Interface Guidelines text
// styles (Large Title → Caption 2). Tracking is near-zero — Apple's per-size
// tracking is hand-tuned for SF Pro, so it is intentionally NOT copied here.
// Readex Pro carries BOTH Latin and Arabic in the same files, so no separate
// Arabic face is needed; Arabic only takes a slightly taller leading.
//
//   ThemeData(textTheme: dabblerTextThemeFor(locale), ...)
//   Text('Join game', style: DabblerType.headline)
//
// Mirrors dabbler_type.css. Pairs with the color system (dabbler_colors.dart).
// =============================================================================

import 'package:flutter/material.dart';

/// Font family as declared in pubspec.yaml (see the fonts: block).
const String kDabblerFontFamily = 'ReadexPro';

/// Arabic needs a touch more line-height for comfortable rendering.
const double kArabicLeadingScale = 1.18;

/// Apple HIG type ramp, rendered in Readex Pro.
abstract final class DabblerType {
  DabblerType._();

  static const _f = kDabblerFontFamily;
  static const _reg = FontWeight.w400;
  static const _med = FontWeight.w500;
  static const _semi = FontWeight.w600;
  static const _bold = FontWeight.w700;

  // leading (pt) / size (pt) = Flutter height multiplier.
  static TextStyle _s(double size, double leading, FontWeight w) => TextStyle(
        fontFamily: _f,
        fontSize: size,
        height: leading / size,
        fontWeight: w,
        letterSpacing: 0,
        // color is intentionally null — text inherits onSurface from the theme.
      );

  // Apple text styles at the default Dynamic Type size.
  static final TextStyle largeTitle  = _s(34, 41, _reg);
  static final TextStyle title1      = _s(28, 34, _reg);
  static final TextStyle title2      = _s(22, 28, _reg);
  static final TextStyle title3      = _s(20, 25, _reg);
  static final TextStyle headline    = _s(17, 22, _semi);
  static final TextStyle body        = _s(17, 22, _reg);
  static final TextStyle callout     = _s(16, 21, _reg);
  static final TextStyle subheadline = _s(15, 20, _reg);
  static final TextStyle footnote    = _s(13, 18, _reg);
  static final TextStyle caption1    = _s(12, 16, _reg);
  static final TextStyle caption2    = _s(11, 13, _reg);

  /// Apple's "emphasized" trait — same style, heavier weight.
  static TextStyle emphasized(TextStyle s) => s.copyWith(fontWeight: _semi);
  static TextStyle bold(TextStyle s) => s.copyWith(fontWeight: _bold);

  /// Apply Arabic leading to any style.
  static TextStyle arabic(TextStyle s) =>
      s.copyWith(height: (s.height ?? 1.0) * kArabicLeadingScale, letterSpacing: 0);
}

/// Builds the Flutter M3 TextTheme from the Apple ramp.
/// Each Apple style maps onto the closest M3 slot so Material widgets inherit it.
TextTheme dabblerTextTheme({bool arabic = false}) {
  TextStyle a(TextStyle s) => arabic ? DabblerType.arabic(s) : s;
  return TextTheme(
    // Display ← Large Title / Title 1 / Title 2
    displayLarge:  a(DabblerType.largeTitle),
    displayMedium: a(DabblerType.title1),
    displaySmall:  a(DabblerType.title2),
    // Headline ← Title 1 / Title 2 / Title 3
    headlineLarge:  a(DabblerType.title1),
    headlineMedium: a(DabblerType.title2),
    headlineSmall:  a(DabblerType.title3),
    // Title ← Title 3 / Headline / Subheadline
    titleLarge:  a(DabblerType.title3),
    titleMedium: a(DabblerType.headline),
    titleSmall:  a(DabblerType.subheadline),
    // Body ← Body / Callout / Footnote
    bodyLarge:  a(DabblerType.body),
    bodyMedium: a(DabblerType.callout),
    bodySmall:  a(DabblerType.footnote),
    // Label ← Headline (buttons, 17/600) / Footnote / Caption 2
    labelLarge:  a(DabblerType.headline),
    labelMedium: a(DabblerType.footnote.copyWith(fontWeight: DabblerType._med)),
    labelSmall:  a(DabblerType.caption2.copyWith(fontWeight: DabblerType._med)),
  );
}

/// Pick the right TextTheme for the active locale (Arabic → taller leading).
TextTheme dabblerTextThemeFor(Locale locale) =>
    dabblerTextTheme(arabic: locale.languageCode == 'ar');

// -----------------------------------------------------------------------------
// Gallery specimen — drop into the Theme Gallery to verify the ramp.
// -----------------------------------------------------------------------------
class DabblerTypeSpecimen extends StatelessWidget {
  const DabblerTypeSpecimen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(String, TextStyle)>[
      ('Large Title', DabblerType.largeTitle),
      ('Title 1', DabblerType.title1),
      ('Title 2', DabblerType.title2),
      ('Title 3', DabblerType.title3),
      ('Headline', DabblerType.headline),
      ('Body', DabblerType.body),
      ('Callout', DabblerType.callout),
      ('Subheadline', DabblerType.subheadline),
      ('Footnote', DabblerType.footnote),
      ('Caption 1', DabblerType.caption1),
      ('Caption 2', DabblerType.caption2),
    ];
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, i) {
        final (name, style) = items[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name.toUpperCase(),
              style: TextStyle(fontSize: 11, color: muted, letterSpacing: 0.6),
            ),
            const SizedBox(height: 4),
            Text('Sport belongs to everyone', style: style),
            const SizedBox(height: 2),
            Text(
              'الرياضة لكل من يحضر',
              textDirection: TextDirection.rtl,
              style: DabblerType.arabic(style),
            ),
          ],
        );
      },
    );
  }
}
