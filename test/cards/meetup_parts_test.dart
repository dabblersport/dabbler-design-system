import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

const List<String> _four = <String>['Ahmed', 'Lina', 'Yousef', 'Nadia'];

void main() {
  group('MeetupAttendees', () {
    testWidgets('draws going and capacity, caps the stack at three', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerMeetupAttendees(
            people: _four,
            goingLabel: '24 going',
            capacityLabel: 'Max 40',
          ),
        ),
      );
      expect(find.text('24 going'), findsOneWidget);
      expect(find.text('Max 40'), findsOneWidget);
      final DabblerAvatarGroup g = tester.widget(
        find.byType(DabblerAvatarGroup),
      );
      expect(g.people.length, 3);
      expect(g.overflow, 1);
    });

    testWidgets('full draws the capacity in the error ink', (tester) async {
      await tester.pumpWidget(
        host(
          const DabblerMeetupAttendees(
            people: _four,
            goingLabel: '25 going',
            capacityLabel: 'Full',
            full: true,
          ),
        ),
      );
      final Text t = tester.widget(find.text('Full'));
      expect(t.style!.color, testColors().error.strong);
    });

    testWidgets('nobody yet draws no stack', (tester) async {
      await tester.pumpWidget(
        host(const DabblerMeetupAttendees(goingLabel: '0 going')),
      );
      expect(find.byType(DabblerAvatarGroup), findsNothing);
      expect(find.text('0 going'), findsOneWidget);
    });

    testWidgets('RTL Arabic: the stack leads at the right', (tester) async {
      await tester.pumpWidget(
        host(
          const DabblerMeetupAttendees(
            people: _four,
            goingLabel: '24 ذاهب',
            capacityLabel: 'الحد الأقصى 40',
          ),
          direction: TextDirection.rtl,
        ),
      );
      final double stack = tester.getCenter(find.byType(DabblerAvatarGroup)).dx;
      final double text = tester.getCenter(find.text('24 ذاهب')).dx;
      expect(stack, greaterThan(text));
    });
  });

  group('CardUpcomingRail', () {
    Widget rail({TextDirection d = TextDirection.ltr, VoidCallback? onTap}) =>
        host(
          DabblerCardUpcomingRail(
            month: 'SEP',
            day: '2',
            title: d == TextDirection.rtl ? 'يوغا الغروب' : 'Sunrise run',
            time: '6:00 AM',
            place: 'Kite Beach',
            fraction: 0.4,
            countdownValue: '3',
            countdownUnit: 'hours',
            onTap: onTap,
          ),
          direction: d,
          width: 300,
        );

    testWidgets('draws date, title, time, place and the ring', (tester) async {
      await tester.pumpWidget(rail());
      for (final String t in <String>[
        'SEP',
        '2',
        'Sunrise run',
        '6:00 AM',
        'Kite Beach',
        '3',
        'hours',
      ]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(find.byType(DabblerRing), findsOneWidget);
    });

    testWidgets('tap fires', (tester) async {
      int n = 0;
      await tester.pumpWidget(rail(onTap: () => n++));
      await tester.tap(find.text('Sunrise run'));
      expect(n, 1);
    });

    testWidgets('RTL Arabic: the date block leads at the right', (
      tester,
    ) async {
      await tester.pumpWidget(rail(d: TextDirection.rtl));
      final double date = tester.getCenter(find.text('SEP')).dx;
      final double title = tester.getCenter(find.text('يوغا الغروب')).dx;
      expect(date, greaterThan(title));
    });
  });

  group('RsvpCta', () {
    Widget cta(
      DabblerRsvpCtaState s, {
      VoidCallback? onPressed,
      bool loading = false,
      TextDirection d = TextDirection.ltr,
      String label = 'Label',
    }) => host(
      DabblerRsvpCta(
        state: s,
        label: label,
        onPressed: onPressed,
        loading: loading,
      ),
      direction: d,
    );

    testWidgets('every state draws its label', (tester) async {
      for (final DabblerRsvpCtaState s in DabblerRsvpCtaState.values) {
        await tester.pumpWidget(cta(s, label: s.name, onPressed: () {}));
        expect(find.text(s.name), findsOneWidget, reason: s.name);
      }
    });

    testWidgets('interactive states press, inert states do not', (
      tester,
    ) async {
      for (final DabblerRsvpCtaState s in DabblerRsvpCtaState.values) {
        int n = 0;
        await tester.pumpWidget(cta(s, onPressed: () => n++));
        await tester.tap(find.text('Label'));
        expect(n, s.interactive ? 1 : 0, reason: s.name);
      }
    });

    testWidgets('loading blocks the press', (tester) async {
      int n = 0;
      await tester.pumpWidget(
        cta(DabblerRsvpCtaState.join, onPressed: () => n++, loading: true),
      );
      await tester.tap(find.text('Label'));
      expect(n, 0);
    });

    testWidgets('going is the success status with a tick', (tester) async {
      await tester.pumpWidget(cta(DabblerRsvpCtaState.going));
      final DabblerColors c = testColors();
      expect(
        DabblerRsvpCta.fillOf(c, DabblerRsvpCtaState.going),
        c.success.surface,
      );
      expect(
        DabblerRsvpCta.inkOf(c, DabblerRsvpCtaState.going),
        c.success.strong,
      );
      expect(
        DabblerRsvpCta.borderOf(c, DabblerRsvpCtaState.going),
        c.success.base,
      );
      expect(DabblerRsvpCtaState.going.glyph, 'tick-circle');
      expect(find.byType(DabblerIcon), findsOneWidget);
    });

    testWidgets('join is the brand fill and draws no glyph', (tester) async {
      await tester.pumpWidget(cta(DabblerRsvpCtaState.join));
      final DabblerColors c = testColors();
      expect(
        DabblerRsvpCta.fillOf(c, DabblerRsvpCtaState.join),
        c.brandPrimary,
      );
      expect(find.byType(DabblerIcon), findsNothing);
    });

    testWidgets('inert states take the sunken fill', (tester) async {
      final DabblerColors c = testColors();
      for (final DabblerRsvpCtaState s in <DabblerRsvpCtaState>[
        DabblerRsvpCtaState.closed,
        DabblerRsvpCtaState.started,
        DabblerRsvpCtaState.notVisible,
        DabblerRsvpCtaState.notAllowed,
      ]) {
        expect(DabblerRsvpCta.fillOf(c, s), c.surfaceSunken, reason: s.name);
        expect(s.interactive, isFalse);
      }
    });

    testWidgets('pill heights: bar 52, card 45', (tester) async {
      await tester.pumpWidget(cta(DabblerRsvpCtaState.join));
      expect(tester.getSize(find.byType(DabblerSurface)).height, 52);
      await tester.pumpWidget(
        host(
          const DabblerRsvpCta(
            state: DabblerRsvpCtaState.join,
            label: 'Join',
            size: DabblerRsvpCtaSize.card,
          ),
        ),
      );
      expect(tester.getSize(find.byType(DabblerSurface)).height, 45);
    });

    testWidgets('RTL Arabic: the glyph leads at the right of the label', (
      tester,
    ) async {
      await tester.pumpWidget(
        cta(
          DabblerRsvpCtaState.going,
          d: TextDirection.rtl,
          label: 'أنت ذاهب',
          onPressed: () {},
        ),
      );
      final double icon = tester.getCenter(find.byType(DabblerIcon)).dx;
      final double text = tester.getCenter(find.text('أنت ذاهب')).dx;
      expect(icon, greaterThan(text));
    });
  });

  group('HostCard', () {
    testWidgets('draws caption, name and a working action', (tester) async {
      int n = 0;
      await tester.pumpWidget(
        host(
          DabblerHostCard(
            name: 'Dubai Running Club',
            caption: 'Community host',
            actionLabel: 'Follow',
            onAction: () => n++,
          ),
        ),
      );
      expect(find.text('Community host'), findsOneWidget);
      expect(find.text('Dubai Running Club'), findsOneWidget);
      await tester.tap(find.text('Follow'));
      expect(n, 1);
    });

    testWidgets('without an action draws no pill', (tester) async {
      await tester.pumpWidget(host(const DabblerHostCard(name: 'Mariam')));
      expect(find.text('Follow'), findsNothing);
    });

    testWidgets('RTL Arabic: the action sits at the left', (tester) async {
      await tester.pumpWidget(
        host(
          DabblerHostCard(
            name: 'نادي دبي للجري',
            actionLabel: 'متابعة',
            onAction: () {},
          ),
          direction: TextDirection.rtl,
        ),
      );
      final double action = tester.getCenter(find.text('متابعة')).dx;
      final double name = tester.getCenter(find.text('نادي دبي للجري')).dx;
      expect(action, lessThan(name));
    });
  });

  group('additions to existing parts', () {
    testWidgets('ActionRow selected takes the brand fill and a bold glyph', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerActionRow(
            icon: 'tick-circle',
            label: 'Yes, I am going',
            selected: true,
          ),
        ),
      );
      final DabblerSurface s = tester.widget(find.byType(DabblerSurface));
      expect(s.fill, testColors().brandPrimary);
      final DabblerIcon i = tester.widget(find.byType(DabblerIcon));
      expect(i.weight, DabblerIconWeight.bold);
    });

    testWidgets('DetailHeader tile paints the tile surface with ink text', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerDetailHeader(
            tile: DabblerDetailHeaderTile.amber,
            title: 'Sunrise run',
            place: 'Kite Beach',
            meta: '3 km away',
            extra: 'Today 6:00 AM',
          ),
        ),
      );
      expect(find.text('Today 6:00 AM'), findsOneWidget);
      final ColoredBox box = tester.widget(
        find
            .descendant(
              of: find.byType(DabblerDetailHeader),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(box.color, DabblerColors.tileAmber.surface);
      final Text title = tester.widget(find.text('Sunrise run'));
      expect(title.style!.color, testColors().textPrimary);
    });

    testWidgets('OnColorIconButton onTile washes the ink, not the on-colour', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          DabblerOnColorIconButton(
            onTile: true,
            icon: 'share',
            semanticLabel: 'Share',
            onPressed: () {},
          ),
        ),
      );
      final DecoratedBox d = tester.widget(
        find
            .descendant(
              of: find.byType(DabblerOnColorIconButton),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(
        (d.decoration as BoxDecoration).color,
        testColors().textPrimary.withValues(
          alpha: DabblerOnColorIconButton.tileFillAlpha,
        ),
      );
    });
  });
}
