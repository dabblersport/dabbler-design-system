import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';

/// Shared host for the thread-part tests (KAN-412 gaps 5 item 9).
final DabblerColors threadColors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget threadHost(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  MediaQueryData? media,
}) {
  Widget app = MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[threadColors]),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 360,
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    ),
  );
  if (media != null) app = MediaQuery(data: media, child: app);
  return app;
}
