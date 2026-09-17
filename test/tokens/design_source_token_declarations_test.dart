import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// KAN-271 — `DECISIONS.md` **D-007(3)**, as a gate on the design source:
///
/// > A source-side check must fail the build when a referenced `--*` is not
/// > declared in `tokens/`.
///
/// The cause D-007 identified: `_adherence.oxlintrc.json` enumerates allowed
/// `--*` names *independently* of what `tokens/` declares, so a name can be
/// "allowed" and undeclared at the same time. Verified here — `--text-body` and
/// `--accent-indigo` are both in that allowlist (`:1097`, `:1133`), and the
/// allowlist is the only check the design-source repo has. On the web an
/// undeclared `var(--x)` silently inherits and nobody notices; Flutter cannot
/// inherit a name that does not exist, so it arrives here as a transcription
/// with nothing to transcribe.
///
/// The design source has no test runner, so the check lives in this package,
/// reusing [dabbler_palette_test]'s directory-walk for locating a source tree
/// that sits outside the package root.
///
/// ## Scope: `tokens/` is read recursively, and that is a decision
///
/// D-007 says "declared in `tokens/`" — the directory. The ticket's AC1 says
/// `tokens/*.css` — the glob. **They give different answers**, and the
/// difference is `tokens/figma/fig-tokens.css`, a 345-name Figma mirror
/// alongside the six hand-authored files:
///
/// | scope | referenced | undeclared |
/// |---|---|---|
/// | `tokens/*.css` (glob) | 128 | **28** |
/// | `tokens/` (recursive) | 128 | **1** |
///
/// This gate takes **the recursive reading**, for two reasons. It is what D-007
/// says, and the ruling outranks the ticket's paraphrase of it. And the glob
/// reading would open with 28 known failures — `--neutral-white`,
/// `--purple-600`, the `--font-size-*` family — which are legacy aliases the
/// Figma mirror does declare and which no ruling has called defects. Pinning 28
/// names would be pinning a question nobody has asked, and a gate whose
/// expected-failure list is longer than its finding is a gate people learn to
/// ignore.
///
/// The consequence is recorded rather than hidden: the second scope is asserted
/// separately in *`--accent-indigo` is still missing from the hand-authored
/// colors.css*, below, so D-004's finding stays visible under this gate even
/// though the recursive scope does not catch it.
///
/// ## The expected-failure state (AC4)
///
/// AC4 requires the known failure to be **asserted, not skipped**, so the
/// ticket cannot go green for the wrong reason. The mechanism used is an
/// exact-set pin: [knownUndeclared] is compared with `==`, not `containsAll`.
/// That makes the pin fail in **both** directions —
///
/// * a **new** undeclared name appears → the set no longer matches → red. This
///   is the gate doing its job.
/// * `--text-body` is **fixed** (D-007(1)) → the set no longer matches → red,
///   with the reason telling the next developer to delete the entry. The pin
///   cannot outlive the defect it documents.
///
/// A `skip:` or an exclusion list would have done neither.
///
/// **AC4 as written expected two names; one of the two does not hold.**
/// `--accent-indigo` **is** declared, at `tokens/figma/fig-tokens.css:5`. D-004
/// rules it an omission from `colors.css` specifically, which is a narrower
/// finding than "undeclared in `tokens/`" — so it is pinned by the colors.css
/// test below rather than by this one. Reported to the orchestrator as a
/// divergence from the AC rather than resolved silently.
///
/// ## Mutation evidence (AC3)
///
/// A scratch component declaring `color: var(--kan271-does-not-exist)` was
/// written into the design source's `components/` tree; this test failed,
/// naming the file and the token. Removing it made the test pass again. The
/// same injection was run against a `.prompt.md` and a `.d.ts` to prove all
/// three extensions are actually scanned and not just globbed for.

/// The design source root, located by walking up from the package. It is
/// checked out both directly and as a git worktree at varying depths, so a
/// fixed relative path does not hold — the same reason
/// `dabbler_palette_test.dart` walks.
const String designSourceSuffix = 'dabbler-design-system-design/project';

