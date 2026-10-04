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
/// ## D-024 AMENDED (2026-10-04, KAN-426)
///
/// **D-024 (type ramp frozen) is amended: the design is the source of truth.**
/// Roles the design frames use were added on 2026-10-04 as
/// [DabblerType.frameRoles]; the ramp may grow only from design frames. The
/// twelve `.t-*` [DabblerType.styles] are unchanged. The freeze text below is
/// kept as history and still governs anything that is *not* a design frame.
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
/// exactly as `DabblerButton.labelStyle` does for 16/14/12-at-600. A literal value
/// with a stated provenance is the wanted behaviour here; inventing a ramp
/// step is not.
///
/// **A freeze is not a decision** — it holds the line while the decision is
/// made. It lifts when KAN-281 is answered, and not by anyone else.
///
/// ## Arabic size and the live header's contradiction
///
/// Arabic is the Latin size less 0.9px on all twelve styles
/// ([DabblerTypeStyle.arabicFontSize]), as the RTL block of the live
/// `tokens/typography.css` (1.2.0) declares each one. That file's own header
/// still says Arabic "runs the SAME sizes as Latin"; the declarations render and
/// the header is prose about them, so the declarations govern. The
/// inconsistency lives in the design source and is recorded here rather than
/// edited there. Arabic leading is separate and unchanged (see
/// [DabblerTypeStyle.arabicLeading]). Components that take a size from a step
/// inherit the offset; an explicit pixel override keeps its Latin pixels in
/// RTL unless that component's own live CSS offsets it too.
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
    arabicFontSize: 33.1,
    latinLeading: 41,
    arabicLeading: 41,
    fontWeight: regular,
  );

  /// `.t-title-1` — 28/34, weight 400, display role.
  static const DabblerTypeStyle title1 = DabblerTypeStyle(
    name: 'title1',
    role: DabblerTypeRole.display,
    fontSize: 28,
    arabicFontSize: 27.1,
    latinLeading: 34,
    arabicLeading: 34,
    fontWeight: regular,
  );

  /// `.t-title-2` — 22/28, weight 400, display role.
  static const DabblerTypeStyle title2 = DabblerTypeStyle(
    name: 'title2',
    role: DabblerTypeRole.display,
    fontSize: 22,
    arabicFontSize: 21.1,
    latinLeading: 28,
    arabicLeading: 28,
    fontWeight: regular,
  );

  /// `.t-title-3` — 20/25, weight 400, display role.
  static const DabblerTypeStyle title3 = DabblerTypeStyle(
    name: 'title3',
    role: DabblerTypeRole.display,
    fontSize: 20,
    arabicFontSize: 19.1,
    latinLeading: 25,
    arabicLeading: 25,
    fontWeight: regular,
  );

  /// `.t-headline` — 17/22, weight 600, sans role. Arabic leading 25.
  static const DabblerTypeStyle headline = DabblerTypeStyle(
    name: 'headline',
    role: DabblerTypeRole.sans,
    fontSize: 17,
    arabicFontSize: 16.1,
    latinLeading: 22,
    arabicLeading: 25,
    fontWeight: semibold,
  );

  /// `.t-body` — 16/21, weight 400, sans role. Arabic leading 24.
  static const DabblerTypeStyle body = DabblerTypeStyle(
    name: 'body',
    role: DabblerTypeRole.sans,
    fontSize: 16,
    arabicFontSize: 15.1,
    latinLeading: 21,
    arabicLeading: 24,
    fontWeight: regular,
  );

  /// `.t-callout` — 17/22, weight 500, sans role. Arabic leading 25.
  static const DabblerTypeStyle callout = DabblerTypeStyle(
    name: 'callout',
    role: DabblerTypeRole.sans,
    fontSize: 17,
    arabicFontSize: 16.1,
    latinLeading: 22,
    arabicLeading: 25,
    fontWeight: medium,
  );

  /// `.t-subheadline` — 15/20, weight 400, sans role. Arabic leading 23.
  static const DabblerTypeStyle subheadline = DabblerTypeStyle(
    name: 'subheadline',
    role: DabblerTypeRole.sans,
    fontSize: 15,
    arabicFontSize: 14.1,
    latinLeading: 20,
    arabicLeading: 23,
    fontWeight: regular,
  );

  /// `.t-footnote` — 13/18, weight 400, sans role.
  static const DabblerTypeStyle footnote = DabblerTypeStyle(
    name: 'footnote',
    role: DabblerTypeRole.sans,
    fontSize: 13,
    arabicFontSize: 12.1,
    latinLeading: 18,
    arabicLeading: 18,
    fontWeight: regular,
  );

  /// `.t-caption-1` — 12/16, weight 400, sans role.
  static const DabblerTypeStyle caption1 = DabblerTypeStyle(
    name: 'caption1',
    role: DabblerTypeRole.sans,
    fontSize: 12,
    arabicFontSize: 11.1,
    latinLeading: 16,
    arabicLeading: 16,
    fontWeight: regular,
  );

  /// `.t-caption-2` — 11/13, weight 400, sans role.
  static const DabblerTypeStyle caption2 = DabblerTypeStyle(
    name: 'caption2',
    role: DabblerTypeRole.sans,
    fontSize: 11,
    arabicFontSize: 10.1,
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
    arabicFontSize: 16.1,
    latinLeading: 22,
    arabicLeading: 22,
    fontWeight: medium,
  );

  // --- Frame roles (KAN-426, 2026-10-04) ---
  //
  // The design is the source of truth: D-024 is amended (see [frameRoles]).
  // Each role below is a size/leading the design frames set and the twelve
  // `.t-*` steps cannot express. Arabic is Latin less 0.9px (the live RTL
  // rule); Arabic leading is the design's own Arabic frame where one exists,
  // else the Latin leading.
  /// Hero display — 40/46, weight 400, display role. `Auth and Onboarding.dc.html:305` ("You're in."), `:673`.
  static const DabblerTypeStyle displayHero = DabblerTypeStyle(
    name: 'displayHero',
    role: DabblerTypeRole.display,
    fontSize: 40,
    arabicFontSize: 39.1,
    latinLeading: 46,
    arabicLeading: 46,
    fontWeight: regular,
  );

  /// Welcome headline — 36/42, weight 400, display role. `Auth and Onboarding.dc.html:509` (`doneHeadline`).
  static const DabblerTypeStyle displayWelcome = DabblerTypeStyle(
    name: 'displayWelcome',
    role: DabblerTypeRole.display,
    fontSize: 36,
    arabicFontSize: 35.1,
    latinLeading: 42,
    arabicLeading: 42,
    fontWeight: regular,
  );

  /// Screen title — 34/40, weight 400, display role. `Auth and Onboarding.dc.html:101,155,188,218,292` and the Details/Listings headers; [largeTitle] is the same size at 41.
  static const DabblerTypeStyle displayScreen = DabblerTypeStyle(
    name: 'displayScreen',
    role: DabblerTypeRole.display,
    fontSize: 34,
    arabicFontSize: 33.1,
    latinLeading: 40,
    arabicLeading: 40,
    fontWeight: regular,
  );

  /// Onboarding step title — 30/36, weight 400, display role. `Auth and Onboarding.dc.html:345,460`. The Arabic frame sets it at 40 (`:1003`, `30/40`), so Arabic takes +4 leading.
  static const DabblerTypeStyle displayStep = DabblerTypeStyle(
    name: 'displayStep',
    role: DabblerTypeRole.display,
    fontSize: 30,
    arabicFontSize: 29.1,
    latinLeading: 36,
    arabicLeading: 40,
    fontWeight: regular,
  );

  /// Section display — 26/32, weight 400, display role. `Auth and Onboarding.dc.html:256` (`providerTitle`).
  static const DabblerTypeStyle displaySection = DabblerTypeStyle(
    name: 'displaySection',
    role: DabblerTypeRole.display,
    fontSize: 26,
    arabicFontSize: 25.1,
    latinLeading: 32,
    arabicLeading: 32,
    fontWeight: regular,
  );

  /// Profile statistic — 42/46, weight 400, display role. `Sport Profile v2.dc.html:60` (the sport name heading).
  static const DabblerTypeStyle displayStat = DabblerTypeStyle(
    name: 'displayStat',
    role: DabblerTypeRole.display,
    fontSize: 42,
    arabicFontSize: 41.1,
    latinLeading: 46,
    arabicLeading: 46,
    fontWeight: regular,
  );

  /// Profile hero statistic — 56/56, weight 400, display role. `Sport Profile v2.dc.html:92` (minutes figure).
  static const DabblerTypeStyle displayStatHero = DabblerTypeStyle(
    name: 'displayStatHero',
    role: DabblerTypeRole.display,
    fontSize: 56,
    arabicFontSize: 55.1,
    latinLeading: 56,
    arabicLeading: 56,
    fontWeight: regular,
  );

  /// Profile statistic, mid — 34/36, weight 400, display role.
  /// `Sport Profile v2.dc.html:146` (matches figure).
  static const DabblerTypeStyle displayStatMid = DabblerTypeStyle(
    name: 'displayStatMid',
    role: DabblerTypeRole.display,
    fontSize: 34,
    arabicFontSize: 33.1,
    latinLeading: 36,
    arabicLeading: 36,
    fontWeight: regular,
  );

  /// Profile statistic, small — 30/32, weight 400, display role.
  /// `Sport Profile v2.dc.html:118` (per-day minutes).
  static const DabblerTypeStyle displayStatSmall = DabblerTypeStyle(
    name: 'displayStatSmall',
    role: DabblerTypeRole.display,
    fontSize: 30,
    arabicFontSize: 29.1,
    latinLeading: 32,
    arabicLeading: 32,
    fontWeight: regular,
  );

  /// Rail label — 18/23, weight 400, display role. `Listings.dc.html:116,424` ("Upcoming" over a listing's countdown rail).
  static const DabblerTypeStyle displayLabel = DabblerTypeStyle(
    name: 'displayLabel',
    role: DabblerTypeRole.display,
    fontSize: 18,
    arabicFontSize: 17.1,
    latinLeading: 23,
    arabicLeading: 23,
    fontWeight: regular,
  );

  /// Large lead — 19/27, weight 400, sans role. `Auth and Onboarding.dc.html:77` (landing "want" line), `:510` and `:827` at weight 600 via `DabblerText.weight`.
  static const DabblerTypeStyle leadLarge = DabblerTypeStyle(
    name: 'leadLarge',
    role: DabblerTypeRole.sans,
    fontSize: 19,
    arabicFontSize: 18.1,
    latinLeading: 27,
    arabicLeading: 27,
    fontWeight: regular,
  );

  /// Lead / subtitle — 17/24, weight 400, sans role. `Auth and Onboarding.dc.html:102,156,189,219,293,306` (screen subtitles). Arabic leading 25 as [headline].
  static const DabblerTypeStyle lead = DabblerTypeStyle(
    name: 'lead',
    role: DabblerTypeRole.sans,
    fontSize: 17,
    arabicFontSize: 16.1,
    latinLeading: 24,
    arabicLeading: 25,
    fontWeight: regular,
  );

  /// Row title — 17/23, weight 500, sans role. `Auth and Onboarding.dc.html:421,503,772`. Arabic leading 25 (`:1036`, `17/25`).
  static const DabblerTypeStyle rowTitle = DabblerTypeStyle(
    name: 'rowTitle',
    role: DabblerTypeRole.sans,
    fontSize: 17,
    arabicFontSize: 16.1,
    latinLeading: 23,
    arabicLeading: 25,
    fontWeight: medium,
  );

  /// Copy — 15/21, weight 400, sans role. The dominant body size of `Auth and Onboarding.dc.html` (`:108-118,131,311-319,461`); links at weight 500 via `DabblerText.weight`. Arabic leading 24 (`:1004,1075`, `15/24`).
  static const DabblerTypeStyle copy = DabblerTypeStyle(
    name: 'copy',
    role: DabblerTypeRole.sans,
    fontSize: 15,
    arabicFontSize: 14.1,
    latinLeading: 21,
    arabicLeading: 24,
    fontWeight: regular,
  );

  /// Small — 14/20, weight 400, sans role. `Auth and Onboarding.dc.html:85,226,384,428` (role and link text). Arabic leading 22 (`:1037`, `14/22`).
  static const DabblerTypeStyle small = DabblerTypeStyle(
    name: 'small',
    role: DabblerTypeRole.sans,
    fontSize: 14,
    arabicFontSize: 13.1,
    latinLeading: 20,
    arabicLeading: 22,
    fontWeight: regular,
  );

  /// Small, tight — 14/19, weight 400, sans role. `Listings.dc.html`, `Details.dc.html`, `Profiles.dc.html`, `Sport Profile v2.dc.html` (card meta and rows; weight 600 via `DabblerText.weight`). Arabic leading 22.
  static const DabblerTypeStyle smallTight = DabblerTypeStyle(
    name: 'smallTight',
    role: DabblerTypeRole.sans,
    fontSize: 14,
    arabicFontSize: 13.1,
    latinLeading: 19,
    arabicLeading: 22,
    fontWeight: regular,
  );

  /// Small, relaxed — 14/21, weight 400, sans role. `Auth and Onboarding.dc.html:773` (persona body), `Listings.dc.html`, `Favourites.dc.html`. Arabic leading 22 (`:1037`).
  static const DabblerTypeStyle smallRelaxed = DabblerTypeStyle(
    name: 'smallRelaxed',
    role: DabblerTypeRole.sans,
    fontSize: 14,
    arabicFontSize: 13.1,
    latinLeading: 21,
    arabicLeading: 22,
    fontWeight: regular,
  );

  /// Footnote, tight — 13/17, weight 600, sans role. `Listings.dc.html:244,549,786` (player counts, ratings), `Details.dc.html` (labels).
  static const DabblerTypeStyle footnoteTight = DabblerTypeStyle(
    name: 'footnoteTight',
    role: DabblerTypeRole.sans,
    fontSize: 13,
    arabicFontSize: 12.1,
    latinLeading: 17,
    arabicLeading: 17,
    fontWeight: semibold,
  );

  /// Footnote, relaxed — 13/20, weight 400, sans role. `Details.dc.html:486` (venue "About" copy).
  static const DabblerTypeStyle footnoteRelaxed = DabblerTypeStyle(
    name: 'footnoteRelaxed',
    role: DabblerTypeRole.sans,
    fontSize: 13,
    arabicFontSize: 12.1,
    latinLeading: 20,
    arabicLeading: 20,
    fontWeight: regular,
  );

  /// Tag — 11/15, weight 600, sans role. Chip and badge text in `Auth and Onboarding.dc.html`, `Listings.dc.html`, `Details.dc.html`.
  static const DabblerTypeStyle tag = DabblerTypeStyle(
    name: 'tag',
    role: DabblerTypeRole.sans,
    fontSize: 11,
    arabicFontSize: 10.1,
    latinLeading: 15,
    arabicLeading: 15,
    fontWeight: semibold,
  );

  /// Tag, tight — 11/14, weight 600, sans role. Pill labels in `Listings.dc.html`, `Profiles.dc.html`, `Auth and Onboarding.dc.html`.
  static const DabblerTypeStyle tagTight = DabblerTypeStyle(
    name: 'tagTight',
    role: DabblerTypeRole.sans,
    fontSize: 11,
    arabicFontSize: 10.1,
    latinLeading: 14,
    arabicLeading: 14,
    fontWeight: semibold,
  );

  /// Figure — 18/22, weight 700, sans role. `Listings.dc.html:122,459` (calendar day number).
  static const DabblerTypeStyle figure = DabblerTypeStyle(
    name: 'figure',
    role: DabblerTypeRole.sans,
    fontSize: 18,
    arabicFontSize: 17.1,
    latinLeading: 22,
    arabicLeading: 22,
    fontWeight: bold,
  );

  /// Large figure — 20/26, weight 700, sans role. `Listings.dc.html:227,533,1096` (game time).
  static const DabblerTypeStyle figureLarge = DabblerTypeStyle(
    name: 'figureLarge',
    role: DabblerTypeRole.sans,
    fontSize: 20,
    arabicFontSize: 19.1,
    latinLeading: 26,
    arabicLeading: 26,
    fontWeight: bold,
  );

  /// Extra-large figure — 22/27, weight 700, sans role. `Listings.dc.html:251,553,1120` (card price).
  static const DabblerTypeStyle figureXl = DabblerTypeStyle(
    name: 'figureXl',
    role: DabblerTypeRole.sans,
    fontSize: 22,
    arabicFontSize: 21.1,
    latinLeading: 27,
    arabicLeading: 27,
    fontWeight: bold,
  );

  /// Profile name, long — 19/25, weight 400, display role. `Profiles.dc.html:848-849`: a name of 15 to 20 characters steps down from [title2] (22/28) to this.
  static const DabblerTypeStyle displayNameMid = DabblerTypeStyle(
    name: 'displayNameMid',
    role: DabblerTypeRole.display,
    fontSize: 19,
    arabicFontSize: 18.1,
    latinLeading: 25,
    arabicLeading: 25,
    fontWeight: regular,
  );

  /// Profile name, longest — 17/22, weight 400, display role. `Profiles.dc.html:848-849`: a name over 20 characters.
  static const DabblerTypeStyle displayNameSmall = DabblerTypeStyle(
    name: 'displayNameSmall',
    role: DabblerTypeRole.display,
    fontSize: 17,
    arabicFontSize: 16.1,
    latinLeading: 22,
    arabicLeading: 22,
    fontWeight: regular,
  );

  /// Every role added from the design frames (KAN-426), in declaration order.
  ///
  /// **D-024 (type ramp frozen) is amended: the design is the source of truth.**
  /// The roles here were added on 2026-10-04 because the Auth and Onboarding,
  /// Listings, Details, Profiles, Sport Profile v2 and Favourites frames set
  /// type at sizes and leadings the twelve `.t-*` steps do not carry. The ramp
  /// may grow only from design frames. [styles] is unchanged and still equals
  /// `typography.css`.
  ///
  /// Sizes and leadings not listed (one-off frame chrome, emoji spans, review
  /// scaffolding) are deliberately not roles.
  static const List<DabblerTypeStyle> frameRoles = <DabblerTypeStyle>[
    displayHero,
    displayWelcome,
    displayScreen,
    displayStep,
    displaySection,
    displayStat,
    displayStatHero,
    displayStatMid,
    displayStatSmall,
    displayLabel,
    leadLarge,
    lead,
    rowTitle,
    copy,
    small,
    smallTight,
    smallRelaxed,
    footnoteTight,
    footnoteRelaxed,
    tag,
    tagTight,
    figure,
    figureLarge,
    figureXl,
    displayNameMid,
    displayNameSmall,
  ];

  /// The frame roles that take additional leading in Arabic.
  static const List<String> frameRolesArabicExtraLeading = <String>[
    'displayStep',
    'lead',
    'rowTitle',
    'copy',
    'small',
    'smallTight',
    'smallRelaxed',
  ];

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

