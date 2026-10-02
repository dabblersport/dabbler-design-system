import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';

/// The light main-theme colours every atoms test resolves against.
DabblerColors atomColors() => DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

/// Hosts [child] at [width] under [direction], optionally with reduced motion.
Widget atomHost(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 360,
  bool reduceMotion = false,
}) {
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[atomColors()]),
    home: Builder(
      builder: (BuildContext context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: width, child: child),
            ),
          ),
        ),
      ),
    ),
  );
}
