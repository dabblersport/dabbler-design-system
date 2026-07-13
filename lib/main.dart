// =============================================================================
// Dabbler Design System — entry point
// -----------------------------------------------------------------------------
// Resolves SharedPreferences up front and injects it into the provider scope so
// the theme controller can read the persisted override + ThemeMode synchronously
// on first frame (no theme flash).
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'docs/docs_app.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The web build is the public documentation site (deploys to GitHub Pages).
  if (kIsWeb) {
    runApp(const DocsApp());
    return;
  }

  // Native keeps the app shell (with the debug Theme Gallery route).
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const DabblerApp(),
    ),
  );
}
