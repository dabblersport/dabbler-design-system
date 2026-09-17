import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/layout/tabs.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The three tabs of the design source's own example
/// (`components/controls/buttons.card.html:143-147`).
const List<DabblerTabItem> _items = <DabblerTabItem>[
  DabblerTabItem(id: 'overview', label: 'overview'),
  DabblerTabItem(id: 'players', label: 'players'),
  DabblerTabItem(id: 'chat', label: 'chat'),
];

DabblerColors _colors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

/// The minimum the tabs need: a direction, a [DabblerColors] in the theme, a
/// [MediaQuery] the test controls, and a bounded width.
Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  double width = 360,
  bool disableAnimations = false,
}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Directionality(
      textDirection: direction,
      child: Theme(
        data: ThemeData(
          brightness: brightness,
          extensions: <ThemeExtension<dynamic>>[
            _colors(theme: theme, brightness: brightness),
          ],
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

/// A stateful harness, because the widget is controlled: it reports and
/// redraws, it does not hold the selection.
class _Harness extends StatefulWidget {
  const _Harness({
    this.items = _items,
    this.initial = 'overview',
    this.variant = DabblerTabsVariant.underline,
    this.scrollable = false,
    this.fullWidth = false,
    this.label,
    this.onChanged,
  });

  final List<DabblerTabItem> items;
  final String initial;
  final DabblerTabsVariant variant;
  final bool scrollable;
  final bool fullWidth;
  final String? label;
  final ValueChanged<String>? onChanged;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late String value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DabblerTabs(
          items: widget.items,
          value: value,
          variant: widget.variant,
          scrollable: widget.scrollable,
          fullWidth: widget.fullWidth,
          label: widget.label,
          onChanged: (String id) {
            widget.onChanged?.call(id);
            setState(() => value = id);
          },
        ),
        for (final DabblerTabItem item in widget.items)
          DabblerTabPanel(
            id: item.id,
            value: value,
            child: Text('panel:${item.id}'),
          ),
      ],
    );
  }
}

