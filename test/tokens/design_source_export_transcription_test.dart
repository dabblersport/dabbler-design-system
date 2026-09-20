import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// KAN-296 — `DECISIONS.md` **D-028**, the direction `D-007`'s gate does not
/// cover.
///
/// `design_source_token_declarations_test.dart` (KAN-271) compares
/// *references* against *declarations* and correctly catches a name used but
/// never declared. It cannot catch the opposite, and that opposite is a real
/// defect class: a name the Figma export **does** declare that the
/// hand-authored `tokens/*.css` never picked up.
///
/// That is how `--accent-indigo` reached five components undetected.
/// `tokens/figma/fig-tokens.css:5` declared it, so nothing was "missing" from
/// `tokens/` as a whole and KAN-271's gate stayed green — `colors.css` simply
/// never carried it across. The export was non-empty and was mistaken for
/// complete.
///
/// **A sibling file, not an edit to KAN-271's.** The ticket allows either; a
/// sibling is taken because the two gates answer different questions from
/// different inputs, and because folding this in would have pushed that file
/// to 507 lines, past the 500-line limit this package holds itself to.
///
/// ## Why the finding is pinned rather than simply failed
///
/// AC1 says an export-only name "must fail the test". Taken literally on day
/// one that is 70 red names, because the export mirrors whole Figma ramps
/// (`--pink-*`, `--purple-*`, `--status-*`) that `colors.css` deliberately
/// re-authors under its own semantic names. KAN-271 met the same problem and
/// recorded the answer: *"a gate whose expected-failure list is longer than
/// its finding is a gate people learn to ignore."*
///
/// So the mechanism is [knownUndeclared]'s, exactly: an **exact-set** pin,
/// compared with `==`. It fails in both directions — a **new** export-only
/// name is a new transcription gap and turns the suite red, and a pinned name
/// that disappears means it was transcribed and the entry must be deleted.
/// Neither direction can rot quietly, and nothing is skipped.
///
/// ## Mutation evidence (AC3)
///
/// [exportOnly] is a pure set difference, deliberately separated from the file
/// walk, so the mutation can be driven with a synthetic export instead of
/// writing into the design source — which is read-only reference and must not
/// be touched. The scratch name `--kan296-export-only` is injected on the
/// export side only, the gate reports it, and removing it clears the finding.
/// Both halves are asserted below and retained, so a later edit to the
/// matcher cannot quietly stop it matching.
///
/// Additionally verified end to end before this landed: a temporary copy of
/// the real export with one extra name appended was fed through the same
/// `exportOnly` call and the name was reported; the copy was then discarded.
/// The design source itself was never written to.
const String designSourceSuffix = 'dabbler-design-system-design/project';

/// The export the Figma plugin writes, relative to the design source root.
const String figmaExportPath = 'tokens/figma/fig-tokens.css';

/// Names the export declares that no hand-authored `tokens/*.css` picked up.
///
/// **This is a finding, not an allowlist.** Every entry is the export naming
/// something the hand-authored source chose not to carry across. Most are
/// Figma ramps `colors.css` re-authors semantically; that is a decision, and
/// pinning it records the decision instead of re-litigating it on every run.
/// A name arriving here that nobody put here is the D-028 defect.
const Set<String> knownTranscriptionGaps = <String>{
  // Figma type scale. The hand-authored ramp is typography.css's
  // --type-*/--leading-* pair; these are the export's own unitless numbers.
  '--font-size-body',
  '--font-size-body-lg',
  '--font-size-body-sm',
  '--font-size-caption',
  '--font-size-display',
  '--font-size-h1',
  '--font-size-h2',
  '--font-size-h3',
  '--font-size-h4',
  '--font-size-micro',
  '--font-size-overline',
  '--font-size-small',

  // Same family, leading half.
  '--line-height-body',
  '--line-height-body-lg',
  '--line-height-body-sm',
  '--line-height-caption',
  '--line-height-display',
  '--line-height-h1',
  '--line-height-h2',
  '--line-height-h3',
  '--line-height-h4',
  '--line-height-micro',
  '--line-height-overline',
  '--line-height-small',

  // The paper ramp under its export names. colors.css re-authors the same
  // values as --surface-*/--outline-*/--ink*.
  '--neutral-100',
  '--neutral-200',
  '--neutral-300',
  '--neutral-400',
  '--neutral-50',
  '--neutral-500',
  '--neutral-600',
  '--neutral-700',
  '--neutral-800',
  '--neutral-900',
  '--neutral-black',
  '--neutral-white',

  // Raw Figma ramps with no hand-authored counterpart.
  '--pink-100',
  '--pink-200',
  '--pink-300',
  '--pink-400',
  '--pink-50',
  '--pink-500',
  '--pink-600',
  '--pink-700',
  '--pink-800',
  '--pink-900',

  // Raw Figma ramps; the brand purple is re-authored as --main-p-*.
  '--purple-100',
  '--purple-200',
  '--purple-300',
  '--purple-400',
  '--purple-50',
  '--purple-500',
  '--purple-600',
  '--purple-700',
  '--purple-800',
  '--purple-900',

  // Export-only corner aliases; spacing.css authors its own scale.
  '--radius-2xl',
  '--radius-full',

  // The export's status naming; colors.css authors --success-*/--error-*
  // /--warning-*/--info-* instead.
  '--status-error',
  '--status-error-bg',
  '--status-error-text',
  '--status-info',
  '--status-info-bg',
  '--status-info-text',
  '--status-success',
  '--status-success-bg',
  '--status-success-text',
  '--status-warning',
  '--status-warning-bg',
  '--status-warning-text',

};

