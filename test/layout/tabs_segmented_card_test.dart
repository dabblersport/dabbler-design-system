import 'package:dabbler_design_system/src/layout/tabs.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-624 — the card-thumb segmented variant, tokens read from
/// `Location.dc.html:539` (track), `:1169` (thumb and label tones).
const List<DabblerTabItem> _items = <DabblerTabItem>[
  DabblerTabItem(id: 'auto', label: 'Auto'),
  DabblerTabItem(id: 'manual', label: 'Manual'),
];

DabblerColors _colors(Brightness brightness) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: brightness);

Widget _host(
  DabblerTabsVariant variant, {
  Brightness brightness = Brightness.light,
}) {
  return MediaQuery(
    data: const MediaQueryData(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: ThemeData(
          brightness: brightness,
          extensions: <ThemeExtension<dynamic>>[_colors(brightness)],
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 360,
            child: DabblerTabs(
              items: _items,
              value: 'auto',
              variant: variant,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
}

AnimatedContainer _pill(WidgetTester tester, String label) =>
    tester.widget<AnimatedContainer>(
      find
          .ancestor(
            of: find.text(label),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );

BoxDecoration _thumb(WidgetTester tester, String label) =>
    _pill(tester, label).decoration! as BoxDecoration;

Color? _labelColor(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style?.color;

void main() {
  for (final Brightness brightness in Brightness.values) {
    group('segmentedCard (${brightness.name})', () {
      final DabblerColors colors = _colors(brightness);

      testWidgets('selected thumb is surface-card, no border, no shadow', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(DabblerTabsVariant.segmentedCard, brightness: brightness),
        );
        await tester.pumpAndSettle();

        final BoxDecoration thumb = _thumb(tester, 'Auto');
        expect(thumb.color, colors.surfaceCard);
        expect(thumb.border, isNull);
        expect(thumb.boxShadow, isNull);
        expect(thumb.borderRadius, DabblerRadius.pillAll);
        expect(_thumb(tester, 'Manual').color, isNull);
      });

      testWidgets('labels: selected is ink, unselected is muted', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(DabblerTabsVariant.segmentedCard, brightness: brightness),
        );
        await tester.pumpAndSettle();

        expect(_labelColor(tester, 'Auto'), colors.textPrimary);
        expect(_labelColor(tester, 'Manual'), colors.textTertiary);
      });
    });
  }

  testWidgets('track and 39/45 geometry match segmented', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(DabblerTabsVariant.segmentedCard));
    await tester.pumpAndSettle();

    final Container track = tester.widget<Container>(
      find
          .ancestor(of: find.text('Auto'), matching: find.byType(Container))
          .last,
    );
    final BoxDecoration trackBox = track.decoration! as BoxDecoration;
    expect(trackBox.color, _colors(Brightness.light).surfaceSunken);
    expect(track.constraints?.maxHeight, DabblerSizing.touchTargetMin);
    expect(
      _pill(tester, 'Auto').constraints?.maxHeight,
      DabblerSizing.touchTargetMin - DabblerSpacing.space2,
    );
  });

  testWidgets('existing segmented stays brand-filled (unchanged)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(DabblerTabsVariant.segmented));
    await tester.pumpAndSettle();

    final DabblerColors colors = _colors(Brightness.light);
    expect(_thumb(tester, 'Auto').color, colors.brandPrimary);
    expect(_labelColor(tester, 'Auto'), colors.onBrand);
    expect(_labelColor(tester, 'Manual'), colors.textSecondary);
  });
}
