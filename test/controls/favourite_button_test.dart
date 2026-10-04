import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Widget _wrap(
  Widget child, {
  TextDirection d = TextDirection.ltr,
  Brightness b = Brightness.light,
}) => host(
  Shortcuts(
    shortcuts: WidgetsApp.defaultShortcuts,
    child: Row(children: <Widget>[child]),
  ),
  direction: d,
  brightness: b,
);

DabblerSurface _well(WidgetTester t) =>
    t.widget<DabblerSurface>(find.byType(DabblerSurface));

DabblerIcon _heart(WidgetTester t) =>
    t.widget<DabblerIcon>(find.byType(DabblerIcon));

void main() {
  for (final Brightness b in Brightness.values) {
    for (final TextDirection d in TextDirection.values) {
      group('DabblerFavouriteButton $b $d', () {
        testWidgets('off: a 32 well, 12 radius, linear secondary heart', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(
            _wrap(
              DabblerFavouriteButton(
                selected: false,
                semanticLabel: 'Save',
                onPressed: () {},
              ),
              d: d,
              b: b,
            ),
          );
          final DabblerColors c = testColors(brightness: b);
          expect(_well(tester).radius, DabblerFavouriteButton.radius);
          expect(DabblerFavouriteButton.radius, 12);
          expect(DabblerFavouriteButton.wellSide, 32);
          expect(
            tester.getSize(find.byType(DabblerSurface)),
            const Size(32, 32),
          );
          final DabblerIcon icon = _heart(tester);
          expect(icon.weight, DabblerIconWeight.linear);
          expect(icon.size, 18);
          expect(icon.color, c.textSecondary);
        });

        testWidgets('on: a bold error heart', (WidgetTester tester) async {
          await tester.pumpWidget(
            _wrap(
              DabblerFavouriteButton(
                selected: true,
                semanticLabel: 'Unsave',
                onPressed: () {},
              ),
              d: d,
              b: b,
            ),
          );
          final DabblerIcon icon = _heart(tester);
          expect(icon.weight, DabblerIconWeight.bold);
          expect(icon.color, testColors(brightness: b).error.base);
        });
      });
    }
  }

  testWidgets('hit area clears the 45 floor around the 32 well', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        DabblerFavouriteButton(
          selected: false,
          semanticLabel: 'Save',
          onPressed: () {},
        ),
      ),
    );
    final Size s = tester.getSize(find.byType(DabblerFavouriteButton));
    expect(s.width, DabblerSizing.touchTargetMin);
    expect(s.height, DabblerSizing.touchTargetMin);
  });

  testWidgets('tap, Enter and Space fire it; disabled does not', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      _wrap(
        DabblerFavouriteButton(
          selected: false,
          semanticLabel: 'Save',
          autofocus: true,
          onPressed: () => taps++,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(DabblerSurface));
    expect(taps, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(taps, 3);

    await tester.pumpWidget(
      _wrap(
        const DabblerFavouriteButton(selected: false, semanticLabel: 'Save'),
      ),
    );
    await tester.tap(find.byType(DabblerSurface), warnIfMissed: false);
    expect(taps, 3);
    expect(
      tester.getSemantics(find.byType(DabblerFavouriteButton)),
      matchesSemantics(
        label: 'Save',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        hasToggledState: true,
        isToggled: false,
      ),
    );
  });

  testWidgets('semantics: a toggle named by its label, state not by colour', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle h = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        DabblerFavouriteButton(
          selected: true,
          semanticLabel: 'Remove from favourites',
          onPressed: () {},
        ),
        d: TextDirection.rtl,
      ),
    );
    expect(
      tester.getSemantics(find.byType(DabblerFavouriteButton)),
      matchesSemantics(
        label: 'Remove from favourites',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasToggledState: true,
        isToggled: true,
      ),
    );
    h.dispose();
  });

  testWidgets('plain: a 36 borderless round heart, no surface', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        DabblerFavouriteButton(
          plain: true,
          selected: true,
          semanticLabel: 'Remove',
          onPressed: () {},
        ),
        d: TextDirection.rtl,
      ),
    );
    expect(find.byType(DabblerSurface), findsNothing);
    expect(
      tester.getSize(find.byType(SizedBox).first),
      isNot(const Size(32, 32)),
    );
    expect(DabblerFavouriteButton.plainSide, 36);
    expect(_heart(tester).color, testColors().error.base);
    expect(_heart(tester).weight, DabblerIconWeight.bold);
  });

  testWidgets('sits at the inline end of a venue card name row in RTL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        DabblerCardVenue(
          name: 'ملعب البادل',
          favourite: DabblerFavouriteButton(
            selected: false,
            semanticLabel: 'حفظ',
            onPressed: () {},
          ),
        ),
        direction: TextDirection.rtl,
        width: 360,
      ),
    );
    final Offset well = tester.getCenter(find.byType(DabblerFavouriteButton));
    final Offset name = tester.getCenter(find.text('ملعب البادل'));
    expect(well.dx, lessThan(name.dx));
  });
}
