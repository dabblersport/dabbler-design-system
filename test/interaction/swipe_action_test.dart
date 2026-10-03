import 'package:dabbler_design_system/src/interaction/swipe_action.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    MaterialApp(
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          DabblerColors.resolve(
            theme: DabblerTheme.main,
            brightness: Brightness.light,
          ),
        ],
      ),
      home: Directionality(
        textDirection: direction,
        child: Scaffold(body: child),
      ),
    );

Widget _list(List<String> fired) => ListView(
  children: <Widget>[
    for (int i = 0; i < 3; i++)
      DabblerSwipeAction(
        key: ValueKey<int>(i),
        actions: <DabblerSwipeActionItem>[
          DabblerSwipeActionItem(
            label: 'Hide',
            icon: 'eye-slash',
            tone: DabblerSwipeActionTone.destructive,
            onPressed: () => fired.add('hide$i'),
          ),
        ],
        child: SizedBox(height: 60, child: Text('row $i')),
      ),
  ],
);

DabblerSwipeActionState _state(WidgetTester t, int i) =>
    t.state<DabblerSwipeActionState>(find.byKey(ValueKey<int>(i)));

void main() {
  testWidgets('LTR: swipe left reveals, tap fires and closes', (t) async {
    final List<String> fired = <String>[];
    await t.pumpWidget(_host(_list(fired)));
    await t.drag(find.text('row 0'), const Offset(-100, 0));
    await t.pumpAndSettle();
    expect(_state(t, 0).isOpen, isTrue);
    final Rect box = t.getRect(find.text('Hide').first);
    expect(box.center.dx, greaterThan(400)); // inline end = right
    final Size hit = t.getSize(
      find
          .ancestor(
            of: find.text('Hide').first,
            matching: find.byType(ConstrainedBox),
          )
          .first,
    );
    expect(hit.width, greaterThanOrEqualTo(45));
    expect(hit.height, greaterThanOrEqualTo(45));
    await t.tap(find.text('Hide').first);
    await t.pumpAndSettle();
    expect(fired, <String>['hide0']);
    expect(_state(t, 0).isOpen, isFalse);
  });

  testWidgets('LTR: swipe right does not open', (t) async {
    await t.pumpWidget(_host(_list(<String>[])));
    await t.drag(find.text('row 1'), const Offset(100, 0));
    await t.pumpAndSettle();
    expect(_state(t, 1).isOpen, isFalse);
  });

  testWidgets('RTL: mirrored — swipe right reveals on the left', (t) async {
    final List<String> fired = <String>[];
    await t.pumpWidget(_host(_list(fired), direction: TextDirection.rtl));
    await t.drag(find.text('row 0'), const Offset(-100, 0));
    await t.pumpAndSettle();
    expect(_state(t, 0).isOpen, isFalse);
    await t.drag(find.text('row 0'), const Offset(100, 0));
    await t.pumpAndSettle();
    expect(_state(t, 0).isOpen, isTrue);
    expect(t.getRect(find.text('Hide').first).center.dx, lessThan(400));
  });

  testWidgets('tap on open row closes without firing', (t) async {
    final List<String> fired = <String>[];
    await t.pumpWidget(_host(_list(fired)));
    await t.drag(find.text('row 2'), const Offset(-100, 0));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey<int>(2)));
    await t.pumpAndSettle();
    expect(_state(t, 2).isOpen, isFalse);
    expect(fired, isEmpty);
  });

  testWidgets('vertical drag still scrolls the list', (t) async {
    await t.pumpWidget(
      _host(
        ListView(
          children: <Widget>[
            for (int i = 0; i < 30; i++)
              DabblerSwipeAction(
                actions: <DabblerSwipeActionItem>[
                  DabblerSwipeActionItem(label: 'Hide', onPressed: () {}),
                ],
                child: SizedBox(height: 60, child: Text('r$i')),
              ),
          ],
        ),
      ),
    );
    await t.drag(find.text('r3'), const Offset(0, -300));
    await t.pumpAndSettle();
    expect(find.text('r0'), findsNothing);
  });

  testWidgets('semantics custom action fires without a gesture', (t) async {
    final SemanticsHandle handle = t.ensureSemantics();
    final List<String> fired = <String>[];
    await t.pumpWidget(_host(_list(fired)));
    final SemanticsNode node = t.getSemantics(
      find.byKey(const ValueKey<int>(0)),
    );
    final int id = CustomSemanticsAction.getIdentifier(
      const CustomSemanticsAction(label: 'Hide'),
    );
    node.owner!.performAction(node.id, SemanticsAction.customAction, id);
    await t.pumpAndSettle();
    expect(fired, <String>['hide0']);
    handle.dispose();
  });

  group('DabblerAvatarGroup imageUrls', () {
    Future<List<Rect>> rects(WidgetTester t, Widget g, TextDirection d) async {
      await t.pumpWidget(_host(Center(child: g), direction: d));
      return t
          .widgetList<DabblerAvatar>(find.byType(DabblerAvatar))
          .map((DabblerAvatar a) => t.getRect(find.byWidget(a)))
          .toList();
    }

    for (final TextDirection d in TextDirection.values) {
      testWidgets('geometry unchanged with imageUrls ($d)', (t) async {
        const List<String> people = <String>['A', 'B', 'C'];
        final List<Rect> plain = await rects(
          t,
          const DabblerAvatarGroup(people: people, overflow: 4),
          d,
        );
        final Size plainSize = t.getSize(find.byType(DabblerAvatarGroup));
        final List<Rect> withUrls = await rects(
          t,
          const DabblerAvatarGroup(
            people: people,
            overflow: 4,
            imageUrls: <String?>['https://invalid.example/a.png', null],
          ),
          d,
        );
        expect(withUrls, plain);
        expect(t.getSize(find.byType(DabblerAvatarGroup)), plainSize);
        expect(find.text('+4'), findsOneWidget);
        final List<DabblerAvatar> avatars = t
            .widgetList<DabblerAvatar>(find.byType(DabblerAvatar))
            .toList();
        expect(avatars.map((DabblerAvatar a) => a.imageUrl).toSet(), <String?>{
          'https://invalid.example/a.png',
          null,
        });
        // First person stays at the inline start.
        final DabblerAvatar first = avatars.firstWhere(
          (DabblerAvatar a) => a.seed == 'A',
        );
        expect(first.imageUrl, 'https://invalid.example/a.png');
        final double firstX = t.getRect(find.byWidget(first)).center.dx;
        final double others = t
            .getRect(find.byWidget(avatars.firstWhere((a) => a.seed == 'C')))
            .center
            .dx;
        expect(
          d == TextDirection.ltr ? firstX < others : firstX > others,
          isTrue,
        );
      });
    }
  });
}
