import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'forms/_host.dart';

void main() {
  final DabblerColors colors = testColors();
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('chip mutedRemove paints the remove glyph muted (${dir.name})',
        (tester) async {
      await tester.pumpWidget(host(
        Center(child: DabblerChip(label: 'x', onRemove: () {}, mutedRemove: true)),
        direction: dir,
      ));
      final DabblerIcon g = tester.widget(find.byWidgetPredicate(
          (w) => w is DabblerIcon && w.name == DabblerChip.removeIconName));
      expect(g.color, colors.textTertiary);
    });

    testWidgets('post row showActions:false hides the action row (${dir.name})',
        (tester) async {
      await tester.pumpWidget(host(
        const DabblerPostRow(
            name: 'A', time: '1h', place: 'P', body: 'b', sportLabel: 'Padel',
            showActions: false),
        direction: dir,
      ));
      expect(find.byType(DabblerFeedAction), findsNothing);
      expect(find.text('Padel'), findsOneWidget);
    });

    testWidgets('plain top bar has no back disc and centres the title (${dir.name})',
        (tester) async {
      await tester.pumpWidget(host(
        SizedBox(
          width: 400,
          child: DabblerNavigationTopBar.titled(
              title: 'T', onBack: () {}, plain: true, safeArea: false),
        ),
        direction: dir,
      ));
      final Rect bar = tester.getRect(find.byType(DabblerNavigationTopBar));
      final double cx = tester.getCenter(find.text('T')).dx;
      expect((cx - bar.center.dx).abs(), lessThan(1));
    });
  }
}
