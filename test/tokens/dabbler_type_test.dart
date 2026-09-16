import 'dart:io';

import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design source the ramp is transcribed from. It lives outside this
/// package, so it is located by walking up from the package root rather than by
/// a fixed relative path (the package is checked out both directly and as a git
/// worktree at varying depths).
const String typographyCssSuffix =
    'dabbler-design-system-design/project/tokens/typography.css';

File? _findTypographyCss() {
  Directory dir = Directory.current;
  for (int i = 0; i < 8; i++) {
    final File candidate = File('${dir.path}/$typographyCssSuffix');
    if (candidate.existsSync()) return candidate;
    final File nested = File('${dir.path}/Dabbler/$typographyCssSuffix');
    if (nested.existsSync()) return nested;
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }
  return null;
}

/// One `.t-*` rule of the source, as declared.
class _CssRule {
  const _CssRule(this.fontSize, this.lineHeight, this.fontWeight, this.family);

  final double fontSize;
  final double lineHeight;
  final int fontWeight;

  /// `display` or `sans`, read off `var(--font-display)` / `var(--font-sans)`.
  final String family;
}

/// Every `.t-<name> { … }` rule of the source, keyed by the CSS class name.
Map<String, _CssRule> _parseRules(String css) {
  final RegExp rule = RegExp(
    r'^\.t-([a-z0-9-]+)\s*\{([^}]*)\}',
    multiLine: true,
  );
  double px(String body, String prop) => double.parse(
    RegExp('$prop:\\s*([0-9.]+)px').firstMatch(body)!.group(1)!,
  );
  return <String, _CssRule>{
    for (final RegExpMatch m in rule.allMatches(css))
      m.group(1)!: _CssRule(
        px(m.group(2)!, 'font-size'),
        px(m.group(2)!, 'line-height'),
        int.parse(
          RegExp(r'font-weight:\s*(\d+)').firstMatch(m.group(2)!)!.group(1)!,
        ),
        RegExp(
          r'font-family:var\(--font-(display|sans)\)',
        ).firstMatch(m.group(2)!)!.group(1)!,
      ),
  };
}

/// Every `[dir="rtl"] .t-<name> { line-height:<n>px; }` override.
Map<String, double> _parseRtlLeading(String css) => <String, double>{
  for (final RegExpMatch m in RegExp(
    r'\[dir="rtl"\]\s*\.t-([a-z0-9-]+)\s*\{\s*line-height:\s*([0-9.]+)px',
  ).allMatches(css))
    m.group(1)!: double.parse(m.group(2)!),
};

/// `largeTitle` -> `large-title`, `caption1` -> `caption-1`.
String _cssName(String dartName) => dartName
    .replaceAllMapped(
      RegExp('([a-z])([A-Z0-9])'),
      (Match m) => '${m[1]}-${m[2]!.toLowerCase()}',
    )
    .toLowerCase();

