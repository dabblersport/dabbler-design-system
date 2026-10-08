import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/media/image.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-410 item b — DabblerImage.
///
/// No real network: flutter_test answers every request with HTTP 400, which
/// is exactly the failing-image path.

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    MaterialApp(
      theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
      home: Directionality(
        textDirection: direction,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 300, child: child),
        ),
      ),
    );

Future<void> _settleFailure(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pump();
}

Color? _fillOf(WidgetTester tester) {
  final Iterable<ColoredBox> boxes = tester.widgetList<ColoredBox>(
    find.descendant(
      of: find.byType(DabblerImage),
      matching: find.byType(ColoredBox),
    ),
  );
  return boxes.first.color;
}

void main() {
  testWidgets('null URL: sunken fill, no Image, no glyph', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const DabblerImage(height: 100)));
    expect(find.byType(Image), findsNothing);
    expect(find.byType(DabblerIcon), findsNothing);
    expect(_fillOf(tester), _colors.surfaceSunken);
    expect(tester.getSize(find.byType(DabblerImage)), const Size(300, 100));
  });

  testWidgets('blank URL is treated as null', (WidgetTester tester) async {
    await tester.pumpWidget(_host(const DabblerImage(url: '  ', height: 50)));
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('loading: an Image is requested and nothing errors yet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(const DabblerImage(url: 'https://example.invalid/a.png')),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(DabblerIcon), findsNothing);
    expect(_fillOf(tester), _colors.surfaceSunken);
  });

  testWidgets('a failing image shows the glyph and the localised label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerImage(
          url: 'https://example.invalid/broken.png',
          height: 120,
          errorLabel: 'تعذّر تحميل الصورة',
        ),
      ),
    );
    await _settleFailure(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(DabblerIcon), findsOneWidget);
    expect(find.text('تعذّر تحميل الصورة'), findsOneWidget);
    // Same frame size as the loading state.
    expect(tester.getSize(find.byType(DabblerImage)), const Size(300, 120));
  });

  testWidgets('error without a label shows the glyph alone', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerImage(
          url: 'https://example.invalid/broken.png',
          height: 120,
        ),
      ),
    );
    await _settleFailure(tester);
    expect(find.byType(DabblerIcon), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('aspect ratio sizes the frame from the width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const DabblerImage(aspectRatio: 2)));
    expect(tester.getSize(find.byType(DabblerImage)), const Size(300, 150));
  });

  testWidgets('scrim draws the scrim role over the fill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const DabblerImage(height: 80, scrim: true)));
    final Iterable<Color> colors = tester
        .widgetList<ColoredBox>(
          find.descendant(
            of: find.byType(DabblerImage),
            matching: find.byType(ColoredBox),
          ),
        )
        .map((ColoredBox b) => b.color);
    expect(colors, contains(_colors.scrim));

    await tester.pumpWidget(_host(const DabblerImage(height: 80)));
    final Iterable<Color> without = tester
        .widgetList<ColoredBox>(
          find.descendant(
            of: find.byType(DabblerImage),
            matching: find.byType(ColoredBox),
          ),
        )
        .map((ColoredBox b) => b.color);
    expect(without, isNot(contains(_colors.scrim)));
  });

  testWidgets('radius param reaches the clip; default is the xl corner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const DabblerImage(height: 80)));
    expect(
      tester.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius,
      DabblerRadius.xlAll,
    );
    await tester.pumpWidget(
      _host(const DabblerImage(height: 80, radius: DabblerRadius.lgAll)),
    );
    expect(
      tester.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius,
      DabblerRadius.lgAll,
    );
  });

  testWidgets('semantics: decorative by default, labelled when named', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const DabblerImage(height: 80)));
    expect(find.bySemanticsLabel('Pitch at dusk'), findsNothing);
    await tester.pumpWidget(
      _host(const DabblerImage(height: 80, semanticLabel: 'Pitch at dusk')),
    );
    expect(find.bySemanticsLabel('Pitch at dusk'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('onTap makes the image a button', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      _host(
        DabblerImage(
          height: 80,
          semanticLabel: 'Open photo',
          onTap: () => taps++,
        ),
      ),
    );
    await tester.tap(find.byType(DabblerImage));
    expect(taps, 1);
  });

  testWidgets('overlay sits at the inline-start corner and mirrors in RTL', (
    WidgetTester tester,
  ) async {
    const Key key = ValueKey<String>('overlay');
    const Widget overlay = SizedBox(key: key, width: 20, height: 10);

    await tester.pumpWidget(
      _host(const DabblerImage(height: 100, overlay: overlay)),
    );
    final Rect ltr = tester.getRect(find.byKey(key));
    final Rect frameLtr = tester.getRect(find.byType(DabblerImage));
    expect(ltr.left - frameLtr.left, DabblerImage.overlayInset);
    expect(ltr.top - frameLtr.top, DabblerImage.overlayInset);

    await tester.pumpWidget(
      _host(
        const DabblerImage(height: 100, overlay: overlay),
        direction: TextDirection.rtl,
      ),
    );
    final Rect rtl = tester.getRect(find.byKey(key));
    final Rect frameRtl = tester.getRect(find.byType(DabblerImage));
    expect(frameRtl.right - rtl.right, DabblerImage.overlayInset);
  });

  testWidgets('fit defaults to cover and passes contain through', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerImage(url: 'https://example.invalid/a.png', height: 80),
      ),
    );
    expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.cover);

    await tester.pumpWidget(
      _host(
        const DabblerImage(
          url: 'https://example.invalid/a.png',
          height: 80,
          fit: BoxFit.contain,
        ),
      ),
    );
    expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.contain);
  });

  testWidgets('headers reach the network image provider', (
    WidgetTester tester,
  ) async {
    const Map<String, String> headers = <String, String>{'Accept': 'image/*'};
    await tester.pumpWidget(
      _host(
        const DabblerImage(
          url: 'https://example.invalid/b.png',
          height: 80,
          headers: headers,
        ),
      ),
    );
    final NetworkImage provider =
        tester.widget<Image>(find.byType(Image)).image as NetworkImage;
    expect(provider.headers, headers);
  });

  testWidgets('contain + headers keep the failure path and semantics, RTL', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const DabblerImage(
          url: 'https://example.invalid/c.png',
          height: 80,
          fit: BoxFit.contain,
          headers: <String, String>{'User-Agent': 'dabbler'},
          semanticLabel: 'Pitch',
          errorLabel: 'Could not load',
        ),
        direction: TextDirection.rtl,
      ),
    );
    await _settleFailure(tester);
    expect(find.text('Could not load'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Pitch')), findsOneWidget);
    handle.dispose();
  });

  group('placeholderGlyph', () {
    testWidgets('null url draws the bare fill by default', (tester) async {
      await tester.pumpWidget(
        _host(const DabblerImage(url: null, height: 120)),
      );
      expect(find.byType(DabblerIcon), findsNothing);
    });

    testWidgets('null url draws the gallery glyph when asked', (tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerImage(url: null, height: 120, placeholderGlyph: true),
        ),
      );
      expect(find.byType(DabblerIcon), findsOneWidget);
    });
  });
}
