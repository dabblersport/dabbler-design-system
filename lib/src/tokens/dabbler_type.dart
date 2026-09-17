import 'package:flutter/widgets.dart';

/// The type ramp of the Dabbler design system.
///
/// Every value here is transcribed from the design source
/// `tokens/typography.css`: the `.t-*` rules give each named style its size,
/// leading and weight, and the `[dir="rtl"]` block gives the Arabic leading
/// overrides.
///
/// This class is a **plain const class, not a `ThemeExtension`**. Geometry and
/// type do not vary by theme — the seven Dabbler themes differ in colour only —
/// so the ramp is a compile-time constant rather than a value resolved off a
/// [BuildContext]. (Colour, which does vary, lives in the palette layer.)
///
/// ## Two roles × two scripts
///
/// The source declares four faces on two roles. The **role** never changes;
/// only the **script** swaps with text direction:
///
/// | Role | Latin | Arabic |
/// |---|---|---|
/// | display — large title and titles 1–3 | Gloock | Wingx |
/// | sans — everything else | Glory | Meral Sans |
///
/// Gloock and Wingx each ship a single weight (400), so **every title style is
/// weight 400 in both scripts** — titles never run Light and never run Bold.
///
/// ## FREEZE — in effect now, bounded, `DECISIONS.md` D-024(3)
///
/// `cxo` measured the design source on 2026-09-17 and found it specifies type
/// **three** different ways across 79 components: 30 on `.t-*` from
/// `tokens/typography.css`, 13 on `--font-size-*` from the Figma export
/// `tokens/figma/fig-tokens.css`, and 25 on raw inline literals. Those are two
/// genuinely different ramps — `typography.css` is HIG-shaped and carries no
/// 14 at all; the Figma file's body size *is* 14. Which one the product's type
/// actually is is escalated to the CEO as the design source (KAN-281).
///
/// Until that is resolved, and to stop the split widening while it is decided:
///
/// * **No new ramp constants** are added to this class.
/// * **No component's private scale is promoted into `typography.css`** — a
///   ramp step earns its place by being a role the system names and several
///   unrelated things reach for, not by one component parking a value.
/// * **No further transcription of `--font-size-*` from `fig-tokens.css`**,
///   which D-024(c) rules an export artefact — a diagnostic, never a source of
///   truth.
///
/// **New work uses the `.t-*` ramp.** Where it genuinely cannot, it
/// **transcribes the source's value literally, with a comment naming D-024** —
/// exactly as `DabblerCalendarTextAction` already did for its own gap, and as
/// `DabblerButtonMetrics.labelStyle` does for 16/14/12-at-600. A literal value
/// with a stated provenance is the wanted behaviour here; inventing a ramp
/// step is not.
///
/// **A freeze is not a decision** — it holds the line while the decision is
/// made. It lifts when KAN-281 is answered, and not by anyone else.
///
/// ## Structure only
///
/// DS-103a delivers the ramp's structure. The font binaries, and therefore any
/// claim about real glyph coverage or family resolution, are DS-103b's — see
/// [fontFamilyFor], which builds the qualified `packages/…` family name the
/// binaries will be registered under once they land.
abstract final class DabblerType {
  const DabblerType._();

  /// The package the font binaries are (will be) registered under.
  static const String package = 'dabbler_design_system';

  // --- The four faces ---

  /// Latin display face — `--font-display-en`.
  static const String displayLatinFamily = 'Gloock';

  /// Arabic display face — `--font-display-ar`.
  static const String displayArabicFamily = 'Wingx';

  /// Latin text face — `--font-sans-en`.
  static const String sansLatinFamily = 'Glory';

  /// Arabic text face — `--font-sans-ar`.
  static const String sansArabicFamily = 'Meral Sans';

  /// Concrete fallback families for the display role, after the bare name.
  ///
  /// The CSS generic keywords (`serif`, `system-ui`, `-apple-system`) are
  /// deliberately not carried over: they are not font family names Flutter can
  /// resolve.
  static const List<String> displayFallbacks = <String>[
    'Georgia',
    'Times New Roman',
  ];