/// Which script a style is being resolved for. Direction picks the face, the
/// size (Arabic is Latin less 0.9px) and the leading.
enum DabblerTypeScript {
  /// Latin (LTR).
  latin,

  /// Arabic (RTL).
  arabic,
}

/// One named step of the [DabblerType] ramp.
///
/// Carries the ramp's structure — size and leading per script, weight and role —
/// and resolves to a [TextStyle] on demand. Tracking is near-zero on purpose,
/// so [letterSpacing] is `0` on every style.
@immutable
class DabblerTypeStyle {
  const DabblerTypeStyle({
    required this.name,
    required this.role,
    required this.fontSize,
    required this.arabicFontSize,
    required this.latinLeading,
    required this.arabicLeading,
    required this.fontWeight,
    this.letterSpacing = 0,
  });

  /// The style's name, matching the `.t-*` class it was transcribed from.
  final String name;

  /// Which face role the style is set in.
  final DabblerTypeRole role;

  /// Latin size in logical pixels.
  final double fontSize;

  /// Arabic size in logical pixels — the Latin size less 0.9, on every style.
  ///
  /// `typography.css` 1.2.0 declares this in its RTL block (`[dir="rtl"]
  /// .t-* { font-size: 33.1px; … }` and so on for all twelve), with the
  /// comment *"size = Latin size − 0.9px at every step (Meral Sans / Wingx
  /// render optically larger and heavier than Glory / Gloock)"*. The same
  /// file's header says the opposite (*"Arabic runs the SAME sizes as Latin at
  /// every step … there is no size bump"*). The declarations are what render,
  /// so they govern (D-004: the CSS is the source, prose about it is not); the
  /// header is a design-source inconsistency recorded here and upstream.
  final double arabicFontSize;

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

