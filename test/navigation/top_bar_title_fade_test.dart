import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(
  Widget child, {
  TextDirection dir = TextDirection.ltr,
  bool reduceMotion = false,
}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduceMotion),
  child: Directionality(
    textDirection: dir,
    child: Theme(
      data: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          DabblerColors.resolve(
            theme: DabblerTheme.main,
            brightness: Brightness.light,
          ),
        ],
      ),
      child: child,
    ),
  ),
);

Widget _page(ScrollController c, {bool reduceMotion = false}) => _host(
  Column(
    children: <Widget>[
      DabblerNavigationTopBar.titled(
        title: 'Lina',
        onBack: () {},
        safeArea: false,
        scrollController: c,
      ),
      Expanded(
        child: ListView(
          controller: c,
          children: <Widget>[const SizedBox(height: 3000)],
        ),
      ),
    ],
  ),
  reduceMotion: reduceMotion,
);

double _titleOpacity(WidgetTester t) => t
    .widget<AnimatedOpacity>(
      find.ancestor(
        of: find.text('Lina'),
        matching: find.byType(AnimatedOpacity),
      ),
    )
    .opacity;

void main() {
  group('DabblerNavigationTopBar.titled — empty title stays titled', () {
    for (final TextDirection d in TextDirection.values) {
      testWidgets("title: '' draws back, no wordmark (${d.name})", (
        WidgetTester t,
      ) async {
        await t.pumpWidget(
          _host(
            const DabblerNavigationTopBar.titled(title: '', safeArea: false),
            dir: d,
          ),
        );
        expect(find.byType(DabblerWordmark), findsNothing);
      });
    }

    testWidgets('title null and no onBack is still titled', (
      WidgetTester t,
    ) async {
      const DabblerNavigationTopBar bar = DabblerNavigationTopBar.titled(
        safeArea: false,
      );
      expect(bar.isTitled, isTrue);
      await t.pumpWidget(_host(bar));
      expect(find.byType(DabblerWordmark), findsNothing);
    });

    testWidgets("title: '' with onBack shows the back button", (
      WidgetTester t,
    ) async {
      final SemanticsHandle h = t.ensureSemantics();
      await t.pumpWidget(
        _host(
          DabblerNavigationTopBar.titled(
            title: '',
            onBack: () {},
            safeArea: false,
          ),
        ),
      );
      expect(find.byType(DabblerWordmark), findsNothing);
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      h.dispose();
    });

    testWidgets('the plain bar is still the wordmark bar', (
      WidgetTester t,
    ) async {
      const DabblerNavigationTopBar bar = DabblerNavigationTopBar(
        safeArea: false,
      );
      expect(bar.isTitled, isFalse);
      await t.pumpWidget(_host(bar));
      expect(find.byType(DabblerWordmark), findsOneWidget);
    });
  });

  group('DabblerNavigationTopBar.titled — scroll-fade title', () {
    testWidgets('titleOpacity fades the title directly', (
      WidgetTester t,
    ) async {
      await t.pumpWidget(
        _host(
          const DabblerNavigationTopBar.titled(
            title: 'Lina',
            titleOpacity: 0.4,
            safeArea: false,
          ),
        ),
      );
      final Opacity o = t.widget<Opacity>(
        find.ancestor(of: find.text('Lina'), matching: find.byType(Opacity)),
      );
      expect(o.opacity, 0.4);
    });

    testWidgets('default titleOpacity paints the title unwrapped', (
      WidgetTester t,
    ) async {
      await t.pumpWidget(
        _host(
          const DabblerNavigationTopBar.titled(title: 'Lina', safeArea: false),
        ),
      );
      expect(
        find.ancestor(of: find.text('Lina'), matching: find.byType(Opacity)),
        findsNothing,
      );
    });

    for (final TextDirection d in TextDirection.values) {
      testWidgets('hidden at rest, revealed past the offset (${d.name})', (
        WidgetTester t,
      ) async {
        final ScrollController c = ScrollController();
        addTearDown(c.dispose);
        await t.pumpWidget(Directionality(textDirection: d, child: _page(c)));
        expect(_titleOpacity(t), 0);

        c.jumpTo(DabblerNavigationTopBar.defaultTitleRevealOffset + 1);
        await t.pump();
        expect(_titleOpacity(t), 1);
        await t.pumpAndSettle();

        c.jumpTo(0);
        await t.pump();
        expect(_titleOpacity(t), 0);
      });
    }

    testWidgets('animates over base; immediate under reduced motion', (
      WidgetTester t,
    ) async {
      final ScrollController c = ScrollController();
      addTearDown(c.dispose);
      await t.pumpWidget(_page(c));
      AnimatedOpacity a = t.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.text('Lina'),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(a.duration, DabblerMotion.base);

      await t.pumpWidget(_page(c, reduceMotion: true));
      a = t.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.text('Lina'),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(a.duration, Duration.zero);
    });

    testWidgets('the title stays a header in semantics while hidden', (
      WidgetTester t,
    ) async {
      final SemanticsHandle h = t.ensureSemantics();
      final ScrollController c = ScrollController();
      addTearDown(c.dispose);
      await t.pumpWidget(_page(c));
      expect(
        t.getSemantics(find.text('Lina')),
        matchesSemantics(label: 'Lina', isHeader: true),
      );
      h.dispose();
    });
  });
}
