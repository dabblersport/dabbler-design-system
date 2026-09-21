/// Band-order gate — `T-087`(h)'s recommended containment, in `T-086`'s shape.
///
/// Run it:
///
/// ```
/// dart run tool/check_order_bands.dart            # the real corpus
/// dart run tool/check_order_bands.dart --self-test # the gate's own evidence
/// ```
///
/// Exits non-zero on findings, zero when the two artefacts agree.
///
/// ## The drift this catches
///
/// Two artefacts that must agree and have no mechanism keeping them agreed:
///
/// - `assets/documentation/_order.md` — the authored reading order, whose
///   `## Components` group headings are the index's band sequence since
///   `D-049` (`gallery_index.dart:104-128`);
/// - `enum GalleryPurpose` in `lib/src/gallery/gallery_entry.dart`, whose
///   `label` strings are what an entry's band is matched by, and whose
///   declaration order is still the fallback when the file cannot be read
///   (`D-047`(d)).
///
/// **A label renamed on one side and not the other, a group added to the enum
/// and never written into the file, or the two sequences diverging, is
/// invisible.** The gallery renders nine bands either way: the fallback path
/// and the authored path produce the same screen while the two agree, and a
/// divergence shows up only as a band silently sorted to the end or an entry
/// filed under a name the reading order never mentions. This is `T-087`(b)'s
/// drift class, not a behaviour: nothing here pumps a widget or asserts what
/// renders.
///
/// `cto` named this gate in `T-087`(h) — *"the invariant underneath the first
/// of these … IS a population drift and IS gate-shaped … a few lines in the
/// `T-086` shape would cover it and would make the stub test redundant."*
/// `KAN-342` builds it and removes that stub test.
///
/// ## Why it is a script and not a test
///
/// `T-087`(c)'s placement standard: `tool/` when the check can reach its
/// evidence without `dart:ui`. It can — both artefacts are files on disk,
/// read with `dart:io`. **This file imports nothing from the package**,
/// because `gallery_entry.dart` pulls in Flutter through `GalleryEntry`'s
/// `WidgetBuilder`; the enum is therefore read from its source text, which is
/// also what makes the comparison a comparison of two artefacts rather than
/// a program asking itself.
///
/// ## What this proves, and what it does NOT
///
/// It proves the two **authored sequences** match. It does not prove the
/// index renders them — that is the degradation behaviour left in
/// `test/gallery_index_order_test.dart`, which `T-087`(h) explicitly declines
/// to classify and which this gate does not claim to cover.
library;

import 'dart:io';

/// The authored reading order.
const String orderPath = 'assets/documentation/_order.md';

/// Where `enum GalleryPurpose` is declared.
const String purposePath = 'lib/src/gallery/gallery_entry.dart';

/// The `_order.md` section whose `###` headings are the band sequence.
///
/// `## Foundations` and `## Patterns` are not purpose groups — Foundations is
/// hardcoded first by `D-033`(a) and is not what moved to the file.
const String componentsSection = 'Components';

/// `### 1 · Navigation — orienting the user…`; ordinal and tagline optional.
final RegExp groupHeading =
    RegExp(r'^###\s+(?:\d+\s*·\s*)?([^—]+?)(?:\s+—\s+.*)?$');

/// `navigation('Navigation'),` — an enum value and its label.
final RegExp enumValue = RegExp(r"^\s*[a-z][A-Za-z0-9]*\('([^']+)'\)\s*[,;]");

/// The group names under `## Components`, in the order the file writes them.
List<String> readFileGroups(String raw) {
  final List<String> names = <String>[];
  bool inComponents = false;
  for (final String line in raw.split('\n')) {
    final String trimmed = line.trimRight();
    if (trimmed.startsWith('## ')) {
      inComponents = trimmed.substring(3).trim() == componentsSection;
      continue;
    }
    if (!inComponents) continue;
    final RegExpMatch? m = groupHeading.firstMatch(trimmed);
    if (m != null) names.add(m.group(1)!.trim());
  }
  return names;
}

/// The `GalleryPurpose` labels, in declaration order.
List<String> readEnumLabels(String source) {
  final int at = source.indexOf('enum GalleryPurpose {');
  if (at < 0) return const <String>[];
  final List<String> labels = <String>[];
  for (final String line in source.substring(at).split('\n').skip(1)) {
    if (line.startsWith('}')) break;
    // The constructor and the field sit after the last value; a `;` value
    // terminator ends the list, which `enumValue` already requires.
    final RegExpMatch? m = enumValue.firstMatch(line);
    if (m != null) labels.add(m.group(1)!);
  }
  return labels;
}