/// The painted text style of the tab labelled [label].
TextStyle _labelStyle(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style!;

/// The rect of the tab labelled [label], as laid out.
Rect _tabRect(WidgetTester tester, String label) => tester.getRect(
      find
          .ancestor(of: find.text(label), matching: find.byType(GestureDetector))
          .first,
    );

Future<void> _pressKey(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  // ------------------------------------------------------------------
  // AC1 — content switches by `id === value`, an identity match.
  //        Source: components/layout/Tabs.jsx:31 and :154.
  // ------------------------------------------------------------------
  group('AC1 — identity match, not index', () {
    testWidgets('only the panel whose id equals value renders', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness()));

      expect(find.text('panel:overview'), findsOneWidget);
      expect(find.text('panel:players'), findsNothing);
      expect(find.text('panel:chat'), findsNothing);
    });

    testWidgets('a miss renders nothing and occupies no space', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerTabPanel(
            id: 'players',
            value: 'overview',
            child: Text('panel:players'),
          ),
        ),
      );

      expect(find.text('panel:players'), findsNothing);
      expect(tester.getSize(find.byType(DabblerTabPanel)).height, 0);
    });

    testWidgets('reordering the items does not change which panel shows', (
      WidgetTester tester,
    ) async {
      // The whole point of matching on the id: `players` is index 1 in one
      // order and index 2 in the other, and both must show the same panel.
      await tester.pumpWidget(
        _host(const _Harness(initial: 'players')),
      );
      expect(find.text('panel:players'), findsOneWidget);

      const List<DabblerTabItem> reordered = <DabblerTabItem>[
        DabblerTabItem(id: 'overview', label: 'overview'),
        DabblerTabItem(id: 'chat', label: 'chat'),
        DabblerTabItem(id: 'players', label: 'players'),
      ];
      await tester.pumpWidget(
        _host(const _Harness(items: reordered, initial: 'players')),
      );
      await tester.pumpAndSettle();

      expect(find.text('panel:players'), findsOneWidget);
      expect(find.text('panel:overview'), findsNothing);
      expect(find.text('panel:chat'), findsNothing);
    });

    testWidgets('reordering moves the indicator to the tab, not the slot', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness(initial: 'players')));
      await tester.pumpAndSettle();
      final Rect before = _tabRect(tester, 'players');
      expect(tester.getRect(find.byType(ColoredBox).last).left, before.left);

      const List<DabblerTabItem> reordered = <DabblerTabItem>[
        DabblerTabItem(id: 'players', label: 'players'),
        DabblerTabItem(id: 'chat', label: 'chat'),
        DabblerTabItem(id: 'overview', label: 'overview'),
      ];
      await tester.pumpWidget(
        _host(const _Harness(items: reordered, initial: 'players')),
      );
      await tester.pumpAndSettle();

      final Rect after = _tabRect(tester, 'players');
      expect(after.left, isNot(before.left),
          reason: 'the reorder must actually have moved the tab');
      expect(tester.getRect(find.byType(ColoredBox).last).left, after.left);
    });

    testWidgets('a value matching no item falls back to the first tab', (
      WidgetTester tester,
    ) async {
      // `Math.max(0, findIndex(...))` — Tabs.jsx:31.
      await tester.pumpWidget(
        _host(const DabblerTabs(items: _items, value: 'nope')),
      );
      await tester.pumpAndSettle();

      final DabblerColors colors = _colors();
      expect(_labelStyle(tester, 'overview').color, colors.textPrimary);
      expect(_labelStyle(tester, 'players').color, colors.textSecondary);
    });

    testWidgets('a tap reports the tapped tab\'s id', (
      WidgetTester tester,
    ) async {
      final List<String> reported = <String>[];
      await tester.pumpWidget(
        _host(_Harness(onChanged: reported.add)),
      );

      await tester.tap(find.text('chat'));
      await tester.pumpAndSettle();

      expect(reported, <String>['chat']);
      expect(find.text('panel:chat'), findsOneWidget);
      expect(find.text('panel:overview'), findsNothing);
    });

    testWidgets('a null onChanged leaves the tabs inert', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerTabs(items: _items, value: 'overview')),
      );

      await tester.tap(find.text('chat'));
      await tester.pumpAndSettle();

      expect(_labelStyle(tester, 'overview').color, _colors().textPrimary);
    });
  });

  // ------------------------------------------------------------------
  // AC2a — roving arrow-key focus.
  //        Source: Tabs.jsx:55-69, Tabs.prompt.md "Behaviour".
  // ------------------------------------------------------------------
  group('AC2 — roving tab order', () {
    testWidgets('only the active tab is in the tab order', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness(initial: 'players')));
      await tester.pumpAndSettle();

      final List<FocusNode> nodes = tester
          .widgetList<DabblerFocusRing>(find.byType(DabblerFocusRing))
          .map((DabblerFocusRing r) => r.focusNode!)
          .toList();

      expect(nodes.map((FocusNode n) => n.skipTraversal),
          <bool>[true, false, true]);
    });

    testWidgets('the roving order follows the selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('chat'));
      await tester.pumpAndSettle();

      final List<FocusNode> nodes = tester
          .widgetList<DabblerFocusRing>(find.byType(DabblerFocusRing))
          .map((DabblerFocusRing r) => r.focusNode!)
          .toList();

      expect(nodes.map((FocusNode n) => n.skipTraversal),
          <bool>[true, true, false]);
    });
  });

  group('AC2 — arrow keys move and select', () {
    testWidgets('ArrowRight advances and ArrowLeft goes back, in LTR', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('overview'));
      await tester.pumpAndSettle();

      await _pressKey(tester, LogicalKeyboardKey.arrowRight);
      expect(find.text('panel:players'), findsOneWidget);

      await _pressKey(tester, LogicalKeyboardKey.arrowRight);
      expect(find.text('panel:chat'), findsOneWidget);

      await _pressKey(tester, LogicalKeyboardKey.arrowLeft);
      expect(find.text('panel:players'), findsOneWidget);
    });

    testWidgets('the arrow keys swap under RTL — ArrowLeft advances', (
      WidgetTester tester,
    ) async {
      // Tabs.jsx:59-63 and Tabs.prompt.md — "RTL behaviour".
      await tester.pumpWidget(
        _host(const _Harness(), direction: TextDirection.rtl),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('overview'));
      await tester.pumpAndSettle();

      await _pressKey(tester, LogicalKeyboardKey.arrowLeft);
      expect(find.text('panel:players'), findsOneWidget);

      await _pressKey(tester, LogicalKeyboardKey.arrowRight);
      expect(find.text('panel:overview'), findsOneWidget);
    });

    testWidgets('the arrow keys wrap at both ends', (
      WidgetTester tester,
    ) async {
      // `(activeIndex + dir + items.length) % items.length` — Tabs.jsx:56.
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('overview'));
      await tester.pumpAndSettle();

      await _pressKey(tester, LogicalKeyboardKey.arrowLeft);
      expect(find.text('panel:chat'), findsOneWidget);

      await _pressKey(tester, LogicalKeyboardKey.arrowRight);
      expect(find.text('panel:overview'), findsOneWidget);
    });

    testWidgets('Home and End jump to the ends', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _Harness(initial: 'players')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('players'));
      await tester.pumpAndSettle();

      await _pressKey(tester, LogicalKeyboardKey.end);
      expect(find.text('panel:chat'), findsOneWidget);

      await _pressKey(tester, LogicalKeyboardKey.home);
      expect(find.text('panel:overview'), findsOneWidget);
    });

    testWidgets('focus follows selection, so the focused tab stays in order', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('overview'));
      await tester.pumpAndSettle();

      await _pressKey(tester, LogicalKeyboardKey.end);

      final List<FocusNode> nodes = tester
          .widgetList<DabblerFocusRing>(find.byType(DabblerFocusRing))
          .map((DabblerFocusRing r) => r.focusNode!)
          .toList();

      expect(nodes.last.hasFocus, isTrue);
      expect(nodes.last.skipTraversal, isFalse);
    });

    testWidgets('an unhandled key is not swallowed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('overview'));
      await tester.pumpAndSettle();

      await _pressKey(tester, LogicalKeyboardKey.arrowUp);
      expect(find.text('panel:overview'), findsOneWidget);
    });
  });

  // ------------------------------------------------------------------
  // AC2b — a visible focus indicator, via DS-200's shared ring.
  // ------------------------------------------------------------------
  group('AC2 — focus indicator is DS-200, not a local ring', () {
    testWidgets('every tab is wrapped in the shared focus ring', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();

      expect(find.byType(DabblerFocusRing), findsNWidgets(_items.length));
    });

    testWidgets('the ring paints on keyboard focus and never moves anything', (
      WidgetTester tester,
    ) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic;
      });

      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();
      final Rect before = _tabRect(tester, 'players');

      await tester.tap(find.text('overview'));
      await tester.pumpAndSettle();
      await _pressKey(tester, LogicalKeyboardKey.arrowRight);

      final Finder ring = find
          .ancestor(of: find.text('players'), matching: find.byType(CustomPaint))
          .first;
      expect(
        tester.widget<CustomPaint>(ring).foregroundPainter,
        isNotNull,
        reason: 'the focused tab must paint the DS-200 ring',
      );
      // The ring is painted, not laid out — turning it on cannot reflow.
      expect(_tabRect(tester, 'players'), before);
    });

    testWidgets('the segmented ring traces the pill', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const _Harness(
            items: <DabblerTabItem>[
              DabblerTabItem(id: 'list', label: 'list'),
              DabblerTabItem(id: 'map', label: 'map'),
            ],
            initial: 'list',
            variant: DabblerTabsVariant.segmented,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final DabblerFocusRing ring =
          tester.widgetList<DabblerFocusRing>(find.byType(DabblerFocusRing)).first;
      expect(ring.borderRadius, DabblerRadius.pillAll);
    });
  });

  // ------------------------------------------------------------------
  // Touch targets — guidelines/measurements.html:113, "Tabs tabs" are
  // documented consumers of the 45px floor; this ticket requires ≥44×44.
  // ------------------------------------------------------------------
  group('touch targets clear 44x44, measured', () {
    testWidgets('underline tabs', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();

      for (final DabblerTabItem item in _items) {
        final Rect rect = _tabRect(tester, item.label);
        expect(rect.height, DabblerSizing.touchTargetMin);
        expect(rect.height, greaterThanOrEqualTo(44));
        expect(rect.width, greaterThanOrEqualTo(44));
      }
    });

    testWidgets('a one-character label still clears the floor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const _Harness(
            items: <DabblerTabItem>[
              DabblerTabItem(id: 'a', label: 'a'),
              DabblerTabItem(id: 'b', label: 'b'),
            ],
            initial: 'a',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_tabRect(tester, 'a').width,
          greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
    });

    testWidgets('segmented tabs — the pill paints 39, the target is 45', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const _Harness(
            items: <DabblerTabItem>[
              DabblerTabItem(id: 'list', label: 'list'),
              DabblerTabItem(id: 'map', label: 'map'),
            ],
            initial: 'list',
            variant: DabblerTabsVariant.segmented,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Rect target = _tabRect(tester, 'list');
      expect(target.height, DabblerSizing.touchTargetMin);
      expect(target.width, greaterThanOrEqualTo(44));

      // 45 − `--space-2` = 39, the source's own segmented tab height.
      final Size pill = tester.getSize(
        find
            .ancestor(
              of: find.text('list'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(pill.height, DabblerSizing.touchTargetMin - DabblerSpacing.space2);
    });

    testWidgets('a tap in the segmented track padding still selects', (
      WidgetTester tester,
    ) async {
      // The hit box is the full 45 even though the pill paints 39: a tap 1px
      // below the pill's bottom edge must land on the tab.
      final List<String> reported = <String>[];
      await tester.pumpWidget(
        _host(
          _Harness(
            items: const <DabblerTabItem>[
              DabblerTabItem(id: 'list', label: 'list'),
              DabblerTabItem(id: 'map', label: 'map'),
            ],
            initial: 'list',
            variant: DabblerTabsVariant.segmented,
            onChanged: reported.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Rect target = _tabRect(tester, 'map');
      await tester.tapAt(Offset(target.center.dx, target.bottom - 1));
      await tester.pumpAndSettle();

      expect(reported, <String>['map']);
    });
  });

  // ------------------------------------------------------------------
  // Visual transcription — every value against the design source.
  // ------------------------------------------------------------------
  group('visual — transcribed values, no literals', () {
    testWidgets('underline: brand indicator over a --faint rail', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();

      final DabblerColors colors = _colors();
      final List<ColoredBox> boxes =
          tester.widgetList<ColoredBox>(find.byType(ColoredBox)).toList();

      expect(boxes.map((ColoredBox b) => b.color), contains(colors.bgTertiary));
      expect(
          boxes.map((ColoredBox b) => b.color), contains(colors.brandPrimary));
    });

    testWidgets('the indicator is 2px and spans the active tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness(initial: 'players')));
      await tester.pumpAndSettle();

      final Rect tab = _tabRect(tester, 'players');
      final Rect indicator = tester.getRect(find.byType(ColoredBox).last);

      expect(indicator.height, 2);
      expect(indicator.width, tab.width);
      expect(indicator.left, tab.left);
    });

    testWidgets('the rail is 1px — --border-default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();

      final Finder rail = find.byWidgetPredicate(
        (Widget w) => w is ColoredBox && w.color == _colors().bgTertiary,
      );
      expect(tester.getSize(rail).height, DabblerSizing.borderDefault);
    });

    testWidgets('underline gap is --space-5, segmented gap is --space-1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();
      expect(
        _tabRect(tester, 'players').left - _tabRect(tester, 'overview').right,
        moreOrLessEquals(DabblerSpacing.space5),
      );

      await tester.pumpWidget(
        _host(
          const _Harness(
            items: <DabblerTabItem>[
              DabblerTabItem(id: 'list', label: 'list'),
              DabblerTabItem(id: 'map', label: 'map'),
            ],
            initial: 'list',
            variant: DabblerTabsVariant.segmented,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        _tabRect(tester, 'map').left - _tabRect(tester, 'list').right,
        moreOrLessEquals(DabblerSpacing.space1),
      );
    });

    testWidgets('labels are .t-subheadline, active at weight 500', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();

      final TextStyle active = _labelStyle(tester, 'overview');
      final TextStyle inactive = _labelStyle(tester, 'chat');

      expect(active.fontSize, DabblerType.subheadline.fontSize);
      expect(active.fontWeight, DabblerType.medium);
      expect(inactive.fontWeight, DabblerType.regular);
      expect(active.color, _colors().textPrimary);
      expect(inactive.color, _colors().textSecondary);
    });

    testWidgets('Arabic leading is taken under RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const _Harness(), direction: TextDirection.rtl),
      );
      await tester.pumpAndSettle();

      expect(
        _labelStyle(tester, 'overview').height,
        DabblerType.subheadline.arabicLeading /
            DabblerType.subheadline.fontSize,
      );
    });

    testWidgets('segmented: sunken pill track, brand fill, on-brand ink', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const _Harness(
            items: <DabblerTabItem>[
              DabblerTabItem(id: 'list', label: 'list'),
              DabblerTabItem(id: 'map', label: 'map'),
            ],
            initial: 'list',
            variant: DabblerTabsVariant.segmented,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final DabblerColors colors = _colors();
      final Container track = tester.widget<Container>(
        find
            .ancestor(of: find.text('list'), matching: find.byType(Container))
            .last,
      );
      final BoxDecoration trackBox = track.decoration! as BoxDecoration;
      expect(trackBox.color, colors.surfaceSunken);
      expect(trackBox.borderRadius, DabblerRadius.pillAll);
      expect(track.constraints?.maxHeight, DabblerSizing.touchTargetMin);

      final AnimatedContainer pill = tester.widget<AnimatedContainer>(
        find
            .ancestor(
              of: find.text('list'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect((pill.decoration! as BoxDecoration).color, colors.brandPrimary);
      expect(_labelStyle(tester, 'list').color, colors.onBrand);
      expect(_labelStyle(tester, 'map').color, colors.textSecondary);
    });

    testWidgets('segmented draws no underline indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const _Harness(
            items: <DabblerTabItem>[
              DabblerTabItem(id: 'list', label: 'list'),
              DabblerTabItem(id: 'map', label: 'map'),
            ],
            initial: 'list',
            variant: DabblerTabsVariant.segmented,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ColoredBox), findsNothing);
    });

    testWidgets('flat — nothing in the tree carries a shadow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const _Harness(
            items: <DabblerTabItem>[
              DabblerTabItem(id: 'list', label: 'list'),
              DabblerTabItem(id: 'map', label: 'map'),
            ],
            initial: 'list',
            variant: DabblerTabsVariant.segmented,
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final BoxDecoration d in tester
          .widgetList<Container>(find.byType(Container))
          .map((Container c) => c.decoration)
          .whereType<BoxDecoration>()) {
        expect(d.boxShadow ?? const <BoxShadow>[], isEmpty);
        expect(d.gradient, isNull);
      }
    });

    testWidgets('every theme re-tints from its own brand primary', (
      WidgetTester tester,
    ) async {
      for (final DabblerTheme theme in DabblerTheme.values) {
        await tester.pumpWidget(
          _host(const _Harness(initial: 'players'), theme: theme),
        );
        await tester.pumpAndSettle();

        final DabblerColors colors = _colors(theme: theme);
        expect(
          tester.widget<ColoredBox>(find.byType(ColoredBox).last).color,
          colors.brandPrimary,
          reason: 'the ${theme.name} indicator must use its own brand primary',
        );
      }
    });
  });

  // ------------------------------------------------------------------
  // RTL — order, indicator travel, and the scroller's axis.
  // ------------------------------------------------------------------
  group('RTL', () {
    testWidgets('visual order reverses', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const _Harness(), direction: TextDirection.rtl),
      );
      await tester.pumpAndSettle();

      expect(
        _tabRect(tester, 'overview').left,
        greaterThan(_tabRect(tester, 'chat').left),
      );
    });

    testWidgets('the indicator tracks the active tab under RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const _Harness(), direction: TextDirection.rtl),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byType(ColoredBox).last).right,
        moreOrLessEquals(_tabRect(tester, 'overview').right),
      );

      await tester.tap(find.text('chat'));
      await tester.pumpAndSettle();

      final Rect indicator = tester.getRect(find.byType(ColoredBox).last);
      final Rect tab = _tabRect(tester, 'chat');
      expect(indicator.left, moreOrLessEquals(tab.left));
      expect(indicator.width, moreOrLessEquals(tab.width));
    });
  });

  // ------------------------------------------------------------------
  // Scrollable — Tabs.jsx:45-53.
  // ------------------------------------------------------------------
  group('scrollable', () {
    const List<DabblerTabItem> many = <DabblerTabItem>[
      DabblerTabItem(id: 'a', label: 'aaaaaaaaaa'),
      DabblerTabItem(id: 'b', label: 'bbbbbbbbbb'),
      DabblerTabItem(id: 'c', label: 'cccccccccc'),
      DabblerTabItem(id: 'd', label: 'dddddddddd'),
      DabblerTabItem(id: 'e', label: 'eeeeeeeeee'),
      DabblerTabItem(id: 'f', label: 'ffffffffff'),
    ];

    testWidgets('a horizontal scroller appears only when asked', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const _Harness(items: many, initial: 'a'), width: 200),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsNothing);

      await tester.pumpWidget(
        _host(
          const _Harness(items: many, initial: 'a', scrollable: true),
          width: 200,
        ),
      );
      await tester.pumpAndSettle();
      final SingleChildScrollView view = tester
          .widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      expect(view.scrollDirection, Axis.horizontal);
    });

    testWidgets('selecting an off-screen tab scrolls it into view', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const _Harness(items: many, initial: 'a', scrollable: true),
          width: 200,
        ),
      );
      await tester.pumpAndSettle();

      final ScrollableState scrollable =
          tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.pixels, 0);

      // Arrow-key to the far end, which is the path that must not move
      // anything but the scroller.
      await tester.tap(find.text('aaaaaaaaaa'));
      await tester.pumpAndSettle();
      await _pressKey(tester, LogicalKeyboardKey.end);

      expect(scrollable.position.pixels, greaterThan(0));
      // Scrolled by the scroller's own offset only — the host never moved.
      expect(tester.getTopLeft(find.byType(DabblerTabs)).dy, 0);
    });

    testWidgets('segmented ignores scrollable, as the source does', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const _Harness(
            items: <DabblerTabItem>[
              DabblerTabItem(id: 'list', label: 'list'),
              DabblerTabItem(id: 'map', label: 'map'),
            ],
            initial: 'list',
            variant: DabblerTabsVariant.segmented,
            scrollable: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsNothing);
    });
  });

  // ------------------------------------------------------------------
  // Layout options.
  // ------------------------------------------------------------------
  group('fullWidth', () {
    testWidgets('splits the available width evenly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const _Harness(fullWidth: true), width: 300),
      );
      await tester.pumpAndSettle();

      final double a = _tabRect(tester, 'overview').width;
      final double b = _tabRect(tester, 'players').width;
      final double c = _tabRect(tester, 'chat').width;
      expect(a, moreOrLessEquals(b));
      expect(b, moreOrLessEquals(c));
    });

    testWidgets('segmented is always full width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const _Harness(
            items: <DabblerTabItem>[
              DabblerTabItem(id: 'list', label: 'list'),
              DabblerTabItem(id: 'map', label: 'mapmapmapmap'),
            ],
            initial: 'list',
            variant: DabblerTabsVariant.segmented,
          ),
          width: 300,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        _tabRect(tester, 'list').width,
        moreOrLessEquals(_tabRect(tester, 'mapmapmapmap').width),
      );
    });
  });

  // ------------------------------------------------------------------
  // Motion — --motion-base, and reduced motion.
  // ------------------------------------------------------------------
  group('motion', () {
    testWidgets('the indicator slides over --motion-base', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();

      final AnimatedPositionedDirectional indicator =
          tester.widget<AnimatedPositionedDirectional>(
        find.byType(AnimatedPositionedDirectional),
      );
      expect(indicator.duration, const Duration(milliseconds: 120));
      expect(indicator.curve, const Cubic(0.2, 0, 0.2, 1));
    });

    testWidgets('reduced motion drops the slide to zero', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const _Harness(), disableAnimations: true),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<AnimatedPositionedDirectional>(
              find.byType(AnimatedPositionedDirectional),
            )
            .duration,
        Duration.zero,
      );
    });
  });

  // ------------------------------------------------------------------
  // Semantics — the ARIA wiring of Tabs.jsx:97-104 and :155-156.
  // ------------------------------------------------------------------
  group('semantics', () {
    testWidgets('tablist, tabs, and the selected state', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const _Harness(label: 'game')));
      await tester.pumpAndSettle();

      final SemanticsNode list = tester.getSemantics(
        find.byWidgetPredicate(
          (Widget w) => w is Semantics && w.properties.role == SemanticsRole.tabBar,
        ),
      );
      expect(list.role, SemanticsRole.tabBar);
      expect(list.label, 'game');

      final List<SemanticsNode> tabs = <SemanticsNode>[];
      list.visitChildren((SemanticsNode child) {
        tabs.add(child);
        return true;
      });

      expect(tabs.length, _items.length);
      expect(tabs.map((SemanticsNode n) => n.role),
          everyElement(SemanticsRole.tab));
      expect(tabs.map((SemanticsNode n) => n.label),
          <String>['overview', 'players', 'chat']);
      expect(
        tabs.map((SemanticsNode n) =>
            n.getSemanticsData().flagsCollection.isSelected.name),
        <String>['isTrue', 'isFalse', 'isFalse'],
      );
      expect(
        tabs.every((SemanticsNode n) =>
            n.getSemanticsData().hasAction(SemanticsAction.tap)),
        isTrue,
      );
      handle.dispose();
    });

    testWidgets('each tab names the panel it controls', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();

      final SemanticsNode tab = tester.getSemantics(
        find.byWidgetPredicate(
          (Widget w) => w is Semantics && w.properties.label == 'players',
        ),
      );
      expect(
        tab.getSemanticsData().controlsNodes,
        <String>{DabblerTabPanel.semanticsIdentifier('players')},
      );
      handle.dispose();
    });

    testWidgets('the panel carries the tabPanel role and its identifier', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();

      final SemanticsNode panel =
          tester.getSemantics(find.text('panel:overview'));
      expect(panel.role, SemanticsRole.tabPanel);
      expect(panel.identifier,
          DabblerTabPanel.semanticsIdentifier('overview'));
      handle.dispose();
    });
  });

  // ------------------------------------------------------------------
  // Edges.
  // ------------------------------------------------------------------
  group('edges', () {
    testWidgets('an empty strip builds and draws no indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerTabs(items: <DabblerTabItem>[])),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DabblerTabs), findsOneWidget);
      expect(find.byType(AnimatedPositionedDirectional), findsNothing);
    });

    testWidgets('an arrow key on an empty strip does nothing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerTabs(items: <DabblerTabItem>[])),
      );
      await tester.pumpAndSettle();
      await _pressKey(tester, LogicalKeyboardKey.arrowRight);

      expect(tester.takeException(), isNull);
    });

    testWidgets('growing and shrinking the item list keeps nodes in step', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        _host(
          const _Harness(
            items: <DabblerTabItem>[
              DabblerTabItem(id: 'overview', label: 'overview'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DabblerFocusRing), findsOneWidget);

      await tester.pumpWidget(_host(const _Harness()));
      await tester.pumpAndSettle();
      expect(find.byType(DabblerFocusRing), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('icon and badge slots render around the label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const _Harness(
            items: <DabblerTabItem>[
              DabblerTabItem(
                id: 'players',
                label: 'players',
                icon: Text('I'),
                badge: Text('8'),
              ),
            ],
            initial: 'players',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getCenter(find.text('I')).dx,
        lessThan(tester.getCenter(find.text('players')).dx),
      );
      expect(
        tester.getCenter(find.text('8')).dx,
        greaterThan(tester.getCenter(find.text('players')).dx),
      );
    });
  });
}
