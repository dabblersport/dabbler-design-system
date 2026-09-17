import 'package:dabbler_design_system/src/layout/section.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The width every section under test is laid out in, so edge assertions have
/// a fixed frame to compare against.
const double hostWidth = 320;

DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

/// The minimum a section needs: a [ThemeData] carrying [DabblerColors], a
/// direction, and a bounded width.
Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[_colors(brightness: brightness)],
    ),
    home: Directionality(
      textDirection: direction,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: hostWidth, child: child),
      ),
    ),
  );
}

/// A child with a stable identity and a known height, so gaps between children
/// can be measured from geometry rather than inferred from widget order.
Widget _child(String label) =>
    SizedBox(key: ValueKey<String>(label), height: 20);

/// The heights of every [SizedBox] that DabblerSection itself inserted as a
/// gap — i.e. the spacers, which have a height and no width and no key.
List<double> _gapHeights(WidgetTester tester) {
  return tester
      .widgetList<SizedBox>(
        find.descendant(
          of: find.byType(DabblerSection),
          matching: find.byType(SizedBox),
        ),
      )
      .where((SizedBox b) => b.key == null && b.height != null && b.width == null)
      .map((SizedBox b) => b.height!)
      .toList();
}

Rect _rectOf(WidgetTester tester, Finder finder) =>
    tester.getRect(finder.first);

