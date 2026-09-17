import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';

/// The width every control under test is laid out in, so edge and fraction
/// assertions have a fixed frame. Mirrors `test/forms/text_field_test.dart`.
const double hostWidth = 320;

/// The resolved token set the assertions compare against — never a literal.
DabblerColors testColors({
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) =>
    DabblerColors.resolve(theme: theme, brightness: brightness);

/// A minimal app around [child], at [direction] and [brightness].
Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  Brightness brightness = Brightness.light,
  double width = hostWidth,
}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[
        testColors(brightness: brightness),
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
