import 'dart:io';

import 'package:dabbler_design_system/src/controls/chip.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/interaction/press_scale.dart';
import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hosts [child] under a [DabblerColors] resolved for [theme] at [brightness].
Widget _host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
}) {
  final DabblerColors colors =
      DabblerColors.resolve(theme: theme, brightness: brightness);
  // A plain [Theme], not a [MaterialApp]: MaterialApp wraps its theme in an
  // AnimatedTheme, so a [DabblerColors] read immediately after a re-pump is a
  // lerp between the old theme and the new one rather than the new one. These
  // tests switch theme between pumps.
  return MediaQuery(
    data: const MediaQueryData(),
    child: Directionality(
      textDirection: textDirection,
      child: Theme(
        data: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
        // The Enter/Space -> ActivateIntent bindings a real app gets from
        // WidgetsApp. The chip supplies the Action, never the binding.
        child: Shortcuts(
          shortcuts: WidgetsApp.defaultShortcuts,
          child: DefaultTextEditingShortcuts(
            child: Align(alignment: Alignment.topLeft, child: child),
          ),
        ),
      ),
    ),
  );
}

/// The chip's one painted pill.
DabblerSurface _pill(WidgetTester tester) => tester.widget<DabblerSurface>(
      find.descendant(
        of: find.byType(DabblerChip),
        matching: find.byType(DabblerSurface),
      ),
    );

TextStyle _labelStyle(WidgetTester tester) => tester
    .widget<Text>(find.descendant(
      of: find.byType(DabblerChip),
      matching: find.byType(Text),
    ))
    .style!;

