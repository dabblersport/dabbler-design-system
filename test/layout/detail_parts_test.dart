import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

const String _arabic = 'مباراة الثلاثاء';

void main() {
  for (final TextDirection d in TextDirection.values) {
    final String dir = d == TextDirection.rtl ? 'rtl' : 'ltr';
    final String title = d == TextDirection.rtl ? _arabic : 'Tuesday 5-a-side';

    group('Details parts — $dir', () {
      testWidgets('DetailHeader paints the sport band and shows its text', (
        WidgetTester t,
      ) async {
        await t.pumpWidget(
          host(
            DabblerDetailHeader(
              leading: DabblerOnColorIconButton(
                icon: 'arrow-circle-left',
                semanticLabel: 'Back',
                mirrorInRtl: true,
                onPressed: () {},
              ),
              chips: const <String>['Upcoming'],
              title: title,
              place: 'Dubai',
              meta: '2 km',
            ),
            direction: d,
          ),
        );
        expect(find.text(title), findsOneWidget);
        expect(find.text('Upcoming'), findsOneWidget);
        final ColoredBox band = t.widget<ColoredBox>(
          find
              .descendant(
                of: find.byType(DabblerDetailHeader),
                matching: find.byType(ColoredBox),
              )
              .first,
        );
        expect(
          band.color,
          DabblerColors.resolve(
            theme: DabblerTheme.sport,
            brightness: Brightness.light,
          ).brandPrimary,
        );
        expect(t.takeException(), isNull);
      });

      testWidgets('GalleryHero pages and shows captions', (
        WidgetTester t,
      ) async {
        int page = 0;
        await t.pumpWidget(
          host(
            DabblerGalleryHero(
              slides: <DabblerGallerySlide>[
                DabblerGallerySlide(label: title),
                const DabblerGallerySlide(label: 'Two'),
              ],
              onPageChanged: (int p) => page = p,
            ),
            direction: d,
          ),
        );
        expect(find.text(title), findsOneWidget);
        await t.drag(
          find.byType(PageView),
          Offset(d == TextDirection.rtl ? 300 : -300, 0),
        );
        await t.pumpAndSettle();
        expect(page, 1);
        expect(
          t.getSize(find.byType(DabblerGalleryHero)).height,
          DabblerGalleryHero.height,
        );
      });

      testWidgets('ActionBar lays price and primary action', (
        WidgetTester t,
      ) async {
        await t.pumpWidget(
          host(
            DabblerActionBar(
              price: 'AED 40',
              caption: title,
              primary: DabblerButton(
                label: 'Join',
                fullWidth: true,
                onPressed: () {},
              ),
            ),
            direction: d,
          ),
        );
        expect(find.text('AED 40'), findsOneWidget);
        expect(find.text('Join'), findsOneWidget);
        final double priceX = t.getTopLeft(find.text('AED 40')).dx;
        final double joinX = t.getTopLeft(find.text('Join')).dx;
        expect(d == TextDirection.rtl ? priceX > joinX : priceX < joinX, true);
      });

      testWidgets('ListGroup draws rows; a tappable row fires', (
        WidgetTester t,
      ) async {
        int taps = 0;
        await t.pumpWidget(
          host(
            DabblerListGroup(
              tone: DabblerListGroupTone.info,
              children: <Widget>[
                DabblerListRow(
                  overline: 'Phone',
                  title: title,
                  showChevron: true,
                  onTap: () => taps++,
                ),
                const DabblerListRow(title: 'Two', subtitle: 'sub'),
              ],
            ),
            direction: d,
          ),
        );
        expect(find.byType(DabblerDivider), findsOneWidget);
        await t.tap(find.text(title));
        expect(taps, 1);
      });

      testWidgets('Headcount shows headline, caption and bar', (
        WidgetTester t,
      ) async {
        await t.pumpWidget(
          host(
            DabblerHeadcount(
              headline: title,
              caption: 'Full',
              progress: 1,
              critical: true,
            ),
            direction: d,
          ),
        );
        expect(find.text(title), findsOneWidget);
        expect(find.byType(DabblerProgressBar), findsOneWidget);
      });

      testWidgets('StatTile detail size, success tone and Section label', (
        WidgetTester t,
      ) async {
        await t.pumpWidget(
          host(
            Column(
              children: <Widget>[
                SizedBox(
                  height: 100,
                  child: DabblerStatTile(
                    size: DabblerStatTileSize.detail,
                    tone: DabblerStatTileTone.success,
                    value: title,
                    label: 'Daily',
                  ),
                ),
                DabblerSection(
                  style: DabblerSectionStyle.label,
                  title: 'Spaces',
                  subtitle: 'three',
                  children: <Widget>[DabblerChip(label: title, compact: true)],
                ),
              ],
            ),
            direction: d,
          ),
        );
        expect(find.text('Spaces'), findsOneWidget);
        expect(find.text('three'), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    });
  }
}
