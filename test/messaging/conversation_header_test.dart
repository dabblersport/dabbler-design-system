// Geometry pins cite live components/messaging/ConversationHeader.jsx
// (live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1, read via
// DesignSync get_file on 2026-10-02, local mirror).
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/messaging/conversation_header.dart';
import 'package:dabbler_design_system/src/messaging/messaging_atoms.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';

DabblerColors _colors() => DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 360,
}) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors()]),
  home: Directionality(
    textDirection: direction,
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: child),
      ),
    ),
  ),
);

void _noop() {}

const DabblerConversationHeader _basic = DabblerConversationHeader(
  title: 'Layla Haddad',
  subtitle: 'Last seen 2h ago',
  onBack: _noop,
  onTitlePress: _noop,
  onOverflow: _noop,
);

Rect _iconRect(WidgetTester t, String name) => t.getRect(
  find
      .ancestor(
        of: find.byWidgetPredicate(
          (Widget w) => w is DabblerIcon && w.name == name,
        ),
        matching: find.byType(SizedBox),
      )
      .first,
);

Text _text(WidgetTester t, String s) => t.widget<Text>(find.text(s));

void main() {
  group('geometry — ConversationHeader.jsx', () {
    for (final TextDirection dir in TextDirection.values) {
      testWidgets(
        'row 52, inline 6, targets 45, gap 3, avatar 36 (${dir.name})',
        (tester) async {
          await tester.pumpWidget(_host(_basic, direction: dir));
          final Rect bar = tester.getRect(
            find.byType(DabblerConversationHeader),
          );
          expect(bar.height, 52); // height: 52
          final Rect back = _iconRect(tester, 'arrow-circle-left');
          final Rect more = _iconRect(tester, 'more');
          expect(back.size, const Size(45, 45)); // --touch-target-min
          expect(more.size, const Size(45, 45));
          // Content box is 51 tall (border-box, 1px hairline) — targets centred.
          expect(back.top, closeTo((51 - 45) / 2, 0.01));
          final Rect avatar = tester.getRect(
            find.byType(DabblerConversationAvatar),
          );
          expect(avatar.size, const Size(36, 36)); // size={36}
          if (dir == TextDirection.ltr) {
            expect(back.left, 6); // paddingInline: --space-2
            expect(bar.right - more.right, 6);
            expect(
              avatar.left - back.right,
              3 + 3,
            ); // gap --space-1 + inline --space-1
          } else {
            expect(bar.right - back.right, 6);
            expect(more.left, 6);
            expect(back.left - avatar.right, 3 + 3);
          }
        },
      );
    }

    testWidgets('bottom hairline is 1px --faint on --surface-page', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_basic));
      final Container c = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(DabblerConversationHeader),
              matching: find.byType(Container),
            )
            .first,
      );
      final BoxDecoration d = c.decoration! as BoxDecoration;
      expect(d.color, _colors().bgPrimary);
      final Border b = d.border! as Border;
      expect(b.bottom.width, 1);
      expect(b.bottom.color, _colors().bgTertiary);
      expect(b.top, BorderSide.none);
    });

    testWidgets('title subheadline 600 ink, subtitle caption-2 muted', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_basic));
      final TextStyle title = _text(tester, 'Layla Haddad').style!;
      expect(title.fontWeight, FontWeight.w600);
      expect(title.fontSize, 15);
      expect(title.color, _colors().textPrimary);
      final TextStyle sub = _text(tester, 'Last seen 2h ago').style!;
      expect(sub.fontSize, 11);
      expect(sub.color, _colors().textSecondary);
    });

    testWidgets('Arabic metrics: Latin minus 0.9px', (tester) async {
      await tester.pumpWidget(_host(_basic, direction: TextDirection.rtl));
      expect(
        _text(tester, 'Layla Haddad').style!.fontSize,
        closeTo(14.1, 1e-9),
      );
      expect(
        _text(tester, 'Last seen 2h ago').style!.fontSize,
        closeTo(10.1, 1e-9),
      );
    });
  });

  group('states', () {
    for (final (DabblerConversationSubtitleTone tone, Color expected)
        in <(DabblerConversationSubtitleTone, Color)>[
          (DabblerConversationSubtitleTone.success, _colors().success.strong),
          (DabblerConversationSubtitleTone.error, _colors().error.strong),
          (DabblerConversationSubtitleTone.muted, _colors().textSecondary),
        ]) {
      testWidgets('subtitleTone ${tone.name}', (tester) async {
        await tester.pumpWidget(
          _host(
            DabblerConversationHeader(
              title: 'A',
              subtitle: 'S',
              subtitleTone: tone,
            ),
          ),
        );
        expect(_text(tester, 'S').style!.color, expected);
      });
    }

    testWidgets('typing replaces the subtitle', (tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerConversationHeader(
            title: 'Huddle',
            subtitle: '8 members',
            typing: <String>['Omar'],
          ),
        ),
      );
      expect(find.byType(DabblerTypingIndicator), findsOneWidget);
      expect(find.text('8 members'), findsNothing);
      expect(find.text('Omar is typing'), findsOneWidget);
    });

    testWidgets('seed falls back to title; avatar carries kind and online', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerConversationHeader(title: 'Layla', online: true)),
      );
      final DabblerConversationAvatar a = tester.widget(
        find.byType(DabblerConversationAvatar),
      );
      expect(a.seed, 'Layla');
      expect(a.online, isTrue);
      expect(a.size, 36);
    });

    testWidgets('long title and subtitle ellipsize on one line, no overflow', (
      tester,
    ) async {
      const String long =
          'Sunday morning football league, west side pitches, all levels';
      await tester.pumpWidget(
        _host(
          const DabblerConversationHeader(title: long, subtitle: long),
          width: 320,
        ),
      );
      expect(tester.takeException(), isNull);
      for (final Text t in tester.widgetList<Text>(find.text(long))) {
        expect(t.maxLines, 1);
        expect(t.overflow, TextOverflow.ellipsis);
      }
      expect(tester.getRect(find.byType(DabblerConversationHeader)).height, 52);
    });

    testWidgets('callbacks fire from each target', (tester) async {
      final List<String> log = <String>[];
      await tester.pumpWidget(
        _host(
          DabblerConversationHeader(
            title: 'Layla',
            onBack: () => log.add('back'),
            onTitlePress: () => log.add('title'),
            onOverflow: () => log.add('more'),
          ),
        ),
      );
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is DabblerIcon && w.name == 'arrow-circle-left',
        ),
      );
      await tester.tap(find.text('Layla'));
      await tester.tap(
        find.byWidgetPredicate((w) => w is DabblerIcon && w.name == 'more'),
      );
      expect(log, <String>['back', 'title', 'more']);
    });
  });

  group('direction', () {
    testWidgets('RTL mirrors order; back glyph is not mirrored (as live)', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_basic, direction: TextDirection.rtl));
      final Rect back = _iconRect(tester, 'arrow-circle-left');
      final Rect more = _iconRect(tester, 'more');
      expect(back.left, greaterThan(more.left));
      // Same glyph name in RTL, and no Transform with a negative x scale
      // (the press scale is a positive uniform scale).
      final Iterable<Transform> ts = tester.widgetList<Transform>(
        find.ancestor(
          of: find.byWidgetPredicate(
            (Widget w) => w is DabblerIcon && w.name == 'arrow-circle-left',
          ),
          matching: find.byType(Transform),
        ),
      );
      for (final Transform t in ts) {
        expect(t.transform.entry(0, 0), greaterThan(0));
      }
      // Text starts at the inline start (right edge of the text column).
      expect(_text(tester, 'Layla Haddad').textAlign, TextAlign.start);
    });
  });

  group('semantics', () {
    testWidgets('three labelled buttons', (tester) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const DabblerConversationHeader(
            title: 'Layla',
            subtitle: 'Online',
            backLabel: 'رجوع',
            overflowLabel: 'Options',
            onBack: _noop,
            onTitlePress: _noop,
            onOverflow: _noop,
          ),
        ),
      );
      for (final String label in <String>['رجوع', 'Layla, Online', 'Options']) {
        final SemanticsNode n = tester.getSemantics(
          find.bySemanticsLabel(label),
        );
        expect(n.flagsCollection.isButton, isTrue, reason: label);
      }
      h.dispose();
    });

    testWidgets('default labels are Back and More; typing names identity', (
      tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const DabblerConversationHeader(
            title: 'Huddle',
            typing: <String>['Omar', 'Sara'],
            onBack: _noop,
            onTitlePress: _noop,
            onOverflow: _noop,
          ),
        ),
      );
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      expect(find.bySemanticsLabel('More'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Huddle, Omar and Sara are typing'),
        findsOneWidget,
      );
      h.dispose();
    });
  });

  group('png', () {
    testWidgets('renders a non-empty PNG in LTR and RTL', (tester) async {
      for (final TextDirection d in TextDirection.values) {
        final f = await renderPng(
          tester,
          const SizedBox(width: 390, child: _basic),
          name: 'conversation_header_test_${d.name}',
          size: const Size(390, 60),
          direction: d,
          alignment: Alignment.topCenter,
        );
        expect(f.lengthSync(), greaterThan(1000));
      }
    });
  });
}
