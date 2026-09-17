import 'package:dabbler_design_system/src/interaction/press_scale.dart';
import 'package:dabbler_design_system/src/interaction/scrim.dart';
import 'package:dabbler_design_system/src/overlays/sheet.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The viewport every test measures against, so a detent fraction is
/// arithmetic rather than a guess.
const Size _viewport = Size(800, 600);

DabblerColors _colours({Brightness brightness = Brightness.light}) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: brightness);

/// A sheet needs a [MediaQuery] with a real size, a [Directionality], a
/// [Navigator] for the route tests and a [DabblerColors] for `of`.
Widget _host(
  Widget child, {
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
  EdgeInsets viewPadding = EdgeInsets.zero,
  bool disableAnimations = false,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: _viewport,
      viewPadding: viewPadding,
      padding: viewPadding,
      disableAnimations: disableAnimations,
    ),
    child: Directionality(
      textDirection: textDirection,
      child: Theme(
        data: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            _colours(brightness: brightness),
          ],
        ),
        child: Navigator(
          onGenerateRoute: (RouteSettings settings) => PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, _, _) => child,
          ),
        ),
      ),
    ),
  );
}

BoxDecoration _panelDecoration(WidgetTester tester) {
  return tester
      .widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(DabblerSheet),
              matching: find.byType(DecoratedBox),
            )
            .first,
      )
      .decoration as BoxDecoration;
}

