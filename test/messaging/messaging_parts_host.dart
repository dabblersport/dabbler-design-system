// Shared host for the messaging-parts tests (not a test file itself).
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';

DabblerColors partsColors([Brightness b = Brightness.light]) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: b);

Widget partsHost(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 360,
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[partsColors(brightness)],
    ),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}
