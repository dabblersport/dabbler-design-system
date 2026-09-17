import 'package:dabbler_design_system/src/cards/card.dart';
import 'package:dabbler_design_system/src/cards/empty_state.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

Widget _host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  TextDirection direction = TextDirection.ltr,
}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[
        _colors(theme: theme, brightness: brightness),
      ],
    ),
    home: Directionality(
      textDirection: direction,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: 320, child: child),
      ),
    ),
  );
}

/// The specimen at `components/cards/cards.card.html:100`, and the first
/// example of `EmptyState.prompt.md`.
const DabblerEmptyState _inline = DabblerEmptyState(
  icon: 'game',
  title: 'no games near you',
  text: 'widen the distance filter or create your own.',
);

void main() {
  group('KAN-242 AC1 — no illustration; DS-300 Icon inside DS-800 only', () {
    testWidgets('no mark is ever drawn at the illustration sizes',
        (WidgetTester tester) async {
      // The criterion is a constraint: cpo §5.2 lists elaborate hero
      // illustrations under what the app avoids. The source renders artwork at
      // 120px inline and 180px on a page; nothing here may reach either, at
      // either size, even when the caller supplies its own mark. The well is
      // the ceiling.
      for (final DabblerEmptyStateSize size in DabblerEmptyStateSize.values) {
        await tester.pumpWidget(_host(DabblerEmptyState(
          iconWidget: const SizedBox(width: 180, height: 180),
          text: 'nothing here',
          size: size,
        )));

        final Finder well = find.descendant(
          of: find.byType(DabblerEmptyState),
          matching: find.byType(Container),
        ).first;
        expect(tester.getSize(well).width, DabblerEmptyState.wellSide,
            reason: '$size');
        expect(tester.getSize(well).height, DabblerEmptyState.wellSide,
            reason: '$size');
        expect(DabblerEmptyState.wellSide, lessThan(120.0));
      }
    });

    testWidgets('the only mark drawn is a DS-300 DabblerIcon',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_inline));

      expect(find.byType(DabblerIcon), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      final DabblerIcon icon =
          tester.widget<DabblerIcon>(find.byType(DabblerIcon));
      expect(icon.name, 'game');
      expect(DabblerIconRegistry.vocabulary, contains(icon.name));
      expect(icon.size, DabblerSizing.iconMd);
    });

    testWidgets('inline composes DS-800\'s Card on the white shell',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_inline));

      expect(find.byType(DabblerCard), findsOneWidget);
      final DabblerCard card =
          tester.widget<DabblerCard>(find.byType(DabblerCard));
      // `--surface-card` with a 1px `--outline-card` hairline.
      expect(card.variant, DabblerCardVariant.white);
      expect(DabblerCard.fillOf(_colors(), card.variant),
          _colors().surfaceCard);
      expect(DabblerCard.borderOf(_colors(), card.variant),
          _colors().borderDefault);
      expect(DabblerCard.borderWidthOf(card.variant),
          DabblerSizing.borderDefault);
      // `--radius-lg` is a token in the source, so nothing is overridden.
      expect(card.radius, isNull);
      expect(DabblerCard.defaultRadius, DabblerRadius.lg);
    });

    testWidgets('page composes no card, because the source gives it no frame',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerEmptyState(
        icon: 'game',
        title: 'nothing saved yet',
        text: 'tap the heart on a game to keep it here.',
        size: DabblerEmptyStateSize.page,
      )));

      expect(find.byType(DabblerCard), findsNothing);
      expect(find.text('nothing saved yet'), findsOneWidget);
    });
  });

  group('content', () {
    testWidgets('title, copy and icon all render', (WidgetTester tester) async {
      await tester.pumpWidget(_host(_inline));

      expect(find.text('no games near you'), findsOneWidget);
      expect(find.text('widen the distance filter or create your own.'),
          findsOneWidget);
    });

    testWidgets('a title-less, icon-less state is still a state',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerEmptyState(
        text: "Aisha's posts are visible to followers.",
      )));

      expect(find.byType(DabblerIcon), findsNothing);
      expect(find.text("Aisha's posts are visible to followers."),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('one action at most, and it renders', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerEmptyState(
        icon: 'game',
        title: 'nothing saved yet',
        text: 'tap the heart on a game to keep it here.',
        size: DabblerEmptyStateSize.page,
        action: Text('find a game'),
      )));

      expect(find.text('find a game'), findsOneWidget);
    });

    testWidgets('everything is centred — no mirroring is needed under RTL',
        (WidgetTester tester) async {
      for (final TextDirection direction in TextDirection.values) {
        await tester.pumpWidget(_host(_inline, direction: direction));

        final Text title =
            tester.widget<Text>(find.text('no games near you'));
        expect(title.textAlign, TextAlign.center, reason: '$direction');
        final Column column = tester.widget<Column>(
          find.descendant(
            of: find.byType(DabblerEmptyState),
            matching: find.byType(Column),
          ).first,
        );
        expect(column.crossAxisAlignment, CrossAxisAlignment.center);
      }
    });
  });

  group('the icon well', () {
    testWidgets('is 45×45 at --radius-md with a --faint hairline',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_inline));

      final Finder well = find.descendant(
        of: find.byType(DabblerEmptyState),
        matching: find.byType(Container),
      ).first;
      final BoxDecoration decoration =
          tester.widget<Container>(well).decoration! as BoxDecoration;

      // `--surface-page` fill, 1px `--faint`, `--subtle` ink.
      expect(decoration.color, _colors().bgPrimary);
      expect(decoration.borderRadius,
          const BorderRadius.all(Radius.circular(DabblerRadius.md)));
      expect(
        (decoration.border! as Border).top.color,
        _colors().bgTertiary,
      );
      expect((decoration.border! as Border).top.width,
          DabblerSizing.borderDefault);
      expect(tester.getSize(well),
          const Size(DabblerEmptyState.wellSide, DabblerEmptyState.wellSide));

      final DabblerIcon icon =
          tester.widget<DabblerIcon>(find.byType(DabblerIcon));
      expect(icon.color, _colors().textTertiary);
    });

    testWidgets('a supplied widget sits in the same well, not instead of it',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerEmptyState(
        iconWidget: SizedBox.shrink(key: ValueKey<String>('custom')),
        text: 'nothing here',
      )));

      expect(find.byKey(const ValueKey<String>('custom')), findsOneWidget);
      expect(find.byType(DabblerIcon), findsNothing);
      final Finder well = find.descendant(
        of: find.byType(DabblerEmptyState),
        matching: find.byType(Container),
      ).first;
      expect(tester.getSize(well),
          const Size(DabblerEmptyState.wellSide, DabblerEmptyState.wellSide));
    });
  });

  group('type and spacing per size', () {
    testWidgets('inline\'s title is .t-body metrics at Semibold',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_inline));

      final TextStyle style =
          tester.widget<Text>(find.text('no games near you')).style!;
      expect(style.fontSize, DabblerType.body.fontSize);
      expect(style.fontWeight, DabblerType.semibold);
      expect(style.color, _colors().textPrimary);
    });

    testWidgets('page\'s title is .t-title-3, the class the source names',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerEmptyState(
        title: 'nothing saved yet',
        size: DabblerEmptyStateSize.page,
      )));

      final TextStyle style =
          tester.widget<Text>(find.text('nothing saved yet')).style!;
      expect(style.fontSize, DabblerType.title3.fontSize);
      expect(style.fontWeight, DabblerType.title3.fontWeight);
    });

    testWidgets('the copy is .t-footnote on --muted at both sizes',
        (WidgetTester tester) async {
      for (final DabblerEmptyStateSize size in DabblerEmptyStateSize.values) {
        await tester.pumpWidget(_host(DabblerEmptyState(
          text: 'widen the distance filter or create your own.',
          size: size,
        )));

        final TextStyle style = tester
            .widget<Text>(
                find.text('widen the distance filter or create your own.'))
            .style!;
        expect(style.fontSize, DabblerType.footnote.fontSize, reason: '$size');
        expect(style.color, _colors().textSecondary, reason: '$size');
      }
    });

    test('the padding of each size is the source\'s, in grid steps', () {
      // inline `'30px 12px'`, page `var(--space-10) var(--space-6)`.
      expect(DabblerEmptyState.inlinePadding,
          const EdgeInsetsDirectional.symmetric(vertical: 30, horizontal: 12));
      expect(DabblerEmptyState.pagePadding,
          const EdgeInsetsDirectional.symmetric(vertical: 36, horizontal: 18));
      expect(DabblerSpacing.scale, containsAll(<double>[30, 12, 36, 18]));
      expect(DabblerEmptyState.gap, DabblerSpacing.stackDefault);
      expect(DabblerEmptyState.actionGap, DabblerSpacing.stackTight);
    });

    testWidgets('page caps its copy at 320 and clears 60% of the viewport',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerEmptyState(
        title: 'nothing saved yet',
        text: 'tap the heart on a game to keep it here.',
        size: DabblerEmptyStateSize.page,
      )));

      final double viewport =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(
        tester.getSize(find.byType(DabblerEmptyState)).height,
        greaterThanOrEqualTo(
          viewport * DabblerEmptyState.pageMinHeightFraction,
        ),
      );
      expect(DabblerEmptyState.pageTextMaxWidth, 320);
    });
  });

  testWidgets('it renders in every theme and both brightnesses',
      (WidgetTester tester) async {
    for (final DabblerTheme theme in DabblerTheme.values) {
      for (final Brightness brightness in Brightness.values) {
        for (final DabblerEmptyStateSize size
            in DabblerEmptyStateSize.values) {
          await tester.pumpWidget(_host(
            DabblerEmptyState(
              icon: 'game',
              title: 'no games near you',
              text: 'widen the distance filter.',
              size: size,
            ),
            theme: theme,
            brightness: brightness,
          ));
          expect(tester.takeException(), isNull,
              reason: '$theme / $brightness / $size');
        }
      }
    }
  });
}