void main() {
  group('AC1 — the sheet uses DS-200 scrim and renders modally from the bottom',
      () {
    testWidgets('the wash is DabblerScrim, composed exactly once',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(DabblerSheet(onClose: () {}, child: const Text('body'))),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DabblerScrim), findsOneWidget);
      // The panel itself never paints the scrim colour — one scrim, not two.
      final Iterable<DecoratedBox> boxes =
          tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      for (final DecoratedBox box in boxes) {
        expect((box.decoration as BoxDecoration).color,
            isNot(_colours().scrim));
      }
    });

    testWidgets('the panel sits on the bottom edge of the viewport',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(DabblerSheet(onClose: () {}, child: const Text('body'))),
      );
      await tester.pumpAndSettle();

      final Rect panel = tester.getRect(find.byType(ClipRRect).first);
      expect(panel.bottom, _viewport.height);
      // Default detent 0.5 of the viewport (`Sheet.d.ts:8`).
      expect(panel.height, closeTo(_viewport.height * 0.5, 0.5));
    });

    testWidgets('detents are sorted ascending and snapTo indexes into them',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          DabblerSheet(
            onClose: () {},
            detents: const <double>[0.9, 0.25],
            snapTo: 0,
            child: const Text('body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // snapTo 0 is the SMALLEST detent once sorted, i.e. 0.25 not 0.9.
      expect(
        tester.getRect(find.byType(ClipRRect).first).height,
        closeTo(_viewport.height * 0.25, 0.5),
      );
    });

    testWidgets('the panel never exceeds 520 wide', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Theme(
              data: ThemeData(
                extensions: <ThemeExtension<dynamic>>[_colours()],
              ),
              child: DabblerSheet(onClose: () {}, child: const Text('body')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.byType(ClipRRect).first).width,
        DabblerSheet.maxPanelWidth,
      );
    });
  });

  group('flat panel — Sheet.prompt.md "Visual"', () {
    testWidgets('surface-card fill, 1px outline-card hairline, no shadow',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(DabblerSheet(onClose: () {}, child: const Text('body'))),
      );
      await tester.pumpAndSettle();

      final BoxDecoration decoration = _panelDecoration(tester);
      expect(decoration.color, _colours().surfaceCard);
      expect(decoration.boxShadow, isNull);
      final Border border = decoration.border! as Border;
      expect(border.top.color, _colours().borderDefault);
      expect(border.top.width, DabblerSizing.borderDefault);
      // Modal drops the bottom edge; it is off-screen (`Sheet.jsx:85`).
      expect(border.bottom, BorderSide.none);
    });

    testWidgets('top corners are --radius-xl (18)', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(DabblerSheet(onClose: () {}, child: const Text('body'))),
      );
      await tester.pumpAndSettle();

      expect(
        _panelDecoration(tester).borderRadius,
        const BorderRadius.vertical(top: Radius.circular(DabblerRadius.xl)),
      );
      expect(DabblerRadius.xl, 18);
    });

    testWidgets('inline presentation has no scrim and all four corners',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerSheet(
            presentation: DabblerSheetPresentation.inline,
            child: Text('body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DabblerScrim), findsNothing);
      expect(_panelDecoration(tester).borderRadius, DabblerRadius.xlAll);
    });
  });

  group('the grab handle', () {
    testWidgets('is a 40x4 pill in --outline-strong on a 45 tall row',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(DabblerSheet(onClose: () {}, child: const Text('body'))),
      );
      await tester.pumpAndSettle();

      final Finder handle = find.byWidgetPredicate(
        (Widget w) =>
            w is Container &&
            w.constraints?.maxWidth == DabblerSheet.handleWidth,
      );
      final Size size = tester.getSize(handle);
      expect(size, const Size(40, 4));

      final BoxDecoration decoration =
          tester.widget<Container>(handle).decoration! as BoxDecoration;
      expect(decoration.color, _colours().borderStrong);
      expect(decoration.borderRadius, DabblerRadius.pillAll);

      final Finder row = find.ancestor(
        of: handle,
        matching: find.byType(GestureDetector),
      );
      expect(
        tester.getSize(row.first).height,
        DabblerSizing.touchTargetMin,
      );
    });

    testWidgets('is absent when dragHandle is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          DabblerSheet(
            onClose: () {},
            dragHandle: false,
            child: const Text('body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((Widget w) =>
            w is Container &&
            w.constraints?.maxWidth == DabblerSheet.handleWidth),
        findsNothing,
      );
    });
  });

  group('dismissal', () {
    testWidgets('the close affordance is at least 44x44 and closes',
        (WidgetTester tester) async {
      int closed = 0;
      await tester.pumpWidget(
        _host(
          DabblerSheet(
            title: 'filters',
            onClose: () => closed++,
            child: const Text('body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder close = find.bySemanticsLabel('Close');
      final Size size = tester.getSize(close);
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(size.width, DabblerSizing.touchTargetMin);

      await tester.tap(close);
      expect(closed, 1);
    });

    testWidgets('a press on the scrim closes', (WidgetTester tester) async {
      int closed = 0;
      await tester.pumpWidget(
        _host(
          DabblerSheet(onClose: () => closed++, child: const Text('body')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(200, 40));
      expect(closed, 1);
    });

    testWidgets('Escape closes', (WidgetTester tester) async {
      int closed = 0;
      await tester.pumpWidget(
        _host(
          DabblerSheet(onClose: () => closed++, child: const Text('body')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(closed, 1);
    });

    testWidgets('dismissible false removes every route',
        (WidgetTester tester) async {
      int closed = 0;
      await tester.pumpWidget(
        _host(
          DabblerSheet(
            dismissible: false,
            title: 'filters',
            onClose: () => closed++,
            child: const Text('body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No close button.
      expect(find.bySemanticsLabel('Close'), findsNothing);
      // The scrim is inert.
      expect(
        tester.widget<DabblerScrim>(find.byType(DabblerScrim)).onDismiss,
        isNull,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(closed, 0);
    });
  });

  group('dragging moves the panel and nothing else', () {
    testWidgets('a drag well past the smallest detent dismisses',
        (WidgetTester tester) async {
      int closed = 0;
      await tester.pumpWidget(
        _host(
          DabblerSheet(onClose: () => closed++, child: const Text('body')),
        ),
      );
      await tester.pumpAndSettle();

      final Finder handle = find.byWidgetPredicate(
        (Widget w) =>
            w is Container &&
            w.constraints?.maxWidth == DabblerSheet.handleWidth,
      );
      await tester.drag(handle, const Offset(0, 300));
      await tester.pumpAndSettle();
      expect(closed, 1);
    });

    testWidgets('a small drag snaps back without changing the panel height',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(DabblerSheet(onClose: () {}, child: const Text('body'))),
      );
      await tester.pumpAndSettle();

      final double before =
          tester.getRect(find.byType(ClipRRect).first).height;
      await tester.drag(
        find.byWidgetPredicate((Widget w) =>
            w is Container &&
            w.constraints?.maxWidth == DabblerSheet.handleWidth),
        const Offset(0, 20),
      );
      await tester.pumpAndSettle();

      // Height is untouched by the gesture: the drag is a translation only
      // (`Sheet.prompt.md:58`).
      expect(
        tester.getRect(find.byType(ClipRRect).first).height,
        before,
      );
    });
  });

  group('title, body and footer', () {
    testWidgets('the title renders in .t-title-3 (20px) on text-primary',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          DabblerSheet(
            title: 'filters',
            onClose: () {},
            child: const Text('body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final TextStyle style =
          tester.widget<Text>(find.text('filters')).style!;
      expect(style.fontSize, 20);
      expect(style.color, _colours().textPrimary);
    });

    testWidgets('the footer is separated by a --faint hairline and clears the '
        'bottom safe area', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          DabblerSheet(
            onClose: () {},
            footer: const Text('go live'),
            child: const Text('body'),
          ),
          viewPadding: const EdgeInsets.only(bottom: 34),
        ),
      );
      await tester.pumpAndSettle();

      final BoxDecoration footer = tester
          .widgetList<DecoratedBox>(find.descendant(
            of: find.byType(DabblerSheet),
            matching: find.byType(DecoratedBox),
          ))
          .map((DecoratedBox b) => b.decoration as BoxDecoration)
          .firstWhere((BoxDecoration d) => d.color == null);
      expect((footer.border! as Border).top.color, _colours().bgTertiary);

      final EdgeInsets padding = tester
          .widgetList<Padding>(find.descendant(
            of: find.byType(DabblerSheet),
            matching: find.byType(Padding),
          ))
          .map((Padding p) => p.padding.resolve(TextDirection.ltr))
          .firstWhere((EdgeInsets e) => e.bottom > DabblerSpacing.space6);
      expect(padding.bottom, DabblerSpacing.space6 + 34);
      expect(padding.top, DabblerSpacing.space4);
    });

    testWidgets('padding is directional, so RTL mirrors it',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          DabblerSheet(
            title: 'filters',
            onClose: () {},
            child: const Text('body'),
          ),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      // Everything this widget lays out is directional, so the close button
      // moves to the leading (left) edge under RTL rather than staying right.
      final Rect panel = tester.getRect(find.byType(ClipRRect).first);
      final Rect close = tester.getRect(find.bySemanticsLabel('Close'));
      expect(close.left - panel.left, lessThan(panel.right - close.right));
    });
  });

  group('the route helper', () {
    testWidgets('showDabblerSheet opens a sheet and resolves what it pops',
        (WidgetTester tester) async {
      late BuildContext sheetContext;
      Future<String?>? result;

      await tester.pumpWidget(
        _host(
          Builder(
            builder: (BuildContext context) => GestureDetector(
              onTap: () {
                result = showDabblerSheet<String>(
                  context: context,
                  title: 'filters',
                  builder: (BuildContext inner) {
                    sheetContext = inner;
                    return const Text('body');
                  },
                );
              },
              child: const SizedBox.expand(child: Text('open')),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(DabblerSheet), findsOneWidget);
      expect(find.text('filters'), findsOneWidget);

      Navigator.of(sheetContext).pop('padel');
      await tester.pumpAndSettle();
      expect(find.byType(DabblerSheet), findsNothing);
      expect(await result, 'padel');
    });

    testWidgets('the route draws no barrier colour of its own',
        (WidgetTester tester) async {
      final DabblerSheetRoute<void> route = DabblerSheetRoute<void>(
        builder: (BuildContext context) => const Text('body'),
      );
      expect(route.barrierColor, isNull);
      expect(route.barrierDismissible, isFalse);
      expect(route.transitionDuration, DabblerMotion.slow);
    });
  });
}
