import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// KAN-269 — `DECISIONS.md` **D-017**, as a gate on the source:
///
/// > Importing `package:flutter/material.dart` for a MECHANISM is allowed.
/// > Inheriting Material's APPEARANCE is forbidden.
///
/// Tap-to-focus, selection handles, autofill and text-editing plumbing are
/// mechanisms; Flutter offers them nowhere else. Material ink and ripple,
/// Material default typography, Material's `ColorScheme`-derived paint and any
/// `ThemeData` value reaching a pixel are appearance, and none may survive into
/// what this system renders.
///
/// The import itself is therefore *not* what this gate scans for — 28 files
/// under `lib/src/` import `material.dart` and D-017 rules that legitimate.
/// What it scans for is the one act that turns the mechanism into an
/// appearance: **reading the enclosing Material theme and using what comes back
/// in this package's own paint.**
///
/// ## Why the gate is written as an allowlist of one
///
/// The obvious shape — a deny-list of `.colorScheme`, `.textTheme`,
/// `.primaryColor`, … — fails open. It passes on every Material surface nobody
/// thought to enumerate (`.cardColor`, `.splashColor`, `.dividerTheme`), and it
/// passes outright on
///
/// ```dart
/// final ThemeData theme = Theme.of(context);   // deny-list sees nothing
/// color: theme.colorScheme.primary;            // …and neither does it here
/// ```
///
/// So the rule is inverted. **Every** `Theme.of(context)` / `Theme.maybeOf`
/// read is a violation *unless* the very next thing it does is
/// `.extension<…>()`. A theme extension is this package's own
/// [DabblerColors] travelling in Material's carrier — the value is ours, and
/// `ThemeData` is only the envelope. Anything else pulled off that object is
/// Material's, by construction, whether or not this file names it.
///
/// `ColorScheme.of(context)` and `TextTheme.of(context)` are the same read
/// spelled differently since Flutter 3.22, and are always violations — there is
/// no extension form of either.
///
/// `IconTheme.of(context)` is deliberately **not** caught. It is not a Material
/// theme read: it is the inherited-icon-colour mechanism the package itself
/// sets with `IconThemeData` at eleven call sites, and reads back in
/// `spinner.dart`, `icon.dart`, `sport_icon.dart` and `top_bar.dart` for the
/// `inherit` tone. The negative lookbehind on the pattern is what keeps
/// `IconTheme.of` out — see [_themeRead].
///
/// ## Mutation evidence (AC2)
///
/// Recorded because a scanning gate that cannot fail is worse than no gate —
/// DS-504's spacing gate was found passing vacuously under exactly this test.
/// Injecting `color: Theme.of(context).colorScheme.primary` into
/// `lib/src/controls/button.dart` made this test fail, naming that file and
/// that member; reverting the injection made it pass again. The variable form
/// (`final ThemeData t = Theme.of(context);`) was injected separately and also
/// failed, which is the case the deny-list shape would have missed.

/// A Material theme read, plus the member taken off it (if any).
///
/// `(?<![A-Za-z0-9_$.])` is load-bearing twice over: without it the pattern
/// matches the `Theme.of` inside `IconTheme.of` and `DefaultTextStyle`-style
/// composites, and every legitimate icon-tone read in the package becomes a
/// false failure. `of\(` never nests parentheses in practice (`of(context)`),
/// so `[^()]*` is sufficient to reach the closing bracket.
final RegExp _themeRead = RegExp(
  r'(?<![A-Za-z0-9_$.])Theme\.(?:maybeOf|of)\([^()]*\)(\.[A-Za-z_][A-Za-z0-9_]*)?',
);

/// `ColorScheme.of(context)` / `TextTheme.of(context)` — the same appearance
/// read, spelled without the word `Theme.of`. Neither has an extension form, so
/// neither is ever legal here.
final RegExp _shorthandRead = RegExp(
  r'(?<![A-Za-z0-9_$.])(?:ColorScheme|TextTheme)\.(?:maybeOf|of)\(',
);