void main() {
  group('DabblerSection geometry uses DS-104 tokens', () {
    testWidgets('header -> children gap is stackDefault', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerSection(
            title: 'Upcoming games',
            children: <Widget>[_child('a')],
          ),
        ),
      );
      expect(_gapHeights(tester), <double>[DabblerSpacing.stackDefault]);
      expect(DabblerSpacing.stackDefault, DabblerSpacing.space4);
    });

    testWidgets('header -> subtitle gap is stackTight', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerSection(
            title: 'Upcoming games',
            subtitle: 'only friends can join',
          ),
        ),
      );
      expect(_gapHeights(tester), <double>[DabblerSpacing.stackTight]);
      expect(DabblerSpacing.stackTight, DabblerSpacing.space2);
    });

    testWidgets('child -> child gaps are stackDefault', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerSection(
            children: <Widget>[_child('a'), _child('b'), _child('c')],
          ),
        ),
      );
      // No header, so no header gap: exactly two inter-child gaps.
      expect(_gapHeights(tester), <double>[
        DabblerSpacing.stackDefault,
        DabblerSpacing.stackDefault,
      ]);

      // And the rendered distance matches, not just the declared spacer.
      final Rect a = _rectOf(tester, find.byKey(const ValueKey<String>('a')));
      final Rect b = _rectOf(tester, find.byKey(const ValueKey<String>('b')));
      expect(b.top - a.bottom, DabblerSpacing.stackDefault);
    });

    testWidgets('title -> action gap is stackDefault', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerSection(
            title: 'Upcoming games',
            action: SizedBox(
              key: const ValueKey<String>('action'),
              width: 60,
              height: 20,
            ),
          ),
        ),
      );
      expect(_gapHeights(tester), isEmpty);
      final Iterable<SizedBox> spacers = tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(DabblerSection),
              matching: find.byType(SizedBox),
            ),
          )
          .where((SizedBox b) => b.key == null && b.width != null);
      expect(
        spacers.map((SizedBox b) => b.width),
        contains(DabblerSpacing.stackDefault),
      );
    });

    testWidgets('a subtitle alone does not open the header gap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerSection(
            subtitle: 'only friends can join',
            children: <Widget>[_child('a')],
          ),
        ),
      );
      // Section.jsx:31 — the children margin is `hasHeader && items.length`.
      expect(_gapHeights(tester), isEmpty);
    });

    testWidgets('a section adds no padding of its own', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerSection(
            title: 'Upcoming games',
            children: <Widget>[_child('a')],
          ),
        ),
      );
      // No screenGutter, no sectionGap, no cardPadding: the child spans the
      // whole width the section was given.
      expect(
        _rectOf(tester, find.byKey(const ValueKey<String>('a'))).width,
        hostWidth,
      );
      expect(
        find
            .descendant(
              of: find.byType(DabblerSection),
              matching: find.byType(Padding),
            )
            .evaluate(),
        isEmpty,
      );
    });
  });

  group('DabblerSection type and colour come from the tokens', () {
    testWidgets('title is title3 at --weight-light, subtitle footnote at '
        'textSecondary', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerSection(
            title: 'Upcoming games',
            subtitle: 'only friends can join',
          ),
        ),
      );
      final DabblerColors colors = _colors();
      final TextStyle title =
          tester.widget<Text>(find.text('Upcoming games')).style!;
      expect(title.fontSize, DabblerType.title3.fontSize);
      expect(title.height! * title.fontSize!, DabblerType.title3.latinLeading);
      // `fontWeight: 300` (`Section.jsx:19-20`) — `--weight-light`, NOT
      // `.t-title-3`'s own regular default. This test previously asserted
      // regular, which is what left the section heading a full step heavier
      // than the specimen draws it — the single most visible thing about a
      // Section.
      expect(title.fontWeight, DabblerType.light);
      expect(title.color, colors.textPrimary);

      final TextStyle subtitle =
          tester.widget<Text>(find.text('only friends can join')).style!;
      expect(subtitle.fontSize, DabblerType.footnote.fontSize);
      expect(subtitle.color, colors.textSecondary);
    });

    testWidgets('the Arabic face is selected under RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerSection(title: 'الألعاب القادمة'),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        tester.widget<Text>(find.text('الألعاب القادمة')).style!.fontFamily,
        DabblerType.fontFamilyFor(
          DabblerTypeRole.display,
          DabblerTypeScript.arabic,
        ),
      );
    });
  });

  group('DabblerSection is RTL-correct', () {
    /// Lays out a header and returns (title rect, action rect) in [direction].
    Future<(Rect, Rect)> header(
      WidgetTester tester,
      TextDirection direction,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerSection(
            title: 'Upcoming games',
            action: SizedBox(
              key: const ValueKey<String>('action'),
              width: 60,
              height: 20,
            ),
          ),
          direction: direction,
        ),
      );
      return (
        _rectOf(tester, find.text('Upcoming games')),
        _rectOf(tester, find.byKey(const ValueKey<String>('action'))),
      );
    }

    testWidgets('LTR: title leads on the left, action trails on the right', (
      WidgetTester tester,
    ) async {
      final (Rect title, Rect action) =
          await header(tester, TextDirection.ltr);
      final Rect section = _rectOf(tester, find.byType(DabblerSection));
      expect(title.left, section.left);
      expect(action.right, section.right);
      expect(title.right, lessThanOrEqualTo(action.left));
    });

    testWidgets('RTL: title leads on the right, action trails on the left', (
      WidgetTester tester,
    ) async {
      final (Rect title, Rect action) =
          await header(tester, TextDirection.rtl);
      final Rect section = _rectOf(tester, find.byType(DabblerSection));
      expect(title.right, section.right);
      expect(action.left, section.left);
      expect(action.right, lessThanOrEqualTo(title.left));
    });

    testWidgets('an action with no title still trails in both directions', (
      WidgetTester tester,
    ) async {
      for (final TextDirection direction in TextDirection.values) {
        await tester.pumpWidget(
          _host(
            DabblerSection(
              action: SizedBox(
                key: const ValueKey<String>('action'),
                width: 60,
                height: 20,
              ),
            ),
            direction: direction,
          ),
        );
        final Rect section = _rectOf(tester, find.byType(DabblerSection));
        final Rect action =
            _rectOf(tester, find.byKey(const ValueKey<String>('action')));
        expect(
          direction == TextDirection.ltr ? action.right : action.left,
          direction == TextDirection.ltr ? section.right : section.left,
          reason: 'action must sit on the trailing edge in $direction',
        );
      }
    });

    testWidgets('the subtitle starts at the leading edge in both directions', (
      WidgetTester tester,
    ) async {
      for (final TextDirection direction in TextDirection.values) {
        await tester.pumpWidget(
          _host(
            const DabblerSection(
              title: 'Upcoming games',
              subtitle: 'only friends can join',
            ),
            direction: direction,
          ),
        );
        final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
          find.text('only friends can join'),
        );
        expect(paragraph.textDirection, direction);
      }
    });
  });
}
