import 'package:dabbler_design_system/src/forms/field_shell.dart';
import 'package:dabbler_design_system/src/forms/text_field.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The width every field under test is laid out in, so edge assertions have a
/// fixed frame to compare against. Mirrors `test/layout/section_test.dart`.
const double hostWidth = 320;

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

Rect _rectOf(WidgetTester tester, Finder finder) => tester.getRect(finder.first);

/// The shell's box, as the widget that was configured — so border colour and
/// width are read as values rather than inferred from pixels.
DabblerSurface _box(WidgetTester tester) => tester.widget<DabblerSurface>(
      find
          .descendant(
            of: find.byType(DabblerFieldShell),
            matching: find.byType(DabblerSurface),
          )
          .first,
    );

/// The global rect of the caret at [offset] inside the field's editable.
///
/// Measured off [RenderEditable], not guessed: this is the real insertion
/// point the user sees.
Rect _caretRect(WidgetTester tester, {int offset = 0}) {
  final EditableTextState state =
      tester.state<EditableTextState>(find.byType(EditableText).first);
  final RenderEditable editable = state.renderEditable;
  final Rect local = editable.getLocalRectForCaret(TextPosition(offset: offset));
  final Offset origin = editable.localToGlobal(local.topLeft);
  return origin & local.size;
}

