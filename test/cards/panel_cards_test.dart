import 'package:dabbler_design_system/src/cards/checklist_panel.dart';
import 'package:dabbler_design_system/src/cards/member_list_panel.dart';
import 'package:dabbler_design_system/src/cards/mutuals_card.dart';
import 'package:dabbler_design_system/src/cards/panel_card.dart';
import 'package:dabbler_design_system/src/forms/checkbox.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

DabblerColors _colors([Brightness b = Brightness.light]) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: b);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[_colors(brightness)],
    ),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('DabblerPanelCard — PanelCard.jsx', () {
    test('constants are the source', () {
      expect(DabblerPanelCard.defaultWidth, 340);
      expect(DabblerPanelCard.frameRadius, 24);
      expect(DabblerPanelCard.panelRadius, 18);
      expect(DabblerPanelCard.inset, 6);
      expect(DabblerPanelCard.dimmedArrowOpacity, 0.4);
    });

    test('frame and on-frame colours per tone', () {
      final DabblerColors c = _colors();
      expect(DabblerPanelCard.frameFor(c, DabblerPanelCardTone.brand),
          c.brandPrimary);
      expect(DabblerPanelCard.frameFor(c, DabblerPanelCardTone.sport),
          DabblerPalette.sportP600);
      expect(DabblerPanelCard.frameFor(c, DabblerPanelCardTone.active),
          DabblerPalette.activeP600);
      expect(DabblerPanelCard.frameFor(c, DabblerPanelCardTone.info),
          c.info.solid);
      expect(DabblerPanelCard.onFrameFor(c, DabblerPanelCardTone.info),
          DabblerPalette.paper);
      expect(DabblerPanelCard.onFrameFor(c, DabblerPanelCardTone.amber),
          DabblerColors.tileAmber.ink);
    });

    testWidgets('is 340 wide by default and 6px inset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerPanelCard(title: 'Tasks', child: Text('body'))),
      );
      expect(tester.getSize(find.byType(DabblerPanelCard)).width, 340);
    });

    testWidgets('title is headline at weight 700, footer is 15/600', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerPanelCard(
            title: 'Tasks',
            footerLabel: 'View all',
            child: Text('body'),
          ),
        ),
      );
      final Text title = tester.widget<Text>(find.text('Tasks'));
      expect(title.style!.fontSize, 17);
      expect(title.style!.fontWeight, FontWeight.w700);
      final Text footer = tester.widget<Text>(find.text('View all'));
      expect(footer.style!.fontSize, 15);
      expect(footer.style!.fontWeight, FontWeight.w600);
    });

    testWidgets('collapsed hides the body; the toggle flips it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      bool collapsed = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext c, StateSetter set) => _host(
            DabblerPanelCard(
              title: 'Tasks',
              collapsed: collapsed,
              onToggle: () => set(() => collapsed = !collapsed),
              child: const Text('body'),
            ),
          ),
        ),
      );
      expect(find.text('body'), findsOneWidget);
      expect(find.bySemanticsLabel('Collapse'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Collapse'));
      await tester.pumpAndSettle();
      expect(find.text('body'), findsNothing);
      expect(find.bySemanticsLabel('Expand'), findsOneWidget);
      h.dispose();
    });

    testWidgets('arrows fire; a missing callback draws dimmed and inert', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      int next = 0;
      await tester.pumpWidget(
        _host(
          DabblerPanelCard(
            title: 'Tasks',
            footerLabel: 'View all',
            onNext: () => next++,
            child: const Text('body'),
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Next'));
      expect(next, 1);
      expect(find.bySemanticsLabel('Previous'), findsNothing,
          reason: 'no onPrev: no button semantics');
      expect(
        tester
            .widgetList<Opacity>(find.byType(Opacity))
            .any((Opacity o) => o.opacity == 0.4),
        isTrue,
      );
      h.dispose();
    });

    testWidgets('headerInside false draws no header or padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerPanelCard(
            title: 'Tasks',
            headerInside: false,
            child: Text('own header'),
          ),
        ),
      );
      expect(find.text('Tasks'), findsNothing);
      expect(find.text('own header'), findsOneWidget);
    });

    testWidgets('every tone renders light, dark, and RTL', (
      WidgetTester tester,
    ) async {
      for (final Brightness b in Brightness.values) {
        for (final DabblerPanelCardTone t in DabblerPanelCardTone.values) {
          await tester.pumpWidget(
            _host(
              DabblerPanelCard(
                tone: t,
                dark: t == DabblerPanelCardTone.info,
                title: 'T',
                footerLabel: 'f',
                onPrev: () {},
                onNext: () {},
                child: const Text('b'),
              ),
              direction: TextDirection.rtl,
              brightness: b,
            ),
          );
          expect(tester.takeException(), isNull, reason: '${t.name} ${b.name}');
        }
      }
    });
  });

  group('DabblerChecklistPanel — ChecklistPanel.jsx', () {
    const List<DabblerChecklistItem> items = <DabblerChecklistItem>[
      DabblerChecklistItem(label: 'One', done: true),
      DabblerChecklistItem(label: 'Two'),
    ];

    test('done rows are muted; dark open rows are page paper', () {
      final DabblerColors c = _colors();
      expect(DabblerChecklistPanel.labelColorFor(c, done: true, dark: false),
          c.textSecondary);
      expect(DabblerChecklistPanel.labelColorFor(c, done: false, dark: false),
          c.textPrimary);
      expect(DabblerChecklistPanel.labelColorFor(c, done: false, dark: true),
          DabblerPalette.surfacePage);
    });

    testWidgets('label is subheadline 15 at weight 500; rows are 6 apart', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerChecklistPanel(items: items)),
      );
      final Text t = tester.widget<Text>(find.text('Two'));
      expect(t.style!.fontSize, 15);
      expect(t.style!.fontWeight, FontWeight.w500);
      expect(DabblerChecklistPanel.rowGap, 6);
    });

    testWidgets('toggling reports the row index and reflects done', (
      WidgetTester tester,
    ) async {
      final List<int> toggled = <int>[];
      await tester.pumpWidget(
        _host(DabblerChecklistPanel(items: items, onToggle: toggled.add)),
      );
      final Finder boxes = find.byType(DabblerCheckbox);
      expect(boxes, findsNWidgets(2));
      expect(tester.widget<DabblerCheckbox>(boxes.first).checked, isTrue);
      expect(tester.widget<DabblerCheckbox>(boxes.last).checked, isFalse);
      await tester.tap(boxes.last);
      expect(toggled, <int>[1]);
    });

    testWidgets('long labels ellipsise on one line', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 200,
            child: DabblerChecklistPanel(
              items: <DabblerChecklistItem>[
                DabblerChecklistItem(label: 'long ' * 40),
              ],
            ),
          ),
        ),
      );
      final Text t = tester.widget<Text>(find.textContaining('long'));
      expect(t.maxLines, 1);
      expect(t.overflow, TextOverflow.ellipsis);
    });
  });

  group('DabblerMemberListPanel — MemberListPanel.jsx', () {
    const List<DabblerMember> people = <DabblerMember>[
      DabblerMember(name: 'Alen', role: 'Organiser', added: true),
      DabblerMember(name: 'Mariam', role: 'Regular'),
    ];

    test('button colours per added and dark', () {
      final DabblerColors c = _colors();
      expect(DabblerMemberListPanel.buttonFillFor(c, added: true, dark: false),
          DabblerPalette.ink);
      expect(DabblerMemberListPanel.buttonFillFor(c, added: true, dark: true),
          c.surfaceCard);
      expect(
          DabblerMemberListPanel.buttonFillFor(c, added: false, dark: false)
              .a,
          0);
      expect(DabblerMemberListPanel.buttonBorderFor(c, added: true, dark: false),
          isNull);
      expect(DabblerMemberListPanel.buttonBorderFor(c, added: false, dark: false),
          c.borderDefault);
      expect(
          DabblerMemberListPanel.buttonBorderFor(c, added: false, dark: true)!
              .a,
          closeTo(0.28, 0.01));
      expect(DabblerMemberListPanel.buttonSide, 32);
    });

    testWidgets('name is 15/700, role is 13; avatars are the sm size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerMemberListPanel(people: people)),
      );
      final Text name = tester.widget<Text>(find.text('Alen'));
      expect(name.style!.fontSize, 15);
      expect(name.style!.fontWeight, FontWeight.w700);
      expect(tester.widget<Text>(find.text('Organiser')).style!.fontSize, 13);
      expect(
        tester.widgetList<DabblerAvatar>(find.byType(DabblerAvatar)).every(
              (DabblerAvatar a) => a.size == DabblerAvatarSize.sm,
            ),
        isTrue,
      );
    });

    testWidgets('the button reports its row, names the action, and keeps a '
        '45px hit area around the 32 disc', (WidgetTester tester) async {
      final SemanticsHandle h = tester.ensureSemantics();
      final List<int> toggled = <int>[];
      await tester.pumpWidget(
        _host(DabblerMemberListPanel(people: people, onToggle: toggled.add)),
      );
      expect(find.bySemanticsLabel('Remove Alen'), findsOneWidget);
      expect(find.bySemanticsLabel('Add Mariam'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Add Mariam'));
      expect(toggled, <int>[1]);
      final Size hit = tester.getSize(find.bySemanticsLabel('Add Mariam'));
      expect(hit.width, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
      expect(hit.height, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
      h.dispose();
    });

    testWidgets('renders dark and RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerMemberListPanel(people: people, dark: true),
          direction: TextDirection.rtl,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('DabblerMutualsCard — MutualsCard.jsx', () {
    testWidgets('card shell: fill, 1px outline, 12 radius; text footnote',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 340,
            child: DabblerMutualsCard(
              avatars: SizedBox(width: 40, height: 36),
              text: 'Followed by Bushra',
            ),
          ),
        ),
      );
      final DecoratedBox box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(DabblerMutualsCard),
          matching: find.byType(DecoratedBox),
        ).first,
      );
      final BoxDecoration d = box.decoration as BoxDecoration;
      final DabblerColors c = _colors();
      expect(d.color, c.surfaceCard);
      expect(d.borderRadius, DabblerRadius.lgAll);
      expect((d.border! as Border).top.color, c.borderDefault);
      final Text t = tester.widget<Text>(find.text('Followed by Bushra'));
      expect(t.style!.fontSize, 13);
      expect(t.style!.color, DabblerPalette.inkSoft);
      expect(DabblerMutualsCard.padding, 12);
    });

    testWidgets('text only renders without avatars, and in RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 300,
            child: DabblerMutualsCard(text: 'يتابعه أصدقاؤك'),
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('يتابعه أصدقاؤك'), findsOneWidget);
    });
  });
}