  /// Concrete fallback families for the sans role, after the bare name.
  static const List<String> sansFallbacks = <String>[];

  // --- Weights ---

  /// `--weight-light`.
  static const FontWeight light = FontWeight.w300;

  /// `--weight-regular`.
  static const FontWeight regular = FontWeight.w400;

  /// `--weight-medium`.
  static const FontWeight medium = FontWeight.w500;

  /// `--weight-semibold`.
  static const FontWeight semibold = FontWeight.w600;

  /// `--weight-bold`.
  static const FontWeight bold = FontWeight.w700;

  // --- The ramp ---

  /// `.t-large-title` — 34/41, weight 400, display role.
  static const DabblerTypeStyle largeTitle = DabblerTypeStyle(
    name: 'largeTitle',
    role: DabblerTypeRole.display,
    fontSize: 34,
    latinLeading: 41,
    arabicLeading: 41,
    fontWeight: regular,
  );

  /// `.t-title-1` — 28/34, weight 400, display role.
  static const DabblerTypeStyle title1 = DabblerTypeStyle(
    name: 'title1',
    role: DabblerTypeRole.display,
    fontSize: 28,
    latinLeading: 34,
    arabicLeading: 34,
    fontWeight: regular,
  );

  /// `.t-title-2` — 22/28, weight 400, display role.
  static const DabblerTypeStyle title2 = DabblerTypeStyle(
    name: 'title2',
    role: DabblerTypeRole.display,
    fontSize: 22,
    latinLeading: 28,
    arabicLeading: 28,
    fontWeight: regular,
  );

  /// `.t-title-3` — 20/25, weight 400, display role.
  static const DabblerTypeStyle title3 = DabblerTypeStyle(
    name: 'title3',
    role: DabblerTypeRole.display,
    fontSize: 20,
    latinLeading: 25,
    arabicLeading: 25,
    fontWeight: regular,
  );

  /// `.t-headline` — 17/22, weight 600, sans role. Arabic leading 25.
  static const DabblerTypeStyle headline = DabblerTypeStyle(
    name: 'headline',
    role: DabblerTypeRole.sans,
    fontSize: 17,
    latinLeading: 22,
    arabicLeading: 25,
    fontWeight: semibold,
  );

  /// `.t-body` — 16/21, weight 400, sans role. Arabic leading 24.
  static const DabblerTypeStyle body = DabblerTypeStyle(
    name: 'body',
    role: DabblerTypeRole.sans,
    fontSize: 16,
    latinLeading: 21,
    arabicLeading: 24,
    fontWeight: regular,
  );

  /// `.t-callout` — 17/22, weight 500, sans role. Arabic leading 25.
  static const DabblerTypeStyle callout = DabblerTypeStyle(
    name: 'callout',
    role: DabblerTypeRole.sans,
    fontSize: 17,
    latinLeading: 22,
    arabicLeading: 25,
    fontWeight: medium,
  );

  /// `.t-subheadline` — 15/20, weight 400, sans role. Arabic leading 23.
  static const DabblerTypeStyle subheadline = DabblerTypeStyle(
    name: 'subheadline',
    role: DabblerTypeRole.sans,
    fontSize: 15,
    latinLeading: 20,
    arabicLeading: 23,
    fontWeight: regular,
  );

  /// `.t-footnote` — 13/18, weight 400, sans role.
  static const DabblerTypeStyle footnote = DabblerTypeStyle(
    name: 'footnote',
    role: DabblerTypeRole.sans,
    fontSize: 13,
    latinLeading: 18,
    arabicLeading: 18,
    fontWeight: regular,
  );

  /// `.t-caption-1` — 12/16, weight 400, sans role.
  static const DabblerTypeStyle caption1 = DabblerTypeStyle(
    name: 'caption1',
    role: DabblerTypeRole.sans,
    fontSize: 12,
    latinLeading: 16,
    arabicLeading: 16,
    fontWeight: regular,
  );

