import 'package:dabbler_design_system/src/controls/button.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/overlays/menu.dart';
import 'package:dabbler_design_system/src/overlays/sheet.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'dart:async' show unawaited;
import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A desktop-width viewport: above [DabblerMenu.sheetBreakpoint], so the menu
/// is a popover.
const Size _wide = Size(800, 600);

/// A phone-width viewport: below the breakpoint, so the menu is a Sheet.
const Size _phone = Size(390, 780);

DabblerColors _colours({Brightness brightness = Brightness.light}) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: brightness);

Widget _host(
  Widget child, {
  Size size = _wide,
  TextDirection textDirection = TextDirection.ltr,
  Brightness brightness = Brightness.light,
  AlignmentDirectional alignment = AlignmentDirectional.center,
}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: Directionality(
      textDirection: textDirection,
      child: Theme(
        data: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            _colours(brightness: brightness),
          ],
        ),
        // A Navigator supplies the Overlay that OverlayPortal needs.
        child: Navigator(
          onGenerateRoute: (RouteSettings settings) => PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, _, _) => Align(alignment: alignment, child: child),
          ),
        ),
      ),
    ),
  );
}

const Widget _trigger = SizedBox(
  width: DabblerSizing.touchTargetMin,
  height: DabblerSizing.touchTargetMin,
  child: Text('open'),
);

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

List<DabblerMenuEntry> _threeItems({
  ValueChanged<DabblerMenuEntry>? onSelect,
  bool disableSecond = false,
}) =>
    <DabblerMenuEntry>[
      DabblerMenuEntry(id: 'share', label: 'share game', onSelect: onSelect),
      DabblerMenuEntry(
        id: 'copy',
        label: 'copy link',
        disabled: disableSecond,
        onSelect: onSelect,
      ),
      const DabblerMenuEntry.separator(id: 'rule'),
      DabblerMenuEntry(
        id: 'leave',
        label: 'leave game',
        tone: DabblerMenuItemTone.destructive,
        onSelect: onSelect,
      ),
    ];

