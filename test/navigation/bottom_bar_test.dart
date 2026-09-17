import 'package:dabbler_design_system/src/controls/fab.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/navigation/bottom_bar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-240 AC1's floor, stated as the ticket states it — **not** as the token
/// states it. The widget uses `--touch-target-min` (45); this is the number the
/// acceptance criterion names, so a future token change that dropped below 44
/// would fail here rather than pass by definition.
const double kTargetFloor = 44;

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
  bool disableAnimations = true,
}) {
  return MediaQuery(
    data: MediaQueryData(
      padding: padding,
      disableAnimations: disableAnimations,
    ),
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
          alignment: Alignment.bottomCenter,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

/// Every hit box the bar exposes: each destination's and the action's.
List<Element> _hitBoxes(WidgetTester tester) => tester
    .elementList(find.descendant(
      of: find.byType(DabblerNavigationBottomBar),
      matching: find.byWidgetPredicate(
        (Widget w) =>
            w is GestureDetector && w.behavior == HitTestBehavior.opaque,
      ),
    ))
    .toList();

void main() {
  group('defaults transcribed from the source', () {
    testWidgets('the four destinations are Home / Explore / Games / You',
        (WidgetTester tester) async {
      expect(
        DabblerNavigationBottomBar.defaultItems
            .map((DabblerNavigationItem i) => i.id),
        <String>['home', 'explore', 'games', 'you'],
      );
      expect(
        DabblerNavigationBottomBar.defaultItems
            .map((DabblerNavigationItem i) => i.icon),
        <String>['home-2', 'search-normal', 'game', 'user'],
      );
      expect(
        DabblerNavigationBottomBar.defaultCreateItems
            .map((DabblerNavigationCreateItem i) => i.id),
        <String>['post', 'game', 'meetup'],
      );
    });

    testWidgets('only the active destination shows a label',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerNavigationBottomBar()));

      // `defaultActive ?? items[0].id` — Home.
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Explore'), findsNothing);
      expect(find.text('Games'), findsNothing);
      expect(find.text('You'), findsNothing);
    });

    testWidgets('a controlled `active` moves the chip',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationBottomBar(active: 'games')),
      );
      expect(find.text('Games'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });
  });

  group('AC1 — icon weight is the active signal', () {
    testWidgets('active renders bold, every other destination linear',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationBottomBar(active: 'explore')),
      );

      final List<DabblerIcon> icons = tester
          .widgetList<DabblerIcon>(find.descendant(
            of: find.byType(DabblerNavigationBottomBar),
            matching: find.byType(DabblerIcon),
          ))
          .toList();

      final DabblerIcon explore =
          icons.firstWhere((DabblerIcon i) => i.name == 'search-normal');
      expect(explore.weight, DabblerIconWeight.bold);

      for (final String name in <String>['home-2', 'game', 'user']) {
        expect(
          icons.firstWhere((DabblerIcon i) => i.name == name).weight,
          DabblerIconWeight.linear,
          reason: '$name is inactive and must stay linear',
        );
      }
    });

    testWidgets('the active glyph takes the brand, the inactive --neutral-400',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationBottomBar(active: 'home')),
      );
      final DabblerColors colors = _colors();

      final List<DabblerIcon> icons = tester
          .widgetList<DabblerIcon>(find.byType(DabblerIcon))
          .toList();

      expect(
        icons.firstWhere((DabblerIcon i) => i.name == 'home-2').color,
        colors.brandPrimary,
      );
      // `--neutral-400` is `--outline-card` — tokens/colors.css:36.
      expect(
        icons.firstWhere((DabblerIcon i) => i.name == 'user').color,
        colors.borderDefault,
      );
    });

    testWidgets('every navigation glyph is --icon-md (24)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerNavigationBottomBar()));
      for (final DabblerIcon icon
          in tester.widgetList<DabblerIcon>(find.byType(DabblerIcon))) {
        expect(icon.size, DabblerSizing.iconMd);
      }
    });
  });

  group('AC1 — touch targets, measured', () {
    testWidgets('every destination and the action clear 44x44',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      for (final String? active in <String?>[
        'home',
        'explore',
        'games',
        'you'
      ]) {
        await tester.pumpWidget(
          _host(DabblerNavigationBottomBar(active: active)),
        );
        final List<Element> boxes = _hitBoxes(tester);
        // four destinations + the action
        expect(boxes.length, 5);
        for (final Element box in boxes) {
          final Size size = tester.getSize(find.byElementPredicate(
            (Element e) => identical(e, box),
          ));
          expect(size.width, greaterThanOrEqualTo(kTargetFloor),
              reason: 'width with active=$active');
          expect(size.height, greaterThanOrEqualTo(kTargetFloor),
              reason: 'height with active=$active');
        }
      }
    });

    testWidgets('the create tiles clear 44x44 too',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationBottomBar(defaultMenuOpen: true)),
      );
      await tester.pumpAndSettle();

      // three tiles + the action
      final List<Element> boxes = _hitBoxes(tester);
      expect(boxes.length, 4);
      for (final Element box in boxes) {
        final Size size = tester.getSize(
          find.byElementPredicate((Element e) => identical(e, box)),
        );
        expect(size.width, greaterThanOrEqualTo(kTargetFloor));
        expect(size.height, greaterThanOrEqualTo(kTargetFloor));
      }
    });

    testWidgets('the action is the FAB diameter', (WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_host(const DabblerNavigationBottomBar()));
      final Size action = tester.getSize(find.byType(DabblerIcon).last);
      // The glyph is icon-md inside a 56 plate; assert the plate.
      expect(action.width, DabblerSizing.iconMd);
      final Size plate = tester.getSize(find.ancestor(
        of: find.byType(AnimatedRotation),
        matching: find.byType(Container),
      ));
      expect(plate, const Size(DabblerFab.size, DabblerFab.size));
    });
  });

  group('AC1 — DS-200 focus and press', () {
    testWidgets('every target carries the shared focus ring',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerNavigationBottomBar()));
      // four destinations + the action
      expect(find.byType(DabblerFocusRing), findsNWidgets(5));
    });

    testWidgets('no destination draws a ring of its own',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerNavigationBottomBar()));
      for (final DabblerFocusRing ring
          in tester.widgetList<DabblerFocusRing>(
              find.byType(DabblerFocusRing))) {
        expect(ring.width, DabblerFocusRing.ringWidth);
        expect(ring.offset, DabblerFocusRing.ringOffset);
      }
    });
  });

  group('selection', () {
    testWidgets('tapping a destination reports and moves the chip',
        (WidgetTester tester) async {
      final List<String> selected = <String>[];
      await tester.pumpWidget(
        _host(DabblerNavigationBottomBar(onSelect: selected.add)),
      );

      await tester.tap(find.byWidgetPredicate(
        (Widget w) => w is DabblerIcon && w.name == 'game',
      ));
      await tester.pumpAndSettle();

      expect(selected, <String>['games']);
      // Uncontrolled: it moved itself.
      expect(find.text('Games'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('a controlled bar reports but does not move itself',
        (WidgetTester tester) async {
      final List<String> selected = <String>[];
      await tester.pumpWidget(
        _host(DabblerNavigationBottomBar(
          active: 'home',
          onSelect: selected.add,
        )),
      );

      await tester.tap(find.byWidgetPredicate(
        (Widget w) => w is DabblerIcon && w.name == 'user',
      ));
      await tester.pumpAndSettle();

      expect(selected, <String>['you']);
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('the create menu', () {
    testWidgets('the action opens it, replacing the pill in flow',
        (WidgetTester tester) async {
      final List<bool> reported = <bool>[];
      await tester.pumpWidget(
        _host(DabblerNavigationBottomBar(onAction: reported.add)),
      );

      expect(find.text('Create post'), findsNothing);
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.byWidgetPredicate(
        (Widget w) => w is DabblerIcon && w.name == 'add',
      ));
      await tester.pumpAndSettle();

      expect(reported, <bool>[true]);
      expect(find.text('Create post'), findsOneWidget);
      expect(find.text('Create game'), findsOneWidget);
      expect(find.text('Create meetup'), findsOneWidget);
      // The pill is gone — it is replaced, not covered.
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('the action rotates 45 degrees while open',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerNavigationBottomBar()));
      expect(
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
        0,
      );

      // A distinct key, so the bar is rebuilt rather than reusing the State
      // whose `defaultMenuOpen` was already read in `initState`.
      await tester.pumpWidget(
        _host(const DabblerNavigationBottomBar(
          key: ValueKey<String>('open'),
          defaultMenuOpen: true,
        )),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
        DabblerNavigationBottomBar.actionOpenTurns,
      );
    });

    testWidgets('tapping a tile reports its id and closes the menu',
        (WidgetTester tester) async {
      final List<String> created = <String>[];
      await tester.pumpWidget(
        _host(DabblerNavigationBottomBar(
          defaultMenuOpen: true,
          onCreate: created.add,
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create game'));
      await tester.pumpAndSettle();

      expect(created, <String>['game']);
      expect(find.text('Create game'), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('a controlled menu does not close itself',
        (WidgetTester tester) async {
      final List<String> created = <String>[];
      await tester.pumpWidget(
        _host(DabblerNavigationBottomBar(
          menuOpen: true,
          onCreate: created.add,
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create post'));
      await tester.pumpAndSettle();

      expect(created, <String>['post']);
      expect(find.text('Create post'), findsOneWidget);
    });

    testWidgets('the row bottom-aligns while open', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationBottomBar(defaultMenuOpen: true)),
      );
      await tester.pumpAndSettle();
      final Row row = tester.widget<Row>(find.descendant(
        of: find.byType(DabblerNavigationBottomBar),
        matching: find.byType(Row),
      ).first);
      expect(row.crossAxisAlignment, CrossAxisAlignment.end);
    });
  });

  group('keyboard — roving focus, as in DabblerTabs', () {
    Future<void> pressArrow(WidgetTester tester, LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    testWidgets('arrow keys move and select, wrapping at both ends',
        (WidgetTester tester) async {
      final List<String> selected = <String>[];
      await tester.pumpWidget(
        _host(DabblerNavigationBottomBar(onSelect: selected.add)),
      );

      // Put keyboard focus on the active destination. A bare host has no
      // WidgetsApp and therefore no traversal root for a Tab press to enter,
      // so the tap — which requests focus on the node it selects — is what
      // gets us onto the roving strip.
      await tester.tap(find.byWidgetPredicate(
        (Widget w) => w is DabblerIcon && w.name == 'home-2',
      ));
      await tester.pumpAndSettle();
      selected.clear();

      await pressArrow(tester, LogicalKeyboardKey.arrowRight);
      await pressArrow(tester, LogicalKeyboardKey.arrowRight);
      await pressArrow(tester, LogicalKeyboardKey.arrowRight);
      // …and one more wraps back to the first.
      await pressArrow(tester, LogicalKeyboardKey.arrowRight);

      expect(selected, <String>['explore', 'games', 'you', 'home']);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Home and End jump to the ends', (WidgetTester tester) async {
      final List<String> selected = <String>[];
      await tester.pumpWidget(
        _host(DabblerNavigationBottomBar(onSelect: selected.add)),
      );
      await tester.tap(find.byWidgetPredicate(
        (Widget w) => w is DabblerIcon && w.name == 'home-2',
      ));
      await tester.pumpAndSettle();
      selected.clear();

      await pressArrow(tester, LogicalKeyboardKey.end);
      await pressArrow(tester, LogicalKeyboardKey.home);

      expect(selected, <String>['you', 'home']);
    });

    testWidgets('under RTL the arrow keys swap', (WidgetTester tester) async {
      final List<String> selected = <String>[];
      await tester.pumpWidget(
        _host(
          DabblerNavigationBottomBar(onSelect: selected.add),
          direction: TextDirection.rtl,
        ),
      );
      await tester.tap(find.byWidgetPredicate(
        (Widget w) => w is DabblerIcon && w.name == 'home-2',
      ));
      await tester.pumpAndSettle();
      selected.clear();

      // ArrowLeft advances in RTL — the source's own rule.
      await pressArrow(tester, LogicalKeyboardKey.arrowLeft);
      expect(selected, <String>['explore']);
    });
  });

  group('RTL', () {
    testWidgets('the pill leads and the action trails, both directions',
        (WidgetTester tester) async {
      Future<({double pill, double action})> edges(
          TextDirection direction) async {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          _host(const DabblerNavigationBottomBar(), direction: direction),
        );
        final Rect pill = tester.getRect(find.byWidgetPredicate(
          (Widget w) => w is DabblerIcon && w.name == 'home-2',
        ));
        final Rect action = tester.getRect(find.byWidgetPredicate(
          (Widget w) => w is DabblerIcon && w.name == 'add',
        ));
        return (pill: pill.center.dx, action: action.center.dx);
      }

      final ({double action, double pill}) ltr = await edges(TextDirection.ltr);
      expect(ltr.pill, lessThan(ltr.action),
          reason: 'LTR: pill left, action right');

      final ({double action, double pill}) rtl = await edges(TextDirection.rtl);
      expect(rtl.pill, greaterThan(rtl.action),
          reason: 'RTL: pill right, action left');
    });

    testWidgets('the active item flips icon and label order',
        (WidgetTester tester) async {
      Future<bool> iconLeadsLabel(TextDirection direction) async {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          _host(
            const DabblerNavigationBottomBar(active: 'home'),
            direction: direction,
          ),
        );
        final double icon = tester
            .getRect(find.byWidgetPredicate(
              (Widget w) => w is DabblerIcon && w.name == 'home-2',
            ))
            .center
            .dx;
        final double label = tester.getRect(find.text('Home')).center.dx;
        return icon < label;
      }

      expect(await iconLeadsLabel(TextDirection.ltr), isTrue);
      expect(await iconLeadsLabel(TextDirection.rtl), isFalse);
    });
  });

  group('safe area', () {
    testWidgets('pads the bottom inset', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerNavigationBottomBar(),
          padding: const EdgeInsets.only(bottom: 34),
        ),
      );
      final Padding pad = tester.widget<Padding>(find.descendant(
        of: find.byType(DabblerNavigationBottomBar),
        matching: find.byType(Padding),
      ).first);
      expect(pad.padding, const EdgeInsets.only(bottom: 34));
    });

    testWidgets('does not double-apply under an ancestor SafeArea',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const SafeArea(child: DabblerNavigationBottomBar()),
          padding: const EdgeInsets.only(bottom: 34),
        ),
      );
      final Padding pad = tester.widget<Padding>(find.descendant(
        of: find.byType(DabblerNavigationBottomBar),
        matching: find.byType(Padding),
      ).first);
      // The SafeArea consumed it; the bar reads zero and adds nothing.
      expect(pad.padding, EdgeInsets.zero);
    });

    testWidgets('safeArea: false adds no padding at all',
        (WidgetTester tester) async {
      Future<double> heightWith({required bool safeArea}) async {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          _host(
            DabblerNavigationBottomBar(safeArea: safeArea),
            padding: const EdgeInsets.only(bottom: 34),
          ),
        );
        return tester.getSize(find.byType(DabblerNavigationBottomBar)).height;
      }

      final double off = await heightWith(safeArea: false);
      final double on = await heightWith(safeArea: true);
      expect(on - off, 34);
    });
  });

  group('flat, themed, and no hardcoded colour', () {
    testWidgets('nothing in the bar paints a shadow',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationBottomBar(defaultMenuOpen: true)),
      );
      await tester.pumpAndSettle();
      for (final Container box in tester.widgetList<Container>(find.descendant(
        of: find.byType(DabblerNavigationBottomBar),
        matching: find.byType(Container),
      ))) {
        final Decoration? decoration = box.decoration;
        if (decoration is BoxDecoration) {
          expect(decoration.boxShadow ?? const <BoxShadow>[], isEmpty);
          expect(decoration.gradient, isNull);
        }
      }
    });

    testWidgets('the pill re-tints with the section theme',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in <DabblerTheme>[
        DabblerTheme.main,
        DabblerTheme.sport,
      ]) {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          _host(const DabblerNavigationBottomBar(), theme: theme),
        );
        final DabblerIcon active = tester.widget<DabblerIcon>(
          find.byWidgetPredicate(
            (Widget w) => w is DabblerIcon && w.name == 'home-2',
          ),
        );
        expect(active.color, _colors(theme: theme).brandPrimary);
      }
    });
  });

  group('edge cases', () {
    testWidgets('an empty items list still renders the action',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationBottomBar(
          items: <DabblerNavigationItem>[],
        )),
      );
      expect(
        find.byWidgetPredicate((Widget w) => w is DabblerIcon && w.name == 'add'),
        findsOneWidget,
      );
    });

    testWidgets('an active id matching nothing expands no chip',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationBottomBar(active: 'nowhere')),
      );
      for (final String label in <String>['Home', 'Explore', 'Games', 'You']) {
        expect(find.text(label), findsNothing);
      }
    });

    testWidgets('more than four create tiles wrap into a second row',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationBottomBar(
          defaultMenuOpen: true,
          createItems: <DabblerNavigationCreateItem>[
            DabblerNavigationCreateItem(id: 'a', icon: 'game', label: 'A'),
            DabblerNavigationCreateItem(id: 'b', icon: 'game', label: 'B'),
            DabblerNavigationCreateItem(id: 'c', icon: 'game', label: 'C'),
            DabblerNavigationCreateItem(id: 'd', icon: 'game', label: 'D'),
            DabblerNavigationCreateItem(id: 'e', icon: 'game', label: 'E'),
          ],
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('E'), findsOneWidget);
      expect(
        tester.getRect(find.text('E')).top,
        greaterThan(tester.getRect(find.text('A')).top),
      );
      // The wrapped tile keeps a full column's width, not the whole row.
      expect(
        tester.getSize(find.text('E')).width,
        lessThan(tester.getSize(find.byType(DabblerNavigationBottomBar)).width /
            2),
      );
    });

    testWidgets('value equality on the item models', (WidgetTester tester) async {
      const DabblerNavigationItem a =
          DabblerNavigationItem(id: 'x', icon: 'game', label: 'X');
      const DabblerNavigationItem b =
          DabblerNavigationItem(id: 'x', icon: 'game', label: 'X');
      expect(a, b);
      expect(a.hashCode, b.hashCode);

      const DabblerNavigationCreateItem c =
          DabblerNavigationCreateItem(id: 'y', icon: 'game', label: 'Y');
      const DabblerNavigationCreateItem d =
          DabblerNavigationCreateItem(id: 'y', icon: 'game', label: 'Y');
      expect(c, d);
      expect(c.hashCode, d.hashCode);
    });
  });
}