  /// `.t-caption-2` — 11/13, weight 400, sans role.
  static const DabblerTypeStyle caption2 = DabblerTypeStyle(
    name: 'caption2',
    role: DabblerTypeRole.sans,
    fontSize: 11,
    latinLeading: 13,
    arabicLeading: 13,
    fontWeight: regular,
  );

  /// `.t-label` — 17/22, weight 500, sans role. The button/label convenience:
  /// headline metrics at Medium.
  static const DabblerTypeStyle label = DabblerTypeStyle(
    name: 'label',
    role: DabblerTypeRole.sans,
    fontSize: 17,
    latinLeading: 22,
    arabicLeading: 22,
    fontWeight: medium,
  );

  /// Every named style of the ramp, in source order.
  static const List<DabblerTypeStyle> styles = <DabblerTypeStyle>[
    largeTitle,
    title1,
    title2,
    title3,
    headline,
    body,
    callout,
    subheadline,
    footnote,
    caption1,
    caption2,
    label,
  ];

  /// The only four styles that take additional leading in Arabic.
  ///
  /// Meral Sans needs more vertical room than Glory on running text. Titles,
  /// footnote and the captions share Latin's leading exactly.
  static const List<String> arabicExtraLeadingStyles = <String>[
    'headline',
    'body',
    'callout',
    'subheadline',
  ];

  // --- Numerals ---

  /// Numerals are **always** Western Arabic (`0`–`9`), never Eastern
  /// Arabic-Indic (`٠`–`٩`), in both scripts.
  ///
  /// Two halves, both required. These features stop an Arabic-aware face from
  /// substituting Indic forms at render time; [toWesternDigits] is the source
  /// half — the formatter that produces the string in the first place.
  static const List<FontFeature> numeralFeatures = <FontFeature>[
    FontFeature.disable('anum'),
    FontFeature.liningFigures(),
  ];

  /// Eastern Arabic-Indic `٠`–`٩` (U+0660–U+0669).
  static const int _arabicIndicZero = 0x0660;

  /// Extended Arabic-Indic `۰`–`۹` (U+06F0–U+06F9), used by Persian/Urdu faces.
  static const int _extendedArabicIndicZero = 0x06F0;

  /// Rewrites any Arabic-Indic digit in [input] to its Western Arabic (`0`–`9`)
  /// equivalent, leaving every other character untouched.
  ///
  /// This is the *source* half of the numerals rule: text handed to a Dabbler
  /// style always carries Western digits, whatever the locale of the data or
  /// of the device.
  static String toWesternDigits(String input) {
    const int asciiZero = 0x30;
    return String.fromCharCodes(<int>[
      for (final int code in input.runes)
        if (code >= _arabicIndicZero && code <= _arabicIndicZero + 9)
          asciiZero + (code - _arabicIndicZero)
        else if (code >= _extendedArabicIndicZero &&
            code <= _extendedArabicIndicZero + 9)
          asciiZero + (code - _extendedArabicIndicZero)
        else
          code,
    ]);
  }

  // --- Families ---

  /// The qualified family name for [role] in [script].
  ///
  /// Qualified as `packages/dabbler_design_system/<family>`, which is how a
  /// font shipped inside this package is addressed from a consuming app. The
  /// bare family name goes in `fontFamilyFallback` (see [fontFamilyFallbackFor])
  /// so a host app that has registered the face itself still resolves it.
  ///
  /// Structure only: nothing resolves until DS-103b lands the binaries and
  /// declares them in `pubspec.yaml`.
  static String fontFamilyFor(DabblerTypeRole role, DabblerTypeScript script) =>
      'packages/$package/${bareFamilyFor(role, script)}';

