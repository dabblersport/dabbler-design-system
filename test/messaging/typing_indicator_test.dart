// Pins TypingIndicator.jsx + messaging.jsx (live project 4286affa-...,
// mirror 2026-10-02): phrases for 1/2/3+ names and 'typing'; dots 4px pill
// currentColor (--muted), gap --space-1=3; text gap --space-2=6;
// `dbl-typing 1200ms ease-in-out infinite`, delay i*180ms, keyframes
// 0%,70%,100% opacity .25 / 35% opacity 1; reduced motion: animation none
// (dots visible); text form aria-live=polite; dots aria-hidden.
import 'package:dabbler_design_system/src/messaging/messaging_atoms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import 'atoms_host.dart';

void main() {
  Finder dots() => find.descendant(
    of: find.byType(DabblerTypingIndicator),
    matching: find.byType(Opacity),
  );

  group('phrasing', () {
    test('1 / 2 / 3+ / none / label override', () {
      expect(
        DabblerTypingIndicator.textFor(<String>['Mina']),
        'Mina is typing',
      );
      expect(
        DabblerTypingIndicator.textFor(<String>['Mina', 'Omar']),
        'Mina and Omar are typing',
      );
      expect(
        DabblerTypingIndicator.textFor(<String>['Mina', 'Omar', 'Sara', 'Ali']),
        'Mina and 3 others are typing',
      );
      expect(DabblerTypingIndicator.textFor(const <String>[]), 'typing');
      expect(
        DabblerTypingIndicator.textFor(<String>['Mina'], label: 'مينا تكتب'),
        'مينا تكتب',
      );
    });
  });

  group('keyframes', () {
    test('peaks at 35%, floors at 0 and 70-100%, eased per segment', () {
      expect(DabblerTypingIndicator.opacityAt(0, 0), closeTo(0.25, 1e-9));
      expect(DabblerTypingIndicator.opacityAt(0.35, 0), closeTo(1, 1e-9));
      expect(DabblerTypingIndicator.opacityAt(0.8, 0), 0.25);
      // ease-in-out midpoint is 0.5 -> 0.625.
      expect(DabblerTypingIndicator.opacityAt(0.175, 0), closeTo(0.625, 1e-3));
      // ease-in-out is slow at the start: 10% into the segment < linear.
      expect(
        DabblerTypingIndicator.opacityAt(0.035, 0),
        lessThan(0.25 + 0.075),
      );
    });
    test('dot i lags by i*180ms', () {
      const double lag = 180 / 1200;
      expect(DabblerTypingIndicator.opacityAt(0.35 + lag, 1), closeTo(1, 1e-5));
      expect(
        DabblerTypingIndicator.opacityAt(0.35 + 2 * lag, 2),
        closeTo(1, 1e-5),
      );
    });
  });

  testWidgets('three 4px dots, 3 apart, secondary ink; text 6 after', (
    t,
  ) async {
    await t.pumpWidget(
      atomHost(const DabblerTypingIndicator(names: <String>['Mina'])),
    );
    final List<Rect> r = dots()
        .evaluate()
        .map((e) => t.getRect(find.byWidget(e.widget)))
        .toList();
    expect(r, hasLength(3));
    for (final Rect d in r) {
      expect(d.size, const Size(4, 4));
    }
    expect(r[1].left - r[0].right, 3);
    expect(r[2].left - r[1].right, 3);
    expect(t.getRect(find.text('Mina is typing')).left - r[2].right, 6);
    final DecoratedBox box = t.widget<DecoratedBox>(
      find.descendant(of: dots().first, matching: find.byType(DecoratedBox)),
    );
    expect((box.decoration as BoxDecoration).color, atomColors().textSecondary);
    final Text text = t.widget<Text>(find.text('Mina is typing'));
    expect(text.style!.fontSize, 12);
    expect(text.style!.color, atomColors().textSecondary);
  });

  testWidgets('animates: opacity changes over time', (t) async {
    await t.pumpWidget(atomHost(const DabblerTypingIndicator(dotsOnly: true)));
    final double a = t.widget<Opacity>(dots().first).opacity;
    await t.pump(const Duration(milliseconds: 420));
    final double b = t.widget<Opacity>(dots().first).opacity;
    expect(a, isNot(closeTo(b, 0.05)));
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('reduced motion: dots stay visible at full opacity, no ticker', (
    t,
  ) async {
    await t.pumpWidget(
      atomHost(
        const DabblerTypingIndicator(names: <String>['Mina']),
        reduceMotion: true,
      ),
    );
    for (final Element e in dots().evaluate()) {
      expect((e.widget as Opacity).opacity, 1);
    }
    await t.pump(const Duration(milliseconds: 420));
    for (final Element e in dots().evaluate()) {
      expect((e.widget as Opacity).opacity, 1);
    }
  });

  testWidgets('RTL: dots at the inline start (right), Arabic caption-1', (
    t,
  ) async {
    await t.pumpWidget(
      atomHost(
        const DabblerTypingIndicator(label: 'مينا تكتب'),
        direction: TextDirection.rtl,
      ),
    );
    final Rect text = t.getRect(find.text('مينا تكتب'));
    final Rect last = t.getRect(dots().last);
    expect(text.right, lessThan(last.left));
    expect(last.left - text.right, 6);
    expect(
      t.widget<Text>(find.text('مينا تكتب')).style!.fontSize,
      closeTo(11.1, 0.001),
    );
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('text form is a polite live region; dots-only is silent', (
    t,
  ) async {
    final SemanticsHandle h = t.ensureSemantics();
    await t.pumpWidget(
      atomHost(const DabblerTypingIndicator(names: <String>['Mina', 'Omar'])),
    );
    expect(
      t.getSemantics(find.bySemanticsLabel('Mina and Omar are typing')),
      matchesSemantics(label: 'Mina and Omar are typing', isLiveRegion: true),
    );
    await t.pumpWidget(atomHost(const DabblerTypingIndicator(dotsOnly: true)));
    expect(find.bySemanticsLabel(RegExp('typing')), findsNothing);
    expect(find.byType(Text), findsNothing);
    await t.pumpWidget(const SizedBox());
    h.dispose();
  });

  testWidgets('renders LTR and RTL PNGs (still frame)', (t) async {
    for (final TextDirection d in TextDirection.values) {
      final bool rtl = d == TextDirection.rtl;
      final f = await renderPng(
        t,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DabblerTypingIndicator(
                names: const <String>['Mina'],
                label: rtl ? 'مينا تكتب' : null,
              ),
              DabblerTypingIndicator(
                names: const <String>['Mina', 'Omar', 'Sara'],
                label: rtl ? 'مينا و2 آخرون يكتبون' : null,
              ),
              const DabblerTypingIndicator(dotsOnly: true),
            ],
          ),
        ),
        name: 'typing_indicator_${d.name}',
        size: const Size(300, 70),
        direction: d,
        alignment: Alignment.center,
      );
      expect(f.lengthSync(), greaterThan(0));
    }
  });
}