void main() {
  group('AC1 — the source\'s own paint and geometry', () {
    test('every geometry constant is a token, at the source\'s value', () {
      // `padding: '9px 15px'` (Chip.jsx:31).
      expect(DabblerChip.verticalPadding, DabblerSpacing.space3);
      expect(DabblerChip.verticalPadding, 9);
      expect(DabblerChip.horizontalPadding, DabblerSpacing.space5);
      expect(DabblerChip.horizontalPadding, 15);
      // `gap: var(--icon-gap)` (Chip.jsx:30).
      expect(DabblerChip.iconGap, DabblerSpacing.iconGap);
      expect(DabblerChip.iconGap, 6);
      // `radius="var(--radius-pill)"` (Chip.jsx:24) and
      // guidelines/measurements.html:76 — NOT --radius-sm.
      expect(DabblerChip.radius, DabblerRadius.pill);
      expect(DabblerChip.radius, isNot(DabblerRadius.sm));
    });

    test('the label step is the ramp\'s 15/20, taken at Medium', () {
      // `fontSize: 15, lineHeight: '20px', fontWeight: 500` (Chip.jsx:31-32).
      expect(DabblerChip.labelStyle, same(DabblerType.subheadline));
      expect(DabblerChip.labelStyle.fontSize, 15);
      expect(DabblerChip.labelStyle.latinLeading, 20);
      final DabblerColors colors = DabblerColors.resolve(
          theme: DabblerTheme.main, brightness: Brightness.light);
      final TextStyle style = DabblerChip.labelStyleFor(
          colors, TextDirection.ltr,
          selected: false);
      expect(style.fontSize, 15);
      expect(style.fontWeight, DabblerType.medium);
      expect(style.fontWeight, FontWeight.w500);
    });

    testWidgets('unselected is the card fill plus the hairline',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerChip(label: 'Free')));
      final DabblerSurface pill = _pill(tester);
      expect(pill.variant, DabblerSurfaceVariant.card);
      expect(pill.radius, DabblerChip.radius);
      expect(pill.borderColor, isNull, reason: 'the card hairline stands');
    });

    testWidgets('selected is the brand fill with a transparent border',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _host(const DabblerChip(label: 'Near me', selected: true)));
      final DabblerSurface pill = _pill(tester);
      expect(pill.variant, DabblerSurfaceVariant.selected);
      expect(pill.borderColor, Colors.transparent);
    });

    testWidgets('selecting does not change the chip\'s size',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerChip(label: 'This week')));
      final Size unselected = tester.getSize(find.byType(DabblerSurface));
      await tester.pumpWidget(
          _host(const DabblerChip(label: 'This week', selected: true)));
      final Size selected = tester.getSize(find.byType(DabblerSurface));
      expect(selected, unselected,
          reason: 'the transparent border keeps both states the same box');
      expect(unselected.height, DabblerChip.visualHeight);
      expect(unselected.height, 38);
    });

    testWidgets('the selected label is onBrand, never white — including bright',
        (WidgetTester tester) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        final DabblerColors colors = DabblerColors.resolve(
            theme: theme, brightness: Brightness.light);
        await tester.pumpWidget(_host(
          const DabblerChip(label: 'Tennis', selected: true),
          theme: theme,
        ));
        expect(_labelStyle(tester).color, colors.onBrand,
            reason: '$theme selected label must be onBrand');
      }
      // The rule only bites where onBrand is not white; bright is that case.
      final DabblerColors bright = DabblerColors.resolve(
          theme: DabblerTheme.bright, brightness: Brightness.light);
      expect(bright.onBrand, isNot(Colors.white));
    });

    testWidgets('the unselected label is ink and the icon is brand',
        (WidgetTester tester) async {
      final DabblerColors colors = DabblerColors.resolve(
          theme: DabblerTheme.main, brightness: Brightness.light);
      await tester.pumpWidget(_host(
        const DabblerChip(label: 'Padel', leadingIcon: Icon(Icons.circle)),
      ));
      expect(_labelStyle(tester).color, colors.textPrimary);
      final IconThemeData iconTheme = IconTheme.of(
        tester.element(find.byIcon(Icons.circle)),
      );
      expect(iconTheme.color, colors.brandPrimary);
      expect(iconTheme.size, DabblerSizing.iconSm);
      expect(DabblerSizing.iconSm, 18);
    });

    testWidgets('the leading icon is slotted at 18 and gapped by --icon-gap',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerChip(label: 'Padel', leadingIcon: Icon(Icons.circle)),
      ));
      final Size iconBox = tester.getSize(find.ancestor(
        of: find.byIcon(Icons.circle),
        matching: find.byType(SizedBox),
      ).first);
      expect(iconBox, const Size(DabblerSizing.iconSm, DabblerSizing.iconSm));

      final Rect icon = tester.getRect(find.ancestor(
        of: find.byIcon(Icons.circle),
        matching: find.byType(SizedBox),
      ).first);
      final Rect text = tester.getRect(find.text('Padel'));
      expect(text.left - icon.right, closeTo(DabblerChip.iconGap, 0.01));
    });

    testWidgets('no leading icon means no icon box at all',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerChip(label: 'Free')));
      expect(find.byType(Icon), findsNothing);
    });
  });

  group('AC1 — the touch target clears 44 while the pill stays at its height',
      () {
    testWidgets('a tappable chip hit-tests over at least 45×45',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _host(DabblerChip(label: 'X', onTap: () {})));
      final Size target = tester.getSize(find.descendant(
        of: find.byType(DabblerChip),
        matching: find.byType(ConstrainedBox),
      ).first);
      expect(target.width, greaterThanOrEqualTo(44));
      expect(target.height, greaterThanOrEqualTo(44));
      expect(target.height, DabblerSizing.touchTargetMin);
      expect(DabblerSizing.touchTargetMin, 45);

      // And the pill inside it is still the source's smaller height.
      final Size pill = tester.getSize(find.byType(DabblerSurface));
      expect(pill.height, DabblerChip.visualHeight);
      expect(pill.height, lessThan(44));
    });

    testWidgets('a tap landing outside the pill but inside the target fires',
        (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
          _host(DabblerChip(label: 'X', onTap: () => taps++)));
      final Rect pill = tester.getRect(find.byType(DabblerSurface));
      final Rect target = tester.getRect(find.descendant(
        of: find.byType(DabblerChip),
        matching: find.byType(ConstrainedBox),
      ).first);
      expect(target.top, lessThan(pill.top),
          reason: 'the target must extend past the pill to be worth testing');
      await tester.tapAt(Offset(target.center.dx, target.top + 1));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('a static tag is not padded to a touch target',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerChip(label: 'Tennis')));
      expect(
        find.descendant(
          of: find.byType(DabblerChip),
          matching: find.byType(ConstrainedBox),
        ),
        findsNothing,
      );
      expect(tester.getSize(find.byType(DabblerSurface)).height,
          DabblerChip.visualHeight);
    });
  });

  group('AC1 — it composes DS-200 and restates none of it', () {
    testWidgets('press and focus are the shared primitives',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _host(DabblerChip(label: 'Tennis', onTap: () {})));
      expect(
          find.descendant(
              of: find.byType(DabblerChip),
              matching: find.byType(DabblerPressScale)),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(DabblerChip),
              matching: find.byType(DabblerFocusRing)),
          findsOneWidget);
    });

    testWidgets('the ring traces the pill radius', (WidgetTester tester) async {
      await tester.pumpWidget(
          _host(DabblerChip(label: 'Tennis', onTap: () {})));
      final DabblerFocusRing ring =
          tester.widget<DabblerFocusRing>(find.byType(DabblerFocusRing));
      expect(ring.borderRadius, DabblerRadius.pillAll);
      // Untouched: the chip does not override the ring's own geometry.
      expect(ring.width, DabblerFocusRing.ringWidth);
      expect(ring.offset, DabblerFocusRing.ringOffset);
    });

    testWidgets('pressing drives DabblerPressScale, not a local scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _host(DabblerChip(label: 'Tennis', onTap: () {})));
      DabblerPressScale scale() =>
          tester.widget<DabblerPressScale>(find.byType(DabblerPressScale));
      expect(scale().pressed, isFalse);
      // The scale value is the primitive's default — the chip never names one.
      expect(scale().scale, DabblerMotion.pressScale);

      final TestGesture gesture =
          await tester.startGesture(tester.getCenter(find.text('Tennis')));
      await tester.pump();
      expect(scale().pressed, isTrue);
      await gesture.up();
      await tester.pump();
      expect(scale().pressed, isFalse);
    });

    testWidgets('a static tag never presses and never rings',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerChip(label: 'Tennis')));
      expect(
          tester
              .widget<DabblerPressScale>(find.byType(DabblerPressScale))
              .enabled,
          isFalse);
      expect(
          tester.widget<DabblerFocusRing>(find.byType(DabblerFocusRing)).enabled,
          isFalse);
      expect(find.byType(FocusableActionDetector), findsNothing);
    });

    test('chip.dart states no press or focus geometry of its own', () {
      final String source =
          File('lib/src/controls/chip.dart').readAsStringSync();
      // Strip dartdoc and comments: the file is allowed to *explain* DS-200,
      // only not to reimplement it.
      final String code = source
          .split('\n')
          .where((String l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      for (final String forbidden in <String>[
        'AnimatedScale',
        'Transform.scale',
        'pressScale',
        'Curves.',
        'Cubic(',
        'milliseconds',
        'Duration(',
        'focusRing',
        'FocusHighlightMode',
        'CustomPaint',
        'strokeWidth',
        'ringWidth',
        'ringOffset',
      ]) {
        expect(code.contains(forbidden), isFalse,
            reason: '$forbidden belongs to DS-200, not to Chip');
      }
    });
  });

  group('AC1 — interaction, semantics and RTL', () {
    testWidgets('tapping fires onTap once', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
          _host(DabblerChip(label: 'Tennis', onTap: () => taps++)));
      await tester.tap(find.text('Tennis'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('Enter activates a focused chip', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
          _host(DabblerChip(label: 'Tennis', onTap: () => taps++)));
      final FocusableActionDetector detector =
          tester.widget<FocusableActionDetector>(
              find.byType(FocusableActionDetector));
      expect(detector.actions!.containsKey(ActivateIntent), isTrue);

      final Element element = tester.element(find.byType(GestureDetector));
      Focus.maybeOf(element)!.requestFocus();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('a tappable chip announces as a selectable button',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
          _host(DabblerChip(label: 'Tennis', selected: true, onTap: () {})));
      expect(
        tester.getSemantics(find.byType(DabblerChip)),
        matchesSemantics(
          label: 'Tennis',
          isButton: true,
          isSelected: true,
          hasTapAction: true,
          hasSelectedState: true,
          hasEnabledState: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('a static tag is not announced as a button',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerChip(label: 'Tennis')));
      final SemanticsNode node =
          tester.getSemantics(find.byType(DabblerChip));
      expect(node.label, 'Tennis');
      expect(node.flagsCollection.isButton, isFalse);
      handle.dispose();
    });

    testWidgets('RTL puts the leading icon on the right and takes Arabic '
        'leading', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const DabblerChip(label: 'تنس', leadingIcon: Icon(Icons.circle)),
        textDirection: TextDirection.rtl,
      ));
      final Rect icon = tester.getRect(find.byIcon(Icons.circle));
      final Rect text = tester.getRect(find.text('تنس'));
      expect(icon.left, greaterThan(text.right - 1),
          reason: 'the leading slot is at the inline start, which is the '
              'right under RTL');

      final TextStyle style = _labelStyle(tester);
      expect(style.height! * style.fontSize!,
          closeTo(DabblerChip.labelStyle.arabicLeading, 0.01));
    });

    testWidgets('the chip hugs its label in an unbounded rail',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const <Widget>[
              DabblerChip(label: 'Free'),
              DabblerChip(label: 'Near me'),
            ],
          ),
        ),
      ));
      final double free =
          tester.getSize(find.byType(DabblerSurface).first).width;
      final double nearMe =
          tester.getSize(find.byType(DabblerSurface).last).width;
      expect(free, lessThan(nearMe),
          reason: 'each chip sizes to its own label, never to the rail');
      // Padding is the source's, on both sides.
      expect(tester.getRect(find.text('Free')).left -
              tester.getRect(find.byType(DabblerSurface).first).left,
          closeTo(DabblerChip.horizontalPadding, 0.01));
    });
  });
}
