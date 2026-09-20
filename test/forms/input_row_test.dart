import 'dart:io';

import 'package:dabbler_design_system/src/forms/input_row.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/interaction/press_scale.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_motion.dart';
import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// The width every row under test is laid out in.
const double hostWidth = 400;

DabblerColors _colors({Brightness brightness = Brightness.light}) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: brightness);

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

DabblerSurface _surface(WidgetTester tester) => tester.widget<DabblerSurface>(
      find
          .descendant(
            of: find.byType(DabblerInputRow),
            matching: find.byType(DabblerSurface),
          )
          .first,
    );

void main() {
  group('KAN-248 AC1 — a horizontal composition helper for form fields', () {
    testWidgets('lays leading, text column and trailing out in one row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerInputRow(
            leading: SizedBox(key: ValueKey<String>('lead'), width: 24, height: 24),
            title: 'my friends',
            subtitle: 'only friends can join',
            trailing: SizedBox(
              key: ValueKey<String>('trail'),
              width: 24,
              height: 24,
            ),
          ),
        ),
      );

      final Rect lead = tester.getRect(find.byKey(const ValueKey<String>('lead')));
      final Rect title = tester.getRect(find.text('my friends'));
      final Rect trail =
          tester.getRect(find.byKey(const ValueKey<String>('trail')));

      expect(lead.right, lessThanOrEqualTo(title.left));
      expect(title.right, lessThanOrEqualTo(trail.left));
      expect(find.text('only friends can join'), findsOneWidget);
    });

    testWidgets('a subtitle-less row renders one line only', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerInputRow(title: 'pinned link')),
      );
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('every slot is optional', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerInputRow()));
      expect(find.byType(Text), findsNothing);
      expect(find.byType(DabblerInputRow), findsOneWidget);
    });

    testWidgets('the gap between slots is --space-4 (12)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerInputRow(
            leading: SizedBox(key: ValueKey<String>('lead'), width: 24, height: 24),
            title: 'x',
            trailing: SizedBox(
              key: ValueKey<String>('trail'),
              width: 24,
              height: 24,
            ),
          ),
        ),
      );
      final Rect lead = tester.getRect(find.byKey(const ValueKey<String>('lead')));
      final Rect title = tester.getRect(find.text('x'));
      final Rect trail =
          tester.getRect(find.byKey(const ValueKey<String>('trail')));

      expect(title.left - lead.right, DabblerSpacing.stackDefault);
      expect(DabblerInputRow.slotGap, 12);
      // The text column is Expanded, so the trailing gap is measured off the
      // column's edge rather than the glyph's.
      expect(trail.left - title.right, greaterThanOrEqualTo(DabblerInputRow.slotGap));
    });

    testWidgets('the text column takes the remaining width and wraps inside it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerInputRow(
            title: 'a very long settings row title that will not fit on a line',
            trailing: SizedBox(
              key: ValueKey<String>('trail'),
              width: 24,
              height: 24,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final Rect row = tester.getRect(find.byType(DabblerInputRow));
      final Rect trail =
          tester.getRect(find.byKey(const ValueKey<String>('trail')));
      expect(row.width, hostWidth);
      expect(
        trail.right,
        lessThanOrEqualTo(row.right),
        reason: 'the trailing slot stays inside the row however long the title',
      );
      expect(
        tester.getRect(find.byType(Text)).right,
        lessThanOrEqualTo(row.right),
      );
    });
  });

  group('geometry — the drawn literals, with the token conflicts named', () {
    testWidgets('radius is the source literal 16, which no ramp step carries', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerInputRow(title: 'x')));
      expect(_surface(tester).radius, 16);
      expect(DabblerInputRow.defaultRadius, 16);
      expect(DabblerRadius.lg, 12);
      expect(DabblerRadius.xl, 18);
    });

    testWidgets('padding is the drawn 14 block / 16 inline, and mirrors in RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerInputRow(title: 'x')));
      expect(_surface(tester).padding, DabblerInputRow.defaultPadding);
      expect(
        DabblerInputRow.defaultPadding,
        const EdgeInsetsDirectional.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      );

      final Rect ltrRow = tester.getRect(find.byType(DabblerInputRow));
      final Rect ltr = tester.getRect(find.text('x'));
      expect(ltr.left - ltrRow.left, closeTo(16, 0.01));

      await tester.pumpWidget(
        _host(const DabblerInputRow(title: 'x'), direction: TextDirection.rtl),
      );
      final Rect rtlRow = tester.getRect(find.byType(DabblerInputRow));
      final Rect rtl = tester.getRect(find.text('x'));
      expect(
        rtlRow.right - rtl.right,
        closeTo(16, 0.01),
        reason: 'the inline start inset moves to the right in RTL',
      );
    });

    testWidgets('the row is never shorter than the 45px touch floor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerInputRow()));
      expect(
        tester.getSize(find.byType(DabblerInputRow)).height,
        greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
      );
      expect(DabblerInputRow.minHeight, DabblerSizing.touchTargetMin);
      expect(DabblerSizing.touchTargetMin, 45);
    });

    testWidgets('a two-line row grows past the floor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerInputRow(title: 'one', subtitle: 'two')),
      );
      expect(
        tester.getSize(find.byType(DabblerInputRow)).height,
        greaterThan(DabblerSizing.touchTargetMin),
      );
    });

    testWidgets('the fill is --surface-sunken and the system stays flat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerInputRow(title: 'x')));
      final DabblerSurface surface = _surface(tester);
      expect(surface.variant, DabblerSurfaceVariant.sunken);
      expect(surface.fill, isNull, reason: 'the variant resolves its own fill');
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('it holds in dark mode without a literal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerInputRow(title: 'x', subtitle: 'y'),
          brightness: Brightness.dark,
        ),
      );
      final DabblerColors dark = _colors(brightness: Brightness.dark);
      expect(
        tester.widget<Text>(find.text('x')).style!.color,
        dark.textPrimary,
      );
      expect(
        tester.widget<Text>(find.text('y')).style!.color,
        dark.textSecondary,
      );
    });
  });

  group('typography and the D-003 colour ruling', () {
    testWidgets('title is .t-subheadline in --color-text-primary', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerInputRow(title: 'my friends')));
      final TextStyle style = tester.widget<Text>(find.text('my friends')).style!;
      expect(style.fontSize, DabblerType.subheadline.fontSize);
      expect(style.fontSize, 15);
      expect(style.fontWeight, DabblerType.regular);
      expect(style.color, _colors().textPrimary);
    });

    testWidgets('subtitle is .t-footnote and NOT --subtle (D-003)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerInputRow(title: 'a', subtitle: 'only friends can join'),
        ),
      );
      final TextStyle style =
          tester.widget<Text>(find.text('only friends can join')).style!;
      expect(style.fontSize, DabblerType.footnote.fontSize);
      expect(style.fontSize, 13);
      expect(
        style.color,
        _colors().textSecondary,
        reason: 'D-003 forbids --subtle as a text colour; textSecondary is the '
            'role the system carries for a second line',
      );
    });

    testWidgets('both lines take the drawn .5px leadings, not the ramp step', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerInputRow(title: 'a', subtitle: 'b')),
      );
      final TextStyle title = tester.widget<Text>(find.text('a')).style!;
      final TextStyle subtitle = tester.widget<Text>(find.text('b')).style!;
      expect(title.height! * title.fontSize!, closeTo(22.5, 0.01));
      expect(subtitle.height! * subtitle.fontSize!, closeTo(19.5, 0.01));
    });
  });

  group('tappable rows use the system interaction primitives', () {
    testWidgets('an inert row has no press, focus or button semantics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerInputRow(title: 'x')));
      expect(find.byType(DabblerPressScale), findsNothing);
      expect(find.byType(DabblerFocusRing), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('onTap adds press scale and the focus ring, and fires', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(DabblerInputRow(title: 'pinned link', onTap: () => taps++)),
      );
      expect(find.byType(DabblerPressScale), findsOneWidget);

      final DabblerFocusRing ring =
          tester.widget<DabblerFocusRing>(find.byType(DabblerFocusRing));
      expect(
        ring.borderRadius,
        const BorderRadius.all(Radius.circular(DabblerInputRow.defaultRadius)),
      );
      expect(ring.width, DabblerFocusRing.ringWidth);

      await tester.tap(find.byType(DabblerInputRow));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('the press tint is not ported — the row scales', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerInputRow(title: 'x', onTap: () {})),
      );
      final DabblerPressScale press =
          tester.widget<DabblerPressScale>(find.byType(DabblerPressScale));
      expect(press.scale, DabblerMotion.pressScale);

      // The fill is the variant's at rest and while pressed: nothing here
      // darkens it.
      final Color? restingFill = _surface(tester).fill;
      final TestGesture gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      expect(_surface(tester).fill, restingFill);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a disabled row is inert but still announces itself', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          DabblerInputRow(title: 'x', enabled: false, onTap: () => taps++),
        ),
      );
      await tester.tap(find.byType(DabblerInputRow), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(taps, 0);
      expect(
        tester.widget<DabblerPressScale>(find.byType(DabblerPressScale)).enabled,
        isFalse,
      );
      expect(
        tester.widget<DabblerFocusRing>(find.byType(DabblerFocusRing)).enabled,
        isFalse,
      );
    });

    testWidgets('a tappable row is one button named by its own lines', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          DabblerInputRow(
            title: 'my friends',
            subtitle: 'only friends can join',
            onTap: () {},
          ),
        ),
      );

      final SemanticsNode node = tester.getSemantics(
        find.byType(DabblerInputRow),
      );
      expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
      expect(
        node.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );
      expect(node.label, contains('my friends'));
      expect(node.label, contains('only friends can join'));
      expect(
        'my friends'.allMatches(node.label).length,
        1,
        reason: 'the name is said once, not once per semantics layer',
      );
      handle.dispose();
    });

    testWidgets('semanticLabel replaces the lines rather than repeating them', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          DabblerInputRow(
            title: 'my friends',
            subtitle: 'only friends can join',
            semanticLabel: 'privacy: my friends',
            onTap: () {},
          ),
        ),
      );

      final SemanticsNode node = tester.getSemantics(
        find.byType(DabblerInputRow),
      );
      expect(node.label, 'privacy: my friends');
      expect(node.label, isNot(contains('only friends can join')));
      handle.dispose();
    });

    testWidgets('semanticLabel keeps the trailing control announceable', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          DabblerInputRow(
            title: 'my friends',
            semanticLabel: 'privacy',
            trailing: Semantics(
              label: 'toggle',
              container: true,
              child: const SizedBox(width: 24, height: 24),
            ),
            onTap: () {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('toggle'), findsWidgets);
      handle.dispose();
    });

    testWidgets('a tappable row clears the 45px target floor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerInputRow(title: 'x', onTap: () {})),
      );
      final Size size = tester.getSize(find.byType(DabblerInputRow));
      expect(size.height, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
    });
  });

  group('Chevron', () {
    testWidgets('is arrow-right at --icon-sm in LTR', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerChevron()));
      expect(DabblerChevron.iconNameFor(TextDirection.ltr), 'arrow-right');
      expect(DabblerChevron.size, DabblerSizing.iconSm);
      expect(DabblerChevron.size, 18);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mirrors by name in RTL, not by transform', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerChevron(), direction: TextDirection.rtl),
      );
      expect(DabblerChevron.iconNameFor(TextDirection.rtl), 'arrow-left');
      expect(
        find.descendant(
          of: find.byType(DabblerChevron),
          matching: find.byType(Transform),
        ),
        findsNothing,
        reason: 'the system mirrors by selecting the mirrored glyph',
      );
    });

    testWidgets('takes --color-text-tertiary, not --subtle (D-027)', (
      WidgetTester tester,
    ) async {
      // D-037 moved it off textSecondary: a chevron is a non-informational
      // directional glyph, not text, and must read lighter than the subtitle
      // beside it — the weight difference `InputRow.jsx` draws.
      await tester.pumpWidget(_host(const DabblerChevron()));
      final Iterable<Icon> icons = tester.widgetList<Icon>(
        find.descendant(
          of: find.byType(DabblerChevron),
          matching: find.byType(Icon),
        ),
      );
      for (final Icon icon in icons) {
        expect(icon.color, _colors().textTertiary);
        expect(icon.color, isNot(_colors().textSecondary),
            reason: 'the chevron must not read as heavy as the subtitle');
        expect(icon.size, DabblerSizing.iconSm);
      }
    });

    testWidgets('sits in a row as the trailing slot', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerInputRow(
            title: 'pinned link',
            trailing: const DabblerChevron(),
            onTap: () {},
          ),
        ),
      );
      final Rect title = tester.getRect(find.text('pinned link'));
      final Rect chevron = tester.getRect(find.byType(DabblerChevron));
      expect(chevron.left, greaterThanOrEqualTo(title.left));
    });
  });

  group('composed, not restated', () {
    test('every geometry constant is a token, or a named drawn literal', () {
      // Overturned 2026-09-17 by the CEO's visual-fidelity ruling: the radius,
      // the padding and the two leadings are the source's own literals, and
      // the class doc names the token each one conflicts with. Everything the
      // ramp CAN express still comes from the ramp.
      expect(DabblerInputRow.defaultRadius, 16);
      expect(DabblerInputRow.titleLeading, 22.5);
      expect(DabblerInputRow.subtitleLeading, 19.5);
      expect(DabblerInputRow.slotGap, DabblerSpacing.stackDefault);
      expect(DabblerInputRow.minHeight, DabblerSizing.touchTargetMin);
      expect(DabblerChevron.size, DabblerSizing.iconSm);
    });

    test('input_row.dart restates no colour, ring or press constant', () {
      const String path = 'lib/src/forms/input_row.dart';
      final String code = File(path)
          .readAsLinesSync()
          .where((String l) => !l.trimLeft().startsWith('///'))
          .where((String l) => !l.trimLeft().startsWith('//'))
          .join('\n');

      expect(
        RegExp(r'Color\(0x').hasMatch(code),
        isFalse,
        reason: '$path must take every colour from the tokens',
      );
      expect(
        RegExp(r'ringWidth\s*=|ringOffset\s*=|pressScale\s*=|outlineOffset')
            .hasMatch(code),
        isFalse,
        reason: '$path must not restate an interaction constant',
      );
      expect(
        RegExp(r'BoxShadow|LinearGradient|ImageFilter|BackdropFilter')
            .hasMatch(code),
        isFalse,
        reason: 'the system is flat',
      );
      expect(
        RegExp(r'Duration\(').hasMatch(code),
        isFalse,
        reason: 'the press timing is DabblerMotion s, not this file s',
      );
      expect(
        RegExp(r'=\s*45\s*;|=\s*12\s*;|=\s*18\s*;').hasMatch(code),
        isFalse,
        reason: 'a value the ramp DOES express is read from the ramp; only '
            'the four drawn values no token carries (16, 14, 22.5, 19.5) are '
            'written literally, each named in the class doc',
      );
      expect(
        RegExp(r'EdgeInsets\.only|EdgeInsets\.fromLTRB|left:|right:')
            .hasMatch(code),
        isFalse,
        reason: 'the row is RTL-safe: directional insets only',
      );
    });
  });
}