/// Compares the two sequences and names every disagreement.
List<String> compare(List<String> fileGroups, List<String> enumLabels) {
  final List<String> findings = <String>[];
  if (fileGroups.isEmpty) {
    findings.add('$orderPath declares no `## $componentsSection` groups');
  }
  if (enumLabels.isEmpty) {
    findings.add('no `enum GalleryPurpose` values found in $purposePath');
  }
  if (findings.isNotEmpty) return findings;

  for (final String label in enumLabels) {
    if (!fileGroups.contains(label)) {
      findings.add(
        'GalleryPurpose declares "$label", which `$orderPath` never names — '
        'the band sorts after every authored one instead of where the reading '
        'order wants it',
      );
    }
  }
  for (final String name in fileGroups) {
    if (!enumLabels.contains(name)) {
      findings.add(
        '`$orderPath` names the group "$name", which no GalleryPurpose label '
        'spells — no entry can ever land in it',
      );
    }
  }
  if (findings.isNotEmpty) return findings;

  for (int i = 0; i < fileGroups.length; i++) {
    if (fileGroups[i] != enumLabels[i]) {
      findings.add(
        'position ${i + 1}: `$orderPath` says "${fileGroups[i]}", '
        'GalleryPurpose declares "${enumLabels[i]}" — the sequences have '
        'diverged, so the fallback order and the authored order no longer '
        'render the same index',
      );
    }
  }
  return findings;
}

/// The gate's own can-it-fail evidence — `T-087`(b), one case per rule class,
/// every one driven by an in-memory fixture and never by editing an asset.
int selfTest() {
  String orderMd(List<String> groups) {
    final StringBuffer b = StringBuffer('# Reading order\n\nLead.\n\n'
        '## Foundations\n\n- [Colour](foundations/colour.md) — x.\n\n'
        '## Components\n\n');
    for (int i = 0; i < groups.length; i++) {
      b
        ..writeln('### ${i + 1} · ${groups[i]} — a tagline\n')
        ..writeln('- [A page](components/a.md) — one line.\n');
    }
    return b.toString();
  }

  String enumSource(List<String> labels) {
    final StringBuffer b = StringBuffer('enum GalleryPurpose {\n');
    for (int i = 0; i < labels.length; i++) {
      b.writeln("  value$i('${labels[i]}')${i == labels.length - 1 ? ';' : ','}");
    }
    return (b..writeln('\n  const GalleryPurpose(this.label);\n')
          ..writeln('  final String label;')
          ..writeln('}'))
        .toString();
  }

  const List<String> abc = <String>['Alpha', 'Beta', 'Gamma'];
  final List<({String name, List<String> file, List<String> declared})> cases =
      <({String name, List<String> file, List<String> declared})>[
    (name: 'agreement is clean', file: abc, declared: abc),
    (
      name: 'a label the file never names',
      file: <String>['Alpha', 'Beta'],
      declared: abc,
    ),
    (
      name: 'a group no label spells',
      file: abc,
      declared: <String>['Alpha', 'Beta'],
    ),
    (
      name: 'the sequences diverge',
      file: <String>['Gamma', 'Beta', 'Alpha'],
      declared: abc,
    ),
  ];

  int failures = 0;
  for (final ({String name, List<String> file, List<String> declared}) c
      in cases) {
    final bool shouldPass = c.name == 'agreement is clean';
    final List<String> found = compare(
      readFileGroups(orderMd(c.file)),
      readEnumLabels(enumSource(c.declared)),
    );
    final bool passed = found.isEmpty;
    if (passed != shouldPass) {
      failures++;
      stdout.writeln('  FAIL  ${c.name} — '
          '${passed ? 'the gate stayed green' : 'the gate went red'} and '
          'should not have');
    } else {
      stdout.writeln('  ok    ${c.name}'
          '${found.isEmpty ? '' : ' → ${found.length} finding(s)'}');
    }
  }
  stdout.writeln('band-order gate self-test — ${cases.length} cases, '
      '${failures == 0 ? 'clean' : '$failures failed'}');
  return failures == 0 ? 0 : 1;
}

void main(List<String> args) {
  if (args.contains('--self-test')) {
    exit(selfTest());
  }

  final File order = File(orderPath);
  final File purpose = File(purposePath);
  if (!order.existsSync() || !purpose.existsSync()) {
    stderr.writeln('missing $orderPath or $purposePath — run from the '
        'package root');
    exit(2);
  }

  final List<String> fileGroups = readFileGroups(order.readAsStringSync());
  final List<String> enumLabels = readEnumLabels(purpose.readAsStringSync());
  final List<String> findings = compare(fileGroups, enumLabels);

  stdout.writeln('band-order gate — ${fileGroups.length} authored group(s), '
      '${enumLabels.length} GalleryPurpose label(s)');
  if (findings.isEmpty) {
    stdout.writeln('clean');
    exit(0);
  }
  stdout.writeln('${findings.length} finding(s):');
  for (final String f in findings) {
    stdout.writeln('  $f');
  }
  exit(1);
}