void main() {
  group('FieldShell geometry is the design source, not invention', () {
    testWidgets('the box is --radius-xxl on every variant but multiline', (
      WidgetTester tester,
    ) async {
      for (final DabblerTextFieldVariant variant
          in DabblerTextFieldVariant.values) {
        await tester.pumpWidget(_host(DabblerTextField(variant: variant)));
        expect(
          _box(tester).radius,
          variant == DabblerTextFieldVariant.multiline
              ? DabblerRadius.xl
              : DabblerRadius.xxl,
          reason: '$variant',
        );
      }
      expect(DabblerRadius.xxl, 24);
      expect(DabblerRadius.xl, 18);
    });

    testWidgets('the box is never shorter than --touch-target-min', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerTextField()));
      expect(
        _rectOf(tester, find.byType(DabblerSurface)).height,
        greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
      );
      expect(DabblerSizing.touchTargetMin, 45);
    });

    testWidgets('inner padding is 9px block / 12px inline', (
      WidgetTester tester,
    ) async {
      expect(
        DabblerFieldShell.defaultInnerPadding,
        const EdgeInsetsDirectional.fromSTEB(
          DabblerSpacing.space4,
          DabblerSpacing.space3,
          DabblerSpacing.space4,
          DabblerSpacing.space3,
        ),
      );
      expect(DabblerSpacing.space3, 9);
      expect(DabblerSpacing.space4, 12);

      await tester.pumpWidget(
        _host(
          const DabblerTextField(
            prefixIcon: Icon(Icons.abc, key: ValueKey<String>('lead')),
          ),
        ),
      );
      final Rect box = _rectOf(tester, find.byType(DabblerSurface));
      final Rect lead =
          _rectOf(tester, find.byKey(const ValueKey<String>('lead')));
      expect(lead.left - box.left, DabblerSpacing.space4);
    });

    testWidgets('label -> box and box -> message gaps are --stack-tight', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerTextField(label: 'Email', helperText: 'we never share it'),
        ),
      );
      final Rect label = _rectOf(tester, find.text('Email'));
      final Rect box = _rectOf(tester, find.byType(DabblerSurface));
      final Rect helper = _rectOf(tester, find.text('we never share it'));
      expect(box.top - label.bottom, DabblerSpacing.stackTight);
      expect(helper.top - box.bottom, DabblerSpacing.stackTight);
      expect(DabblerSpacing.stackTight, 6);
    });

    testWidgets('row children are --icon-gap apart', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerTextField(
            variant: DabblerTextFieldVariant.search,
            suffixIcon: Icon(Icons.abc, key: ValueKey<String>('trail')),
          ),
        ),
      );
      final Rect trail =
          _rectOf(tester, find.byKey(const ValueKey<String>('trail')));
      final Rect editable = _rectOf(tester, find.byType(EditableText));
      expect(trail.left - editable.right, DabblerSpacing.iconGap);
      expect(DabblerSpacing.iconGap, 6);
    });
  });

  group('the four border states come from tokens, in source precedence', () {
    final DabblerColors colors = _colors();

    testWidgets('rest keeps the surface hairline', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerTextField()));
      expect(_box(tester).borderColor, isNull);
      expect(_box(tester).borderWidth, DabblerSizing.borderDefault);
    });

    testWidgets('focus swaps it for the 2px focus ring colour', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerTextField()));
      await tester.tap(find.byType(EditableText));
      await tester.pumpAndSettle();
      expect(_box(tester).borderColor, colors.focusRing);
      expect(_box(tester).borderWidth, DabblerFocusRing.ringWidth);
      expect(DabblerFocusRing.ringWidth, 2);
    });

    testWidgets('error swaps it for --color-status-error at 1px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerTextField(errorText: 'Enter a valid email')),
      );
      expect(
        _box(tester).borderColor,
        colors.status(DabblerStatusTone.error).base,
      );
      expect(_box(tester).borderWidth, DabblerSizing.borderDefault);
    });

    testWidgets('disabled wins over error, as the source tests it first', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerTextField(enabled: false, errorText: 'still invalid'),
        ),
      );
      expect(_box(tester).borderColor, colors.borderDefault);
      expect(_box(tester).borderWidth, DabblerSizing.borderDefault);
    });

    testWidgets('the disabled fill is the opaque 4% brand mix', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerTextField(enabled: false)));
      final Color fill = _box(tester).fill!;
      expect(fill, DabblerFieldShell.disabledFill(colors));
      expect(fill.a, 1.0, reason: 'the flat system has no translucent fill');
      expect(fill, isNot(colors.surfaceCard));
    });

    testWidgets('the fill is the flat card surface at rest', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerTextField()));
      expect(_box(tester).fill, colors.surfaceCard);
    });
  });

  group('validation and helper text — AC3, and D-003', () {
    final DabblerColors colors = _colors();

    TextStyle styleOf(WidgetTester tester, String text) =>
        tester.widget<Text>(find.text(text)).style!;

    testWidgets('errorText replaces helperText — one line, never two', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerTextField(
            helperText: 'we never share it',
            errorText: 'Enter a valid email',
          ),
        ),
      );
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('we never share it'), findsNothing);
    });

    testWidgets('helper text is textSecondary, not a surface neutral (D-003)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerTextField(helperText: 'we never share it')),
      );
      final TextStyle style = styleOf(tester, 'we never share it');
      expect(style.color, colors.textSecondary);
      expect(style.color, isNot(colors.textTertiary));
      expect(style.fontSize, DabblerType.footnote.fontSize);
    });

    testWidgets('error text is --color-status-error at footnote metrics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerTextField(errorText: 'Enter a valid email')),
      );
      final TextStyle style = styleOf(tester, 'Enter a valid email');
      expect(style.color, colors.status(DabblerStatusTone.error).base);
      expect(style.fontSize, DabblerType.footnote.fontSize);
    });

    testWidgets('the label tints to the brand while focused', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerTextField(label: 'Email')));
      expect(styleOf(tester, 'Email').color, colors.textSecondary);
      await tester.tap(find.byType(EditableText));
      await tester.pumpAndSettle();
      expect(styleOf(tester, 'Email').color, colors.brandPrimary);
    });

    testWidgets('an error does not disable the field', (
      WidgetTester tester,
    ) async {
      String? seen;
      await tester.pumpWidget(
        _host(
          DabblerTextField(
            errorText: 'Enter a valid email',
            onChanged: (String v) => seen = v,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'a@b.co');
      expect(seen, 'a@b.co');
    });
  });

  group('AC4 — RTL mirroring, proven by measured geometry', () {
    /// Every directional affordance the shell has, in one field.
    Future<void> pumpAll(WidgetTester tester, TextDirection direction) =>
        tester.pumpWidget(
          _host(
            const DabblerTextField(
              label: 'Email',
              helperText: 'we never share it',
              prefixIcon: Icon(Icons.abc, key: ValueKey<String>('lead')),
              suffixIcon: Icon(Icons.abc, key: ValueKey<String>('trail')),
            ),
            direction: direction,
          ),
        );

    testWidgets('the label leads on the inline start in both directions', (
      WidgetTester tester,
    ) async {
      await pumpAll(tester, TextDirection.ltr);
      Rect field = _rectOf(tester, find.byType(DabblerTextField));
      expect(_rectOf(tester, find.text('Email')).left, field.left);

      await pumpAll(tester, TextDirection.rtl);
      field = _rectOf(tester, find.byType(DabblerTextField));
      expect(_rectOf(tester, find.text('Email')).right, field.right);
    });

    testWidgets('the helper line keeps its 12px indent on the inline start', (
      WidgetTester tester,
    ) async {
      await pumpAll(tester, TextDirection.ltr);
      Rect box = _rectOf(tester, find.byType(DabblerSurface));
      Rect helper = _rectOf(tester, find.text('we never share it'));
      expect(helper.left - box.left, DabblerSpacing.space4);

      await pumpAll(tester, TextDirection.rtl);
      box = _rectOf(tester, find.byType(DabblerSurface));
      helper = _rectOf(tester, find.text('we never share it'));
      expect(box.right - helper.right, DabblerSpacing.space4);
    });

    testWidgets('prefix and suffix swap sides, and never overlap', (
      WidgetTester tester,
    ) async {
      await pumpAll(tester, TextDirection.ltr);
      Rect box = _rectOf(tester, find.byType(DabblerSurface));
      Rect lead = _rectOf(tester, find.byKey(const ValueKey<String>('lead')));
      Rect trail = _rectOf(tester, find.byKey(const ValueKey<String>('trail')));
      expect(lead.left - box.left, DabblerSpacing.space4);
      expect(box.right - trail.right, DabblerSpacing.space4);
      expect(lead.right, lessThanOrEqualTo(trail.left));

      await pumpAll(tester, TextDirection.rtl);
      box = _rectOf(tester, find.byType(DabblerSurface));
      lead = _rectOf(tester, find.byKey(const ValueKey<String>('lead')));
      trail = _rectOf(tester, find.byKey(const ValueKey<String>('trail')));
      expect(box.right - lead.right, DabblerSpacing.space4);
      expect(trail.left - box.left, DabblerSpacing.space4);
      expect(trail.right, lessThanOrEqualTo(lead.left));
    });

    testWidgets('the caret starts on the inline start in both directions', (
      WidgetTester tester,
    ) async {
      await pumpAll(tester, TextDirection.ltr);
      Rect editable = _rectOf(tester, find.byType(EditableText));
      Rect caret = _caretRect(tester);
      expect(
        (caret.left - editable.left).abs(),
        lessThanOrEqualTo(1),
        reason: 'LTR: the insertion point is at the left edge of the editable',
      );

      await pumpAll(tester, TextDirection.rtl);
      editable = _rectOf(tester, find.byType(EditableText));
      caret = _caretRect(tester);
      expect(
        (editable.right - caret.right).abs(),
        lessThanOrEqualTo(1),
        reason: 'RTL: it is at the right edge',
      );
    });

    testWidgets('typed text stays on the inline start under RTL', (
      WidgetTester tester,
    ) async {
      await pumpAll(tester, TextDirection.rtl);
      await tester.enterText(find.byType(EditableText), 'ملعب');
      await tester.pumpAndSettle();
      final Rect editable = _rectOf(tester, find.byType(EditableText));
      final Rect caret = _caretRect(tester, offset: 4);
      expect(caret.left, greaterThanOrEqualTo(editable.left - 1));
      expect(caret.right, lessThanOrEqualTo(editable.right + 1));
    });

    testWidgets('the select arrow trails in both directions', (
      WidgetTester tester,
    ) async {
      for (final TextDirection direction in TextDirection.values) {
        await tester.pumpWidget(
          _host(
            const DabblerTextField(
              variant: DabblerTextFieldVariant.select,
              label: 'Sport',
              value: 'padel',
            ),
            direction: direction,
          ),
        );
        final Rect box = _rectOf(tester, find.byType(DabblerSurface));
        final Rect arrow = _rectOf(
          tester,
          find.descendant(
            of: find.byType(AnimatedRotation),
            matching: find.byType(SizedBox),
          ),
        );
        if (direction == TextDirection.ltr) {
          expect(box.right - arrow.right, DabblerSpacing.space4);
        } else {
          expect(arrow.left - box.left, DabblerSpacing.space4);
        }
      }
    });

    testWidgets('the Arabic face is selected under RTL', (
      WidgetTester tester,
    ) async {
      await pumpAll(tester, TextDirection.rtl);
      final TextStyle label = tester.widget<Text>(find.text('Email')).style!;
      expect(
        label.fontFamily,
        DabblerType.subheadline.resolve(DabblerTypeScript.arabic).fontFamily,
      );
    });
  });

  group('variants', () {
    testWidgets('search supplies its own leading glyph and ignores prefixIcon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerTextField(
            variant: DabblerTextFieldVariant.search,
            prefixIcon: Icon(Icons.abc, key: ValueKey<String>('lead')),
          ),
        ),
      );
      expect(find.byKey(const ValueKey<String>('lead')), findsNothing);
      expect(DabblerTextField.searchIconName, 'search-normal');
    });

    testWidgets('password obscures, and the toggle reveals on a 45px target', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerTextField(
            variant: DabblerTextFieldVariant.password,
            initialValue: 'dabbler123',
          ),
        ),
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );
      final Finder toggle = find.bySemanticsLabel('Show password');
      expect(tester.getSize(toggle), const Size.square(DabblerSizing.touchTargetMin));

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
      expect(find.bySemanticsLabel('Hide password'), findsOneWidget);
    });

    testWidgets('multiline is top-aligned and takes its rows', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerTextField(
            variant: DabblerTextFieldVariant.multiline,
            rows: 2,
          ),
        ),
      );
      final DabblerFieldShell shell =
          tester.widget<DabblerFieldShell>(find.byType(DabblerFieldShell));
      expect(shell.align, DabblerFieldAlign.start);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).maxLines,
        2,
      );
    });

    testWidgets('select is a button, holds focus while open, and rotates', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          DabblerTextField(
            variant: DabblerTextFieldVariant.select,
            label: 'Sport',
            value: 'padel',
            open: true,
            onPressed: () => taps++,
          ),
        ),
      );
      expect(find.byType(EditableText), findsNothing);
      final DabblerFieldShell shell =
          tester.widget<DabblerFieldShell>(find.byType(DabblerFieldShell));
      expect(shell.focused, isTrue, reason: 'open holds the focus state');
      expect(
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
        0.5,
      );
      await tester.tap(find.byType(DabblerSurface));
      expect(taps, 1);
    });

    testWidgets('a disabled select does not fire', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          DabblerTextField(
            variant: DabblerTextFieldVariant.select,
            value: 'padel',
            enabled: false,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(DabblerSurface), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('a select with no value shows the placeholder in textSecondary', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerTextField(
            variant: DabblerTextFieldVariant.select,
            placeholder: 'pick a sport',
          ),
        ),
      );
      // D-003(a): a placeholder is text under WCAG, so it takes the
      // ink-soft-backed secondary role — never a surface neutral.
      expect(
        tester.widget<Text>(find.text('pick a sport')).style!.color,
        _colors().textSecondary,
      );
    });
  });

  group('the shell is composed, not restated', () {
    test('the focus ring width is DS-200s, not a local constant', () {
      expect(
        DabblerFieldShell.borderWidthFor(
          disabled: false,
          hasError: false,
          focused: true,
        ),
        DabblerFocusRing.ringWidth,
      );
    });

    test('no ring geometry or press constant is declared in the forms files',
        () {
      for (final String path in <String>[
        'lib/src/forms/field_shell.dart',
        'lib/src/forms/text_field.dart',
      ]) {
        final String source = File(path).readAsStringSync();
        final String code = source
            .split('\n')
            .where((String l) => !l.trimLeft().startsWith('///'))
            .where((String l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        expect(
          RegExp(r'Color\(0x').hasMatch(code),
          isFalse,
          reason: '$path must take every colour from the tokens',
        );
        expect(
          RegExp(r'outlineOffset|ringWidth\s*=|pressScale\s*=').hasMatch(code),
          isFalse,
          reason: '$path must not restate an interaction constant',
        );
      }
    });
  });
}
