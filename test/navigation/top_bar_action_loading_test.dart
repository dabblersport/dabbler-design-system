import 'package:dabbler_design_system/src/feedback/spinner.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/navigation/top_bar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: dir,
        child: Theme(
          data: ThemeData(
            extensions: <ThemeExtension<dynamic>>[
              DabblerColors.resolve(
                theme: DabblerTheme.main,
                brightness: Brightness.light,
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: 390, child: child),
          ),
        ),
      ),
    );

Widget _bar(List<DabblerNavigationAction> actions) =>
    DabblerNavigationTopBar.titled(
      title: 'Edit',
      onBack: () {},
      safeArea: false,
      actions: actions,
    );

void main() {
  test('loading defaults to false and is part of equality', () {
    const DabblerNavigationAction a = DabblerNavigationAction(
      icon: 'sms',
      label: 'Messages',
    );
    const DabblerNavigationAction b = DabblerNavigationAction(
      icon: 'sms',
      label: 'Messages',
      loading: true,
    );
    expect(a.loading, isFalse);
    expect(const DabblerNavigationAction.text(label: 'Save').loading, isFalse);
    expect(a == b, isFalse);
  });

  for (final TextDirection dir in TextDirection.values) {
    group('${dir.name}: icon action loading', () {
      testWidgets('spinner replaces glyph inside the 45 target, inert', (
        t,
      ) async {
        int taps = 0;
        await t.pumpWidget(
          _host(
            _bar(<DabblerNavigationAction>[
              DabblerNavigationAction(
                icon: 'tick-circle',
                label: 'Save',
                loading: true,
                onPressed: () => taps++,
              ),
            ]),
            dir: dir,
          ),
        );
        final Finder spinner = find.byType(DabblerSpinner);
        expect(spinner, findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (Widget w) => w is DabblerIcon && w.name == 'tick-circle',
          ),
          findsNothing,
        );
        expect(t.widget<DabblerSpinner>(spinner).size, DabblerSpinnerSize.md);
        final Finder target = find.ancestor(
          of: spinner,
          matching: find.byWidgetPredicate(
            (Widget w) =>
                w is SizedBox &&
                w.width == DabblerNavigationTopBar.actionTarget.width,
          ),
        );
        expect(
          t.getSize(target.first).height,
          greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
        );
        await t.tap(spinner);
        expect(taps, 0);
        final SemanticsHandle h = t.ensureSemantics();
        expect(
          t.getSemantics(target.first),
          matchesSemantics(
            label: 'Save',
            value: DabblerSpinner.defaultLabel,
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
          ),
        );
        h.dispose();
      });

      testWidgets('not loading: glyph drawn and taps fire', (t) async {
        int taps = 0;
        await t.pumpWidget(
          _host(
            _bar(<DabblerNavigationAction>[
              DabblerNavigationAction(
                icon: 'tick-circle',
                label: 'Save',
                onPressed: () => taps++,
              ),
            ]),
            dir: dir,
          ),
        );
        expect(find.byType(DabblerSpinner), findsNothing);
        await t.tap(find.byType(DabblerIcon).last);
        expect(taps, 1);
      });
    });

    group('${dir.name}: text action loading', () {
      testWidgets('spinner replaces label, width kept, inert, name kept', (
        t,
      ) async {
        int taps = 0;
        DabblerNavigationAction action(bool loading) =>
            DabblerNavigationAction.text(
              label: 'Save',
              semanticLabel: 'Save profile',
              loading: loading,
              onPressed: () => taps++,
            );
        await t.pumpWidget(
          _host(_bar(<DabblerNavigationAction>[action(false)]), dir: dir),
        );
        final Rect idle = t.getRect(find.text('Save'));
        await t.pumpWidget(
          _host(_bar(<DabblerNavigationAction>[action(true)]), dir: dir),
        );
        await t.pump();
        final Finder spinner = find.byType(DabblerSpinner);
        expect(spinner, findsOneWidget);
        // The label is laid out but not painted: same footprint, invisible.
        final Finder hidden = find.byType(Visibility);
        expect(t.widget<Visibility>(hidden.last).visible, isFalse);
        expect(t.getRect(find.text('Save', skipOffstage: false)), idle);
        // Spinner centred over where the label was, in either direction.
        expect((t.getCenter(spinner).dx - idle.center.dx).abs(), lessThan(1.0));
        await t.tap(spinner);
        expect(taps, 0);
        final SemanticsHandle h = t.ensureSemantics();
        expect(find.bySemanticsLabel('Save profile'), findsOneWidget);
        expect(
          t.getSemantics(find.bySemanticsLabel('Save profile')),
          matchesSemantics(
            label: 'Save profile',
            value: DabblerSpinner.defaultLabel,
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
          ),
        );
        h.dispose();
      });
    });
  }
}
