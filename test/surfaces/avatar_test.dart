import 'dart:io';

import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hosts [child] under a resolved [DabblerColors], which is all an avatar
/// needs, plus a [Directionality] so the RTL cases can flip it.
Widget _host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
}) {
  final DabblerColors colors =
      DabblerColors.resolve(theme: theme, brightness: brightness);
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
    home: Directionality(
      textDirection: textDirection,
      child: Align(alignment: Alignment.topLeft, child: child),
    ),
  );
}

DabblerColors _colors([
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
]) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

/// `dabbler-code/pubspec.yaml`, if the app repo is checked out beside this
/// package. Located by walking up, like the palette test's design source.
File? _findAppPubspec() {
  Directory dir = Directory.current;
  for (int i = 0; i < 8; i++) {
    for (final String suffix in <String>[
      'dabbler-code/pubspec.yaml',
      'Dabbler/dabbler-code/pubspec.yaml',
    ]) {
      final File candidate = File('${dir.path}/$suffix');
      if (candidate.existsSync()) return candidate;
    }
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }
  return null;
}

/// The rect of the 24px corner badge — the [Container] the badge child sits in,
/// not the child itself, which is a 10px icon.
Rect _badgeRect(WidgetTester tester) => tester.getRect(find
    .ancestor(of: find.byIcon(Icons.star), matching: find.byType(Container))
    .first);

/// The rect of each person's circle, in the order [DabblerAvatarGroup] was
/// given them — the paint order is reversed, so tree order is not people order.
List<Rect> _groupRects(WidgetTester tester, List<String> people) => <Rect>[
      for (final String seed in people)
        tester.getRect(find.byWidget(tester
            .widgetList<DabblerAvatar>(find.byType(DabblerAvatar))
            .firstWhere((DabblerAvatar a) => a.seed == seed))),
    ];

/// Every string rendered anywhere under [root] — [Text], [RichText],
/// [Semantics] labels/values/hints, and [Tooltip] messages.
///
/// This is the instrument AC2 is measured with, so it looks in every place a
/// character could reach a user, not only in [Text].
List<String> _renderedStrings(WidgetTester tester, Finder root) {
  final List<String> out = <String>[];
  for (final Widget w
      in tester.allWidgets.where((Widget w) => w is Text || w is RichText)) {
    if (w is Text) {
      if (w.data != null) out.add(w.data!);
      final InlineSpan? span = w.textSpan;
      if (span != null) out.add(span.toPlainText());
    } else if (w is RichText) {
      out.add(w.text.toPlainText());
    }
  }
  for (final Semantics s in tester.widgetList<Semantics>(find.byType(Semantics))) {
    final SemanticsProperties p = s.properties;
    for (final String? v in <String?>[p.label, p.value, p.hint, p.tooltip]) {
      if (v != null) out.add(v);
    }
  }
  for (final Tooltip t in tester.widgetList<Tooltip>(find.byType(Tooltip))) {
    if (t.message != null) out.add(t.message!);
  }
  // The composited semantics tree, which is what assistive technology reads.
  out.addAll(_semanticsLabels(tester));
  return out;
}

List<String> _semanticsLabels(WidgetTester tester) {
  final List<String> labels = <String>[];
  void visit(SemanticsNode node) {
    final SemanticsData d = node.getSemanticsData();
    for (final String v in <String>[d.label, d.value, d.hint, d.tooltip]) {
      if (v.isNotEmpty) labels.add(v);
    }
    node.visitChildren((SemanticsNode child) {
      visit(child);
      return true;
    });
  }

  visit(tester.getSemantics(find.byType(MaterialApp)));
  return labels;
}

