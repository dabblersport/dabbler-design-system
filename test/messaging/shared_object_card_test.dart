// Pins values from the live Claude Design project
// 4286affa-bf50-4ff6-9576-917f76a93ca1, file
// components/messaging/SharedObjectCard.jsx (mirror of 2026-10-02): `PASTEL`,
// and tokens/colors.css:90-91 (`--tile-info-surface:#DCEAFB`,
// `--tile-accent-surface:#FBE0EC`).
import 'package:dabbler_design_system/src/controls/button.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/messaging/messaging_foundations.dart';
import 'package:dabbler_design_system/src/messaging/messaging_parts.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/surfaces/badge.dart';
import 'package:dabbler_design_system/src/surfaces/icon_tile.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import 'messaging_parts_host.dart';

const Color _info = Color(0xFFDCEAFB);
const Color _accent = Color(0xFFFBE0EC);

BoxDecoration _frame(WidgetTester t) =>
    t
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byType(DabblerSharedObjectCard),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

BoxDecoration _chip(WidgetTester t, String label) =>
    t
            .widget<DecoratedBox>(
              find
                  .ancestor(
                    of: find.text(label),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

void main() {
  test('PASTEL mapping per kind', () {
    final c = partsColors();
    expect(
      DabblerSharedObjectCard.surfaceFor(c, DabblerSharedKind.game),
      _info,
    );
    expect(
      DabblerSharedObjectCard.surfaceFor(c, DabblerSharedKind.venue),
      _info,
    );
    expect(
      DabblerSharedObjectCard.surfaceFor(c, DabblerSharedKind.player),
      _accent,
    );
    expect(DabblerSharedObjectCard.chipFor(c, DabblerSharedKind.game), _accent);
    expect(DabblerSharedObjectCard.chipFor(c, DabblerSharedKind.player), _info);
    expect(
      DabblerSharedObjectCard.chipFor(c, DabblerSharedKind.venue),
      c.surfaceCard,
    );
  });

  testWidgets('game: pastel frame, 36 tile, badge, meta, footnote, cta; '
      'title clamps', (tester) async {
    int taps = 0;
    await tester.pumpWidget(
      partsHost(
        DabblerSharedObjectCard(
          title: 'Friday 5-a-side',
          subtitle: 'Hosted by Omar',
          status: DabblerActivityStatus.confirmed,
          meta: const <DabblerSharedMeta>[
            DabblerSharedMeta(icon: 'calendar', text: 'Fri 19:00'),
          ],
          chips: const <String>['ignored on a game'],
          footnote: '8 of 10',
          cta: 'View game',
          onPress: () => taps++,
        ),
        width: 268,
      ),
    );
    final c = partsColors();
    final BoxDecoration f = _frame(tester);
    expect(f.color, _info);
    expect(f.borderRadius, BorderRadius.circular(12));
    expect((f.border! as Border).top.color, c.borderDefault);
    expect(tester.getSize(find.byType(DabblerIconTile)), const Size(36, 36));
    expect(find.widgetWithText(DabblerBadge, 'Confirmed'), findsOneWidget);
    expect(find.text('ignored on a game'), findsNothing);
    expect(tester.widget<Text>(find.text('Friday 5-a-side')).maxLines, 1);
    final DabblerIcon m = tester.widget(
      find.byWidgetPredicate((w) => w is DabblerIcon && w.name == 'calendar'),
    );
    expect(m.size, 14);
    expect(m.weight, DabblerIconWeight.bold);
    expect(m.color, c.brandPrimary);
    expect(
      tester.widget<Text>(find.text('Fri 19:00')).style!.color,
      c.textSecondary,
    );
    expect(
      tester.widget<Text>(find.text('8 of 10')).style!.color,
      c.textSecondary,
    );
    // content inset = 1px border + 12px padding, as in CSS.
    final Offset origin = tester.getTopLeft(
      find.byType(DabblerSharedObjectCard),
    );
    expect(tester.getTopLeft(find.byType(DabblerIconTile)).dx - origin.dx, 13);
    expect(tester.getTopLeft(find.text('Friday 5-a-side')).dy - origin.dy, 13);
    await tester.tap(find.byType(DabblerButton));
    expect(taps, 1);
  });

  testWidgets('player: accent ground, md avatar, info chips with ink label', (
    tester,
  ) async {
    await tester.pumpWidget(
      partsHost(
        const DabblerSharedObjectCard(
          kind: DabblerSharedKind.player,
          title: 'Lina Haddad',
          subtitle: 'Midfielder',
          chips: <String>['Football'],
          footnote: 'not shown on a player',
        ),
        width: 268,
      ),
    );
    expect(_frame(tester).color, _accent);
    expect(
      tester.widget<DabblerAvatar>(find.byType(DabblerAvatar)).size,
      DabblerAvatarSize.md,
    );
    expect(_chip(tester, 'Football').color, _info);
    expect(
      tester.widget<Text>(find.text('Football')).style!.color,
      partsColors().textPrimary,
    );
    expect(find.text('not shown on a player'), findsNothing);
    expect(tester.widget<Text>(find.text('Lina Haddad')).maxLines, isNull);
  });

  testWidgets('venue: 120px slot with placeholder, card-filled chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      partsHost(
        const DabblerSharedObjectCard(
          kind: DabblerSharedKind.venue,
          title: 'Al Nahda Hub',
          chips: <String>['Indoor'],
        ),
        width: 268,
      ),
    );
    expect(_frame(tester).color, _info);
    expect(find.text('Venue photo'), findsOneWidget);
    final Finder slot = find
        .ancestor(of: find.text('Venue photo'), matching: find.byType(SizedBox))
        .first;
    expect(tester.getSize(slot).height, 120);
    expect(_chip(tester, 'Indoor').color, partsColors().surfaceCard);
    await tester.pumpWidget(
      partsHost(
        const DabblerSharedObjectCard(
          kind: DabblerSharedKind.venue,
          title: 'Al Nahda Hub',
          photo: ColoredBox(key: Key('photo'), color: Color(0xFF000000)),
        ),
        width: 268,
      ),
    );
    expect(find.text('Venue photo'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('photo'))),
      const Size(266, 120),
    );
  });

  testWidgets('RTL: sport tile at the right, badge at the left; Arabic title', (
    tester,
  ) async {
    await tester.pumpWidget(
      partsHost(
        const DabblerSharedObjectCard(
          title: 'مباراة الجمعة',
          status: DabblerActivityStatus.open,
          statusLabel: 'مفتوحة',
        ),
        width: 268,
        direction: TextDirection.rtl,
      ),
    );
    final Rect card = tester.getRect(find.byType(DabblerSharedObjectCard));
    expect(card.right - tester.getRect(find.byType(DabblerIconTile)).right, 13);
    expect(
      tester.getCenter(find.byType(DabblerBadge)).dx,
      lessThan(card.center.dx),
    );
    final double latin = DabblerType.subheadline
        .resolveForDirection(TextDirection.ltr)
        .fontSize!;
    expect(
      tester.widget<Text>(find.text('مباراة الجمعة')).style!.fontSize,
      closeTo(latin - 0.9, 0.001),
    );
  });

  testWidgets('renders PNGs for each kind in both directions', (tester) async {
    for (final TextDirection d in TextDirection.values) {
      final bool ar = d == TextDirection.rtl;
      for (final DabblerSharedKind k in DabblerSharedKind.values) {
        final f = await renderPng(
          tester,
          SizedBox(
            width: 268,
            child: DabblerSharedObjectCard(
              kind: k,
              title: ar ? 'مباراة الجمعة' : 'Friday 5-a-side',
              subtitle: ar ? 'يستضيفها عمر' : 'Hosted by Omar',
              status: DabblerActivityStatus.confirmed,
              meta: <DabblerSharedMeta>[
                DabblerSharedMeta(
                  icon: 'location',
                  text: ar ? 'ملعب النهضة' : 'Al Nahda',
                ),
              ],
              chips: <String>[ar ? 'داخلي' : 'Indoor'],
              footnote: ar ? '8 من 10' : '8 of 10',
              cta: ar ? 'عرض' : 'View',
              onPress: () {},
            ),
          ),
          name: 'shared_object_card_${k.name}_${d.name}',
          size: const Size(300, 380),
          direction: d,
          alignment: Alignment.center,
        );
        expect(f.lengthSync(), greaterThan(0));
      }
    }
  });

  testWidgets('CTA hit box clears the 45 floor (D-039)', (tester) async {
    // Dabbler/dabbler-docs/DECISIONS.md:13014 (D-032) and :13611 (D-039):
    // the hit box is not the painted mark; every target clears 45.
    int taps = 0;
    await tester.pumpWidget(
      partsHost(
        DabblerSharedObjectCard(
          title: 'Friday 5-a-side',
          cta: 'View game',
          onPress: () => taps++,
        ),
        width: 268,
      ),
    );
    final Size s = tester.getSize(find.byType(DabblerButton));
    expect(s.height, greaterThanOrEqualTo(45));
    expect(s.width, greaterThanOrEqualTo(45));
    await tester.tap(find.byType(DabblerButton));
    expect(taps, 1);
  });
}