final RegExp _declaration = RegExp(r'(--[a-zA-Z0-9-]+)\s*:');
final RegExp _varReference = RegExp(r'var\(\s*(--[a-zA-Z0-9-]+)');

/// Every `--name:` declared in [css].
Set<String> declarationsIn(String css) =>
    _declaration.allMatches(css).map((RegExpMatch m) => m.group(1)!).toSet();

/// Names in [export] that [handAuthored] never declares.
///
/// A pure set difference, kept apart from the file walk so the AC3 mutation
/// can drive it with a synthetic export rather than mutating the read-only
/// design source.
Set<String> exportOnly({
  required Set<String> export,
  required Set<String> handAuthored,
}) =>
    export.difference(handAuthored);

/// The design source root, located by walking up from the package, for the
/// reason `design_source_token_declarations_test.dart` states: the package is
/// checked out both directly and as a git worktree at varying depths.
Directory? _findDesignSource() {
  Directory dir = Directory.current;
  for (int i = 0; i < 8; i++) {
    final Directory candidate = Directory('${dir.path}/$designSourceSuffix');
    if (candidate.existsSync()) return candidate;
    final Directory nested = Directory('${dir.path}/Dabbler/$designSourceSuffix');
    if (nested.existsSync()) return nested;
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }
  return null;
}

/// `tokens/*.css` — the hand-authored files. The `figma/` subdirectory is
/// excluded on purpose: it is the other side of this comparison, and including
/// it would make the difference empty by construction.
Set<String> _handAuthoredTokens(Directory tokens) {
  final Set<String> names = <String>{};
  for (final File file in tokens
      .listSync()
      .whereType<File>()
      .where((File f) => f.path.endsWith('.css'))) {
    names.addAll(declarationsIn(file.readAsStringSync()));
  }
  return names;
}

/// How many component files reference each `var(--name)`, for the failure
/// message. A gap nothing references is inert mirror content; a gap a
/// component references is the `--accent-indigo` shape.
Map<String, int> _referenceCounts(Directory project) {
  final Map<String, Set<String>> refs = <String, Set<String>>{};
  for (final File file in project.listSync(recursive: true).whereType<File>()) {
    final String rel = file.path.substring(project.path.length + 1);
    if (rel.startsWith('uploads/') || rel.startsWith('node_modules/')) continue;
    if (!rel.endsWith('.jsx') && !rel.endsWith('.d.ts') && !rel.endsWith('.prompt.md')) {
      continue;
    }
    for (final RegExpMatch m in _varReference.allMatches(file.readAsStringSync())) {
      refs.putIfAbsent(m.group(1)!, () => <String>{}).add(rel);
    }
  }
  return refs.map((String k, Set<String> v) => MapEntry<String, int>(k, v.length));
}