Directory? _findDesignSource() {
  Directory dir = Directory.current;
  for (int i = 0; i < 8; i++) {
    final Directory candidate = Directory('${dir.path}/$designSourceSuffix');
    if (candidate.existsSync()) return candidate;
    final Directory nested =
        Directory('${dir.path}/Dabbler/$designSourceSuffix');
    if (nested.existsSync()) return nested;
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }
  return null;
}

/// Names referenced in the source but declared nowhere under `tokens/`.
///
/// **This is a defect list, not an allowlist.** Every entry is an open ticket,
/// and the set is compared exactly — see the header. Delete an entry the moment
/// its ticket lands; the test will tell you to.
const Set<String> knownUndeclared = <String>{
  // D-007(1) / `NavigationBottomBar.jsx:121`. Ruled a defect, not a missing
  // token: the create-tile label takes the same role its sibling labels take.
  // Remove this entry when that source fix lands.
  '--text-body',
};

/// Directories under the design source that are not the design system: user
/// uploads and the generated bundle's own copies.
bool _isScanned(String relativePath) =>
    !relativePath.startsWith('uploads/') &&
    !relativePath.startsWith('node_modules/');

/// Every `--name:` declared anywhere under `tokens/`, recursively.
Set<String> _declaredTokens(Directory tokens) {
  final RegExp declaration = RegExp(r'(--[a-zA-Z0-9-]+)\s*:');
  final Set<String> declared = <String>{};
  for (final File file in tokens
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.css'))) {
    for (final RegExpMatch m in declaration.allMatches(file.readAsStringSync())) {
      declared.add(m.group(1)!);
    }
  }
  return declared;
}

/// A `var(--name)` reference — the form that actually paints.
final RegExp _varReference = RegExp(r'var\(\s*(--[a-zA-Z0-9-]+)');

/// A bare `--name` outside a `var()`, as the prompt files use when they name a
/// token in prose.
///
/// Two exclusions keep this from drowning the gate in false positives, both
/// found by running it:
///
/// * **Markdown horizontal rules.** `---` and `-------------` are dashes, not
///   tokens. Requiring at least one letter removes them.
/// * **Prose prefixes.** `Banner.prompt.md` writes "`--color-status-*`" and
///   `Toast.prompt.md` writes "`--surface-`" to mean a family. A name ending in
///   `-` is a fragment, not a reference, and cannot be declared.
///
/// Without these the scan reports six phantom names and the real finding is
/// lost in them — which is the failure mode this ticket exists to prevent,
/// arriving from the opposite direction.
final RegExp _bareReference =
    RegExp(r'(?<![a-zA-Z0-9-])(--[a-zA-Z0-9-]*[a-zA-Z][a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*)(?![a-zA-Z0-9-])');

