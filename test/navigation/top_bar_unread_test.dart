import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/navigation/top_bar.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-409 item 2 — the 9px unread dot on a top-bar action.

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(
  List<DabblerNavigationAction> actions, {
  TextDirection direction = TextDirection.ltr,
}) => MediaQuery(
  data: const MediaQueryData(disableAnimations: true),
  child: Directionality(
    textDirection: direction,
    child: Theme(
      data: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 390,
          child: DabblerNavigationTopBar(actions: actions, safeArea: false),
        ),
      ),
    ),
  ),
);

const DabblerNavigationAction _bell = DabblerNavigationAction(
  icon: 'notification-bing',
  label: 'Notifications',
  unread: true,
  unreadLabel: 'unread',
);

void main() {
  setUp(() => DabblerAvatar.portrait = const DabblerPlaceholderPortrait());
  tearDown(() => DabblerAvatar.portrait = const DabblerRandomAvatarPortrait());

  testWidgets('no dot unless unread', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(const <DabblerNavigationAction>[
        DabblerNavigationAction(icon: 'notification-bing', label: 'N'),
      ]),
    );
    expect(find.byKey(DabblerNavigationUnreadDot.dotKey), findsNothing);
  });

  testWidgets('dot is 9px fill + 2px border, brand on surface-page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const <DabblerNavigationAction>[_bell]));
    final Finder dot = find.byKey(DabblerNavigationUnreadDot.dotKey);
    expect(dot, findsOneWidget);
    expect(tester.getSize(dot), const Size.square(13));
    final BoxDecoration deco =
        tester.widget<Container>(dot).decoration! as BoxDecoration;
    expect(deco.color, _colors.brandPrimary);
    expect((deco.border! as Border).top.color, _colors.bgPrimary);
    expect((deco.border! as Border).top.width, 2);
  });

  testWidgets('dot sits on the glyph top-end corner and mirrors in RTL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const <DabblerNavigationAction>[_bell]));
    Rect glyph = tester.getRect(find.byType(DabblerIcon));
    Rect dot = tester.getRect(find.byKey(DabblerNavigationUnreadDot.dotKey));
    expect(dot.right, closeTo(glyph.right + 1.5, 0.01));
    expect(dot.top, closeTo(glyph.top - 1.5, 0.01));

    await tester.pumpWidget(
      _host(const <DabblerNavigationAction>[
        _bell,
      ], direction: TextDirection.rtl),
    );
    glyph = tester.getRect(find.byType(DabblerIcon));
    dot = tester.getRect(find.byKey(DabblerNavigationUnreadDot.dotKey));
    expect(dot.left, closeTo(glyph.left - 1.5, 0.01));
    expect(dot.top, closeTo(glyph.top - 1.5, 0.01));
  });

  testWidgets('semantics label carries the unread label', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const <DabblerNavigationAction>[_bell]));
    expect(find.bySemanticsLabel('Notifications, unread'), findsOneWidget);
    handle.dispose();
  });

  test('equality includes unread fields', () {
    expect(
      _bell ==
          const DabblerNavigationAction(
            icon: 'notification-bing',
            label: 'Notifications',
          ),
      isFalse,
    );
  });
}
