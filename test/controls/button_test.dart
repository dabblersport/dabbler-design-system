import 'dart:io';

import 'package:dabbler_design_system/src/controls/button.dart';
import 'package:dabbler_design_system/src/controls/button_gallery.dart';
import 'package:dabbler_design_system/src/gallery/gallery_entry.dart';
import 'package:dabbler_design_system/src/feedback/spinner.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/interaction/press_scale.dart';
import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// `lib/src/controls/button.dart` with its dartdoc and line comments removed.
///
/// The prose legitimately names the legacy tones and the DS-200 values in order
/// to explain why neither is restated in code; scanning the raw file would
/// therefore fail on its own documentation.
String _code() => File('lib/src/controls/button.dart')
    .readAsLinesSync()
    .where((String line) => !line.trimLeft().startsWith('//'))
    .join('\n');

/// Hosts [child] under a [DabblerColors] resolved for [theme] at [brightness].
///
/// A plain [Theme] and not a [MaterialApp], for the reason
/// `test/controls/chip_test.dart` states: MaterialApp's AnimatedTheme would
/// hand back a lerp on the pump after a theme change.
Widget _host(
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
}) {
  final DabblerColors colors =
      DabblerColors.resolve(theme: theme, brightness: brightness);
  return MediaQuery(
    data: const MediaQueryData(),
    child: Directionality(
      textDirection: textDirection,
      child: Theme(
        data: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
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

/// The button's one painted box.
DabblerSurface _surface(WidgetTester tester) => tester.widget<DabblerSurface>(
      find.descendant(
        of: find.byType(DabblerButton),
        matching: find.byType(DabblerSurface),
      ),
    );

TextStyle _labelStyle(WidgetTester tester) => tester
    .widget<Text>(find.descendant(
      of: find.byType(DabblerButton),
      matching: find.byType(Text),
    ))
    .style!;

DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

void main() {
  group('AC1 — the tone enum', () {
    test('is exactly the ten values the ticket names, in source order', () {
      // KAN-279/D-023(3) added `text` after `outlined`, the slot it occupies in
      // `Button.jsx`'s TONES map.
      expect(
        DabblerButtonTone.values.map((DabblerButtonTone t) => t.name).toList(),
        <String>[
          'primary',
          'secondary',
          'accent',
          'neutral',
          'filled',
          'outlined',
          'text',
          'destructive',
          'iconLabel',
          'icon',
        ],
      );
    });

    test('names no legacy alias anywhere in the file', () {
      // AC1: `outline` / `ghost` / `dark` are not ported at all — no alias, no
      // deprecation, no warning. A source scan, because the absence of an enum
      // value would not catch an alias smuggled in as a constructor or a map.
      final String source = _code();
      // The enum value `outlined` legitimately contains `outline`, so the scan
      // is for the bare identifiers.
      expect(RegExp(r'\boutline\b').hasMatch(source), isFalse,
          reason: 'legacy tone name `outline` must not be ported');
      expect(RegExp(r'\bghost\b').hasMatch(source), isFalse,
          reason: 'legacy tone name `ghost` must not be ported');
      expect(source.contains('TONE_ALIASES'), isFalse);
      expect(source.contains('@Deprecated'), isFalse);
    });

    testWidgets('paints each tone from the source TONES map', (
      WidgetTester tester,
    ) async {
      final DabblerColors c = _colors();
      final Map<DabblerButtonTone, (Color, Color)> expected =
          <DabblerButtonTone, (Color, Color)>{
        DabblerButtonTone.primary: (c.brandPrimary, c.onBrand),
        DabblerButtonTone.secondary: (c.accent, c.onAccent),
        DabblerButtonTone.accent: (DabblerButton.accentFill, c.surfaceCard),
        DabblerButtonTone.neutral: (c.surfaceSunken, c.textPrimary),
        DabblerButtonTone.filled: (c.textPrimary, c.surfaceCard),
        DabblerButtonTone.outlined: (Colors.transparent, c.textPrimary),
        DabblerButtonTone.text: (Colors.transparent, c.textPrimary),
        DabblerButtonTone.destructive: (c.error.solid, DabblerPalette.paper),
        DabblerButtonTone.iconLabel: (c.surfaceSunken, c.textPrimary),
        DabblerButtonTone.icon: (c.textPrimary, c.surfaceCard),
      };

      for (final DabblerButtonTone tone in DabblerButtonTone.values) {
        await tester.pumpWidget(
          _host(DabblerButton(label: 'join', tone: tone, onPressed: () {})),
        );
        final (Color bg, Color fg) = expected[tone]!;
        expect(_surface(tester).fill, bg, reason: '$tone background');
        expect(_labelStyle(tester).color, fg, reason: '$tone foreground');
      }
    });

    testWidgets('only `outlined` draws a hairline', (WidgetTester tester) async {
      final DabblerColors c = _colors();
      for (final DabblerButtonTone tone in DabblerButtonTone.values) {
        await tester.pumpWidget(
          _host(DabblerButton(label: 'join', tone: tone, onPressed: () {})),
        );
        expect(
          _surface(tester).borderColor,
          tone == DabblerButtonTone.outlined
              ? c.borderDefault
              : Colors.transparent,
          reason: '$tone border',
        );
      }
    });

    testWidgets('KAN-279 — `text` paints no fill and no hairline', (
      WidgetTester tester,
    ) async {
      // The tone is `outlined` minus the hairline: the label alone. Asserted in
      // every theme and mode, because a fill leaking back in under one section
      // theme is exactly the regression this tone cannot survive.
      for (final DabblerTheme theme in DabblerTheme.values) {
        for (final Brightness brightness in Brightness.values) {
          await tester.pumpWidget(
            _host(
              DabblerButton(
                label: 'cancel',
                tone: DabblerButtonTone.text,
                onPressed: () {},
              ),
              theme: theme,
              brightness: brightness,
            ),
          );
          final DabblerColors c = _colors(theme: theme, brightness: brightness);
          expect(_surface(tester).fill, Colors.transparent,
              reason: '${theme.name}/${brightness.name} fill');
          expect(_surface(tester).borderColor, Colors.transparent,
              reason: '${theme.name}/${brightness.name} border');
          expect(_labelStyle(tester).color, c.textPrimary,
              reason: '${theme.name}/${brightness.name} label');
        }
      }
    });

    test('KAN-279 — `text` carries D-023(c) on the tone, not in a comment', () {
      // AC2: the affordance constraint has to be in the API surface a caller
      // reads, so it is asserted against the dartdoc rather than trusted.
      final String doc = File('lib/src/controls/button.dart').readAsStringSync();
      final int start = doc.indexOf('/// Transparent fill, `--ink` label, **no** hairline');
      final int end = doc.indexOf('  text,', start);
      expect(start, greaterThan(-1), reason: 'the `text` dartdoc is gone');
      expect(end, greaterThan(start));
      final String block = doc.substring(start, end);
      expect(block.contains('D-023(c)'), isTrue);
      expect(block.contains('Never the only action in a group'), isTrue);
      expect(block.contains('Never the primary action, and never the destructive one'),
          isTrue);
    });

    testWidgets('re-tints with the section theme', (WidgetTester tester) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        await tester.pumpWidget(
          _host(
            DabblerButton(label: 'join', onPressed: () {}),
            theme: theme,
          ),
        );
        final DabblerColors c = _colors(theme: theme);
        expect(_surface(tester).fill, c.brandPrimary, reason: theme.name);
        expect(_labelStyle(tester).color, c.onBrand, reason: theme.name);
      }
    });
  });

  group('AC2 — size, icon, fullWidth, disabled as modifiers', () {
    test('the size enum is the three the source declares', () {
      expect(
        DabblerButtonSize.values.map((DabblerButtonSize s) => s.name).toList(),
        <String>['full', 'medium', 'small'],
      );
    });

    testWidgets('full is a fixed 320×52', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerButton(
            label: 'start free trial',
            size: DabblerButtonSize.full,
          ),
        ),
      );
      final Size size = tester.getSize(find.byType(DabblerButton));
      expect(size.width, DabblerButton.fullWidthPx);
      expect(size.width, 320);
      expect(size.height, DabblerButton.fullHeight);
      expect(size.height, 52);
    });

    testWidgets('fullWidth stretches to the container', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 500,
            child: DabblerButton(
              label: 'start free trial',
              size: DabblerButtonSize.full,
              fullWidth: true,
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(DabblerButton)).width, 500);
    });

    test('padding is the source\'s 10/20 and 8/16, and zero on full', () {
      expect(
        DabblerButton.paddingFor(DabblerButtonSize.medium),
        const EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 20),
      );
      expect(
        DabblerButton.paddingFor(DabblerButtonSize.small),
        const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 16),
      );
      expect(
        DabblerButton.paddingFor(DabblerButtonSize.full),
        EdgeInsetsDirectional.zero,
      );
    });

    test('the label ramp is 16/14/12, all at weight 600', () {
      expect(DabblerButton.fontSizeFor(DabblerButtonSize.full), 16);
      expect(DabblerButton.fontSizeFor(DabblerButtonSize.medium), 14);
      expect(DabblerButton.fontSizeFor(DabblerButtonSize.small), 12);
      for (final DabblerButtonSize size in DabblerButtonSize.values) {
        final TextStyle style = DabblerButton.labelStyleFor(
          _colors(),
          TextDirection.ltr,
          size: size,
          tone: DabblerButtonTone.primary,
        );
        expect(style.fontWeight, DabblerType.semibold);
        expect(style.fontWeight, FontWeight.w600);
        expect(style.fontSize, DabblerButton.fontSizeFor(size));
        // `line-height: 1.4`, a multiplier.
        expect(style.height, 1.4);
      }
    });

    test('the corner is 21 on full and pill on the rest (D-005)', () {
      expect(DabblerButton.radiusFor(DabblerButtonSize.full), 21);
      expect(DabblerButton.fullRadius, DabblerSpacing.space7);
      expect(
        DabblerButton.radiusFor(DabblerButtonSize.medium),
        DabblerRadius.pill,
      );
      expect(
        DabblerButton.radiusFor(DabblerButtonSize.small),
        DabblerRadius.pill,
      );
    });

    testWidgets('the leading icon is a DabblerIcon at 18, gapped by 8', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerButton(label: 'create a game', icon: 'add', onPressed: () {}),
        ),
      );
      final DabblerIcon icon = tester.widget<DabblerIcon>(
        find.byType(DabblerIcon),
      );
      expect(icon.name, 'add');
      expect(icon.size, DabblerSizing.iconSm);
      expect(icon.size, 18);

      // The gap is the one SizedBox that is a direct child of the content Row
      // — DabblerIcon has SizedBoxes of its own, so the finder is by position
      // in the Row rather than by type alone.
      final Row row = tester.widget<Row>(
        find.descendant(
          of: find.byType(DabblerButton),
          matching: find.byType(Row),
        ),
      );
      final SizedBox gap =
          row.children.whereType<SizedBox>().single;
      expect(gap.width, DabblerButton.iconGap);
      expect(gap.width, 8);

      // And the gap exists only when the slot is occupied.
      await tester.pumpWidget(
        _host(DabblerButton(label: 'join', onPressed: () {})),
      );
      final Row bare = tester.widget<Row>(
        find.descendant(
          of: find.byType(DabblerButton),
          matching: find.byType(Row),
        ),
      );
      expect(bare.children.whereType<SizedBox>(), isEmpty);
    });

    testWidgets('an icon-only button renders its glyph at 20 and no label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerButton.icon(
            icon: 'more',
            semanticLabel: 'More',
            onPressed: () {},
          ),
        ),
      );
      expect(
        tester.widget<DabblerIcon>(find.byType(DabblerIcon)).size,
        DabblerButton.iconOnlyGlyphSize,
      );
      expect(
        find.descendant(
          of: find.byType(DabblerButton),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
    });

    testWidgets('disabled is inert and 45% opaque; a null handler is not', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          DabblerButton(label: 'join', disabled: true, onPressed: () => taps++),
        ),
      );
      await tester.tap(find.byType(DabblerButton));
      await tester.pump();
      expect(taps, 0);

      final Opacity opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(DabblerButton),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, DabblerButton.disabledOpacity);
      expect(opacity.opacity, 0.45);

      // An enabled button with no handler draws at full opacity — `disabled`
      // and "no onClick" are separate in the source.
      await tester.pumpWidget(_host(const DabblerButton(label: 'join')));
      expect(
        find.descendant(
          of: find.byType(DabblerButton),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
    });

    testWidgets('press darkens the fill by 12% and scales via DS-200', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerButton(label: 'join', onPressed: () {})),
      );
      final DabblerColors c = _colors();
      expect(_surface(tester).fill, c.brandPrimary);

      final TestGesture gesture =
          await tester.startGesture(tester.getCenter(find.byType(DabblerButton)));
      await tester.pump();
      expect(
        _surface(tester).fill,
        Color.lerp(c.brandPrimary, Colors.black, DabblerButton.pressDarken),
      );
      expect(
        tester.widget<DabblerPressScale>(find.byType(DabblerPressScale)).pressed,
        isTrue,
      );
      await gesture.up();
      await tester.pump();
      expect(_surface(tester).fill, c.brandPrimary);
    });

    test('there is one widget, not thirteen', () {
      // The merge is the point of DS-400: 10 tones × 3 sizes are modifiers on
      // DabblerButton and nothing else is exported from the file.
      final String source = _code();
      final Iterable<String> publicClasses = RegExp(r'^class (\w+)', multiLine: true)
          .allMatches(source)
          .map((RegExpMatch m) => m.group(1)!)
          .where((String name) => !name.startsWith('_'));
      expect(publicClasses, <String>['DabblerButton']);
    });
  });

  group('AC3 — loading', () {
    testWidgets('renders DS-403\'s spinner at sm, tone inherit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerButton(label: 'joining', loading: true, onPressed: () {}),
        ),
      );
      final DabblerSpinner spinner =
          tester.widget<DabblerSpinner>(find.byType(DabblerSpinner));
      expect(spinner.size, DabblerSpinnerSize.sm);
      expect(spinner.tone, DabblerSpinnerTone.inherit);
      expect(spinner.size.diameter, DabblerSizing.iconSm);
    });

    testWidgets('blocks interaction but does not dim', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          DabblerButton(label: 'joining', loading: true, onPressed: () => taps++),
        ),
      );
      await tester.tap(find.byType(DabblerButton));
      await tester.pump();
      expect(taps, 0);
      // `opacity: disabled ? 0.45 : 1` keys off `disabled` alone.
      expect(
        find.descendant(
          of: find.byType(DabblerButton),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
    });

    testWidgets('the spinner replaces the leading icon, keeping the label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerButton(
            label: 'joining',
            icon: 'add',
            loading: true,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(DabblerSpinner), findsOneWidget);
      expect(find.byType(DabblerIcon), findsNothing);
      expect(find.text('joining'), findsOneWidget);
    });

    test('the file contains no private spinner', () {
      final String source = _code();
      expect(source.contains('CustomPaint'), isFalse);
      expect(source.contains('AnimationController'), isFalse);
    });
  });

  group('AC5 — touch target ≥44×44, measured', () {
    testWidgets('every size, both scripts, labelled and icon-only', (
      WidgetTester tester,
    ) async {
      for (final DabblerButtonSize size in DabblerButtonSize.values) {
        for (final TextDirection direction in TextDirection.values) {
          for (final bool iconOnly in <bool>[false, true]) {
            await tester.pumpWidget(
              _host(
                iconOnly
                    ? DabblerButton.icon(
                        icon: 'more',
                        semanticLabel: 'More',
                        size: size,
                        onPressed: () {},
                      )
                    : DabblerButton(
                        label: direction == TextDirection.rtl ? 'انضم' : 'join',
                        size: size,
                        onPressed: () {},
                      ),
                textDirection: direction,
              ),
            );
            final Size box = tester.getSize(find.byType(DabblerButton));
            final String what = '$size/$direction/iconOnly=$iconOnly';
            expect(box.width, greaterThanOrEqualTo(44), reason: what);
            expect(box.height, greaterThanOrEqualTo(44), reason: what);
          }
        }
      }
    });

    testWidgets('the whole box is hit-testable, not just the content', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          DabblerButton(
            label: 'x',
            size: DabblerButtonSize.small,
            onPressed: () => taps++,
          ),
        ),
      );
      final Rect box = tester.getRect(find.byType(DabblerButton));
      expect(box.height, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
      // The top-left corner, which a content-sized hit area would miss.
      await tester.tapAt(box.topLeft + const Offset(1, 1));
      await tester.pump();
      expect(taps, 1);
    });
  });

  group('interaction, semantics and composition', () {
    testWidgets('tap fires onPressed', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(DabblerButton(label: 'join', onPressed: () => taps++)),
      );
      await tester.tap(find.byType(DabblerButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('Enter and Space activate a focused button', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(DabblerButton(label: 'join', onPressed: () => taps++)),
      );
      Focus.maybeOf(tester.element(find.byType(GestureDetector)))!
          .requestFocus();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(taps, 2);
    });

    testWidgets('exposes a button node with the right name and enablement', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _host(DabblerButton(label: 'join', onPressed: () {})),
      );
      expect(
        tester.getSemantics(find.byType(DabblerButton)),
        matchesSemantics(
          hasTapAction: true,
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          label: 'join',
        ),
      );

      // Icon-only: the name comes from semanticLabel, since there is no label.
      await tester.pumpWidget(
        _host(
          DabblerButton.icon(
            icon: 'more',
            semanticLabel: 'More',
            onPressed: () {},
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(DabblerButton)).label,
        'More',
      );

      // Disabled: no tap action, and not enabled.
      await tester.pumpWidget(
        _host(
          DabblerButton(label: 'join', disabled: true, onPressed: () {}),
        ),
      );
      expect(
        tester.getSemantics(find.byType(DabblerButton)),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
          label: 'join',
        ),
      );

      handle.dispose();
    });

    testWidgets('focus paints the DS-200 ring, and not while inert', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerButton(label: 'join', onPressed: () {})),
      );
      expect(find.byType(DabblerFocusRing), findsOneWidget);
      expect(
        tester.widget<DabblerFocusRing>(find.byType(DabblerFocusRing)).enabled,
        isTrue,
      );

      await tester.pumpWidget(
        _host(DabblerButton(label: 'join', disabled: true, onPressed: () {})),
      );
      expect(
        tester.widget<DabblerFocusRing>(find.byType(DabblerFocusRing)).enabled,
        isFalse,
      );
    });

    test('restates none of DS-200\'s values', () {
      final String source = _code();
      // The press scale, the durations, the curve, the ring width and offset
      // all live in lib/src/interaction/ and must not be repeated here.
      for (final String forbidden in <String>[
        '0.98',
        'Duration(',
        'Cubic(',
        'ringWidth',
        'ringOffset',
      ]) {
        expect(source.contains(forbidden), isFalse,
            reason: 'DS-200 value `$forbidden` restated in button.dart');
      }
    });

    test('names no colour literal and no left/right', () {
      final String source = _code();
      expect(RegExp(r'Color\(0x').hasMatch(source), isFalse);
      expect(RegExp(r'\bColors\.(?!transparent|black\b)').hasMatch(source),
          isFalse);
      expect(RegExp(r'EdgeInsets\.only').hasMatch(source), isFalse);
      expect(RegExp(r'\bleft:|\bright:').hasMatch(source), isFalse);
    });

    testWidgets('RTL puts the icon after the label in visual order', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerButton(label: 'انضم', icon: 'add', onPressed: () {}),
          textDirection: TextDirection.rtl,
        ),
      );
      final double icon = tester.getCenter(find.byType(DabblerIcon)).dx;
      final double label = tester.getCenter(find.byType(Text)).dx;
      expect(icon, greaterThan(label),
          reason: 'the leading slot is at the inline start, which is the right '
              'under RTL');
    });

    testWidgets('the label takes the Arabic face under RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerButton(label: 'انضم', onPressed: () {}),
          textDirection: TextDirection.rtl,
        ),
      );
      expect(
        _labelStyle(tester).fontFamily,
        DabblerType.label.resolve(DabblerTypeScript.arabic).fontFamily,
      );
    });
  });

  group('AC4 — consumed-shape font check', () {
    // BLOCKED on DS-103b (KAN-254), which supplies the font binaries. Until
    // those land no family name resolves, and a test asserting one would be
    // asserting a string rather than a rendered face. What CAN be checked
    // without them is that the label's style is the qualified package form the
    // AC will measure — that is a property of DabblerType, not of the binaries.
    testWidgets('the label style is already the packages/… qualified form', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerButton(label: 'join', onPressed: () {})),
      );
      final TextStyle style = _labelStyle(tester);
      expect(style.fontFamily, startsWith('packages/dabbler_design_system/'));
      expect(style.fontFamilyFallback, isNotEmpty);
      expect(
        style.fontFamilyFallback!.first,
        isNot(startsWith('packages/')),
        reason: 'the bare family belongs in the fallback',
      );
    });
  });

  /// KAN-340 — the specimen exhibits the real axis.
  ///
  /// `_matrixTones` is a hand-listed set, not [DabblerButtonTone.values], so
  /// a tone can ship and never be drawn. `text` did exactly that: added by
  /// D-023 via KAN-279, live at `calendar.dart:880` and
  /// `time_picker.dart:535`, and absent from the gallery until this ticket.
  /// The assertion is deliberately the WHOLE SET rather than `text` alone —
  /// pinning one name would not stop an eleventh tone repeating the defect.
  group('the Button gallery exhibits every tone (KAN-340)', () {
    testWidgets('every DabblerButtonTone is drawn somewhere', (
      WidgetTester tester,
    ) async {
      final Set<DabblerButtonTone> drawn = <DabblerButtonTone>{};
      for (final GalleryEntry entry in buttonGalleryEntries) {
        await tester.pumpWidget(_host(Builder(builder: entry.builder)));
        await tester.pump();
        drawn.addAll(
          tester
              .widgetList<DabblerButton>(find.byType(DabblerButton))
              .map((DabblerButton b) => b.tone),
        );
      }
      expect(
        drawn,
        DabblerButtonTone.values.toSet(),
        reason: 'a tone with no specimen is a tone a reader cannot check '
            'the implementation against',
      );
    });
  });
}
