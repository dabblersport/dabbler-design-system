/// KAN-324 — the documentation corpus gate, `D-042` + `T-085`(3).
///
/// **Where it runs is settled, not a choice.** `cto` resolved D-041's apparent
/// contradiction — "fails the build" against "an edit must be visible without
/// regenerating Dart" — by putting the check here: a writer edits a `.md`, hot
/// reloads and sees it; a bad page fails CI before merge, never before render.
/// So this is a Dart test over the asset directory. Not a build step, not a
/// render-path assertion, not a hook on the writer.
///
/// **It authors nothing.** The vocabulary is [DabblerDocVocabulary]
/// (`KAN-323`), transcribed from `D-042`(b)–(e) rather than read off the
/// pages, and AC2 forbids a second list: a gate derived from the corpus it
/// polices cannot fail. The parse is [DabblerDocSplitter], the same one the
/// renderer uses, so the gate cannot disagree with the screen. Specimen
/// resolution is [DabblerDocSpecimenResolver.unresolvedIds].
///
/// [corpusViolations] is a pure function of (path, contents), so AC4's
/// negative cases are driven with in-memory fixtures: **no asset is edited to
/// test the gate.** A broken page is a string here, not a file on disk.
library;

import 'dart:io';

import 'package:dabbler_design_system/src/gallery/docs/doc_page.dart';
import 'package:dabbler_design_system/src/gallery/docs/doc_specimen_resolver.dart';
import 'package:dabbler_design_system/src/gallery/docs/doc_vocabulary.dart';
import 'package:dabbler_design_system/src/gallery/gallery_entry.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The one file excluded entirely — `D-042`(e): `_order.md` is not a page.
///
/// **Excluded by path, deliberately, not incidentally** (AC3). Named here and
/// asserted below, so the exclusion cannot quietly decay into "it happens not
/// to match the vocabulary anyway".
const String notAPage = '_order.md';

/// `assets/documentation`, relative to the package root tests run from.
const String corpusRoot = DabblerDocVocabulary.assetRoot;

/// Every `.md` in the corpus except [notAPage], sorted for stable reporting.
List<File> corpusFiles() => Directory(corpusRoot)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File f) => f.path.endsWith('.md') && !f.path.endsWith('/$notAPage'))
    .toList()
  ..sort((File a, File b) => a.path.compareTo(b.path));

/// A sentence terminator followed by the start of another sentence.
///
/// Rule (a)'s "a single sentence" needs a boundary test, and the corpus writes
/// `D-042(b).`, `e.g.` and `v1.2` — splitting naively on `.` calls all three
/// two sentences. A boundary is a terminator, then space, then a capital or an
/// opening backtick/bracket, which is how the corpus actually opens one.
final RegExp _sentenceBoundary = RegExp(r'[.!?]["’)]?\s+(?=[A-Z`\[(])');