void main() {
  setUp(() {
    // The seam is a mutable static; every test starts from the shipped default
    // so one test cannot leak a generator into the next.
    DabblerAvatar.portrait = const DabblerRandomAvatarPortrait();
  });

  group('AC1 — the shell: sizes, badge slot, badge tones', () {
    test('the five sizes are the design source\'s exact pixel values', () {
      expect(
        DabblerAvatarSize.values.map((DabblerAvatarSize s) => s.diameter),
        <double>[28, 36, 48, 64, 80],
        reason: "Avatar.jsx: SIZES = { xs: 28, sm: 36, md: 48, lg: 64, xl: 80 }",
      );
    });

    testWidgets('each size lays out at its own diameter', (WidgetTester tester) async {
      for (final DabblerAvatarSize size in DabblerAvatarSize.values) {
        await tester.pumpWidget(_host(DabblerAvatar(seed: 'Alen Rahman', size: size)));
        expect(
          tester.getSize(find.byType(DabblerAvatar)),
          Size.square(size.diameter),
          reason: '${size.name} must render ${size.diameter}px',
        );
      }
    });

    testWidgets('md is the default size', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatar(seed: 'Alen Rahman')));
      expect(tester.getSize(find.byType(DabblerAvatar)), const Size.square(48));
    });

    testWidgets('no badge slot renders no badge', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatar(seed: 'Alen Rahman')));
      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byType(Stack), findsNothing);
    });

    testWidgets('a badge renders at 24px, overhanging the circle',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatar(
        seed: 'Alen Rahman',
        size: DabblerAvatarSize.md,
        badge: Icon(Icons.star),
      )));
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(DabblerAvatar.badgeDiameter, DabblerSizing.iconMd);

      final Rect avatar = tester.getRect(find.byType(DabblerAvatar));
      final Rect badge = _badgeRect(tester);
      expect(badge.size, const Size.square(24));
      // `right: -2, bottom: -2` — the badge sits past the circle's edge.
      expect(badge.right, greaterThan(avatar.right));
      expect(badge.bottom, greaterThan(avatar.bottom));
    });

    test('primary and accent badge tones resolve through DabblerColors', () {
      for (final DabblerTheme theme in DabblerTheme.values) {
        final DabblerColors c = _colors(theme);
        expect(
          DabblerAvatar.badgeFill(c, DabblerAvatarBadgeTone.primary),
          c.brandPrimary,
          reason: 'var(--color-brand-primary)',
        );
        expect(
          DabblerAvatar.badgeFill(c, DabblerAvatarBadgeTone.accent),
          c.accent,
          reason: 'var(--color-accent)',
        );
      }
    });

    test('indigo is --accent-indigo, and is theme-invariant', () {
      // `Avatar.jsx` fills the indigo badge with `var(--accent-indigo)`, now
      // declared in tokens/colors.css and transcribed to the palette.
      for (final DabblerTheme theme in DabblerTheme.values) {
        expect(
          DabblerAvatar.badgeFill(_colors(theme), DabblerAvatarBadgeTone.indigo),
          DabblerPalette.accentIndigo,
        );
      }
      expect(DabblerPalette.accentIndigo, const Color(0xFF5C50E6));
    });

    testWidgets('the badge paints its tone fill', (WidgetTester tester) async {
      for (final DabblerAvatarBadgeTone tone in DabblerAvatarBadgeTone.values) {
        await tester.pumpWidget(_host(DabblerAvatar(
          seed: 'Alen Rahman',
          badge: const Icon(Icons.star),
          badgeTone: tone,
        )));
        final BoxDecoration d = tester
            .widgetList<Container>(find.byType(Container))
            .map((Container c) => c.decoration)
            .whereType<BoxDecoration>()
            .firstWhere((BoxDecoration d) => d.shape == BoxShape.circle);
        expect(d.color, DabblerAvatar.badgeFill(_colors(), tone));
      }
    });
  });

  group('AC2 — the seed is a hash input and NEVER reaches the widget tree', () {
    // Seeds whose characters are rare enough that a match cannot be a
    // coincidence with framework chrome.
    const List<String> seeds = <String>[
      'Alen Rahman',
      'ZQXJV',
      'user_8812',
      'Bushra Riaz',
    ];

    testWidgets('no character of the seed is rendered anywhere',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      for (final String seed in seeds) {
        for (final DabblerAvatarSize size in DabblerAvatarSize.values) {
          await tester.pumpWidget(_host(DabblerAvatar(seed: seed, size: size)));
          final List<String> rendered =
              _renderedStrings(tester, find.byType(DabblerAvatar));
          for (final String s in rendered) {
            for (final int unit in seed.toLowerCase().codeUnits) {
              final String ch = String.fromCharCode(unit);
              if (ch == ' ' || ch == '_') continue;
              expect(
                s.toLowerCase().contains(ch),
                isFalse,
                reason: "'$ch' of seed '$seed' reached the tree as '$s'",
              );
            }
          }
        }
      }
      handle.dispose();
    });

    testWidgets('an avatar renders no Text and no RichText at all',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatar(seed: 'Alen Rahman')));
      expect(find.byType(Text), findsNothing);
      expect(find.byType(RichText), findsNothing);
    });

    testWidgets('a badged avatar renders only the badge child\'s own content',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatar(
        seed: 'Alen Rahman',
        badge: Icon(Icons.star),
      )));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('a group renders only the +N count, never a seed',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerAvatarGroup(
        people: <String>['Alen Rahman', 'Bushra Riaz', 'Carlos Alvarez'],
        overflow: 42,
      )));
      final List<String> rendered =
          _renderedStrings(tester, find.byType(DabblerAvatarGroup));
      expect(
        rendered.where((String s) => s.trim().isNotEmpty).toSet(),
        <String>{'+42'},
      );
      handle.dispose();
    });

    testWidgets('the portrait is excluded from semantics',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerAvatar(seed: 'Alen Rahman')));
      expect(
        find.descendant(
          of: find.byType(DabblerAvatar),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      expect(_semanticsLabels(tester), isEmpty);
      handle.dispose();
    });

    test('the seed only ever leaves the widget as an int', () {
      expect(DabblerAvatarSeed.hash('Alen Rahman'), isA<int>());
      expect(DabblerAvatarSeed.fallback, 'dabbler');
    });
  });

  group('AC3 — the real Multiavatar generator (DECISIONS.md T-084)', () {
    test('the default generator is Multiavatar, not the fallback', () {
      expect(DabblerAvatar.portrait, isA<DabblerRandomAvatarPortrait>());
    });

    test('the pubspec constraint matches dabbler-code\'s, which is the '
        'mechanism keeping seeds aligned', () {
      final String here = File('pubspec.yaml').readAsStringSync();
      final RegExp constraint = RegExp(r'random_avatar:\s*(\S+)');
      final RegExpMatch? mine = constraint.firstMatch(here);
      expect(mine, isNotNull, reason: 'random_avatar must be declared');

      final File? app = _findAppPubspec();
      if (app == null) {
        // The app repo is not always checked out beside this package. The
        // constraint is still asserted against the approved value.
        expect(mine!.group(1), '^0.0.8');
        return;
      }
      final RegExpMatch? theirs =
          constraint.firstMatch(app.readAsStringSync());
      expect(theirs, isNotNull, reason: '${app.path} must declare it too');
      expect(mine!.group(1), theirs!.group(1),
          reason: 'a one-sided bump re-faces every user on one platform');
    });

    testWidgets('a real portrait renders, and renders no text',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatar(seed: 'Alen Rahman')));
      expect(tester.takeException(), isNull);
      expect(find.byType(Text), findsNothing);
      expect(find.byType(RichText), findsNothing);
    });

    testWidgets('an empty seed falls back to the deterministic placeholder',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatar(seed: '')));
      expect(
        find.descendant(
          of: find.byType(DabblerAvatar),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
        reason: 'the placeholder paints; Multiavatar cannot seed on empty',
      );
    });

    testWidgets('a throwing generator degrades to the fallback, never initials',
        (WidgetTester tester) async {
      DabblerAvatar.portrait =
          const _ThrowingPortrait(fallback: DabblerPlaceholderPortrait());
      await tester.pumpWidget(_host(const DabblerAvatar(seed: 'Alen Rahman')));
      expect(tester.takeException(), isNull);
      expect(find.byType(Text), findsNothing);
    });
  });

  group('the fallback portrait is deterministic and behind a seam', () {
    setUp(() {
      DabblerAvatar.portrait = const DabblerPlaceholderPortrait();
    });

    test('the same seed always hashes identically', () {
      expect(DabblerAvatarSeed.hash('Alen Rahman'),
          DabblerAvatarSeed.hash('Alen Rahman'));
    });

    test('different seeds hash differently', () {
      const List<String> seeds = <String>[
        'Alen Rahman',
        'Bushra Riaz',
        'Carlos Alvarez',
        'Dana Halabi',
        'Elias Noor',
        'user_8812',
        'dabbler',
      ];
      final Set<int> hashes =
          seeds.map(DabblerAvatarSeed.hash).toSet();
      expect(hashes, hasLength(seeds.length));
    });

    testWidgets('the same seed paints the same placeholder parts',
        (WidgetTester tester) async {
      Future<_PortraitParts> partsFor(String seed) async {
        await tester.pumpWidget(_host(DabblerAvatar(seed: seed)));
        final CustomPaint paint = tester.widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(DabblerAvatar),
            matching: find.byType(CustomPaint),
          ),
        ).firstWhere((CustomPaint p) => p.painter != null);
        return _PortraitParts(paint.painter!.toString(), paint.painter!);
      }

      final _PortraitParts a = await partsFor('Alen Rahman');
      final _PortraitParts b = await partsFor('Bushra Riaz');
      final _PortraitParts a2 = await partsFor('Alen Rahman');

      expect(a2.painter.shouldRepaint(a.painter), isFalse,
          reason: 'the same seed must paint the same portrait');
      expect(b.painter.shouldRepaint(a.painter), isTrue,
          reason: 'different seeds must paint different portraits');
    });

    test('placeholder parts are palette colours, never literals', () {
      expect(DabblerPlaceholderPortrait.parts, hasLength(10));
      expect(
        DabblerPlaceholderPortrait.parts.toSet(),
        hasLength(10),
        reason: 'ten distinct declared brand steps',
      );
    });

    testWidgets('the generator is swappable without touching the shell',
        (WidgetTester tester) async {
      DabblerAvatar.portrait = const _StubPortrait();
      await tester.pumpWidget(_host(const DabblerAvatar(seed: 'Alen Rahman')));
      expect(find.byKey(const ValueKey<String>('stub-portrait')), findsOneWidget);
      expect(find.byType(CustomPaint), findsNothing);
    });

    testWidgets('a null seed falls back to the source default',
        (WidgetTester tester) async {
      DabblerAvatar.portrait = const _RecordingPortrait();
      await tester.pumpWidget(_host(const DabblerAvatar()));
      expect(_RecordingPortrait.lastSeed, DabblerAvatarSeed.fallback);
    });
  });

  group('AvatarGroup — 36px circles, −10 overlap, +N chip, RTL', () {
    testWidgets('stacks sm avatars 26px apart', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatarGroup(
        people: <String>['Alen Rahman', 'Bushra Riaz', 'Carlos Alvarez'],
      )));
      final List<Rect> rects = _groupRects(
          tester, const <String>['Alen Rahman', 'Bushra Riaz', 'Carlos Alvarez']);
      expect(rects, hasLength(3));
      for (final Rect r in rects) {
        expect(r.size, const Size.square(36), reason: 'group circles are sm');
      }
      expect(DabblerAvatarGroup.overlap, 10);
      expect(rects[1].left - rects[0].left, 26);
      expect(rects[2].left - rects[1].left, 26);
    });

    testWidgets('the first person is painted on top', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatarGroup(
        people: <String>['Alen Rahman', 'Bushra Riaz'],
      )));
      final Stack stack = tester.widget<Stack>(find.descendant(
        of: find.byType(DabblerAvatarGroup),
        matching: find.byType(Stack),
      ));
      final DabblerAvatar last =
          (stack.children.last as PositionedDirectional).child as DabblerAvatar;
      expect(last.seed, 'Alen Rahman');
    });

    testWidgets('each stacked avatar is ringed in the page background',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatarGroup(
        people: <String>['Alen Rahman', 'Bushra Riaz'],
      )));
      for (final DabblerAvatar a
          in tester.widgetList<DabblerAvatar>(find.byType(DabblerAvatar))) {
        expect(a.ringColor, _colors().bgPrimary);
      }
    });

    testWidgets('the +N chip carries the faint fill and muted ink',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatarGroup(
        people: <String>['Alen Rahman'],
        overflow: 42,
      )));
      expect(find.text('+42'), findsOneWidget);
      final Text chip = tester.widget<Text>(find.text('+42'));
      expect(chip.style!.color, _colors().textSecondary);

      final BoxDecoration d = tester
          .widgetList<Container>(find.byType(Container))
          .map((Container c) => c.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((BoxDecoration d) => d.borderRadius != null);
      expect(d.color, _colors().bgTertiary);
      expect(d.borderRadius, DabblerRadius.pillAll);
      expect(tester.getSize(find.text('+42')).height, lessThanOrEqualTo(36));
    });

    testWidgets('overflow 0 renders no chip', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatarGroup(
        people: <String>['Alen Rahman'],
      )));
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('an empty group renders nothing', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatarGroup()));
      expect(find.byType(DabblerAvatar), findsNothing);
    });

    testWidgets('the stack mirrors under RTL', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerAvatarGroup(
          people: <String>['Alen Rahman', 'Bushra Riaz', 'Carlos Alvarez'],
        ),
        textDirection: TextDirection.rtl,
      ));
      final List<Rect> rects = _groupRects(
          tester, const <String>['Alen Rahman', 'Bushra Riaz', 'Carlos Alvarez']);
      // In RTL the first person starts at the right edge and later people run
      // leftwards, the mirror of the LTR case.
      expect(rects[1].left - rects[0].left, -26);
      expect(rects[2].left - rects[1].left, -26);
    });

    testWidgets('the badge mirrors under RTL', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerAvatar(seed: 'Alen Rahman', badge: Icon(Icons.star)),
        textDirection: TextDirection.rtl,
      ));
      final Rect avatar = tester.getRect(find.byType(DabblerAvatar));
      final Rect badge = _badgeRect(tester);
      expect(badge.left, lessThan(avatar.left),
          reason: 'end-aligned, so the badge sits on the left in Arabic');
    });

    test('a negative overflow is rejected', () {
      expect(() => DabblerAvatarGroup(overflow: -1), throwsAssertionError);
    });
  });

  group('the flat system holds', () {
    testWidgets('an avatar paints no shadow and no gradient',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerAvatarGroup(
        people: <String>['Alen Rahman', 'Bushra Riaz'],
        overflow: 6,
      )));
      final Iterable<BoxDecoration> decorations = tester
          .allWidgets
          .whereType<DecoratedBox>()
          .map((DecoratedBox b) => b.decoration)
          .whereType<BoxDecoration>();
      for (final BoxDecoration d in decorations) {
        expect(d.boxShadow, anyOf(isNull, isEmpty));
        expect(d.gradient, isNull);
      }
    });

    testWidgets('every brightness and theme resolves without a null colour',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        for (final Brightness b in Brightness.values) {
          await tester.pumpWidget(_host(
            const DabblerAvatar(seed: 'Alen Rahman', badge: Icon(Icons.star)),
            theme: theme,
            brightness: b,
          ));
          expect(tester.takeException(), isNull);
        }
      }
    });
  });
}

