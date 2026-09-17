import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';

/// The minimum a widget test of an interaction primitive needs: a
/// [Directionality], a [MediaQuery] whose `disableAnimations` the test
/// controls, and a [DabblerColors] in the theme for `DabblerColors.of` to
/// find.
Widget host(
  Widget child, {
  bool disableAnimations = false,
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
}) {
  final DabblerColors colors =
      DabblerColors.resolve(theme: theme, brightness: brightness);
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Directionality(
      textDirection: textDirection,
      child: Theme(
        data: ThemeData(
          extensions: <ThemeExtension<dynamic>>[colors],
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: child,
        ),
      ),
    ),
  );
}