/// Every rule (a)/vocabulary/order/specimen violation in one page.
///
/// Empty means the page conforms. Each entry is a sentence a reader can act on
/// without opening this file.
List<String> corpusViolations(
  String assetPath,
  String raw, {
  DabblerDocSpecimenResolver? resolver,
}) {
  final List<String> found = <String>[];
  final DabblerDocPageKind kind =
      DabblerDocVocabulary.kindForAssetPath(assetPath);
  if (kind == DabblerDocPageKind.notAPage) {
    return found;
  }
  final DabblerDocPage page = DabblerDocSplitter.split(assetPath, raw);

  // Rule (a) binds EVERY kind, start-here.md included, and is checked
  // separately from heading membership. Exactly two paragraphs between the `#`
  // title and the first `##`: a one-sentence Definition, then the Intro. A
  // `### ` in the lead is a heading, not a paragraph, so it is not counted —
  // most component pages open `# Toast` / `### `DabblerToast``.
  final List<DabblerDocProse> leadProse =
      page.lead.whereType<DabblerDocProse>().toList();
  if (leadProse.length != 2) {
    found.add('lead prose: expected exactly 2 paragraphs (Definition, then '
        'Intro), found ${leadProse.length}');
  } else {
    final String definition = leadProse.first.markup.trim();
    if (_sentenceBoundary.hasMatch(definition)) {
      found.add('lead prose: the Definition paragraph must be a single '
          'sentence — "${definition.replaceAll('\n', ' ')}"');
    }
  }

  // An empty vocabulary means UNCONSTRAINED (start-here.md), never "no
  // headings allowed" — doc_vocabulary.dart says so in as many words.
  if (DabblerDocVocabulary.isGoverned(kind)) {
    final List<DabblerDocHeading> vocabulary =
        DabblerDocVocabulary.forKind(kind);
    final List<String> legal =
        vocabulary.map((DabblerDocHeading h) => h.text).toList();
    final List<String> present =
        page.sections.map((DabblerDocSection s) => s.heading).toList();

    for (final String heading in present) {
      if (!legal.contains(heading)) {
        found.add('heading "$heading" is not in the ${kind.name} vocabulary '
            '(${legal.join(" · ")})');
      }
    }
    for (final DabblerDocHeading h in vocabulary) {
      if (h.required && !present.contains(h.text)) {
        found.add('required heading "${h.text}" is missing');
      }
    }
    // Ordering is the table order: a present-but-misordered heading fails
    // exactly as an unrecognised one does (D-042(f)).
    final List<String> recognised = present.where(legal.contains).toList();
    final List<String> expected = legal.where(recognised.contains).toList();
    if (recognised.join('|') != expected.join('|')) {
      found.add('headings out of order: found ${recognised.join(" · ")}, '
          'expected ${expected.join(" · ")}');
    }
    // Optional means omitted, never emptied — a present heading with no body
    // fails, and there is no way to spell an accepted stub.
    for (final DabblerDocSection s in page.sections) {
      if (s.blocks.isEmpty) {
        found.add('section "${s.heading}" is present but empty — optional '
            'means omitted, never emptied');
      }
    }
  }

  // Zero `@specimen` lines exist in the corpus today; that is KAN-325 AC4 not
  // having landed, and nothing to resolve is not a failure.
  final List<String> unresolved =
      (resolver ?? DabblerDocSpecimenResolver(const <GalleryEntry>[]))
          .unresolvedIds(page);
  for (final String id in unresolved) {
    found.add('@specimen "$id" resolves to no gallery entry');
  }
  return found;
}