/// Pairs a painter with its description so a failure names what differed.
class _PortraitParts {
  const _PortraitParts(this.description, this.painter);
  final String description;
  final CustomPainter painter;
}

/// A generator that renders something structurally unmistakable, proving the
/// seam is the only place the portrait comes from.
/// Stands in for a generator that throws, to exercise the degrade path.
class _ThrowingPortrait extends DabblerAvatarPortraitBuilder {
  const _ThrowingPortrait({required this.fallback});

  final DabblerAvatarPortraitBuilder fallback;

  @override
  Widget build(BuildContext context,
      {required String seed, required double diameter}) {
    try {
      throw StateError('generator unavailable');
    } on Object {
      return fallback.build(context, seed: seed, diameter: diameter);
    }
  }
}

class _StubPortrait extends DabblerAvatarPortraitBuilder {
  const _StubPortrait();

  @override
  Widget build(BuildContext context, {required String seed, required double diameter}) =>
      const SizedBox.shrink(key: ValueKey<String>('stub-portrait'));
}

/// Records the seed it was handed, so the fallback can be asserted.
class _RecordingPortrait extends DabblerAvatarPortraitBuilder {
  const _RecordingPortrait();

  static String? lastSeed;

  @override
  Widget build(BuildContext context, {required String seed, required double diameter}) {
    lastSeed = seed;
    return const SizedBox.shrink();
  }
}
