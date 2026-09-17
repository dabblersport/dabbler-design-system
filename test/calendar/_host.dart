import 'dart:math' as math;

import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The specimen's card width — `calendar.card.html:20` gives the Calendar a
/// `320` box.
const double specimenWidth = 320;

/// A typical phone width, used to measure the wider of the two touch-target
/// claims in [DabblerCalendar]'s doc.
const double phoneWidth = 375;

DabblerColors colorsFor({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

/// A [ThemeData] carrying [DabblerColors], a direction and a bounded width —
/// the same minimum `test/layout/section_test.dart` uses, so geometry
/// assertions have a fixed frame.
Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  Brightness brightness = Brightness.light,
  DabblerTheme theme = DabblerTheme.main,
  double width = specimenWidth,
}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[
        colorsFor(theme: theme, brightness: brightness),
      ],
    ),
    home: Directionality(
      textDirection: direction,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

/// Eastern Arabic-Indic `٠`–`٩` and extended Arabic-Indic `۰`–`۹`.
bool isArabicIndicDigit(int rune) =>
    (rune >= 0x0660 && rune <= 0x0669) || (rune >= 0x06F0 && rune <= 0x06F9);

/// Every string this subtree lays out.
List<String> renderedStrings(WidgetTester tester, Finder root) => tester
    .widgetList<Text>(find.descendant(of: root, matching: find.byType(Text)))
    .map((Text t) => t.data ?? '')
    .where((String s) => s.isNotEmpty)
    .toList();

/// The WCAG 2.x relative luminance of [color], composited over white.
///
/// Every colour asserted in these tests is opaque, so the composite is a
/// no-op; it is done anyway so an alpha that creeps in later fails loudly
/// rather than silently measuring the wrong thing.
double relativeLuminance(Color color) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// The WCAG 2.x contrast ratio between two opaque colours.
double contrastRatio(Color a, Color b) {
  final double la = relativeLuminance(a);
  final double lb = relativeLuminance(b);
  final double lighter = la > lb ? la : lb;
  final double darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}
