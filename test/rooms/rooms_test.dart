import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/rooms/mini_player.dart';
import 'package:dabbler_design_system/src/rooms/speaker_grid.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

DabblerColors _c([Brightness b = Brightness.light]) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: b);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  Brightness brightness = Brightness.light,
  double width = 384,
}) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_c(brightness)]),
  home: Directionality(
    textDirection: direction,
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: child),
      ),
    ),
  ),
);

void main() {
  group('DabblerMiniPlayer — MiniPlayer.jsx', () {
    test('constants and tone colours', () {
      expect(DabblerMiniPlayer.radius, 16);
      expect(DabblerMiniPlayer.avatarSide, 28);
      expect(DabblerMiniPlayer.avatarStep, 22);
      expect(DabblerMiniPlayer.glyphSize, 18);
      expect(DabblerMiniPlayer.captionWeight, FontWeight.w600);
      final DabblerColors c = _c();
      expect(DabblerMiniPlayer.toneColor(c, DabblerMiniPlayerTone.brand),
          c.brandPrimary);
      expect(DabblerMiniPlayer.toneColor(c, DabblerMiniPlayerTone.muted),
          c.textSecondary);
      expect(DabblerMiniPlayer.toneColor(c, DabblerMiniPlayerTone.accent),
          c.accent);
    });

    testWidgets('the caption is caption-1 12 at weight 600 on one line', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerMiniPlayer(caption: 'Design room · 134 listening'),
        ),
      );
      final Text t = tester.widget<Text>(find.textContaining('Design room'));
      expect(t.style!.fontSize, 12);
      expect(t.style!.fontWeight, FontWeight.w600);
      expect(t.maxLines, 1);
    });

    testWidgets('actions are icons at 18, the tap area is 45, and onTap fires',
        (WidgetTester tester) async {
      final SemanticsHandle h = tester.ensureSemantics();
      int liked = 0;
      await tester.pumpWidget(
        _host(
          DabblerMiniPlayer(
            caption: 'c',
            actions: <DabblerMiniPlayerAction>[
              DabblerMiniPlayerAction(
                icon: 'heart',
                label: 'Like',
                weight: DabblerIconWeight.bold,
                tone: DabblerMiniPlayerTone.accent,
                onTap: () => liked++,
              ),
              const DabblerMiniPlayerAction(icon: 'sms', label: 'Chat'),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(DabblerIcon).first), const Size(18, 18));
      expect(tester.getSize(find.bySemanticsLabel('Like')).width,
          greaterThanOrEqualTo(45));
      await tester.tap(find.bySemanticsLabel('Like'));
      expect(liked, 1);
      final SemanticsNode chat = tester.getSemantics(
        find.bySemanticsLabel('Chat'),
      );
      expect(chat.flagsCollection.isButton, isFalse,
          reason: 'no onTap: decorative');
      h.dispose();
    });

    testWidgets('avatars overlap by 6 (step 22 on 28)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerMiniPlayer(
            caption: 'c',
            avatarSeeds: <String>['a', 'b', 'c'],
          ),
        ),
      );
      final List<double> xs = tester
          .widgetList<DabblerAvatar>(find.byType(DabblerAvatar))
          .map((DabblerAvatar a) => tester.getTopLeft(find.byWidget(a)).dx)
          .toList();
      expect(xs[1] - xs[0], 22);
      expect(xs[2] - xs[1], 22);
    });

    testWidgets('RTL and dark render', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerMiniPlayer(
            caption: 'غرفة التصميم',
            avatarSeeds: <String>['a'],
            actions: <DabblerMiniPlayerAction>[
              DabblerMiniPlayerAction(icon: 'sms', label: 'x'),
            ],
          ),
          direction: TextDirection.rtl,
          brightness: Brightness.dark,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('DabblerSpeakerGrid — SpeakerGrid.jsx', () {
    const List<DabblerSpeaker> six = <DabblerSpeaker>[
      DabblerSpeaker(name: 'Alen', badge: DabblerSpeakerBadge.speaking),
      DabblerSpeaker(name: 'Maya', badge: DabblerSpeakerBadge.speaking),
      DabblerSpeaker(name: 'Sara'),
      DabblerSpeaker(name: 'Josh', badge: DabblerSpeakerBadge.invite),
      DabblerSpeaker(name: 'Nina', badge: DabblerSpeakerBadge.speaking),
      DabblerSpeaker(name: 'Drew'),
    ];

    test('constants are the source', () {
      expect(DabblerSpeakerGrid.columns, 3);
      expect(DabblerSpeakerGrid.cellWidth, 96);
      expect(DabblerSpeakerGrid.rowHeight, 88);
      expect(DabblerSpeakerGrid.gap, 16);
      expect(DabblerSpeakerGrid.avatarSide, 64);
      expect(DabblerSpeakerGrid.badgeSide, 24);
      expect(DabblerSpeakerGrid.badgeOffset, 42);
    });

    test('badge fills', () {
      final DabblerColors c = _c();
      expect(DabblerSpeakerGrid.badgeFillFor(c, DabblerSpeakerBadge.speaking),
          c.brandPrimary);
      expect(DabblerSpeakerGrid.badgeFillFor(c, DabblerSpeakerBadge.invite),
          DabblerPalette.activeP600);
      expect(DabblerSpeakerGrid.badgeFillFor(c, DabblerSpeakerBadge.none).a, 0);
    });

    testWidgets('six speakers fill the source 320 x 192 frame', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerSpeakerGrid(speakers: six), width: 320),
      );
      expect(
        tester.getSize(find.byType(DabblerSpeakerGrid)),
        const Size(320, 192),
      );
    });

    testWidgets('cells land in three columns and add rows past six', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerSpeakerGrid(
            speakers: <DabblerSpeaker>[
              ...six,
              const DabblerSpeaker(name: 'Zed'),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(DabblerSpeakerGrid)).height,
          3 * 88 + 2 * 16);
      final double a = tester.getCenter(find.text('Alen')).dx;
      final double m = tester.getCenter(find.text('Maya')).dx;
      expect(m - a, 96 + 16);
      expect(tester.getTopLeft(find.text('Josh')).dy,
          greaterThan(tester.getTopLeft(find.text('Alen')).dy));
    });

    testWidgets('names are caption-1 12 at 600; avatars are the 64 size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerSpeakerGrid(speakers: six)));
      final Text t = tester.widget<Text>(find.text('Alen'));
      expect(t.style!.fontSize, 12);
      expect(t.style!.fontWeight, FontWeight.w600);
      expect(tester.getSize(find.byType(DabblerAvatar).first),
          const Size(64, 64));
    });

    testWidgets('a speaking cell is announced as speaking', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerSpeakerGrid(speakers: six)));
      expect(find.bySemanticsLabel('Alen, speaking'), findsOneWidget);
      expect(find.bySemanticsLabel('Sara'), findsOneWidget);
      h.dispose();
    });

    testWidgets('empty renders nothing; RTL mirrors the first column', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerSpeakerGrid(speakers: <DabblerSpeaker>[])),
      );
      expect(tester.getSize(find.byType(DabblerSpeakerGrid)).height, 0);
      await tester.pumpWidget(
        _host(
          const DabblerSpeakerGrid(speakers: six),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        tester.getCenter(find.text('Alen')).dx,
        greaterThan(tester.getCenter(find.text('Maya')).dx),
      );
    });
  });
}