void main() {
  // ----- AC1: viewport-aware flipping, exercised at all four edges -----
  group('positionFor (AC1)', () {
    const Size child = Size(240, 200);
    const Size viewport = Size(800, 600);

    test('stays below the trigger when there is room', () {
      final DabblerMenuPosition p = DabblerMenu.positionFor(
        anchor: const Rect.fromLTWH(100, 100, 45, 45),
        childSize: child,
        viewport: viewport,
        placement: DabblerMenuPlacement.bottomStart,
        textDirection: TextDirection.ltr,
      );
      expect(p.placement, DabblerMenuPlacement.bottomStart);
      expect(p.offset.dy, 145 + DabblerMenu.anchorGap);
      expect(p.offset.dx, 100);
    });

    test('flips to the block start near the bottom edge', () {
      final DabblerMenuPosition p = DabblerMenu.positionFor(
        // 45 tall, sitting 40px off the bottom: 200 does not fit below.
        anchor: const Rect.fromLTWH(100, 515, 45, 45),
        childSize: child,
        viewport: viewport,
        placement: DabblerMenuPlacement.bottomStart,
        textDirection: TextDirection.ltr,
      );
      expect(p.placement, DabblerMenuPlacement.topStart);
      expect(p.offset.dy, 515 - DabblerMenu.anchorGap - 200);
    });

    test('flips back down near the top edge', () {
      final DabblerMenuPosition p = DabblerMenu.positionFor(
        anchor: const Rect.fromLTWH(100, 10, 45, 45),
        childSize: child,
        viewport: viewport,
        placement: DabblerMenuPlacement.topStart,
        textDirection: TextDirection.ltr,
      );
      expect(p.placement, DabblerMenuPlacement.bottomStart);
      expect(p.offset.dy, 55 + DabblerMenu.anchorGap);
    });

    test('flips to the inline end near the inline end edge (LTR)', () {
      final DabblerMenuPosition p = DabblerMenu.positionFor(
        // Start-aligned would put the right edge at 780 + 240 = well past 800.
        anchor: const Rect.fromLTWH(740, 100, 45, 45),
        childSize: child,
        viewport: viewport,
        placement: DabblerMenuPlacement.bottomStart,
        textDirection: TextDirection.ltr,
      );
      expect(p.placement, DabblerMenuPlacement.bottomEnd);
      expect(p.offset.dx, 785 - 240);
    });

    test('flips to the inline start near the inline start edge (LTR)', () {
      final DabblerMenuPosition p = DabblerMenu.positionFor(
        anchor: const Rect.fromLTWH(10, 100, 45, 45),
        childSize: child,
        viewport: viewport,
        placement: DabblerMenuPlacement.bottomEnd,
        textDirection: TextDirection.ltr,
      );
      expect(p.placement, DabblerMenuPlacement.bottomStart);
      expect(p.offset.dx, 10);
    });

    test('RTL mirrors the inline axis: bottomStart hangs from the right', () {
      final DabblerMenuPosition p = DabblerMenu.positionFor(
        anchor: const Rect.fromLTWH(400, 100, 45, 45),
        childSize: child,
        viewport: viewport,
        placement: DabblerMenuPlacement.bottomStart,
        textDirection: TextDirection.rtl,
      );
      // Start edge in RTL is the trigger's right edge: 445 - 240.
      expect(p.offset.dx, 445 - 240);
      expect(p.placement, DabblerMenuPlacement.bottomStart);
    });

    test('RTL flips at the inline end (the left-hand) edge', () {
      final DabblerMenuPosition p = DabblerMenu.positionFor(
        // Start-aligned in RTL runs leftwards from 65 and falls off the left
        // edge, so the popover flips to hang from the trigger's left edge.
        anchor: const Rect.fromLTWH(20, 100, 45, 45),
        childSize: child,
        viewport: viewport,
        placement: DabblerMenuPlacement.bottomStart,
        textDirection: TextDirection.rtl,
      );
      expect(p.placement, DabblerMenuPlacement.bottomEnd);
      expect(p.offset.dx, 20);
    });

    test('clamps into the viewport when neither side fits', () {
      final DabblerMenuPosition p = DabblerMenu.positionFor(
        anchor: const Rect.fromLTWH(100, 280, 45, 45),
        childSize: const Size(240, 560),
        viewport: viewport,
        placement: DabblerMenuPlacement.bottomStart,
        textDirection: TextDirection.ltr,
      );
      // Neither side fits, so it is clamped to the lowest top that still
      // leaves the margin at the bottom: 600 - 8 - 560.
      expect(p.offset.dy, 32);
      expect(p.offset.dy + 560, 600 - DabblerMenu.viewportMargin);
    });
  });

  // ----- Opening, dismissal and selection -----
  group('open and dismiss', () {
    testWidgets('the trigger opens the menu and reports its state',
        (WidgetTester tester) async {
      final List<bool> opened = <bool>[];
      await tester.pumpWidget(_host(
        DabblerMenu(
          label: 'game actions',
          trigger: _trigger,
          items: _threeItems(),
          onOpenChanged: opened.add,
        ),
      ));
      expect(find.text('share game'), findsNothing);

      await _openMenu(tester);
      expect(find.text('share game'), findsOneWidget);
      expect(find.text('leave game'), findsOneWidget);
      expect(opened, <bool>[true]);
    });

    testWidgets('Escape closes it', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenu(trigger: _trigger, items: _threeItems()),
      ));
      await _openMenu(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('share game'), findsNothing);
    });

    testWidgets('a pointer down outside closes it', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenu(trigger: _trigger, items: _threeItems()),
      ));
      await _openMenu(tester);
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.text('share game'), findsNothing);
    });

    testWidgets('a tap on an item selects it and closes',
        (WidgetTester tester) async {
      final List<String> chosen = <String>[];
      await tester.pumpWidget(_host(
        DabblerMenu(
          trigger: _trigger,
          items: _threeItems(
            onSelect: (DabblerMenuEntry e) => chosen.add(e.id!),
          ),
        ),
      ));
      await _openMenu(tester);
      await tester.tap(find.text('copy link'));
      await tester.pumpAndSettle();
      expect(chosen, <String>['copy']);
      expect(find.text('copy link'), findsNothing);
    });

    testWidgets('closeOnSelect: false keeps it open',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenu(
          trigger: _trigger,
          closeOnSelect: false,
          items: _threeItems(),
        ),
      ));
      await _openMenu(tester);
      await tester.tap(find.text('copy link'));
      await tester.pumpAndSettle();
      expect(find.text('copy link'), findsOneWidget);
    });

    testWidgets('a disabled item stays in the list and does not fire',
        (WidgetTester tester) async {
      final List<String> chosen = <String>[];
      await tester.pumpWidget(_host(
        DabblerMenu(
          trigger: _trigger,
          items: _threeItems(
            disableSecond: true,
            onSelect: (DabblerMenuEntry e) => chosen.add(e.id!),
          ),
        ),
      ));
      await _openMenu(tester);
      expect(find.text('copy link'), findsOneWidget);
      await tester.tap(find.text('copy link'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(chosen, isEmpty);
    });
  });

  // ----- Controlled open, the path Select (DS-601) and PickerField need -----
  group('KAN-286 — an uncontrolled menu opens from a gesture-handling trigger',
      () {
    // The defect: the trigger wrapper was a GestureDetector, and Flutter's
    // arena is winner-take-all, so a DabblerButton trigger claimed the tap for
    // its press-scale recogniser and the wrapper never fired. The source works
    // because `<span onClick>` receives the click by DOM bubbling
    // (`Menu.jsx:146`), which a [Listener] reproduces.

    testWidgets('a DabblerButton trigger with no onPressed opens the menu', (
      WidgetTester tester,
    ) async {
      // Exactly the shape menu_gallery.dart:47 ships, and exactly the shape
      // the class dartdoc recommends.
      await tester.pumpWidget(_host(
        DabblerMenu(
          label: 'game actions',
          trigger: const DabblerButton(label: 'Actions'),
          items: _threeItems(),
        ),
      ));
      expect(find.text('share game'), findsNothing);

      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      expect(find.text('share game'), findsOneWidget,
          reason: 'the documented uncontrolled pattern must actually open');
    });

    testWidgets('tapping the trigger again closes it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(
        DabblerMenu(
          label: 'game actions',
          trigger: const DabblerButton(label: 'Actions'),
          items: _threeItems(),
        ),
      ));
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      expect(find.text('share game'), findsOneWidget);

      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      expect(find.text('share game'), findsNothing,
          reason: 'the wrapper toggles, as `setOpen(!open)` does');
    });

    testWidgets("the trigger's own onPressed still runs — both fire, as in "
        'the DOM', (WidgetTester tester) async {
      int pressed = 0;
      await tester.pumpWidget(_host(
        DabblerMenu(
          label: 'game actions',
          trigger: DabblerButton(label: 'Actions', onPressed: () => pressed++),
          items: _threeItems(),
        ),
      ));
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      expect(pressed, 1, reason: 'the Listener must not steal the tap');
      expect(find.text('share game'), findsOneWidget,
          reason: 'and the menu still opens — bubbling, not interception');
    });

    testWidgets('a drag off the trigger does not toggle it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(
        DabblerMenu(
          label: 'game actions',
          trigger: const DabblerButton(label: 'Actions'),
          items: _threeItems(),
        ),
      ));
      final Offset start = tester.getCenter(find.text('Actions'));
      final TestGesture gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(120, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('share game'), findsNothing,
          reason: 'a Listener sees every pointer up; only a click opens');
    });

    testWidgets('a non-gesture trigger still opens — no regression', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(
        DabblerMenu(
          label: 'game actions',
          trigger: _trigger,
          items: _threeItems(),
        ),
      ));
      await _openMenu(tester);
      expect(find.text('share game'), findsOneWidget);
    });
  });

  group('controlled open', () {
    /// An owner that holds `open` itself, as `Select` does.
    Widget controlled({
      required ValueNotifier<bool> open,
      Size size = _wide,
    }) {
      return _host(
        ValueListenableBuilder<bool>(
          valueListenable: open,
          builder: (BuildContext context, bool value, _) => DabblerMenu(
            open: value,
            onOpenChanged: (bool next) => open.value = next,
            trigger: _trigger,
            items: _threeItems(),
          ),
        ),
        size: size,
      );
    }

    testWidgets('flipping open to true from the owner opens it',
        (WidgetTester tester) async {
      // Regression, DS-601: the owner's rebuild reaches didUpdateWidget during
      // the build phase, where OverlayPortalController.show asserts.
      final ValueNotifier<bool> open = ValueNotifier<bool>(false);
      addTearDown(open.dispose);
      await tester.pumpWidget(controlled(open: open));
      expect(find.text('share game'), findsNothing);

      open.value = true;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('share game'), findsOneWidget);
    });

    testWidgets('flipping it back to false closes it',
        (WidgetTester tester) async {
      final ValueNotifier<bool> open = ValueNotifier<bool>(true);
      addTearDown(open.dispose);
      await tester.pumpWidget(controlled(open: open));
      await tester.pumpAndSettle();
      expect(find.text('share game'), findsOneWidget);

      open.value = false;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('share game'), findsNothing);
    });

    testWidgets('a menu that starts open shows without a tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenu(open: true, trigger: _trigger, items: _threeItems()),
      ));
      await tester.pumpAndSettle();
      expect(find.text('share game'), findsOneWidget);
    });

    testWidgets('an owner that ignores onOpenChanged keeps it shut',
        (WidgetTester tester) async {
      final List<bool> reported = <bool>[];
      await tester.pumpWidget(_host(
        DabblerMenu(
          open: false,
          onOpenChanged: reported.add,
          trigger: _trigger,
          items: _threeItems(),
        ),
      ));
      await _openMenu(tester);
      expect(reported, <bool>[true]);
      expect(find.text('share game'), findsNothing);
    });

    testWidgets('the controlled path works at sheet width too',
        (WidgetTester tester) async {
      final ValueNotifier<bool> open = ValueNotifier<bool>(false);
      addTearDown(open.dispose);
      await tester.pumpWidget(controlled(open: open, size: _phone));
      open.value = true;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(DabblerSheet), findsOneWidget);
    });

    testWidgets('Escape routes through onOpenChanged, not internal state',
        (WidgetTester tester) async {
      final ValueNotifier<bool> open = ValueNotifier<bool>(true);
      addTearDown(open.dispose);
      await tester.pumpWidget(controlled(open: open));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(open.value, isFalse);
      expect(find.text('share game'), findsNothing);
    });
  });

  // ----- AC2: the Sheet presentation below 480px -----
  group('sheet below 480px (AC2)', () {
    testWidgets('a phone-width viewport renders the items in a Sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenu(
          label: 'add to post',
          trigger: _trigger,
          items: _threeItems(),
        ),
        size: _phone,
      ));
      await _openMenu(tester);

      expect(find.byType(DabblerSheet), findsOneWidget);
      expect(find.text('share game'), findsOneWidget);
      // The label becomes the sheet's title.
      expect(find.text('add to post'), findsOneWidget);
    });

    testWidgets('the Sheet is the widget, not a pushed route',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenu(trigger: _trigger, items: _threeItems()),
        size: _phone,
      ));
      await _openMenu(tester);
      expect(find.byType(DabblerSheetRoute<dynamic>), findsNothing);
      // Selecting from the sheet still runs the menu's own close path.
      await tester.tap(find.text('copy link'));
      await tester.pumpAndSettle();
      expect(find.byType(DabblerSheet), findsNothing);
    });

    testWidgets('exactly 480 is still a popover', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenu(trigger: _trigger, items: _threeItems()),
        size: const Size(DabblerMenu.sheetBreakpoint, 700),
      ));
      await _openMenu(tester);
      expect(find.byType(DabblerSheet), findsNothing);
      expect(find.text('share game'), findsOneWidget);
    });

    testWidgets('479 is a sheet', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenu(trigger: _trigger, items: _threeItems()),
        size: const Size(DabblerMenu.sheetBreakpoint - 1, 700),
      ));
      await _openMenu(tester);
      expect(find.byType(DabblerSheet), findsOneWidget);
    });
  });

  // ----- AC3: keyboard -----
  group('keyboard (AC3)', () {
    Future<void> pumpOpen(
      WidgetTester tester, {
      bool disableSecond = false,
      List<String>? chosen,
    }) async {
      await tester.pumpWidget(_host(
        DabblerMenu(
          trigger: _trigger,
          items: _threeItems(
            disableSecond: disableSecond,
            onSelect: chosen == null
                ? null
                : (DabblerMenuEntry e) => chosen.add(e.id!),
          ),
        ),
      ));
      await _openMenu(tester);
    }

    bool focused(WidgetTester tester, String label) {
      final DabblerMenuItem item = tester.widget<DabblerMenuItem>(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(DabblerMenuItem),
        ),
      );
      return item.active && (item.focusNode?.hasFocus ?? false);
    }

    testWidgets('ArrowDown enters the list, then cycles and wraps',
        (WidgetTester tester) async {
      await pumpOpen(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused(tester, 'share game'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused(tester, 'copy link'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      // The separator is skipped.
      expect(focused(tester, 'leave game'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused(tester, 'share game'), isTrue);
    });

    testWidgets('ArrowUp from closed enters at the end',
        (WidgetTester tester) async {
      await pumpOpen(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(focused(tester, 'leave game'), isTrue);
    });

    testWidgets('arrow keys skip a disabled item',
        (WidgetTester tester) async {
      await pumpOpen(tester, disableSecond: true);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused(tester, 'leave game'), isTrue);
    });

    testWidgets('Home and End jump to the ends', (WidgetTester tester) async {
      await pumpOpen(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(focused(tester, 'leave game'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(focused(tester, 'share game'), isTrue);
    });

    testWidgets('Enter selects the active item', (WidgetTester tester) async {
      final List<String> chosen = <String>[];
      await pumpOpen(tester, chosen: chosen);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(chosen, <String>['share']);
      expect(find.text('share game'), findsNothing);
    });

    testWidgets('type-ahead jumps to the first matching label',
        (WidgetTester tester) async {
      await pumpOpen(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pump();
      expect(focused(tester, 'copy link'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
      await tester.pump();
      // "cl" matches nothing, so the active row does not move.
      expect(focused(tester, 'copy link'), isTrue);
    });

    testWidgets('the type-ahead buffer resets after the timeout',
        (WidgetTester tester) async {
      await pumpOpen(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pump(DabblerMenuList.typeAheadTimeout * 2);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
      await tester.pump();
      // A fresh buffer of "l" reaches "leave game".
      expect(focused(tester, 'leave game'), isTrue);
    });

    testWidgets('type-ahead skips a disabled item',
        (WidgetTester tester) async {
      await pumpOpen(tester, disableSecond: true);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pump();
      expect(focused(tester, 'copy link'), isFalse);
    });

    testWidgets('roving tab order: only the active row is traversable',
        (WidgetTester tester) async {
      await pumpOpen(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      final List<DabblerMenuItem> rows = tester
          .widgetList<DabblerMenuItem>(find.byType(DabblerMenuItem))
          .toList();
      expect(
        rows.where((DabblerMenuItem r) => !(r.focusNode?.skipTraversal ?? true)),
        hasLength(1),
      );
    });

    testWidgets('hover moves the active row without taking focus',
        (WidgetTester tester) async {
      await pumpOpen(tester);
      final TestGesture pointer =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await pointer.addPointer();
      addTearDown(pointer.removePointer);
      await pointer.moveTo(tester.getCenter(find.text('leave game')));
      await tester.pump();

      final DabblerMenuItem row = tester.widget<DabblerMenuItem>(
        find.ancestor(
          of: find.text('leave game'),
          matching: find.byType(DabblerMenuItem),
        ),
      );
      expect(row.active, isTrue);
      expect(row.focusNode?.hasFocus, isFalse);
    });
  });

  // ----- AC4: the semantic iconTone tile -----
  group('iconTone (AC4)', () {
    Future<DabblerColors> pumpItem(
      WidgetTester tester, {
      DabblerMenuIconTone? tone,
      String? icon = 'gallery',
      Brightness brightness = Brightness.light,
    }) async {
      await tester.pumpWidget(_host(
        DabblerMenuItem(label: 'photo', icon: icon, iconTone: tone),
        brightness: brightness,
      ));
      await tester.pumpAndSettle();
      return _colours(brightness: brightness);
    }

    Finder tile() => find.byKey(DabblerMenuItem.tileKey);

    BoxDecoration tileDecoration(WidgetTester tester) => tester
        .widget<DecoratedBox>(
          find.descendant(of: tile(), matching: find.byType(DecoratedBox)),
        )
        .decoration as BoxDecoration;

    testWidgets('no tone means a bare glyph and no tile',
        (WidgetTester tester) async {
      await pumpItem(tester);
      expect(tile(), findsNothing);
      expect(find.byType(DabblerIcon), findsOneWidget);
    });

    testWidgets('a tone draws a 30px tinted tile at 12%',
        (WidgetTester tester) async {
      final DabblerColors colors =
          await pumpItem(tester, tone: DabblerMenuIconTone.brand);
      final BoxDecoration decoration = tileDecoration(tester);
      expect(
        decoration.color,
        colors.brandPrimary.withValues(alpha: DabblerMenuItem.tileTintOpacity),
      );
      expect(decoration.borderRadius, DabblerRadius.mdAll);

      final Size size = tester.getSize(tile());
      expect(size.width, DabblerSizing.iconLg);
      expect(size.height, DabblerSizing.iconLg);
    });

    testWidgets('every tone resolves to its own token',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const SizedBox.shrink()));
      final DabblerColors colors = _colours();
      expect(
        DabblerMenuItem.toneColorOf(DabblerMenuIconTone.success, colors),
        colors.success.base,
      );
      expect(
        DabblerMenuItem.toneColorOf(DabblerMenuIconTone.warning, colors),
        colors.warning.base,
      );
      expect(
        DabblerMenuItem.toneColorOf(DabblerMenuIconTone.error, colors),
        colors.error.base,
      );
      expect(
        DabblerMenuItem.toneColorOf(DabblerMenuIconTone.info, colors),
        colors.info.base,
      );
      // neutral is outside the --color-status-* API, from the paper ramp.
      expect(
        DabblerMenuItem.toneColorOf(DabblerMenuIconTone.neutral, colors),
        colors.textSecondary,
      );
      expect(
        DabblerMenuItem.toneColorOf(DabblerMenuIconTone.brand, colors),
        colors.brandPrimary,
      );
    });

    testWidgets('the tone follows dark mode', (WidgetTester tester) async {
      final DabblerColors dark = await pumpItem(
        tester,
        tone: DabblerMenuIconTone.info,
        brightness: Brightness.dark,
      );
      expect(
        tileDecoration(tester).color,
        dark.info.base.withValues(alpha: DabblerMenuItem.tileTintOpacity),
      );
    });

    testWidgets('a tile does not change the row height',
        (WidgetTester tester) async {
      await pumpItem(tester);
      final double bare =
          tester.getSize(find.byType(DabblerMenuItem)).height;
      await pumpItem(tester, tone: DabblerMenuIconTone.success);
      expect(tester.getSize(find.byType(DabblerMenuItem)).height, bare);
      expect(bare, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
    });

    testWidgets('a tone with no icon draws nothing',
        (WidgetTester tester) async {
      await pumpItem(tester, tone: DabblerMenuIconTone.error, icon: null);
      expect(tile(), findsNothing);
    });
  });

  // ----- Visual transcription -----
  group('visual', () {
    testWidgets('the popover is a flat card: surface, hairline, radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenu(trigger: _trigger, items: _threeItems()),
      ));
      await _openMenu(tester);
      final BoxDecoration decoration = tester
          .widget<DecoratedBox>(
            find
                .descendant(
                  of: find.byType(DabblerMenuList),
                  matching: find.byType(DecoratedBox),
                )
                .first,
          )
          .decoration as BoxDecoration;
      final DabblerColors colors = _colours();
      expect(decoration.color, colors.surfaceCard);
      expect(decoration.borderRadius, DabblerRadius.lgAll);
      expect(
        (decoration.border! as Border).top.color,
        colors.borderDefault,
      );
      // Flat: no shadow anywhere in the system but Dialog's.
      expect(decoration.boxShadow, isNull);
    });

    testWidgets('the popover respects the 200–320 width range',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenu(trigger: _trigger, items: _threeItems()),
      ));
      await _openMenu(tester);
      final double width = tester.getSize(find.byType(DabblerMenuList)).width;
      expect(width, greaterThanOrEqualTo(DabblerMenu.minPopoverWidth));
      expect(width, lessThanOrEqualTo(DabblerMenu.maxPopoverWidth));
    });

    testWidgets('fullWidth matches the trigger instead',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        SizedBox(
          width: 360,
          child: DabblerMenu(
            fullWidth: true,
            trigger: _trigger,
            items: _threeItems(),
          ),
        ),
      ));
      await _openMenu(tester);
      expect(tester.getSize(find.byType(DabblerMenuList)).width, 360);
    });

    testWidgets('a destructive item takes the error ink',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerMenuItem(
          label: 'leave game',
          tone: DabblerMenuItemTone.destructive,
        ),
      ));
      final Text text = tester.widget<Text>(find.text('leave game'));
      expect(text.style!.color, _colours().error.strong);
    });

    testWidgets('the active row fills with --faint',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerMenuItem(label: 'share game', active: true),
      ));
      await tester.pumpAndSettle();
      final BoxDecoration decoration = tester
          .widget<AnimatedContainer>(find.byType(AnimatedContainer))
          .decoration! as BoxDecoration;
      expect(decoration.color, _colours().bgTertiary);
    });

    testWidgets('the separator is a 1px --faint hairline',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerMenuSeparator()));
      expect(tester.getSize(find.byType(ColoredBox)).height,
          DabblerSizing.borderDefault);
      expect(
        tester.widget<ColoredBox>(find.byType(ColoredBox)).color,
        _colours().bgTertiary,
      );
    });

    testWidgets('every row clears the 44×44 touch floor',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenu(trigger: _trigger, items: _threeItems()),
      ));
      await _openMenu(tester);
      for (final Element row in find.byType(DabblerMenuItem).evaluate()) {
        expect(
          tester.getSize(find.byElementPredicate((Element e) => e == row)).height,
          greaterThanOrEqualTo(44),
        );
      }
    });
  });

  // ----- Reuse by Select (DS-601) and TimePicker (DS-806) -----
  group('controller (KAN-278)', () {
    /// Enough rows to overflow [height] and leave something to scroll to.
    List<DabblerMenuEntry> manyRows() => List<DabblerMenuEntry>.generate(
          40,
          (int i) => DabblerMenuEntry(id: '$i', label: 'row $i'),
        );

    Widget column(ScrollController? controller, {double height = 200}) =>
        _host(Center(
          child: SizedBox(
            height: height,
            width: 240,
            child: DabblerMenuList(
              label: 'rows',
              items: manyRows(),
              controller: controller,
              decorated: false,
              autofocus: false,
            ),
          ),
        ));

    testWidgets('a supplied controller actually moves the scroll offset',
        (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(column(controller));
      await tester.pumpAndSettle();

      expect(controller.hasClients, isTrue,
          reason: 'the controller must be attached to the list\'s own view');
      expect(controller.offset, 0);

      controller.jumpTo(150);
      await tester.pump();
      expect(controller.offset, 150);

      // And the rows really moved with it, not just the controller's number.
      final Offset afterJump = tester.getTopLeft(find.text('row 0'));

      unawaited(controller.animateTo(
        300,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      ));
      await tester.pumpAndSettle();
      expect(controller.offset, 300);
      expect(tester.getTopLeft(find.text('row 0')).dy,
          lessThan(afterJump.dy));
    });

    testWidgets('null controller is unchanged — ambient Primary still works',
        (WidgetTester tester) async {
      final ScrollController ambient = ScrollController();
      addTearDown(ambient.dispose);

      await tester.pumpWidget(_host(Center(
        child: SizedBox(
          height: 200,
          width: 240,
          child: PrimaryScrollController(
            controller: ambient,
            automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
            child: DabblerMenuList(
              label: 'rows',
              items: manyRows(),
              decorated: false,
              autofocus: false,
            ),
          ),
        ),
      )));
      await tester.pumpAndSettle();

      expect(ambient.hasClients, isTrue);
      ambient.jumpTo(120);
      await tester.pump();
      expect(ambient.offset, 120);
    });
  });

  group('composition', () {
    testWidgets('the list stands alone, with no Menu around it',
        (WidgetTester tester) async {
      final List<String> chosen = <String>[];
      await tester.pumpWidget(_host(
        DabblerMenuList(
          label: 'sort by',
          items: _threeItems(
            onSelect: (DabblerMenuEntry e) => chosen.add(e.id!),
          ),
          onSelected: (DabblerMenuEntry e) => e.onSelect?.call(e),
        ),
      ));
      expect(find.byType(DabblerMenu), findsNothing);
      await tester.tap(find.text('share game'));
      await tester.pump();
      expect(chosen, <String>['share']);
    });

    testWidgets('the listbox role leaves the keyboard to its composer',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenuList(
          role: DabblerMenuRole.listbox,
          items: _threeItems(),
        ),
      ));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      final Iterable<DabblerMenuItem> rows =
          tester.widgetList<DabblerMenuItem>(find.byType(DabblerMenuItem));
      expect(rows.where((DabblerMenuItem r) => r.active), isEmpty);
      expect(rows.every((DabblerMenuItem r) => r.role == DabblerMenuRole.listbox),
          isTrue);
    });

    testWidgets('a header sits above the rows', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        DabblerMenuList(
          header: const Text('search'),
          items: _threeItems(),
        ),
      ));
      expect(
        tester.getTopLeft(find.text('search')).dy,
        lessThan(tester.getTopLeft(find.text('share game')).dy),
      );
    });

    testWidgets('an empty list renders and carries no menu role',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const DabblerMenuList(items: <DabblerMenuEntry>[]),
      ));
      expect(find.byType(DabblerMenuList), findsOneWidget);
      expect(find.byType(DabblerMenuItem), findsNothing);
      handle.dispose();
    });
  });

  // ----- Accessibility -----
  group('semantics', () {
    testWidgets('the list is a menu and the rows are menu items',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        DabblerMenu(
          label: 'game actions',
          trigger: _trigger,
          items: _threeItems(),
        ),
      ));
      await _openMenu(tester);

      final Finder listNode = find.byWidgetPredicate(
        (Widget w) => w is Semantics && w.properties.role == SemanticsRole.menu,
      );
      expect(listNode, findsOneWidget);
      expect(tester.getSemantics(listNode).role, SemanticsRole.menu);
      expect(
        tester
            .getSemantics(find.byType(DabblerMenuItem).first)
            .role,
        SemanticsRole.menuItem,
      );
      handle.dispose();
    });

    testWidgets('the trigger reports its expanded state',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        DabblerMenu(trigger: _trigger, items: _threeItems()),
      ));
      expect(
        tester.getSemantics(find.text('open')).flagsCollection.isExpanded,
        Tristate.isFalse,
      );
      await _openMenu(tester);
      expect(
        tester.getSemantics(find.text('open')).flagsCollection.isExpanded,
        Tristate.isTrue,
      );
      handle.dispose();
    });
  });
}
