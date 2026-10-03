import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) {
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
    home: Directionality(
      textDirection: direction,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: 320, child: child),
      ),
    ),
  );
}

BoxDecoration _wellDecoration(WidgetTester tester) {
  final Container well = tester.widget<Container>(
    find
        .ancestor(
          of: find.byType(DabblerIcon),
          matching: find.byType(Container),
        )
        .first,
  );
  return well.decoration! as BoxDecoration;
}

void main() {
  test('default constructor keeps the neutral tone and no retry', () {
    const DabblerEmptyState s = DabblerEmptyState(title: 'x');
    expect(s.tone, DabblerEmptyStateTone.neutral);
    expect(s.size, DabblerEmptyStateSize.inline);
    expect(s.onRetry, isNull);
  });

  test('error defaults: page size, danger glyph, error tone', () {
    const DabblerEmptyState s = DabblerEmptyState.error(title: 'x');
    expect(s.tone, DabblerEmptyStateTone.error);
    expect(s.size, DabblerEmptyStateSize.page);
    expect(s.icon, 'danger');
    expect(s.retryLabel, 'Try again');
  });

  testWidgets('neutral well is unchanged', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(const DabblerEmptyState(icon: 'game', title: 'x')),
    );
    final BoxDecoration d = _wellDecoration(tester);
    expect(d.color, _colors.bgPrimary);
    expect(find.byType(DabblerButton), findsNothing);
  });

  testWidgets('error well uses status error surface/strong, retry fires', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      _host(
        DabblerEmptyState.error(
          title: 'Something went wrong',
          text: 'Check your connection.',
          size: DabblerEmptyStateSize.inline,
          onRetry: () => taps++,
        ),
      ),
    );
    final BoxDecoration d = _wellDecoration(tester);
    expect(d.color, _colors.error.surface);
    final DabblerIcon icon = tester.widget<DabblerIcon>(
      find.byType(DabblerIcon).first,
    );
    expect(icon.color, _colors.error.strong);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.byType(DabblerButton));
    expect(taps, 1);
  });

  testWidgets('error without onRetry draws no button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerEmptyState.error(
          title: 'x',
          size: DabblerEmptyStateSize.inline,
        ),
      ),
    );
    expect(find.byType(DabblerButton), findsNothing);
  });

  testWidgets('RTL: error page renders centred copy and retry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        DabblerEmptyState.error(
          title: 'حدث خطأ ما',
          text: 'تحقق من اتصالك وحاول مرة أخرى.',
          retryLabel: 'حاول مرة أخرى',
          size: DabblerEmptyStateSize.inline,
          onRetry: () {},
        ),
        direction: TextDirection.rtl,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('حاول مرة أخرى'), findsOneWidget);
    final Text title = tester.widget<Text>(find.text('حدث خطأ ما'));
    expect(title.textAlign, TextAlign.center);
    final double cx = tester.getCenter(find.text('حدث خطأ ما')).dx;
    expect(cx, closeTo(400, 1));
  });

  testWidgets('PNG renders LTR and RTL', (WidgetTester tester) async {
    await renderPng(
      tester,
      DabblerEmptyState.error(
        title: 'Something went wrong',
        text: 'Check your connection and try again.',
        onRetry: () {},
      ),
      name: 'empty_state_error_ltr',
      alignment: Alignment.center,
    );
    await renderPng(
      tester,
      DabblerEmptyState.error(
        title: 'حدث خطأ ما',
        text: 'تحقق من اتصالك وحاول مرة أخرى.',
        retryLabel: 'حاول مرة أخرى',
        onRetry: () {},
      ),
      name: 'empty_state_error_rtl',
      direction: TextDirection.rtl,
      alignment: Alignment.center,
    );
  });
}