/// Every referenced `--name`, mapped to the source files referencing it.
Map<String, Set<String>> _references(Directory project) {
  final Map<String, Set<String>> refs = <String, Set<String>>{};
  for (final File file in project.listSync(recursive: true).whereType<File>()) {
    final String relative =
        file.path.substring(project.path.length + 1).replaceAll(r'\', '/');
    if (!_isScanned(relative)) continue;
    if (!relative.endsWith('.jsx') &&
        !relative.endsWith('.d.ts') &&
        !relative.endsWith('.prompt.md')) {
      continue;
    }
    final String body = file.readAsStringSync();
    for (final RegExpMatch m in _varReference.allMatches(body)) {
      refs.putIfAbsent(m.group(1)!, () => <String>{}).add(relative);
    }
    // Bare names are looked for only in what is left once the `var()` forms are
    // removed, so a reference is not counted twice under two different rules.
    final String outsideVar = body.replaceAll(_varReference, '');
    for (final RegExpMatch m in _bareReference.allMatches(outsideVar)) {
      refs.putIfAbsent(m.group(1)!, () => <String>{}).add(relative);
    }
  }
  return refs;
}

void main() {
  late Directory project;
  late Set<String> declared;
  late Map<String, Set<String>> references;

  setUpAll(() {
    final Directory? found = _findDesignSource();
    expect(found, isNotNull, reason: 'design source not found: */$designSourceSuffix');
    project = found!;
    final Directory tokens = Directory('${project.path}/tokens');
    expect(tokens.existsSync(), isTrue, reason: '${tokens.path} not found');
    declared = _declaredTokens(tokens);
    references = _references(project);
  });

  group('D-007(3) — every referenced design token is declared', () {
    test('the scan actually found the source it is meant to police', () {
      // The gate that cannot find its input passes vacuously, which is the
      // exact failure DS-504 was caught in. Assert the inputs are non-trivial
      // before asserting anything about them.
      expect(declared.length, greaterThan(200),
          reason: 'tokens/ parsed to ${declared.length} names — too few to be '
              'the real token set; the parse or the path is wrong');
      expect(references.length, greaterThan(100),
          reason: 'only ${references.length} references found across the '
              'source — the file walk is not reaching the components');
    });

    test('no var(--x) reference is undeclared, beyond the pinned defects', () {
      final Map<String, Set<String>> undeclared = <String, Set<String>>{
        for (final MapEntry<String, Set<String>> e in references.entries)
          if (!declared.contains(e.key)) e.key: e.value,
      };

      // Exact, in both directions — see the header. A name added here is a new
      // finding; a name that disappears means its ticket landed and the pin
      // must be deleted.
      expect(
        undeclared.keys.toSet(),
        knownUndeclared,
        reason: 'Referenced but not declared under tokens/:\n'
            '${undeclared.entries.map((MapEntry<String, Set<String>> e) => '  ${e.key} — ${e.value.join(', ')}').join('\n')}\n'
            'If a name here is new, that is the defect D-007 predicted. If a '
            'name in knownUndeclared has gone, its fix landed — delete the '
            'entry rather than widening the pin.',
      );
    });

    test('--text-body is still the open D-007(1) defect, at its one call site',
        () {
      // Pinned at the site as well as the name, so the entry above cannot be
      // kept alive by an unrelated second use of the same name.
      expect(
        references['--text-body'],
        <String>{'components/navigation/NavigationBottomBar.jsx'},
        reason: 'D-007 verified exactly one reference; the shape of the defect '
            'has changed',
      );
      expect(declared.contains('--text-body'), isFalse,
          reason: 'D-007(1) ruled --text-body a defect, NOT a token to add to '
              'colors.css — if it is now declared, that resolution was not the '
              'one ruled',
      );
    });

    test('--accent-indigo is still missing from the hand-authored colors.css',
        () {
      // D-004/KAN-261. The recursive scope above does not catch it, because
      // `tokens/figma/fig-tokens.css:5` declares it — so it is pinned here
      // instead, and this is the second scope the header describes.
      final Set<String> handAuthored = <String>{};
      for (final File file in Directory('${project.path}/tokens')
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.endsWith('.css'))) {
        handAuthored.addAll(RegExp(r'(--[a-zA-Z0-9-]+)\s*:')
            .allMatches(file.readAsStringSync())
            .map((RegExpMatch m) => m.group(1)!));
      }
      expect(declared.contains('--accent-indigo'), isTrue,
          reason: 'expected the Figma mirror to declare it');
      expect(
        handAuthored.contains('--accent-indigo'),
        isFalse,
        reason: 'KAN-261 has landed — delete this test, and note in D-004 that '
            'the finding is closed',
      );
    });

    test('the gate can fail — mutation check, AC3', () {
      // Proved end to end against the real tree by injecting a scratch
      // component (see the header). Retained here against the matcher so a
      // later edit to the regexes cannot quietly stop them matching.
      const String injected = 'style={{ color: "var(--kan271-does-not-exist)" }}';
      expect(
        _varReference.allMatches(injected).map((RegExpMatch m) => m.group(1)),
        <String>['--kan271-does-not-exist'],
      );
      expect(declared.contains('--kan271-does-not-exist'), isFalse);

      // …and the two exclusions that keep it honest still exclude.
      expect(_bareReference.hasMatch('\n---\n'), isFalse,
          reason: 'a markdown rule is not a token');
      expect(_bareReference.hasMatch('the `--surface-` family'), isFalse,
          reason: 'a prose prefix is not a token');
      expect(_bareReference.hasMatch('prefer `--text-body` here'), isTrue,
          reason: 'a bare name in prose IS a reference and must be scanned');
    });
  });
}
