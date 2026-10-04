import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../feed/thread_host.dart';

void main() {
  for (final TextDirection d in TextDirection.values) {
    final bool rtl = d == TextDirection.rtl;
    group('DabblerProfileRow (${d.name})', () {
      testWidgets('lead block, texts, tag and tap', (tester) async {
        int taps = 0;
        await tester.pumpWidget(
          threadHost(
            DabblerProfileRow(
              title: rtl ? 'بادل زوجي' : 'Padel doubles',
              subtitle: rtl ? '٧:٠٠ م' : '7:00 PM',
              lead: '19',
              leadCaption: rtl ? 'الثلاثاء' : 'Tue',
              captionFirst: true,
              tag: rtl ? 'منضم' : 'Joined',
              tone: DabblerProfileRowTone.info,
              onTap: () => taps++,
            ),
            direction: d,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('19'), findsOneWidget);
        final double captionY = tester
            .getTopLeft(find.text(rtl ? 'الثلاثاء' : 'Tue'))
            .dy;
        expect(captionY, lessThan(tester.getTopLeft(find.text('19')).dy));
        await tester.tap(find.byType(DabblerProfileRow));
        expect(taps, 1);
        final double leadX = tester.getCenter(find.text('19')).dx;
        final double tagX = tester
            .getCenter(find.text(rtl ? 'منضم' : 'Joined'))
            .dx;
        expect(rtl ? leadX > tagX : leadX < tagX, isTrue);
      });

      testWidgets('every tone builds without onTap', (tester) async {
        await tester.pumpWidget(
          threadHost(
            Column(
              children: <Widget>[
                for (final DabblerProfileRowTone t
                    in DabblerProfileRowTone.values)
                  DabblerProfileRow(
                    title: 'x',
                    lead: '3/4',
                    leadCaption: 'a',
                    tone: t,
                  ),
              ],
            ),
            direction: d,
          ),
        );
        expect(tester.takeException(), isNull);
      });
    });

    group('DabblerLinkChip (${d.name})', () {
      testWidgets('idle and copied', (tester) async {
        int taps = 0;
        bool copied = false;
        await tester.pumpWidget(
          threadHost(
            StatefulBuilder(
              builder: (context, set) => DabblerLinkChip(
                semanticLabel: 'Copy profile link',
                copied: copied,
                copiedLabel: rtl ? 'تم النسخ' : 'Link copied',
                onTap: () {
                  taps++;
                  set(() => copied = true);
                },
              ),
            ),
            direction: d,
          ),
        );
        expect(find.text('Link copied'), findsNothing);
        await tester.tap(find.byType(DabblerLinkChip));
        await tester.pump();
        expect(taps, 1);
        expect(find.text(rtl ? 'تم النسخ' : 'Link copied'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('DabblerCounterLink taps (${d.name})', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        threadHost(
          DabblerCounterLink(
            value: rtl ? '٤١٢' : '412',
            label: rtl ? 'متابع' : 'Followers',
            onTap: () => taps++,
          ),
          direction: d,
        ),
      );
      await tester.tap(find.byType(DabblerCounterLink));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DabblerAvatar onTap and comfortable badge (${d.name})', (
      tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        threadHost(
          Column(
            children: <Widget>[
              DabblerAvatar(
                seed: 'x',
                semanticLabel: 'Change avatar',
                badge: const DabblerIcon('camera'),
                onTap: () => taps++,
              ),
              DabblerBadge(
                label: rtl ? 'لاعب' : 'Player',
                comfortable: true,
                icon: const DabblerIcon('activity', size: 14),
              ),
              const DabblerBadge(label: 'Player'),
            ],
          ),
          direction: d,
        ),
      );
      await tester.tap(find.byType(DabblerAvatar));
      expect(taps, 1);
      final double big = tester.getSize(find.byType(DabblerBadge).at(0)).height;
      final double small = tester
          .getSize(find.byType(DabblerBadge).at(1))
          .height;
      expect(big, greaterThan(small));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DabblerChip dot builds (${d.name})', (tester) async {
      await tester.pumpWidget(
        threadHost(
          const Row(
            children: <Widget>[
              DabblerChip(label: 'Padel', dot: true),
              DabblerChip(label: 'Football', dot: true, selected: true),
            ],
          ),
          direction: d,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
