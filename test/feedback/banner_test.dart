import 'package:dabbler_design_system/src/feedback/banner.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// The resolved tokens the banner is checked against, for [theme] at
/// [brightness].
DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

/// Wraps a banner in the minimum it needs: a [ThemeData] carrying the
/// [DabblerColors] extension, and a direction.
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

BoxDecoration _shell(WidgetTester tester) {
  final Container container = tester.widget<Container>(
    find
        .ancestor(
          of: find.byType(Row),
          matching: find.byType(Container),
        )
        .first,
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  group('AC1 — status tones, no literal colours', () {
    // Every status tone paints its own surface, its own strong ink and a
    // hairline of that strong colour at 20% — statusTones / statusHairline,
    // components/foundations/overlay.jsx:160-173.
    for (final DabblerBannerTone tone in <DabblerBannerTone>[
      DabblerBannerTone.success,
      DabblerBannerTone.warning,
      DabblerBannerTone.error,
      DabblerBannerTone.info,
    ]) {
      testWidgets('${tone.name} uses surface, strong and a 20% hairline',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(
            DabblerBanner(tone: tone, title: 'title', message: 'message'),
          ),
        );

        final DabblerStatusColor expected =
            _colors().status(tone.status!);
        final BoxDecoration decoration = _shell(tester);

        expect(decoration.color, expected.surface);
        expect(
          (decoration.border! as Border).top.color,
          expected.strong.withValues(alpha: 0.20),
        );

        for (final String text in <String>['title', 'message']) {
          expect(
            tester.widget<Text>(find.text(text)).style!.color,
            expected.strong,
            reason: '$text must use the tone strong ink, never a secondary '
                'text colour (Banner.prompt.md, "Contrast")',
          );
        }
      });
    }

    testWidgets('neutral uses the card roles, not a status triple',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerBanner(
            tone: DabblerBannerTone.neutral,
            title: 'profile is private',
          ),
        ),
      );

      final DabblerColors colors = _colors();
      final BoxDecoration decoration = _shell(tester);

      expect(DabblerBannerTone.neutral.status, isNull);
      expect(decoration.color, colors.surfaceCard);
      expect((decoration.border! as Border).top.color, colors.borderDefault);
      expect(
        tester.widget<Text>(find.text('profile is private')).style!.color,
        colors.textPrimary,
      );
    });

    testWidgets('the tone follows the theme it is resolved in',
        (WidgetTester tester) async {
      // The sport theme overrides success; the banner must not cache a colour.
      await tester.pumpWidget(
        _host(
          const DabblerBanner(
            tone: DabblerBannerTone.success,
            title: 'booking confirmed',
          ),
          theme: DabblerTheme.sport,
          brightness: Brightness.dark,
        ),
      );

      final DabblerStatusColor expected = _colors(
        theme: DabblerTheme.sport,
        brightness: Brightness.dark,
      ).status(DabblerStatusTone.success);

      expect(_shell(tester).color, expected.surface);
      expect(
        tester.widget<Text>(find.text('booking confirmed')).style!.color,
        expected.strong,
      );
    });

    testWidgets('the shell is flat — no shadow, no gradient',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerBanner(title: 'new season starting')),
      );
      final BoxDecoration decoration = _shell(tester);
      expect(decoration.boxShadow, anyOf(isNull, isEmpty));
      expect(decoration.gradient, isNull);
      expect(
        decoration.borderRadius,
        DabblerRadius.lgAll,
        reason: '--radius-lg, Banner.prompt.md "Visual"',
      );
    });
  });

  group('AC2 — the dismiss target measures at least 44×44', () {
    testWidgets('the rendered box is touchTargetMin square',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          DabblerBanner(
            tone: DabblerBannerTone.error,
            title: 'game cancelled',
            onDismiss: () {},
          ),
        ),
      );

      final Size size = tester.getSize(find.byKey(DabblerBanner.dismissTargetKey));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(size, const Size(DabblerSizing.touchTargetMin,
          DabblerSizing.touchTargetMin));
    });

    testWidgets('the whole box is live, not just the glyph',
        (WidgetTester tester) async {
      int dismissed = 0;
      await tester.pumpWidget(
        _host(
          DabblerBanner(
            title: 'game cancelled',
            onDismiss: () => dismissed++,
          ),
        ),
      );

      final Rect box =
          tester.getRect(find.byKey(DabblerBanner.dismissTargetKey));
      // The four corners, inset half a logical pixel so they land inside.
      for (final Offset corner in <Offset>[
        box.topLeft + const Offset(0.5, 0.5),
        box.topRight + const Offset(-0.5, 0.5),
        box.bottomLeft + const Offset(0.5, -0.5),
        box.bottomRight + const Offset(-0.5, -0.5),
      ]) {
        await tester.tapAt(corner);
        await tester.pump();
      }
      expect(dismissed, 4,
          reason: 'every corner of the 45×45 target must dispatch the tap');
    });

    testWidgets('no dismiss button without onDismiss',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const DabblerBanner(title: 'new season starting')),
      );
      expect(find.byKey(DabblerBanner.dismissTargetKey), findsNothing);
    });

    testWidgets('the action button also clears the floor',
        (WidgetTester tester) async {
      int pressed = 0;
      await tester.pumpWidget(
        _host(
          DabblerBanner(
            tone: DabblerBannerTone.warning,
            title: 'verification needed',
            message: 'add a phone number before you can host games.',
            action: DabblerBannerAction(
              label: 'verify now',
              onPressed: () => pressed++,
            ),
          ),
        ),
      );

      final Size size = tester.getSize(find.byKey(DabblerBanner.actionTargetKey));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(size.height, DabblerSizing.touchTargetMin);

      await tester.tap(find.byKey(DabblerBanner.actionTargetKey));
      expect(pressed, 1);
    });
  });

  group('structure and semantics', () {
    testWidgets('error and warning are live regions; the others are not',
        (WidgetTester tester) async {
      for (final DabblerBannerTone tone in DabblerBannerTone.values) {
        await tester.pumpWidget(
          _host(DabblerBanner(tone: tone, title: 'title')),
        );
        final SemanticsNode node =
            tester.getSemantics(find.byType(DabblerBanner));
        expect(
          node.getSemanticsData().flagsCollection.isLiveRegion,
          tone.interrupts,
          reason: '${tone.name}: role="alert" only for error and warning',
        );
      }
    });

    testWidgets('the dismiss button is a named button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(DabblerBanner(title: 'title', onDismiss: () {})),
      );
      expect(
        find.bySemanticsLabel(DabblerBanner.defaultDismissSemanticLabel),
        findsOneWidget,
      );
    });

    testWidgets('the default tone is info', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerBanner(title: 'title')));
      expect(
        _shell(tester).color,
        _colors().status(DabblerStatusTone.info).surface,
      );
    });

    testWidgets('the leading glyph sits in a 24×24 slot',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerBanner(
            title: 'title',
            icon: Icon(Icons.info_outline),
          ),
        ),
      );
      expect(
        tester.getSize(find.ancestor(
          of: find.byIcon(Icons.info_outline),
          matching: find.byType(SizedBox),
        ).first),
        const Size(DabblerSizing.iconMd, DabblerSizing.iconMd),
      );
    });

    testWidgets('RTL puts the dismiss button at the inline end',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          DabblerBanner(title: 'title', onDismiss: () {}),
          direction: TextDirection.rtl,
        ),
      );
      final Rect dismiss =
          tester.getRect(find.byKey(DabblerBanner.dismissTargetKey));
      final Rect text = tester.getRect(find.text('title'));
      expect(dismiss.right, lessThan(text.left),
          reason: 'in RTL the inline end is the left edge');
    });
  });
}