void main() {
  late Set<String> exportDeclared;
  late Set<String> handAuthored;
  late Map<String, int> referenceCounts;

  setUpAll(() {
    final Directory? found = _findDesignSource();
    expect(found, isNotNull,
        reason: 'design source not found: */$designSourceSuffix');
    final Directory project = found!;
    final Directory tokens = Directory('${project.path}/tokens');
    expect(tokens.existsSync(), isTrue, reason: '${tokens.path} not found');

    final File export = File('${project.path}/$figmaExportPath');
    expect(export.existsSync(), isTrue, reason: '${export.path} not found');

    exportDeclared = declarationsIn(export.readAsStringSync());
    handAuthored = _handAuthoredTokens(tokens);
    referenceCounts = _referenceCounts(project);
  });

  group('D-028 — every EXPORTED token is transcribed', () {
    test('the scan found both sides it is meant to compare', () {
      // A comparison whose inputs are empty passes vacuously — and this gate
      // exists precisely because a non-empty export was mistaken for a
      // complete one. Assert both sides are real before comparing them.
      expect(exportDeclared.length, greaterThan(50),
          reason: '$figmaExportPath parsed to ${exportDeclared.length} names '
              '— too few to be the real export; the parse or path is wrong');
      expect(handAuthored.length, greaterThan(200),
          reason: 'tokens/*.css parsed to ${handAuthored.length} names — too '
              'few to be the hand-authored set');
    });

    test('no exported name is missing from tokens/*.css, beyond the pinned set',
        () {
      final Set<String> gaps =
          exportOnly(export: exportDeclared, handAuthored: handAuthored);

      // AC2 — every gap named, not counted, each carrying whether a component
      // actually consumes it, so a new finding can be triaged from the
      // failure message alone.
      final String detail = (gaps.toList()..sort())
          .map((String n) => referenceCounts.containsKey(n)
              ? '  $n — REFERENCED by ${referenceCounts[n]} file(s)'
              : '  $n — not referenced')
          .join('\n');

      expect(
        gaps,
        knownTranscriptionGaps,
        reason: 'Declared in $figmaExportPath but absent from the '
            'hand-authored tokens/*.css:\n$detail\n'
            'A name here that is not pinned is a NEW transcription gap — the '
            'defect D-028 names, and the one --accent-indigo slipped through. '
            'A pinned name that has gone means it was transcribed; delete the '
            'entry rather than widening the pin.',
      );
    });

    test('--accent-indigo, D-028\'s own case, is transcribed and stays so', () {
      // AC4 asked for the opposite: --accent-indigo was expected to FAIL here
      // until KAN-261/KAN-264 landed. Both have now landed — KAN-261 declared
      // it in colors.css, KAN-264 transcribed it to
      // DabblerPalette.accentIndigo — so pinning it as an expected failure
      // would assert something untrue.
      //
      // The assertion is inverted rather than dropped, for the reason AC4
      // gave for wanting it: the motivating case stays visible under this
      // gate, so a regression that removes it from colors.css fails HERE,
      // naming D-028, instead of silently reopening the gap.
      expect(exportDeclared, contains('--accent-indigo'),
          reason: 'the export no longer declares it — this gate is reading '
              'the wrong file');
      expect(handAuthored, contains('--accent-indigo'),
          reason: 'KAN-261 declared --accent-indigo in colors.css; if it is '
              'gone, D-028 has reopened');
      expect(exportOnly(export: exportDeclared, handAuthored: handAuthored),
          isNot(contains('--accent-indigo')));
      expect(knownTranscriptionGaps, isNot(contains('--accent-indigo')),
          reason: 'it is transcribed; it must not be pinned as a gap');
    });

    test('the gate can fail — mutation check, AC3', () {
      // Driven with a synthetic export, not by writing into the design source,
      // which is read-only reference.
      const String scratchExport = ':root {\n'
          '  --accent-indigo: rgb(92,80,230);\n'
          '  --kan296-export-only: rgb(1,2,3);\n'
          '}\n';
      const String scratchHand = ':root { --accent-indigo:#5C50E6; }';

      expect(
        exportOnly(
          export: declarationsIn(scratchExport),
          handAuthored: declarationsIn(scratchHand),
        ),
        <String>{'--kan296-export-only'},
        reason: 'the export-only name must be reported and the transcribed '
            'one must not',
      );

      // The other half: remove the scratch name and the finding clears. A
      // matcher that reported everything would fail this.
      expect(
        exportOnly(
          export: declarationsIn(scratchHand),
          handAuthored: declarationsIn(scratchHand),
        ),
        isEmpty,
      );

      // And the real export is genuinely parsed, not stubbed.
      expect(exportDeclared, isNot(contains('--kan296-export-only')));
    });
  });
}
