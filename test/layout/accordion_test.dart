import 'package:dabbler_design_system/src/layout/accordion.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) {
  final DabblerColors colors = DabblerColors.resolve(
    theme: DabblerTheme.main,
    brightness: Brightness.light,
  );
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

const List<DabblerAccordionItem> _items = <DabblerAccordionItem>[
  DabblerAccordionItem(id: 'a', title: 'Refunds', content: Text('body-a')),
  DabblerAccordionItem(id: 'b', title: 'Rules', content: Text('body-b')),
];

void main() {
  group('DabblerAccordion — Accordion.jsx', () {
    testWidgets('every section starts closed and its body is not built', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerAccordion(items: _items)));
      expect(find.text('Refunds'), findsOneWidget);
      expect(find.text('body-a'), findsNothing);
      expect(find.text('body-b'), findsNothing);
    });

    testWidgets('tapping a header opens it and tapping again closes it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerAccordion(items: _items)));
      await tester.tap(find.text('Refunds'));
      await tester.pumpAndSettle();
      expect(find.text('body-a'), findsOneWidget);
      await tester.tap(find.text('Refunds'));
      await tester.pumpAndSettle();
      expect(find.text('body-a'), findsNothing);
    });

    testWidgets('single-open: opening one closes the other', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerAccordion(items: _items)));
      await tester.tap(find.text('Refunds'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rules'));
      await tester.pumpAndSettle();
      expect(find.text('body-a'), findsNothing);
      expect(find.text('body-b'), findsOneWidget);
    });

    testWidgets('multiple keeps both open', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerAccordion(items: _items, multiple: true)),
      );
      await tester.tap(find.text('Refunds'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rules'));
      await tester.pumpAndSettle();
      expect(find.text('body-a'), findsOneWidget);
      expect(find.text('body-b'), findsOneWidget);
    });

    testWidgets('onChanged reports the id (single) and the list (multiple)', (
      WidgetTester tester,
    ) async {
      final List<Object?> seen = <Object?>[];
      await tester.pumpWidget(
        _host(DabblerAccordion(items: _items, onChanged: seen.add)),
      );
      await tester.tap(find.text('Rules'));
      await tester.pumpAndSettle();
      expect(seen, <Object?>['b']);

      final List<Object?> many = <Object?>[];
      await tester.pumpWidget(
        _host(
          DabblerAccordion(items: _items, multiple: true, onChanged: many.add),
        ),
      );
      await tester.tap(find.text('Refunds'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rules'));
      await tester.pumpAndSettle();
      expect(many.last, <String>['a', 'b']);
    });

    testWidgets('controlled: value decides what is open, not the tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerAccordion(items: _items, value: 'a', onChanged: (_) {})),
      );
      expect(find.text('body-a'), findsOneWidget);
      await tester.tap(find.text('Rules'));
      await tester.pumpAndSettle();
      expect(
        find.text('body-b'),
        findsNothing,
        reason: 'a controlled accordion waits for its parent',
      );
    });

    testWidgets('card variant and RTL both render', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerAccordion(
            items: _items,
            variant: DabblerAccordionVariant.card,
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Refunds'), findsOneWidget);
    });
  });

  group('DabblerCollapse', () {
    testWidgets('open reveals the child, closed drops it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerCollapse(open: true, child: Text('x'))),
      );
      expect(find.text('x'), findsOneWidget);
      await tester.pumpWidget(
        _host(const DabblerCollapse(open: false, child: Text('x'))),
      );
      await tester.pumpAndSettle();
      expect(find.text('x'), findsNothing);
    });
  });
}
