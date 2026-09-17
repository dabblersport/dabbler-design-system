import 'dart:ui' as ui;

import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/navigation/top_bar.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-241 AC1's floor, stated as the ticket states it rather than as the
/// token states it. See the twin note in `bottom_bar_test.dart`.
const double kTargetFloor = 44;

/// The export's documented trailing pair —
/// `navigation-system.card.html` → *Anatomy*.
const List<DabblerNavigationAction> _actions = <DabblerNavigationAction>[
  DabblerNavigationAction(icon: 'sms', label: 'Messages'),
  DabblerNavigationAction(icon: 'notification-bing', label: 'Notifications'),
];

DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  double width = 390,
  EdgeInsets padding = EdgeInsets.zero,
}) {
  return MediaQuery(
    data: MediaQueryData(padding: padding, disableAnimations: true),
    child: Directionality(
      textDirection: direction,
      child: Theme(
        data: ThemeData(
          brightness: brightness,
          extensions: <ThemeExtension<dynamic>>[
            _colors(theme: theme, brightness: brightness),
          ],
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

List<Element> _hitBoxes(WidgetTester tester) => tester
    .elementList(find.descendant(
      of: find.byType(DabblerNavigationTopBar),
      matching: find.byWidgetPredicate(
        (Widget w) =>
            w is GestureDetector && w.behavior == HitTestBehavior.opaque,
      ),
    ))
    .toList();

void main() {
  group('anatomy transcribed from the export', () {
    testWidgets('the wordmark leads and the avatar trails',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationTopBar(actions: _actions)),
      );

      expect(find.byType(DabblerWordmark), findsOneWidget);
      expect(find.byType(DabblerAvatar), findsOneWidget);
      expect(
        tester.getRect(find.byType(DabblerWordmark)).center.dx,
        lessThan(tester.getRect(find.byType(DabblerAvatar)).center.dx),
      );
    });

    testWidgets('the wordmark is the export box, 100 x 19',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerNavigationTopBar()));
      expect(
        tester.getSize(find.byType(DabblerWordmark)),
        DabblerNavigationTopBar.wordmarkSize,
      );
    });

    testWidgets('the wordmark path fills its own 100 x 19 box',
        (WidgetTester tester) async {
      final ui.Path path = DabblerWordmark.buildPath();
      final Rect bounds = path.getBounds();
      // The export's leftmost glyph starts at x 0 and its tallest at y 0;
      // the last glyph ends at 88.745 + 11.255 = 100.
      expect(bounds.left, closeTo(0, 0.001));
      expect(bounds.right, closeTo(100, 0.001));
      expect(bounds.top, closeTo(0.186, 0.001));
      expect(bounds.bottom, closeTo(18.814, 0.001));
      expect(path.fillType, PathFillType.evenOdd);
    });

    testWidgets('the wordmark takes the section brand',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in <DabblerTheme>[
        DabblerTheme.main,
        DabblerTheme.social,
      ]) {
        await tester.pumpWidget(const SizedBox());
        await tester
            .pumpWidget(_host(const DabblerNavigationTopBar(), theme: theme));
        expect(
          tester.widget<DabblerWordmark>(find.byType(DabblerWordmark)).color,
          _colors(theme: theme).brandPrimary,
        );
      }
    });

    testWidgets('the avatar defaults to the export seed and is 36',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerNavigationTopBar()));
      final DabblerAvatar avatar =
          tester.widget<DabblerAvatar>(find.byType(DabblerAvatar));
      expect(avatar.seed, DabblerNavigationTopBar.defaultAvatarSeed);
      expect(avatar.size, DabblerAvatarSize.sm);
      expect(avatar.size.diameter, 36);
    });

    testWidgets('a `leading` slot replaces the wordmark',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerNavigationTopBar(leading: Text('Dabbler')),
      ));
      expect(find.byType(DabblerWordmark), findsNothing);
      expect(find.text('Dabbler'), findsOneWidget);
    });
  });

  group('AC1 — touch targets, measured', () {
    testWidgets('each trailing action is the ruled 34x45 box — D-032',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(DabblerNavigationTopBar(
        actions: <DabblerNavigationAction>[
          DabblerNavigationAction(
              icon: 'sms', label: 'Messages', onPressed: () {}),
          DabblerNavigationAction(
              icon: 'notification-bing',
              label: 'Notifications',
              onPressed: () {}),
        ],
      )));

      final List<Element> boxes = _hitBoxes(tester);
      expect(boxes.length, 2);
      for (final Element box in boxes) {
        final Size size = tester.getSize(
          find.byElementPredicate((Element e) => identical(e, box)),
        );
        // `DECISIONS.md` **D-032**: the target floor never cost this bar its
        // fidelity — assuming the hit box had to be *square* did. A 45x45 box
        // carries 11.5 of inline padding each side, so the specimen's `gap: 12`
        // on top spread the cluster to 57 between glyph centres against the
        // drawn 34. The ruled box is 34 x 45: 34 reproduces the drawn pitch
        // exactly when the boxes are butted, and 45 still clears the floor on
        // the constrained axis.
        //
        // This test previously required >= 44 on BOTH axes, which is what made
        // a square box look mandatory. It now pins the ruled geometry.
        expect(size, DabblerNavigationTopBar.actionTarget);
        expect(size.height, greaterThanOrEqualTo(kTargetFloor));
      }
    });

    testWidgets('a tappable avatar gets a target too, while still painting 36',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(DabblerNavigationTopBar(
        onAvatarPressed: () {},
      )));

      final List<Element> boxes = _hitBoxes(tester);
      expect(boxes.length, 1);
      final Size target = tester.getSize(
        find.byElementPredicate((Element e) => identical(e, boxes.single)),
      );
      expect(target.width, greaterThanOrEqualTo(kTargetFloor));
      expect(target.height, greaterThanOrEqualTo(kTargetFloor));
      expect(
        tester.getSize(find.byType(DabblerAvatar)),
        const Size(36, 36),
      );
    });

    testWidgets('a decorative avatar is no target at all',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerNavigationTopBar()));
      expect(_hitBoxes(tester), isEmpty);
    });

    testWidgets('the bar is at least the export height',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationTopBar(actions: _actions)),
      );
      expect(
        tester.getSize(find.byType(DabblerNavigationTopBar)).height,
        greaterThanOrEqualTo(DabblerNavigationTopBar.barHeight),
      );
    });
  });

  group('AC1 — DS-300 icons and DS-200 focus/press', () {
    testWidgets('every glyph is the drawn 22 and linear by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationTopBar(actions: _actions)),
      );
      final List<DabblerIcon> icons =
          tester.widgetList<DabblerIcon>(find.byType(DabblerIcon)).toList();
      expect(icons.map((DabblerIcon i) => i.name),
          <String>['sms', 'notification-bing']);
      for (final DabblerIcon icon in icons) {
        // `size={22}` (`NavigationTopBar.jsx:165,184`) — OFF the 18/24/30 icon
        // ramp, transcribed literally. This test previously asserted
        // `--icon-md` (24), which is what pinned the glyphs to the ramp and
        // crowded the 12px gap the specimen leaves between them and the avatar.
        expect(icon.size, DabblerNavigationTopBar.actionGlyphSize);
        expect(icon.weight, DabblerIconWeight.linear);
        expect(icon.color, _colors().textPrimary);
      }
    });

    testWidgets('an action can ask for the bold weight',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerNavigationTopBar(
        actions: <DabblerNavigationAction>[
          DabblerNavigationAction(
            icon: 'notification-bing',
            label: 'Notifications',
            weight: DabblerIconWeight.bold,
          ),
        ],
      )));
      expect(
        tester.widget<DabblerIcon>(find.byType(DabblerIcon)).weight,
        DabblerIconWeight.bold,
      );
    });

    testWidgets('every action carries the shared focus ring',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(DabblerNavigationTopBar(
        actions: _actions,
        onAvatarPressed: () {},
      )));
      // two actions + the tappable avatar
      expect(find.byType(DabblerFocusRing), findsNWidgets(3));
      for (final DabblerFocusRing ring
          in tester.widgetList<DabblerFocusRing>(
              find.byType(DabblerFocusRing))) {
        expect(ring.width, DabblerFocusRing.ringWidth);
        expect(ring.offset, DabblerFocusRing.ringOffset);
      }
    });

    testWidgets('tapping an action fires it', (WidgetTester tester) async {
      final List<String> taps = <String>[];
      await tester.pumpWidget(_host(DabblerNavigationTopBar(
        actions: <DabblerNavigationAction>[
          DabblerNavigationAction(
            icon: 'sms',
            label: 'Messages',
            onPressed: () => taps.add('sms'),
          ),
        ],
        onAvatarPressed: () => taps.add('avatar'),
      )));

      await tester.tap(find.byType(DabblerIcon));
      await tester.tap(find.byType(DabblerAvatar));
      await tester.pumpAndSettle();

      expect(taps, <String>['sms', 'avatar']);
    });

    testWidgets('an inert action does not press', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationTopBar(actions: _actions)),
      );
      // `DabblerNavigationAction.onPressed` is null, so the press affordance
      // is disabled rather than silently animating a control that does nothing.
      expect(find.byType(DabblerFocusRing), findsNWidgets(2));
    });
  });

  group('RTL', () {
    testWidgets('the wordmark and the trailing group swap sides',
        (WidgetTester tester) async {
      Future<bool> wordmarkLeadsAvatar(TextDirection direction) async {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(_host(
          const DabblerNavigationTopBar(actions: _actions),
          direction: direction,
        ));
        return tester.getRect(find.byType(DabblerWordmark)).center.dx <
            tester.getRect(find.byType(DabblerAvatar)).center.dx;
      }

      expect(await wordmarkLeadsAvatar(TextDirection.ltr), isTrue);
      expect(await wordmarkLeadsAvatar(TextDirection.rtl), isFalse);
    });

    testWidgets('the actions keep their own order within the trailing group',
        (WidgetTester tester) async {
      Future<bool> smsBeforeBell(TextDirection direction) async {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(_host(
          const DabblerNavigationTopBar(actions: _actions),
          direction: direction,
        ));
        final double sms = tester
            .getRect(find.byWidgetPredicate(
              (Widget w) => w is DabblerIcon && w.name == 'sms',
            ))
            .center
            .dx;
        final double bell = tester
            .getRect(find.byWidgetPredicate(
              (Widget w) => w is DabblerIcon && w.name == 'notification-bing',
            ))
            .center
            .dx;
        return sms < bell;
      }

      // Inline order is preserved; the visual order mirrors, as plain flow does.
      expect(await smsBeforeBell(TextDirection.ltr), isTrue);
      expect(await smsBeforeBell(TextDirection.rtl), isFalse);
    });

    testWidgets('the wordmark is never mirrored', (WidgetTester tester) async {
      // A wordmark is text, not a directional glyph. Its painted geometry is
      // identical in both directions.
      Future<Rect> box(TextDirection direction) async {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          _host(const DabblerNavigationTopBar(), direction: direction),
        );
        return tester.getRect(find.byType(CustomPaint).first);
      }

      final Rect ltr = await box(TextDirection.ltr);
      final Rect rtl = await box(TextDirection.rtl);
      expect(ltr.size, rtl.size);
      expect(
        find.descendant(
          of: find.byType(DabblerWordmark),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );
    });
  });

  group('safe area', () {
    testWidgets('pads the top inset', (WidgetTester tester) async {
      Future<double> heightWith({required bool safeArea}) async {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(_host(
          DabblerNavigationTopBar(safeArea: safeArea, actions: _actions),
          padding: const EdgeInsets.only(top: 59),
        ));
        return tester.getSize(find.byType(DabblerNavigationTopBar)).height;
      }

      expect(
        await heightWith(safeArea: true) - await heightWith(safeArea: false),
        59,
      );
    });

    testWidgets('does not double-apply under an ancestor SafeArea',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const SafeArea(child: DabblerNavigationTopBar(actions: _actions)),
        padding: const EdgeInsets.only(top: 59),
      ));
      final Padding pad = tester.widget<Padding>(find.descendant(
        of: find.byType(DabblerNavigationTopBar),
        matching: find.byType(Padding),
      ).first);
      expect(pad.padding, EdgeInsets.zero);
    });
  });

  group('flat, and no hardcoded colour', () {
    testWidgets('the bar paints no shadow and no gradient',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationTopBar(actions: _actions, border: true)),
      );
      for (final Container box in tester.widgetList<Container>(find.descendant(
        of: find.byType(DabblerNavigationTopBar),
        matching: find.byType(Container),
      ))) {
        final Decoration? decoration = box.decoration;
        if (decoration is BoxDecoration) {
          expect(decoration.boxShadow ?? const <BoxShadow>[], isEmpty);
          expect(decoration.gradient, isNull);
        }
      }
    });

    testWidgets('the row sits on --neutral-100 and takes the export padding',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationTopBar(actions: _actions)),
      );
      final Container bar = tester.widget<Container>(find.descendant(
        of: find.byType(DabblerNavigationTopBar),
        matching: find.byType(Container),
      ).first);
      final BoxDecoration decoration = bar.decoration! as BoxDecoration;
      // `--neutral-100` is `--surface-page` — tokens/colors.css:32.
      expect(decoration.color, _colors().bgPrimary);
      expect(decoration.border, isNull);
      expect(bar.padding, DabblerNavigationTopBar.barPadding);
    });

    testWidgets('`border: true` restores the specimen outline',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationTopBar(border: true)),
      );
      final Container bar = tester.widget<Container>(find.descendant(
        of: find.byType(DabblerNavigationTopBar),
        matching: find.byType(Container),
      ).first);
      final BoxDecoration decoration = bar.decoration! as BoxDecoration;
      expect(decoration.borderRadius, DabblerRadius.lgAll);
      expect(
        (decoration.border! as Border).top.color,
        _colors().borderDefault,
      );
    });
  });

  testWidgets('value equality on the action model',
      (WidgetTester tester) async {
    const DabblerNavigationAction a =
        DabblerNavigationAction(icon: 'sms', label: 'Messages');
    const DabblerNavigationAction b =
        DabblerNavigationAction(icon: 'sms', label: 'Messages');
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