/// The one continuation D-017 permits: this package's own theme extension
/// riding in Material's carrier.
const String _permittedMember = '.extension';

/// Strips `///`, `//` and `/* … */` so that dartdoc quoting the forbidden form
/// — as this very file's header does — is not itself a violation. Documenting
/// where a rule bites is the house style.
String _stripComments(String source) {
  final String noBlock =
      source.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
  return noBlock
      .split('\n')
      .map((String line) {
        final int slashes = line.indexOf('//');
        return slashes == -1 ? line : line.substring(0, slashes);
      })
      .join('\n');
}

List<File> _dartFilesUnder(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File f) => f.path.endsWith('.dart'))
    .toList();

/// Every D-017 violation in [code], as `line: offending text`.
List<String> _violations(String code) {
  final List<String> found = <String>[];

  void record(int index, String text) {
    final int line = code.substring(0, index).split('\n').length;
    found.add('$line: ${text.trim()}');
  }

  for (final RegExpMatch m in _themeRead.allMatches(code)) {
    final String? member = m.group(1);
    if (member == _permittedMember) continue;
    // A bare `Theme.of(context)` with no member is the assign-to-a-variable
    // form; the paint happens a line later and is just as forbidden.
    record(m.start, m.group(0)!);
  }
  for (final RegExpMatch m in _shorthandRead.allMatches(code)) {
    record(m.start, m.group(0)!);
  }
  return found;
}

void main() {
  group('D-017 — Material is a mechanism here, never an appearance', () {
    test('no widget under lib/src paints from Material\'s Theme.of(context)',
        () {
      final Map<String, List<String>> offenders = <String, List<String>>{};
      for (final File file in _dartFilesUnder('lib/src')) {
        final List<String> found =
            _violations(_stripComments(file.readAsStringSync()));
        if (found.isNotEmpty) {
          offenders[file.path.replaceAll(r'\', '/')] = found;
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'D-017: a Material theme value reached this package\'s paint. '
            'Only `Theme.of(context).extension<…>()` is permitted — take the '
            'value from DabblerColors/DabblerType instead.',
      );
    });

    test('the four files D-017 names are clean (AC3)', () {
      // cxo ruled these compliant by inspection. The gate agreeing with the
      // ruling is what makes the ruling checkable rather than remembered.
      const List<String> ruledCompliant = <String>[
        'lib/src/forms/field_shell.dart',
        'lib/src/forms/text_field.dart',
        'lib/src/controls/chip.dart',
        'lib/src/surfaces/surface.dart',
      ];
      for (final String path in ruledCompliant) {
        final File file = File(path);
        expect(file.existsSync(), isTrue, reason: '$path not found');
        expect(
          _violations(_stripComments(file.readAsStringSync())),
          isEmpty,
          reason: '$path was ruled compliant in D-017 and no longer is',
        );
      }
    });

    test('the gate can fail — mutation check, AC2', () {
      // The injections from the header, run against the matcher itself so the
      // evidence survives in the suite rather than only in a commit message.
      // A gate proved only by hand is a gate nobody re-proves after an edit.
      expect(
        _violations('color: Theme.of(context).colorScheme.primary,'),
        hasLength(1),
        reason: 'the direct paint form must be caught',
      );
      expect(
        _violations('final ThemeData t = Theme.of(context);'),
        hasLength(1),
        reason: 'the assign-to-a-variable form must be caught',
      );
      expect(
        _violations('style: Theme.of(context).textTheme.bodyMedium,'),
        hasLength(1),
      );
      expect(
        _violations('final ColorScheme s = ColorScheme.of(context);'),
        hasLength(1),
      );
      // …and it must not fire on the mechanisms D-017 allows.
      expect(
        _violations('Theme.of(context).extension<DabblerColors>()'),
        isEmpty,
        reason: 'the package\'s own extension is the permitted read',
      );
      expect(
        _violations('IconTheme.of(context).color ?? DabblerColors.of(context)'),
        isEmpty,
        reason: 'IconTheme is the inherited-icon mechanism, not a Material '
            'theme read',
      );
    });
  });
}
