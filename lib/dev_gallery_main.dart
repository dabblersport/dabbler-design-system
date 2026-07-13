// =============================================================================
// Dev-only entrypoint — boots straight into the debug Theme Gallery on web.
// The default web target (lib/main.dart) serves the public docs site instead.
//
//   flutter run -d chrome -t lib/dev_gallery_main.dart
// =============================================================================

import 'package:flutter/material.dart';

import 'debug/theme_gallery.dart';
import 'theme/dabbler_colors.dart';
import 'theme/dabbler_theme_data.dart';

void main() => runApp(const _GalleryDevApp());

class _GalleryDevApp extends StatelessWidget {
  const _GalleryDevApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dabbler Theme Gallery (dev)',
      debugShowCheckedModeBanner: false,
      theme: dabblerThemeData(DabblerTheme.main, Brightness.light),
      home: const ThemeGalleryScreen(),
    );
  }
}