void main() {
  group('KAN-324 — the corpus conforms (AC5)', () {
    test('every in-scope page passes rule (a), vocabulary, order and specimens',
        () {
      final List<File> files = corpusFiles();
      expect(files.length, greaterThan(50),
          reason: 'found ${files.length} pages — the walk is not reaching the '
              'corpus, and a gate that reads nothing passes vacuously');

      final Map<String, List<String>> failures = <String, List<String>>{};
      for (final File f in files) {
        final List<String> v = corpusViolations(f.path, f.readAsStringSync());
        if (v.isNotEmpty) failures[f.path] = v;
      }
      expect(failures, isEmpty,
          reason: 'The corpus was re-baselined clean; a red result here is a '
              'real regression:\n${failures.entries.map((MapEntry<String, List<String>> e) => '  ${e.key}\n${e.value.map((String s) => '    - $s').join('\n')}').join('\n')}');
    });

    test('the three vocabularies come from KAN-323, not from here', () {
      expect(DabblerDocVocabulary.component.length, 7);
      expect(DabblerDocVocabulary.foundations.length, 6);
      expect(DabblerDocVocabulary.patterns.length, 4);
      expect(
        DabblerDocVocabulary.foundations
            .any((DabblerDocHeading h) => h.text == 'Tokens used'),
        isFalse,
        reason: 'D-034(a): on a Foundations page its presence is the error',
      );
    });
  });

  group('KAN-324 — exclusions and exemptions (AC3)', () {
    test('_order.md is excluded by path, explicitly', () {
      expect(DabblerDocVocabulary.kindForAssetPath('$corpusRoot/$notAPage'),
          DabblerDocPageKind.notAPage);
      expect(corpusFiles().where((File f) => f.path.endsWith(notAPage)),
          isEmpty,
          reason: 'the walk must exclude it by name, not by luck');
      expect(corpusViolations('$corpusRoot/$notAPage', '# not a page'), isEmpty);
    });

    test('start-here.md is vocabulary-exempt but bound by rule (a)', () {
      expect(DabblerDocVocabulary.kindForAssetPath('$corpusRoot/start-here.md'),
          DabblerDocPageKind.exempt);
      expect(
        corpusViolations('$corpusRoot/start-here.md',
            '# Start here\n\nOne sentence.\n\nIntro.\n\n## Anything at all\n\nBody.\n'),
        isEmpty,
      );
      expect(
        corpusViolations('$corpusRoot/start-here.md',
            '# Start here\n\nOnly one paragraph.\n\n## Anything\n\nBody.\n'),
        contains(startsWith('lead prose:')),
      );
    });
  });

  group('KAN-324 — the gate can fail (AC4)', () {
    const String good = '# Button\n\n'
        'A button is the one control that commits an action.\n\n'
        'Intro paragraph that may run to several sentences. It does here.\n\n'
        '## Specimen\n\nBody.\n\n'
        '## Using it\n\nBody.\n\n'
        '## Tokens used\n\nBody.\n\n'
        '## Source\n\nBody.\n';
    const String path = '$corpusRoot/components/button.md';

    test('the control case passes, or every negative below proves nothing', () {
      expect(corpusViolations(path, good), isEmpty);
    });

    test('an unrecognised heading fails', () {
      expect(corpusViolations(path, good.replaceFirst('## Using it', '## Usage')),
          contains(contains('not in the component vocabulary')));
    });

    test('a misordered heading fails', () {
      const String swapped = '# Button\n\n'
          'A button is the one control that commits an action.\n\n'
          'Intro.\n\n'
          '## Using it\n\nBody.\n\n'
          '## Specimen\n\nBody.\n\n'
          '## Tokens used\n\nBody.\n\n'
          '## Source\n\nBody.\n';
      expect(corpusViolations(path, swapped), contains(contains('out of order')));
    });

    test('an optional heading present but empty fails', () {
      expect(
        corpusViolations(
            path, good.replaceFirst('## Source', '## Change log\n\n## Source')),
        contains(contains('present but empty')),
      );
    });

    test('a required heading missing fails', () {
      expect(
        corpusViolations(
            path, good.replaceFirst('## Tokens used\n\nBody.\n\n', '')),
        contains(contains('required heading "Tokens used" is missing')),
      );
    });

    test('Tokens used on a Foundations page fails (D-034(a))', () {
      expect(corpusViolations('$corpusRoot/foundations/colour.md', good),
          contains(contains('not in the foundations vocabulary')));
    });

    test('a two-sentence Definition fails rule (a)', () {
      expect(
        corpusViolations(
            path,
            good.replaceFirst(
                'A button is the one control that commits an action.',
                'A button commits an action. It is the only control that does.')),
        contains(contains('must be a single sentence')),
      );
    });

    test('a lead of one paragraph fails rule (a)', () {
      expect(
        corpusViolations(
            path,
            good.replaceFirst(
                'Intro paragraph that may run to several sentences. It does here.\n\n',
                '')),
        contains(contains('expected exactly 2 paragraphs')),
      );
    });

    test('an unresolved @specimen id fails', () {
      expect(
        corpusViolations(path,
            good.replaceFirst('## Specimen\n\nBody.', '## Specimen\n\n@specimen no-such-entry')),
        contains(contains('resolves to no gallery entry')),
      );
    });

    test('a resolvable @specimen id passes', () {
      final DabblerDocSpecimenResolver resolver =
          DabblerDocSpecimenResolver(<GalleryEntry>[
        GalleryEntry(
          id: 'real-entry',
          title: 'Real',
          page: 'x',
          group: GalleryPurpose.navigation,
          builder: (BuildContext _) => const SizedBox.shrink(),
        ),
      ]);
      expect(
        corpusViolations(
          path,
          good.replaceFirst('## Specimen\n\nBody.', '## Specimen\n\n@specimen real-entry'),
          resolver: resolver,
        ),
        isEmpty,
      );
    });
  });
}