void main() {
  late Map<String, _CssRule> rules;
  late Map<String, double> rtlLeading;

  setUpAll(() {
    final File? css = _findTypographyCss();
    expect(css, isNotNull, reason: 'design source not found: */$typographyCssSuffix');
    final String source = css!.readAsStringSync();
    rules = _parseRules(source);
    rtlLeading = _parseRtlLeading(source);
    expect(rules, isNotEmpty);
  });

  group('DabblerType transcribes typography.css', () {
    test('declares every named style the source declares, and no other', () {
      expect(
        DabblerType.styles.map((DabblerTypeStyle s) => _cssName(s.name)).toSet(),
        rules.keys.toSet(),
      );
    });

    test('size, Latin leading, weight and role match the source', () {
      for (final DabblerTypeStyle style in DabblerType.styles) {
        final _CssRule rule = rules[_cssName(style.name)]!;
        expect(style.fontSize, rule.fontSize, reason: '${style.name} size');
        expect(
          style.latinLeading,
          rule.lineHeight,
          reason: '${style.name} Latin leading',
        );
        expect(
          style.fontWeight.value,
          rule.fontWeight,
          reason: '${style.name} weight',
        );
        expect(
          style.role,
          rule.family == 'display'
              ? DabblerTypeRole.display
              : DabblerTypeRole.sans,
          reason: '${style.name} role',
        );
        expect(style.letterSpacing, 0, reason: 'tracking is near-zero');
      }
    });

    test('Arabic runs the same sizes as Latin at every step', () {
      for (final DabblerTypeStyle style in DabblerType.styles) {
        expect(
          style
              .resolve(DabblerTypeScript.arabic)
              .fontSize,
          style.resolve(DabblerTypeScript.latin).fontSize,
          reason: '${style.name} must not take a size bump in Arabic',
        );
      }
    });
  });

  group('title styles', () {
    test('display-role styles are weight 400 in BOTH script slots', () {
      // Gloock and Wingx each ship one weight, so a title is never Light and
      // never Bold, whichever face is selected.
      final Iterable<DabblerTypeStyle> titles = DabblerType.styles.where(
        (DabblerTypeStyle s) => s.role == DabblerTypeRole.display,
      );
      expect(titles, hasLength(4));
      for (final DabblerTypeStyle style in titles) {
        for (final DabblerTypeScript script in DabblerTypeScript.values) {
          expect(
            style.resolve(script).fontWeight,
            FontWeight.w400,
            reason: '${style.name} in $script',
          );
        }
      }
    });

    test('the display role covers exactly large title and titles 1–3', () {
      expect(
        DabblerType.styles
            .where((DabblerTypeStyle s) => s.role == DabblerTypeRole.display)
            .map((DabblerTypeStyle s) => s.name),
        <String>['largeTitle', 'title1', 'title2', 'title3'],
      );
    });
  });

  group('Arabic leading', () {
    test('exactly four styles take additional leading', () {
      expect(
        DabblerType.styles
            .where((DabblerTypeStyle s) => s.takesArabicExtraLeading)
            .map((DabblerTypeStyle s) => s.name),
        <String>['headline', 'body', 'callout', 'subheadline'],
      );
      expect(DabblerType.arabicExtraLeadingStyles, hasLength(4));
    });

    test('the four values match the [dir="rtl"] block', () {
      expect(rtlLeading.keys.toSet(), <String>{
        'headline',
        'body',
        'callout',
        'subheadline',
      });
      for (final MapEntry<String, double> entry in rtlLeading.entries) {
        final DabblerTypeStyle style = DabblerType.styles.firstWhere(
          (DabblerTypeStyle s) => _cssName(s.name) == entry.key,
        );
        expect(style.arabicLeading, entry.value, reason: entry.key);
        expect(style.arabicLeading, greaterThan(style.latinLeading));
      }
    });

    test('every other style has identical leading in both directions', () {
      for (final DabblerTypeStyle style in DabblerType.styles) {
        if (rtlLeading.containsKey(_cssName(style.name))) continue;
        expect(
          style.leadingFor(DabblerTypeScript.arabic),
          style.leadingFor(DabblerTypeScript.latin),
          reason: '${style.name} must inherit Latin leading',
        );
      }
    });

    test('resolve() turns pixel leading into a height multiple', () {
      expect(
        DabblerType.body.resolve(DabblerTypeScript.latin).height,
        21 / 16,
      );
      expect(
        DabblerType.body.resolve(DabblerTypeScript.arabic).height,
        24 / 16,
      );
      expect(
        DabblerType.body.resolveForDirection(TextDirection.rtl).height,
        DabblerType.body.resolve(DabblerTypeScript.arabic).height,
      );
    });
  });

  group('numerals are always Western Arabic', () {
    test('every resolved style disables Arabic-Indic substitution', () {
      for (final DabblerTypeStyle style in DabblerType.styles) {
        for (final DabblerTypeScript script in DabblerTypeScript.values) {
          expect(
            style.resolve(script).fontFeatures,
            containsAll(<FontFeature>[
              const FontFeature.disable('anum'),
              const FontFeature.liningFigures(),
            ]),
            reason: '${style.name} in $script',
          );
        }
      }
    });

    test('the text source rewrites Arabic-Indic digits to 0–9', () {
      expect(DabblerType.toWesternDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
      expect(DabblerType.toWesternDigits('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
      expect(DabblerType.toWesternDigits('٤ لاعبين'), '4 لاعبين');
      expect(DabblerType.toWesternDigits('12 players'), '12 players');
      expect(DabblerType.toWesternDigits(''), '');
    });
  });

  group('font families', () {
    test('fontFamily is the qualified packages/… form', () {
      for (final DabblerTypeStyle style in DabblerType.styles) {
        for (final DabblerTypeScript script in DabblerTypeScript.values) {
          final TextStyle resolved = style.resolve(script);
          expect(
            resolved.fontFamily,
            startsWith('packages/dabbler_design_system/'),
            reason: '${style.name} in $script',
          );
          expect(
            resolved.fontFamilyFallback!.first,
            DabblerType.bareFamilyFor(style.role, script),
            reason: 'bare name leads the fallback chain',
          );
          expect(
            resolved.fontFamily,
            'packages/dabbler_design_system/'
            '${DabblerType.bareFamilyFor(style.role, script)}',
          );
        }
      }
    });

    test('the role is fixed and only the script swaps the face', () {
      expect(
        DabblerType.bareFamilyFor(
          DabblerTypeRole.display,
          DabblerTypeScript.latin,
        ),
        'Gloock',
      );
      expect(
        DabblerType.bareFamilyFor(
          DabblerTypeRole.display,
          DabblerTypeScript.arabic,
        ),
        'Wingx',
      );
      expect(
        DabblerType.bareFamilyFor(
          DabblerTypeRole.sans,
          DabblerTypeScript.latin,
        ),
        'Glory',
      );
      expect(
        DabblerType.bareFamilyFor(
          DabblerTypeRole.sans,
          DabblerTypeScript.arabic,
        ),
        'Meral Sans',
      );
    });

    test('all four faces are the ones the source declares', () {
      final File css = _findTypographyCss()!;
      final String source = css.readAsStringSync();
      for (final String family in <String>[
        DabblerType.displayLatinFamily,
        DabblerType.displayArabicFamily,
        DabblerType.sansLatinFamily,
        DabblerType.sansArabicFamily,
      ]) {
        expect(source, contains("'$family'"), reason: '$family not in source');
      }
    });
  });

  test('DabblerType is a plain const class, not a ThemeExtension', () {
    // Doc comments discuss the ruling, so only declaration lines are checked.
    final String declarations = File('lib/src/tokens/dabbler_type.dart')
        .readAsLinesSync()
        .where((String l) => !l.trimLeft().startsWith('//'))
        .join('\n');
    expect(
      declarations.contains('ThemeExtension'),
      isFalse,
      reason: 'geometry and type do not vary by theme',
    );
    // Every ramp value is available without a BuildContext.
    expect(DabblerType.body.fontSize, 16);
    expect(DabblerType.styles, hasLength(12));
  });
}
