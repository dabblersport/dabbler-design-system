/// The gallery's theme and brightness switcher.
///
/// `DabblerColors.resolve` answers for seven themes x two brightnesses. What
/// these tests pin is that the control actually reaches the other thirteen —
/// that a selection changes the [DabblerColors] every component reads, and
/// that opening a component and coming back does not put it back to `main`.
library;

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:dabbler_design_system/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The colours a component would resolve at [finder]'s context — the same
/// lookup every widget in this package makes.
DabblerColors _colorsAt(WidgetTester tester, Finder finder) =>
    DabblerColors.of(tester.element(finder));

/// Every fill actually painted by a [DecoratedBox] inside the specimen band of
/// a rendered entry screen.
///
/// AC8 is worded to rule out a state variable standing in for a rendered
/// change, so this reads the paint: the fills come off the widgets that carry
/// the [BoxDecoration] the components draw themselves with.
///
/// Scoped to [GalleryGroup] — the band the entry screen puts the specimen in —
/// rather than to [GallerySpecimen]. Both scopes exclude the switcher's own
/// trigger buttons, which sit in the page header, but [GallerySpecimen] is a
/// layout helper a component may or may not use: `'Button — tones x states'`
/// was rewritten as a bare matrix with no [GallerySpecimen] in it, and this
/// helper silently returned an empty set for that entry. The band is part of
/// the chrome and is therefore always there.
Set<Color?> _paintedFills(WidgetTester tester) => <Color?>{
      for (final Element element in find
          .descendant(
            of: find.byType(GalleryGroup),
            matching: find.byType(DecoratedBox),
          )
          .evaluate())
        ((element.widget as DecoratedBox).decoration as BoxDecoration).color,
    };