  /// Size for [script], in logical pixels.
  double sizeFor(DabblerTypeScript script) =>
      script == DabblerTypeScript.arabic ? arabicFontSize : fontSize;

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
  ///
  /// ## Why [TextDecoration.none] is set explicitly
  ///
  /// It looks redundant — the design draws no underline anywhere, so why say
  /// so? Because **a style that omits `decoration` does not clear an inherited
  /// one.** `MaterialApp` installs Flutter's `_errorTextStyle` as the app-wide
  /// [DefaultTextStyle] (`flutter/lib/src/material/app.dart`): `underline`, in
  /// `0xFFFFFF00` yellow, `double`, labelled *"fallback style; consider putting
  /// your text in a Material"*. A [Material] overrides it per screen, so most
  /// screens never see it. Where there is no [Material] ancestor, a component's
  /// own style wins on size, colour and weight and **loses on decoration**,
  /// which is why the result read as broken rather than merely unstyled: a
  /// [DabblerButton] with no [Material] above it measured
  /// `decoration=underline color=yellow style=double size=14.0` — the `14.0` is
  /// this style landing correctly with the underline coming through beneath it.
  ///
  /// **This is not just a consumer forgetting a wrapper.** Overlays are exposed
  /// even in an app whose every screen uses a `Scaffold`: `dialog.dart` and
  /// `sheet_route.dart` are `PopupRoute`s and `menu.dart` goes through
  /// `Overlay.of`, so an overlay entry is a *sibling* of the screen, not a
  /// descendant of its [Material], and never inherits one. The defect therefore
  /// reaches every consumer, `dabbler-code` included.
  ///
  /// Setting it here rather than wrapping components in
  /// `Material(type: transparency)` is deliberate: the wrapper would put
  /// Material back into the **appearance** path, which `D-017` forbids.
  TextStyle resolve([DabblerTypeScript script = DabblerTypeScript.latin]) =>
      TextStyle(
        fontFamily: DabblerType.fontFamilyFor(role, script),
        fontFamilyFallback: DabblerType.fontFamilyFallbackFor(role, script),
        fontSize: sizeFor(script),
        height: leadingFor(script) / sizeFor(script),
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        fontFeatures: DabblerType.numeralFeatures,
        decoration: TextDecoration.none,
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