  /// The unqualified family name for [role] in [script].
  static String bareFamilyFor(DabblerTypeRole role, DabblerTypeScript script) {
    switch (role) {
      case DabblerTypeRole.display:
        return script == DabblerTypeScript.arabic
            ? displayArabicFamily
            : displayLatinFamily;
      case DabblerTypeRole.sans:
        return script == DabblerTypeScript.arabic
            ? sansArabicFamily
            : sansLatinFamily;
    }
  }

  /// The fallback chain for [role] in [script]: the bare family first, then the
  /// concrete faces the source names.
  static List<String> fontFamilyFallbackFor(
    DabblerTypeRole role,
    DabblerTypeScript script,
  ) => <String>[
    bareFamilyFor(role, script),
    ...(role == DabblerTypeRole.display ? displayFallbacks : sansFallbacks),
  ];
}

/// Which of the two roles a style is set in. The role is fixed per style and
/// never changes with direction.
enum DabblerTypeRole {
  /// Large title and titles 1–3 — Gloock (Latin) / Wingx (Arabic).
  display,

  /// Everything else — Glory (Latin) / Meral Sans (Arabic).
  sans,
}

/// Which script a style is being resolved for. Direction picks the face; the
/// sizes are identical in both.
enum DabblerTypeScript {
  /// Latin (LTR).
  latin,

  /// Arabic (RTL).
  arabic,
}

/// One named step of the [DabblerType] ramp.
///
/// Carries the ramp's structure — size, leading per script, weight and role —
/// and resolves to a [TextStyle] on demand. Tracking is near-zero on purpose,
/// so [letterSpacing] is `0` on every style.
@immutable
class DabblerTypeStyle {
  const DabblerTypeStyle({
    required this.name,
    required this.role,
    required this.fontSize,
    required this.latinLeading,
    required this.arabicLeading,
    required this.fontWeight,
    this.letterSpacing = 0,
  });

  /// The style's name, matching the `.t-*` class it was transcribed from.
  final String name;

  /// Which face role the style is set in.
  final DabblerTypeRole role;

  /// Size in logical pixels. Identical in both scripts — Wingx and Gloock read
  /// at matching optical weight, so Arabic takes no size bump.
  final double fontSize;

  /// Leading (line box height) in logical pixels, Latin.
  final double latinLeading;

  /// Leading in logical pixels, Arabic. Equal to [latinLeading] on every style
  /// except the four in [DabblerType.arabicExtraLeadingStyles].
  final double arabicLeading;

  /// The style's weight. Always [DabblerType.regular] on a display-role style,
  /// in both scripts.
  final FontWeight fontWeight;

  /// Tracking, near-zero throughout.
  final double letterSpacing;

  /// Leading for [script], in logical pixels.
  double leadingFor(DabblerTypeScript script) =>
      script == DabblerTypeScript.arabic ? arabicLeading : latinLeading;

  /// Whether Arabic takes additional leading on this style.
  bool get takesArabicExtraLeading => arabicLeading > latinLeading;

  /// Resolves the step to a [TextStyle] for [script].
  ///
  /// [TextStyle.height] is a multiple of [fontSize], so the CSS pixel leading is
  /// divided through; [TextStyle.leadingDistribution] is set to
  /// [TextLeadingDistribution.even] so the extra room lands evenly above and
  /// below, as a CSS line box distributes it.
  TextStyle resolve([DabblerTypeScript script = DabblerTypeScript.latin]) =>
      TextStyle(
        fontFamily: DabblerType.fontFamilyFor(role, script),
        fontFamilyFallback: DabblerType.fontFamilyFallbackFor(role, script),
        fontSize: fontSize,
        height: leadingFor(script) / fontSize,
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        fontFeatures: DabblerType.numeralFeatures,
      );

  /// Resolves the step for the script implied by [direction].
  TextStyle resolveForDirection(TextDirection direction) => resolve(
    direction == TextDirection.rtl
        ? DabblerTypeScript.arabic
        : DabblerTypeScript.latin,
  );

  @override
  String toString() => 'DabblerTypeStyle($name)';
}