/// Opens the first catalogue entry for the component named [component],
/// scrolling the catalogue to reach it.
///
/// Found by the tile's own entry rather than by its text, for two reasons.
/// The chrome rebuild made the catalogue a band of [GalleryIndexTile]s that
/// split `'<Component> — <subject>'` across two lines, so the full title is no
/// longer a single string on screen. And matching on the component half alone
/// means a component renaming one of its specimens — `'Button — tones'` became
/// `'Button — tones × states'` while this suite was being updated — no longer
/// breaks a test that never cared which of that component's entries it opened.
Future<void> _openEntry(WidgetTester tester, String component) async {
  final Finder tile = find
      .byWidgetPredicate(
        (Widget w) =>
            w is GalleryIndexTile && w.entry.title.split(' — ').first == component,
      )
      .first;
  await tester.scrollUntilVisible(tile, 200);
  await tester.pumpAndSettle();
  await tester.tap(tile);
  // Not pumpAndSettle, for the reason `test/gallery_test.dart` gives: several
  // specimens are deliberately perpetual — a loading button, the spinner, the
  // shimmering skeleton — and settling would never return. Two pumps past the
  // route's 160ms fade is enough to build, lay out and paint the entry.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Opens the switcher menu whose trigger currently reads [triggerLabel], and
/// chooses [choice].
///
/// Bounded pumps rather than `pumpAndSettle` for the same reason [_openEntry]
/// uses them: the switcher is on every entry screen, so this runs with a
/// perpetual specimen — a loading button, a spinner — already on screen, and
/// settling would never return.
Future<void> _choose(
  WidgetTester tester,
  String triggerLabel,
  String choice,
) async {
  await tester.tap(find.widgetWithText(DabblerButton, triggerLabel));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.widgetWithText(DabblerMenuItem, choice));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('the switcher is on the index and on every entry screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GalleryApp(entries: galleryEntries));
    await tester.pumpAndSettle();
    expect(find.byType(GalleryThemeSwitcher), findsOneWidget);

    await tester.tap(find.byType(GalleryIndexTile).first);
    await tester.pumpAndSettle();
    expect(find.byType(GalleryEntryScreen), findsOneWidget);
    expect(
      find.byType(GalleryThemeSwitcher),
      findsOneWidget,
      reason: 'a component screen is exactly where a reviewer switches theme',
    );
  });

  testWidgets('switching theme changes what a rendered component paints (AC8)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GalleryApp(entries: galleryEntries));
    await tester.pumpAndSettle();
    await _openEntry(tester, 'Button');

    Color brandOf(DabblerTheme theme) => DabblerColors.resolve(
          theme: theme,
          brightness: Brightness.light,
        ).brandPrimary;

    expect(
      _paintedFills(tester),
      contains(brandOf(DabblerTheme.main)),
      reason: 'the primary button paints --color-brand-primary of the theme',
    );
    expect(_paintedFills(tester), isNot(contains(brandOf(DabblerTheme.sport))));

    await _choose(tester, 'Main', 'Sport');

    expect(
      _paintedFills(tester),
      contains(brandOf(DabblerTheme.sport)),
      reason: 'AC8 — the specimen must actually repaint, not merely be told to',
    );
    expect(
      _paintedFills(tester),
      isNot(contains(brandOf(DabblerTheme.main))),
      reason: 'the old theme\'s brand must be gone from the paint',
    );
  });

  testWidgets('choosing a theme changes the colours components render with', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GalleryApp(entries: galleryEntries));
    await tester.pumpAndSettle();

    final Finder screen = find.byType(GalleryHomeScreen);
    expect(_colorsAt(tester, screen).brandPrimary,
        DabblerColors.resolve(theme: DabblerTheme.main,
                brightness: Brightness.light)
            .brandPrimary);

    await _choose(tester, 'Main', 'Sport');

    expect(
      _colorsAt(tester, screen).brandPrimary,
      DabblerColors.resolve(
        theme: DabblerTheme.sport,
        brightness: Brightness.light,
      ).brandPrimary,
      reason: 'the selection must drive DabblerColors for the whole subtree',
    );
    expect(find.widgetWithText(DabblerButton, 'Sport'), findsOneWidget);
  });

  testWidgets('choosing a brightness switches the resolved ramp', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GalleryApp(entries: galleryEntries));
    await tester.pumpAndSettle();

    final Finder screen = find.byType(GalleryHomeScreen);
    await _choose(tester, 'Light', 'Dark');

    final DabblerColors dark = DabblerColors.resolve(
      theme: DabblerTheme.main,
      brightness: Brightness.dark,
    );
    expect(_colorsAt(tester, screen).bgPrimary, dark.bgPrimary);
    expect(Theme.of(tester.element(screen)).brightness, Brightness.dark);

    await _choose(tester, 'Dark', 'Light');
    expect(
      _colorsAt(tester, screen).bgPrimary,
      DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      ).bgPrimary,
    );
  });

  testWidgets('the choice survives opening a component and coming back (AC9)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GalleryApp(entries: galleryEntries));
    await tester.pumpAndSettle();

    await _choose(tester, 'Main', 'Social');
    await _choose(tester, 'Light', 'Dark');

    final DabblerColors expected = DabblerColors.resolve(
      theme: DabblerTheme.social,
      brightness: Brightness.dark,
    );

    await _openEntry(tester, 'Button');
    expect(
      _paintedFills(tester),
      contains(expected.brandPrimary),
      reason: 'the pushed route paints under the chosen appearance',
    );
    expect(find.widgetWithText(DabblerButton, 'Social'), findsOneWidget);
    expect(find.widgetWithText(DabblerButton, 'Dark'), findsOneWidget);

    // Not `tester.pageBack()`: that helper hunts for a Material or Cupertino
    // back button, and the chrome rebuild replaced the `AppBar` with the
    // design's own page header, whose back affordance is a [DabblerButton].
    // Tapping the real control is also the truer assertion.
    await tester.tap(find.widgetWithText(DabblerButton, 'Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      _colorsAt(tester, find.byType(GalleryHomeScreen)).brandPrimary,
      expected.brandPrimary,
      reason: 'coming back must not reset the choice',
    );

    // …and going in a second time still paints it, which is the half a
    // surviving *state variable* would pass without the paint following.
    await _openEntry(tester, 'Button');
    expect(_paintedFills(tester), contains(expected.brandPrimary));
    expect(
      _paintedFills(tester),
      isNot(
        contains(
          DabblerColors.resolve(
            theme: DabblerTheme.main,
            brightness: Brightness.light,
          ).brandPrimary,
        ),
      ),
    );
  });

  testWidgets('every one of the seven themes is offered', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GalleryApp(entries: galleryEntries));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(DabblerButton, 'Main'));
    await tester.pumpAndSettle();
    for (final DabblerTheme theme in DabblerTheme.values) {
      expect(
        find.widgetWithText(DabblerMenuItem, galleryThemeLabel(theme)),
        findsOneWidget,
        reason: '${theme.name} is unreviewable if it is not in the picker',
      );
    }
  });
}
